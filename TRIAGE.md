# Issue triage rubric

Instructions for the automated issue triager (Claude Code via the GitHub
Action). This is the MoaV documentation site. Triage only — never edit content,
open a PR, or close an issue.

## What to do (one pass)

1. Read the issue. Classify it using the repo's **actual** label set (list them
   first; never invent a label). For a docs site the usual fits are
   `documentation` (typo / broken / missing / unclear content), `bug` (the site
   itself is broken — build, layout, dead link at runtime), `enhancement` (new
   page or section), a translation request/fix (use a `translation` label if the
   repo has one, else `documentation`), `question`, or `duplicate`.
2. Apply the fitting label(s) — 1–3 at most. Add `good first issue` for small,
   well-scoped doc fixes. Leave `invalid` / `wontfix` for a human.
3. Post **one concise triage comment**: restate the ask in a line, name the
   likely area, and say what's still needed (which page/URL, which language, a
   repro for a build/layout bug).
4. If it's a duplicate, link the original. If the answer is already in the docs,
   link the page.

## Areas (name these in the comment, not as labels)

- **English docs** — `docs/*.md`
- **Translated docs** — `docs/<locale>/*.md` (`fa`, and Russian/Chinese as they land); translation requests/fixes
- **Landing page** — `site/`
- **Build / config** — `mkdocs.yml`, strict-build failures

## Security & privacy

- If an issue contains a secret, a real server IP/domain, or a full share-URI,
  **flag it and ask the reporter to redact** — do not echo the value back, and
  suggest maintainers scrub the issue.

## Tone & limits

- Helpful and short; at most 2–3 clarifying questions.
- Don't re-triage an issue you've already commented on unless asked again.
- Advisory: a maintainer confirms the disposition.
