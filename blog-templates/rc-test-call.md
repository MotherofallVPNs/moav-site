# Maintainer template — release-candidate test-call post

Copy to `docs/blog/posts/YYYY-MM-DD-help-us-test-moav-X.Y.Z.md`, fill the blanks,
add a card to `docs/blog/index.md` (newest first), and mirror to
`docs/fa/blog/posts/…` if you can. Keep the *how to test / report* in the
evergreen guide `docs/blog/how-to-test.md`; this post is only "what's new + which RC".

```markdown
---
title: Help us test MoaV X.Y.Z
description: <one-line hook: the headline changes this cycle>.
hide:
  - navigation
---

<p class="post-meta">YYYY-MM-DD · Testing · N min read · <a href="../../">The MoaV Blog</a></p>

# Help us test MoaV X.Y.Z

**MoaV X.Y.Z is in release-candidate testing.** <one-paragraph ask>.

Part of our release-candidate test-call series. The standing *how to test / report* lives in
[How to help test MoaV](../../how-to-test.md).

- **This RC:** `vX.Y.Z-rc.N` (or newer — see the [releases page](https://github.com/MotherofallVPNs/MoaV/releases))
- **Tracking:** the [X.Y.Z release pull request](https://github.com/MotherofallVPNs/MoaV/pull/NNN)
- **Full testing guide:** [How to help test MoaV](../../how-to-test.md)

!!! warning "A release candidate is not a stable release"
    Run it on a throwaway server. Stable `moav update` will not pull an RC.

## What is new in X.Y.Z
### <feature> — <why it matters, what to stress>

## Run this RC
=== "Fresh install (throwaway server)"
    curl -fsSL moav.sh/install.sh | bash -s -- -b vX.Y.Z-rc.N
=== "Upgrade an existing test box"
    moav update -b vX.Y.Z-rc.N && moav build && moav start
    # add `moav regenerate-users` only if this RC requires re-issued bundles

## What to focus on this cycle
Beyond the standard [test plan](../../how-to-test.md#the-test-plan): <1-3 RC-specific asks>.
Report back per the [guide](../../how-to-test.md#how-to-report-back).
```

Style: no em-dashes; keep the redaction note implicit via the guide; link releases + the tracking PR every time so the post stays useful after the tag moves.
