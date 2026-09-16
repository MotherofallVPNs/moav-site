---
title: How to help test MoaV
description: A standing guide for testing MoaV release candidates from real, censored networks. Find the latest RC, run it on a throwaway box, and report what survives.
hide:
  - navigation
---

<p class="post-meta">Evergreen guide · updated per release · <a href="../">The MoaV Blog</a></p>

# How to help test MoaV

Free internet is a human right, and the only way MoaV keeps earning that claim is if it actually connects from the networks that fight hardest to block it. Our CI builds every image and runs the full protocol matrix on a clean server for every change. What CI cannot do is sit inside Iran, China, or Russia on a real ISP during a real throttle. **You can.**

This page is the standing guide. Each release candidate gets its own short post with what changed; the *how* lives here so it stays current.

## Find the current release candidate

The latest RC is always on the releases page. Grab the newest tag that ends in `-rc.N`:

- **Releases:** [github.com/MotherofallVPNs/MoaV/releases](https://github.com/MotherofallVPNs/MoaV/releases)
- Each RC test-call post (tagged **Testing** on [the blog](index.md)) links to its exact tag, what's new, and the tracking pull request.

Throughout this guide, `<RC_TAG>` means that tag, for example `v2.3.0-rc.5`.

!!! warning "A release candidate is not a stable release"
    Run it on a test or throwaway server, never the box your friends and family depend on. Stable `moav update` will not pull an RC; you opt in explicitly with the tag.

## Run it

=== "Fresh install (throwaway server)"

    ```bash
    curl -fsSL moav.sh/install.sh | bash -s -- -b <RC_TAG>
    ```
    Installs to `/opt/moav` and walks you through setup.

=== "Upgrade an existing test box"

    ```bash
    moav update -b <RC_TAG>
    moav build
    moav start
    moav regenerate-users   # re-issues bundles; some RCs require it, the post will say
    ```

## The test plan

Work through as much as you can. Even one or two data points from a real network is valuable.

**1. It comes up clean** — `moav doctor` should be green; note anything that is not.

**2. Every enabled protocol passes the built-in matrix:**
```bash
moav user add alice
moav test alice
```
Report any protocol that shows `fail`. A `warn` or `skip` is usually environmental.

**3. Real clients, real network (the part CI cannot do).** Import a bundle into the apps your community actually uses and connect **from your real network**: which protocols connect, which are blocked or throttled, rough speed on each. If you are behind a national firewall, this is the single most useful thing you can report.

**4. Exercise whatever the RC post highlights** — a new protocol, a new obfuscation, an upgrade path. The per-release post lists the specifics and any `.env` toggles.

## How to report back

Tell us what happened, good or bad: server OS and architecture, your country and ISP if you are comfortable sharing (it genuinely helps), which protocols passed, failed, or were blocked, which client apps you used, rough speeds, and any exact error text.

- **GitHub:** open an issue at [MotherofallVPNs/MoaV](https://github.com/MotherofallVPNs/MoaV/issues), or comment on the RC's tracking pull request.
- **Telegram:** [@motherofallvpns](https://t.me/motherofallvpns).

!!! note "Please redact secrets"
    Never paste keys, passwords, share links, or your server IP into a public issue or chat. Describe the shape of the problem, not the credentials.

## Why your test matters

A censor only has to win once to cut someone off. MoaV's answer is diversity: when one protocol falls, another is already standing. But that promise is only as good as the protocols that actually reach you, on your ISP, on the day it matters. CI proves the code is correct. You prove it works where it counts.

**Ready?** Pick the [latest RC test-call post](index.md) and go.
