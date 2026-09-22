#!/usr/bin/env bash
# S2 composition proof runner v5.4 — S2-R54-EXECUTION-SAFETY. Derived (2026-09-22) from FROZEN v5.3.1
# sha256 fb0d7ce4803fa0d414c703cb0362b2e66626b8d6cf63dfa9054ed8e3eb2dc925 (execution/s2-setup-prep, unchanged). v5.4 delta (FINDINGS_MAP.md):
#   O1 (A01/B01) every step group id is RETAINED in OWNED_PGIDS for the whole run; owned_scan covers all recorded groups (live members) plus the
#      unchanged anchored patterns (NOT widened); after each step's leader exits, a bounded post-exit quiescence check (QUIESCE_WAIT) must find
#      the group empty, otherwise the group is halted (TERM/KILL, bounded), the stage is refused (first_exit = step rc if nonzero else 70) and
#      the run ends via cleanup; halt targets are live groups, gated on group membership, never on the leader pid alone (inner 124 path).
#   O2 (A02) one elapsed cleanup deadline (CLEANUP_BUDGET s from cleanup/signal start): every reap poll, the fixture stop/status bounds and the
#      isolation-anomaly branch are clipped to the remaining time; no unconditional `wait` on a still-alive pid; deadline exhaustion is recorded
#      (deadline_exceeded=yes → cleanup class 71 at least); cleanup_seconds is measured before AND after the final evidence hashing.
#   O3 stub-mode-only: STUB_STEP40_BOUND may shorten step 40's bound so an inner-timeout counterexample fits a bounded control; ignored in real mode.
#   Unchanged: lock/fd-9 handling, target pins (head/lock/closure/fixture/NS/DB/PORT), steps 10–45 and the 164+1 harness, first-vs-cleanup exit
#   registers, refusal codes, quarantine posture (failed reap → fixture stop REFUSED, nothing erased), no destroy. v5.3.1 header follows.
# S2 composition proof runner v5.3.1 — S2-RUNNER-53 LANE. Derived (S2-SETUP-FIXTURE-PREP, 2026-09-22) from FROZEN v5.3
# sha256 fbc8b9af592b370429a66bf164d3c5ac0f0b1bac0f57474c50ac293ebebd1bfc (execution/s2-runner53, unchanged). v5.3.1 delta (see REPORT.md):
#   L1 lane paths: LANE=execution/s2-setup-prep, fixture infra/s2-fixture-r53.sh (REIMPLEMENTED fixture, sha pinned below; not 6062f4ce);
#   L2 fresh unique lane identity: NS=s2comp-r53, DB=s1_rls_s2comp_r53, PORT=54353 (was 54321; every listener/URL/confirm/scan literal now derives from $PORT);
#   L3 S2_FIXTURE_NS env export removed (fixture pins its own namespace; no env-controlled target);
#   L4 toolchain identity stamp (timeout/flock/setsid/pgrep implementations) — the sandbox `timeout` is uutils, not GNU (exit 15 vs 143 under group TERM, see s2-runner53 controls);
#   L5 output dirs composition-r53/ and runner-selftest-r531/. No other logic changed. v5.3 original header follows.
# S2 composition proof runner v5.3 — R3 LANE, EXECUTION-ONLY closure successor of v5.1 (sha256 0f4467e00c1ec878f4b8ff204a910d271a817a3c6bdc28a0df44f25023842e15).
# Source under test is UNCHANGED d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c (worktree /home/user/workspace/worktrees/s2-runner53). No product/harness/S1 edit.
#
# REIMPLEMENTATION NOTICE (G04): the v5.2 runner named in LAST_OPERATOR_STATE ("7e280683…5ccb") is NOT preserved in the named packet
# (b2-failed-and-r3-source/ holds v4.0/v4.1/v5.0/v5.1 only). v5.3 is therefore derived from the frozen v5.1 bytes plus the recorded
# counterexamples — 03A's TERM control (step child tree survives the runner; fixture stopped under a live harness; step mislabelled
# "notrun") and the state-recorded v5.2 limits (cleanup could take up to 25 s reap + 60 s stop > 60 s outer kill grace; fixture could be
# stopped after a FAILED reap). v5.3 does not claim to recover or contain v5.2 bytes.
#
# Closure implemented here (and only here):
#   1. every owned step runs in its OWN process group (setsid); the runner records pid/pgid/label of the live step;
#   2. TERM/INT/HUP → halt the live step's group (TERM, bounded reap; KILL, bounded reap), label it interrupted(<sig>), THEN cleanup;
#   3. a FAILED reap (any owned-work process survives) FORBIDS fixture stop / any further mutation: quarantine record, exit class 72,
#      "LOCK: NOT safely handed off"; nothing is erased;
#   4. cleanup is time-bounded by explicit constants whose worst case (48 s) fits the outer `timeout -k 60` grace with a 12 s margin;
#      fixture stop/status are wrapped in their own timeouts (the fixture script itself is used byte-for-byte, never edited);
#   5. the FIRST failing exit (or signal exit) is recorded separately from the CLEANUP exit; the process exit is the first failure
#      when there is one, otherwise the cleanup class (0 / 71 / 72). Both are always in exit-codes.txt and stamp.txt.
# Everything else (one nonblocking lock on fd 9 held from before fixture init through cleanup; fd 9 closed for every child except
# fixture init; refusals 64/64 before any server; fresh-only namespace / 54321 / no-postgres prechecks; pre-existing /tmp scratch
# files → REFUSE 70 untouched; anchored survivor scan; 75 lock busy; 70 refused precondition) is carried from v5.1.
#
# Offline self-test: S2_RUNNER_STUBS=<dir> swaps guard-spec/fixture/harness/discriminator for stub scripts, uses a lane-private lock
# and writes under runner-selftest-r53/ with a "STUB MODE — NOT EVIDENCE" banner. Refusal steps 20/21 still exercise the REAL harness's
# offline string layer (exit 64 before any psql/connection). Never for proof.
set -u
ROOT=/home/user/workspace
WT=$ROOT/worktrees/s2-runner53
LANE=$ROOT/execution/s2-setup-prep   # setup/fixture lane (grant05 install, fixture 9fcc3696); this runner lives in execution/s2-runner54
R54=$ROOT/execution/s2-runner54
EXPECT_HEAD=d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c   # FROZEN successor r3; no override
EXPECT_LOCK_SHA=62b05b908c835dae51e54af1e553d91f763a070da21813c4419d66e018d61390
EXPECT_FIXTURE_SHA=9fcc3696a48627b4ed10544cc6c8911e9f13d95fc7acf7ff324770363c24b881   # infra/s2-fixture-r53.sh (REIMPLEMENTATION from 08987e4c; request-03's 6062f4ce is unpreserved); refuse if absent/different
CLOSURE_REF=9742037b153221de565e651ad8ba3b721bc0fb31   # A2 dependency closure was installed at this ancestor
DB=s1_rls_s2comp_r53
NS=s2comp-r53   # must equal the fixture's pinned NS (fixture is hash-pinned above)
PORT=54353      # must equal the fixture's pinned PORT; lane-unique (historical S2 lanes 54321, S5 54325)
unset S2_KEEP_FIXTURE
# ---- cleanup budget (seconds). Outer launch is `timeout --foreground -k 60 2100`: TERM at 2100 s, KILL 60 s later.
OUTER_GRACE=60; REAP_TERM_WAIT=10; REAP_KILL_WAIT=5; STOP_BUDGET=20; STOP_KILL=3; STATUS_BUDGET=5; STATUS_KILL=2; SCAN_HASH_ALLOW=3
CLEANUP_BUDGET=50; QUIESCE_WAIT=2; ANOMALY_WAIT=3   # O2: single elapsed deadline for the whole cleanup (< OUTER_GRACE); O1: post-exit group quiescence; isolation-anomaly bound
WORST=$((REAP_TERM_WAIT+REAP_KILL_WAIT+STOP_BUDGET+STOP_KILL+STATUS_BUDGET+STATUS_KILL+SCAN_HASH_ALLOW)); MARGIN=$((OUTER_GRACE-WORST))
STAMP=$(date -u +%Y%m%dT%H%M%SZ)
STUBS=${S2_RUNNER_STUBS-}
if [ -n "$STUBS" ]; then
  LOCK=$STUBS/test-validation.lock; OUT=$R54/runner-selftest-r54/$STAMP
  GUARD_SPEC="bash $STUBS/guard-spec.sh"; FIXTURE="bash $STUBS/fixture.sh"; HARNESS="bash $STUBS/harness.sh"; DISC="bash $STUBS/discriminator.sh"
  REFUSAL_HARNESS="bash $WT/test/release/s1s2-composition.sh"   # real offline refusal path is cheap and DB-free
  OWNED_PAT="^bash $STUBS/|^s2r53-stub-escapee|^bash $WT/test/release/s1s2-composition.sh"
else
  LOCK=$ROOT/execution/test-validation.lock; OUT=$R54/composition-r54/$STAMP
  GUARD_SPEC="bash test/db/s1-harness-guard.spec.sh"; FIXTURE="bash $LANE/infra/s2-fixture-r53.sh"
  HARNESS="bash test/release/s1s2-composition.sh"; DISC="bash test/db/s1-r4-truncate-discriminator.sh"; REFUSAL_HARNESS=$HARNESS
  OWNED_PAT="^bash test/db/s1-harness-guard.spec.sh|^bash test/release/s1s2-composition.sh|^bash test/db/s1-r4-truncate-discriminator.sh|^psql .*(127\.0\.0\.1:$PORT|-p $PORT)|^node .*prisma/build/index.js"
fi
FIXTURE_PAT="^/home/user/pg17/dist/bin/postgres|^postgres: s1-disposable-pg17"
mkdir -p "$OUT"
S="$OUT/stamp.txt"
stamp(){ echo "$*" | tee -a "$S"; }
lock_probe(){ if flock -n "$LOCK" true 2>/dev/null; then echo FREE; else echo HELD; fi; }
[ -n "$STUBS" ] && stamp "STUB MODE — NOT EVIDENCE (stubs=$STUBS, private lock=$LOCK)"

# ---- result registers. FIRST_EXIT = first failing step / signal; CLEANUP_EXIT = cleanup class; FINAL derived in cleanup, never an unconditional 0.
FIRST_EXIT=unset; CLEANUP_EXIT=unset; FINAL=1; SIGNAL=none; REAP=unchecked; RC_STOP=notrun; SURVIVORS=unchecked; FIXTURE_STARTED=0; CLEANUP_T0=
RC_GUARD=notrun; RC_R20=notrun; RC_R21=notrun; RC_FIXTURE=notrun; RC_COMP=notrun; RC_DISC=notrun
STEP_LABEL=none; STEP_PID=; STEP_PGID=; OWNED_PGIDS=; DEADLINE_EXCEEDED=no; CLEANUP_DEADLINE=
now_s(){ date +%s; }
remaining(){ local r; [ -n "$CLEANUP_DEADLINE" ] || { echo 999; return; }; r=$((CLEANUP_DEADLINE-$(now_s))); [ $r -gt 0 ] && echo $r || echo 0; }   # pure (safe in subshells)
deadline_check(){ [ -n "$CLEANUP_DEADLINE" ] && [ "$(now_s)" -ge "$CLEANUP_DEADLINE" ] && DEADLINE_EXCEEDED=yes; :; }   # sets the flag in the main shell
live_groups(){ local g; for g in $OWNED_PGIDS; do pgrep -g "$g" >/dev/null 2>&1 && echo "$g"; done; }
finish(){ FIRST_EXIT=$1; exit; }   # EXIT trap → cleanup decides the process exit

# ---- owned-work scan: processes of the live step's group plus anchored owned-work cmdlines (never the fixture server; never platform/unowned processes)
owned_scan(){   # O1: every recorded step group (live members) + anchored owned-work cmdlines; patterns deliberately NOT widened
  { local g; for g in $OWNED_PGIDS; do pgrep -g "$g" -a 2>/dev/null; done; pgrep -af "$OWNED_PAT" 2>/dev/null; } | grep -vE "^[0-9]+ (pgrep|grep) " | awk -v me=$$ '$1!=me' | sort -u
}
# poll_until_quiet <max_s>: returns 0 when owned_scan is empty; bounded by max_s AND by the cleanup deadline (O2)
poll_until_quiet(){ local end=$(( $(now_s) + $1 )) lim; while :; do [ -z "$(owned_scan)" ] && return 0; lim=$end; [ -n "$CLEANUP_DEADLINE" ] && [ "$CLEANUP_DEADLINE" -lt "$lim" ] && lim=$CLEANUP_DEADLINE; [ "$(now_s)" -ge "$lim" ] && { deadline_check; return 1; }; sleep 0.1; done; }
# halt_owned_work: TERM the live step's group, bounded reap; then KILL, bounded reap. Sets REAP=ok|FAILED. Signals ONLY the recorded group.
halt_owned_work(){   # O1/O2: targets = every recorded group that still has members (not the leader pid); bounded, deadline-clipped; no blocking wait
  local t0=$(now_s) left groups g
  groups=$(live_groups)
  if [ -n "$groups" ]; then
    stamp "HALT: live owned groups [$(echo $groups)] (current step '$STEP_LABEL' pid=${STEP_PID:-none}) → SIGTERM to each group (reap wait ≤${REAP_TERM_WAIT}s, remaining ${CLEANUP_DEADLINE:+$(remaining)s}${CLEANUP_DEADLINE:-unbounded-pre-cleanup})"
    for g in $groups; do kill -TERM -- "-$g" 2>/dev/null; done
    if ! poll_until_quiet "$REAP_TERM_WAIT"; then
      groups=$(live_groups); stamp "HALT: owned work still present after TERM → SIGKILL to groups [$(echo $groups)] (reap wait ≤${REAP_KILL_WAIT}s)"
      for g in $groups; do kill -KILL -- "-$g" 2>/dev/null; done
      poll_until_quiet "$REAP_KILL_WAIT" || true
    fi
    if [ -n "${STEP_PID:-}" ]; then
      if kill -0 "$STEP_PID" 2>/dev/null; then stamp "HALT: step child pid=$STEP_PID STILL ALIVE after KILL budget — not waiting on it (unreapable/blocked); counted as survivor"
      else wait "$STEP_PID" 2>/dev/null; stamp "HALT: step child pid=$STEP_PID reaped (wait status $?) after $(( $(now_s)-t0 ))s"; fi
    fi
  fi
  left=$(owned_scan)
  if [ -n "$left" ]; then REAP=FAILED; stamp "REAP FAILED: owned-work processes survive (listed in QUARANTINE.txt):"; echo "$left" | sed 's/^/  survivor: /' | tee -a "$S" > "$OUT/QUARANTINE.txt"
  else REAP=ok; stamp "REAP ok: no owned-work process survives (recorded groups [$(echo ${OWNED_PGIDS:-none})], anchored scan)"; fi
  STEP_PID=; STEP_PGID=   # group ids stay in OWNED_PGIDS (O1)
}
on_signal(){
  local sig=$1 code
  trap '' TERM INT HUP
  CLEANUP_T0=$(date +%s.%N); SIGNAL=$sig; CLEANUP_DEADLINE=$(( $(now_s) + CLEANUP_BUDGET ))   # O2: deadline starts at the signal
  case $sig in TERM) code=143;; INT) code=130;; HUP) code=129;; *) code=1;; esac
  stamp "SIGNAL SIG$sig at $(date -u +%FT%TZ) during step '$STEP_LABEL' (pid=${STEP_PID:-none} pgid=${STEP_PGID:-none}); owned work halts BEFORE any fixture stop; first_exit=$code (outer timeout itself reports 124)"
  case $STEP_LABEL in 10*) RC_GUARD="interrupted($sig)";; 20*) RC_R20="interrupted($sig)";; 21*) RC_R21="interrupted($sig)";;
    30*|31*|32*) RC_FIXTURE="interrupted($sig)";; 40*) RC_COMP="interrupted($sig)";; 45*) RC_DISC="interrupted($sig)";; esac
  halt_owned_work
  finish "$code"
}

# run_step <label> <bound_s> <log> [--inherit-fd9] -- <cmd...> : own process group per step; fd 9 closed unless --inherit-fd9 (fixture init only)
run_step(){
  local label=$1 bound=$2 log=$3; shift 3
  local inherit=0; [ "${1-}" = --inherit-fd9 ] && { inherit=1; shift; }; [ "${1-}" = -- ] && shift
  STEP_LABEL=$label
  if [ $inherit = 1 ]; then setsid timeout --foreground "$bound" "$@" >"$log" 2>&1 & else setsid timeout --foreground "$bound" "$@" >"$log" 2>&1 9>&- & fi
  STEP_PID=$!; STEP_PGID=
  for ((i=0;i<40;i++)); do STEP_PGID=$(ps -o pgid= -p "$STEP_PID" 2>/dev/null | tr -d ' '); [ "$STEP_PGID" = "$STEP_PID" ] && break; kill -0 "$STEP_PID" 2>/dev/null || break; sleep 0.05; done
  if [ "$STEP_PGID" != "$STEP_PID" ] && kill -0 "$STEP_PID" 2>/dev/null; then
    # O2: bounded anomaly handling — TERM by pid, poll ≤ANOMALY_WAIT, KILL, poll ≤1 s, never an unconditional wait on a live pid
    stamp "$label: ISOLATION ANOMALY pid=$STEP_PID pgid=$STEP_PGID (not its own group leader) → TERM by pid (≤${ANOMALY_WAIT}s), refuse (70)"; kill -TERM "$STEP_PID" 2>/dev/null
    for ((i=0;i<ANOMALY_WAIT*10;i++)); do kill -0 "$STEP_PID" 2>/dev/null || break; sleep 0.1; done
    if kill -0 "$STEP_PID" 2>/dev/null; then kill -KILL "$STEP_PID" 2>/dev/null; for ((i=0;i<10;i++)); do kill -0 "$STEP_PID" 2>/dev/null || break; sleep 0.1; done; fi
    if kill -0 "$STEP_PID" 2>/dev/null; then stamp "$label: anomaly pid=$STEP_PID still alive after KILL; recorded, not waited on"; [ -n "$STEP_PGID" ] && OWNED_PGIDS="$OWNED_PGIDS $STEP_PGID"; else wait "$STEP_PID" 2>/dev/null; fi
    STEP_PID=; STEP_PGID=; finish 70
  fi
  OWNED_PGIDS="$OWNED_PGIDS $STEP_PGID"   # O1: retained for the whole run, never cleared
  wait "$STEP_PID"; local rc=$?
  [ "$SIGNAL" != none ] && return 1   # a trapped signal already took over; never record this rc
  # O1: post-exit quiescence — the leader (timeout) exited; the GROUP must be empty before the stage counts as finished
  local end=$(( $(now_s) + QUIESCE_WAIT )) left
  while pgrep -g "$STEP_PGID" >/dev/null 2>&1 && [ "$(now_s)" -lt "$end" ]; do sleep 0.1; done
  left=$(pgrep -g "$STEP_PGID" -a 2>/dev/null | grep -vE "^[0-9]+ (pgrep|grep) ")
  if [ -n "$left" ]; then
    stamp "$label: leader pid=$STEP_PID exited rc=$rc but group $STEP_PGID still has members after ${QUIESCE_WAIT}s → stage NOT accepted; halting the group (owned survivors after step exit):"; echo "$left" | sed 's/^/  member: /' | tee -a "$S"
    halt_owned_work
    [ "$rc" -ne 0 ] && finish "$rc" || finish 70
  fi
  STEP_PID=; STEP_PGID=; STEP_LABEL=none
  return $rc
}

cleanup(){
  trap - EXIT; trap '' TERM INT HUP
  [ -n "$CLEANUP_T0" ] || CLEANUP_T0=$(date +%s.%N)
  [ -n "$CLEANUP_DEADLINE" ] || CLEANUP_DEADLINE=$(( $(now_s) + CLEANUP_BUDGET ))   # O2: elapsed deadline (starts at signal if one was trapped)
  [ "$FIRST_EXIT" = unset ] && FIRST_EXIT=1
  stamp "CLEANUP begin $(date -u +%FT%TZ) first_exit=$FIRST_EXIT signal=$SIGNAL lock=$(lock_probe) (held by this runner) budget: reap ${REAP_TERM_WAIT}+${REAP_KILL_WAIT}s, stop ${STOP_BUDGET}+${STOP_KILL}s, status ${STATUS_BUDGET}+${STATUS_KILL}s, scan/hash ${SCAN_HASH_ALLOW}s → worst ${WORST}s; ENFORCED elapsed deadline ${CLEANUP_BUDGET}s (remaining $(remaining)s) of outer grace ${OUTER_GRACE}s"
  # Owned work must be gone BEFORE the fixture is touched — on the normal path as well as after a signal.
  [ "$REAP" = unchecked ] && halt_owned_work
  if [ "$REAP" = FAILED ]; then
    CLEANUP_EXIT=72; RC_STOP=REFUSED
    stamp "QUARANTINE: owned work not reaped → fixture stop REFUSED, no further mutation (fixture_started=$FIXTURE_STARTED). Nothing erased. Parent must inspect QUARANTINE.txt before any other slot."
  elif [ "$FIXTURE_STARTED" != 0 ] && [ "${S2_KEEP_FIXTURE:-0}" != 1 ]; then
    # Stop attempted whenever a start was ATTEMPTED. Bounded here (the fixture's own pg_ctl -w default is 60 s, which alone would exceed outer grace).
    local sb=$STOP_BUDGET rem; rem=$(remaining); [ $((rem-STOP_KILL-STATUS_BUDGET-STATUS_KILL-SCAN_HASH_ALLOW)) -lt $sb ] && sb=$((rem-STOP_KILL-STATUS_BUDGET-STATUS_KILL-SCAN_HASH_ALLOW))   # O2: clip to remaining deadline
    if [ "$sb" -lt 3 ]; then RC_STOP="SKIPPED(deadline)"; DEADLINE_EXCEEDED=yes; stamp "50 fixture-stop SKIPPED: cleanup deadline leaves ${rem}s (<3 s usable); fixture left as is, reported as cleanup failure"
    else
      timeout --foreground -k $STOP_KILL $sb $FIXTURE stop >"$OUT/50-fixture-stop.log" 2>&1 9>&-; RC_STOP=$?
      stamp "50 fixture-stop exit=$RC_STOP (124=stop bound ${sb}s exceeded; nominal ${STOP_BUDGET}s) $(tail -1 "$OUT/50-fixture-stop.log" 2>/dev/null)"
      rem=$(remaining); if [ "$rem" -ge $((STATUS_BUDGET+STATUS_KILL)) ]; then timeout --foreground -k $STATUS_KILL $STATUS_BUDGET $FIXTURE status >"$OUT/51-fixture-status-after-stop.log" 2>&1 9>&-; stamp "51 fixture-status-after-stop: $(head -1 "$OUT/51-fixture-status-after-stop.log")"; else stamp "51 fixture-status SKIPPED (remaining ${rem}s)"; fi
    fi
  fi
  # process evidence: fixture postgres, any owned-work child, any $PORT listener (anchored cmdline starts; see v4.1 false-positive note)
  SURVIVORS=$( { pgrep -af "$FIXTURE_PAT|$OWNED_PAT" 2>/dev/null | grep -vE "^[0-9]+ (pgrep|grep) " | awk -v me=$$ '$1!=me'; ss -ltnH 2>/dev/null | grep -E ":${PORT}\b"; } | sed 's/^/  survivor: /' )
  if [ -n "$SURVIVORS" ]; then stamp "CLEANUP: surviving processes/listeners after cleanup:"; echo "$SURVIVORS" | tee -a "$S"; SURVIVORS=present; else SURVIVORS=none; stamp "CLEANUP: no surviving fixture/owned-work processes, nothing listening on $PORT"; fi
  if [ "$CLEANUP_EXIT" = unset ]; then
    deadline_check; if { [ "$RC_STOP" != notrun ] && [ "$RC_STOP" != 0 ]; } || [ "$SURVIVORS" = present ] || [ "$DEADLINE_EXCEEDED" = yes ]; then CLEANUP_EXIT=71; stamp "CLEANUP FAILURE: class 71 (stop_exit=$RC_STOP survivors=$SURVIVORS deadline_exceeded=$DEADLINE_EXCEEDED)"; else CLEANUP_EXIT=0; fi
  fi
  if [ "$FIRST_EXIT" != 0 ]; then FINAL=$FIRST_EXIT; else FINAL=$CLEANUP_EXIT; fi
  if [ "$REAP" = FAILED ] || [ "$SURVIVORS" = present ]; then stamp "LOCK: held by runner through cleanup ($(lock_probe)); NOT safely handed off — quarantine/survivors; parent must inspect before granting another slot"
  else stamp "LOCK: held by runner through cleanup ($(lock_probe)); released by runner exit; no survivors (probe after exit with check-lock.sh)"; fi
  local dur; dur=$(awk -v a="$CLEANUP_T0" -v b="$(date +%s.%N)" 'BEGIN{printf "%.2f", b-a}')
  stamp "end_utc=$(date -u +%FT%TZ) final_exit=$FINAL first_exit=$FIRST_EXIT cleanup_exit=$CLEANUP_EXIT signal=$SIGNAL reap=$REAP cleanup_seconds=$dur deadline_exceeded=$DEADLINE_EXCEEDED (enforced ${CLEANUP_BUDGET}s, arithmetic worst ${WORST}s, grace ${OUTER_GRACE}s) owned_groups=[$(echo ${OWNED_PGIDS:-none})] guard_spec=$RC_GUARD refusal_hosted=$RC_R20 refusal_noconfirm=$RC_R21 fixture=$RC_FIXTURE composition=$RC_COMP s1_r4_discriminator=$RC_DISC fixture_stop=$RC_STOP survivors=$SURVIVORS"
  echo "final=$FINAL first_exit=$FIRST_EXIT cleanup_exit=$CLEANUP_EXIT signal=$SIGNAL reap=$REAP cleanup_seconds=$dur deadline_exceeded=$DEADLINE_EXCEEDED guard_spec=$RC_GUARD refusal_hosted=$RC_R20 refusal_noconfirm=$RC_R21 fixture=$RC_FIXTURE composition=$RC_COMP s1_r4_discriminator=$RC_DISC fixture_stop=$RC_STOP survivors=$SURVIVORS" > "$OUT/exit-codes.txt"
  ( cd "$OUT" && find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS )
  # O2: honest total including the evidence hashing above; appended after the manifest so the manifest covers the registers, the total covers the manifest work
  dur=$(awk -v a="$CLEANUP_T0" -v b="$(date +%s.%N)" 'BEGIN{printf "%.2f", b-a}'); echo "cleanup_seconds_total=$dur (after SHA256SUMS; not covered by SHA256SUMS)" >> "$OUT/exit-codes.txt"; stamp "cleanup_seconds_total=$dur"
  exit "$FINAL"
}
trap cleanup EXIT
trap 'on_signal TERM' TERM; trap 'on_signal INT' INT; trap 'on_signal HUP' HUP   # registered after the EXIT trap so a signal always reaches cleanup

# ---- 0) lock FIRST (nonblocking), then identity/precondition refusals
exec 9>"$LOCK"
flock -n 9 || { stamp "lock busy: $LOCK (exit 75)"; finish 75; }
stamp "lock acquired pid=$$ fd9=$(readlink /proc/$$/fd/9) $(date -u +%FT%TZ) purpose=s2-composition-proof out=$OUT"
export PATH=/home/user/pg17/dist/bin:/usr/lib/postgresql/18/bin:$PATH
cd "$WT" || finish 70
HEAD=$(git rev-parse HEAD 9>&-); TREE=$(git rev-parse HEAD^{tree} 9>&-); DIRTY=$(git status --porcelain --untracked-files=all 9>&- | wc -l)
stamp "start_utc=$(date -u +%FT%TZ) runner=$0 runner_sha256=$(sha256sum "$0" | cut -c1-64) head=$HEAD tree=$TREE dirty_lines=$DIRTY branch=$(git rev-parse --abbrev-ref HEAD 9>&-)"
stamp "expect_head=$EXPECT_HEAD lock_sha256=$(sha256sum package-lock.json | cut -c1-64) expect_lock=$EXPECT_LOCK_SHA"
stamp "cleanup_budget: reap_term=${REAP_TERM_WAIT}s reap_kill=${REAP_KILL_WAIT}s stop=${STOP_BUDGET}+${STOP_KILL}s status=${STATUS_BUDGET}+${STATUS_KILL}s scan_hash=${SCAN_HASH_ALLOW}s worst=${WORST}s outer_grace=${OUTER_GRACE}s margin=${MARGIN}s"
stamp "harness_sha256=$(sha256sum test/release/s1s2-composition.sh | cut -c1-64) release_sh_sha256=$(sha256sum scripts/release.sh | cut -c1-64)"
stamp "toolchain: timeout=$(timeout --version 2>&1 | head -1) flock=$(flock --version 2>&1 | head -1) setsid=$(setsid --version 2>&1 | head -1) pgrep=$(pgrep --version 2>&1 | head -1) bash=$BASH_VERSION lane_identity: NS=$NS DB=$DB PORT=$PORT"
stamp "nproc=$(nproc) mem_free_mb=$(awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo) disk_free=$(df -h /home/user | awk 'NR==2{print $4}')"
[ "$HEAD" = "$EXPECT_HEAD" ] || { stamp "REFUSED: head $HEAD != expected $EXPECT_HEAD"; finish 70; }
[ "$DIRTY" = 0 ] || { stamp "REFUSED: worktree dirty ($DIRTY lines)"; git status --porcelain --untracked-files=all 9>&- | tee "$OUT/dirty.txt"; finish 70; }
[ "$(sha256sum package-lock.json | cut -c1-64)" = "$EXPECT_LOCK_SHA" ] || { stamp "REFUSED: lockfile hash mismatch"; finish 70; }
# dependency-closure admissibility: package-lock.json, package.json, prisma/schema.prisma must be byte-identical to the closure's install head
git diff --quiet "$CLOSURE_REF" HEAD -- package-lock.json package.json prisma/schema.prisma 9>&- || { stamp "REFUSED: closure files differ from $CLOSURE_REF; reused install not admissible"; finish 70; }
stamp "closure files identical to $CLOSURE_REF (package-lock.json package.json prisma/schema.prisma)"
if [ -z "$STUBS" ]; then
  stamp "node=$(node --version 2>&1) npm=$(npm --version 2>&1) psql=$(psql --version 2>&1) postgres=$(/home/user/pg17/dist/bin/postgres --version 2>&1)"
  stamp "prisma=$(node node_modules/prisma/build/index.js --version 2>/dev/null 9>&- | tr -s ' ' | tr '\n' ';')"
  stamp "prisma_cli_sha256=$(sha256sum node_modules/prisma/build/index.js 2>/dev/null | cut -c1-64) fixture_sha256=$(sha256sum "$LANE/infra/s2-fixture-r53.sh" 2>/dev/null | cut -c1-64) expect_fixture=$EXPECT_FIXTURE_SHA"
  [ -f node_modules/.s2-composition-install-stamp ] && sed 's/^/install_stamp: /' node_modules/.s2-composition-install-stamp | tee -a "$S"
  [ -f node_modules/prisma/build/index.js ] || { stamp "REFUSED: node_modules/prisma missing (setup-30 not done in this sandbox)"; finish 70; }
  NM_TARGET=$(readlink -f node_modules); stamp "node_modules -> $NM_TARGET"
  grep -q "^lock=$EXPECT_LOCK_SHA$" node_modules/.s2-composition-install-stamp 2>/dev/null || { stamp "REFUSED: install stamp lock hash != expected"; finish 70; }
  command -v psql >/dev/null || { stamp "REFUSED: psql missing (setup-10 not done)"; finish 70; }
  [ -x /home/user/pg17/dist/bin/postgres ] || { stamp "REFUSED: PG17 dist missing (setup-20 not done)"; finish 70; }
  [ "$(sha256sum "$LANE/infra/s2-fixture-r53.sh" 2>/dev/null | cut -c1-64)" = "$EXPECT_FIXTURE_SHA" ] || { stamp "REFUSED: fixture $LANE/infra/s2-fixture-r53.sh absent or != pinned $EXPECT_FIXTURE_SHA"; finish 70; }
  grep -q "^PORT=$PORT;" "$LANE/infra/s2-fixture-r53.sh" && grep -q "^NS=$NS$" "$LANE/infra/s2-fixture-r53.sh" || { stamp "REFUSED: fixture PORT/NS literals do not match runner PORT=$PORT NS=$NS"; finish 70; }
else
  stamp "STUB MODE: toolchain/node_modules/PG17/fixture-hash prechecks SKIPPED (not evidence); head/dirty/lockfile/closure checks above were REAL"
fi

# ---- 1) S1 offline guard spec at the composed head (no DB)
run_step 10-guard-spec 120 "$OUT/10-guard-spec.log" -- $GUARD_SPEC; RC_GUARD=$?
stamp "10 guard-spec exit=$RC_GUARD $(tail -1 "$OUT/10-guard-spec.log")"
[ "$RC_GUARD" -eq 0 ] || finish "$RC_GUARD"

# ---- 2) harness-level offline refusals BEFORE any server exists on the port (must exit 64, no DB contact)
run_step 20-refusal-hosted 120 "$OUT/20-refusal-hosted.log" -- env -i PATH="$PATH" HOME="$HOME" S1_PG_SUPER_URL='postgresql://postgres:pw@db.example.supabase.co:5432/postgres' S1_PG_PORT=5432 \
  S1_PG_DISPOSABLE_CONFIRM="DESTROY-db.example.supabase.co:5432/$DB,${DB}_lock" $REFUSAL_HARNESS "$DB"; RC_R20=$?
stamp "20 refusal-hosted exit=$RC_R20 (expect 64) $(tail -1 "$OUT/20-refusal-hosted.log")"; [ "$RC_R20" -eq 64 ] || finish 70
run_step 21-refusal-noconfirm 120 "$OUT/21-refusal-noconfirm.log" -- env -i PATH="$PATH" HOME="$HOME" S1_PG_SUPER_URL="postgresql://s1_super:s1_local_synthetic@127.0.0.1:$PORT/postgres" S1_PG_PORT=$PORT \
  $REFUSAL_HARNESS "$DB"; RC_R21=$?
stamp "21 refusal-noconfirm exit=$RC_R21 (expect 64) $(tail -1 "$OUT/21-refusal-noconfirm.log")"; [ "$RC_R21" -eq 64 ] || finish 70

# ---- 3) disposable fixture under THIS lock hold: init inherits fd 9 (fixture verifies via /proc); start/stop never take it
if [ -z "$STUBS" ]; then
  if [ -e /home/user/pg17/clusters/$NS ]; then stamp "30 REFUSED: /home/user/pg17/clusters/$NS already exists (unexpected state; not adopting, not deleting)"; finish 70; fi
  if ss -ltnH 2>/dev/null | grep -qE ":${PORT}\b"; then stamp "30 REFUSED: something already listens on $PORT: $(ss -ltnpH 2>/dev/null | grep -E ":${PORT}\b" | head -1)"; finish 70; fi
  if pgrep -f "^/home/user/pg17/dist/bin/postgres" >/dev/null; then stamp "30 REFUSED: a pg17 fixture postgres is already running: $(pgrep -af '^/home/user/pg17/dist/bin/postgres' | head -1)"; finish 70; fi
  stamp "30 precheck: clusters/$NS absent, no $PORT listener, no fixture postgres"
  PRE=$(ls -1 /tmp/prisma_migrate.log /tmp/prisma_status.log /tmp/prisma_verify.log /tmp/prisma_verifier.log /tmp/release_verifiers_discovered.txt 2>/dev/null)
  if [ -n "$PRE" ]; then ls -l --time-style=+%FT%TZ $PRE > "$OUT/preexisting-tmp-LISTING.txt"; stamp "30 precheck REFUSED: pre-existing release.sh /tmp scratch files (not touched): $(echo $PRE | tr '\n' ' ')"; finish 70; fi
  stamp "30 precheck: no pre-existing release.sh /tmp scratch files"
fi
run_step 30-fixture-init 120 "$OUT/30-fixture-init.log" --inherit-fd9 -- $FIXTURE init; RC_FIXTURE=$?
stamp "30 fixture-init exit=$RC_FIXTURE $(head -1 "$OUT/30-fixture-init.log")"; [ "$RC_FIXTURE" -eq 0 ] || finish "$RC_FIXTURE"
FIXTURE_STARTED=attempted
run_step 31-fixture-start 120 "$OUT/31-fixture-start.log" -- $FIXTURE start; RC_FIXTURE=$?
stamp "31 fixture-start exit=$RC_FIXTURE $(tail -1 "$OUT/31-fixture-start.log")"; [ "$RC_FIXTURE" -eq 0 ] || finish "$RC_FIXTURE"
FIXTURE_STARTED=1
run_step 32-fixture-status 30 "$OUT/32-fixture-status.log" -- $FIXTURE status; stamp "32 fixture-status: $(head -1 "$OUT/32-fixture-status.log")"
stamp "lock still held by runner: $(lock_probe) fd9=$(readlink /proc/$$/fd/9)"

# ---- 4) the real composition proof (guard preflight is the first thing the harness does)
export S1_PG_SUPER_URL="postgresql://s1_super:s1_local_synthetic@127.0.0.1:$PORT/postgres" S1_PG_PORT=$PORT
export S1_PG_DISPOSABLE_CONFIRM="DESTROY-127.0.0.1:$PORT/$DB,${DB}_lock" S2_COMP_OUT="$OUT/harness"
BOUND40=1500; [ -n "$STUBS" ] && [ -n "${STUB_STEP40_BOUND-}" ] && BOUND40=$STUB_STEP40_BOUND   # O3: stub mode only
run_step 40-composition "$BOUND40" "$OUT/40-composition.log" -- $HARNESS "$DB"; RC_COMP=$?
stamp "40 composition exit=$RC_COMP end_utc=$(date -u +%FT%TZ) $(grep -E '^== [0-9]+ passed' "$OUT/40-composition.log" | tail -1)"
[ "$RC_COMP" -eq 0 ] || finish "$RC_COMP"

# ---- 5) S1 R4 discriminator (S1-owned, frozen) on the PROTECTED database the harness leaves behind, under the same hold.
mkdir -p "$OUT/s1-r4"
export S1_PRISMA_CLI="$WT/node_modules/prisma/build/index.js" S1_PROOF_LOG="$OUT/s1-r4/s1-r4-discriminator.detail.log" S1_R4_LOCK_HOLDER="run-composition-r54-v5.4 pid=$$ fd9=$LOCK"
run_step 45-s1-r4-discriminator 300 "$OUT/s1-r4/s1-r4-discriminator.log" -- $DISC "$DB"; RC_DISC=$?
stamp "45 s1-r4-discriminator exit=$RC_DISC $(grep -E 'passed|FAIL' "$OUT/s1-r4/s1-r4-discriminator.log" | tail -1)"
stamp "lock still held by runner after discriminator: $(lock_probe)"
stamp "post_tree_dirty_lines=$(git status --porcelain --untracked-files=all 9>&- | wc -l)"
[ "$RC_DISC" -eq 0 ] || finish "$RC_DISC"
finish 0
