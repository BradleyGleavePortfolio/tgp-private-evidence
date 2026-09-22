#!/usr/bin/env bash
# S5 R4 L5 checker v4b bounded driver (preparation only; NOT executed). Pure read. Runs l5-check.sh over the
# fixed counterexample set with an EXPECTED result per file, captures raw rc + printed predicates, stops on the
# FIRST mismatch (exit 1), and enforces an explicit aggregate bound: 10 s work + 2 s stop (exit 124 on bound).
set -u
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; OUT="${1:-$D/../control-results/wave-l5check}"; mkdir -p "$OUT"
START=$(date +%s); BOUND=10
expected() { case "$1" in 00-*|P2-*) echo 0;; N*) echo 1;; *) echo "?";; esac; }
for f in "$D"/counterexamples/00-wave2-preserved-raw.log "$D"/counterexamples/P2-*.log "$D"/counterexamples/N*.log; do
  b=$(basename "$f"); exp=$(expected "$b"); left=$((BOUND - ($(date +%s) - START))); [ "$left" -ge 1 ] || { echo "AGGREGATE_BOUND_HIT before $b"; exit 124; }
  timeout -k 2 "$left" bash "$D/l5-check.sh" "$f" > "$OUT/$b.out" 2>&1; rc=$?
  echo "FILE=$b RC=$rc EXPECTED=$exp $(grep -o 'L5_CHECK_RESULT=[A-Z]*' "$OUT/$b.out")"
  [ "$rc" = "$exp" ] || { echo "FIRST_MISMATCH file=$b rc=$rc expected=$exp; stopping (raw in $OUT/$b.out)"; exit 1; }
done
echo "L5_CHECKER_CONTROL_OK files=7 elapsed=$(( $(date +%s) - START ))s"
