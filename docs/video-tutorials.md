# Video tutorials

Community-made walkthroughs of installing and running MoaV.

!!! info "No English tutorial yet — one in Farsi"
    Switch the language in the top bar (**فارسی**) for a full server walkthrough by [@iaghapour](https://x.com/iaghapour).

    **Made one, or thinking about it?** Open an issue or a PR and we will link it. A recording of a real install is worth more than any amount of prose, and it finds bugs the maintainers never hit — several fixes in [2.1.0](https://github.com/MotherofallVPNs/MoaV/releases/tag/v2.1.0) came from watching the Farsi one. Credit stays with the author; we link rather than re-host.

Prefer reading? [Quick Start](quick-start.md) is the same path in about ten minutes.

## What a good tutorial covers

Roughly the order a new operator needs. Nobody has to cover all of it — one clear piece is useful on its own.

**Getting a server running**

1. A VPS and a domain pointed at it — [VPS Deployment](DEPLOY.md), [DNS Configuration](DNS.md)
2. The one-command install, and what `moav bootstrap` asks for
3. **Running it at home** instead: a Raspberry Pi or spare box, checking for CGNAT first, forwarding the ports — [Home server / Raspberry Pi](DNS.md#home-server-raspberry-pi)

**Getting people connected**

4. Creating a user and sending them their bundle — `moav user add NAME --package`
5. Connecting from a phone: importing a config, and which app suits which protocol — [Client Apps](CLIENTS.md)
6. Choosing between protocols, and what to do when one is blocked — [Supported Protocols](protocols.md#which-one-should-i-use), then `moav doctor`

**Going further**

7. **The MoaV client** — running [moav-client](client.md) on a desktop so several protocols are probed and the fastest live one is used automatically, rather than switching by hand
8. **Routing rules and plugins**, which is where it stops being only a VPN. Send local and national sites *direct* so banking and government portals still work and your exit bandwidth is not wasted; block ad and tracker domains for every device on the tunnel; block torrent traffic on a donated server. The client's rule engine is hot-swappable, so this is a satisfying thing to demo live.
9. **The admin dashboard and Grafana** — adding users from a browser, and watching per-protocol throughput and per-user traffic: [admin commands](CLI.md#admin), [Monitoring](MONITORING.md)
