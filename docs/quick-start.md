# Quick Start

Install MoaV, then hand someone a link that connects them. That's the whole path, and it takes about ten minutes.

MoaV deploys [16+ anti-censorship protocols](protocols.md) and turns each user into a share-ready **bundle** — configs, QR codes, and plain-language instructions in English and Farsi. The person receiving it doesn't need to understand any of it. Curious why this exists? Read [the mission](philosophy.md).

## What you need

- **A server** — Debian 12 / Ubuntu 22.04 or 24.04, or a **Raspberry Pi 4+** (ARM64). 1 vCPU / 1 GB RAM is the floor; 2 GB if you want monitoring.
- **A domain** — optional, but worth it. It roughly doubles the protocols you can offer and is the only way to run the DNS tunnels, which are what still work during a shutdown. See [Do I need a domain?](DNS.md#do-i-need-a-domain).

!!! tip "Point your DNS *before* installing"
    Certificate issuance needs the domain already resolving to the server, so adding the records first makes the install smooth. The exact records are in [DNS Configuration](DNS.md#with-a-domain-the-records) — and after setup, `moav doctor dns` writes them out for you as a file you can import straight into Cloudflare.

    No VPS yet? [VPS Deployment](DEPLOY.md) has provider-by-provider steps from ~$5/month. On a home server or Pi, check for CGNAT first and forward the [protocol ports](DNS.md#ports-to-forward).

## 1. Install

SSH in and run:

```bash
curl -fsSL moav.sh/install.sh | bash
```

It installs Docker, clones MoaV, and asks for three things: your **domain** (blank for domainless), an **email** for Let's Encrypt, and an **admin password** — which is also your Grafana password, so pick a real one.

When it finishes it prints your dashboard URLs and the DNS records to add.

## 2. Create your first user

Two ways. Use whichever you prefer — they do the same thing.

=== "Web dashboard"
    Open **`https://your-server:9443`** and log in — **any username**, with the admin password you chose.

    ??? warning "Your browser will warn about the certificate"
        The dashboard uses a self-signed certificate, so you'll see a privacy warning the first time. That's expected. Proceed past it.

    Click **+ New**, enter a name, and the user appears in the table with a badge for every protocol they got — Reality, Trojan, Hy2, CDN, WG, AWG, XHTTP and so on. Hit **.zip** to download their bundle.

    The dashboard is the easiest place to run day to day: it lists every user with their creation date and protocols, downloads bundles on demand, and shows live server stats.

=== "Command line"
    ```bash
    moav user add alice              # one user
    moav user add alice --package    # ...and build the .zip
    moav user add --batch 10         # ten at once
    moav user list                   # who exists
    ```

    Bundles land in `outputs/bundles/alice/`.

Either way you get the same bundle:

- **`README.html`** — the file to actually send. Step-by-step instructions in English and Farsi, with QR codes. They open it, pick their platform, scan, and they're online.
- Config files and share links for every enabled protocol, plus a one-paste **subscription** for MahsaNG, v2rayNG and Hiddify.

Send it over something private — Signal, encrypted email, in person. See [Client Apps](CLIENTS.md) for what to tell them per platform.

## 3. Know these four commands

```bash
moav status    # what's running, which profiles are up, health at a glance
moav doctor    # diagnose problems: DNS, ports, certificates, resources
moav logs      # tail a service when something misbehaves
moav test alice  # prove alice's configs actually pass traffic, end to end
```

`moav doctor` is the one to reach for first when anything looks wrong — it checks the things that break most often and usually names the problem outright. `moav test` is the one to run before you tell someone their bundle works, because it connects through each protocol for real and reports the exit IP.

Running plain **`moav`** opens an interactive menu over all of it, so there's nothing to memorize. Every entry maps to a command in the [CLI Reference](CLI.md).

## 4. Watch it work (optional)

If you enabled monitoring, **Grafana** is at **`https://your-server:9444`** — user `admin`, same password.

Ten dashboards ship preconfigured, so there's nothing to build:

| Dashboard | What it tells you |
|---|---|
| **sing-box** | Per-user connections and throughput for Reality, Trojan, Hysteria2, Shadowsocks |
| **WireGuard** · **AmneziaWG** | Peer handshakes, transfer per peer |
| **DNS tunnels** | Traffic across dnstt, Slipstream, MasterDNS, XDNS |
| **Xray** · **telemt** | XHTTP/XDNS and Telegram MTProxy activity |
| **Conduit** · **Snowflake** | Bandwidth you're donating to Psiphon and Tor users |
| **System** · **Containers** | CPU, memory, disk, and per-container resource use |

Not running monitoring? `moav start monitoring` turns it on — it wants ~2 GB RAM. Details in [Monitoring](MONITORING.md).

## Where to go next

- **[Client Apps](CLIENTS.md)** — what your users install, per platform
- **[CLI Reference](CLI.md)** — every command
- **[DNS Configuration](DNS.md)** — records, DNS tunnels, CDN mode
- **[Setup Guide](SETUP.md)** — every configuration option in depth
- **[OPSEC Guide](OPSEC.md)** — running and sharing this safely
- **[Troubleshooting](TROUBLESHOOTING.md)** — when something breaks
