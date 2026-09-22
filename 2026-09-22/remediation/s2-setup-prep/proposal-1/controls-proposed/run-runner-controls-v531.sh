#!/usr/bin/env bash
# PROPOSED, NOT EXECUTED under S2-SETUP-FIXTURE-PREP (2026-09-22). Derived from execution/s2-runner53/controls/run-controls.sh
# sha256 4d4bc661978eccb666bd22596c0282db78f1c627c16db9e7df9f6cbebc64e689: paths -> s2-setup-prep, runner -> v5.3.1, outputs -> runner-selftest-r531/,
# results -> controls-proposed/results/<utc>/. Stubs byte-identical to the s2-runner53 stubs. Expectations unchanged (K1..K6).
# S2-RUNNER-53 bounded no-DB / no-network fake-process controls. ONE control at a time, sequential, ≤60 s total wall clock,
# lane-private lock ($STUBS/test-validation.lock), synthetic temp paths only, explicit owned PID/group cleanup, one-strike stop.
# Never touches /home/user/workspace/execution/test-validation.lock, any database, network, product source or unowned process.
set -u
LANE=/home/user/workspace/execution/s2-setup-prep; RUNNER=$LANE/run-composition-r53-v5.3.1-when-granted.sh; STUBS=$LANE/controls-proposed/stubs
CTL=$LANE/controls-proposed/results/$(date -u +%Y%m%dT%H%M%SZ); mkdir -p "$CTL"; R=$CTL/CONTROLS_RESULT.txt
T0=$(date +%s.%N); BUDGET=60; SOFT=45
say(){ echo "$*" | tee -a "$R"; }
now(){ awk -v a="$T0" -v b="$(date +%s.%N)" 'BEGIN{printf "%.2f", b-a}'; }
owned_pids(){ pgrep -f "^s2r53-stub-escapee|^timeout --foreground 1500 bash $STUBS/harness.sh|^bash $STUBS/harness.sh" 2>/dev/null; }
descendants(){ local p; for p in "$@"; do echo "$p"; descendants $(pgrep -P "$p" 2>/dev/null); done; }
# explicit owned cleanup: only pids matched by our stub patterns and their descendants
owned_cleanup(){ local pids; pids=$(descendants $(owned_pids) | sort -un); if [ -n "$pids" ]; then say "  owned cleanup: TERM pids [$(echo $pids)] $(ps -o pid=,pgid=,cmd= -p $(echo $pids | tr ' ' ',') | tr '\n' ';')"; kill -TERM $pids 2>/dev/null; sleep 0.5; pids=$(descendants $(owned_pids) | sort -un); [ -n "$pids" ] && { say "  owned cleanup: KILL pids [$(echo $pids)]"; kill -KILL $pids 2>/dev/null; sleep 0.3; }; fi; say "  owned processes after cleanup: [$(owned_pids | tr '\n' ' ')]"; }
latest_out(){ ls -1dt "$LANE"/runner-selftest-r531/*/ 2>/dev/null | head -1; }
expect(){ # expect <file> <regex> <description>
  if grep -qE "$2" "$1" 2>/dev/null; then say "  PASS: $3"; else say "  FAIL: $3 (expected /$2/ in $1)"; STRIKE=1; fi; }
gate(){ local e; e=$(now); if awk -v e="$e" -v s="$SOFT" 'BEGIN{exit !(e>s)}'; then say "BUDGET GATE: elapsed ${e}s > ${SOFT}s soft limit — remaining controls NOT RUN"; finish; fi; [ "${STRIKE:-0}" = 1 ] && { say "ONE-STRIKE STOP: previous control failed its expectation — remaining controls NOT RUN"; finish; }; }
finish(){ owned_cleanup; say "TOTAL wall clock: $(now)s of ${BUDGET}s budget; lane lock: $(flock -n "$STUBS/test-validation.lock" true && echo FREE || echo HELD); canonical lock file exists: $([ -e /home/user/workspace/execution/test-validation.lock ] && echo yes || echo no) (never touched)"; ( cd "$CTL" && find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS ); exit 0; }
STRIKE=0
say "S2-RUNNER-53 controls start $(date -u +%FT%TZ) runner_sha256=$(sha256sum "$RUNNER" | cut -c1-64) stubs=$(cd "$STUBS" && sha256sum *.sh | cut -c1-16 | tr '\n' ' ')"
say "pre-snapshot owned-pattern processes: [$(owned_pids | tr '\n' ' ')] (must be empty for attributable survivors)"; [ -z "$(owned_pids)" ] || { say "ABORT: pre-existing pattern matches"; finish; }
say "pre-snapshot 54321 listener: [$(ss -ltnH 2>/dev/null | grep -E ':54321\b')] pg17 postgres: [$(pgrep -af '^/home/user/pg17' | tr '\n' ' ')]"

# ---------- K1: predecessor MECHANISM counterexample (reimplemented v5.1 shape; NOT v5.1 bytes)
say; say "== K1 predecessor-mechanism (v5.1 shape) under timeout --foreground -k 5 2 — expect: outer 124, fixture stop ran, step-40 child tree SURVIVES runner exit  [t=$(now)s]"
K1=$CTL/k1; mkdir -p "$K1"
timeout --foreground -k 5 2 bash "$LANE/controls-proposed/k1-predecessor-mechanism.sh" "$K1" "$STUBS" >"$K1/driver.log" 2>&1; rc=$?
say "  K1 outer exit=$rc; stamp:"; sed 's/^/    /' "$K1/stamp.txt" | tee -a "$R"
surv=$(descendants $(owned_pids) | sort -un | tr '\n' ' ')
say "  K1 step-40 child tree after runner exit: [$surv] $(ps -o pid=,pgid=,cmd= -p $(echo $surv | tr ' ' ',') 2>/dev/null | tr '\n' ';')"
[ "$rc" = 124 ] && say "  PASS: outer timeout fired (124)" || { say "  FAIL: outer exit $rc"; STRIKE=1; }
[ -f "$K1/50-fixture-stop.log" ] && say "  PASS(counterexample): fixture stop ran under a live step-40 child (predecessor defect reproduced)" || { say "  FAIL: fixture stop log missing"; STRIKE=1; }
[ -n "$surv" ] && say "  PASS(counterexample): step-40 child tree survived the runner (predecessor defect reproduced)" || { say "  FAIL: no survivor observed — counterexample not reproduced"; STRIKE=1; }
owned_cleanup; gate

# ---------- K2: v5.3 stub success
say; say "== K2 v5.3 stub success — expect exit 0, first_exit=0 cleanup_exit=0 reap=ok survivors=none, refusals 64/64  [t=$(now)s]"
S2_RUNNER_STUBS=$STUBS bash "$RUNNER" >"$CTL/k2.driver.log" 2>&1; rc=$?; O=$(latest_out); say "  K2 exit=$rc out=$O"
expect "$O/exit-codes.txt" '^final=0 first_exit=0 cleanup_exit=0 signal=none reap=ok' "K2 result registers"
expect "$O/exit-codes.txt" 'guard_spec=0 refusal_hosted=64 refusal_noconfirm=64 fixture=0 composition=0 s1_r4_discriminator=0 fixture_stop=0 survivors=none' "K2 all steps reached, refusals 64/64, stop 0"
expect "$O/stamp.txt" 'STUB MODE — NOT EVIDENCE' "K2 stub banner present"
expect "$O/stamp.txt" 'head=d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c tree=c0ab87d4dc584b2a7ccad53db16fa551b93fe359 dirty_lines=0' "K2 real head/tree/clean check at restored d5cd"
expect "$O/stamp.txt" 'REAP ok' "K2 owned-work scan clean before fixture stop"
expect "$O/20-refusal-hosted.log" 'S1-GUARD REFUSED URL_HOST' "K2 real harness offline refusal (hosted URL) — string layer, no connection"
expect "$O/21-refusal-noconfirm.log" 'S1-GUARD REFUSED CONFIRM' "K2 real harness offline refusal (no confirm)"
expect "$O/30-fixture-init.log" "fd9=$STUBS/test-validation.lock" "K2 fixture init inherited fd 9 (private lock)"
expect "$O/40-composition.log" 'fd9=closed' "K2 harness saw fd 9 closed"
[ "$rc" = 0 ] || { say "  FAIL: exit $rc"; STRIKE=1; }
owned_cleanup; gate

# ---------- K3: v5.3 TERM during step 40 (sleeping stub harness)
say; say "== K3 v5.3 SIGTERM during step 40 under timeout --foreground -k 20 3 — expect: halt+reap BEFORE fixture stop, composition=interrupted(TERM), first_exit=143, no survivors  [t=$(now)s]"
STUB_HARNESS_MODE=sleep STUB_HARNESS_SLEEP=30 timeout --foreground -k 20 3 env S2_RUNNER_STUBS=$STUBS bash "$RUNNER" >"$CTL/k3.driver.log" 2>&1; rc=$?; O=$(latest_out); say "  K3 outer exit=$rc out=$O"
surv=$(descendants $(owned_pids) | sort -un | tr '\n' ' '); say "  K3 owned-pattern processes after runner exit: [$surv]"
expect "$O/exit-codes.txt" '^final=143 first_exit=143 cleanup_exit=0 signal=TERM reap=ok' "K3 signal exit recorded as first exit; cleanup class 0"
expect "$O/exit-codes.txt" 'composition=interrupted\(TERM\) s1_r4_discriminator=notrun fixture_stop=0 survivors=none' "K3 step labelled interrupted, stop 0, no survivors"
[ -z "$surv" ] && say "  PASS: no step-40 child survives the runner (predecessor defect closed)" || { say "  FAIL: survivors [$surv]"; STRIKE=1; }
# ordering: SIGNAL line < HALT line < REAP ok < CLEANUP begin < 50 fixture-stop
o1=$(grep -n '^SIGNAL SIGTERM' "$O/stamp.txt" | cut -d: -f1 | head -1); o2=$(grep -n '^REAP ok' "$O/stamp.txt" | cut -d: -f1 | head -1); o3=$(grep -n '^50 fixture-stop' "$O/stamp.txt" | cut -d: -f1 | head -1)
[ -n "$o1" ] && [ -n "$o2" ] && [ -n "$o3" ] && [ "$o1" -lt "$o2" ] && [ "$o2" -lt "$o3" ] && say "  PASS: ordering SIGNAL($o1) < REAP ok($o2) < fixture stop($o3)" || { say "  FAIL: ordering signal=$o1 reap=$o2 stop=$o3"; STRIKE=1; }
expect "$O/stamp.txt" 'LOCK: held by runner through cleanup \(HELD\)' "K3 lock held through cleanup"
say "  K3 cleanup timing: $(grep -o 'cleanup_seconds=[0-9.]*' "$O/exit-codes.txt")"
[ "$rc" = 124 ] || { say "  FAIL: outer exit $rc (expected 124 from timeout)"; STRIKE=1; }
owned_cleanup; gate

# ---------- K4: v5.3 escapee → REAP FAILED → fixture stop REFUSED (quarantine 72)
say; say "== K4 v5.3 SIGTERM with a group-escaping child (setsid) — expect: reap FAILED after TERM+KILL budget (≤15 s), fixture stop REFUSED, cleanup_exit=72, QUARANTINE.txt, lock not handed off  [t=$(now)s]"
STUB_HARNESS_MODE=escape STUB_HARNESS_SLEEP=40 timeout --foreground -k 20 3 env S2_RUNNER_STUBS=$STUBS bash "$RUNNER" >"$CTL/k4.driver.log" 2>&1; rc=$?; O=$(latest_out); say "  K4 outer exit=$rc out=$O"
esc=$(pgrep -f '^s2r53-stub-escapee' | tr '\n' ' '); say "  K4 escapee still alive after runner exit (expected; it is the quarantined survivor): [$esc]"
expect "$O/exit-codes.txt" '^final=143 first_exit=143 cleanup_exit=72 signal=TERM reap=FAILED' "K4 quarantine class 72 recorded separately from first exit 143"
expect "$O/exit-codes.txt" 'fixture_stop=REFUSED survivors=present' "K4 fixture stop REFUSED, survivors present"
expect "$O/QUARANTINE.txt" 's2r53-stub-escapee' "K4 QUARANTINE.txt lists the escapee"
expect "$O/stamp.txt" 'LOCK: held by runner through cleanup \(HELD\); NOT safely handed off' "K4 lock not declared handed off"
[ -f "$O/50-fixture-stop.log" ] && { say "  FAIL: fixture stop ran after failed reap"; STRIKE=1; } || say "  PASS: no fixture stop attempted after failed reap"
say "  K4 cleanup timing: $(grep -o 'cleanup_seconds=[0-9.]*' "$O/exit-codes.txt") (budget worst 48 s; TERM+KILL reap waits 10+5 s)"
[ "$rc" = 124 ] || { say "  FAIL: outer exit $rc"; STRIKE=1; }
owned_cleanup; gate

# ---------- K5: normal-path stop failure → first_exit 0 preserved, cleanup 71
say; say "== K5 v5.3 stub fixture stop rc=1 on the normal path — expect first_exit=0 cleanup_exit=71 final=71  [t=$(now)s]"
STUB_STOP_RC=1 S2_RUNNER_STUBS=$STUBS bash "$RUNNER" >"$CTL/k5.driver.log" 2>&1; rc=$?; O=$(latest_out); say "  K5 exit=$rc out=$O"
expect "$O/exit-codes.txt" '^final=71 first_exit=0 cleanup_exit=71 signal=none reap=ok' "K5 cleanup failure class with first exit preserved as 0"
expect "$O/exit-codes.txt" 'fixture_stop=1 survivors=none' "K5 stop exit 1 recorded"
[ "$rc" = 71 ] || { say "  FAIL: exit $rc"; STRIKE=1; }
owned_cleanup; gate

# ---------- K6: first failing step preserved (guard spec exit 3), nothing started → no stop
say; say "== K6 v5.3 stub guard-spec rc=3 — expect final=3 first_exit=3 cleanup_exit=0 fixture=notrun fixture_stop=notrun  [t=$(now)s]"
STUB_GUARD_RC=3 S2_RUNNER_STUBS=$STUBS bash "$RUNNER" >"$CTL/k6.driver.log" 2>&1; rc=$?; O=$(latest_out); say "  K6 exit=$rc out=$O"
expect "$O/exit-codes.txt" '^final=3 first_exit=3 cleanup_exit=0 signal=none reap=ok' "K6 first failure is the process exit"
expect "$O/exit-codes.txt" 'guard_spec=3 refusal_hosted=notrun .* fixture=notrun composition=notrun s1_r4_discriminator=notrun fixture_stop=notrun survivors=none' "K6 later steps notrun, no stop attempted"
[ "$rc" = 3 ] || { say "  FAIL: exit $rc"; STRIKE=1; }
owned_cleanup
say; say "ALL SIX CONTROLS EXECUTED; strike=$STRIKE"; finish
