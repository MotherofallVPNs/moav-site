# Development & Testing

MoaV is developed across three repos under the [MotherofallVPNs](https://github.com/MotherofallVPNs) org:

- **[moav](https://github.com/MotherofallVPNs/moav)** — the server (the `moav` CLI + the Docker stack)
- **[moav-client](https://github.com/MotherofallVPNs/moav-client)** — the multi-protocol client + web dashboard
- **[moav-site](https://github.com/MotherofallVPNs/moav-site)** — this documentation site

Start with **[CONTRIBUTING.md](https://github.com/MotherofallVPNs/moav/blob/main/CONTRIBUTING.md)** (dev setup, branch/PR flow, coding conventions).

## Test coverage

Two layers, on each repo:

- **Per-PR CI** (GitHub-hosted, fast) — lint (`shellcheck`, `go vet`, `golangci-lint`), unit tests (`go test -race`, web-ui `vitest`), `docker compose config` validation, and a protocol-roster drift check. Runs on every pull request; never brings the stack up.
- **End-to-end** (self-hosted runner, real server) — stands the full stack up and verifies real connectivity.

### Server e2e (`moav`)

`moav test` (`client-test.sh`) drives a client tunnel per protocol against a **live** server and checks the exit IP, plus a `moav` **CLI smoke test**. It covers the full protocol matrix:

> Reality · Trojan · AnyTLS · Hysteria2 · Shadowsocks-2022 · XHTTP · CDN · WireGuard · AmneziaWG · wstunnel · dnstt · Slipstream · MasterDNS · XDNS · GooseRelay · TrustTunnel · telemt

Run it manually (**Actions → e2e → Run workflow**), on every push to `main`, and on each release. It has a `domainless` mode that skips Let's Encrypt entirely for quick iteration.

### Client e2e (`moav-client`)

Brings the client stack up against a real MoaV server bundle, connects per protocol, and asserts traffic **exits from the server's IP** (not the runner's). The **[protocol parity audit](https://github.com/MotherofallVPNs/moav-client/blob/main/docs/PROTOCOL-PARITY.md)** documents which server protocols the client connects with.

## Setting up the self-hosted runner

The e2e needs a **dedicated test VPS** (Docker + a throwaway test domain) with a self-hosted GitHub runner. Full step-by-step setup — registering the runner, the required secrets, the reclaim-workspace hook, and how to read the pass/warn/skip/fail matrix — is in the repo:

- **Server:** [`docs/devdocs/E2E-TESTING.md`](https://github.com/MotherofallVPNs/moav/blob/main/docs/devdocs/E2E-TESTING.md)
- **Client:** [`docs/devdocs/E2E-TESTING.md`](https://github.com/MotherofallVPNs/moav-client/blob/main/docs/devdocs/E2E-TESTING.md)

## Developer references

Kept in the server repo (they're contributor/agent-facing, not end-user docs):

- **[Protocol Integration Checklist](https://github.com/MotherofallVPNs/moav/blob/main/docs/devdocs/PROTOCOL-INTEGRATION-CHECKLIST.md)** — every file/step to add a new protocol end-to-end.
- **[Version Bump Checklist](https://github.com/MotherofallVPNs/moav/blob/main/docs/devdocs/VERSION-BUMP-CHECKLIST.md)** — the release checklist.
