---
title: Help us test MoaV 2.3.0
description: A new protocol, a stealthier Hysteria2, a hardened DNS tunnel, and a smoother upgrade. We built it and tested it in CI. Now we need your real network.
hide:
  - navigation
---

<p class="post-meta">2026-09-13 · Release · 6 min read · <a href="../../">The MoaV Blog</a></p>

# Help us test MoaV 2.3.0

Free internet is a human right, and the only way MoaV keeps earning that claim is if it actually connects from the networks that fight hardest to block it. Our CI builds every image and runs the full protocol matrix on a clean server for every change. What CI cannot do is sit inside Iran, China, or Russia on a real ISP during a real throttle. **You can. That is why this post exists.**

MoaV 2.3.0 is in release-candidate testing. Before we cut the final, we are asking operators and users to run it on a throwaway box, put the new features through their paces, and tell us what works and what does not.

!!! warning "This is a release candidate, not a stable release"
    Run it on a test or throwaway server, not the box your friends and family depend on. Stable `moav update` will not pull an RC. You opt in explicitly, as shown below.

## What is new in 2.3.0

MoaV now ships **18+ circumvention protocols and fallback paths** in one command. Here is what changed this cycle.

### Snell, a new protocol (on by default)
A lightweight TCP proxy from the Surge ecosystem with optional HTTP obfuscation. No TLS and no domain required, so it works in domainless mode. It is a good "different shape on the wire" to have when the TLS-based protocols get scrutinized.

- **Shared-key.** Unlike the other proxies, Snell is not per-user. Everyone connects with one server key, the same model as the DNS tunnels. Revoking a single user does not remove Snell access, you rotate the key and re-issue.
- **Client support is specific.** Snell v5 works with **Surge 5** or **Stash** (iOS), **Clash Mi** or **Mihomo** (iOS), and **Clash Meta for Android** or **FlClash**. It does **not** work with v2rayNG, Hiddify, NekoBox, or the sing-box apps.

### Hysteria2 gets a stealthier obfuscation: gecko
sing-box 1.14 adds a new Hysteria2 obfuscator, **gecko**, which fragments the QUIC handshake into random-sized padded chunks and resists Iran/CN/RU DPI better than the default. It is **opt-in**, because gecko needs a newer client core.

### sing-box updated to 1.14
The engine behind Reality, Trojan, Hysteria2, Shadowsocks, AnyTLS, and Snell. No configuration change is required on your side. We validated the rendered config against the real 1.14 binary in CI.

### XDNS is now encrypted
The XDNS DNS tunnel previously carried its inner traffic unencrypted at the VLESS layer. In 2.3.0 it uses proper VLESS Encryption end to end. It is transparent to you, but existing installs need one command after upgrading (below) so clients pick up the key.

### A smoother `moav update`
- `moav update -b <tag>` now accepts a **tag**, so you can jump an install straight onto a release candidate to test it.
- The "Discard changes" option now fully resets, so local edits no longer block an update.
- New config options added during an update no longer drag a trailing comment into their value.

### Security and component updates
Grafana moves to 13.2.1 (two CVE fixes), plus routine bumps to Xray-core, telemt, Slipstream, and MasterDNS.

## How to run the release candidate

=== "Fresh install (throwaway server)"

    ```bash
    curl -fsSL moav.sh/install.sh | bash -s -- -b v2.3.0-rc.5
    ```
    Installs to `/opt/moav` and walks you through setup. Check the [releases page](https://github.com/MotherofallVPNs/MoaV/releases) for the latest RC tag.

=== "Upgrade an existing test box"

    ```bash
    moav update -b v2.3.0-rc.5   # also exercises the new tag-aware update
    moav build
    moav start
    moav regenerate-users        # REQUIRED: Snell (new default) + the XDNS key
    ```

!!! danger "The `moav regenerate-users` step is not optional on an upgrade"
    Snell is newly on by default and XDNS now needs an encryption key in each bundle. Without it, existing bundles keep working for every other protocol, but will not include Snell or the updated XDNS.

## The test plan

Work through as much as you can. Even one or two data points from a real network is valuable.

**1. It comes up clean**
```bash
moav doctor
```
Everything should be green. Note anything that is not.

**2. Every enabled protocol passes the built-in matrix**
```bash
moav user add alice     # create a test user + bundle
moav test alice         # stand up a client tunnel per protocol, check the exit IP
```
Report any protocol that shows `fail`. A `warn` or `skip` is usually environmental (a protocol that needs hardware or a delegation you have not set up).

**3. Real clients, real network (the part CI cannot do)**
Import alice's bundle into the apps your community actually uses and connect **from your real network**:

- Which protocols connect? Which are blocked or throttled?
- Rough speed on each (a large download, a video call).
- If you are behind a national firewall, this is the single most useful thing you can report.

**4. Try the new Snell protocol**
Snell is on by default. Import the Snell config into a **v5 client** (Surge 5, Stash, Clash Mi, Mihomo, Clash Meta for Android, or FlClash) and confirm it connects and browses. You can switch obfuscation with `SNELL_OBFS=http` (default) or `none` in `.env`, then `moav restart sing-box` and `moav regenerate-users`.

**5. Try gecko obfuscation for Hysteria2 (optional)**
Set `HYSTERIA2_OBFS_TYPE=gecko` in `.env`, run `moav regenerate-users`, and reconnect with a client whose core is **sing-box 1.14+ or Hysteria 2.9.2+**. Compare how it survives on your network versus the default salamander. Older clients will not connect on gecko, that is expected, switch back with `salamander`.

**6. Exercise the upgrade path**
If you started from a 2.2.x box, confirm your **existing users still connect** after the upgrade, and that `moav regenerate-users` cleanly adds Snell and the updated XDNS to their bundles.

## Customizations worth trying

- **Move a fingerprinted port.** If your ISP flags a protocol, change its `PORT_*` in `.env` and `moav restart sing-box`.
- **Turn optional protocols on or off.** Each has an `ENABLE_*` flag and a `PORT_*`. Secrets are auto-generated on first bootstrap, you do not set keys by hand.
- **Donate spare bandwidth.** If your server has headroom, enable Psiphon Conduit and Tor Snowflake, or donate configs to MahsaNet.
- **Watch it live.** Grafana (now 13.2.1) gives you per-protocol throughput and endpoint health.

Full reference lives in [Supported Protocols](../../protocols.md) and the [Setup guide](../../SETUP.md).

## How to report back

Tell us what happened, good or bad: your server OS and architecture, your country and ISP if you are comfortable sharing (it genuinely helps), which protocols passed, failed, or were blocked, which client apps you used, rough speeds, and any exact error text.

- **GitHub:** open an issue at [MotherofallVPNs/MoaV](https://github.com/MotherofallVPNs/MoaV/issues).
- **Telegram:** [@motherofallvpns](https://t.me/motherofallvpns).

!!! note "Please redact secrets"
    Never paste keys, passwords, share links, or your server IP into a public issue or chat. Describe the shape of the problem, not the credentials. If you must share a config to debug, strip the secret first.

## Why your test matters

A censor only has to win once to cut someone off. MoaV's answer is diversity: when one protocol falls, another is already standing. But that promise is only as good as the protocols that actually reach you, on your ISP, on the day it matters. CI proves the code is correct. You prove it works where it counts.

Thank you for testing. Every report you send makes the final 2.3.0, and the people who depend on it, a little harder to silence.
