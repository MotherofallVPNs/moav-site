# DNS Configuration

What DNS records MoaV needs, and how to add them. Most setups need **one to six records**; the rest of this page is provider quirks and edge cases, folded away until you need them.

## Do I need a domain?

**No — MoaV runs without one** in [domainless mode](#domainless-no-domain). A domain unlocks the TLS- and DNS-tunnel protocols; everything else works on a bare IP.

| Works on a bare IP | Needs a domain |
|---|---|
| Reality, XHTTP | Trojan, Hysteria2, TrustTunnel |
| WireGuard, AmneziaWG, wstunnel | CDN via Cloudflare *(CloudFront needs none)* |
| Telegram MTProxy | dnstt, Slipstream, MasterDNS, XDNS *(DNS tunnels — need NS records)* |
| Admin dashboard, Conduit, Snowflake | |

The domain-only protocols need either a Let's Encrypt certificate or an NS delegation, and both require a real domain.

## Domainless (no domain)

Leave `DOMAIN=` empty in `.env`. MoaV detects this and starts only the IP-friendly protocols above (Reality uses `REALITY_TARGET`, e.g. `dl.google.com`, for its TLS camouflage instead of your domain). You can add a domain later with `DOMAIN=…` + `moav bootstrap`.

On a home network, forward these ports (no port 80 — domainless mode never touches Let's Encrypt):

`443/tcp` Reality · `2096/tcp` XHTTP · `51820/udp` WireGuard · `8080/tcp` wstunnel · `51821/udp` AmneziaWG · `993/tcp` MTProxy · `9443/tcp` admin

## With a domain: the records

Add only the rows for the features you enable. This table is the whole story — everything below it is provider-specific detail.

| Record | Name | Value | Cloudflare proxy | Needed for |
|---|---|---|:-:|---|
| A | `@` | server IP | DNS only | **Always** — Trojan, Hysteria2, Reality, TLS |
| A | `dns` | server IP | DNS only | Any DNS tunnel (the nameserver for the delegations below) |
| NS | `t` `s` `m` `x` | `dns.yourdomain.com` | — | One per DNS tunnel you expose (dnstt / Slipstream / MasterDNS / XDNS) |
| A | `cdn` | server IP | **Proxied** | CDN-fronted VLESS |
| A | `www` | server IP | **Proxied** | CDN stealth connect address (`CDN_ADDRESS=www.…`) |
| A | `grafana` | server IP | **Proxied** | Faster Grafana over the CDN *(optional)* |

**Minimum** (no DNS tunnels): just the `@` A record. That already enables Reality, Trojan, Hysteria2, TrustTunnel and CDN mode.

!!! note "DNS tunnels — the four `NS` records"
    All four tunnels share port 53 through `dns-router`, which fans queries out by subdomain, so each needs its own NS delegation pointing at `dns.yourdomain.com`. They're all enabled by default; a disabled tunnel's container just stays down. Toggle with `ENABLE_DNSTT` / `ENABLE_SLIPSTREAM` / `ENABLE_MASTERDNS` / `ENABLE_XDNS`.

    | Tunnel | Sub | Speed vs dnstt | Best for |
    |---|---|---|---|
    | **dnstt** | `t` | 1× | Widest client support (25+ platforms) |
    | **Slipstream** | `s` | 1.5–5× | Faster general use |
    | **MasterDNS** | `m` | up to 9× | Harsh shutdowns; **native [MahsaNG v16](mahsanet.md)** import |
    | **XDNS** | `x` | ~1× | FinalMask clients (Happ, Xray CLI); per-user auth |

    All four depend on a public resolver the *client* can reach (`1.1.1.1`/`8.8.8.8` are often throttled during shutdowns) — see [Protocols → reachable resolvers](protocols.md#reachable-dns-resolvers). MasterDNS also supports a separate public delegation via `MASTERDNS_PUBLIC_SUBDOMAIN`. IPv6: add an `AAAA` on `dns` if your server has one.

## Provider setup

The records are the same everywhere; only the UI differs. Cloudflare additionally needs two settings for CDN mode.

=== "Cloudflare"
    DNS → Records. Set every record to **DNS only** (gray cloud) **except** `cdn` / `www` / `grafana`, which must be **Proxied** (orange cloud).

    **CDN mode needs two extra settings** (both required):

    1. **Origin Rule** (Rules → Origin Rules): when hostname = `cdn.yourdomain.com`, rewrite **Destination Port → 2082**. MoaV's CDN listener doesn't bind 80/443.
    2. **SSL/TLS → Overview → Flexible**: MoaV's CDN inbound is plain HTTP; Cloudflare terminates TLS for the client. If other subdomains need Full (Strict), scope a **Configuration Rule** to `cdn.` only.

    Verify: `curl -so /dev/null -w "%{http_code}" https://cdn.yourdomain.com/x` → `400`/`404` = working, `521` = Origin Rule missing, `525` = SSL mode wrong.

=== "AWS CloudFront"
    An alternative CDN that **needs no domain** — you get a `*.cloudfront.net` name automatically. CloudFront rejects bare-IP origins, so use free wildcard DNS: `YOUR_IP.sslip.io` (pure DNS, no traffic passes through it).

    ??? example "Create the distribution (console or CLI)"
        **Origin:** `YOUR_IP.sslip.io`, HTTP only, port **2082**.
        **Behavior:** viewer protocol **HTTPS only**; methods **GET,HEAD,OPTIONS,PUT,POST,PATCH,DELETE**; **CachePolicy = CachingDisabled**, **OriginRequestPolicy = AllViewer** (these two forward the WebSocket upgrade headers — omitting them causes `bad "Sec-WebSocket-Key" header`). `PriceClass_200`+ includes Middle East / Asia edges.

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

    Then in `.env` (note `CDN_TRANSPORT=ws` — CloudFront rejects the default `httpupgrade`):
    ```bash
    CDN_SUBDOMAIN=
    CDN_DOMAIN=d123.cloudfront.net
    CDN_ADDRESS=d123.cloudfront.net
    CDN_SNI=d123.cloudfront.net
    CDN_TRANSPORT=ws
    ```
    `moav bootstrap`, then verify: `curl -so /dev/null -w "%{http_code}" https://d123.cloudfront.net/x` → `400`. AWS blocked domain fronting in 2018, so the SNI must be your distribution/CNAME. You can run Cloudflare **and** CloudFront together for redundancy.

=== "Namecheap / Google / Hetzner / other"
    Add the same records in the registrar's DNS panel. Two gotchas:

    - Some registrars want a **trailing dot** on NS values: `dns.yourdomain.com.`
    - "Automatic" / `300` TTL is fine everywhere.

    Hetzner zone-file form:
    ```
    @   IN A  YOUR_IP
    dns IN A  YOUR_IP
    t   IN NS dns.yourdomain.com.
    s   IN NS dns.yourdomain.com.
    ```

??? note "Home server / Raspberry Pi (dynamic IP)"
    MoaV runs on a Pi 4+ (2 GB+) or any ARM64/x64 Linux box. Two extra concerns behind a home router:

    **Port forwarding** — forward the ports for your enabled protocols to the server's LAN IP. Domainless needs `443/tcp 51820/udp 8080/tcp 51821/udp 993/tcp 9443/tcp`; a domain adds `80/tcp` (Let's Encrypt, during issuance only), `443/udp` (Hysteria2), `8443/tcp` (Trojan), `4443/tcp+udp` (TrustTunnel), `53/udp` (DNS tunnels). Check for CGNAT: `curl ifconfig.me` must equal your router's WAN IP, or no forwarding will work.

    **Dynamic DNS** — if your IP changes, point the domain with a DDNS updater on a 5-minute cron: [DuckDNS](https://www.duckdns.org) (free subdomain, no domain needed) or a Cloudflare-token script against your own domain. After the IP moves, re-run `moav cert renew` if a certificate was issued for the old IP.

## Verify

```bash
moav doctor dns                     # MoaV's own check
dig +short yourdomain.com           # → your server IP
dig NS t.yourdomain.com             # → dns.yourdomain.com in AUTHORITY
```

Propagation is usually 5–30 min (rarely up to 48 h). Cross-check worldwide at [dnschecker.org](https://dnschecker.org).

??? question "Troubleshooting"
    **Not propagated** — wait, and test other resolvers: `dig @8.8.8.8 yourdomain.com`, `dig @1.1.1.1 …`.

    **NS record not working** — confirm the `dns` A record exists, add a trailing dot if your registrar needs one, and give delegations longer to propagate.

    **Certificate acquisition failed** — check the `@` A record, ensure port 80 is open and free during ACME, and remember domainless mode issues no certs.

    **Can't connect from outside a home network** — verify port forwarding, rule out CGNAT (`curl ifconfig.me` vs router WAN IP), and test from mobile data rather than the same Wi-Fi.

## Getting a domain

Any registrar with WHOIS privacy works; [Namecheap, Porkbun, Njalla](https://njal.la) accept crypto. Keep the name generic — it's the first thing DPI sees in the TLS SNI, so avoid `vpn`/`proxy`/`tunnel` and random strings, and favour boring infrastructure-style names. The full naming-and-SNI strategy lives in the [OPSEC Guide](OPSEC.md) so it stays in one place.
