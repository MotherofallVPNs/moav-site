# moav-site

The public website and documentation for **MoaV (Mother of all VPNs)**, served at
**[moav.sh](https://moav.sh)** and **[moav.sh/docs](https://moav.sh/docs)**.

This repo is intentionally separate from the server code
([MotherofallVPNs/moav](https://github.com/MotherofallVPNs/moav)) so the landing
page and docs can be edited and deployed without touching — or waiting on — a
server release.

## What's here

| Path | What |
|------|------|
| `site/` | The landing page (`index.html`, `style.css`, `script.js`), the `install.sh` one-liner (refreshed from the server's latest release at deploy — see the deploy workflow), demos, and `CNAME` (`moav.sh`). |
| `docs/` | The MkDocs (Material) documentation source — setup, DNS, clients, protocols, OPSEC, troubleshooting, etc. |
| `mkdocs.yml` | MkDocs config. `repo_url` points here (moav-site) so the docs' "edit" links land on the doc source. |
| `.github/workflows/deploy-site.yml` | Builds the docs and publishes `site/` (with `docs/` built into `site/docs/`) to GitHub Pages. |

## How it deploys

`deploy-site.yml` runs on every push to `main` (and via manual **Run workflow**):
it `mkdocs build`s into `site/docs/`, then publishes the whole `site/` tree to
GitHub Pages. The custom domain `moav.sh` is configured via `site/CNAME` + the
repo's Pages settings; Cloudflare A records point at the GitHub Pages IPs.

## Local development

```bash
# landing page — just open it
open site/index.html

# docs — live preview with MkDocs
pip install mkdocs-material
mkdocs serve            # http://127.0.0.1:8000
```

Push to `main` (or run the workflow) to publish.

## Related repos

- **[MotherofallVPNs/moav](https://github.com/MotherofallVPNs/moav)** — the server stack (this site documents it).
- **[MotherofallVPNs/moav-client](https://github.com/MotherofallVPNs/moav-client)** — the multi-protocol client + dashboard.

## License

MIT — see [LICENSE](LICENSE).
