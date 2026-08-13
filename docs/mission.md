# Mission

MoaV, Mother of all VPNs, is open-source resilient connectivity infrastructure for censorship and shutdown environments. It helps trusted operators deploy multi-protocol access nodes so users have fallback routes when VPNs, domains, apps, or protocols are blocked.

MoaV is not trying to be another commercial VPN brand. It is a public-interest deployment stack for people who need the open internet to keep working under pressure.

## The talk

**Rage-coding the Mother of all VPNs** — [Shayan Eskandari](https://github.com/shayanb) at DappCon 2026, Berlin. Why MoaV exists, what it takes to keep sixteen protocols working under pressure, and what was learned building it.

<!-- referrerpolicy must not be no-referrer: YouTube reads the origin to load
     a public embed and answers Error 153 without it. -->
<div class="moav-embed">
  <iframe src="https://www.youtube.com/embed/uYygWN1MZDE" title="Rage-coding the Mother of all VPNs — Shayan Eskandari, DappCon 2026" loading="lazy" referrerpolicy="strict-origin-when-cross-origin" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

<p><a href="https://www.youtube.com/watch?v=uYygWN1MZDE">Watch on YouTube</a></p>

## Why MoaV exists

Internet shutdowns and protocol blocking are now routine tools of control. During protests, crackdowns, elections, and conflicts, governments can throttle bandwidth, block popular apps, fingerprint VPN protocols, and isolate people from the outside world.

Most circumvention tools help only if they are already reachable. A single blocked domain, protocol, app store, payment route, or infrastructure provider can cut off a large group of users at once.

MoaV is built around a different assumption: no single route survives every censor. The useful system is the one that degrades gracefully.

## What MoaV does

MoaV turns a low-cost server into a multi-protocol circumvention node. It automates setup, generates user bundles, and supports multiple transports so operators do not have to assemble a stack by hand.

The goal is simple:

- make deployment fast for trusted operators
- support many fallback protocols
- reduce dependence on one provider or domain
- make operator documentation clear
- keep the code open source and auditable
- help communities add capacity before the next shutdown

## Who MoaV serves

MoaV is designed for:

- people in censored environments who need access to the open internet
- journalists, activists, students, families, and civil-society groups affected by blocking
- diaspora communities that can donate servers, bandwidth, and operational support
- open-source internet-freedom projects that need reusable deployment tooling

The first community focus is Iran, but the design is not Iran-only. The same patterns apply anywhere networks are filtered, throttled, or partially shut down.

## What MoaV is not

MoaV is not a promise of perfect anonymity. It is not a token network. It is not a magic way around every form of surveillance. It is access infrastructure, and it should be used with a clear understanding of risk.

Read the [Threat Model](threat-model.md) for the limits, adversaries, and safety assumptions.

## How to help

If you want to help users reach the open internet:

1. [Deploy MoaV](quick-start.md) on a VPS.
2. Read the [OPSEC Guide](OPSEC.md) before sharing access.
3. Share user bundles only through trusted channels.
4. Enable donation paths such as [Psiphon Conduit](support.md#donate-bandwidth-instead-of-users), [Tor Snowflake](support.md#donate-bandwidth-instead-of-users), or [MahsaNet](mahsanet.md) when appropriate.
5. Contribute code, protocol support, documentation, testing, or translations.

## Related pages

- [Impact](impact.md)
- [Threat Model](threat-model.md)
- [Architecture](architecture.md)
- [Supported Protocols](protocols.md)
- [Mission & Philosophy](philosophy.md)
