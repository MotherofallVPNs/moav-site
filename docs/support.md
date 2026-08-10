# Support MoaV

MoaV is free software built for people who can't rely on the internet being open. There are four ways to help, and the first one is worth more than the rest.

## Run a server

**This is the highest-leverage thing you can do.** Every MoaV server is capacity that didn't exist before — for your family, your colleagues, or people you'll never meet. The project doesn't run infrastructure on anyone's behalf; the network *is* the people running servers.

A $5/month VPS or a Raspberry Pi in a spare room is enough. [Quick Start](quick-start.md) takes about ten minutes.

If you already run one, the most useful next step is **giving bundles to people who need them** — see [sharing safely](OPSEC.md#sharing-bundles-safely) first, because how you distribute matters as much as that you do.

## Donate bandwidth

You can help even without users of your own, by relaying traffic for existing circumvention networks. Both are opt-in, capped, and run alongside everything else:

```bash
moav start conduit      # relay for Psiphon users worldwide
moav start snowflake    # relay for Tor users
```

- **[Psiphon Conduit](protocols.md#psiphon-conduit)** — your spare bandwidth carries Psiphon traffic for people in censored regions.
- **[Tor Snowflake](protocols.md#tor-snowflake)** — your server becomes a Snowflake proxy, helping people reach Tor.

You can also **donate configs to [MahsaNet](mahsanet.md)**, which distributes them to users in Iran who have no server of their own. That turns spare capacity on your server into access for someone who can't set one up.

## Contribute code

Bugs, protocols, docs, packaging — all of it. [Development & Testing](development.md) covers running from source, how CI and the end-to-end suite work, and the one rule that shapes the project: **every bug fixed ships a regression test in the same PR**.

**Bug reports count.** A reproducible report with `moav doctor` output is often more work than the fix, and it's the thing that turns "it's broken for me" into something that stays fixed for everyone.

> Never paste bundles, `.env` contents or share links into an issue — they contain live keys.

## Translate

Documentation only in English is a real barrier for exactly the people MoaV exists for. A Persian setup guide is worth more than another protocol.

The highest-value pages are the ones someone reads under pressure: [Quick Start](quick-start.md), [Setup](SETUP.md), [DNS Configuration](DNS.md), [Client Apps](CLIENTS.md), [Troubleshooting](TROUBLESHOOTING.md) and [OPSEC](OPSEC.md). Deep developer docs can stay English.

**Partial translations are welcome** — a translated Quick Start on its own is useful. Two things we ask:

- **Human-reviewed only.** A machine-translated DNS or OPSEC instruction that's subtly wrong is worse than an English one that's right. Unreviewed drafts get marked as drafts.
- **English stays the source of truth**, so a translated page can be checked against it when things change.

Open an issue saying which language you'd like to take, and we'll set up the scaffolding.

## Donate money

Funds go to infrastructure the project actually needs — test servers for the end-to-end suite, domains, and build capacity. Not salaries.

| | |
|---|---|
| **GitHub Sponsors** | [github.com/sponsors/MotherofallVPNs](https://github.com/sponsors/MotherofallVPNs) |
| **Monero (XMR)** | *see the [repository](https://github.com/MotherofallVPNs/MoaV) for the current address* |
| **Bitcoin / Lightning** | *see the [repository](https://github.com/MotherofallVPNs/MoaV) for the current address* |

!!! note "Why Monero and Lightning"
    For a censorship-circumvention project, privacy-preserving payment rails aren't a nice-to-have. Donors in hostile jurisdictions shouldn't have to create a traceable financial link to a circumvention tool in order to support one.

!!! warning "Verify the address"
    Addresses are long and easy to spoof. Take them from the project repository or this site over HTTPS, and check the first and last characters after pasting. We will never DM you an address.

---

## Just here to use it?

That's fine — that's the point. If you want to help without running anything, the most useful things are: tell someone who needs it, report what breaks, and don't share bundles in public channels where they'll be collected and blocked.
