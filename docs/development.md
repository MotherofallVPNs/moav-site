# Development & Testing

How to run MoaV from source, how it's tested, and how to contribute a change that lands.

## Installing a specific version

The one-liner on `moav.sh` always installs the **latest stable release**. To run a development build or a specific release candidate, fetch the installer *from that ref* and tell it to clone the same one — the two must match, or you'll get an installer from one version setting up another.

=== "Latest dev"
    ```bash
    curl -fsSL https://raw.githubusercontent.com/MotherofallVPNs/MoaV/dev/install.sh | bash -s -- -b dev
    ```

=== "A specific tag"
    ```bash
    curl -fsSL https://raw.githubusercontent.com/MotherofallVPNs/MoaV/v2.0.0/install.sh | bash -s -- -b v2.0.0
    ```

=== "Already installed"
    ```bash
    moav update -b dev     # or a tag
    moav build             # images must be rebuilt when the code moves
    moav start
    ```

!!! warning "`dev` is where work in progress lands"
    It gets the fixes first and the regressions first. Run it on a test server, not on the one people depend on.

## Running from a clone

```bash
git clone https://github.com/MotherofallVPNs/MoaV.git && cd MoaV
cp .env.example .env         # set DOMAIN, ACME_EMAIL, ADMIN_PASSWORD
./moav.sh build && ./moav.sh bootstrap && ./moav.sh start all
./moav.sh doctor
```

`./moav.sh` is the same dispatcher the installed `moav` command runs — the global install is just a symlink.

!!! note "bash 4+ required"
    MoaV uses associative arrays, and macOS ships bash 3.2. The dispatcher refuses to run and tells you so rather than failing obscurely. On macOS: `brew install bash`, or work on a Linux box.

## How the code is laid out

| Path | What lives there |
|---|---|
| `moav.sh` | The CLI dispatcher — argument parsing, then straight into a `cmd_*` function |
| `lib/*.sh` | Host-side modules: `service`, `users`, `bootstrap`, `doctor`, `cert`, `migrate`, `donate`, `nettune`, `dns`, `menu`, … |
| `scripts/*-entrypoint.sh` | Container entrypoints, one per service |
| `scripts/lib/*.sh` | Shared provisioning libraries, mounted into containers as `/app/lib` |
| `configs/` | `*.template` files (tracked) rendered into `*.json` / `*.conf` (gitignored) |
| `dockerfiles/`, `exporters/`, `admin/` | Image builds, Prometheus exporters, the FastAPI dashboard |
| `tests/` | The regression suite |

The deep guide for anyone — human or AI agent — working in the repo is [`AGENTS.md`](https://github.com/MotherofallVPNs/MoaV/blob/main/AGENTS.md), and [`llms.txt`](https://moav.sh/llms.txt) is the one-fetch index.

## How testing works

Two layers, and they answer different questions.

### CI — fast, on every push

Runs on GitHub-hosted runners in a couple of minutes: `shellcheck`, a parse check on every script, `docker compose config`, Go tests for the DNS router, and **22 bash suites**.

Each suite is named after the bug class it pins rather than the file it tests — `reality-desync-test`, `wg-keygen-fallback-test`, `entrypoint-strict-test`, `state-perms-test`, `uuid-capture-test`. That naming is deliberate: the suite reads as a list of ways MoaV has broken before and can't break again.

```bash
bash tests/<name>-test.sh     # any suite, locally, no install needed
```

### End-to-end — slow, before anything ships

A self-hosted workflow builds the entire stack on a real server with a real domain, provisions a user, and **connects through every protocol**, checking the exit IP is the server. It's the merge bar for anything touching provisioning, because it's the only thing that proves a bundle actually carries traffic.

Tiers: `default` (domain mode), `full` (domain + domainless), `mega` (adds local image builds and image removal on uninstall). The server and domain come from repository secrets, so contributors don't need infrastructure of their own — the maintainers run it on the PR.

Two scripts in `tests/` are **integration harnesses**, not CI suites: `cli-smoke-test.sh` drives a live stack, and `client-test.sh` *is* what `moav test` runs. Both need a real install, and both exit `2` rather than pretending to pass when preconditions are missing.

### The rule

**Every bug fixed ships a regression test in the same PR.** Not as bureaucracy — several of those tests earned their place immediately by catching mistakes made *while* fixing something else: a render guard that could return a false PASS, a name that came out with a double dash, a probe that proved nothing because its control case also passed.

If you fix something, add the test that would have caught it. If the fix is a one-liner and the test is thirty lines, that's usually the right ratio.

## Contributing

1. **Branch off `dev`.** Never commit to `main` — it tracks releases.
2. **Open a PR into `dev`.** CI runs automatically; a maintainer triggers e2e for anything touching provisioning, protocols or permissions.
3. **Include the regression test** for whatever you fixed.
4. **Explain the failure, not just the change.** The most useful PR descriptions say what broke, how it presented, and why the fix addresses the cause rather than the symptom.

Bug reports are genuinely valuable, especially with `moav doctor` output and the relevant `moav logs`. A reproducible report is often more work than the fix.

Details on style and review: [`CONTRIBUTING.md`](https://github.com/MotherofallVPNs/MoaV/blob/main/CONTRIBUTING.md).

!!! danger "Never paste real credentials into an issue"
    Bundles, `.env` contents, share links and QR codes contain live keys. Redact server IPs and domains too if your setup is in use. See [OPSEC](OPSEC.md).

## Conventions that bite

Hard-won, and easy to trip over:

- **Strict mode everywhere.** Entrypoints run `set -eu` with `pipefail` probed in a subshell — `set -o pipefail` is fatal in `dash`, so the usual `|| true` guard doesn't save you. `((x++))` returns 1 when `x` is 0. A plain `VAR=$(cmd)` propagates the failure, so an unguarded assignment can kill a script silently.
- **Never hand a TTY to a container exec.** `docker exec -i` attaches stdin; against a terminal it blocks until the timeout. This is why some commands worked in scripts and CI but failed interactively.
- **`get_env_val` is the only `.env` accessor.** Don't hand-roll `grep | cut` — it breaks on base64 values containing `=`.
- **Generated configs are gitignored**; only `*.template` is tracked, so a `git pull` can never clobber a rendered config.
- **Secrets live in state, not `.env`.** Renders re-source state immediately before writing, so an empty `.env` value can't blank a live secret.

## Contributing to these docs

The docs are mkdocs-material in [moav-site](https://github.com/MotherofallVPNs/moav-site).

```bash
pip install mkdocs-material
mkdocs serve            # http://127.0.0.1:8000, live-reloads as you edit
mkdocs build --strict   # what CI runs — warnings are failures
```

**Always review from a build, never from the diff.** GitHub's file view doesn't render tabs (`=== "X"`) or collapsibles (`??? note"`) — they appear as literal text with their content turned into code blocks, so a correct page looks broken and a broken one can look fine.

Two ways to see a real render:

- **`mkdocs serve` locally** — instant, live-reloading, and the only option if the hosted preview is unavailable.
- **The PR preview** — every PR touching `docs/` gets a hosted URL posted as a comment (`pr-N.moav-docs-preview.pages.dev`). It's stable for the life of the PR, rebuilds on each push, and is deleted when the PR closes.

`--strict` is the gate: a link to a renamed heading, or one pointing into a tab or collapsible (neither generates an anchor), fails the build rather than shipping dead. If the hosted preview is skipped — missing secrets, Cloudflare down — the strict build still runs, so correctness is never gated on the preview being available.
