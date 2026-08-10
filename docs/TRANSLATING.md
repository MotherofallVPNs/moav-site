# Translating the docs

MoaV exists for people who are being cut off from the internet, and most of them don't read English. A translated Quick Start is worth more to them than any feature we could ship.

This page is everything you need to translate a page. No prior work on MoaV required, and you don't need to understand the software — if you can read the English page and write your language well, you can do this.

**Currently open:** Farsi (فارسی) and Russian (Русский). Want to add another language? [Open an issue](https://github.com/MotherofallVPNs/moav-site/issues) and we'll set it up.

## Pick a page

Start at the top. These are ordered by how many people they reach.

| # | Page | What it is | Farsi | Russian |
|---|---|---|---|---|
| 1 | [Quick Start](quick-start.md) | Install to first user in ten minutes | *open* | *open* |
| 2 | [Client Setup](CLIENTS.md) | How someone connects with their bundle | *open* | *open* |
| 3 | [Troubleshooting](TROUBLESHOOTING.md) | Symptom-first fixes | *open* | *open* |
| 4 | [Home](index.md) | Landing page | *open* | *open* |
| 5 | [Supported Protocols](protocols.md) | What each protocol is and when it survives | *open* | *open* |
| 6 | [Mission](mission.md) | Why the project exists | *open* | *open* |

!!! tip "Pages 1 and 2 matter most"
    Quick Start is read by the person setting up a server. Client Setup is read by the person receiving a bundle — often on a phone, often in a hurry, often on a censored connection. If you only ever translate one page, translate Client Setup.

The remaining pages (CLI reference, Setup, Monitoring, Deploy, OPSEC, Architecture, Development) stay **English-only for now**. They're operator references that change often, and a stale translation of a command reference is worse than no translation — someone will run the old flag. Readers viewing another language see the English version of these automatically.

## Claim it first

So two people don't translate the same page:

1. [Open an issue](https://github.com/MotherofallVPNs/moav-site/issues/new) titled `Translate: <page> → <language>`, e.g. `Translate: CLIENTS → Farsi`.
2. We'll mark it in the table above and it's yours.

If you go quiet for a few weeks we'll release the claim — no hard feelings, and pick it back up whenever.

## Where the file goes

Translations mirror the English tree inside a folder named for your language. **Copy the English file, then translate in place** — don't start from a blank page, because the structure and links need to survive.

```text
docs/
  quick-start.md          <- English, the source of truth. Never edit this.
  CLIENTS.md
  fa/
    quick-start.md        <- your Farsi translation
    CLIENTS.md
  ru/
    quick-start.md        <- Russian
```

Language folders: **`fa`** for Farsi, **`ru`** for Russian.

```bash
# Farsi translation of Client Setup:
mkdir -p docs/fa
cp docs/CLIENTS.md docs/fa/CLIENTS.md
# now edit docs/fa/CLIENTS.md
```

A page you haven't translated yet falls back to English automatically, so **one page is a complete, useful contribution.** Nothing is broken by the other pages not existing.

## What to translate, and what to leave alone

Translate all the prose: headings, paragraphs, list items, table cells, admonition titles, tab labels, image alt text.

Leave these **exactly as they are** — they're machine-read, and translating them turns working instructions into broken ones:

| Leave alone | Example |
|---|---|
| Everything inside a code block | `curl -fsSL moav.sh/install.sh \| bash` |
| Commands, subcommands and flags in prose | `moav user add`, `--config`, `moav doctor dns` |
| File paths and environment variable names | `/opt/moav`, `.env`, `REALITY_TARGET`, `DOMAIN` |
| Protocol and product names | Reality, Hysteria2, WireGuard, AmneziaWG, sing-box, Grafana |
| URLs, domains and ports | `moav.sh`, `9443`, `dl.google.com` |
| The admonition keyword | `!!! tip` stays `!!! tip`; its **title** gets translated |
| Link filenames | `[متن](CLIENTS.md)` — the `CLIENTS.md` part stays |

Two syntax details worth seeing side by side:

=== "Admonitions"
    The keyword after `!!!` is a type, not text. Translate only the quoted title.

    ```markdown
    !!! tip "Point your DNS before installing"
    ```

    becomes

    ```markdown
    !!! tip "قبل از نصب، DNS را تنظیم کنید"
    ```

=== "Tabs"
    Tab labels *are* prose and should be translated.

    ```markdown
    === "Web dashboard"
    === "Command line"
    ```

    becomes

    ```markdown
    === "پنل وب"
    === "خط فرمان"
    ```

### Links with a `#anchor`

This is the one thing that trips people up. An anchor is generated from the *heading text of the target page*, so if you translate a heading, every link pointing at it must change too.

- Linking **within your own translated page**: translate the anchor to match your translated heading. `#do-i-need-a-domain` → the slug of your translated heading.
- Linking to a page that is **still English** (most of them): leave the anchor exactly as-is. It still points at the English heading, which is what the reader will land on.

If you're unsure, leave the anchor alone. The build will tell you if it's wrong — see below.

## Check your work before opening a PR

Two ways, and the first one catches almost everything.

=== "Open the PR and read the preview"
    Every pull request gets a hosted preview posted as a comment within a couple of minutes. Yours will be at `…/fa/CLIENTS/`. This is the easiest route and needs nothing installed.

    The build also **fails** if a link points at a heading that doesn't exist, so a broken anchor is caught for you rather than shipping dead.

=== "Build it locally"
    ```bash
    pip install -r requirements.txt
    mkdocs serve
    ```

    Open `http://127.0.0.1:8000/fa/CLIENTS/`. It live-reloads as you save.

!!! warning "Don't review your translation in GitHub's file view"
    GitHub doesn't render tabs (`=== "…"`) or collapsible blocks (`??? note`) — they show up as literal text with their contents turned into code blocks. A correct page looks broken there, and a broken one can look fine. Always read it from a build.

Farsi renders right-to-left automatically, and the interface strings (search box, navigation) are already translated by the theme. You don't need to do anything for either.

## Opening the pull request

1. Fork the repo, and branch off `main`.
2. Add your file under `docs/fa/` or `docs/ru/`.
3. Open a PR titled `docs(fa): translate Client Setup` (or `docs(ru): …`).
4. Read the preview link when it appears, and fix anything that looks off.

We review for broken syntax and links, not for your language — we mostly can't judge that, which is exactly why we need you. If a reviewer suggests a wording change and you disagree, you're the one who speaks the language. Say so.

## A note on tone

These pages are read by people under pressure, sometimes during a shutdown, often on a phone with a bad connection. Prefer the plain, direct wording of your language over the formal register. If an English sentence is long and hedged, it's fine to make it shorter and clearer — a translation that reads naturally is better than one that mirrors the English clause by clause.

If a passage assumes context your readers won't have, add a short clarifying phrase. You know the audience better than we do.

---

Questions, or want a language added? [Open an issue](https://github.com/MotherofallVPNs/moav-site/issues), or see the other ways to help on [Support MoaV](support.md).
