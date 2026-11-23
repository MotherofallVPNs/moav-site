#!/usr/bin/env bash
# scripts/build-protocol-table.py must hide `status: "removed"` rows and keep the rest.
# Runs on a scratch copy of docs/ so the real tables are never touched.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/scripts"
cp "$ROOT/scripts/build-protocol-table.py" "$work/scripts/"
cp -R "$ROOT/docs" "$work/docs"

# dnstt removed by name, MasterDNS removed by anchor only, AmneziaWG has no status
# (active, even though its blurb says deprecated) and must stay.
cat > "$work/roster.json" <<'JSON'
{"protocols": [
  {"name": "dnstt", "anchor": "dnstt", "status": "removed"},
  {"name": "MasterDNS (old name)", "anchor": "masterdns", "status": "removed"},
  {"name": "AmneziaWG", "anchor": "amneziawg", "blurb": "deprecated"}
]}
JSON

run() { python3 "$work/scripts/build-protocol-table.py" --protocols "$work/roster.json" "$@"; }
fail() { echo "FAIL: $*"; exit 1; }

if run --check >/dev/null; then fail "--check passed while removed rows were listed"; fi
run >/dev/null
run --check >/dev/null || fail "--check still failing after filtering"

for f in "$work/docs/protocols.md" "$work/docs/fa/protocols.md"; do
    block=$(sed -n '/BEGIN gen:overview-table/,/END gen:overview-table/p' "$f")
    grep -q '](#dnstt)' <<<"$block" && fail "$f: dnstt row still in table"
    grep -q '](#masterdns)' <<<"$block" && fail "$f: masterdns row still in table"
    grep -q '](#amneziawg)' <<<"$block" || fail "$f: active AmneziaWG row was dropped"
    # Rows outside the table (detail sections) are not touched.
    grep -q '^### dnstt' "$f" || fail "$f: detail section was modified"
done

# An unreadable roster is a no-op in write mode, never a failed deploy.
python3 "$work/scripts/build-protocol-table.py" --protocols "$work/missing.json" >/dev/null \
    || fail "write mode should exit 0 when the roster is unavailable"

echo "protocol-table-test: OK"
