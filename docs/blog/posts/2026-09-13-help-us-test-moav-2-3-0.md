---
title: Help us test MoaV 2.3.0
description: A new protocol, a stealthier Hysteria2, a hardened DNS tunnel, and a smoother upgrade. Our automated tests pass; now it needs your real network.
hide:
  - navigation
---

<p class="post-meta">2026-09-13 · Testing · 5 min read · <a href="../../">The MoaV Blog</a></p>

# Help us test MoaV 2.3.0

**MoaV 2.3.0 is in release-candidate testing.** Before we cut the final, we are asking operators and users to run it on a throwaway box, put the new features through their paces on a real network, and tell us what works and what does not.

This is the **first in a series**: from now on, every MoaV release candidate gets a short test-call like this one, with what changed and the exact version to run. The standing *how to test / how to report* lives in one place, [**How to help test MoaV**](../how-to-test.md), so it never goes stale.

- **This RC:** `v2.3.0-rc.5` (or newer, check the [releases page](https://github.com/MotherofallVPNs/MoaV/releases) for the latest `-rc` tag)
- **Tracking:** the [2.3.0 release pull request](https://github.com/MotherofallVPNs/MoaV/pull/335)
- **Full testing guide:** [How to help test MoaV](../how-to-test.md)

!!! warning "A release candidate is not a stable release"
    Run it on a test or throwaway server, not the box your friends and family depend on. Stable `moav update` will not pull an RC; you opt in explicitly with the tag below.

## What is new in 2.3.0

MoaV now ships **18+ circumvention protocols and fallback paths** in one command. Here is what changed this cycle, and what is worth putting under load.

### Snell, a new protocol (on by default)
A lightweight TCP proxy from the [Surge ecosystem](https://manual.nssurge.com/policies/snell.html) with optional HTTP obfuscation. No TLS and no domain required, so it works in domainless mode; a good "different shape on the wire" when the TLS-based protocols get scrutinized.

- **Shared-key.** Unlike the other proxies, Snell is not per-user. Everyone connects with one server key, the same model as the DNS tunnels. Revoking a single user does not remove Snell access; you rotate the key and re-issue.
- **Client support is specific.** Snell v5 works with [**Surge 5**](https://apps.apple.com/us/app/surge-5/id1442620678) or [**Stash**](https://apps.apple.com/us/app/stash-rule-based-proxy/id1596063349) (iOS), [**Clash Mi**](https://apps.apple.com/us/app/clash-mi/id6744321968) (iOS), and [**Clash Meta for Android**](https://github.com/MetaCubeX/ClashMetaForAndroid) or [**FlClash**](https://github.com/chen08209/FlClash). It does **not** work with [v2rayNG](https://github.com/2dust/v2rayNG), [Hiddify](https://hiddify.com), [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid), or the [sing-box](https://sing-box.sagernet.org/) apps.

### Hysteria2 gets a stealthier obfuscation: gecko
[sing-box 1.14](https://github.com/SagerNet/sing-box/releases/tag/v1.14.0) adds a new Hysteria2 obfuscator, **gecko**, which fragments the QUIC handshake into random-sized padded chunks and resists Iran/CN/RU DPI better than the default. It is **opt-in** (`HYSTERIA2_OBFS_TYPE=gecko`), because gecko needs a newer client core (sing-box 1.14+ or [Hysteria](https://v2.hysteria.network/) 2.9.2+).

### sing-box updated to 1.14
The engine behind [Reality](https://github.com/XTLS/REALITY), Trojan, Hysteria2, [Shadowsocks](https://shadowsocks.org/doc/sip022.html), AnyTLS, and Snell. No configuration change is required on your side; we validated the rendered config against the real 1.14 binary in CI.

### XDNS is now encrypted
The XDNS DNS tunnel previously carried its inner traffic unencrypted at the VLESS layer. In 2.3.0 it uses proper VLESS Encryption end to end. It is transparent to you, but existing installs need `moav regenerate-users` after upgrading (below) so clients pick up the key.

### A smoother `moav update`
`moav update -b <tag>` now accepts a **tag**, so you can jump an install straight onto a release candidate. "Discard changes" fully resets, and new config options no longer drag a trailing comment into their value.

### Security and component updates
Grafana moves to 13.2.1 (two CVE fixes), plus routine bumps to Xray-core, telemt, Slipstream, and MasterDNS.

## Run this RC

=== "Fresh install (throwaway server)"

    ```bash
    curl -fsSL moav.sh/install.sh | bash -s -- -b v2.3.0-rc.5
    ```

=== "Upgrade an existing test box"

    ```bash
    moav update -b v2.3.0-rc.5
    moav build
    moav start
    moav regenerate-users        # REQUIRED this cycle: Snell (new default) + the XDNS key
    ```

!!! danger "`moav regenerate-users` is not optional on this upgrade"
    Snell is newly on by default and XDNS now needs an encryption key in each bundle. Without it, existing bundles keep working for every other protocol, but will not include Snell or the updated XDNS.

## What to focus on this cycle

The full [test plan](../how-to-test.md#the-test-plan) still applies. On top of it, these four 2.3.0 changes need real-network data the most. For each: **do the step, then tell us the result in bold.**

1. **Snell (new, on by default).** Import its config into a v5 client (Surge 5, Stash, Clash Mi, Clash Meta for Android, or FlClash — links above). **Tell us:** which app you used, whether it connected, and whether it stayed up. To compare obfuscation, switch `SNELL_OBFS` between `http` and `none` (`moav restart sing-box` + `moav regenerate-users`) and say which held up better.
2. **gecko obfuscation (Hysteria2).** Set `HYSTERIA2_OBFS_TYPE=gecko`, run `moav regenerate-users`, and reconnect with a sing-box 1.14+ client. **Tell us:** does gecko connect, and does it get through where the default `salamander` is blocked or throttled?
3. **XDNS (now encrypted).** If you run XDNS, reconnect after upgrading. **Tell us:** does it still tunnel and reach the internet?
4. **The upgrade path.** From a 2.2.x box, run the upgrade. **Tell us:** do your existing users still connect, and did Snell + XDNS get added to their bundles cleanly?

### What makes a report useful

For any protocol you try, five quick things turn "it's slow" into something we can act on:

- **App + connect** — which client you used, and whether the tunnel comes up at all.
- **Blocked?** — does the protocol/port get through your ISP, or is it dropped or reset.
- **Ping** — rough round-trip latency through the tunnel.
- **Speed** — a quick download ([speed.cloudflare.com](https://speed.cloudflare.com) or Ookla).
- **Where** — your country and ISP if you are comfortable sharing; "a censored network" still helps.

The [general guide](../how-to-test.md#the-test-plan) has the full versions of these (leak tests, OONI, and more).

Then report back per the [guide](../how-to-test.md#how-to-report-back). If you are behind a national firewall, one data point from you is worth more than a week of our automated tests.

Thank you for testing. Every report you send makes the final 2.3.0, and the people who depend on it, a little harder to silence.
