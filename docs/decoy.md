# The Decoy Website

Every MoaV server ships a **decoy website** — an innocent-looking static site that anyone poking at your server sees instead of anything that reveals a proxy. It answers two kinds of unwanted attention at once:

- **Direct visitors.** A browser or scanner hitting your server's IP over plain HTTP (port 80) gets an ordinary-looking website.
- **Active probing of Reality.** sing-box uses the decoy as its Reality masquerade target (`masquerade: http://decoy:80`), so a prober that connects to the Reality port without valid credentials is handed the same innocent site, exactly as if it were the real server behind it.

By default the decoy is a small **backgammon game** page — deliberately mundane and non-political.

## Anti-fingerprinting: every server looks different

If every MoaV deployment served a byte-identical decoy, a censor could fingerprint that page once and flag every server that returns it. To prevent that, the page is **regenerated on each container start** from a template, with a randomized title, headings, theme, and content. Two MoaV servers won't serve the same bytes.

## How it's wired

- **Service:** `moav-decoy` (`nginx:alpine`), listening on port 80.
- **Template:** `web/index.html.template`, rendered to the served `index.html` at startup.
- **Randomizer:** `configs/decoy/40-randomize.sh`, run as an nginx entrypoint hook.
- **nginx config:** `configs/decoy/default.conf` — serves the site and the `/.well-known/acme-challenge/` path so certbot can issue TLS certificates.
- **Reality masquerade:** `configs/sing-box/config.json.template` points Reality's `masquerade` at `http://decoy:80`.

## Customizing it

Replace `web/index.html.template` with your own page, then restart the decoy so the randomizer re-renders it:

```bash
moav restart decoy
```

Pick something that would look ordinary for a server in your region — a small business page, a personal blog, a simple landing page. Keep it static and unremarkable. The randomizer varies the surface details on each start; the overall design is yours.

## What it is and isn't

The decoy **reduces obvious disclosure during casual or unauthenticated probing** — a scan or a curious visitor sees a website, not a proxy. It is **not** protection against a targeted investigation: an adversary who already suspects a specific server and analyzes it closely is a different threat. See the [OPSEC Guide](OPSEC.md) for where the decoy fits in the wider picture.
