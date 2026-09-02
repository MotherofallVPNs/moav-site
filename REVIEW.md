# Review rubric

Instructions for the automated PR reviewer (Claude Code `code-review` plugin).
This is the MoaV documentation site: MkDocs (Material), English under `docs/*.md`
and translations in per-locale folders under `docs/` (`docs/fa/`, with Russian
and Chinese landing), plus the landing page in `site/`. Untranslated pages fall
back to English. CI already runs `mkdocs build --strict`, so **broken links and
missing anchors already fail the build** — spend review effort on what the strict
build cannot check.

## Output

- Post findings as **inline comments** on the exact `file:line`, and one
  **grouped summary** organized by the dimensions below.
- Lead the summary with a one-line verdict and counts per dimension.
- Cap **Nits at 5**; if there are more, say "plus N similar".

## Severity

- **Important** — wrong or misleading docs (a command, flag, port, or path that
  does not match how MoaV actually works), a real secret / server IP / domain /
  share-URI in an example, or a translation that changes the meaning.
- **Nit** — wording, tone, small structure, house-style.
- **Pre-existing** — a real problem the PR didn't introduce; report separately.

## Verification bar

Cite the `file:line`. For a "this command/flag is wrong" claim, prefer pointing
at the source repos' behaviour when known, and phrase uncertainty as a question.

---

# Dimensions

Self-contained on purpose, so each can later become its own review agent.

## 1. Accuracy & clarity

- Commands, flags, ports, file paths, and env vars match how MoaV actually
  works; no invented options. Steps are in a runnable order.
- Prose is clear and unambiguous for a non-expert operator; no dangling "TODO"
  or placeholder left in.
- Screenshots/asset references resolve.

## 2. Links, anchors & build

Strict build catches most of this, but two things bite repeatedly:

- **Cross-language anchors.** A link like `protocols.md#some-anchor` is resolved
  by the i18n plugin against the English page AND every translated copy
  (`docs/fa/`, `docs/ru/`, `docs/zh/`, …). If the target heading (hence its slug)
  exists in one language but not another, the strict build fails — flag any new
  cross-doc anchor link whose target may be missing in a translated copy (this
  exact case broke a past PR).
- New pages are wired into the nav (`mkdocs.yml`) if they should appear.

## 3. Translation consistency (English <-> all locales)

Locales live in folders under `docs/` (`fa`, and Russian/Chinese as they land);
untranslated pages fall back to English, so partial translation is fine — flag
gaps and drift, not incompleteness.

- A meaningful change to an English page should be mirrored in each translated
  counterpart (`docs/<locale>/…`), or the PR should note the translation is
  deferred.
- Translated pages keep the same section structure and English-slug anchors the
  English pages use, so shared links resolve in every locale.
- Flag translated text that has drifted from the current English meaning, and
  obvious machine-translation artifacts. Don't grade fluency line-by-line —
  surface divergences and gaps, not stylistic nitpicks.

## 4. Security & privacy

- No real secrets, server IPs, domains, or full share-URIs in examples — use
  placeholders (`example.com`, `203.0.113.x`, `<your-domain>`).
- Docs don't tell operators to do something that leaks their identity or adds
  fingerprint surface without flagging the trade-off.

---

## Style

Match the existing docs' voice: plain, operator-facing, no marketing fluff, and
no em dashes (house preference — use commas/parentheses). Style points are Nits.

## Skip

- Generated site output (`site/`, `_preview/`), build artifacts.
- Anything `mkdocs build --strict` already enforces — don't re-litigate a link
  the build would have failed on.
