# DNS Tunnels

The last transports standing. When a network blocks or throttles almost everything, DNS usually still resolves — because breaking it breaks the whole internet for everyone. DNS tunnels smuggle traffic inside DNS queries, so they keep working during shutdowns that kill every other protocol.

They are **slow**. Treat them as the fallback that keeps chat and messaging alive, not as your everyday transport.

MoaV runs **four** of them, **all at once**, on the same port 53. `dns-router` listens on 53 and fans queries out by subdomain suffix, so `t.` goes to dnstt, `s.` to Slipstream, and so on. There is no "pick one at install" step; users get whichever their client supports.

## Which one should I use?

| Tunnel | Subdomain | Speed vs dnstt | Loss resilience | Best for |
|---|---|---|---|---|
| **dnstt** | `t` | 1× *(baseline)* | low | **Widest client support** — a standalone client on 25+ platforms |
| **Slipstream** | `s` | 1.5–5× | medium | Faster general use where a Slipstream client exists |
| **MasterDNS** | `m` | up to 9× | **high** *(ARQ + packet duplication + multi-resolver)* | **Harsh shutdowns**, and native import in [MahsaNG v16](mahsanet.md) |
| **XDNS** | `x` | ~1× | low | FinalMask-aware clients (Happ, Xray CLI); per-user auth |

**Short answer:** for Iran during heavy throttling or a blackout, **MasterDNS** is the strongest, and it works straight from the MahsaNG app. Offer **dnstt** as well, because its client runs almost everywhere.

All four are enabled by default. Opt any of them out with `ENABLE_DNSTT` / `ENABLE_SLIPSTREAM` / `ENABLE_MASTERDNS` / `ENABLE_XDNS` in `.env` — a disabled tunnel's container simply stays down and `dns-router` stops routing to it.

Or set the combination in one command:

```bash
moav switch-dns                                    # show what's on
moav switch-dns dnstt+slipstream+masterdns+xdns    # all four
moav switch-dns dnstt+slipstream                   # the classic pair
moav switch-dns off                                # no DNS tunnels
```

!!! warning "The client's resolver matters more than the tunnel"
    Every DNS tunnel needs a public resolver **the client can still reach**. `1.1.1.1` and `8.8.8.8` are commonly throttled or null-routed exactly when you need a tunnel. XDNS round-robins across `XDNS_RESOLVERS`; dnstt and Slipstream take a resolver flag on the client side. Tools like [findns](https://github.com/SamNet-dev/findns) and [dns-mns](https://gitlab.com/E-Gurl/dns-mns) scan for resolvers that still work on a given network — see [Protocols → reachable resolvers](protocols.md#reachable-dns-resolvers).

## Setup

All four need the same two things, covered in the [DNS Configuration](DNS.md#with-a-domain-the-records) page:

1. An **A record** for `dns.yourdomain.com` → your server. This is the nameserver.
2. An **NS delegation** per tunnel: `t`, `s`, `m`, `x` → `dns.yourdomain.com`.

Port **53/udp** must reach your server. On a home network that means forwarding it, and some ISPs block 53 outright.

## The four, in detail

### dnstt

Encodes a TCP stream inside DNS queries using KCP + Noise. Extremely hard to block without breaking DNS itself. The slowest of the four, and the most widely supported.

- **Port:** 53/udp *(subdomain `t`)* · **Engine:** [dnstt](https://www.bamsoftware.com/software/dnstt/)
- **Clients:** standalone dnstt client on 25+ platforms
- **Requires:** domain + NS delegation

### Slipstream

Same idea over **QUIC**, which buys real throughput — typically 1.5–5× dnstt.

- **Port:** 53/udp *(subdomain `s`)* · **Engine:** [slipstream-rust](https://github.com/Mygod/slipstream-rust) · [pre-built binaries](https://github.com/net2share/slipstream-rust-build/releases)
- **Requires:** domain + NS delegation

### MasterDNS

The most resilient of the four: low-overhead ARQ, packet duplication and resolver load-balancing, which is what makes it hold up on lossy, throttled links. This is the MasterDNS component bundled in **MahsaNG v16**, so that app connects directly with no extra client.

- **Port:** 53/udp *(subdomain `MASTERDNS_SUBDOMAIN`, default `m`)* · **Engine:** [MasterDnsVPN](https://github.com/masterking32/MasterDnsVPN) (Go)
- **Clients:** MahsaNG v16+, or the standalone client (Linux/Windows/macOS/Termux)
- **Encryption:** AES-256-GCM (`DATA_ENCRYPTION_METHOD=5`); the shared key ships in each user's bundle
- **Extra:** set `MASTERDNS_PUBLIC_SUBDOMAIN` to publish a *different* delegation name than the one used internally — generated bundles then use the public one

### XDNS

Xray-core's mKCP transport with FinalMask. Adds **per-user authentication**, which the other three don't have, at the cost of needing a FinalMask-aware client.

- **Port:** 53/udp *(subdomain `x`)* · **Engine:** [Xray-core](https://github.com/XTLS/Xray-core) *(built from main for FinalMask)*
- **Clients:** Happ (beta), Xray CLI. **Not** standard v2rayNG yet.
- **Best for:** Telegram and light chat apps — not fast enough for browsing

## Verifying a tunnel

```bash
moav doctor dns                          # delegations, records, and tunnel health
dig NS t.yourdomain.com                  # → dns.yourdomain.com in AUTHORITY
dig @YOUR_SERVER_IP test.t.yourdomain.com   # → a response once the tunnel is up
```

If the NS delegation resolves but the tunnel won't connect, the usual causes are: the tunnel's `ENABLE_*` is `false`, port 53/udp isn't reaching the server, or the **client's** resolver is blocked (see the warning above). More in [DNS troubleshooting](DNS.md#troubleshooting).
