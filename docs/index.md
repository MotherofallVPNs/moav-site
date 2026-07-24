# MoaV Documentation

**MoaV (Mother of all VPNs)** is a free, open-source multi-protocol censorship circumvention stack. Deploy a full arsenal of [anti-censorship protocols](protocols.md) on any VPS or home server with a single command.

MoaV generates ready-to-use **client bundles** for each user, containing config files, QR codes, and step-by-step instructions (in English and Farsi) for every enabled protocol. Non-technical users simply open the bundle's `README.html` in their browser, scan a QR code, and connect. No manual configuration needed.

Read the concise [Mission](mission.md), the project's [Impact](impact.md) model, and the public [Threat Model](threat-model.md).

---

**New here?** Start with the [Quick Start Guide](quick-start.md) to get up and running in minutes.

---

## Guides

- **[Quick Start](quick-start.md)**: Get MoaV running in 5 steps
- **[Setup Guide](SETUP.md)**: Complete installation with all options
- **[DNS Configuration](DNS.md)**: DNS records for your domain and provider
- **[VPS Deployment](DEPLOY.md)**: One-click deploy on Hetzner, DigitalOcean, Vultr, Linode

## Using MoaV

- **[Client Apps](CLIENTS.md)**: Connect from iOS, Android, macOS, Windows, Linux
- **[MoaV Client](client.md)**: Self-hosted client with a dashboard, load-balancing, and automatic failover
- **[CLI Reference](CLI.md)**: All `moav` commands and options
- **[Monitoring](MONITORING.md)**: Grafana + Prometheus dashboards
- **[Troubleshooting](TROUBLESHOOTING.md)**: Common issues and fixes

## Security & Philosophy

- **[Mission](mission.md)**: What MoaV is, who it serves, and how to help
- **[Impact](impact.md)**: Theory of change, outcomes, and measurable progress
- **[Threat Model](threat-model.md)**: Honest limits, adversaries, metadata risks, and safety assumptions
- **[OPSEC Guide](OPSEC.md)**: Security best practices for operators
- **[Mission & Philosophy](philosophy.md)**: The longer manifesto behind the project
- **[Supported Protocols](protocols.md)**: All 16+ protocols with descriptions and links

## Developer

- **[Development & Testing](development.md)**: repo layout, test/e2e coverage, self-hosted runner setup, and the contributor/agent checklists
