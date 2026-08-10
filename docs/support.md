# Support MoaV

MoaV is free software built for people who can't rely on the internet being open. There are four ways to help, and the first one is worth more than the rest.

## Run a server

**This is the highest-leverage thing you can do.** Every MoaV server is capacity that didn't exist before — for your family, your colleagues, or people you'll never meet. The project doesn't run infrastructure on anyone's behalf; the network *is* the people running servers.

A $5/month VPS or a Raspberry Pi in a spare room is enough. [Quick Start](quick-start.md) takes about ten minutes.

If you already run one, the most useful next step is **giving bundles to people who need them** — see [sharing safely](OPSEC.md#sharing-bundles-safely) first, because how you distribute matters as much as that you do.

### Donate bandwidth instead of users

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

**The single highest-value target is the user bundle guide** — the `README.html` template that ships inside every bundle. It is the one document a person reads while trying to get online, often on a phone, often in a hurry. It already ships English and Farsi; every additional language there reaches people who never touch this site.

After that, in order:

- **The bundle guide template** (`scripts/lib/bundle-readme.sh` / its template in the MoaV repo)
- **The project READMEs** — [MoaV](https://github.com/MotherofallVPNs/MoaV) and [moav-client](https://github.com/MotherofallVPNs/moav-client). MoaV already has `README-fa.md` as the pattern to follow.
- **The docs pages read under pressure**: [Quick Start](quick-start.md), [Setup](SETUP.md), [DNS Configuration](DNS.md), [Client Apps](CLIENTS.md), [Troubleshooting](TROUBLESHOOTING.md), [OPSEC](OPSEC.md)

Deep developer docs can stay English.

**Partial translations are welcome** — a translated Quick Start on its own is useful. Two things we ask:

- **Human-reviewed only.** A machine-translated DNS or OPSEC instruction that's subtly wrong is worse than an English one that's right. Unreviewed drafts get marked as drafts.
- **English stays the source of truth**, so a translated page can be checked against it when things change.

Open an issue saying which language you'd like to take, and we'll set up the scaffolding.

## Donate money

Funds go to infrastructure the project actually needs — test servers for the end-to-end suite, domains, and build capacity. Not salaries.

<!-- FUNDING:START -->
!!! tip "Cards, PayPal, recurring"

    | Platform | Link |
    |---|---|
    | **GitHub Sponsors** | [github.com/sponsors/shayanb](https://github.com/sponsors/shayanb) |
    | **Buy Me a Coffee** | [buymeacoffee.com/pangana](https://buymeacoffee.com/pangana) |

!!! abstract "Crypto"

    | Coin | Address |
    |---|---|
    | **Bitcoin (BTC)** | <code>bc1qkfq3hg5kpzgy7muc8m3pmh6zemhv820a0ndqgg</code> |
    | **Ethereum (ETH)** <sup>1</sup> | <code>0xB4D06BDb0C2f1D81E0b0b805Ed813F4ffe960aE2</code> |
    | **Zcash (ZEC)** | <code>u1pclheucppc87qlffh9m8wjfw87w2nka40w9nxjuqnyppj0kx9xp7z9rg6wx556662y5f8dtfyeynmm2lnz5aqvaqzmnpajlq0mnmkntdqzqqegk8lwv09cnudf3ttzm3878p3030j3lwupj257rmmv9p3ea32hgwsuf3jdh8ycv7q587</code> |
    | **Tron** <sup>2</sup> | <code>TBSCbnTZCELrMnioobZMkah5r9qS6B1tC6</code> |

    <sup>1</sup> **Ethereum (ETH)** — works on **all EVM chains** at this same address: Ethereum mainnet, BNB Smart Chain (BEP-20), and every L2 (Arbitrum, Optimism, Base, Polygon, Gnosis, zkSync, and so on), plus **any ERC-20 token** such as USDC, USDT or DAI. Use whichever network is cheapest for you.

    <sup>2</sup> **Tron** — accepts TRX and **TRC-20 tokens** (USDT, USDC). Tron has its own address format, so this one is not interchangeable with the EVM address above.
<!-- FUNDING:END -->

!!! warning "Verify the address"
    Addresses are long and easy to spoof. Take them from this page or the repository over HTTPS, and check the first and last characters after pasting. **We will never DM you an address.**

    The table above is generated at build time from [`.github/FUNDING.yml`](https://github.com/MotherofallVPNs/MoaV/blob/main/.github/FUNDING.yml) in the MoaV repository, which is the single source of truth — so what you see here is whatever that file says, and it cannot drift from the repo.

---

## Just here to use it?

That's fine — that's the point. If you want to help without running anything, the most useful things are: tell someone who needs it, report what breaks, and don't share bundles in public channels where they'll be collected and blocked.
