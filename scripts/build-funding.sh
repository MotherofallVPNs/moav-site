#!/usr/bin/env bash
# Regenerate the donation table in docs/support.md from the MoaV repo's
# .github/FUNDING.yml, so addresses live in exactly one place.
#
# Why that file: it is already the canonical list (GitHub reads the `github:`
# and `buy_me_a_coffee:` keys for the Sponsor button), and an operator adding a
# new address there should not have to remember to update the website too.
# GitHub ignores the extra crypto keys, which is fine -- they are ours.
#
# Best-effort, exactly like the install.sh publish step: if the fetch fails, the
# committed table stays and the site never ships an empty donations section. An
# address is the one thing we must never render wrong or blank.
set -euo pipefail

SRC="${FUNDING_URL:-https://raw.githubusercontent.com/MotherofallVPNs/MoaV/main/.github/FUNDING.yml}"
PAGE="docs/support.md"
START="<!-- FUNDING:START -->"
END="<!-- FUNDING:END -->"

tmp=$(mktemp)
if ! curl -fsSL "$SRC" -o "$tmp" || [ ! -s "$tmp" ]; then
    echo "build-funding: could not fetch FUNDING.yml — keeping the committed table."
    rm -f "$tmp"; exit 0
fi

table=$(python3 - "$tmp" <<'PY'
import re, sys

# Deliberately not a YAML parser: this file is a flat key/value list, and
# depending on PyYAML here would add a build dependency for four lines.
labels = {
    "github":            ("GitHub Sponsors", "https://github.com/sponsors/{v}"),
    "buy_me_a_coffee":   ("Buy Me a Coffee", "https://buymeacoffee.com/{v}"),
    "open_collective":   ("Open Collective", "https://opencollective.com/{v}"),
    "liberapay":         ("Liberapay",       "https://liberapay.com/{v}"),
    "ko_fi":             ("Ko-fi",           "https://ko-fi.com/{v}"),
}
# Everything else is treated as a crypto ticker. Nice names where we have them.
coins = {
    "BTC": "Bitcoin", "ETH": "Ethereum", "ZEC": "Zcash", "XMR": "Monero",
    "LTC": "Litecoin", "TRON": "Tron", "SOL": "Solana", "LN": "Lightning",
    "LIGHTNING": "Lightning",
}

rows_platform, rows_crypto = [], []
for line in open(sys.argv[1], encoding="utf-8"):
    line = line.split("#", 1)[0].strip()
    m = re.match(r'^([A-Za-z_]+)\s*:\s*(.+)$', line)
    if not m:
        continue
    key, val = m.group(1), m.group(2).strip()
    val = val.strip("[]").strip().strip("'\"")
    if not val:
        continue
    if key in labels:
        name, url = labels[key]
        rows_platform.append(f"| **{name}** | [{url.format(v=val).split('//')[1]}]({url.format(v=val)}) |")
    else:
        nice = coins.get(key.upper(), key)
        label = f"{nice} ({key.upper()})" if nice.upper() != key.upper() else nice
        rows_crypto.append(f"| **{label}** | <code>{val}</code> |")

out = []
if rows_platform:
    out += ["| Platform | Link |", "|---|---|", *rows_platform, ""]
if rows_crypto:
    out += ["| Coin | Address |", "|---|---|", *rows_crypto, ""]
print("\n".join(out).rstrip())
PY
) || { echo "build-funding: could not render — keeping the committed table."; rm -f "$tmp"; exit 0; }

if [ -z "$table" ]; then
    echo "build-funding: parsed no entries — keeping the committed table."
    rm -f "$tmp"; exit 0
fi

python3 - "$PAGE" "$START" "$END" "$table" <<'PY'
import sys
page, start, end, table = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
s = open(page, encoding="utf-8").read()
if start not in s or end not in s:
    sys.exit(f"build-funding: markers missing in {page}")
a, b = s.index(start) + len(start), s.index(end)
open(page, "w", encoding="utf-8").write(s[:a] + "\n" + table + "\n" + s[b:])
print(f"build-funding: refreshed the donation table in {page}")
PY
rm -f "$tmp"
