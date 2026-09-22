#!/usr/bin/env bash
# OP88-S5-V7 — bounded wrapper for the READ-ONLY T3 checker (NOT EXECUTED by the builder; needs a separate parent grant).
# Binds the checker to the EXACT preserved wave-6 T3 evidence by sha256, runs it once positively, then runs the four
# pre-derived counterexamples (each expected to FAIL on ONE named predicate). Any unexpected outcome stops at first failure.
# No Jest, no worktree, no node_modules, no DB, no network, no lock (the canonical lock path is not opened or probed).
# Requires: node >= 20 on PATH (present in this sandbox: v20.20.1), sha256sum, timeout. Budget: 5 x <= 20 s node calls,
# aggregate bound 120 s. Recommended outer: timeout --foreground -k 10 140.
# Invocation (when granted):
#   cd /home/user/workspace/execution/op88/s5-v7 && S5_CTL_GRANT=granted-by-parent bash controls-v7-selective/run-t3-checker.sh
# Outputs: $S5_V7_OUT (default <packet>/checker-results)/t3-checker-<UTC>.log plus one <case>.out/<case>.json per invocation.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; PKT="$(cd "$HERE/.." && pwd)"
[ "${S5_CTL_GRANT:-}" = "granted-by-parent" ] || { echo "REFUSE: S5_CTL_GRANT=granted-by-parent not set; checker is prepared, not authorized"; exit 2; }
ARCH="${S5_V7_ARCHIVE:-/home/user/workspace/tgp-private-evidence/2026-09-22/remediation/s5-r4/wave-6-gate-failed/control-results/wave6-gate}"
OUT="${S5_V7_OUT:-$PKT/checker-results}"; mkdir -p "$OUT"; TS="$(date -u +%Y%m%dT%H%M%SZ)"; LOG="$OUT/t3-checker-$TS.log"
T0=$(date +%s); AGG_BOUND=120; CALL_BUDGET=20; PASS=0; FAIL=0
log() { echo "$(date -u +%FT%TZ) $*" | tee -a "$LOG"; }
stop() { log "STOP_ON_FIRST_UNEXPECTED $*"; log "SUMMARY pass=$PASS fail=$((FAIL+1)) aggregate_elapsed=$(( $(date +%s) - T0 ))s log=$LOG"; exit 1; }
# ---- exact input pins (all refusals rc 2, before any node call)
CHECKER="$HERE/check-t3-teardown.cjs"
PIN_CHECKER=ae5842aa21c28b49620acfae53fa52bd26ad29d7ab5dc45739df9f38aca65d88
J="$ARCH/gate-20260922T060647Z-T3.jsonl";    PIN_J=ae38014a86d8f054e7046518c20270d021ba2d9fdac56c9d962dc19679cf7909
L="$ARCH/gate-20260922T060647Z-T3.jest.log"; PIN_L=d6c3c1d7605b2750a90017aa7cabf2265170a19af725ac44eb284f4ff5c7ef10
CX="$PKT/counterexamples"
declare -A PIN_CX=(
  [N1-missing-drop.jsonl]=f167885feebbdb8b09a0fb255f4d2f3f813e45c2d0a370faf2cfbdc79d74c5c5
  [N2-missing-resetData.jsonl]=a8d56891b4c978d6db8148f58053afc0c56c6b1a7d44b45f63abec508d80a8bb
  [N3-missing-delete.jsonl]=093239dffb2c82607d6aefeb83acb63f8d93ddcfbf0046773adc7989a5137c9c
  [N4-skipped-marker.jest.log]=2880d6f64a0aa71ea9f9df8a81e15eeb4e7eedec9990e8fa5bb22f963db3dd5e
)
h() { sha256sum "$1" | cut -c1-64; }
[ -r "$J" ] && [ "$(h "$J")" = "$PIN_J" ] || { log "REFUSE: preserved T3 JSONL missing or hash != $PIN_J ($J)"; exit 2; }
[ -r "$L" ] && [ "$(h "$L")" = "$PIN_L" ] || { log "REFUSE: preserved T3 Jest log missing or hash != $PIN_L ($L)"; exit 2; }
[ -r "$CHECKER" ] && [ "$(h "$CHECKER")" = "$PIN_CHECKER" ] || { log "REFUSE: checker hash != pinned $PIN_CHECKER"; exit 2; }
for f in "${!PIN_CX[@]}"; do [ -r "$CX/$f" ] && [ "$(h "$CX/$f")" = "${PIN_CX[$f]}" ] || { log "REFUSE: counterexample $f missing or hash != ${PIN_CX[$f]}"; exit 2; }; done
command -v node >/dev/null || { log "REFUSE: node not on PATH"; exit 2; }
log "T3_CHECKER_START wrapper_sha256=$(h "$0") checker_sha256=$PIN_CHECKER node=$(node --version) jsonl=$PIN_J jest_log=$PIN_L archive=$ARCH out=$OUT"
log "CANONICAL_LOCK_PATH_STAT $(stat -c 'exists mtime=%y' /home/user/workspace/execution/test-validation.lock 2>/dev/null || echo absent) (not opened, not probed)"
# ---- one bounded read-only node invocation; records rc and output; refuses to start with < 5 s aggregate left
invoke() { # <case> <jsonl> <log>  -> RC, OUTF
  local left=$((AGG_BOUND - ($(date +%s) - T0))); [ "$left" -gt 5 ] || { log "AGGREGATE_BOUND_HIT before $1"; RC=124; return; }
  local b=$CALL_BUDGET; [ "$b" -gt "$left" ] && b=$left
  OUTF="$OUT/$TS-$1.out"; timeout -k 5 "$b" node "$CHECKER" "$2" "$3" --json "$OUT/$TS-$1.json" > "$OUTF" 2>&1 < /dev/null; RC=$?
  log "$1 EXIT rc=$RC lines=$(wc -l < "$OUTF") summary=[$(grep '^SUMMARY' "$OUTF" | tail -1)]"
}
expect() { # <case> <expected-rc> <must-match-regex> <description>
  if [ "$RC" = "$2" ] && grep -Eq -- "$3" "$OUTF"; then PASS=$((PASS+1)); log "PASS $1 $4"; else FAIL=$((FAIL+1)); log "FAIL $1 $4 (rc=$RC expected $2; pattern '$3' $(grep -Eq -- "$3" "$OUTF" && echo matched || echo NOT matched))"; stop "case=$1 output=$OUTF"; fi
}
# ---- positive: exact preserved T3 evidence -> all predicates PASS, rc 0
invoke P0 "$J" "$L"
expect P0.rc0 0 '^SUMMARY pass=[0-9]+ fail=0 ' "checker rc 0 with zero FAIL on the preserved T3 JSONL/log"
for id in T3.record_parse T3.setup_partial T3.teardown_ran T3.teardown_after_failed_alter T3.log_bound T3.no_skip; do
  grep -q "^PASS $id " "$OUTF" || { FAIL=$((FAIL+1)); log "FAIL P0.$id predicate not reported PASS"; stop "case=P0 output=$OUTF"; }; PASS=$((PASS+1)); log "PASS P0.$id reported PASS"
done
grep -q '^OBSERVE v6_L80.unescaped_literal_in_raw false' "$OUTF" && grep -q '^OBSERVE v6_L80.escaped_literal_in_raw true' "$OUTF" && log "OBSERVED v6 L80 defect reproduced on raw bytes: unescaped literal absent, JSON-escaped literal present (closure justified, not a predicate)" || log "NOTE raw-bytes observation lines differ from expectation (informational)"
# ---- negatives: each removes one required teardown call or adds one skipped marker -> rc 1 with the NAMED failing predicate
invoke N1 "$CX/N1-missing-drop.jsonl" "$L";      expect N1.missing_drop      1 '^FAIL T3\.teardown_ran .*teardown\.drop=MISSING'      "removing the DROP CONSTRAINT call fails T3.teardown_ran naming teardown.drop"
invoke N2 "$CX/N2-missing-resetData.jsonl" "$L"; expect N2.missing_resetData 1 '^FAIL T3\.teardown_ran .*teardown\.resetData=MISSING' "removing the resetData call fails T3.teardown_ran naming teardown.resetData"
invoke N3 "$CX/N3-missing-delete.jsonl" "$L";    expect N3.missing_delete    1 '^FAIL T3\.teardown_ran .*teardown\.delete=MISSING'    "removing the DELETE FROM \"ScoutImport\" call fails T3.teardown_ran naming teardown.delete"
invoke N4 "$J" "$CX/N4-skipped-marker.jest.log"; expect N4.skipped_marker    1 '^FAIL T3\.no_skip .*occurrences=1'                    "adding one PG17_TEARDOWN_SKIPPED marker fails T3.no_skip"
for c in N1 N2 N3 N4; do grep -q '^PASS T3.record_parse ' "$OUT/$TS-$c.out" || log "NOTE $c: record_parse not PASS (unexpected for a line-deletion fixture)"; done
log "SUMMARY pass=$PASS fail=$FAIL aggregate_elapsed=$(( $(date +%s) - T0 ))s log=$LOG"
[ "$FAIL" = 0 ]
