#!/usr/bin/env bash
# K1 — reimplemented v5.1 MECHANISM (not v5.1 bytes; v5.1 cannot run here: its WT/LANE paths are absent and its lane dir is not this worker's write area).
# Shape copied from v5.1: `trap cleanup EXIT`; step 40 = `timeout --foreground 1500 $HARNESS` run in the FOREGROUND; cleanup runs fixture stop.
set -u; OUT=$1; STUBS=$2; S=$OUT/stamp.txt; stamp(){ echo "$*" | tee -a "$S"; }
RC_COMP=notrun
cleanup(){ trap - EXIT; bash "$STUBS/fixture.sh" stop >"$OUT/50-fixture-stop.log" 2>&1; stamp "50 fixture-stop exit=$? (v5.1 shape: stop runs whether or not step 40's child tree is alive)"; stamp "end composition=$RC_COMP"; exit 1; }
trap cleanup EXIT
stamp "K1 start pid=$$ $(date -u +%FT%TZ)"
STUB_HARNESS_MODE=sleep STUB_HARNESS_SLEEP=20 timeout --foreground 1500 bash "$STUBS/harness.sh" k1db >"$OUT/40-composition.log" 2>&1 9>&-; RC_COMP=$?
stamp "40 composition exit=$RC_COMP"
exit 0
