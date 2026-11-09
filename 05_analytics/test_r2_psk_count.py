"""Test of r2_psk_count.py on a synthetic pcap. Run: python3 -I 05_analytics/test_r2_psk_count.py"""
import os
import struct
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from r2_psk_count import count  # noqa: E402


def ext(t, body):
    return struct.pack(">HH", t, len(body)) + body


def hello(htype, psk, pad):
    """ClientHello (1) or ServerHello (2) with a key_share of `pad` bytes and optional PSK ext."""
    exts = ext(51, b"\x00" * pad) + (ext(41, b"\x00" * 40) if psk else b"")
    body = b"\x03\x03" + b"\x11" * 32 + b"\x20" + b"\x22" * 32
    body += (b"\x00\x02\x13\x01\x01\x00") if htype == 1 else b"\x13\x01\x00"
    body += struct.pack(">H", len(exts)) + exts
    msg = bytes([htype]) + len(body).to_bytes(3, "big") + body
    return b"\x16\x03\x01" + struct.pack(">H", len(msg)) + msg


def tcp_pkt(sport, dport, seq, flags, payload):
    tcp = struct.pack(">HHIIBBHHH", sport, dport, seq, 0, 5 << 4, flags, 65535, 0, 0)
    ip = struct.pack(">BBHHHBBH4s4s", 0x45, 0, 20 + len(tcp) + len(payload), 0, 0, 64, 6, 0,
                     bytes([10, 0, 0, 1]), bytes([10, 0, 0, 2]))
    eth = b"\x00" * 12 + b"\x08\x00"
    return eth + ip + tcp + payload


def write_pcap(path, pkts):
    with open(path, "wb") as f:
        f.write(struct.pack("<IHHiIII", 0xA1B2C3D4, 2, 4, 0, 0, 65535, 1))
        for p in pkts:
            f.write(struct.pack("<IIII", 0, 0, len(p), len(p)) + p)


def connection(cport, ch_psk, sh_psk, split, reverse=False):
    ch = hello(1, ch_psk, 1216)              # ~ hybrid ML-KEM key share, > 1 segment
    sh = hello(2, sh_psk, 1120)
    c_isn, s_isn = 1000, 5000
    cseg = [(c_isn + 1, ch[:split]), (c_isn + 1 + split, ch[split:])]
    if reverse:
        cseg.reverse()
    pk = [tcp_pkt(cport, 8080, c_isn, 0x02, b""), tcp_pkt(8080, cport, s_isn, 0x12, b"")]
    pk += [tcp_pkt(cport, 8080, s, 0x18, d) for s, d in cseg]
    pk += [tcp_pkt(8080, cport, s_isn + 1, 0x18, sh)]
    return pk


def main():
    pkts = []
    pkts += connection(40001, ch_psk=False, sh_psk=False, split=1400)
    pkts += connection(40002, ch_psk=True, sh_psk=True, split=1400, reverse=True)
    pkts += connection(40003, ch_psk=True, sh_psk=False, split=100)
    pkts += connection(40004, ch_psk=True, sh_psk=True, split=1400)
    with tempfile.TemporaryDirectory() as d:
        p = os.path.join(d, "t.pcap")
        write_pcap(p, pkts)
        c = count(p)
    want = {"client_hello": 4, "client_hello_psk": 3, "server_hello": 4, "server_hello_psk": 2,
            "incomplete": 0}
    assert c == want, c
    print("OK", c)


if __name__ == "__main__":
    main()
