#!/usr/bin/env python3
"""Rewrite mkdocs-relative doc links on stdin to absolute site URLs on stdout.

MkDocs resolves [CLI Reference](CLI.md) to the built page at render time, but
llms-full.txt is served at moav.sh/llms-full.txt, where that same link points at
moav.sh/CLI.md and 404s. An agent given the file follows it and gets nothing.

    (CLI.md)            -> (https://moav.sh/docs/CLI/)
    (DNS.md#anchor)     -> (https://moav.sh/docs/DNS/#anchor)
    (index.md)          -> (https://moav.sh/docs/)

Left alone: absolute URLs, root-relative paths, and bare #anchors (which stay
within the served file).
"""
import os
import re
import sys

BASE = os.environ.get("LLMS_BASE", "https://moav.sh/docs").rstrip("/")

# [label](target.md) or [label](target.md#frag) — but not http(s)://, / or #.
LINK = re.compile(r"\[([^\]]*)\]\((?!https?://|/|#)([^)#]+)\.md(#[^)]*)?\)")


def _repl(m):
    label, target, frag = m.group(1), m.group(2), m.group(3) or ""
    slug = "" if target == "index" else target + "/"
    return f"[{label}]({BASE}/{slug}{frag})"


def absolutize(text):
    return LINK.sub(_repl, text)


if __name__ == "__main__":
    sys.stdout.write(absolutize(sys.stdin.read()))
