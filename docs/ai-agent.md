# Run MoaV with an AI agent

MoaV publishes its documentation in a form coding agents read directly, so you can hand the whole thing to Claude, ChatGPT, Cursor or Copilot and have it walk the setup with you. Most operators find this the fastest route from a bare VPS to a working server.

| File | What it is | When to use it |
|---|---|---|
| [moav.sh/llms.txt](https://moav.sh/llms.txt) | Compact index — install command, `.env` location, dashboard and Grafana URLs, and links to every page | Start here. Small enough for any context window. |
| [moav.sh/llms-full.txt](https://moav.sh/llms-full.txt) | The entire documentation in one file | When the agent can take the whole corpus, or you want it to work offline from one paste. |

## Getting started

Point your agent at the index and tell it what you want:

```text
Read https://moav.sh/llms.txt and follow it to set up a MoaV server for me.

Server: <IP or hostname>, Debian 12, I have root SSH access.
Domain: <yourdomain.com> — DNS is at Cloudflare.

Walk me through it, and ask before anything destructive or anything that
needs a secret from me.
```

That is enough to get going. The agent will find the one-command install, the bootstrap flow, and `moav user add` from the index. If it can run commands on the server itself, it can do most of the work; if not, it will give you commands to paste.

Good things to ask for once the server is up:

- *"Add five users and package their bundles"* — `moav user add`, `--batch`, `--package`
- *"Why can't my friend connect on Reality?"* — `moav doctor`, `moav logs`, `moav test`
- *"Which transports are enabled, and which need a domain?"* — reads your `.env` against the protocol table
- *"Set up monitoring and show me the dashboards"* — the `monitoring` profile and Grafana

## Two things worth setting up first

Neither is required, but both remove a lot of back-and-forth.

**SSH key access.** If your agent can SSH into the server itself, it can run the install, read `moav doctor` output and fix what it finds, instead of handing you commands one at a time. Add your key with `ssh-copy-id`, confirm `ssh <server>` works without a password, and give the agent the hostname. Key-based auth is the right way to do this — see [OPSEC](OPSEC.md) before enabling anything broader.

**A Cloudflare API token**, if your DNS is there. The records MoaV needs — including the NS delegations for the DNS tunnels — are fiddly to enter by hand, and an agent with a scoped token can create them for you. Make it **DNS-edit only, for the one zone**, not a global key. `moav doctor dns` also writes the records out as an importable zone file if you would rather do it yourself: see [DNS Configuration](DNS.md#with-a-domain-the-records).

## Keep it safe

An agent operating a live server deserves the same care as a new admin.

- **Never paste secrets into a prompt or a public issue.** Not `.env`, not private keys, not a user's share link — those contain working credentials. Give the agent a path to read on the server instead.
- **Confirm before destructive commands.** `moav uninstall`, `moav user revoke`, re-bootstrapping and `docker system prune -a` all remove things that are awkward or impossible to get back.
- **Keep the admin dashboard closed.** Don't let an agent expose it, disable its auth, or widen `ADMIN_IP_WHITELIST` for convenience.
- **Don't publish server details.** Keep IPs, domains and share URIs out of anything public, including issues and pastebins used to share logs with an agent.
- **Review what it changed.** `git diff` in `/opt/moav`, and `moav doctor` afterwards.

## Contributing with an agent

The files above document *operating* a server. If you are changing MoaV itself, the repository has its own guide for agents — [AGENTS.md](https://github.com/MotherofallVPNs/MoaV/blob/main/AGENTS.md) covers the layout, the conventions that bite, and how to run the tests. [Development &amp; Testing](development.md) is the human version.
