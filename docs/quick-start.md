# Quick Start

Get MoaV running in **two steps** — install, then explore. It deploys [16+ anti-censorship protocols](protocols.md) and turns each user into a share-ready **client bundle** (configs + QR codes + plain-language instructions) that anyone can open and connect with — no deep networking knowledge required. Curious why MoaV exists? Read [the mission](philosophy.md).

## Requirements

- A VPS **or a home server** — Debian 12 / Ubuntu 22.04/24.04, or a **Raspberry Pi 4+** (2 GB+ RAM, ARM64). 1 vCPU / 1 GB RAM minimum.
- A domain name — optional; [domainless mode](SETUP.md#domainless-mode) works without one.

!!! tip "Need a VPS?"
    See [VPS Deployment](DEPLOY.md) for provider-by-provider steps starting at ~$5/month.

!!! tip "Raspberry Pi or home server?"
    MoaV runs great at home in **domainless mode** — no domain required. A home server sits behind a router, so forward the protocol ports to it first: see [Home Servers & Raspberry Pi → Port Forwarding](DNS.md#port-forwarding). (Check for CGNAT before you start — some ISPs block inbound connections entirely.)

## Step 1 — Install

SSH into your server and run:

```bash
curl -fsSL moav.sh/install.sh | bash
```

This installs Docker, clones MoaV, and walks you through first-time setup, asking for:

- **Domain** — pointed at this server (or leave blank for domainless mode)
- **Email** — for your Let's Encrypt TLS certificates
- **Admin password** — for the web dashboard

When it finishes, it prints the exact **DNS records** to add at your registrar — an `A` record for your domain, plus the `NS` records that delegate the DNS-tunnel subdomains to your server.

!!! tip "Point your DNS first (recommended)"
    Certificate issuance needs your domain already resolving to this server, so it's smoothest to add the DNS records **before** you install. Find the exact records for your setup in [DNS Configuration](DNS.md), set them up, then run the installer.

Finally, open your firewall for the protocols you enabled — the [full port list is here](DNS.md#port-forwarding). Most cloud VPS providers leave all ports open by default, so you may not need to.

## Step 2 — Explore your MoaV server

Everything after install lives in one friendly place. Just run:

```bash
moav
```

to open the interactive menu:

```
  Services
  1) Start services
  2) Stop services
  3) Restart services
  4) View status
  5) View logs

  Users & donations
  6) User management
  7) Donate configs (MahsaNet, Psiphon, Snowflake)

  System
  8)  Doctor — diagnose problems
  9)  Admin password reset
  10) Update MoaV
  11) Build/rebuild services
  12) Export/Import (migration)

  0)  Exit
```

From here you **start services**, **add users**, run **diagnostics**, and more — nothing to memorize. The header shows what's running plus your **admin dashboard** (`https://your-server:9443`) and **Grafana** (`https://your-server:9444`, if monitoring is on). Every item maps to a `moav` command — the **[CLI Reference](CLI.md)** walks through the full menu and each one.

Two commands worth knowing right away:

```bash
moav status   # what's running, ports, and health at a glance
moav help     # every command MoaV offers
```

### Share with your users

Add a user — menu → **User management**, or `moav user add alice` (`--batch 10` for many) — and MoaV generates a **client bundle** in `outputs/bundles/`:

- **`README.html`** — step-by-step instructions (English + Farsi) with QR codes. Users open it in a browser, pick their platform, scan a code, and they're connected — no configuration.
- Config files and share links for every enabled protocol, plus a one-paste **V2Ray subscription** for MahsaNG / v2rayNG / Hiddify.

Send them the bundle (or just `README.html`) over a secure channel — Signal, encrypted email, or in person. Grab it from the **admin dashboard** (login → Download), by `scp`, or `moav user package alice`. See [Client Apps](CLIENTS.md) for platform-specific details.

## Next Steps

- [Client Apps](CLIENTS.md) — Platform-specific connection instructions
- [CLI Reference](CLI.md) — The full menu and every `moav` command
- [CDN Mode](SETUP.md#cdn-fronted-mode-cloudflare) — Route through Cloudflare when your IP is blocked
- [Monitoring](MONITORING.md) — Grafana dashboards
- [Troubleshooting](TROUBLESHOOTING.md) — Common issues and fixes
