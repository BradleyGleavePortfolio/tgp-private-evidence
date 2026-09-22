#!/usr/bin/env bash
# S2 composition proof runner v5.5 — S2-RUNNER-V5.5-PREP. Derived (2026-09-22) from FROZEN v5.4
# sha256 3f404479476c5b6a662c946268fd8ed59e3d69c867176431d921aca743604327 (execution/s2-runner54, unchanged). v5.5 delta (FINDINGS_MAP.md):
#   P1 (R54-A-04 / R54B-01) client boundary: CHECKPOINT_DISABLE=1 exported before any step and passed explicitly through the env -i refusal
#      steps; real mode binds the installed Prisma CLI bytes to EXPECT_PRISMA_CLI_SHA (grant05 stamp) and stamps the boundary. Scoped claim:
#      the optional Prisma checkpoint worker (fork detached:true) is excluded; arbitrary future setsid escapes remain OUTSIDE this claim.
#   P2 (R54-A §5 / R54B-02/-05) startup identity: each step leader publishes its own pid into an id file AFTER setsid and BEFORE exec; the
#      runner adopts only that self-published, invocation-created group; no id → the step is never accepted (rc kept if nonzero, else 70) and
#      only the pid is signalled, never a group; groups confirmed empty at quiescence are retired (pid-reuse safety); own pgid never targeted.
#   P3 (R54-A-02) fixture stop/status run as owned groups (same launcher) with a bounded post-exit census inside the cleanup deadline; any
#      member left → halted, counted as survivor → cleanup class 71.
#   P4 (R53-A-02 cont. / R54B-04) the cleanup deadline starts before the FIRST exceptional reap (quiescence failure, anomaly, signal, cleanup).
#   P5 (R54-A-03 / R54B-03) receipts: files are frozen before hashing; SHA256SUMS covers stamp/exit-codes/logs; RECEIPT.txt (post-hash timing,
#      hash status, authoritative final_exit) and SHA256SUMS.outer (hashes SHA256SUMS + RECEIPT.txt) are written afterwards and never mutate a
#      hashed file; a failed/over-deadline receipt forces cleanup class 71 and the process exit follows RECEIPT.txt.
#   Unchanged: pins, steps 10–45, 164+1 harness, first-vs-cleanup registers, quarantine posture, no destroy. v5.4 header follows.
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
R55=$ROOT/execution/s2-runner55
EXPECT_HEAD=d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c   # FROZEN successor r3; no override
EXPECT_LOCK_SHA=62b05b908c835dae51e54af1e553d91f763a070da21813c4419d66e018d61390
EXPECT_PRISMA_CLI_SHA=c2a77456b70e8ba1e640e122824ed694433828a7c0d76ff3db7fc376b4b0e1a0   # P1: installed prisma/build/index.js (6.19.3) recorded by grant05 setup-30; the checkpoint analysis (audits/s2-r54/a) is bound to these bytes
EXPECT_FIXTURE_SHA=9fcc3696a48627b4ed10544cc6c8911e9f13d95fc7acf7ff324770363c24b881   # infra/s2-fixture-r53.sh (REIMPLEMENTATION from 08987e4c; request-03's 6062f4ce is unpreserved); refuse if absent/different
CLOSURE_REF=9742037b153221de565e651ad8ba3b721bc0fb31   # A2 dependency closure was installed at this ancestor
DB=s1_rls_s2comp_r53
NS=s2comp-r53   # must equal the fixture's pinned NS (fixture is hash-pinned above)
PORT=54353      # must equal the fixture's pinned PORT; lane-unique (historical S2 lanes 54321, S5 54325)
unset S2_KEEP_FIXTURE
export CHECKPOINT_DISABLE=1   # P1: inherited by every step (setsid/timeout/bash/env/npx/node pass the environment; consumers use no env -i/-u)
# ---- cleanup budget (seconds). Outer launch is `timeout --foreground -k 60 2100`: TERM at 2100 s, KILL 60 s later.
OUTER_GRACE=60; REAP_TERM_WAIT=10; REAP_KILL_WAIT=5; STOP_BUDGET=20; STOP_KILL=3; STATUS_BUDGET=5; STATUS_KILL=2; SCAN_HASH_ALLOW=3
CLEANUP_BUDGET=50; QUIESCE_WAIT=2; ANOMALY_WAIT=3   # O2: single elapsed deadline for the whole cleanup (< OUTER_GRACE); O1: post-exit group quiescence; isolation-anomaly bound
WORST=$((REAP_TERM_WAIT+REAP_KILL_WAIT+STOP_BUDGET+STOP_KILL+STATUS_BUDGET+STATUS_KILL+SCAN_HASH_ALLOW)); MARGIN=$((OUTER_GRACE-WORST))
STAMP=$(date -u +%Y%m%dT%H%M%SZ)
STUBS=${S2_RUNNER_STUBS-}
if [ -n "$STUBS" ]; then
  LOCK=$STUBS/test-validation.lock; OUT=$R55/runner-selftest-r55/$STAMP
  GUARD_SPEC="bash $STUBS/guard-spec.sh"; FIXTURE="bash $STUBS/fixture.sh"; HARNESS="bash $STUBS/harness.sh"; DISC="bash $STUBS/discriminator.sh"
  REFUSAL_HARNESS="bash $WT/test/release/s1s2-composition.sh"   # real offline refusal path is cheap and DB-free
  OWNED_PAT="^bash $STUBS/|^s2r53-stub-escapee|^bash $WT/test/release/s1s2-composition.sh"
else
  LOCK=$ROOT/execution/test-validation.lock; OUT=$R55/composition-r55/$STAMP
  GUARD_SPEC="bash test/db/s1-harness-guard.spec.sh"; FIXTURE="bash $LANE/infra/s2-fixture-r53.sh"
  HARNESS="bash test/release/s1s2-composition.sh"; DISC="bash test/db/s1-r4-truncate-discriminator.sh"; REFUSAL_HARNESS=$HARNESS
  OWNED_PAT="^bash test/db/s1-harness-guard.spec.sh|^bash test/release/s1s2-composition.sh|^bash test/db/s1-r4-truncate-discriminator.sh|^psql .*(127\.0\.0\.1:$PORT|-p $PORT)|^node .*prisma/build/index.js"
fi
FIXTURE_PAT="^/home/user/pg17/dist/bin/postgres|^postgres: s1-disposable-pg17"
mkdir -p "$OUT"; IDDIR="$OUT/.pgid"; mkdir -p "$IDDIR"   # P2: self-published step identities
S="$OUT/stamp.txt"
stamp(){ echo "$*" | tee -a "$S"; }
lock_probe(){ if flock -n "$LOCK" true 2>/dev/null; then echo FREE; else echo HELD; fi; }
[ -n "$STUBS" ] && stamp "STUB MODE — NOT EVIDENCE (stubs=$STUBS, private lock=$LOCK)"

# ---- result registers. FIRST_EXIT = first failing step / signal; CLEANUP_EXIT = cleanup class; FINAL derived in cleanup, never an unconditional 0.
FIRST_EXIT=unset; CLEANUP_EXIT=unset; FINAL=1; SIGNAL=none; REAP=unchecked; RC_STOP=notrun; SURVIVORS=unchecked; FIXTURE_STARTED=0; CLEANUP_T0=
RC_GUARD=notrun; RC_R20=notrun; RC_R21=notrun; RC_FIXTURE=notrun; RC_COMP=notrun; RC_DISC=notrun
STEP_LABEL=none; STEP_PID=; STEP_PGID=; OWNED_PGIDS=; RETIRED_PGIDS=; DEADLINE_EXCEEDED=no; CLEANUP_DEADLINE=; MY_PGID=$(ps -o pgid= -p $$ | tr -d ' '); PARENT_PGID=$(ps -o pgid= -p $PPID 2>/dev/null | tr -d ' '); IDDIR=
deadline_start(){ [ -n "$CLEANUP_DEADLINE" ] || { CLEANUP_T0=$(date +%s.%N); CLEANUP_DEADLINE=$(( $(now_s) + CLEANUP_BUDGET )); stamp "DEADLINE: cleanup deadline started ($CLEANUP_BUDGET s) reason=$1"; }; }   # P4
now_s(){ date +%s; }
remaining(){ local r; [ -n "$CLEANUP_DEADLINE" ] || { echo 999; return; }; r=$((CLEANUP_DEADLINE-$(now_s))); [ $r -gt 0 ] && echo $r || echo 0; }   # pure (safe in subshells)
deadline_check(){ [ -n "$CLEANUP_DEADLINE" ] && [ "$(now_s)" -ge "$CLEANUP_DEADLINE" ] && DEADLINE_EXCEEDED=yes; :; }   # sets the flag in the main shell
live_groups(){ local g; for g in $OWNED_PGIDS; do { [ "$g" = "$MY_PGID" ] || [ "$g" = "$PARENT_PGID" ]; } && continue; pgrep -g "$g" >/dev/null 2>&1 && echo "$g"; done; }   # P2: never the runner's own group
retire_group(){ local g x rest=; for x in $OWNED_PGIDS; do [ "$x" = "$1" ] || rest="$rest $x"; done; OWNED_PGIDS=$rest; RETIRED_PGIDS="$RETIRED_PGIDS $1"; }   # P2: confirmed-empty groups leave the target set (pid reuse)
finish(){ FIRST_EXIT=$1; exit; }   # EXIT trap → cleanup decides the process exit

# ---- owned-work scan: processes of the live step's group plus anchored owned-work cmdlines (never the fixture server; never platform/unowned processes)
owned_scan(){   # O1: every recorded step group (live members) + anchored owned-work cmdlines; patterns deliberately NOT widened
  { local g; for g in $OWNED_PGIDS; do [ "$g" = "$MY_PGID" ] || pgrep -g "$g" -a 2>/dev/null; done; [ -n "${STEP_PID:-}" ] && kill -0 "$STEP_PID" 2>/dev/null && ps -o pid=,args= -p "$STEP_PID"; pgrep -af "$OWNED_PAT" 2>/dev/null; } | grep -vE "^[0-9]+ (pgrep|grep) " | awk -v me=$$ '$1!=me' | sort -u
}
# poll_until_quiet <max_s>: returns 0 when owned_scan is empty; bounded by max_s AND by the cleanup deadline (O2)
poll_until_quiet(){ local end=$(( $(now_s) + $1 )) lim; while :; do [ -z "$(owned_scan)" ] && return 0; lim=$end; [ -n "$CLEANUP_DEADLINE" ] && [ "$CLEANUP_DEADLINE" -lt "$lim" ] && lim=$CLEANUP_DEADLINE; [ "$(now_s)" -ge "$lim" ] && { deadline_check; return 1; }; sleep 0.1; done; }
# halt_owned_work: TERM the live step's group, bounded reap; then KILL, bounded reap. Sets REAP=ok|FAILED. Signals ONLY the recorded group.
halt_owned_work(){   # O1/O2: targets = every recorded group that still has members (not the leader pid); bounded, deadline-clipped; no blocking wait
  local t0=$(now_s) left groups g
  deadline_start halt   # P4: a reap is exceptional work; the deadline is running before the first signal
  if [ -n "${STEP_PID:-}" ] && kill -0 "$STEP_PID" 2>/dev/null && ! echo " $OWNED_PGIDS " | grep -q " ${STEP_PGID:-none} "; then
    stamp "HALT: in-flight step pid=$STEP_PID has no confirmed exclusive group yet → SIGTERM by pid only (never a group)"; kill -TERM "$STEP_PID" 2>/dev/null   # P2 fallback
  fi
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
  else REAP=ok; stamp "REAP ok: no owned-work process survives (owned groups [$(echo ${OWNED_PGIDS:-none})] retired [$(echo ${RETIRED_PGIDS:-none})], anchored scan)"; fi
  STEP_PID=; STEP_PGID=
}
on_signal(){
  local sig=$1 code
  trap '' TERM INT HUP
  SIGNAL=$sig; deadline_start "signal-$sig"   # P4/O2
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
  # P2: the leader publishes ITS OWN pid (== new session/group id) after setsid and before exec; the runner adopts only that identity
  local idf="$IDDIR/$label.pgid"; rm -f "$idf"
  if [ $inherit = 1 ]; then setsid bash -c 'echo $$ > "$1"; shift; exec timeout --foreground "$@"' _ "$idf" "$bound" "$@" >"$log" 2>&1 &
  else setsid bash -c 'echo $$ > "$1"; shift; exec timeout --foreground "$@"' _ "$idf" "$bound" "$@" >"$log" 2>&1 9>&- & fi
  STEP_PID=$!; STEP_PGID=
  for ((i=0;i<40;i++)); do [ -s "$idf" ] && { STEP_PGID=$(tr -dc '0-9' < "$idf"); break; }; kill -0 "$STEP_PID" 2>/dev/null || { sleep 0.05; [ -s "$idf" ] && STEP_PGID=$(tr -dc '0-9' < "$idf"); break; }; sleep 0.05; done
  [ -n "$STEP_PGID" ] && { [ "$STEP_PGID" = "$MY_PGID" ] || [ "$STEP_PGID" = "$PARENT_PGID" ]; } && { stamp "$label: published identity $STEP_PGID equals the runner's/caller's group → REJECTED (never adopted)"; STEP_PGID=; }   # P2
  if [ "$STEP_PGID" != "$STEP_PID" ]; then
    if kill -0 "$STEP_PID" 2>/dev/null; then
      # identity not published by a live child → not ours to group-signal: TERM/KILL by pid only (bounded), refuse 70, record nothing as a group
      deadline_start anomaly; stamp "$label: IDENTITY ANOMALY pid=$STEP_PID published='${STEP_PGID:-none}' → TERM by pid only (≤${ANOMALY_WAIT}s), refuse (70)"; kill -TERM "$STEP_PID" 2>/dev/null
      for ((i=0;i<ANOMALY_WAIT*10;i++)); do kill -0 "$STEP_PID" 2>/dev/null || break; sleep 0.1; done
      if kill -0 "$STEP_PID" 2>/dev/null; then kill -KILL "$STEP_PID" 2>/dev/null; for ((i=0;i<10;i++)); do kill -0 "$STEP_PID" 2>/dev/null || break; sleep 0.1; done; fi
      if kill -0 "$STEP_PID" 2>/dev/null; then stamp "$label: anomaly pid=$STEP_PID still alive after KILL; listed as survivor, no group adopted"; else wait "$STEP_PID" 2>/dev/null; fi
      STEP_PGID=; finish 70
    fi
    wait "$STEP_PID" 2>/dev/null; local rc0=$?
    stamp "$label: leader pid=$STEP_PID exited rc=$rc0 WITHOUT publishing its identity → stage NOT accepted (unknown acquisition is never certified empty)"
    STEP_PID=; STEP_PGID=; [ "$rc0" -ne 0 ] && finish "$rc0" || finish 70
  fi
  OWNED_PGIDS="$OWNED_PGIDS $STEP_PGID"   # O1/P2: invocation-created, self-published group; retained until confirmed empty
  wait "$STEP_PID"; local rc=$?
  [ "$SIGNAL" != none ] && return 1   # a trapped signal already took over; never record this rc
  # O1: post-exit quiescence — the leader (timeout) exited; the GROUP must be empty before the stage counts as finished
  local end=$(( $(now_s) + QUIESCE_WAIT )) left
  while pgrep -g "$STEP_PGID" >/dev/null 2>&1 && [ "$(now_s)" -lt "$end" ]; do sleep 0.1; done
  left=$(pgrep -g "$STEP_PGID" -a 2>/dev/null | grep -vE "^[0-9]+ (pgrep|grep) ")
  if [ -n "$left" ]; then
    deadline_start "quiescence-$label"   # P4: deadline runs BEFORE the first exceptional reap
    stamp "$label: leader pid=$STEP_PID exited rc=$rc but group $STEP_PGID still has members after ${QUIESCE_WAIT}s → stage NOT accepted; halting the group (owned survivors after step exit):"; echo "$left" | sed 's/^/  member: /' | tee -a "$S"
    halt_owned_work
    [ "$rc" -ne 0 ] && finish "$rc" || finish 70
  fi
  retire_group "$STEP_PGID"   # P2: confirmed empty → no longer a signal target
  STEP_PID=; STEP_PGID=; STEP_LABEL=none
  return $rc
}
# owned_cleanup_cmd <label> <bound> <kill> <log> -- <cmd...> : P3 — cleanup-phase client (fixture stop/status) in its own self-published group,
# bound clipped to the cleanup deadline, followed by a bounded group census; leftovers are halted and counted as survivors. Returns the cmd rc.
owned_cleanup_cmd(){
  local label=$1 bound=$2 kill=$3 log=$4; shift 4; [ "${1-}" = -- ] && shift
  local idf="$IDDIR/$label.pgid" pid pg rc left; rm -f "$idf"
  setsid bash -c 'echo $$ > "$1"; shift; exec timeout --foreground -k "$@"' _ "$idf" "$kill" "$bound" "$@" >"$log" 2>&1 9>&- &
  pid=$!; pg=
  for ((i=0;i<40;i++)); do [ -s "$idf" ] && { pg=$(tr -dc '0-9' < "$idf"); break; }; kill -0 "$pid" 2>/dev/null || { sleep 0.05; [ -s "$idf" ] && pg=$(tr -dc '0-9' < "$idf"); break; }; sleep 0.05; done
  if [ "$pg" = "$pid" ]; then OWNED_PGIDS="$OWNED_PGIDS $pg"; else stamp "$label: cleanup client pid=$pid did not publish its identity (published='${pg:-none}'); pid-only handling"; fi
  wait "$pid" 2>/dev/null; rc=$?
  if [ -n "$pg" ] && [ "$pg" = "$pid" ]; then
    local end=$(( $(now_s) + QUIESCE_WAIT )); while pgrep -g "$pg" >/dev/null 2>&1 && [ "$(now_s)" -lt "$end" ] && [ "$(now_s)" -lt "$CLEANUP_DEADLINE" ]; do sleep 0.1; done
    left=$(pgrep -g "$pg" -a 2>/dev/null | grep -vE "^[0-9]+ (pgrep|grep) ")
    if [ -n "$left" ]; then
      stamp "$label: client exited rc=$rc but its group $pg still has members → SIGTERM/SIGKILL group (bounded), counted as cleanup survivors:"; echo "$left" | sed 's/^/  member: /' | tee -a "$S"
      kill -TERM -- "-$pg" 2>/dev/null; local e2=$(( $(now_s) + 3 )); while pgrep -g "$pg" >/dev/null 2>&1 && [ "$(now_s)" -lt "$e2" ] && [ "$(now_s)" -lt "$CLEANUP_DEADLINE" ]; do sleep 0.1; done
      pgrep -g "$pg" >/dev/null 2>&1 && { kill -KILL -- "-$pg" 2>/dev/null; sleep 0.3; }
      pgrep -g "$pg" >/dev/null 2>&1 && { CLEANUP_SURVIVOR_GROUPS="${CLEANUP_SURVIVOR_GROUPS-} $pg"; stamp "$label: group $pg STILL has members after KILL"; } || { stamp "$label: group $pg census empty after halt (but the client leaked: cleanup failure)"; CLEANUP_LEAK=yes; }
    else stamp "$label: group $pg census empty after exit (owned client fully reaped)"; retire_group "$pg"; fi
  elif kill -0 "$pid" 2>/dev/null; then CLEANUP_LEAK=yes; stamp "$label: pid=$pid alive without identity; survivor"; fi
  return $rc
}
CLEANUP_LEAK=no; CLEANUP_SURVIVOR_GROUPS=

cleanup(){
  trap - EXIT; trap '' TERM INT HUP
  deadline_start cleanup   # P4: no-op if a signal/quiescence failure/anomaly already started it
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
      owned_cleanup_cmd 50-fixture-stop "$sb" "$STOP_KILL" "$OUT/50-fixture-stop.log" -- $FIXTURE stop; RC_STOP=$?   # P3: owned group + census
      stamp "50 fixture-stop exit=$RC_STOP (124=stop bound ${sb}s exceeded; nominal ${STOP_BUDGET}s) $(tail -1 "$OUT/50-fixture-stop.log" 2>/dev/null)"
      rem=$(remaining); if [ "$rem" -ge $((STATUS_BUDGET+STATUS_KILL+SCAN_HASH_ALLOW)) ]; then owned_cleanup_cmd 51-fixture-status "$STATUS_BUDGET" "$STATUS_KILL" "$OUT/51-fixture-status-after-stop.log" -- $FIXTURE status; stamp "51 fixture-status-after-stop: $(head -1 "$OUT/51-fixture-status-after-stop.log")"; else stamp "51 fixture-status SKIPPED (remaining ${rem}s)"; fi
    fi
  fi
  # process evidence: fixture postgres, any owned-work child, any $PORT listener (anchored cmdline starts; see v4.1 false-positive note)
  SURVIVORS=$( { local g; for g in $OWNED_PGIDS $CLEANUP_SURVIVOR_GROUPS; do [ "$g" = "$MY_PGID" ] || pgrep -g "$g" -a 2>/dev/null; done; pgrep -af "$FIXTURE_PAT|$OWNED_PAT" 2>/dev/null | grep -vE "^[0-9]+ (pgrep|grep) " | awk -v me=$$ '$1!=me'; ss -ltnH 2>/dev/null | grep -E ":${PORT}\b"; } | sort -u | sed 's/^/  survivor: /' )
  [ "$CLEANUP_LEAK" = yes ] && { SURVIVORS="$SURVIVORS
  survivor: (cleanup client leaked members; halted — see 50/51 lines)"; }
  if [ -n "$SURVIVORS" ]; then stamp "CLEANUP: surviving processes/listeners after cleanup:"; echo "$SURVIVORS" | tee -a "$S"; SURVIVORS=present; else SURVIVORS=none; stamp "CLEANUP: no surviving fixture/owned-work processes, nothing listening on $PORT"; fi
  if [ "$CLEANUP_EXIT" = unset ]; then
    deadline_check; if { [ "$RC_STOP" != notrun ] && [ "$RC_STOP" != 0 ]; } || [ "$SURVIVORS" = present ] || [ "$DEADLINE_EXCEEDED" = yes ] || [ "$CLEANUP_LEAK" = yes ]; then CLEANUP_EXIT=71; stamp "CLEANUP FAILURE: class 71 (stop_exit=$RC_STOP survivors=$SURVIVORS deadline_exceeded=$DEADLINE_EXCEEDED cleanup_client_leak=$CLEANUP_LEAK)"; else CLEANUP_EXIT=0; fi
  fi
  if [ "$FIRST_EXIT" != 0 ]; then FINAL=$FIRST_EXIT; else FINAL=$CLEANUP_EXIT; fi
  if [ "$REAP" = FAILED ] || [ "$SURVIVORS" = present ]; then stamp "LOCK: held by runner through cleanup ($(lock_probe)); NOT safely handed off — quarantine/survivors; parent must inspect before granting another slot"
  else stamp "LOCK: held by runner through cleanup ($(lock_probe)); released by runner exit; no survivors (probe after exit with check-lock.sh)"; fi
  local dur; dur=$(awk -v a="$CLEANUP_T0" -v b="$(date +%s.%N)" 'BEGIN{printf "%.2f", b-a}')
  stamp "end_utc=$(date -u +%FT%TZ) final_exit=$FINAL first_exit=$FIRST_EXIT cleanup_exit=$CLEANUP_EXIT signal=$SIGNAL reap=$REAP cleanup_seconds=$dur deadline_exceeded=$DEADLINE_EXCEEDED (enforced ${CLEANUP_BUDGET}s, arithmetic worst ${WORST}s, grace ${OUTER_GRACE}s) owned_groups=[$(echo ${OWNED_PGIDS:-none})] retired_groups=[$(echo ${RETIRED_PGIDS:-none})] guard_spec=$RC_GUARD refusal_hosted=$RC_R20 refusal_noconfirm=$RC_R21 fixture=$RC_FIXTURE composition=$RC_COMP s1_r4_discriminator=$RC_DISC fixture_stop=$RC_STOP survivors=$SURVIVORS (pre-receipt; authoritative final in RECEIPT.txt)"
  echo "final=$FINAL first_exit=$FIRST_EXIT cleanup_exit=$CLEANUP_EXIT signal=$SIGNAL reap=$REAP cleanup_seconds=$dur deadline_exceeded=$DEADLINE_EXCEEDED guard_spec=$RC_GUARD refusal_hosted=$RC_R20 refusal_noconfirm=$RC_R21 fixture=$RC_FIXTURE composition=$RC_COMP s1_r4_discriminator=$RC_DISC fixture_stop=$RC_STOP survivors=$SURVIVORS" > "$OUT/exit-codes.txt"
  # P5: stamp.txt and exit-codes.txt are FROZEN from here on. Inner manifest (bounded), then a separate receipt and an additive outer manifest.
  local hrc=0 hb; hb=$(remaining); [ "$hb" -lt 2 ] && hb=2
  ( cd "$OUT" && find . -type f ! -name SHA256SUMS ! -name RECEIPT.txt ! -name SHA256SUMS.outer -print0 | sort -z | timeout --foreground "$hb" xargs -0 sha256sum > SHA256SUMS ) || hrc=$?
  deadline_check; dur=$(awk -v a="$CLEANUP_T0" -v b="$(date +%s.%N)" 'BEGIN{printf "%.2f", b-a}')
  local receipt=ok; [ "$hrc" = 0 ] && [ -s "$OUT/SHA256SUMS" ] || receipt="FAILED(hash_rc=$hrc)"; [ "$DEADLINE_EXCEEDED" = yes ] && receipt="${receipt};deadline_exceeded_after_hash"
  if [ "$receipt" != ok ] && [ "$CLEANUP_EXIT" = 0 ]; then CLEANUP_EXIT=71; fi     # a missing/failed/over-deadline receipt is never cleanup_exit=0
  if [ "$FIRST_EXIT" != 0 ]; then FINAL=$FIRST_EXIT; else FINAL=$CLEANUP_EXIT; fi
  { echo "receipt_status=$receipt"; echo "final_exit=$FINAL first_exit=$FIRST_EXIT cleanup_exit=$CLEANUP_EXIT"; echo "cleanup_seconds_total=$dur deadline_exceeded=$DEADLINE_EXCEEDED hash_rc=$hrc inner_manifest_sha256=$(sha256sum "$OUT/SHA256SUMS" 2>/dev/null | cut -c1-64)"; echo "utc=$(date -u +%FT%TZ)"; } > "$OUT/RECEIPT.txt"
  ( cd "$OUT" && sha256sum SHA256SUMS RECEIPT.txt > SHA256SUMS.outer ) || true
  echo "RECEIPT: $(head -2 "$OUT/RECEIPT.txt" | tr '\n' ' ')"
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
  [ "$(sha256sum node_modules/prisma/build/index.js | cut -c1-64)" = "$EXPECT_PRISMA_CLI_SHA" ] || { stamp "REFUSED: installed prisma CLI bytes != $EXPECT_PRISMA_CLI_SHA (checkpoint analysis not bound)"; finish 70; }   # P1
  stamp "client_boundary: CHECKPOINT_DISABLE=${CHECKPOINT_DISABLE-unset} exported before all steps (env -i steps carry it explicitly); prisma CLI bytes bound; scoped claim: optional Prisma checkpoint worker (detached fork) excluded — arbitrary future setsid escapes are OUTSIDE this claim"
  command -v psql >/dev/null || { stamp "REFUSED: psql missing (setup-10 not done)"; finish 70; }
  [ -x /home/user/pg17/dist/bin/postgres ] || { stamp "REFUSED: PG17 dist missing (setup-20 not done)"; finish 70; }
  [ "$(sha256sum "$LANE/infra/s2-fixture-r53.sh" 2>/dev/null | cut -c1-64)" = "$EXPECT_FIXTURE_SHA" ] || { stamp "REFUSED: fixture $LANE/infra/s2-fixture-r53.sh absent or != pinned $EXPECT_FIXTURE_SHA"; finish 70; }
  grep -q "^PORT=$PORT;" "$LANE/infra/s2-fixture-r53.sh" && grep -q "^NS=$NS$" "$LANE/infra/s2-fixture-r53.sh" || { stamp "REFUSED: fixture PORT/NS literals do not match runner PORT=$PORT NS=$NS"; finish 70; }
else
  stamp "STUB MODE: toolchain/node_modules/PG17/fixture-hash prechecks SKIPPED (not evidence); head/dirty/lockfile/closure checks above were REAL"
  stamp "client_boundary: CHECKPOINT_DISABLE=${CHECKPOINT_DISABLE-unset} exported (stubs echo what they inherit)"
fi

# ---- 1) S1 offline guard spec at the composed head (no DB)
run_step 10-guard-spec 120 "$OUT/10-guard-spec.log" -- $GUARD_SPEC; RC_GUARD=$?
stamp "10 guard-spec exit=$RC_GUARD $(tail -1 "$OUT/10-guard-spec.log")"
[ "$RC_GUARD" -eq 0 ] || finish "$RC_GUARD"

# ---- 2) harness-level offline refusals BEFORE any server exists on the port (must exit 64, no DB contact)
run_step 20-refusal-hosted 120 "$OUT/20-refusal-hosted.log" -- env -i PATH="$PATH" HOME="$HOME" CHECKPOINT_DISABLE=1 S1_PG_SUPER_URL='postgresql://postgres:pw@db.example.supabase.co:5432/postgres' S1_PG_PORT=5432 \
  S1_PG_DISPOSABLE_CONFIRM="DESTROY-db.example.supabase.co:5432/$DB,${DB}_lock" $REFUSAL_HARNESS "$DB"; RC_R20=$?
stamp "20 refusal-hosted exit=$RC_R20 (expect 64) $(tail -1 "$OUT/20-refusal-hosted.log")"; [ "$RC_R20" -eq 64 ] || finish 70
run_step 21-refusal-noconfirm 120 "$OUT/21-refusal-noconfirm.log" -- env -i PATH="$PATH" HOME="$HOME" CHECKPOINT_DISABLE=1 S1_PG_SUPER_URL="postgresql://s1_super:s1_local_synthetic@127.0.0.1:$PORT/postgres" S1_PG_PORT=$PORT \
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
export S1_PRISMA_CLI="$WT/node_modules/prisma/build/index.js" S1_PROOF_LOG="$OUT/s1-r4/s1-r4-discriminator.detail.log" S1_R4_LOCK_HOLDER="run-composition-r55-v5.5 pid=$$ fd9=$LOCK"
run_step 45-s1-r4-discriminator 300 "$OUT/s1-r4/s1-r4-discriminator.log" -- $DISC "$DB"; RC_DISC=$?
stamp "45 s1-r4-discriminator exit=$RC_DISC $(grep -E 'passed|FAIL' "$OUT/s1-r4/s1-r4-discriminator.log" | tail -1)"
stamp "lock still held by runner after discriminator: $(lock_probe)"
stamp "post_tree_dirty_lines=$(git status --porcelain --untracked-files=all 9>&- | wc -l)"
[ "$RC_DISC" -eq 0 ] || finish "$RC_DISC"
finish 0
