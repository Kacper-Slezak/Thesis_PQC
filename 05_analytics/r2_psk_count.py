"""R2: count TLS 1.3 resumption offers and acceptances in a pcap (stdlib only).

For every TCP connection: the first ClientHello and ServerHello are reassembled from the
TCP payload (a hybrid ML-KEM ClientHello is ~1.6 KB, so it may span two segments) and checked
for the pre_shared_key extension (type 41, RFC 8446 §4.2.11):
  - ClientHello with ext 41 -> the client offered a ticket
  - ServerHello with ext 41 -> the server accepted it (resumed handshake)
offers ~= accepts  => incomplete resumption comes from the client not having a ticket (H-R1)
offers >> accepts  => the server rejects tickets (H-R2)

Usage: python3 -I 05_analytics/r2_psk_count.py capture.pcap [port]
"""
import struct
import sys

EXT_PSK = 41


def packets(path):
    """Yield (src, sport, dst, dport, seq, flags, payload) for IPv4/IPv6 TCP packets."""
    with open(path, "rb") as f:
        hdr = f.read(24)
        magic = struct.unpack("<I", hdr[:4])[0]
        end = "<" if magic in (0xA1B2C3D4, 0xA1B23C4D) else ">"
        link = struct.unpack(end + "I", hdr[20:24])[0]
        while True:
            rec = f.read(16)
            if len(rec) < 16:
                return
            incl = struct.unpack(end + "I", rec[8:12])[0]
            data = f.read(incl)
            if link == 1:          # Ethernet
                etype, off = struct.unpack(">H", data[12:14])[0], 14
            elif link == 113:      # Linux cooked (SLL)
                etype, off = struct.unpack(">H", data[14:16])[0], 16
            elif link == 276:      # Linux cooked v2 (SLL2)
                etype, off = struct.unpack(">H", data[0:2])[0], 20
            else:
                raise SystemExit(f"unsupported link type {link}")
            if etype == 0x0800:
                ihl = (data[off] & 0x0F) * 4
                if data[off + 9] != 6:
                    continue
                src, dst = data[off + 12:off + 16], data[off + 16:off + 20]
                total = struct.unpack(">H", data[off + 2:off + 4])[0]
                tcp, end_ip = off + ihl, off + total
            elif etype == 0x86DD:
                if data[off + 6] != 6:
                    continue
                src, dst = data[off + 8:off + 24], data[off + 24:off + 40]
                plen = struct.unpack(">H", data[off + 4:off + 6])[0]
                tcp, end_ip = off + 40, off + 40 + plen
            else:
                continue
            sport, dport, seq = struct.unpack(">HHI", data[tcp:tcp + 8])
            doff = (data[tcp + 12] >> 4) * 4
            flags = data[tcp + 13]
            yield src, sport, dst, dport, seq, flags, data[tcp + doff:end_ip]


def first_handshake(stream):
    """Parse the first TLS handshake message; return (type, has_psk) or None if incomplete."""
    if len(stream) < 5 or stream[0] != 22:
        return None
    # concatenate handshake-record fragments until the first message is complete
    hs, i = b"", 0
    while i + 5 <= len(stream) and stream[i] == 22:
        rlen = struct.unpack(">H", stream[i + 3:i + 5])[0]
        hs += stream[i + 5:i + 5 + rlen]
        i += 5 + rlen
        if len(hs) >= 4 and len(hs) >= 4 + int.from_bytes(hs[1:4], "big"):
            break
    if len(hs) < 4:
        return None
    htype, hlen = hs[0], int.from_bytes(hs[1:4], "big")
    if len(hs) < 4 + hlen:
        return None
    body = hs[4:4 + hlen]
    p = 2 + 32                                   # legacy_version, random
    p += 1 + body[p]                             # session id
    if htype == 1:                               # ClientHello
        p += 2 + struct.unpack(">H", body[p:p + 2])[0]   # cipher suites
        p += 1 + body[p]                                 # compression methods
    elif htype == 2:                             # ServerHello
        p += 2 + 1                                       # cipher suite, compression
    else:
        return htype, False
    if p + 2 > len(body):
        return htype, False
    ext_end = p + 2 + struct.unpack(">H", body[p:p + 2])[0]
    p += 2
    while p + 4 <= ext_end:
        etype, elen = struct.unpack(">HH", body[p:p + 4])
        if etype == EXT_PSK:
            return htype, True
        p += 4 + elen
    return htype, False


def count(path, port=8080):
    """Return dict with ClientHello/ServerHello counts, with and without PSK."""
    isn, segs = {}, {}
    for src, sport, dst, dport, seq, flags, payload in packets(path):
        if port not in (sport, dport):
            continue
        key = (src, sport, dst, dport)
        if flags & 0x02:                         # SYN (or SYN-ACK): next byte is ISN + 1
            isn[key] = seq + 1
            continue
        if payload and key in isn:
            rel = (seq - isn[key]) & 0xFFFFFFFF
            if rel < 16384:                      # the hello is at the start of the stream
                segs.setdefault(key, {})[rel] = payload
    c = {"client_hello": 0, "client_hello_psk": 0, "server_hello": 0, "server_hello_psk": 0,
         "incomplete": 0}
    for key, parts in segs.items():
        stream = b""
        for rel in sorted(parts):
            if rel > len(stream):
                break                            # gap: a segment was not captured
            stream += parts[rel][len(stream) - rel:]
        r = first_handshake(stream)
        if r is None:
            c["incomplete"] += 1
        elif r[0] == 1:
            c["client_hello"] += 1
            c["client_hello_psk"] += r[1]
        elif r[0] == 2:
            c["server_hello"] += 1
            c["server_hello_psk"] += r[1]
    return c


if __name__ == "__main__":
    res = count(sys.argv[1], int(sys.argv[2]) if len(sys.argv) > 2 else 8080)
    for k, v in res.items():
        print(f"{k:18s} {v}")
    ch, sh = res["client_hello"], res["server_hello"]
    if ch:
        print(f"offer_share        {res['client_hello_psk'] / ch:.3f}   (ClientHello with PSK / ClientHello)")
    if sh:
        print(f"accept_share       {res['server_hello_psk'] / sh:.3f}   (ServerHello with PSK / ServerHello)")
    if res["client_hello_psk"]:
        print(f"accept_of_offers   {res['server_hello_psk'] / res['client_hello_psk']:.3f}")
