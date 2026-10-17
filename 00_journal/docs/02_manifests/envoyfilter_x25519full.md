# Documentation for envoyfilter x25519

## Which cipher ?
- standard default one probalby gcm 
- standard curve x25519
- mtls 1.3

# What is diffrent !
- handshake every connection no reuse
- `max_session_keys: 0` and `disable_stateless_session_resumption: true   
          disable_stateful_session_resumption: true` - fore to do  handshake each connection