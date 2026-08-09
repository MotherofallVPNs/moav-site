# Supported Protocols

MoaV deploys 16+ protocols, each with different stealth characteristics, speed profiles, and network requirements. This diversity ensures that when one protocol is blocked, others remain available.

## Protocol Overview

<!-- BEGIN gen:overview-table -->
| Protocol | Port | Stealth | Speed | Domain Required |
|----------|------|---------|-------|-----------------|
| [Reality (VLESS)](#reality-vless) | 443/tcp | Very High | High | No |
| [Trojan](#trojan) | 8443/tcp | High | High | Yes |
| [AnyTLS](#anytls) | 8445/tcp | Very High | High | Yes |
| [Hysteria2](#hysteria2) | 443/udp | High | Very High | Yes |
| [Shadowsocks-2022](#shadowsocks-2022) | 8388/tcp+udp | High | Very High | No |
| [CDN (VLESS+WS)](#cdn-vlessws) | 443 via CDN | Very High | Medium | Yes (Cloudflare) |
| [TrustTunnel](#trusttunnel) | 4443/tcp+udp | Very High | High | Yes |
| [WireGuard](#wireguard) | 51820/udp | Medium | Very High | No |
| [AmneziaWG](#amneziawg) | 51821/udp | Very High | High | No |
| [WireGuard (wstunnel)](#wireguard-wstunnel) | 8080/tcp | High | High | No |
| [Telegram MTProxy](#telegram-mtproxy) | 993/tcp | High | Medium | No |
| [dnstt](#dnstt) | 53/udp | Medium | Low | Yes |
| [Slipstream](#slipstream) | 53/udp | Medium | Low-Medium | Yes |
| [MasterDNS](#masterdns) | 53/udp | Medium | Medium | Yes |
| [GooseRelay](#gooserelay) | 8444/tcp | Very High | Low-Medium | No |
| [Psiphon Conduit](#psiphon-conduit) | dynamic | High | Medium | No |
| [XHTTP (VLESS+XHTTP+Reality)](#xhttp-vlessxhttpreality) | 2096/tcp | Very High | High | No |
| [XDNS (VLESS+mKCP+DNS)](#xdns-vlessmkcpdns) | 53/udp | Medium | Low | Yes |
| [Tor Snowflake](#tor-snowflake) | dynamic | High | Low | No |
| [MahsaNet](#mahsanet) | — | — | — | No |
<!-- END gen:overview-table -->

## Protocols in Detail

### Reality (VLESS)

**Primary protocol.** VLESS with Reality makes your proxy traffic indistinguishable from a real TLS connection to a legitimate website (e.g., `dl.google.com`). The server presents a genuine TLS certificate from the target site, passing even active probing.

- **Port:** 443/tcp
- **Engine:** [sing-box](https://github.com/SagerNet/sing-box)
- **Clients:** Streisand, Hiddify, v2rayNG, v2rayN, NekoBox

### Trojan

Password-authenticated TLS proxy. Traffic looks like normal HTTPS. Uses your domain's real TLS certificate from Let's Encrypt.

- **Port:** 8443/tcp
- **Engine:** [sing-box](https://github.com/SagerNet/sing-box)
- **Clients:** Streisand, Hiddify, v2rayNG, v2rayN, Shadowrocket

### AnyTLS

Password-authenticated TLS proxy designed to defeat **TLS-in-TLS fingerprinting**. By varying record sizes and padding, AnyTLS removes the tell-tale TLS-inside-TLS pattern that DPI uses to detect TLS-tunneling proxies, giving it very high stealth. Reuses the same sing-box engine, the Trojan TLS certificate, and your server domain.

- **Port:** 8445/tcp
- **Engine:** [sing-box](https://github.com/SagerNet/sing-box) (1.13.x)
- **Clients:** Hiddify, sing-box (SFA/SFI), NekoBox/NekoRay, Mihomo Party, Shadowrocket 2.2.65+
- **Note:** Opt-in — enable with `ENABLE_ANYTLS=true`. Requires a domain (TLS). Client support is narrower than VLESS/Trojan; older or Clash-only clients (v2rayNG, Streisand, V2Box, Clash Verge) do **not** support AnyTLS.

### Hysteria2

QUIC-based protocol optimized for high throughput on lossy networks. Includes built-in obfuscation to bypass QUIC blocking.

- **Port:** 443/udp
- **Engine:** [sing-box](https://github.com/SagerNet/sing-box)
- **Clients:** Streisand, Hiddify, v2rayNG, v2rayN
- **Note:** Requires UDP. Blocked in some censored networks that drop all non-DNS UDP.
- **Congestion control:** `up_mbps`/`down_mbps` are left unset and `ignore_client_bandwidth: true` is set, keeping both ends on BBR and stopping a client-advertised bandwidth from switching the link to Brutal (which can saturate a low-RAM VPS). This BBR is Hysteria2's own QUIC-layer controller inside sing-box — unrelated to the kernel `tcp_bbr` module, so it has no host dependency.

### Shadowsocks-2022

AEAD-2022 Shadowsocks (`2022-blake3-aes-128-gcm`), the modern Shadowsocks generation with per-user keys and built-in resistance to active probing and replay attacks. Needs **no domain and no TLS certificate**, so it works in domainless mode and is a good fallback when certificate-based protocols aren't an option. Wire-compatible with the Outline app.

- **Port:** 8388/tcp + 8388/udp
- **Engine:** [sing-box](https://github.com/SagerNet/sing-box)
- **Clients:** Outline (iOS/Android/desktop), NekoBox/NekoRay, Hiddify, Streisand, sing-box — via the standard `ss://` URI
- **Note:** On by default (`ENABLE_SS=true`). If port 8388 is fingerprinted by your ISP, change `PORT_SS` in `.env` to a less-conspicuous port and `moav restart sing-box`.

### CDN (VLESS+WS)

Routes VLESS traffic through Cloudflare's CDN via WebSocket. When your server's IP is blocked, traffic goes through Cloudflare instead, making it unblockable without blocking all of Cloudflare.

- **Port:** 443 (Cloudflare) → 2082 (origin)
- **Engine:** [sing-box](https://github.com/SagerNet/sing-box)
- **Clients:** Streisand, Hiddify, v2rayNG, v2rayN
- **Requires:** Cloudflare-proxied domain

### TrustTunnel

Modern VPN protocol that looks like regular HTTPS traffic. Supports both HTTP/2 (TCP) and HTTP/3 (QUIC/UDP).

- **Port:** 4443/tcp + 4443/udp
- **Engine:** [TrustTunnel](https://github.com/TrustTunnel/TrustTunnel) (server) / [TrustTunnelClient](https://github.com/TrustTunnel/TrustTunnelClient) (client)
- **Clients:** TrustTunnel app (iOS, Android, macOS, Windows, Linux)

### WireGuard

Fast kernel-level VPN. Simple, audited, and widely supported. Direct UDP connection.

- **Port:** 51820/udp
- **Engine:** [sing-box](https://github.com/SagerNet/sing-box) + [wstunnel](https://github.com/erebe/wstunnel)
- **Clients:** WireGuard app (all platforms)
- **Note:** Easily fingerprinted by DPI. Use AmneziaWG or wstunnel variant in censored networks.

### AmneziaWG

Obfuscated WireGuard variant that defeats Deep Packet Inspection. Adds junk packets, changes handshake timing, and modifies header fields to avoid detection.

- **Port:** 51821/udp
- **Engine:** [amneziawg-tools](https://github.com/amnezia-vpn/amneziawg-tools)
- **Clients:** AmneziaVPN (iOS, Android, macOS, Windows, Linux)

### WireGuard (wstunnel)

WireGuard tunneled through WebSocket (TCP). Works when UDP is completely blocked. When a `DOMAIN` is configured the tunnel is served over **`wss://` (TLS)** using the server's Let's Encrypt certificate, so the WebSocket upgrade is indistinguishable from ordinary HTTPS; it falls back to plain `ws://` only in domainless mode. A per-install **HTTP-upgrade path secret** is also required, so a scanner probing port 8080 can't complete the WebSocket upgrade blind. The exact client command (correct `wss://`/`ws://` scheme and path prefix) is emitted in each user bundle's `wireguard-instructions.txt`.

- **Port:** 8080/tcp
- **Engine:** [wstunnel](https://github.com/erebe/wstunnel) wrapping the WireGuard container
- **Clients:** WireGuard app + wstunnel binary
- **Note:** After upgrading an existing install, rebuild the image (`moav build wstunnel`) and re-bootstrap to generate the path secret and enable `wss://`; older bundles keep working over `ws://` until re-issued.

### Telegram MTProxy

Telegram-specific proxy with Fake-TLS V2. Emulates real TLS connections, including certificate mimicry and timing simulation. Provides direct access to Telegram when it's blocked.

- **Port:** 993/tcp (IMAPS port for stealth)
- **Engine:** [telemt](https://github.com/telemt/telemt)
- **Clients:** Telegram app (built-in proxy settings)

<details>
<summary><strong>Anti-DPI Tuning Settings</strong></summary>

telemt has 17+ configurable settings for hostile network environments. All configurable in `.env`:

**Traffic Disguise (anti-DPI):**

| Setting | Default | Purpose |
|---------|---------|---------|
| `TELEMT_KEEPALIVE_RANDOM` | `true` | Randomize keepalive payload to break DPI pattern-matching |
| `TELEMT_KEEPALIVE_JITTER` | `4` | ±N seconds randomness on keepalive timing |
| `TELEMT_KEEPALIVE_INTERVAL` | `20` | Base keepalive interval in seconds |
| `TELEMT_WARMUP_JITTER` | `200` | Randomize connection establishment timing (ms) |

**Connection Pool Resilience:**

| Setting | Default | Purpose |
|---------|---------|---------|
| `TELEMT_POOL_SIZE` | `12` | Number of persistent connections to Telegram DCs |
| `TELEMT_REINIT_SECS` | `600` | Rebuild all connections every N seconds (prevents long-connection fingerprinting) |
| `TELEMT_HARDSWAP` | `true` | Build new pool before tearing down old (zero-downtime rotation) |
| `TELEMT_HARDSWAP_DELAY_MIN` | `500` | Min delay between new connections during swap (ms) |
| `TELEMT_HARDSWAP_DELAY_MAX` | `1200` | Max delay between new connections during swap (ms) |

**Fast Reconnect:**

| Setting | Default | Purpose |
|---------|---------|---------|
| `TELEMT_FAST_RETRIES` | `10` | Quick retries before exponential backoff |
| `TELEMT_BACKOFF_BASE` | `300` | Backoff start interval (ms) |
| `TELEMT_BACKOFF_CAP` | `10000` | Maximum backoff interval (ms) |

**Config Stability:**

| Setting | Default | Purpose |
|---------|---------|---------|
| `TELEMT_STABLE_SNAPSHOTS` | `3` | Require N consistent config snapshots before applying changes |
| `TELEMT_APPLY_COOLDOWN` | `120` | Minimum seconds between config changes |

**For aggressive censorship** (e.g., Iran during shutdowns): increase `TELEMT_POOL_SIZE` to 16-20, decrease `TELEMT_REINIT_SECS` to 300, and increase `TELEMT_FAST_RETRIES` to 20.

Full tuning docs: [telemt TUNING.en.md](https://github.com/telemt/telemt/blob/main/docs/TUNING.en.md) | [API docs](https://github.com/telemt/telemt/blob/main/docs/API.md)

</details>

### GooseRelay

SOCKS5 tunnelled through a **Google Apps Script** web app that the user deploys in their own Google account, which forwards to this VPS exit server. On the wire the client only ever appears to make a domain-fronted HTTPS request to `google.com` — everything is end-to-end AES-256-GCM and Google never sees plaintext or the key. This is the **GooseRelay** component bundled in MahsaNG v16. Extremely stealthy (looks like Google traffic), but throughput is capped by the Apps Script ~20k-calls/day-per-account quota.

- **Port:** `${PORT_GOOSE}`/tcp (default 8444 on the host → 8443 in the container; 8443 on the host is Trojan's)
- **Engine:** [GooseRelayVPN](https://github.com/kianmhz/GooseRelayVPN) (Go), server built from source
- **Clients:** MahsaNG v16+, or the standalone GooseRelay client + a user-deployed Apps Script forwarder
- **Encryption:** AES-256-GCM, shared 64-hex `tunnel_key` (in each user's `gooserelay-instructions.txt`)
- **Requires:** No domain. `PORT_GOOSE` must be reachable from Google's network. The user sets `RELAY_URLS = ['http://SERVER_IP:PORT_GOOSE/tunnel']` in their Apps Script.
- **Note:** Opt-in — set `ENABLE_GOOSERELAY=true` in `.env`. Egress is routed through sing-box. Real-time apps (Telegram/X) drain the Apps Script quota fast; add more deployments under different Google accounts for capacity.

### XHTTP (VLESS+XHTTP+Reality)

**Experimental.** VLESS over XHTTP transport with Reality TLS camouflage, powered by Xray-core. Uses the XHTTP (formerly splithttp) transport for multiplexed HTTP requests, making traffic look like regular web browsing. Reality handles TLS without needing a domain.

- **Port:** 2096/tcp
- **Engine:** [Xray-core](https://github.com/XTLS/Xray-core)
- **Clients:** V2rayNG, Hiddify, Streisand, V2Box, V2rayN, V2rayU, NekoBox
- **Note:** Uses Xray-core (separate from sing-box). Disable with `ENABLE_XHTTP=false` in `.env`.

### Psiphon Conduit

Bandwidth donation to the Psiphon network. Psiphon users worldwide route through your server. Not a protocol you connect to — it's a way to help others bypass censorship.

- **Engine:** [Psiphon Conduit](https://github.com/Psiphon-Inc/conduit)
- **Clients:** [Psiphon](https://psiphon.ca/) app (iOS, Android, Windows)

#### How your Conduit helps people in Iran

There are two ways your running Conduit reaches users:

1. **Public pool — automatic, nothing to share.** The moment Conduit is
   running it donates bandwidth to the Psiphon network. Psiphon app users —
   including in Iran — are brokered through your server automatically. They
   don't need a link, an invite, or any setup. This is the main way Conduit
   helps and requires zero action on the user's side.

2. **Personal Pairing — share a private path with specific people.** Psiphon's
   Conduit lets you give friends/family a private, prioritized path through
   your station. The Psiphon app has a "pairing URL" field for this. To set it
   up: install Psiphon's **Ryve** app (the Conduit manager), import your
   station with the claim link MoaV generates, then in Ryve enable Personal
   Pairing and generate a pairing link to send to people in Iran.

#### `moav conduit link`

```bash
moav conduit link      # Claim link + QR + step-by-step sharing guide
moav conduit status    # Is it running + connected clients / bandwidth
```

This prints the **Ryve claim deep link** (`network.ryve.app://…claim=…`) and
its QR code, plus the sharing walkthrough above.

> **⚠ Security:** the claim link/QR embeds this Conduit's **private key** — it
> is for importing the station into *your own* phone's Ryve app. Treat it like
> a password; do **not** post it publicly (anyone with it can take over your
> station). The public-safe link you give to users is the **Personal Pairing**
> link generated *inside Ryve*, not the claim link. As of
> [Psiphon-Inc/conduit#205](https://github.com/Psiphon-Inc/conduit/issues/205)
> the pairing-URL export lives only in the Conduit/Ryve app UI, so MoaV
> surfaces the claim link and the steps rather than minting a pairing URL
> itself. (`moav donate info` is an alias for `moav conduit link`.)

### Tor Snowflake

Bandwidth donation to the Tor network. Acts as a Snowflake proxy, helping Tor users in censored regions connect. Like Conduit, this is about helping others.

- **Engine:** [Snowflake](https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake)
- **Clients:** [Tor Browser](https://www.torproject.org/) with Snowflake bridge

### MahsaNet

Config donation to [MahsaServer.com](https://www.mahsaserver.com/), a decentralized VPN config sharing platform for the [Mahsa VPN](https://www.mahsaserver.com/) app. With over 2 million users in Iran, Mahsa VPN connects to donated VPN configurations from servers worldwide. Unlike Conduit and Snowflake (which donate bandwidth), MahsaNet donates your server's VPN config links — Mahsa VPN users then connect directly to your server.

- **Supported protocols:** Reality (VLESS), Hysteria2, Trojan, CDN (VLESS+WS)
- **Clients:** [Mahsa VPN](https://www.mahsaserver.com/) app (Android, iOS)
- **Setup:** Register on MahsaServer.com, get API key, then `moav donate`
- **Dashboard:** Donate, list, and manage configs from the Admin Dashboard

## DNS Tunnels

The last transports standing. When a network blocks or throttles almost everything else, DNS usually still resolves — breaking it breaks the whole internet for everyone. DNS tunnels encode traffic inside DNS queries, so they keep working through shutdowns that kill every other protocol.

They are **slow**. Treat them as the fallback that keeps chat and messaging alive, not as an everyday transport.

### How it works

MoaV runs **four** DNS tunnels **simultaneously** on the same public port 53. A small Go service, `dns-router`, is the only thing bound to that port; it reads each query's subdomain prefix and forwards to the matching tunnel container on an internal port.

```
              Public 53/udp
                   │
            ┌──────▼──────┐
            │ dns-router  │   ← the only listener on 53
            └──────┬──────┘
                   │  routes by subdomain prefix
       t.*  ─────►  dnstt        (KCP + Noise)
       s.*  ─────►  slipstream   (QUIC-over-DNS)
       m.*  ─────►  masterdns    (ARQ, MahsaNG-native)
       x.*  ─────►  xray         (XDNS via FinalMask)
                   │
                   ▼
              sing-box  ──►  internet
```

Because they are separated by subdomain rather than by port, there is no "pick one" decision: a user connects with whichever tunnel their client supports, and all four can serve traffic at once.

### What MoaV sets up for you

Each tunnel needs an **NS delegation** handing its subdomain to your server, plus one A record for the nameserver itself:

```
dns.yourdomain.com  A   YOUR_SERVER_IP     # the nameserver
t.yourdomain.com    NS  dns.yourdomain.com # dnstt
s.yourdomain.com    NS  dns.yourdomain.com # Slipstream
m.yourdomain.com    NS  dns.yourdomain.com # MasterDNS
x.yourdomain.com    NS  dns.yourdomain.com # XDNS
```

`moav doctor dns` writes exactly the records your configuration needs to `outputs/dns-records.txt`, ready to import into Cloudflare. Full walkthrough: [DNS Configuration](DNS.md#with-a-domain-the-records).

All four are on by default. Toggle them individually with `ENABLE_DNSTT` / `ENABLE_SLIPSTREAM` / `ENABLE_MASTERDNS` / `ENABLE_XDNS`, or set the combination in one command:

```bash
moav switch-dns                                    # show what is on
moav switch-dns dnstt+slipstream+masterdns+xdns    # all four
moav switch-dns dnstt+slipstream                   # the classic pair
moav switch-dns off                                # no DNS tunnels
```

A disabled tunnel's container stays down and `dns-router` simply has no backend to forward to. Port **53/udp** must reach the server; some ISPs block it outright on residential lines.

### Which one should I use?

| Tunnel | Subdomain | Speed vs dnstt | Loss resilience | Best for |
|---|---|---|---|---|
| **dnstt** | `t` | 1× *(baseline)* | low | **Widest client support** — standalone client on 25+ platforms |
| **Slipstream** | `s` | 1.5–5× | medium | Faster general use where a Slipstream client exists |
| **MasterDNS** | `m` | up to 9× | **high** *(ARQ + packet duplication + multi-resolver)* | **Harsh shutdowns**; native in [MahsaNG v16](mahsanet.md) |
| **XDNS** | `x` | ~1× | low | FinalMask clients (Happ, Xray CLI); per-user auth |

**Short answer:** in Iran during heavy throttling or a blackout, **MasterDNS** is the strongest and works straight from the MahsaNG app. Offer **dnstt** too, because its client runs almost everywhere.

!!! warning "The client's resolver matters more than the tunnel"
    Every DNS tunnel depends on a public resolver **the client can still reach**, and `1.1.1.1` / `8.8.8.8` are commonly throttled or null-routed exactly when a tunnel is needed. XDNS round-robins across `XDNS_RESOLVERS`; dnstt and Slipstream take a resolver flag client-side. [findns](https://github.com/SamNet-dev/findns) and [dns-mns](https://gitlab.com/E-Gurl/dns-mns) scan for resolvers that still work on a given network — see [reachable resolvers](#reachable-dns-resolvers).

### Reachable DNS resolvers

Every DNS tunnel is only as good as the resolver the **client** can reach. During shutdowns the well-known ones (`1.1.1.1`, `8.8.8.8`, `9.9.9.9`) are routinely throttled, hijacked or null-routed, and a tunnel that worked yesterday will look broken.

Two scanners find resolvers that still answer on a given network:

- **[findns](https://github.com/SamNet-dev/findns)** — sweeps a range and reports which resolvers respond correctly
- **[dns-mns](https://gitlab.com/E-Gurl/dns-mns)** — same idea, maintained separately

Feed the survivors to the client: `XDNS_RESOLVERS` accepts a comma-separated list that XDNS round-robins across, and the dnstt / Slipstream clients each take a resolver flag. It's worth shipping users two or three known-good resolvers rather than one.

### dnstt

Encodes a TCP stream inside DNS queries using KCP + Noise. Extremely hard to block without breaking DNS itself; the slowest of the four and the most portable.

- **Port:** 53/udp *(subdomain `t`)* · **Engine:** [dnstt](https://www.bamsoftware.com/software/dnstt/)
- **Clients:** standalone dnstt client on 25+ platforms
- **Requires:** domain + NS delegation

### Slipstream

The same idea over **QUIC**, which buys real throughput — typically 1.5–5× dnstt.

- **Port:** 53/udp *(subdomain `s`)* · **Engine:** [slipstream-rust](https://github.com/Mygod/slipstream-rust) · [pre-built binaries](https://github.com/net2share/slipstream-rust-build/releases)
- **Requires:** domain + NS delegation

### MasterDNS

The most loss-resilient of the four: low-overhead ARQ, packet duplication and resolver load-balancing, which is what keeps it usable on throttled links. This is the MasterDNS component bundled in **MahsaNG v16**, so that app connects with no extra client.

- **Port:** 53/udp *(subdomain `MASTERDNS_SUBDOMAIN`, default `m`)* · **Engine:** [MasterDnsVPN](https://github.com/masterking32/MasterDnsVPN) (Go)
- **Clients:** MahsaNG v16+, or the standalone client (Linux/Windows/macOS/Termux)
- **Encryption:** AES-256-GCM (`DATA_ENCRYPTION_METHOD=5`); the shared key ships in each user's bundle
- **Extra:** `MASTERDNS_PUBLIC_SUBDOMAIN` publishes a *different* delegation name than the one used internally — generated bundles then use the public one

### XDNS (VLESS+mKCP+DNS)

**Experimental.** Xray-core's mKCP transport with FinalMask, and the only DNS tunnel here with **per-user authentication** — at the cost of needing a FinalMask-aware client.

- **Port:** 53/udp *(subdomain `x`)* · **Engine:** [Xray-core](https://github.com/XTLS/Xray-core) *(built from main for FinalMask)*
- **Clients:** Happ (beta), Xray CLI. **Not** standard v2rayNG yet.
- **Best for:** Telegram and light chat apps — not fast enough for browsing

<details>
<summary><strong>XDNS Tuning</strong></summary>

| Setting | Default | Purpose |
|---------|---------|---------|
| `XDNS_MTU` | `35` | mKCP packet size. Smaller = works with more DNS resolvers. 35=safest, 67=most, 130=unrestricted |
| `XDNS_SUBDOMAIN` | `x` | Subdomain for XDNS queries (x.yourdomain.com) |
| `XDNS_RESOLVERS` | `1.1.1.1,8.8.8.8` | CSV of public DNS resolvers the client round-robins across in a single mKCP session (Xray v26.4.13+, [PR #5872](https://github.com/XTLS/Xray-core/pull/5872)). See [Reachable DNS resolvers](#reachable-dns-resolvers) — replace the defaults with resolvers that actually answer on your network. Set empty to fall back to single-resolver mode. |
| `XDNS_METHOD` | `txt` | Finalmask record mode in generated client bundles. `txt` is the widest-compatibility default; `aaaa` ([Xray #6123](https://github.com/XTLS/Xray-core/pull/6123)) gives higher throughput per query but **requires an Xray client core ≥ v26.6.1** (Happ / Xray CLI). Server side needs no change. |

MTU depends on domain name length — shorter domain allows higher MTU. The values above are for ~19-character domains.

For aggressive censorship: use `MTU=35` and connect via a DNS resolver you can actually reach from inside the censored network (see below).

</details>

## Choosing Protocols

**For censored networks (Iran, China, Russia):**

1. Start with **Reality** — highest stealth, most reliable
2. Add **CDN mode** — works when your server IP is blocked
3. Enable **AmneziaWG** — for full VPN when WireGuard is fingerprinted
4. Enable **DNS tunnels** — last resort when almost everything is blocked

**For general privacy:**

1. **WireGuard** — fastest, simplest
2. **Reality** — when WireGuard is blocked

**For helping others:**

1. **Conduit** — donate bandwidth to Psiphon users
2. **Snowflake** — donate bandwidth to Tor users
3. **MahsaNet** — donate VPN configs to Mahsa VPN users in Iran
