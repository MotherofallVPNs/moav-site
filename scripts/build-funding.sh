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

# Footnotes keyed by ticker. The ETH one matters: the same 0x address receives
# on every EVM chain, so people don't need a new address per network. Tron is
# deliberately NOT listed here -- TRX/TRC-20 use a base58 `T...` address and
# anything sent to the 0x address is unrecoverable.
notes = {
    "ETH": "works on **all EVM chains** at this same address: Ethereum mainnet and "
           "every L2 (Arbitrum, Optimism, Base, Polygon, Gnosis, zkSync, and so on), "
           "plus **any ERC-20 token** such as USDC, USDT or DAI.",
    "TRON": "accepts TRX and **TRC-20 tokens** (USDT, USDC). Tron has its own address "
            "format, so this one is not interchangeable with the EVM address above.",
}

rows_platform, blocks_crypto = [], []
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
        # A fenced block rather than a table row: content.code.copy gives every
        # code block a copy button, which a <code> span in a table cell does not
        # get. It also stops the long addresses (the ZEC unified address is ~200
        # characters) from wrecking the table on a narrow screen.
        heading = f"**{label}**"
        note = notes.get(key.upper())
        if note:
            heading += f" — {note}"
        blocks_crypto += [heading, "", "```text", val, "```", ""]

# Each block goes inside a coloured admonition, indented to sit in it.
def boxed(kind, title, body):
    return [f'!!! {kind} "{title}"', ""] + [
        (f"    {line}" if line else "") for line in body
    ] + [""]

out = []
if rows_platform:
    out += boxed("tip", "Cards, PayPal, recurring",
                 ["| Platform | Link |", "|---|---|", *rows_platform])
if blocks_crypto:
    out += boxed("abstract", "Crypto — click an address to copy it", blocks_crypto)
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
