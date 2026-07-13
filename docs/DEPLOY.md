# VPS Deployment

Deploy MoaV on any VPS in minutes. The flow is the same everywhere: create an Ubuntu server, SSH in, and run the one-line installer.

## How It Works

1. **Create a VPS** with the recommended specs (1 vCPU, 2 GB RAM recommended) and an Ubuntu 22.04 image
2. **SSH into your server** once it boots (usually 1-2 minutes): `ssh root@YOUR_IP`
3. **Run the installer:**
   ```bash
   curl -fsSL moav.sh/install.sh | bash
   ```
   It installs Docker + prerequisites, clones MoaV to `/opt/moav`, installs the global `moav` command, and launches the interactive setup wizard.

The installer is safe to re-run and prompts for everything it needs. On low-RAM hosts it offers to add a swapfile so image builds don't get OOM-killed.

---

## Hetzner

Hetzner offers excellent value with servers starting at €3.79/month in European data centers.

### Steps

1. Go to [Hetzner Cloud Console](https://console.hetzner.cloud/)
2. Click **"Add Server"**
3. Choose:
   - **Location**: Choose closest to your users
   - **Image**: Ubuntu 22.04
   - **Type**: CX22 (2 vCPU, 4 GB RAM) recommended, or CX11 (1 vCPU, 2 GB) minimum
   - **Networking**: Enable IPv4 and IPv6
4. Add your SSH key
5. Click **"Create & Buy now"**
6. Wait 1-2 minutes, then SSH in: `ssh root@YOUR_IP`
7. Run `curl -fsSL moav.sh/install.sh | bash` and follow the setup wizard

### Recommended Specs
- **Minimum**: CX11 (1 vCPU, 2 GB RAM) - €3.79/month
- **Recommended**: CX22 (2 vCPU, 4 GB RAM) - €5.39/month

---

## Linode

Linode (now Akamai) offers reliable servers with good global coverage.

### Steps

1. Go to [Linode Cloud Manager](https://cloud.linode.com/)
2. Click **"Create Linode"**
3. Choose:
   - **Image**: Ubuntu 22.04 LTS
   - **Region**: Choose closest to your users
   - **Linode Plan**: Shared CPU - Nanode 1 GB ($5/mo) or Linode 2 GB ($12/mo)
4. Set your root password and add your SSH key
5. Click **"Create Linode"**
6. Wait 1-2 minutes, then SSH in: `ssh root@YOUR_IP`
7. Run `curl -fsSL moav.sh/install.sh | bash` and follow the setup wizard

### Recommended Specs
- **Minimum**: Nanode 1 GB (1 vCPU, 1 GB RAM) - $5/month
- **Recommended**: Linode 2 GB (1 vCPU, 2 GB RAM) - $12/month

---

## Vultr

Vultr offers competitive pricing with many global locations.

### Steps

1. Go to [Vultr Dashboard](https://my.vultr.com/)
2. Click **"Deploy +"** → **"Deploy New Server"**
3. Choose:
   - **Choose Server**: Cloud Compute - Shared CPU
   - **Server Location**: Choose closest to your users
   - **Server Image**: Ubuntu 22.04 LTS x64
   - **Server Size**: 25 GB SSD ($5/mo) minimum
4. Add your SSH key
5. Click **"Deploy Now"**
6. Wait 1-2 minutes, then SSH in: `ssh root@YOUR_IP`
7. Run `curl -fsSL moav.sh/install.sh | bash` and follow the setup wizard

### Recommended Specs
- **Minimum**: 25 GB SSD (1 vCPU, 1 GB RAM) - $5/month
- **Recommended**: 55 GB SSD (1 vCPU, 2 GB RAM) - $10/month

---

## DigitalOcean

DigitalOcean is popular and beginner-friendly with excellent documentation.

### Steps

1. Go to [DigitalOcean Dashboard](https://cloud.digitalocean.com/)
2. Click **"Create"** → **"Droplets"**
3. Choose:
   - **Region**: Choose closest to your users
   - **Image**: Ubuntu 22.04 (LTS) x64
   - **Size**: Basic → Regular → $6/mo (1 GB RAM) or $12/mo (2 GB RAM)
   - **Authentication**: SSH Key (recommended)
4. Click **"Create Droplet"**
5. Wait 1-2 minutes, then SSH in: `ssh root@YOUR_IP`
6. Run `curl -fsSL moav.sh/install.sh | bash` and follow the setup wizard

### Recommended Specs
- **Minimum**: Basic (1 vCPU, 1 GB RAM) - $6/month
- **Recommended**: Basic (1 vCPU, 2 GB RAM) - $12/month

---

## After Installation

The setup wizard will guide you through:

1. Entering your domain name
2. Providing email for TLS certificates
3. Setting the admin dashboard password
4. Selecting which protocols to enable
5. Creating initial users

Once it finishes, `moav status` shows the running services and `moav help` lists everything else.

### Prerequisites Before Setup

Before running the setup, make sure:

1. **Domain configured**: Your domain's DNS A record points to your server's IP
2. **Ports open**: Most VPS providers have all ports open by default, but verify:
   - 443/tcp (Reality)
   - 443/udp (Hysteria2)
   - 8443/tcp (Trojan)
   - 4443/tcp+udp (TrustTunnel)
   - 2082/tcp (CDN WebSocket, if using Cloudflare)
   - 51820/udp (WireGuard)
   - 80/tcp (Let's Encrypt verification)

---

## Troubleshooting

### Installer failed partway

The installer is idempotent — just re-run it:
```bash
curl -fsSL moav.sh/install.sh | bash
```

### Docker not running

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### DNS not propagated yet

Wait a few minutes and verify:
```bash
dig +short yourdomain.com
```

Should return your server's IP address.

---

See [SETUP.md](SETUP.md) for detailed manual installation and configuration instructions.
