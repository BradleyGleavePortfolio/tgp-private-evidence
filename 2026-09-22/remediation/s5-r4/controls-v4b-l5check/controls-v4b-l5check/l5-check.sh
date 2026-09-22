#!/usr/bin/env bash
# S5 R4 corrected L5 checker (v4, preparation only; NOT executed by the builder). Pure read of ONE derived
# run log; no processes, no lock, no DB. Replaces the over-broad wave-2 pattern (`! grep 'CMD.*jest'`,
# which also matched the pre-start guard-unit jest) with the property A-04 actually requires:
#   P1 the busy-refusal line exists exactly once;
#   P2 no `generate-only` CMD and no live-spec (`rls-g2-pg17-etq0.spec.ts`) CMD anywhere in the log;
#   P3 every CMD line precedes the refusal line (nothing is launched after the refusal);
#   P4 the exit record shows FIRST_RC=3 and STOP_RC=0 DAEMON=none (fixture started here was stopped).
# Usage: l5-check.sh <run-log>   exit 0 = property holds, 1 = violated (reasons printed), 2 = usage.
set -u
f="${1:-}"; [ -f "$f" ] || { echo "usage: $0 <run-resume log>"; exit 2; }
fail=0; say() { echo "$1 $2"; if [ "$1" = FAIL ]; then fail=1; fi; return 0; }  # v4b: always return 0 so &&/|| chains never misfire
ref_line=$(grep -nE 'session\(s\) attached .* mutating stage resume refuses' "$f" | cut -d: -f1)
[ "$(printf '%s\n' "$ref_line" | grep -c .)" = 1 ] && say PASS "P1 refusal line present once (line $ref_line)" || say FAIL "P1 refusal line count=$(printf '%s\n' "$ref_line" | grep -c .)"
grep -qE '^CMD .*generate-only' "$f" && say FAIL "P2 generate-only CMD present" || say PASS "P2a no generate-only CMD"
grep -qE '^CMD .*rls-g2-pg17-etq0\.spec\.ts' "$f" && say FAIL "P2 live-spec CMD present" || say PASS "P2b no live-spec CMD"
last_cmd=$(grep -nE '^CMD ' "$f" | tail -1 | cut -d: -f1)
if [ -n "$ref_line" ] && [ -n "$last_cmd" ] && [ "$last_cmd" -lt "$ref_line" ]; then say PASS "P3 last CMD (line $last_cmd) precedes refusal (line $ref_line)"; else say FAIL "P3 a CMD line ($last_cmd) follows or lacks the refusal ($ref_line)"; fi
ex=$(grep -E '^PROOF_EXIT=' "$f" | tail -1)
case "$ex" in *"FIRST_RC=3 "*"STOP_RC=0 "*"DAEMON=none "*) say PASS "P4 exit record FIRST_RC=3 STOP_RC=0 DAEMON=none";; *) say FAIL "P4 exit record: ${ex:-absent}";; esac
echo "L5_CHECK_RESULT=$([ $fail = 0 ] && echo HOLDS || echo VIOLATED) file=$f"
exit $fail
