---
title: "MoaV 2.3.1: update now (compromised CA roots dropped, ten Grafana CVEs)"
description: MoaV 2.3.1 ships Xray and Prometheus rebuilt on Go 1.27.3, which no longer trusts the compromised eMudhra (emSign) CA roots, plus a Grafana release that closes ten CVEs. Also everything that landed in 2.3.0.
hide:
  - navigation
---

<p class="post-meta">2026-10-21 · Release · 6 min read · <a href="../../">The MoaV Blog</a></p>

# MoaV 2.3.1: update now

**MoaV 2.3.1 is a security release.** It covers two things: the upstream fallout from the eMudhra (emSign) Certificate Authority compromise, and a Grafana update that closes ten CVEs. It also rolls up everything that shipped in 2.3.0, so if you skipped that one, this post is the whole story.

If you only read one line: run `moav update`, then follow the [XDNS upgrade note](#xdns-upgrade-note) below.

- **Release:** [v2.3.1 on GitHub](https://github.com/MotherofallVPNs/MoaV/releases/tag/v2.3.1)
- **Source:** [MotherofallVPNs/MoaV](https://github.com/MotherofallVPNs/MoaV)
- **Docs:** [moav.sh/docs](https://moav.sh/docs)

## Why this is a security release

### The eMudhra (emSign) CA compromise

Between 17 and 20 October 2026, eight intermediate CA private keys belonging to eMudhra, an Indian Certificate Authority operating under the emSign brand, were found to be recoverable from their own public certificates. That is the worst thing that can happen to a CA: anyone who recovers the key can mint certificates that chain to a trusted root. The incident was filed as a CA compromise (`cACompromise`).

The response was broad and fast. Browser and OS vendors distrusted the affected roots. Mozilla NSS, Ubuntu, Red Hat, and Python's `certifi` dropped them. Go shipped a key-based block in its standard library (CVE-2026-111943, tracked in [golang/go#82345](https://github.com/golang/go/issues/82345)), so any Go program that verifies TLS now refuses chains built on those keys.

**What this means for MoaV.** Several MoaV components are Go binaries that make outbound TLS connections and verify certificates, and they carry Go's trust logic with them. MoaV 2.3.1 ships [Xray-core](https://github.com/XTLS/Xray-core/releases) v26.10.21 and [Prometheus](https://github.com/prometheus/prometheus/releases) 3.15.1, both rebuilt on Go 1.27.3, which carries the block for the compromised eMudhra keys and no longer trusts those roots.

To be precise about the exposure: this is an upstream CA-trust fix that MoaV inherits by updating these components. We have no evidence that MoaV servers or users were targeted with certificates from the compromised keys. But a TLS stack that still trusts a known-compromised CA is a liability you do not want sitting on a circumvention server, and the fix is a single update.

### Grafana 13.2.1 to 13.2.4: ten CVEs

MoaV's monitoring dashboard moves from Grafana 13.2.1 to 13.2.4. The jump closes ten CVEs: CVE-2026-15815, CVE-2026-76154, CVE-2026-79656, CVE-2026-13719, CVE-2026-13720, CVE-2026-81841, CVE-2026-15577, CVE-2026-33374, CVE-2026-93294, and CVE-2026-95502. MoaV does not expose Grafana to the internet by default, but operators who have opened it up, or who use it from a shared network, should treat this as a must-update.

### Everything else that moved in 2.3.1

Routine upstream bumps, listed so you can check them against your own threat model:

| Component | 2.3.1 |
|---|---|
| Xray-core | v26.10.21 (Go 1.27.3) |
| Prometheus | 3.15.1 (Go 1.27.3) |
| Grafana | 13.2.4 |
| sing-box | 1.14.3 |
| wstunnel | 11.1.0 |
| Psiphon Conduit | 2.1.0 |
| Snowflake | 2.15.2 |
| telemt | 3.5.14 |
| cAdvisor | 0.60.6 |
| docker-socket-proxy | 0.5.0 |
| TrustTunnelClient | 1.0.49 (unchanged) |

## What landed in 2.3.0

2.3.0 went through a public release-candidate cycle ([we asked you to test it](2026-09-24-help-us-test-moav-2-3-0.md), and many of you did). Here is what it brought, in case you are coming from 2.2.x.

- **Snell, a new protocol, on by default.** A lightweight TCP proxy from the Surge ecosystem with optional HTTP obfuscation. No TLS, no domain, so it works in domainless mode. Client support is specific: Surge 5, Stash, Clash Mi, Clash Meta for Android, FlClash. Not v2rayNG, Hiddify, NekoBox, or the sing-box apps.
- **sing-box 1.14.** The engine behind Reality, Trojan, Hysteria2, Shadowsocks, AnyTLS, and Snell. No config change needed on your side.
- **Opt-in gecko obfuscation for Hysteria2.** Fragments the QUIC handshake into random-sized padded chunks. Set `HYSTERIA2_OBFS_TYPE=gecko`; clients need sing-box 1.14+ or Hysteria 2.9.2+.
- **CLI `--json` output and non-interactive install.** Drive MoaV from scripts or an AI agent without parsing human-formatted output or answering prompts.
- **Grafana security patch.** 13.2.1 closed two CVEs. 2.3.1 goes further, see above.
- **CDN flag fix.** A fix to the CDN flag in the installer and CLI.

## XDNS upgrade note {#xdns-upgrade-note}

Xray v26.9.30 and later changed the XDNS `finalmask` schema. The 2.3.1 Xray build carries this change, so if you run XDNS, the update needs two extra commands:

```bash
moav update
moav bootstrap           # idempotent: keeps your keys and user UUIDs
moav regenerate-users
```

`moav bootstrap` rewrites the rendered config for the new schema without touching your keys or user UUIDs. `moav regenerate-users` re-issues bundles with the new XDNS block.

!!! warning "XDNS clients must update too"
    XDNS now needs a client core at or above v26.9.30. Clients on an older core will not connect to XDNS until they update their app, and every XDNS user must re-download their bundle. Every other protocol keeps working with the existing bundles.

If you do not run XDNS, `moav update` alone is enough. Running `moav bootstrap` anyway is harmless.

## Test it, break it, tell us

Every MoaV release gets a test call, and every report from a real censored network shapes the next one. The standing guide, [How to help test MoaV](../how-to-test.md), has the [test plan](../how-to-test.md#the-test-plan) and [how to report back](../how-to-test.md#how-to-report-back). This cycle, we most want to hear:

1. **The XDNS upgrade path.** From a 2.3.0 box, run the three commands above. Did your XDNS users reconnect after re-downloading their bundle?
2. **Snell and gecko in the wild.** Which client, which ISP, did it connect, did it stay up.
3. **Anything that broke.** Open an [issue](https://github.com/MotherofallVPNs/MoaV/issues) with `moav status` output and the component version.

If you want to go further than testing, the repo takes pull requests. Translations, client notes, and protocol field reports are all welcome.

Update now. Then tell us what you see.
