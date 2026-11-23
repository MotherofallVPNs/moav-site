#!/usr/bin/env python3
"""Hide removed protocols from the docs' protocol overview tables.

Reads MoaV's data/protocols.json and drops every `gen:overview-table` row under
docs/ whose protocol has `"status": "removed"` (matched by name or anchor, so
translated tables work too). No status = active and visible. Only removes rows.

  scripts/build-protocol-table.py                     # deploy: roster from latest release
  scripts/build-protocol-table.py --protocols FILE    # use a local protocols.json
  scripts/build-protocol-table.py --check [...]       # exit 1 if a removed row is listed

Write mode is best effort: an unreadable roster leaves the tables alone, exit 0.
"""
import argparse
import glob
import json
import os
import re
import sys
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REPO = "MotherofallVPNs/MoaV"
LATEST = f"https://github.com/{REPO}/releases/latest"
RAW = "https://raw.githubusercontent.com/" + REPO + "/{ref}/data/protocols.json"
BEGIN = "<!-- BEGIN gen:overview-table -->"
END = "<!-- END gen:overview-table -->"
ROW = re.compile(r"^\|\s*\[([^\]]+)\]\(#([^)\s]+)\)")


def default_url():
    # Pin to the latest release tag (not main) so the site tracks what users can install.
    req = urllib.request.Request(LATEST, method="HEAD")
    with urllib.request.urlopen(req, timeout=20) as r:
        tag = r.geturl().rstrip("/").rsplit("/tag/", 1)[-1]
    if not tag or "/" in tag:
        raise ValueError(f"could not resolve latest release tag from {LATEST}")
    return RAW.format(ref=tag)


def load(src):
    if re.match(r"https?://", src):
        with urllib.request.urlopen(src, timeout=20) as r:
            data = json.load(r)
    else:
        with open(src) as f:
            data = json.load(f)
    protocols = data["protocols"]
    if not isinstance(protocols, list) or not protocols:
        raise ValueError("protocols.json has no protocol list")
    return protocols


def removed_keys(protocols):
    names, anchors = set(), set()
    for p in protocols:
        if p.get("status") == "removed":
            names.add(p["name"])
            if p.get("anchor"):
                anchors.add(p["anchor"])
    return names, anchors


def filter_tables(text, names, anchors):
    """Return (new_text, dropped_row_names, kept_row_count)."""
    out, dropped, kept, inside = [], [], 0, False
    for line in text.splitlines(keepends=True):
        stripped = line.strip()
        if stripped == BEGIN:
            inside = True
        elif stripped == END:
            inside = False
        elif inside:
            m = ROW.match(stripped)
            if m:
                if m.group(1) in names or m.group(2) in anchors:
                    dropped.append(m.group(1))
                    continue
                kept += 1
        out.append(line)
    return "".join(out), dropped, kept


def table_files():
    files = glob.glob(os.path.join(ROOT, "docs", "**", "*.md"), recursive=True)
    return sorted(f for f in files if BEGIN in open(f, encoding="utf-8").read())


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--protocols", help="path or URL of protocols.json (default: latest MoaV release)")
    ap.add_argument("--check", action="store_true", help="fail if any removed protocol is still listed")
    args = ap.parse_args()

    try:
        src = args.protocols or os.environ.get("PROTOCOLS_URL") or default_url()
        names, anchors = removed_keys(load(src))
    except Exception as e:  # noqa: BLE001 -- any fetch/parse failure keeps the committed tables
        print(f"build-protocol-table: could not load roster ({e}); keeping the committed tables.")
        return 1 if args.check else 0

    print(f"build-protocol-table: roster {src}; removed: {sorted(names) or 'none'}")
    status = 0
    for path in table_files():
        rel = os.path.relpath(path, ROOT)
        with open(path, encoding="utf-8") as f:
            text = f.read()
        new, dropped, kept = filter_tables(text, names, anchors)
        if not dropped:
            continue
        if args.check:
            print(f"  {rel}: still lists removed protocol(s): {', '.join(dropped)}")
            status = 1
        elif kept == 0:
            # A roster that would empty the table is wrong, not a real removal.
            print(f"  {rel}: refusing to drop every row; keeping the committed table.")
        else:
            with open(path, "w", encoding="utf-8") as f:
                f.write(new)
            print(f"  {rel}: hid {', '.join(dropped)}")
    return status


if __name__ == "__main__":
    sys.exit(main())
