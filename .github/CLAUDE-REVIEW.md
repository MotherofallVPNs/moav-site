# Automated PR review + issue triage with Claude

Two workflows run Claude Code as an **admin-triggered, advisory** assistant on
this repo. Both are read-mostly: review posts comments only; triage applies
labels and comments. Neither edits content, opens PRs, or merges.

- `.github/workflows/claude-review.yml` — reviews a PR diff against
  [`REVIEW.md`](../REVIEW.md); posts inline comments + a grouped summary. On this
  docs repo it focuses on what `mkdocs build --strict` can't catch (accuracy,
  clarity, EN↔FA translation consistency, leaks).
- `.github/workflows/claude-issue-triage.yml` — labels an issue and posts one
  triage comment, per [`TRIAGE.md`](../TRIAGE.md).

## One-time setup

1. Add the Actions secret **`CLAUDE_CODE_OAUTH_TOKEN`** (Claude subscription:
   run `claude setup-token`, paste the token with no trailing whitespace). An
   **org**-level secret shared across the MoaV repos is simplest — make sure its
   visibility includes this repo.
2. Approve the **Claude GitHub App** on the repo (it carries the
   `pull-requests` / `issues` write the workflows need; no `github_token` is
   passed).

## How to trigger (admin-only)

- **Review:** comment `@claude review` on a PR (org members with write access
  only), or Actions → *Claude PR Review* → *Run workflow* → PR number.
- **Triage:** comment `@claude triage` on an issue, or Actions → *Claude Issue
  Triage* → *Run workflow* → issue number.

> The action validates the workflow against the **default branch**, so changes to
> these files only take effect after they're merged to `main`.

## Where to tweak

- **Enable automatic review** of every PR: uncomment the `pull_request` trigger
  in `claude-review.yml` (a diff-size guard is already in the job `if:`).
- **Enable auto-triage** of every new issue: uncomment the `issues` trigger in
  `claude-issue-triage.yml`.
- **Per-dimension agents:** `REVIEW.md` is split into self-contained dimensions
  (Accuracy · Links/build · Translation · Security) so each can later be run as
  its own reviewer job.

The check is non-blocking; Claude review is advisory and doesn't replace human
review.
