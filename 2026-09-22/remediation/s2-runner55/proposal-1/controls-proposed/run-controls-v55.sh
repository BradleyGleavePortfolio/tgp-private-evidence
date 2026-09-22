#!/usr/bin/env bash
# PROPOSED, NOT EXECUTED (S2-RUNNER-V5.5-PREP, 2026-09-22). Successor of s2-runner54/controls-proposed/run-controls-v54.sh (6638ec06…) — v55 delta:
#   E1 (R54-A-01) K1 runs inside an EXCLUSIVE, self-published enclosure group created by this invocation (setsid + id file) — the predecessor's
#      internal foreground mechanism is unchanged; the driver adopts ONLY that group and never a PGID read from an arbitrary child log
#      (the 'stub harness … pgid=' record source is removed). Own/parent groups are never targets.
#   E2 (R54-A-02) K10 records the hanging stop child's published pid and requires it dead + the runner's owned-stop census line; sleep stays 60 s.
#   E3 (R54-A §4) one aggregate deadline: every runner/child-driver bound is clipped to remaining − RESERVE − kill grace; nested child drivers run
#      in their own self-published enclosure under a clipped timeout; a driver-level watchdog TERMs the current enclosure at the deadline;
#      finish() rejects exit 0 when recorded-owned survivors remain, the lane lock is not FREE, or new pattern matches (not pre-snapshot) exist → 4.
#   E4 (R54B-02) g<pgid> records are dropped once verified empty (history kept in owned-history.txt as a receipt, not a kill registry).
#   E5 (R54B-03) totals are read from RECEIPT.txt; receipt_status=ok is a required expectation on every runner control.
#   E6 (R54-A-04) K2/K7/K8 expect CHECKPOINT_DISABLE=1 echoed by the stub harness/discriminator/fixture-stop (inheritance through the invocation graph).
# Original v54 header follows.
# PROPOSED, NOT EXECUTED (S2-R54-EXECUTION-SAFETY, 2026-09-22). Successor of s2-setup-prep/controls-proposed/run-runner-controls-v531.sh
# (759d958f…) closing A03/A04:
#   A03  refusal before ownership (pre-existing pattern match) → exit 2 with NO signal to anything; cleanup signals ONLY pids this invocation
#        recorded (runner-stamped owned groups, 'spawned/escapee pid=' lines and QUARANTINE.txt of runs it launched, K1's harness group) and never a
#        pid seen in the pre-snapshot; process-name patterns are used for DETECTION/REPORTING only.
#   A04  aggregate exit: 0 only if every control of the set ran and none struck; 1 = expectation miss (stop, later controls NOT RUN);
#        2 = precondition abort; 3 = budget exhaustion (a control is started only if its declared maximum + RESERVE fits the remaining budget;
#        every runner invocation is wrapped in an outer `timeout` clipped to the remaining budget). Actual exits are always printed.
# Sets (CTL_SET): k    = K1..K6 regression on v5.4 bytes (declared max 8+15+12+25+15+10 = 85 → runs in ≤60 s historically 30.85 s; budget checked live)
#                 new1 = K7pre/K7 leader-exits-first, K8pre/K8 inner step timeout, K9 unnamed setsid escape (documented boundary)
#                 new2 = K10 hanging fixture stop (deadline-clipped, class 71)
#                 neg  = driver self-negatives N1 decoy-survives-refusal, N2 assertion-miss→exit 1, N3 budget-exhaustion→exit 3
# No DB, no network, no canonical lock (lane-private $STUBS/test-validation.lock), no product/source writes. 'pre' controls run the FROZEN
# v5.3.1 bytes read-only to reproduce the finding; their outputs land under s2-setup-prep/runner-selftest-r531/ (additive; the 37 frozen files
# are untouched). One invocation = one set. CTL_BUDGET default 60.
set -u
R55=/home/user/workspace/execution/s2-runner55; RUNNER=$R55/run-composition-r55-v5.5-when-granted.sh; STUBS=$R55/controls-proposed/stubs; R54=$R55
PRE_RUNNER=/home/user/workspace/execution/s2-setup-prep/run-composition-r53-v5.3.1-when-granted.sh
SET=${CTL_SET:-k}; BUDGET=${CTL_BUDGET:-60}; RESERVE=8; INJECT_FAIL=${CTL_INJECT_FAIL:-0}
CTL=$R55/controls-proposed/results/$SET-$(date -u +%Y%m%dT%H%M%SZ); mkdir -p "$CTL"; R=$CTL/CONTROLS_RESULT.txt; OWNED=$CTL/owned-pids.txt; : > "$OWNED"; HIST=$CTL/owned-history.txt; : > "$HIST"
MY_PGID=$(ps -o pgid= -p $$ | tr -d ' '); PARENT_PGID=$(ps -o pgid= -p $PPID 2>/dev/null | tr -d ' '); ENCL=$CTL/.encl; mkdir -p "$ENCL"
T0=$(date +%s.%N); STRIKE=0; RUN=0; PLANNED=0; WATCHDOG=
say(){ echo "$*" | tee -a "$R"; }
now(){ awk -v a="$T0" -v b="$(date +%s.%N)" 'BEGIN{printf "%.2f", b-a}'; }
left(){ awk -v a="$T0" -v b="$(date +%s.%N)" -v B="$BUDGET" 'BEGIN{printf "%d", B-(b-a)}'; }
PAT="^s2r53-stub-escapee|^timeout --foreground [0-9]+ bash $STUBS/harness.sh|^bash $STUBS/harness.sh|^bash $STUBS/fixture.sh|^bash $RUNNER|^bash $PRE_RUNNER"
detect(){ pgrep -f "$PAT" 2>/dev/null | awk -v me=$$ '$1!=me'; }     # detection only — never a kill list
# ---- ownership records (A03)
record(){ local p; for p in "$@"; do [ -n "$p" ] && { echo "$p" >> "$OWNED"; echo "$(date -u +%T) $p" >> "$HIST"; }; done; }   # E4: HIST is a receipt, never a kill source
record_from_run(){ # record_from_run <outdir> : owned groups stamped by the runner, spawned/escapee pids from step logs, QUARANTINE pids
  local O=$1 g; [ -d "$O" ] || return 0
  for g in $(grep -o 'owned_groups=\[[0-9 ]*\]' "$O/stamp.txt" 2>/dev/null | tr -dc '0-9 \n'); do echo "g$g" >> "$OWNED"; done
  record $(grep -ohE '(spawned|escapee) pid=[0-9]+' "$O"/*.log 2>/dev/null | grep -oE '[0-9]+$')
  record $(grep -oE 'survivor: +[0-9]+' "$O/QUARANTINE.txt" 2>/dev/null | grep -oE '[0-9]+$')
  # E1: NO adoption of a pgid read from a child log (v54 adopted the harness's inherited group here)
}
prune_groups(){ # E4: drop g<pgid> records whose census is empty (history retained in $HIST)
  local x keep=; while read -r x; do case $x in g*) pgrep -g "${x#g}" >/dev/null 2>&1 && keep="$keep$x\n";; '') ;; *) keep="$keep$x\n";; esac; done < "$OWNED"; printf "%b" "$keep" > "$OWNED"; }
enclose(){ # enclose <name> <bound> <grace> <cmd...> : run cmd in an exclusive self-published group (E1/E3); sets ENC_PGID, RC; halts the enclosure if the bound fires
  local name=$1 bound=$2 grace=$3; shift 3; local idf="$ENCL/$name.pgid" pid; rm -f "$idf"
  setsid bash -c 'echo $$ > "$1"; shift; exec timeout --foreground -k "$@"' _ "$idf" "$grace" "$bound" "$@" & pid=$!; ENC_PGID=
  for ((i=0;i<40;i++)); do [ -s "$idf" ] && { ENC_PGID=$(tr -dc '0-9' < "$idf"); break; }; kill -0 "$pid" 2>/dev/null || { sleep 0.05; [ -s "$idf" ] && ENC_PGID=$(tr -dc '0-9' < "$idf"); break; }; sleep 0.05; done
  if [ "$ENC_PGID" = "$pid" ] && [ "$ENC_PGID" != "$MY_PGID" ] && [ "$ENC_PGID" != "$PARENT_PGID" ]; then record "g$ENC_PGID"; else say "  ENCLOSURE IDENTITY NOT CONFIRMED for $name (pid=$pid published='${ENC_PGID:-none}') — pid-only handling, no group adopted"; ENC_PGID=; fi
  wait "$pid"; RC=$?
  if [ -n "$ENC_PGID" ] && pgrep -g "$ENC_PGID" >/dev/null 2>&1; then say "  enclosure $name (group $ENC_PGID) still has members after exit rc=$RC: [$(pgrep -g "$ENC_PGID" -a | tr '\n' ';')] → recorded as owned survivors"; fi
}
owned_live(){ # expand records: plain pids (alive) + live members of recorded groups; exclude pre-snapshot pids, self, own/parent groups (E1/E4)
  local x; { while read -r x; do case $x in g*) { [ "${x#g}" = "$MY_PGID" ] || [ "${x#g}" = "$PARENT_PGID" ]; } || pgrep -g "${x#g}" 2>/dev/null;; '') ;; *) kill -0 "$x" 2>/dev/null && echo "$x";; esac; done < "$OWNED"; } | sort -un | grep -vxF -f "$CTL/pre-snapshot.txt" | awk -v me=$$ -v pp=$PPID '$1!=me && $1!=pp'
}
owned_cleanup(){ local pids; pids=$(owned_live | tr '\n' ' ')
  if [ -n "$pids" ]; then say "  owned cleanup: TERM recorded pids [$pids] $(ps -o pid=,pgid=,cmd= -p $(echo $pids | tr ' ' ',') 2>/dev/null | tr '\n' ';')"; kill -TERM $pids 2>/dev/null; sleep 0.5
    pids=$(owned_live | tr '\n' ' '); [ -n "$pids" ] && { say "  owned cleanup: KILL recorded pids [$pids]"; kill -KILL $pids 2>/dev/null; sleep 0.3; }; fi
  say "  recorded-owned alive after cleanup: [$(owned_live | tr '\n' ' ')]; pattern-detected (report only): [$(detect | tr '\n' ' ')]"; prune_groups; }
finish(){ # finish <code> — E3: assertions passing is not a handoff; survivors / non-free lane lock / new pattern matches force 4
  local code=$1; owned_cleanup; [ -n "$WATCHDOG" ] && { kill "$WATCHDOG" 2>/dev/null; wait "$WATCHDOG" 2>/dev/null; }
  [ "$code" = 0 ] && { [ "$RUN" -lt "$PLANNED" ] || [ "$STRIKE" = 1 ]; } && code=1
  local surv newpat lockst; surv=$(owned_live | tr '\n' ' '); newpat=$(detect | grep -vxF -f "$CTL/pre-snapshot.txt" | tr '\n' ' '); lockst=$(flock -n "$STUBS/test-validation.lock" true && echo FREE || echo HELD)
  if [ -n "$surv" ] || [ -n "$newpat" ] || [ "$lockst" != FREE ]; then say "HANDOFF FAILURE: owned survivors [$surv] new pattern matches [$newpat] lane lock $lockst → aggregate 4 (no further set may start)"; code=4; fi
  [ "$(left)" -lt 0 ] && { say "AGGREGATE DEADLINE EXCEEDED at publication ($(now)s > ${BUDGET}s)"; [ "$code" = 0 ] && code=3; }
  say "SET=$SET controls_run=$RUN/$PLANNED strike=$STRIKE wall=$(now)s of ${BUDGET}s (reserve ${RESERVE}s) aggregate_exit=$code; lane lock: $lockst; canonical lock file: $([ -e /home/user/workspace/execution/test-validation.lock ] && echo exists || echo absent) (never opened)"
  ( cd "$CTL" && find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS ); exit "$code"; }
abort(){ [ -n "$WATCHDOG" ] && { kill "$WATCHDOG" 2>/dev/null; wait "$WATCHDOG" 2>/dev/null; }; say "ABORT (precondition, no ownership acquired, NO signals sent to anything but this driver's own watchdog sleeper): $*"; say "SET=$SET controls_run=0/$PLANNED aggregate_exit=2 wall=$(now)s"; ( cd "$CTL" && find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS ); exit 2; }
need(){ # need <name> <declared_max_s> : budget gate BEFORE starting a control (A04); declared max INCLUDES kill grace and post-run bookkeeping
  [ "$STRIKE" = 1 ] && { say "ONE-STRIKE STOP before $1: previous control missed an expectation — remaining controls NOT RUN"; finish 1; }
  local l; l=$(left); if [ $((l-RESERVE)) -lt "$2" ]; then say "BUDGET EXHAUSTED before $1: remaining ${l}s - reserve ${RESERVE}s < declared max $2 s — $1 and later controls NOT RUN"; finish 3; fi
  say; say "== $1 (declared max $2 s, remaining ${l}s) [t=$(now)s]"; RUN=$((RUN+1)); }
clip(){ local l=$(( $(left) - RESERVE - ${KA:-5} )); [ "$l" -lt 1 ] && l=1; [ "$l" -lt "$1" ] && echo "$l" || echo "$1"; }   # E3: TERM bound + kill grace fit the remaining budget
expect(){ if grep -qE "$2" "$1" 2>/dev/null; then say "  PASS: $3"; else say "  FAIL: $3 (expected /$2/ in $1)"; STRIKE=1; fi; }
alive(){ kill -0 "$1" 2>/dev/null; }
new_out(){ # new_out <parent_dir> <before_listing> : the single directory created by the run we just launched, or empty
  comm -13 <(echo "$2") <(ls -1d "$1"/*/ 2>/dev/null) | tail -1; }
run_runner(){ # run_runner <runner> <outdir_parent> <outer_bound> <envs...> : launches under a clipped outer timeout, records ownership; sets RC and O
  local runner=$1 parent=$2 bound=$3; shift 3; local before; before=$(ls -1d "$parent"/*/ 2>/dev/null)
  enclose "$CUR" "$(clip "$bound")" "${KA:-5}" env "$@" bash "$runner" >"$CTL/$CUR.driver.log" 2>&1   # E1/E3: exclusive enclosure; KA = kill-after grace
  O=$(new_out "$parent" "$before"); record_from_run "$O"; say "  $CUR runner exit=$RC out=${O:-NONE} enclosure_group=${ENC_PGID:-unconfirmed}"; [ -n "$O" ] || { say "  FAIL: no new output dir"; STRIKE=1; O=/nonexistent; }
  [ -n "$O" ] && [ -d "$O" ] && expect "$O/RECEIPT.txt" '^receipt_status=ok$' "$CUR receipt ok (frozen manifest, post-hash receipt)"; }
OUT54=$R55/runner-selftest-r55; OUT531=/home/user/workspace/execution/s2-setup-prep/runner-selftest-r531

say "S2-R54 controls set=$SET start $(date -u +%FT%TZ) budget=${BUDGET}s runner_sha256=$(sha256sum "$RUNNER" | cut -c1-64) pre_runner_sha256=$(sha256sum "$PRE_RUNNER" | cut -c1-64) stubs=$(cd "$STUBS" && sha256sum *.sh | cut -c1-16 | tr '\n' ' ')"
detect > "$CTL/pre-snapshot.txt"
say "pre-snapshot pattern matches (never signalled): [$(tr '\n' ' ' < "$CTL/pre-snapshot.txt")]"
[ -s "$CTL/pre-snapshot.txt" ] && abort "pre-existing pattern matches [$(tr '\n' ' ' < "$CTL/pre-snapshot.txt")] — not ours; refusing without cleanup"
[ -f "$RUNNER" ] && [ -f "$PRE_RUNNER" ] && [ -d "$STUBS" ] || abort "runner/pre-runner/stubs missing"
# E3: aggregate watchdog — at BUDGET-RESERVE/2 it TERMs the current enclosure group (recorded, exclusive) so cleanup/publication fit the budget
( sleep $(( BUDGET - RESERVE/2 )); g=$(f=$(ls -t "$ENCL"/*.pgid 2>/dev/null | head -1); [ -n "$f" ] && tr -dc '0-9' < "$f"); [ -n "$g" ] && [ "$g" != "$MY_PGID" ] && pgrep -g "$g" >/dev/null 2>&1 && kill -TERM -- "-$g" 2>/dev/null; echo "WATCHDOG fired at $(date -u +%FT%TZ) group=${g:-none}" >> "$R" ) & WATCHDOG=$!
case $SET in k) PLANNED=6;; new1) PLANNED=5;; new2) PLANNED=1;; neg) PLANNED=3;; *) abort "unknown CTL_SET=$SET";; esac
[ "$INJECT_FAIL" = 1 ] && say "NEGATIVE MODE: an impossible expectation is injected after the first control (expected aggregate exit 1)"

if [ "$SET" = k ]; then
  # ---------- K1 predecessor MECHANISM counterexample (v5.1 shape; unchanged from s2-runner53)
  need K1-predecessor-mechanism 8; K1=$CTL/k1; mkdir -p "$K1"
  enclose k1 2 5 bash "$R55/controls-proposed/k1-predecessor-mechanism.sh" "$K1" "$STUBS" >"$K1/driver.log" 2>&1; rc=$RC; record_from_run "$K1"; say "  K1 enclosure group=${ENC_PGID:-unconfirmed} (exclusive; predecessor internals unchanged)"
  say "  K1 outer exit=$rc; stamp:"; sed 's/^/    /' "$K1/stamp.txt" | tee -a "$R"; surv=$(owned_live | tr '\n' ' ')
  say "  K1 recorded-owned processes alive after runner exit: [$surv]"
  [ "$rc" = 124 ] && say "  PASS: outer timeout fired (124)" || { say "  FAIL: outer exit $rc"; STRIKE=1; }
  [ -f "$K1/50-fixture-stop.log" ] && say "  PASS(counterexample): fixture stop ran under a live step-40 child" || { say "  FAIL: fixture stop log missing"; STRIKE=1; }
  [ -n "$surv" ] && say "  PASS(counterexample): step-40 child tree survived the runner" || { say "  FAIL: no survivor observed"; STRIKE=1; }
  [ "$INJECT_FAIL" = 1 ] && expect "$K1/stamp.txt" '^THIS-LINE-CANNOT-EXIST' "N2 injected impossible expectation"
  owned_cleanup
  # ---------- K2 stub success
  need K2-stub-success 15; CUR=k2; run_runner "$RUNNER" "$OUT54" 15 S2_RUNNER_STUBS=$STUBS
  expect "$O/exit-codes.txt" '^final=0 first_exit=0 cleanup_exit=0 signal=none reap=ok' "K2 result registers"
  expect "$O/exit-codes.txt" 'deadline_exceeded=no guard_spec=0 refusal_hosted=64 refusal_noconfirm=64 fixture=0 composition=0 s1_r4_discriminator=0 fixture_stop=0 survivors=none' "K2 all steps reached, refusals 64/64, stop 0, deadline kept"
  expect "$O/stamp.txt" 'STUB MODE — NOT EVIDENCE' "K2 stub banner"
  expect "$O/stamp.txt" 'head=d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c tree=c0ab87d4dc584b2a7ccad53db16fa551b93fe359 dirty_lines=0' "K2 real head/tree/clean check"
  expect "$O/stamp.txt" 'REAP ok: no owned-work process survives \(recorded groups \[[0-9 ]+\]' "K2 owned groups retained and empty before fixture stop (O1)"
  expect "$O/20-refusal-hosted.log" 'S1-GUARD REFUSED URL_HOST' "K2 real harness offline refusal (hosted URL)"
  expect "$O/21-refusal-noconfirm.log" 'S1-GUARD REFUSED CONFIRM' "K2 real harness offline refusal (no confirm)"
  expect "$O/30-fixture-init.log" "fd9=$STUBS/test-validation.lock" "K2 fixture init inherited fd 9 (private lock)"
  expect "$O/40-composition.log" 'fd9=closed' "K2 harness saw fd 9 closed"
  expect "$O/40-composition.log" 'CHECKPOINT_DISABLE=1' "K2 harness inherited CHECKPOINT_DISABLE=1 (E6)"
  expect "$O/s1-r4/s1-r4-discriminator.log" 'CHECKPOINT_DISABLE=1' "K2 discriminator inherited CHECKPOINT_DISABLE=1 (E6)"
  expect "$O/50-fixture-stop.log" 'CHECKPOINT_DISABLE=1' "K2 cleanup client inherited CHECKPOINT_DISABLE=1 (E6)"
  expect "$O/stamp.txt" '^50-fixture-stop: group [0-9]+ census empty after exit' "K2 owned stop client fully reaped (P3)"
  [ "$RC" = 0 ] || { say "  FAIL: exit $RC"; STRIKE=1; }; owned_cleanup
  # ---------- K3 TERM during step 40
  need K3-term-during-step40 12; CUR=k3; KA=8 run_runner "$RUNNER" "$OUT54" 3 STUB_HARNESS_MODE=sleep STUB_HARNESS_SLEEP=30 S2_RUNNER_STUBS=$STUBS
  surv=$(owned_live | tr '\n' ' '); say "  K3 recorded-owned alive after runner exit: [$surv]"
  expect "$O/exit-codes.txt" '^final=143 first_exit=143 cleanup_exit=0 signal=TERM reap=ok' "K3 signal exit recorded as first exit; cleanup class 0"
  expect "$O/exit-codes.txt" 'composition=interrupted\(TERM\) s1_r4_discriminator=notrun fixture_stop=0 survivors=none' "K3 step interrupted, stop 0, no survivors"
  [ -z "$surv" ] && say "  PASS: no step-40 child survives" || { say "  FAIL: survivors [$surv]"; STRIKE=1; }
  o1=$(grep -n '^SIGNAL SIGTERM' "$O/stamp.txt" | cut -d: -f1 | head -1); o2=$(grep -n '^REAP ok' "$O/stamp.txt" | cut -d: -f1 | head -1); o3=$(grep -n '^50 fixture-stop' "$O/stamp.txt" | cut -d: -f1 | head -1)
  [ -n "$o1" ] && [ -n "$o2" ] && [ -n "$o3" ] && [ "$o1" -lt "$o2" ] && [ "$o2" -lt "$o3" ] && say "  PASS: ordering SIGNAL($o1) < REAP ok($o2) < fixture stop($o3)" || { say "  FAIL: ordering signal=$o1 reap=$o2 stop=$o3"; STRIKE=1; }
  expect "$O/stamp.txt" 'LOCK: held by runner through cleanup \(HELD\)' "K3 lock held through cleanup"
  say "  K3 timing: $(grep -o 'cleanup_seconds=[0-9.]*' "$O/exit-codes.txt") $(grep -o 'cleanup_seconds_total=[0-9.]*' "$O/RECEIPT.txt")"
  [ "$RC" = 124 ] || { say "  FAIL: outer exit $RC (expected 124)"; STRIKE=1; }; owned_cleanup
  # ---------- K4 escapee → quarantine 72
  need K4-escapee-quarantine 25; CUR=k4; KA=20 run_runner "$RUNNER" "$OUT54" 3 STUB_HARNESS_MODE=escape STUB_HARNESS_SLEEP=40 S2_RUNNER_STUBS=$STUBS
  say "  K4 recorded-owned alive after runner exit (expected: the quarantined escapee): [$(owned_live | tr '\n' ' ')]"
  expect "$O/exit-codes.txt" '^final=143 first_exit=143 cleanup_exit=72 signal=TERM reap=FAILED' "K4 quarantine class 72 separate from first exit 143"
  expect "$O/exit-codes.txt" 'fixture_stop=REFUSED survivors=present' "K4 fixture stop REFUSED, survivors present"
  expect "$O/QUARANTINE.txt" 's2r53-stub-escapee' "K4 QUARANTINE.txt lists the escapee"
  expect "$O/stamp.txt" 'LOCK: held by runner through cleanup \(HELD\); NOT safely handed off' "K4 lock not declared handed off"
  [ -f "$O/50-fixture-stop.log" ] && { say "  FAIL: fixture stop ran after failed reap"; STRIKE=1; } || say "  PASS: no fixture stop after failed reap"
  say "  K4 timing: $(grep -o 'cleanup_seconds=[0-9.]*' "$O/exit-codes.txt") (reap 10+5 s)"
  [ "$RC" = 124 ] || { say "  FAIL: outer exit $RC"; STRIKE=1; }; owned_cleanup
  # ---------- K5 normal-path stop failure → 71
  need K5-stop-failure 15; CUR=k5; run_runner "$RUNNER" "$OUT54" 15 STUB_STOP_RC=1 S2_RUNNER_STUBS=$STUBS
  expect "$O/exit-codes.txt" '^final=71 first_exit=0 cleanup_exit=71 signal=none reap=ok' "K5 cleanup class 71 with first exit 0 preserved"
  expect "$O/exit-codes.txt" 'fixture_stop=1 survivors=none' "K5 stop exit 1 recorded"
  [ "$RC" = 71 ] || { say "  FAIL: exit $RC"; STRIKE=1; }; owned_cleanup
  # ---------- K6 first failing step preserved
  need K6-first-failure 10; CUR=k6; run_runner "$RUNNER" "$OUT54" 10 STUB_GUARD_RC=3 S2_RUNNER_STUBS=$STUBS
  expect "$O/exit-codes.txt" '^final=3 first_exit=3 cleanup_exit=0 signal=none reap=ok' "K6 first failure is the process exit"
  expect "$O/exit-codes.txt" 'guard_spec=3 refusal_hosted=notrun .* fixture=notrun composition=notrun s1_r4_discriminator=notrun fixture_stop=notrun survivors=none' "K6 later steps notrun, no stop"
  [ "$RC" = 3 ] || { say "  FAIL: exit $RC"; STRIKE=1; }; owned_cleanup

elif [ "$SET" = new1 ]; then
  # ---------- K7pre: v5.3.1 bytes, leader exits 0 while a same-group unnamed child lives (A01 counterexample)
  need K7pre-v5.3.1-leader-exits-first 6; CUR=k7pre; run_runner "$PRE_RUNNER" "$OUT531" 6 STUB_HARNESS_MODE=leader-exit STUB_HARNESS_SLEEP=30 S2_RUNNER_STUBS=$STUBS
  sp=$(grep -ohE 'spawned pid=[0-9]+' "$O"/40-composition.log 2>/dev/null | grep -oE '[0-9]+$'); say "  K7pre spawned child pid=[$sp] alive after runner exit: $(alive "$sp" && echo YES || echo no)"
  expect "$O/exit-codes.txt" '^final=0 first_exit=0 cleanup_exit=0 signal=none reap=ok' "K7pre(counterexample): v5.3.1 reports full success"
  expect "$O/exit-codes.txt" 's1_r4_discriminator=0 fixture_stop=0 survivors=none' "K7pre(counterexample): v5.3.1 advanced to the discriminator and stamped survivors=none"
  alive "$sp" && say "  PASS(counterexample): unnamed same-group child survived v5.3.1's success path (A01 reproduced)" || { say "  FAIL: child not alive — counterexample not reproduced"; STRIKE=1; }
  owned_cleanup
  # ---------- K7: v5.4 same scenario → stage refused 70, group halted, no survivors
  need K7-v5.5-leader-exits-first 6; CUR=k7; run_runner "$RUNNER" "$OUT54" 6 STUB_HARNESS_MODE=leader-exit STUB_HARNESS_SLEEP=30 S2_RUNNER_STUBS=$STUBS
  sp=$(grep -ohE 'spawned pid=[0-9]+' "$O"/40-composition.log 2>/dev/null | grep -oE '[0-9]+$'); say "  K7 spawned child pid=[$sp] alive after runner exit: $(alive "$sp" && echo YES || echo no)"
  expect "$O/stamp.txt" '^40-composition: leader pid=[0-9]+ exited rc=0 but group [0-9]+ still has members' "K7 post-exit quiescence detected the leaked group member (O1)"
  expect "$O/stamp.txt" '^HALT: live owned groups \[' "K7 halt targeted the recorded group"
  expect "$O/exit-codes.txt" '^final=70 first_exit=70 cleanup_exit=0 signal=none reap=ok' "K7 stage refused (70), cleanup clean"
  expect "$O/exit-codes.txt" 's1_r4_discriminator=notrun fixture_stop=0 survivors=none' "K7 next stage NOT run, fixture stopped after reap, no survivors"
  expect "$O/stamp.txt" '^DEADLINE: cleanup deadline started \(50 s\) reason=quiescence-40-composition' "K7 deadline started before the first exceptional reap (P4)"
  alive "$sp" && { say "  FAIL: child still alive"; STRIKE=1; } || say "  PASS: leaked child gone before fixture stop/exit"
  [ "$RC" = 70 ] || { say "  FAIL: exit $RC"; STRIKE=1; }; owned_cleanup
  # ---------- K8pre: v5.3.1 bytes, inner step timeout (bound 2 s) with a same-group grandchild (B01 counterexample). Requires STUB_STEP40_BOUND → v5.3.1 ignores it (bound 1500), so use outer TERM at 4 s instead: NOT the same path. Recorded honestly: v5.3.1 has no stub-only bound, so K8pre reproduces via the runner's OWN step-timeout only if the harness times out itself: emulate with STUB_HARNESS_MODE=grandchild + outer 4 s (signal path, K3-like) — this does NOT reproduce B01's 124 path on v5.3.1; it is retained only to show the grandchild survives the v5.3.1 signal path when unnamed.
  need K8pre-v5.3.1-unnamed-grandchild-under-TERM 8; CUR=k8pre; KA=4 run_runner "$PRE_RUNNER" "$OUT531" 4 STUB_HARNESS_MODE=grandchild STUB_HARNESS_SLEEP=30 S2_RUNNER_STUBS=$STUBS
  sp=$(grep -ohE 'spawned pid=[0-9]+' "$O"/40-composition.log 2>/dev/null | grep -oE '[0-9]+$'); say "  K8pre spawned grandchild pid=[$sp] alive after runner exit: $(alive "$sp" && echo YES || echo no) (v5.3.1 signals the live group here, so 'no' is the expected, non-defective outcome — informational)"
  say "  K8pre registers: $(cat "$O/exit-codes.txt" 2>/dev/null | cut -c1-120)"; owned_cleanup
  # ---------- K8: v5.4 inner step timeout (stub-only bound 2 s) with same-group grandchild → 124 kept as first exit, group halted, no survivors
  need K8-v5.5-inner-timeout-grandchild 8; CUR=k8; run_runner "$RUNNER" "$OUT54" 8 STUB_HARNESS_MODE=grandchild STUB_HARNESS_SLEEP=30 STUB_STEP40_BOUND=2 S2_RUNNER_STUBS=$STUBS
  sp=$(grep -ohE 'spawned pid=[0-9]+' "$O"/40-composition.log 2>/dev/null | grep -oE '[0-9]+$'); say "  K8 spawned grandchild pid=[$sp] alive after runner exit: $(alive "$sp" && echo YES || echo no)"
  expect "$O/stamp.txt" '^40-composition: leader pid=[0-9]+ exited rc=124 but group [0-9]+ still has members' "K8 inner 124 with a live group member detected (O1/B01)"
  expect "$O/exit-codes.txt" '^final=124 first_exit=124 cleanup_exit=0 signal=none reap=ok' "K8 first exit 124 preserved, cleanup clean"
  expect "$O/exit-codes.txt" 'fixture_stop=0 survivors=none' "K8 fixture stopped after reap, no survivors"
  alive "$sp" && { say "  FAIL: grandchild still alive"; STRIKE=1; } || say "  PASS: grandchild gone"
  [ "$RC" = 124 ] || { say "  FAIL: exit $RC"; STRIKE=1; }; owned_cleanup
  # ---------- K9: unnamed setsid escapee (own session, cmd 'sleep') — DOCUMENTED BOUNDARY of v5.4 (no OS-level boundary): expected to be missed
  need K9-v5.5-unnamed-setsid-escape-boundary 6; CUR=k9; run_runner "$RUNNER" "$OUT54" 6 STUB_HARNESS_MODE=escape-unnamed STUB_HARNESS_SLEEP=30 S2_RUNNER_STUBS=$STUBS
  sp=$(grep -ohE 'spawned pid=[0-9]+' "$O"/40-composition.log 2>/dev/null | grep -oE '[0-9]+$'); say "  K9 escaped unnamed pid=[$sp] alive after runner exit: $(alive "$sp" && echo YES || echo no)"
  expect "$O/exit-codes.txt" '^final=0 first_exit=0 cleanup_exit=0 signal=none reap=ok' "K9 v5.4 reports success (predicted: the escapee is invisible to group+pattern ownership)"
  alive "$sp" && say "  BOUNDARY CONFIRMED (not an ownership pass): unnamed setsid escapee survives undetected — see FINDINGS_MAP K9/OS-boundary proposal" || { say "  FAIL: prediction wrong — escapee did not survive (investigate before trusting the boundary statement)"; STRIKE=1; }
  owned_cleanup

elif [ "$SET" = new2 ]; then
  # ---------- K10: hanging fixture stop → clipped stop bound, 124, cleanup class 71, first exit 0 preserved, deadline kept
  need K10-v5.5-hanging-stop 40; CUR=k10; run_runner "$RUNNER" "$OUT54" 35 STUB_STOP_HANG=60 S2_RUNNER_STUBS=$STUBS
  sp=$(grep -ohE 'spawned pid=[0-9]+' "$O"/50-fixture-stop.log 2>/dev/null | grep -oE '[0-9]+$'); say "  K10 hanging stop child pid=[$sp] alive after runner exit: $(alive "$sp" && echo YES || echo no)"
  [ -n "$sp" ] && ! alive "$sp" && say "  PASS: hanging stop child (recorded identity) is gone" || { say "  FAIL: hanging child missing identity or alive"; STRIKE=1; }
  expect "$O/exit-codes.txt" '^final=71 first_exit=0 cleanup_exit=71 signal=none reap=ok' "K10 stop failure class 71, first exit 0 preserved"
  expect "$O/exit-codes.txt" 'deadline_exceeded=no .* fixture_stop=124' "K10 stop bound hit (124) inside the cleanup deadline"
  expect "$O/stamp.txt" '^50-fixture-stop: client exited rc=124 but its group [0-9]+ still has members' "K10 owned stop group census caught the hanging child (P3)"
  expect "$O/stamp.txt" 'cleanup_client_leak=yes' "K10 leak classified as cleanup failure, not hidden"
  expect "$O/stamp.txt" '^50 fixture-stop exit=124 \(124=stop bound 20s exceeded' "K10 nominal 20 s stop bound applied (deadline had room)"
  cs=$(grep -o 'cleanup_seconds_total=[0-9.]*' "$O/RECEIPT.txt" | cut -d= -f2); say "  K10 cleanup_seconds_total=$cs (expected 20–30 incl. census/halt/receipt)"
  awk -v c="$cs" 'BEGIN{exit !(c>=20 && c<=30)}' && say "  PASS: cleanup total within 20–30 s" || { say "  FAIL: cleanup_seconds_total=$cs out of range"; STRIKE=1; }
  [ "$RC" = 71 ] || { say "  FAIL: exit $RC"; STRIKE=1; }; owned_cleanup

elif [ "$SET" = neg ]; then
  # ---------- N1: pre-existing decoy must survive the child driver's refusal (A03)
  need N1-decoy-survives-refusal 18
  bash -c 'exec -a s2r53-stub-escapee sleep 25' </dev/null >/dev/null 2>&1 & DECOY=$!; record "$DECOY"; sleep 0.3
  say "  decoy pid=$DECOY launched by THIS driver (recorded owned); invoking child driver CTL_SET=k which must refuse"
  enclose n1 "$(clip 12)" 5 env CTL_SET=k CTL_BUDGET=20 bash "$0" >"$CTL/n1.child.log" 2>&1; rc=$RC; say "  N1 child driver exit=$rc (expected 2)"; grep -h 'ABORT' "$CTL/n1.child.log" | head -1 | sed 's/^/    /' | tee -a "$R"
  [ "$rc" = 2 ] && say "  PASS: refusal exit 2" || { say "  FAIL: exit $rc"; STRIKE=1; }
  alive "$DECOY" && say "  PASS: decoy survived the refusal (not signalled)" || { say "  FAIL: decoy was killed by the refusing driver"; STRIKE=1; }
  grep -q 'controls_run=0/' "$CTL/n1.child.log" && say "  PASS: no control started" || { say "  FAIL: a control started"; STRIKE=1; }
  owned_cleanup   # kills only the recorded decoy
  # ---------- N2: an expectation miss must yield aggregate exit 1 and stop (A04)
  need N2-assertion-miss-exit-1 30
  enclose n2 "$(clip 20)" 5 env CTL_SET=k CTL_INJECT_FAIL=1 CTL_BUDGET=30 bash "$0" >"$CTL/n2.child.log" 2>&1; rc=$RC; say "  N2 child driver exit=$rc (expected 1)"
  [ "$rc" = 1 ] && say "  PASS: aggregate exit 1" || { say "  FAIL: exit $rc"; STRIKE=1; }
  grep -q 'ONE-STRIKE STOP before K2' "$CTL/n2.child.log" && say "  PASS: stopped before K2" || { say "  FAIL: did not stop at K2"; STRIKE=1; }
  grep -q 'controls_run=1/6' "$CTL/n2.child.log" && say "  PASS: 1/6 reported" || { say "  FAIL: run count"; STRIKE=1; }
  owned_cleanup
  # ---------- N3: budget exhaustion must yield exit 3 without starting a control (A04)
  need N3-budget-exhaustion-exit-3 12
  enclose n3 "$(clip 6)" 5 env CTL_SET=k CTL_BUDGET=9 bash "$0" >"$CTL/n3.child.log" 2>&1; rc=$RC; say "  N3 child driver exit=$rc (expected 3)"
  [ "$rc" = 3 ] && say "  PASS: aggregate exit 3" || { say "  FAIL: exit $rc"; STRIKE=1; }
  grep -q 'BUDGET EXHAUSTED before K1' "$CTL/n3.child.log" && grep -q 'controls_run=0/6' "$CTL/n3.child.log" && say "  PASS: nothing started" || { say "  FAIL: a control started or wrong message"; STRIKE=1; }
  owned_cleanup
fi
say; say "SET $SET: all planned controls executed; strike=$STRIKE"; finish 0
