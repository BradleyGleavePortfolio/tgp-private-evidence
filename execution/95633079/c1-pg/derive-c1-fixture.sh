#!/usr/bin/env bash
# Derives c1-fixture.sh from the exact S5 donor s5-fixture.sh (sha256 3a7d57bf…) by textual
# substitution only, per resume-evidence/execution/e7d2385c/s7-c1-pg-preparation/C1_PG_PROOF_PREPARATION.md §4.
# Every change is one of: constant rebinding, S5->C1 identifier/message prefix, caller-guard re-pointing,
# `initdb -A trust` with the PASS/pwfile lines dropped. No new logic, no new subcommand.
set -euo pipefail
D=$(cd "$(dirname "$0")" && pwd)
DONOR=$D/donor/s5-fixture.sh; OUT=$D/c1-fixture.sh
[ "$(sha256sum "$DONOR" | cut -c1-64)" = 3a7d57bf951ab27e2161dc91db1d816f31d4af079ede076e7a2dfd1c44f3a721 ] || { echo "donor hash mismatch"; exit 70; }
sed \
  -e '2s|.*|# C1 disposable PostgreSQL 17.6 cluster helper (lane c1 only), derived by substitution from the S5 R4 fixture|' \
  -e '3s|.*|# s5-fixture.sh (sha256 3a7d57bf…) revision 2. LOCK-FREE BY DESIGN: it takes no flock itself and must be invoked|' \
  -e '4s|.*|# only by the frozen C1 proof binding execution/95633079/c1-pg/c1-pg-proof.sh, the single canonical lock holder.|' \
  -e '5s|S5_RUNNER_PID names a live run-proof.sh|C1_RUNNER_PID names a live c1-pg-proof.sh|' \
  -e "6s|'s5-disposable-pg17' (pinned marker required by preflight and bootstrap)|'c1-disposable-pg17' (pinned marker required by start and destroy)|" \
  -e '8s|port 54325, superuser s5_super / s5_local_synthetic (synthetic value)|port 55439, superuser user, host auth trust (loopback only; the C1 spec forbids URL passwords)|' \
  -e '9s|\$PG17_HOME/clusters/s5;|$PG17_HOME/clusters/c1-builder/pg-data;|' \
  -e '10s|Revision 2 (S5-R3-A-03)|Revision 2 (S5-R3-A-03, inherited)|' \
  -e '14s|S5_STOP_TIMEOUT|C1_STOP_TIMEOUT|' \
  -e '15s|s5-fixture.sh|c1-fixture.sh|' \
  -e '21s|.*|PORT=55439; SUPER=user; MARKER=c1-disposable-pg17|' \
  -e '22s|.*|DATA=$PG17_HOME/clusters/c1-builder/pg-data; LOG=$PG17_HOME/clusters/c1-builder/pg.log; SOCK=$PG17_HOME/run/c1|' \
  -e '23s|S5_STOP_TIMEOUT|C1_STOP_TIMEOUT|' \
  -e '25s|S5_RUNNER_PID|C1_RUNNER_PID|g' -e '25s|run-proof.sh|c1-pg-proof.sh|' \
  -e '26s|s5-fixture.sh must be invoked by run-proof.sh|c1-fixture.sh must be invoked by c1-pg-proof.sh|' \
  -e '30s|"\$PG17_HOME/clusters"|"$(dirname "$DATA")"|' \
  -e '36s|S5_RUNNER_PID|C1_RUNNER_PID|' \
  -e '44d' \
  -e '45s| -A scram-sha-256 --pwfile="\$pwfile"| -A trust|' \
  -e '46d' \
  -e '48s|# --- S5 R4 disposable fixture|# --- C1 disposable fixture|' \
  -e 's|S5_FIXTURE_|C1_FIXTURE_|g' \
  -e '66s|lacks the S5 marker|lacks the C1 marker|' \
  -e '79s|is not the marked S5 cluster|is not the marked C1 cluster|' \
  "$DONOR" > "$OUT"
chmod 644 "$OUT"
bash -n "$OUT"
echo "c1-fixture.sh sha256=$(sha256sum "$OUT" | cut -c1-64) lines=$(wc -l < "$OUT")"
