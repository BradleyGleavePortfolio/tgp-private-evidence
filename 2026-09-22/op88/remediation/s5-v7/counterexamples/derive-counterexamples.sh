#!/usr/bin/env bash
# OP88-S5-V7 — deterministic derivation of the four T3 counterexample fixtures from the EXACT preserved wave-6 bytes.
# Read-only against the archive; writes only into this directory. Not a control; no node/jest/DB/network/lock.
# Each fixture removes ONE required teardown call, or adds ONE skipped marker, so a passing checker result is discriminating.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCH="${S5_V7_ARCHIVE:-/home/user/workspace/tgp-private-evidence/2026-09-22/remediation/s5-r4/wave-6-gate-failed/control-results/wave6-gate}"
J="$ARCH/gate-20260922T060647Z-T3.jsonl"; L="$ARCH/gate-20260922T060647Z-T3.jest.log"
PIN_J=ae38014a86d8f054e7046518c20270d021ba2d9fdac56c9d962dc19679cf7909
PIN_L=d6c3c1d7605b2750a90017aa7cabf2265170a19af725ac44eb284f4ff5c7ef10
[ "$(sha256sum "$J" | cut -c1-64)" = "$PIN_J" ] || { echo "REFUSE: T3 JSONL hash != $PIN_J"; exit 2; }
[ "$(sha256sum "$L" | cut -c1-64)" = "$PIN_L" ] || { echo "REFUSE: T3 Jest log hash != $PIN_L"; exit 2; }
# Preserved record lines (verified from the archive): 13 = ADD CONSTRAINT (failed ALTER), 14 = DROP CONSTRAINT, 15 = resetData, 16 = DELETE FROM "ScoutImport".
sed '14d' "$J" > "$HERE/N1-missing-drop.jsonl"          # removes the DROP CONSTRAINT teardown call        -> expect FAIL T3.teardown_ran (teardown.drop=MISSING)
sed '15d' "$J" > "$HERE/N2-missing-resetData.jsonl"     # removes the resetData teardown call              -> expect FAIL T3.teardown_ran (teardown.resetData=MISSING)
sed '16d' "$J" > "$HERE/N3-missing-delete.jsonl"        # removes the DELETE FROM "ScoutImport" teardown   -> expect FAIL T3.teardown_ran (teardown.delete=MISSING)
{ cat "$L"; printf '\n  console.warn\n    PG17_TEARDOWN_SKIPPED {"reason":"COUNTEREXAMPLE N4: marker appended to a copy of the preserved T3 log; the original log has none"}\n'; } > "$HERE/N4-skipped-marker.jest.log"
for f in N1-missing-drop.jsonl N2-missing-resetData.jsonl N3-missing-delete.jsonl; do [ "$(wc -l < "$HERE/$f")" = 15 ] || { echo "UNEXPECTED: $f line count $(wc -l < "$HERE/$f") != 15"; exit 1; }; done
grep -c PG17_TEARDOWN_SKIPPED "$HERE/N4-skipped-marker.jest.log" | grep -qx 1 || { echo "UNEXPECTED: N4 marker count != 1"; exit 1; }
cd "$HERE" && sha256sum N1-missing-drop.jsonl N2-missing-resetData.jsonl N3-missing-delete.jsonl N4-skipped-marker.jest.log
