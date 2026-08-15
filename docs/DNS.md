# DNS Configuration

What DNS records MoaV needs, and how to add them. Most setups need **one to six records**; the rest of this page is provider quirks and edge cases, folded away until you need them.

## Do I need a domain?

**Not strictly — but get one.** MoaV runs fine on a bare IP, and if you can't register a domain, skip to [without a domain](#without-a-domain). But a domain **unlocks several additional transports**, and it is the only way to run the **DNS tunnels** — which can remain usable where ordinary traffic is blocked but recursive DNS still resolves. A domain costs a few dollars a year; see [getting a domain](#getting-a-domain).

| Protocol | Bare IP | With a domain |
|---|:-:|:-:|
| Reality (VLESS) | ✅ | ✅ |
| XHTTP (VLESS+XHTTP+Reality) | ✅ | ✅ |
| WireGuard *(direct + wstunnel)* | ✅ | ✅ |
| AmneziaWG | ✅ | ✅ |
| Telegram MTProxy | ✅ | ✅ |
| Shadowsocks-2022 | ✅ | ✅ |
| CDN-fronted VLESS *(via AWS CloudFront)* | ✅ | ✅ |
| Admin dashboard · Conduit · Snowflake | ✅ | ✅ |
| **Trojan** | — | ✅ |
| **AnyTLS** | — | ✅ |
| **Hysteria2** | — | ✅ |
| **TrustTunnel** | — | ✅ |
| **CDN-fronted VLESS** *(via Cloudflare)* | — | ✅ |
| **dnstt · Slipstream · MasterDNS · XDNS** *(DNS tunnels)* | — | ✅ |

The domain-only ones need either a Let's Encrypt certificate or an NS delegation, and both require a real domain. Nothing is lost by adding a domain later: set `DOMAIN=` and re-run `moav bootstrap`.

## With a domain: the records

Add only the rows for the features you enable. This table is the whole story — everything below it is provider-specific detail.

| Record | Name | Value | Cloudflare proxy | Needed for |
|---|---|---|:-:|---|
| A | `@` | server IP | DNS only | **Always** — Trojan, Hysteria2, Reality, TLS |
| A | `dns` | server IP | DNS only | Any DNS tunnel (the nameserver for the delegations below) |
| NS | `t`, `s`, `m`, `x` | `dns.yourdomain.com` | — | One per [DNS tunnel](protocols.md#dns-tunnels) you expose |
| A | `cdn` | server IP | **Proxied** | [CDN mode](#cdn-mode) |
| A | `www` | server IP | **Proxied** | [CDN mode](#cdn-mode) stealth connect address (`CDN_ADDRESS=www.…`) |
| A | `grafana` | server IP | **Proxied** | Faster Grafana over the CDN *(optional)* |

**Minimum** (no DNS tunnels): just the `@` A record. That already enables Reality, Trojan, Hysteria2 and TrustTunnel.

Each `NS` row is a separate delegation handing that subdomain to your own server:

```
t.yourdomain.com    NS    dns.yourdomain.com      # dnstt
s.yourdomain.com    NS    dns.yourdomain.com      # Slipstream
m.yourdomain.com    NS    dns.yourdomain.com      # MasterDNS
x.yourdomain.com    NS    dns.yourdomain.com      # XDNS
```

Add only the tunnels you want — see [DNS Tunnels](protocols.md#dns-tunnels) for what each one is and which to pick. Some registrars require a **trailing dot** on NS values (`dns.yourdomain.com.`); Cloudflare and most modern panels do not.

!!! tip "MoaV writes the zone file for you"
    `moav doctor dns` generates **`outputs/dns-records.txt`** — a BIND-style zone file containing exactly the records your configuration needs, with the enabled/disabled state of each tunnel noted in comments. In Cloudflare you can feed it straight to **DNS → Records → Import and Upload** instead of adding records by hand.

## CDN mode

CDN mode fronts VLESS+WebSocket behind a CDN, so the client appears to talk to Cloudflare/AWS rather than to your server. Two things are true of **any** CDN you put in front of MoaV:

- **The origin port is `2082`.** MoaV's CDN listener does not bind 80 or 443, so the CDN must be told to reach your server on 2082.
- **The CDN terminates TLS.** That inbound is plain HTTP by design — the encryption users get is VLESS's own, inside the WebSocket.

How you express those two facts differs per provider, which is the next section. Verifying it works is the same everywhere: see [CDN returns 521 / 525](#troubleshooting).

!!! note "CDN links are off until you turn them on"
    `ENABLE_CDN=false` is the default, because a CDN link generated before the CDN is actually fronting traffic looks valid to the user and cannot connect. Set `ENABLE_CDN=true` in `.env` once the steps below are done. On Cloudflare, `moav doctor dns` confirms the record is *proxied*, not merely resolving; on CloudFront use the `curl` verify in that tab instead (`moav doctor dns` does not recognise CloudFront yet).

## Provider setup

The records are the same everywhere; only the UI differs. Cloudflare additionally needs two settings for CDN mode.

=== "Cloudflare"
    DNS → Records. Set every record to **DNS only** (gray cloud) **except** `cdn` / `www` / `grafana`, which must be **Proxied** (orange cloud).

    **CDN mode needs two extra settings** (both required):

    1. **Origin Rule** (Rules → Origin Rules): when hostname = `cdn.yourdomain.com`, rewrite **Destination Port → 2082**. MoaV's CDN listener doesn't bind 80/443.
    2. **SSL/TLS → Overview → Flexible**: MoaV's CDN inbound is plain HTTP; Cloudflare terminates TLS for the client. If other subdomains need Full (Strict), scope a **Configuration Rule** to `cdn.` only.

    Verify both settings: `curl -so /dev/null -w "%{http_code}" https://cdn.yourdomain.com/x` — `400`/`404` means sing-box is answering and CDN mode works. Anything else is diagnosable: see [CDN returns 521 / 525](#troubleshooting).

=== "AWS CloudFront"
    An alternative CDN that **needs no domain** — you get a `*.cloudfront.net` name automatically. CloudFront rejects bare-IP origins, so use free wildcard DNS: `YOUR_IP.sslip.io` (pure DNS, no traffic passes through it).

    **First, confirm the origin is reachable.** CloudFront connects to your server over the public internet on 2082, so that has to work before AWS is in the picture:
    ```bash
    curl -so /dev/null -w "%{http_code}\n" http://YOUR_IP:2082/x
    ```
    `400` or `404` means sing-box is answering — proceed. A timeout or refused means a firewall or cloud security-group is blocking 2082; fix that first, or CloudFront will just report the origin down.

    ??? example "Create the distribution (console or CLI)"
        **Origin:** `YOUR_IP.sslip.io`, HTTP only, port **2082**.
        **Behavior:** viewer protocol **HTTPS only**; methods **GET,HEAD,OPTIONS,PUT,POST,PATCH,DELETE**; **CachePolicy = CachingDisabled**, **OriginRequestPolicy = AllViewer** (these two forward the WebSocket upgrade headers — omitting them causes `bad "Sec-WebSocket-Key" header`). `PriceClass_200`+ includes Middle East / Asia edges.

        !!! warning "The console's Review screen hides the origin port"
            This is the single most common mistake. The **Review and create** page shows the origin domain but **not** its protocol or port, and the console defaults a custom origin to **HTTPS / 443**. Your origin is plain **HTTP on 2082**. Before creating (or via the origin's **Edit** afterward), confirm **Protocol: HTTP only** and **HTTP port: 2082**. Left at 443, CloudFront gets connection-refused and every request returns `502`.

        CLI create (replace the IP); the same two policy IDs also fix an existing distribution that's missing them:
        ```bash
        aws cloudfront create-distribution --distribution-config '{
          "CallerReference":"moav-'$(date +%s)'","Comment":"MoaV CDN","Enabled":true,
          "Origins":{"Quantity":1,"Items":[{"Id":"moav","DomainName":"YOUR_IP.sslip.io",
            "CustomOriginConfig":{"HTTPPort":2082,"HTTPSPort":443,"OriginProtocolPolicy":"http-only"}}]},
          "DefaultCacheBehavior":{"TargetOriginId":"moav","ViewerProtocolPolicy":"https-only",
            "AllowedMethods":{"Quantity":7,"Items":["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"],
              "CachedMethods":{"Quantity":2,"Items":["GET","HEAD"]}},
            "CachePolicyId":"4135ea2d-6df8-44a3-9df3-4b5a84be39ad",
            "OriginRequestPolicyId":"216adef6-5c7f-47e4-b989-5492eafa07d3","Compress":false},
          "PriceClass":"PriceClass_200"}'
        ```

    Then in `.env` (`CDN_TRANSPORT=ws` is the default and is what CloudFront needs; `httpupgrade` will not work):
    ```bash
    ENABLE_CDN=true
    CDN_SUBDOMAIN=
    CDN_DOMAIN=d123.cloudfront.net
    CDN_ADDRESS=d123.cloudfront.net
    CDN_SNI=d123.cloudfront.net
    CDN_TRANSPORT=ws
    ```
    `moav bootstrap`, then wait for the distribution to finish deploying (~10-15 min — the console shows a timestamp instead of *Deploying*; testing earlier gives misleading errors) and verify:
    ```bash
    curl -so /dev/null -w "%{http_code}\n" https://d123.cloudfront.net/x
    ```
    `400` **or** `404` means it works end to end (CloudFront → origin:2082 → sing-box; `/x` is just not the secret path). `502`/`504` means CloudFront can't reach the origin — recheck the origin port (see the warning above) and the firewall. `403` means the SNI does not match the distribution: AWS blocked domain fronting in 2018, so `CDN_SNI` must be your `*.cloudfront.net` name (or a CNAME you attached), never the root domain.

    !!! note "`moav doctor dns` does not recognise CloudFront yet"
        Its CDN check looks for a Cloudflare `cf-ray` header and reports **NOT proxied** for anything else — so it false-fails a working CloudFront setup. Ignore that one line for CloudFront and trust the `curl` above; the rest of `moav doctor dns` is still accurate. ([tracking issue](https://github.com/MotherofallVPNs/MoaV/issues))

    You can run Cloudflare **and** CloudFront together for redundancy.

    !!! info "Origin exposure"
        With CloudFront the origin's `2082` is reachable directly on the public internet, and the CloudFront-to-origin leg is plain HTTP. User traffic stays safe (VLESS encrypts inside the WebSocket), but the *existence* of a WS endpoint on `2082` is visible to a scanner. To hide it, restrict inbound `2082` to [CloudFront's origin-facing IP ranges](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/LocationsOfEdgeServers.html) in your cloud security group.

## Verify

```bash
moav doctor dns                     # MoaV's own check
dig +short yourdomain.com           # → your server IP
dig NS t.yourdomain.com             # → dns.yourdomain.com in AUTHORITY
```

Propagation is usually 5–30 min (rarely up to 48 h). Cross-check worldwide at [dnschecker.org](https://dnschecker.org).

## Without a domain

Leave `DOMAIN=` empty in `.env`. MoaV detects this and starts only the transports that work on a bare IP (Reality uses `REALITY_TARGET`, e.g. `dl.google.com`, for TLS camouflage instead of your domain). No DNS records, no certificates, no port 80.

You can add a domain at any time — set `DOMAIN=` and run `moav bootstrap`. Existing users keep working and pick up the new protocols on their next bundle.

### Ports to forward

Only needed if the server sits behind a router (home, office, NAT).

| Port | Service | Needed when |
|---|---|:-:|
| `443/tcp` | Reality (VLESS) | always |
| `2096/tcp` | XHTTP | always |
| `51820/udp` | WireGuard | always |
| `8080/tcp` | wstunnel *(WireGuard over WebSocket, for UDP-blocked networks)* | always |
| `51821/udp` | AmneziaWG | always |
| `993/tcp` | Telegram MTProxy | always |
| `9443/tcp` | Admin dashboard | always |
| `80/tcp` | Let's Encrypt (ACME) | **domain only**, during issuance/renewal |
| `443/udp` | Hysteria2 | **domain only** |
| `8443/tcp` | Trojan | **domain only** |
| `4443/tcp` + `4443/udp` | TrustTunnel (HTTP/2 + QUIC) | **domain only** |
| `53/udp` | [DNS tunnels](protocols.md#dns-tunnels) *(all four via `dns-router`)* | **domain only** |
| `2082/tcp` | CDN origin | only if the CDN reaches your origin directly |

### Home server / Raspberry Pi

MoaV runs on a Pi 4+ (2 GB+ RAM) or any ARM64/x64 Linux box. Three things differ from a VPS:

**Check for CGNAT first.** `curl ifconfig.me` must match your router's WAN IP. If it doesn't, your ISP is sharing that address and **no amount of port forwarding will work** — you need a VPS, an IPv6-only setup, or a tunnel from a host that does have a public IP.

**Forward the ports above** to the server's LAN address, and give it a static DHCP lease so that address stops moving.

**Dynamic IP?** If you're using a domain, a residential IP that changes will silently break every record pointing at it. Run a DDNS updater on a 5-minute cron:

- **[DuckDNS](https://www.duckdns.org)** — free subdomain, works with no domain of your own
- **Your own domain** — a small script against your DNS provider's API (Cloudflare tokens are the usual choice)

After the IP moves, re-run `moav cert renew` if a certificate was issued against the old address, and remember that DNS-tunnel NS delegations point at `dns.yourdomain.com`, so that record needs the DDNS update too.

## Troubleshooting

**Not propagated** — wait, and test other resolvers: `dig @8.8.8.8 yourdomain.com`, `dig @1.1.1.1 …`.

**NS record not working** — confirm the `dns` A record exists, add a trailing dot if your registrar needs one, and give delegations longer to propagate.

**Certificate acquisition failed** — check the `@` A record, ensure port 80 is open and free during ACME, and remember domainless mode issues no certs.

**Can't connect from outside a home network** — verify port forwarding, rule out CGNAT (`curl ifconfig.me` vs router WAN IP), and test from mobile data rather than the same Wi-Fi.

**CDN returns 521 / 525** — probe it with
`curl -so /dev/null -w "%{http_code}" https://cdn.yourdomain.com/x`:

| Code | Meaning | Fix |
|---|---|---|
| `400` / `404` | sing-box is answering — CDN mode works | — |
| `521` | the CDN can't reach your origin on port 2082 | Cloudflare: the **Origin Rule** is missing or wrong. CloudFront: the origin's **HTTP port** isn't 2082 |
| `525` | TLS handshake to the origin failed | Cloudflare **SSL/TLS must be Flexible** — the CDN inbound is plain HTTP by design |
| `1016` / `NXDOMAIN` | the `cdn` A record is missing, or not **Proxied** | add it, orange cloud on |

**CDN connects but the client won't** — on CloudFront check `CDN_TRANSPORT=ws`; the default `httpupgrade` is sing-box-specific and fails there with `bad "Sec-WebSocket-Key" header`.

## Getting a domain

Any registrar with WHOIS privacy works; [Namecheap, Porkbun, Njalla](https://njal.la) accept crypto. Keep the name generic — it's the first thing DPI sees in the TLS SNI, so avoid `vpn`/`proxy`/`tunnel` and random strings, and favour boring infrastructure-style names. The full naming-and-SNI strategy lives in the [OPSEC Guide](OPSEC.md) so it stays in one place.
