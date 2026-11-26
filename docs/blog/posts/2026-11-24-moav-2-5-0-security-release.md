---
title: "MoaV 2.5.0 and moav-client 1.5.0: egress isolation, MPTCP off, Slipstream deprecated"
description: MoaV 2.5.0 and moav-client 1.5.0 are a paired security and stability release. Tunneled traffic can no longer reach private networks, Go listeners drop MPTCP (CVE-2026-98432), TrustTunnel moves to 1.3.1, and Slipstream starts its removal. Some operators have to act.
hide:
  - navigation
---

<p class="post-meta">2026-11-24 · Release · 5 min read · <a href="../../">The MoaV Blog</a></p>

# MoaV 2.5.0 and moav-client 1.5.0

**This is a security and stability release, shipped as a pair.** It adds no new protocol. It comes out of a dependency audit and a full end-to-end pass over the server and the client.

Keys, users and certificates are untouched, but some operators have to act. If you only read one section, read [Action required](#action-required).

- **Server:** [MoaV v2.5.0](https://github.com/MotherofallVPNs/MoaV/releases/tag/v2.5.0)
- **Client:** [moav-client v1.5.0](https://github.com/MotherofallVPNs/moav-client/releases/tag/v1.5.0)
- **Patch:** [MoaV v2.5.1](https://github.com/MotherofallVPNs/MoaV/releases/tag/v2.5.1) is the current server release. See [Update: MoaV 2.5.1](#update-2-5-1).

## What we found

- **Tunneled traffic could reach private and infrastructure ranges.** A MoaV exit forwarded whatever destination a client asked for, so any user could reach other containers (the sing-box Clash API, Prometheus, Grafana), the host and its LAN, and the cloud metadata endpoint.
- **A remote-root path through MPTCP.** [CVE-2026-98432](https://nvd.nist.gov/vuln/detail/CVE-2026-98432) is a use-after-free in the Linux kernel's IPv4 TCP code (CVSS 9.8), and the public exploit needs an MPTCP listener. Go has opened MPTCP listeners by default since 1.24, so Xray's XHTTP inbound and Grafana were MPTCP listeners. See the [Go security announcement](https://groups.google.com/g/golang-announce/c/PCoQcdxoScw/m/aD-MgXEvAAAJ); [golang/go#82717](https://github.com/golang/go/issues/82717) proposes changing that default.
- **AmneziaWG key rotation and crash-loops.** `moav regenerate-users` silently rotated the AmneziaWG server key, cutting off existing clients. WireGuard and AmneziaWG restart-looped on dual-stack servers, and a recreated `awg0` came back with no key and no peers.
- **TrustTunnel was tested without the client in the loop.** `moav test` passed even when the client had been refused, and one run only proved whichever of HTTP/2 or HTTP/3 came up first.
- **First-run races.** On an existing install, `moav bootstrap` could report success while generating no configs. `moav start` launched disabled DNS-tunnel containers, which restart-looped. The client's TrustTunnel sidecar idled forever if it started before its config existed.

## What we fixed and shipped

- **Egress isolation, on by default.** RFC1918, CGNAT, link-local, loopback, IPv6 ULA and DappNode ranges are blocked in sing-box, Xray, WireGuard/AmneziaWG and TrustTunnel. WireGuard peers can no longer reach each other through the tunnel. A trusted LAN relay can set `EGRESS_ISOLATION=off`.
- **MPTCP off.** Every Go service runs with [`GODEBUG=multipathtcp=0`](https://go.dev/doc/godebug#go-124), and Xray carries upstream's own listener fix. The kernel bug is not specific to MPTCP, so this only closes the known exploit path. The real fix is a patched host kernel.
- **TrustTunnel endpoint 1.3.1 and client 1.3.0.** `moav test` now runs the real client over HTTP/2 and HTTP/3 separately, and moav-client pins the client download by SHA256.
- **Slipstream deprecation, phase 1.** Upstream is archived. Slipstream is off by default and no longer routed; MasterDNS and dnstt cover the DNS-tunnel case.
- **Digest pinning and Renovate.** Every default runtime image is pinned by tag and digest, and [Renovate](https://docs.renovatebot.com/) opens grouped update PRs in both repos.
- **CLI, user-add and AmneziaWG fixes.** `moav regenerate-users` keeps the AmneziaWG key. `moav restart` applies `.env` changes. `moav user add` from a non-root operator stops before changing anything and prints the fix, instead of leaving TrustTunnel crash-looping.
- **Client routing.** moav-client classifies hostnames before it dials, so in-country names go direct and never see your exit server's IP.

Component versions, with upstream notes:

| Component | Now | Why it moved |
|---|---|---|
| [Xray-core](https://github.com/XTLS/Xray-core/releases/tag/v26.11.9) | v26.11.9 | MPTCP off in the listener (from [v26.10.31](https://github.com/XTLS/Xray-core/releases/tag/v26.10.31)), Chrome 155 fingerprint |
| [sing-box](https://github.com/SagerNet/sing-box/releases/tag/v1.14.4) | 1.14.4 | The client sidecar now matches the server |
| TrustTunnel [endpoint](https://github.com/TrustTunnel/TrustTunnel/releases/tag/v1.3.1) / [client](https://github.com/TrustTunnel/TrustTunnelClient/releases/tag/v1.3.0) | 1.3.1 / 1.3.0 | Error-response fixes on the endpoint; new QUIC stack and HTTP/3 crash fixes in the client |
| [Go](https://go.dev/doc/go1.27) | 1.27 | Builders were on end-of-life 1.22 to 1.25 |
| [Alpine](https://alpinelinux.org/posts/alpine-3.24.0-released/) | 3.24 | 3.21 stopped receiving fixes on 2026-11-01 |
| [Grafana](https://github.com/grafana/grafana/releases/tag/v13.3.1) | 13.3.1 | Six CVEs, two of them high |
| [Snowflake](https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake/-/releases/v2.15.4) | 2.15.4 | Dependency security fixes, proxy deadlock fix |

## Action required {#action-required}

**Server operators (MoaV 2.5.0)**

- **Slipstream clients stop connecting after this update.** Keep `ENABLE_MASTERDNS=true` and/or `ENABLE_DNSTT=true` with their NS records (`moav doctor dns`), run `moav switch-dns dnstt+masterdns+xdns`, then `moav regenerate-users` and hand out the new bundles.
- **TrustTunnel: rebuild its image.** Its egress filter needs `iptables`, which only the new image has; with isolation on, the container refuses to start without it. The filter also blocks DappNode's `172.33.0.0/16`, which is public address space elsewhere and is now unreachable through TrustTunnel on every server.
- **Egress isolation is on by default.** Clients can no longer reach private ranges through the server, and WireGuard/AmneziaWG peers can no longer reach each other. If you run a trusted LAN relay that depends on either, set `EGRESS_ISOLATION=off` in `.env` and run `moav restart`.
- **cAdvisor moved registries.** The default image is now `ghcr.io/google/cadvisor`. If `.env` sets `IMAGE_CADVISOR` to the old `gcr.io` path, update or remove it, and allow `ghcr.io` in any registry allowlist.

**Client installs (moav-client 1.5.0)**

- **Add the `.ir` direct rule by hand.** An update never rewrites your `config.yaml`. Without the rule, an `.ir` name whose local DNS lookup fails goes through the proxy, and your exit server connects to it from its own IP. Add it under `routing_rules`:

    ```yaml
    - match: {type: domain_suffix, value: ir}
      action: direct
    ```

- **An unknown `tls_profile` is now a hard error.** TrustTunnel client 1.3.0 refuses a `client.toml` with a value it does not recognise. MoaV bundles do not set it; fix or remove it in hand-edited or third-party bundles.

## Upgrade

```bash
moav update && moav build && moav start
```

No re-bootstrap is needed. Do not skip the build: the MPTCP and egress changes only take effect once the containers are rebuilt and recreated. Then patch the host kernel.

!!! note "From MoaV 2.5.1: `moav update`, then `moav apply`"
    The sequence above is the manual path for 2.5.0. It is **legacy (pre-2.5.1) and will be removed from the docs in a future release**. From 2.5.1 on, `moav apply` builds, refreshes bundles and recreates the containers in one command, and `moav update --apply` does both in one go. See [Updating MoaV](../../SETUP.md#updating-moav).

<!-- LEGACY-PRE-2.5.1: remove together with the other legacy update guidance (MoaV CHANGELOG 2.5.1, Deprecated) -->

On the client, run `moav-client update` twice: the first run is still executed by the old wrapper and does not move the component versions.

## Update: MoaV 2.5.1 {#update-2-5-1}

[MoaV v2.5.1](https://github.com/MotherofallVPNs/MoaV/releases/tag/v2.5.1) is a patch on top of 2.5.0. It has no breaking changes and needs no re-bootstrap.

- **Grafana 13.3.2 (security).** An upstream [security release](https://github.com/grafana/grafana/releases/tag/v13.3.2) that fixes CVE-2026-107561 and CVE-2026-88960. It replaces the 13.3.1 in the table above. Only the monitoring profile runs Grafana.
- **Umask crash-loop fixed.** `moav update` run under a restrictive umask (`umask 077`, which the MoaV Deploy app's SSH session uses) left the checkout owner-only, so the containers that do not run as root restarted in a loop. `moav` now sets the umask itself. Already affected? Update, then run `moav apply`, or check and repair by hand with `moav doctor perms` and `moav doctor perms --fix`. More in [Troubleshooting](../../TROUBLESHOOTING.md#containers-restart-in-a-loop-with-permission-denied-after-an-update).
- **`moav apply`.** One unattended command that makes an update live: build, refresh bundles, recreate the containers. `moav update --apply` does both in one go. See the [CLI reference](../../CLI.md#moav-apply).
- **`moav build` knows every compose profile.** `moav build xhttp` and `moav build setup` no longer fail with "no such service".

To get it: `moav update`, then `moav apply`.

Found a vulnerability? Report it privately: see [SECURITY.md](https://github.com/MotherofallVPNs/MoaV/blob/main/SECURITY.md). For everything else, open an [issue](https://github.com/MotherofallVPNs/MoaV/issues).
