#!/usr/bin/env bash
# PROPOSED, NOT EXECUTED (S2-V60, 2026-09-23). Successor of execution/e8d546f9/s2-v59/controls-proposed/run-controls-v59.sh
# (924768a25c644da980f320d331d1d767fc202343f03260177c62fddb4b839706, immutable) — v60 delta bound ONLY to the ACTUAL V59 control failure S2-V59-K3-PLACEMENT
# (execution/e8d546f9/s2-v59-control-result, set k aggregate 1 at 2026-09-23T01:37:09Z; FINDINGS_MAP_V60.md):
#   K3-PLACEMENT  v59 K3 placed its "TERM during step 40" by an ELAPSED-TIME GUESS: the enclosure's outer bound (`run_runner … 3` → `timeout … 3`) fired at +3 s,
#                 but on this host the unchanged runner reaches step 40 only ≈3.6 s after enclosure start (steps 20/21 are the REAL harness refusals, ≈1.2 s
#                 each: K2 acks 20→21→30→40 at +0.65/+1.82/+3.01/+3.57 s; the K3 TERM landed at 01:37:08 while step 30 was active). The runner's own
#                 behaviour under that TERM was clean (143, reap ok, cleanup 0, lock held); the control's placement, not the runner, missed.
#                 v60: the K3 TERM is sent ONLY after the runner's OWN attributable evidence that step 40 is ACTIVE — its adoption ack
#                 `<out>/.pgid/40-composition.pgid.ack` (runner L155, written before the leader execs) AND the harness workload line
#                 `stub harness … mode=sleep` in `<out>/40-composition.log` — by a controller-listed, identity-validated controller of exactly the N5b
#                 seam-controller shape (ctrl_arm/ctrl_book latch; runner pid taken from the runner's `lock acquired pid=` stamp and validated to be in
#                 the CURRENT enclosure authority before the single `kill -TERM <pid>`; a timed-out wait sends NOTHING and STRIKEs). Consequences that
#                 are NOT weakenings: the enclosure bound becomes a fail-safe (12 s) instead of the trigger, so the outer status expected from `timeout`
#                 is the runner's own 143 (TERM delivered by the controller) rather than 124 — the SAME status/shape N5b already asserts — and one
#                 assertion is ADDED: the runner's stamp must say the SIGTERM arrived during step '40-composition' (placement confirmed, not inferred).
#                 Every K3 composition/stop/ordering/lock/survivor predicate is unchanged. K3's declared max 12 → 18 (bound 12 + grace 5 + bookkeeping).
#   Lanes: driver/stubs/K1/results in execution/e8d546f9/s2-v60 ($R60); runner BYTE-IDENTICAL to v5.7 (efa273c7…), pinned lane execution/op88/s2-v57 ($RLANE, parent-accepted).
#   NOT changed (reported for the parent BEFORE any expansion, FINDINGS_MAP_V60.md §necessity): K4 (`KA=20 run_runner … 3`, escape mode needs step 40 active)
#                 and N4b (`KA=8 run_runner … 4`, asserts TERM during step '40-composition') place their TERM by the SAME elapsed-time guess (3 s / 4 s vs ≈3.6 s).
# ---- v59 header retained below for provenance ----
# PROPOSED, NOT EXECUTED (S2-V59, 2026-09-23). Successor of execution/e8d546f9/s2-v58/controls-proposed/run-controls-v58.sh
# (1e2e32eb15a7d045dd0f398d96997a65eea09a21575be74387dad5cc9cd277ef, immutable) — v59 delta bound ONLY to frozen audit S2-V58-A01 (FINDINGS_MAP_V59.md):
#   A01(V58)  a g-kind controller child (N6 holder: `setsid flock … &`) is a plain direct child of this driver until it executes setsid; v58's g-kind
#             booking/resolution knew it ONLY as g<pid> (a session that does not exist yet), so a cancellation before the setsid transition discarded the
#             live child, which could then create its session and take the lane lock after the census. v59 keeps the direct child's identity-bound
#             authority from the fork on: g-kind controllers are recorded as BOTH p<pid>:<starttime> (pid-only authority — bounded TERM/KILL of that
#             exact process while no owned session exists) AND g<pid> (validated session-member cleanup once the session exists). controller_cleanup's
#             existing TERM → re-evaluate → KILL → census covers the transition window (a session formed after the pid TERM is found by the g record
#             at re-evaluation). The caller's group is never a target (p = one pid; g = members with sid == pid only). No other change.
#   Lanes: driver/stubs/K1/results in execution/e8d546f9/s2-v59 ($R59); runner BYTE-IDENTICAL to v5.7 (efa273c7…), pinned lane execution/op88/s2-v57 ($RLANE, parent-accepted).
# ---- v58 header retained below for provenance ----
# PROPOSED, NOT EXECUTED (S2-V58, 2026-09-23). Successor of execution/op88/s2-v57/controls-proposed/run-controls-v57.sh
# (698bbb175c768707aef41b52b1b98ba2450791771ac63a34af4bb8d9654c637f, immutable) — v58 delta bound ONLY to frozen audit S2-V57-A (A01..A05, FINDINGS_MAP_V58.md):
#   A01(V57)  the watchdog and the finish alarm capture THEIR OWN shell pid (BASHPID read in that shell) BEFORE any command substitution and pass it to
#             wd_parent_ok <self>; v57 expanded $BASHPID inside $(ps …), i.e. a nested subshell whose parent is never the driver → every guard failed closed.
#   A02(V57)  N1's decoy is booked with the generation-bearing p<pid>:<starttime> record through the controller mechanism (ctrl_arm/ctrl_book) and is ALSO
#             owned work (the N1 `owned_cleanup` still ends exactly it); v57 wrote a bare numeric record that rec_alive could never expand.
#   A03(V57)  the UNCHANGED v5.3.1 predecessor opens ITS private lock at $S2_RUNNER_STUBS/test-validation.lock (predecessor L52/L164): that path is now an
#             enumerated write (set new1 only, CONTROL_REQUEST_14), asserted from the predecessor stamp, and probed at handoff (HELD → 4).
#   A04(V57)  log-imported pids are promoted to signal authority ONLY with producer-published start identity (`spawned|escapee pid=<n> start=<ticks>`, emitted by
#             the stub that owned the child at spawn) that still equals the live /proc starttime; numbers without provenance (QUARANTINE survivors, legacy lines)
#             are reported in HIST (skip-unprovable) and never recorded. Live/post-T0/shape filters retained as additional rejections only.
#   A05(V57)  controller acquisition is interruption-safe: ctrl_arm latches BEFORE the spawn, ctrl_book books immediately after `&` (before any readiness wait/ack),
#             resolve_pending_controller in finish() lists a spawned-but-unbooked controller child so controller_cleanup ends it (N1/N4 decoys, N5b seam controller,
#             N6 holder session, C1 sleeper). N4's decoy stays OUT of owned work (its owned_cleanup survival assertions are unchanged).
#   Lanes: driver/stubs/K1/results live in execution/e8d546f9/s2-v58 ($R58). The runner is BYTE-IDENTICAL to v5.7 (efa273c7…) and keeps its own pinned lane
#          execution/op88/s2-v57 (runner L97) for stub-mode outputs (runner-selftest-r57/) and its private lock (runtime/) → $RLANE below; no runner edit.
# ---- v57 header retained below for provenance ----
# PROPOSED, NOT EXECUTED (OP88-S2-V57, 2026-09-22). Successor of execution/op88/s2-v56/controls-proposed/run-controls-v56.sh
# (10c48b69f63cbc6795a6818aef5ce0aa5e7ac76a82f24af9d6dfce2ca1997de5, immutable) — v57 delta bound to the frozen V5.6 audits (FINDINGS_MAP_V57.md):
#   A01/D-01/D-02  K1 bound to THIS lane's byte-identical k1 copy ($R57); `trap on_exit EXIT` routes any abnormal termination (e.g. nounset) into bounded owner
#                  cleanup + publication (aggregate 4); the watchdog re-checks that its parent is still this driver before EVERY signal (no signal to a reused pid).
#   A02            result manifest excludes SHA256SUMS* and CONTROLS_RECEIPT.txt and the completed manifest is re-verified inside the same bound; the runner's
#                  inner manifest is additionally checked for manifest/temporary entries.
#   A03            registration + CURRENT publication are CHECKED (written and read back) BEFORE the ack; a leader spawned but not yet booked is latched
#                  (PENDING_ENC) and resolved on cancellation/finally (published → registered + group TERM; else bounded pid-only halt; survivor → 4).
#   A04            identity-bound records: p<pid>:<starttime> validated against /proc, g<pgid> members validated by session id; log-imported pids are accepted
#                  only if live, started after this driver and of the owned-work shape; the watchdog owns its sleeper (trap kills `$!`) and stop_watchdog
#                  TERMs the shell FIRST, reaps it, then confirms the final sleeper — census into the gate.
#   A05            no unconditional wait on an unreaped child; ONE bounded publication tail (manifest, verification, receipt write+check); post-publication
#                  elapsed check; a closed finish alarm (own sleeper, parent re-check) bounds the unenclosed tail — residue → 4, never 0.
#   A06            controller registry (decoy, lock holder, seam controller, cancel sleeper) with a finally path on every exit; acknowledged negative-control
#                  states (decoy alive-in-group, holder ready-under-lock, seam actually seen) — timed-out synchronization is refused, never inferred;
#                  N4b asserts the TERM reached step 40; N5b validates the target pid's group against CURRENT (D-04); N7 exercises the KILL escalation
#                  (TERM-ignoring workload); N8 exercises driver cancellation (wdcancel).
#   A07/D-05       lane-private lock under $R57/runtime/ (enumerated write set); set→workload map in CONTROL_REQUEST_12.   D-03: W1 gate slack 3 s.
#   Sets: k(6) new1(5) new2(1) neg(3) neg2(6: N4,N5a,N5b,N6,N7,N8) probe(1) wdtest(1) wdcancel(1). Lane: execution/op88/s2-v57; runner-selftest-r57/.
# ---- v56 header retained below for provenance ----
# Original v55 header follows.
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
# No DB, no network, no canonical lock (lane-private $LANE_LOCK), no product/source writes. 'pre' controls run the FROZEN
# v5.3.1 bytes read-only to reproduce the finding; their outputs land under s2-setup-prep/runner-selftest-r531/ (additive; the 37 frozen files
# are untouched). One invocation = one set. CTL_BUDGET default 60.
set -u
R60=/home/user/workspace/execution/e8d546f9/s2-v60; RUNNER=$R60/run-composition-r57-v5.7-when-granted.sh; STUBS=$R60/controls-proposed/stubs
RLANE=/home/user/workspace/execution/op88/s2-v57   # the UNCHANGED v5.7 runner's pinned lane (runner L97): its stub-mode outputs (runner-selftest-r57/) and private lock (runtime/) resolve HERE, not under $R60 (parent-accepted dual-lane arrangement)
PRE_RUNNER=/home/user/workspace/execution/s2-setup-prep/run-composition-r53-v5.3.1-when-granted.sh   # frozen v5.3.1 fb0d7ce4…, read-only (restored per upstream-prereqs-2)
SET=${CTL_SET:-k}; BUDGET=${CTL_BUDGET:-60}; RESERVE=8; INJECT_FAIL=${CTL_INJECT_FAIL:-0}
CTL=$R60/controls-proposed/results/$SET-$(date -u +%Y%m%dT%H%M%SZ)-$$; mkdir -p "$CTL" || exit 2; R=$CTL/CONTROLS_RESULT.txt; OWNED=$CTL/owned-pids.txt; : > "$OWNED" || exit 2; HIST=$CTL/owned-history.txt; : > "$HIST" || exit 2
CTRL=$CTL/controller-pids.txt; : > "$CTRL" || exit 2   # A06: controller resources (decoy/holder/seam controller/cancel sleeper) — separate registry with its own finally path
MY_PGID=$(ps -o pgid= -p $$ | tr -d ' '); PARENT_PGID=$(ps -o pgid= -p $PPID 2>/dev/null | tr -d ' '); ENCL=$CTL/.encl; mkdir -p "$ENCL" || exit 2
CURF=$ENCL/CURRENT; : > "$CURF" || exit 2   # E7: the single current validated enclosure authority (one pgid or empty); the ONLY watchdog target source
mkdir -p "$RLANE/runtime"; LANE_LOCK=$RLANE/runtime/test-validation.lock   # A07: lane-private lock in the enumerated runtime/ write set (same path the stub-mode runner uses: runner L115 under ITS lane)
PRE_LOCK=$STUBS/test-validation.lock   # A03(V57): the UNCHANGED v5.3.1 predecessor (L52) opens ITS private lock at $S2_RUNNER_STUBS/test-validation.lock — enumerated write (new1 only, CONTROL_REQUEST_18), asserted per run, probed at handoff
T0=$(date +%s.%N); T0_EPOCH=${T0%.*}; STRIKE=0; RUN=0; PLANNED=0; WATCHDOG=; WD_CENSUS=; DRIVER_PID=$$; CUR=none; FINISHED=0; PENDING_ENC=; ENC_PGID=; RC=; O=
PENDING_CTRL=; PENDING_CTRL_KIND=p; PENDING_CTRL_OWNED=; PENDING_CTRL_PREV=   # A05(V57): controller-acquisition latch (armed before a controller spawn, released by ctrl_book, resolved in finish)
WD_TERM_AT=$((BUDGET-RESERVE)); WD_KILL_AT=$((BUDGET-RESERVE/2)); WD_CANCEL_AT=$((WD_KILL_AT+2))   # E7 escalation schedule (s from T0); 2 s between KILL and driver cancellation lets a control that observed the KILL finish normally
ACK_TICKS=150   # E8: 3 s leader ack wait (×0.02 s); the driver's identity poll is ≤ 2 s
LEADER=': s2r57-enclosure-leader; echo $$ > "$1" || exit 70; i=0; while [ ! -e "$1.ack" ]; do i=$((i+1)); [ "$i" -gt "$2" ] && exit 70; sleep 0.02; done; shift 2; exec timeout --foreground -k "$@"'   # E8/A03: same contract as the runner; marker makes an unreaped leader scannable
say(){ echo "$*" | tee -a "$R"; }
now(){ awk -v a="$T0" -v b="$(date +%s.%N)" 'BEGIN{printf "%.2f", b-a}'; }
left(){ awk -v a="$T0" -v b="$(date +%s.%N)" -v B="$BUDGET" 'BEGIN{printf "%d", B-(b-a)}'; }
PAT="^s2r53-stub-escapee|^timeout --foreground [0-9]+ bash $STUBS/harness.sh|^bash $STUBS/harness.sh|^bash $STUBS/fixture.sh|^bash $RUNNER|^bash $PRE_RUNNER|^bash -c : s2r57-(step|enclosure)-leader;"
detect(){ pgrep -f "$PAT" 2>/dev/null | awk -v me=$$ '$1!=me'; }     # detection only — never a kill list
# ---- identity-bound ownership records (A03/A04): p<pid>:<starttime> (validated by /proc starttime) and g<pgid> (members validated by session id == pgid).
# A numeric id alone is never authority: a reused pid/pgid fails the identity check and is dropped, never signalled.
pstart(){ cut -d')' -f2 /proc/"$1"/stat 2>/dev/null | awk '{print $20}'; }   # field 22 of /proc/<pid>/stat (clock ticks since boot)
pstart_epoch(){ local st bt tck; st=$(pstart "$1"); [ -n "$st" ] || return 1; bt=$(awk '/^btime/{print $2}' /proc/stat); tck=$(getconf CLK_TCK 2>/dev/null || echo 100); echo $(( bt + st / tck )); }
pid_rec(){ local st; st=$(pstart "$1"); [ -n "$st" ] && echo "p$1:$st"; }   # identity record for a live pid (empty if gone)
rec_alive(){ # rec_alive <record> : echoes the live, identity-validated pid(s) of a record, nothing otherwise
  local x=$1 pid st g m; case $x in
    p*) pid=${x#p}; pid=${pid%%:*}; st=${x##*:}; [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null && [ "$(pstart "$pid")" = "$st" ] && echo "$pid";;
    g*) g=${x#g}; { [ "$g" = "$MY_PGID" ] || [ "$g" = "$PARENT_PGID" ]; } && return 0; for m in $(pgrep -g "$g" 2>/dev/null); do [ "$(ps -o sid= -p "$m" 2>/dev/null | tr -d ' ')" = "$g" ] && echo "$m"; done;;
  esac; :; }
record(){ # record <rec…> : CHECKED registry write (A03) — returns 1 if any write fails; HIST is a receipt, never a kill source
  local p ok=0; for p in "$@"; do [ -n "$p" ] || continue; echo "$p" >> "$OWNED" || ok=1; echo "$(date -u +%T) $p" >> "$HIST" || ok=1; grep -qxF -- "$p" "$OWNED" || ok=1; done; return $ok; }
record_from_run(){ # record_from_run <outdir> : owned groups stamped by the runner; spawned/escapee pids ONLY with producer-published start identity (A04(V57): `pid=<n> start=<ticks>` written by the stub that owned the child at spawn) that still equals the live /proc starttime; then live/started-after-this-driver/owned-work-shape as additional rejections. QUARANTINE survivor numbers carry no acquisition identity → HIST only, never authority.
  local O=$1 g p st ls se; [ -d "$O" ] || return 0
  for g in $(grep -o 'owned_groups=\[[0-9 ]*\]' "$O/stamp.txt" 2>/dev/null | tr -dc '0-9 \n'); do record "g$g" || STRIKE=1; done
  for p in $(grep -ohE '(spawned|escapee) pid=[0-9]+( start=[0-9]+)?' "$O"/*.log 2>/dev/null | sed -E 's/^(spawned|escapee) pid=//; s/ start=/:/' | sort -u); do
    st=${p#*:}; [ "$st" = "$p" ] && st=; p=${p%%:*}
    [ -n "$st" ] || { echo "$(date -u +%T) skip-unprovable $p (log line carries no producer start identity; number never promoted)" >> "$HIST"; continue; }
    kill -0 "$p" 2>/dev/null || { echo "$(date -u +%T) skip-dead $p" >> "$HIST"; continue; }
    ls=$(pstart "$p"); [ "$ls" = "$st" ] || { echo "$(date -u +%T) skip-identity $p (live start ${ls:-none} != producer start $st: number reused by another process; never signalled)" >> "$HIST"; continue; }
    se=$(pstart_epoch "$p") || continue; [ "$se" -ge "$T0_EPOCH" ] || { echo "$(date -u +%T) skip-predates-run $p" >> "$HIST"; continue; }
    ps -o args= -p "$p" 2>/dev/null | grep -qE '^(sleep [0-9.]+|s2r53-stub-escapee( |$))' || { echo "$(date -u +%T) skip-shape $p" >> "$HIST"; continue; }
    record "p$p:$st" || STRIKE=1; done
  for p in $(grep -oE 'survivor: +[0-9]+' "$O/QUARANTINE.txt" 2>/dev/null | grep -oE '[0-9]+$' | sort -u); do echo "$(date -u +%T) skip-unprovable $p (QUARANTINE survivor: runner-reported number without acquisition identity; report only)" >> "$HIST"; done
  # E1: NO adoption of a pgid read from a child log (v54 adopted the harness's inherited group here)
}
prune_groups(){ # E4/E7/A04: keep only records with live identity-validated members; clear CURRENT if its group is gone (history retained in $HIST)
  local x keep=; while read -r x; do [ -n "$x" ] || continue; [ -n "$(rec_alive "$x")" ] && keep="$keep$x\n"; done < "$OWNED"; printf "%b" "$keep" > "$OWNED"
  local c; c=$(tr -dc '0-9' < "$CURF" 2>/dev/null); [ -n "$c" ] && [ -z "$(rec_alive "g$c")" ] && : > "$CURF"; :; }
bounded_pid_halt(){ # bounded_pid_halt <pid> <secs> : TERM, bounded wait, KILL, short wait; returns 0 if gone, 1 if STILL alive (caller must not wait on it)
  local pid=$1 e=$(( $(date +%s) + $2 )); kill -TERM "$pid" 2>/dev/null; while kill -0 "$pid" 2>/dev/null && [ "$(date +%s)" -lt "$e" ]; do sleep 0.1; done
  kill -0 "$pid" 2>/dev/null && { kill -KILL "$pid" 2>/dev/null; sleep 0.2; }; kill -0 "$pid" 2>/dev/null && return 1; return 0; }
enclose(){ # enclose <name> <bound> <grace> <cmd...> : exclusive self-published group under the fail-closed leader contract (E1/E3/E8/A03); sets ENC_PGID, RC
  local name=$1 bound=$2 grace=$3; shift 3; local idf="$ENCL/$name.pgid" pid pg= i; rm -f "$idf" "$idf.ack"
  PENDING_ENC=$idf; ENC_PGID=   # A03 latch: armed before the spawn; resolve_pending_enclosure() (cancel/finally) recovers the child from $!
  setsid bash -c "$LEADER" _ "$idf" "$ACK_TICKS" "$grace" "$bound" "$@" & pid=$!
  for ((i=0;i<40;i++)); do [ -f "$idf" ] && [ -s "$idf" ] && { pg=$(tr -dc '0-9' < "$idf" 2>/dev/null); break; }; kill -0 "$pid" 2>/dev/null || { sleep 0.05; [ -f "$idf" ] && [ -s "$idf" ] && pg=$(tr -dc '0-9' < "$idf" 2>/dev/null); break; }; sleep 0.05; done   # regular non-empty file only
  if [ -n "$pg" ] && [ "$pg" = "$pid" ] && [ "$pg" != "$MY_PGID" ] && [ "$pg" != "$PARENT_PGID" ]; then
    # A03: registration AND current-authority publication are CHECKED (written, read back) BEFORE the ack; any failure → no ack, group halted, STRIKE
    if record "g$pg" && printf '%s\n' "$pg" > "$CURF" && [ "$(tr -dc '0-9' < "$CURF" 2>/dev/null)" = "$pg" ] && : > "$idf.ack" 2>/dev/null; then ENC_PGID=$pg
    else say "  ENCLOSURE REGISTRATION/ACK FAILED for $name (group $pg) → no ack (leader self-exits 70 without exec); group TERM; STRIKE"; STRIKE=1; ENC_PGID=$pg; kill -TERM -- "-$pg" 2>/dev/null; fi
  else
    say "  ENCLOSURE IDENTITY NOT CONFIRMED for $name (pid=$pid published='${pg:-none}') → STRIKE; bounded TERM/KILL by pid only (never a group); unacked leader never exec'd"; STRIKE=1; record "$(pid_rec "$pid")" || true
    if kill -0 "$pid" 2>/dev/null && ! bounded_pid_halt "$pid" 3; then say "  enclosure $name leader pid=$pid STILL ALIVE after KILL → not waited on; owned survivor"; PENDING_ENC=; RC=leak; return 0; fi   # A05: no unconditional wait on an unreaped child
  fi
  PENDING_ENC=; wait "$pid"; RC=$?   # confirmed enclosures end under their own timeout (TERM bound + kill grace) — the wait is bounded by construction
  if [ -n "$ENC_PGID" ]; then
    if [ -n "$(rec_alive "g$ENC_PGID")" ]; then say "  enclosure $name (group $ENC_PGID) still has members after exit rc=$RC: [$(pgrep -g "$ENC_PGID" -a | tr '\n' ';')] → retained as owned survivors (authority kept until cleaned)"
    else : > "$CURF"; fi   # E7: retired at confirmed-empty census → no longer the watchdog target; prune_groups drops the g record
  fi
}
resolve_pending_enclosure(){ # A03: cancellation/finally path — a leader spawned but not yet booked (PENDING_ENC set) is resolved: published → registered + group TERM; else bounded pid-only halt
  [ -n "$PENDING_ENC" ] || return 0; local idf=$PENDING_ENC lastbg=${!-} pg= i; PENDING_ENC=
  [ -n "$lastbg" ] && kill -0 "$lastbg" 2>/dev/null || return 0
  for ((i=0;i<10;i++)); do [ -f "$idf" ] && [ -s "$idf" ] && { pg=$(tr -dc '0-9' < "$idf" 2>/dev/null); break; }; kill -0 "$lastbg" 2>/dev/null || return 0; sleep 0.05; done   # the leader publishes within ms
  if [ -n "$pg" ] && [ "$pg" = "$lastbg" ] && [ "$pg" != "$MY_PGID" ] && [ "$pg" != "$PARENT_PGID" ]; then record "g$pg" || true; say "  PENDING enclosure leader pid=$lastbg had a published identity $pg → registered and TERMed as a group (never acked → never exec'd)"; kill -TERM -- "-$pg" 2>/dev/null
  else say "  PENDING enclosure leader pid=$lastbg without published identity → bounded pid-only TERM/KILL"; record "$(pid_rec "$lastbg")" || true; bounded_pid_halt "$lastbg" 3 || say "  pending leader pid=$lastbg STILL ALIVE after KILL → owned survivor"; fi
}
ctrl_record(){ record "$@"; echo "$*" >> "$CTRL" || STRIKE=1; }   # A06: controller resources are BOTH owned (cleanup) and separately listed (finally census)
ctrl_arm(){ PENDING_CTRL_PREV=${!-}; PENDING_CTRL_KIND=${2:-p}; PENDING_CTRL_OWNED=${3:-}; PENDING_CTRL=$1; }   # A05(V57): ctrl_arm <name> [p|g] [owned] — latch armed BEFORE the controller spawn (name set LAST, after the pre-spawn $! is captured, so a trap inside ctrl_arm never resolves an older child); p = p<pid>:<start> record, g = p<pid>:<start> AND g<pid> (A01(V58): direct-child identity plus session record); 'owned' also registers as owned work
ctrl_recs(){ # ctrl_recs <pid> : the controller record(s) for a live child of the armed kind — p: p<pid>:<start>; g (A01(V58)): p<pid>:<start> (direct-child identity from the fork on, pid-only authority before the child's setsid) AND g<pid> (validated session members once established); empty if the child is already gone
  local prec; prec=$(pid_rec "$1"); [ -n "$prec" ] || return 0; echo "$prec"; [ "$PENDING_CTRL_KIND" = g ] && echo "g$1"; :; }
ctrl_book(){ # ctrl_book <pid> : CHECKED booking of the latched controller child into CTRL (+OWNED when armed 'owned'), immediately after `&` and before any readiness wait; releases the latch; 1 (+STRIKE) if the identity is already gone or a write failed
  local rec ok=1 recs; recs=$(ctrl_recs "$1")
  if [ -n "$recs" ]; then ok=0; for rec in $recs; do [ "$PENDING_CTRL_OWNED" = owned ] && { record "$rec" || STRIKE=1; }; echo "$rec" >> "$CTRL" 2>/dev/null; grep -qxF -- "$rec" "$CTRL" || ok=1; done; fi
  PENDING_CTRL=; [ "$ok" = 0 ] || STRIKE=1; return $ok; }
resolve_pending_controller(){ # A05(V57)/A01(V58): cancellation/finally path — a controller child spawned (new $!) but not yet booked is listed with its full record set so controller_cleanup ends it (pid-only while pre-session, group members once a session exists); never waited on, never the caller's group
  [ -n "$PENDING_CTRL" ] || return 0; local name=$PENDING_CTRL lastbg=${!-} rec recs=; PENDING_CTRL=
  [ -n "$lastbg" ] && [ "$lastbg" != "$PENDING_CTRL_PREV" ] || return 0   # no new background child since arming → nothing was spawned
  recs=$(ctrl_recs "$lastbg"); [ -n "$recs" ] || return 0
  for rec in $recs; do echo "$rec" >> "$CTRL" || true; done; say "  PENDING controller $name pid=$lastbg (spawned, not yet booked) → listed for controller cleanup [$(echo $recs)]"; }
controller_cleanup(){ # A06: finally path for controller resources (decoy, lock holder, seam controller, cancel sleeper): TERM → bounded → KILL; census reported
  local x pids= p; while read -r x; do [ -n "$x" ] && pids="$pids $(rec_alive "$x" | tr '\n' ' ')"; done < "$CTRL"; pids=$(echo $pids)
  if [ -n "$pids" ]; then say "  controller cleanup: TERM [$pids]"; kill -TERM $pids 2>/dev/null; sleep 0.5; pids=; while read -r x; do [ -n "$x" ] && pids="$pids $(rec_alive "$x" | tr '\n' ' ')"; done < "$CTRL"; pids=$(echo $pids)
    [ -n "$pids" ] && { say "  controller cleanup: KILL [$pids]"; kill -KILL $pids 2>/dev/null; sleep 0.3; }; fi
  CTRL_CENSUS=; while read -r x; do [ -n "$x" ] && CTRL_CENSUS="$CTRL_CENSUS $(rec_alive "$x" | tr '\n' ' ')"; done < "$CTRL"; CTRL_CENSUS=$(echo $CTRL_CENSUS)
  say "  controllers ended: census_after=[${CTRL_CENSUS:-empty}]"; }
owned_live(){ # expand records to live identity-validated pids; exclude pre-snapshot pids, self, own/parent groups (E1/E4/A04)
  local x; { while read -r x; do [ -n "$x" ] && rec_alive "$x"; done < "$OWNED"; } | sort -un | grep -vxF -f "$CTL/pre-snapshot.txt" | awk -v me=$$ -v pp=$PPID '$1!=me && $1!=pp'
}
owned_cleanup(){ local pids; pids=$(owned_live | tr '\n' ' ')
  if [ -n "$pids" ]; then say "  owned cleanup: TERM recorded pids [$pids] $(ps -o pid=,pgid=,cmd= -p $(echo $pids | tr ' ' ',') 2>/dev/null | tr '\n' ';')"; kill -TERM $pids 2>/dev/null; sleep 0.5
    pids=$(owned_live | tr '\n' ' '); [ -n "$pids" ] && { say "  owned cleanup: KILL recorded pids [$pids]"; kill -KILL $pids 2>/dev/null; sleep 0.3; }; fi
  say "  recorded-owned alive after cleanup: [$(owned_live | tr '\n' ' ')]; pattern-detected (report only): [$(detect | tr '\n' ' ')]"; prune_groups; }
stop_watchdog(){ # E7/A04: closed stop — TERM the watchdog shell FIRST (its own trap kills its current sleeper), reap it, THEN read the final sleeper pid and confirm; census feeds the gate
  [ -n "$WATCHDOG" ] || return 0; local s e
  kill -TERM "$WATCHDOG" 2>/dev/null; wait "$WATCHDOG" 2>/dev/null
  s=$(tr -dc '0-9' < "$ENCL/wd.sleeper" 2>/dev/null); [ -n "$s" ] && kill -TERM "$s" 2>/dev/null   # idempotent: the shell's trap normally already ended it
  e=$(( $(date +%s)+2 )); while { kill -0 "$WATCHDOG" 2>/dev/null || { [ -n "$s" ] && kill -0 "$s" 2>/dev/null; }; } && [ "$(date +%s)" -lt "$e" ]; do sleep 0.05; done
  WD_CENSUS=; kill -0 "$WATCHDOG" 2>/dev/null && WD_CENSUS="$WD_CENSUS $WATCHDOG"; [ -n "$s" ] && kill -0 "$s" 2>/dev/null && WD_CENSUS="$WD_CENSUS $s"
  say "  watchdog stopped: shell=$WATCHDOG sleeper=${s:-none} census_after=[${WD_CENSUS:-empty}]"; WATCHDOG=; }
publish_results(){ # publish_results <code> : E10/A02/A05 — ONE bounded kill-after tail: manifest (temporaries excluded) + completed-manifest verification + CONTROLS_RECEIPT.txt (hashed by nothing, write checked); classified code in PUB_CODE
  local code=$1 prc=0 pb pub=ok; pb=$(left); [ "$pb" -gt 5 ] && pb=5; [ "$pb" -lt 2 ] && pb=2   # a 2 s failure-reporting reserve even past the deadline (the deadline is reported separately)
  timeout -k 1 "$pb" bash -c 'cd "$1" || exit 10
    find . -type f ! -name "SHA256SUMS*" ! -name CONTROLS_RECEIPT.txt -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS.tmp && mv -f SHA256SUMS.tmp SHA256SUMS || exit 11
    [ -s SHA256SUMS ] && sha256sum -c --quiet SHA256SUMS || exit 12
    { echo "publication_status=ok"; echo "aggregate_exit=$2"; echo "set=$3 controls_run=$4 strike=$5 wall=$6s budget=$7s"; echo "rule: process exit == aggregate_exit unless the finish alarm left residue (then 4); a failed publication is never 0"; echo "utc=$(date -u +%FT%TZ)"; } > CONTROLS_RECEIPT.txt || exit 13
    grep -q "^aggregate_exit=$2\$" CONTROLS_RECEIPT.txt || exit 14' _ "$CTL" "$code" "$SET" "$RUN/$PLANNED" "$STRIKE" "$(now)" "$BUDGET" 2>/dev/null || prc=$?
  rm -f "$CTL/SHA256SUMS.tmp"
  case $prc in 0) pub=ok;; 10) pub=resultdir_unreachable;; 11) pub=manifest_write_failed;; 12) pub=manifest_verify_failed;; 13) pub=receipt_write_failed;; 14) pub=receipt_content_mismatch;; 124|137) pub="publication_timeout(rc=$prc)";; *) pub="publication_failed(rc=$prc)";; esac
  [ "$pub" = ok ] || { [ "$code" = 0 ] && code=4; { echo "publication_status=$pub"; echo "aggregate_exit=$code"; } > "$CTL/CONTROLS_RECEIPT.txt" 2>/dev/null || true; }   # failure reporting (best effort, unhashed)
  echo "CONTROLS_RECEIPT: publication_status=$pub aggregate_exit=$code (classified after publication)"; PUB_CODE=$code; }
start_finish_alarm(){ # A05: total completion bound for the unenclosed finish tail — closed ownership (own trap kills its sleeper; parent identity re-checked before the KILL)
  local pb; pb=$(left); [ "$pb" -lt 3 ] && pb=3; pb=$((pb+2))
  ( FA_SELF=$BASHPID; trap 'kill $! 2>/dev/null; exit 0' TERM; sleep "$pb" & echo $! > "$ENCL/fin.sleeper"; wait $!   # A01(V57): own pid captured in THIS shell, never inside a $(…)
    wd_parent_ok "$FA_SELF" || exit 0
    echo "FINISH ALARM: driver tail exceeded ${pb}s after finish start → KILL driver pid=$DRIVER_PID (publication incomplete by construction; never exit 0)" | tee -a "$R"; kill -KILL "$DRIVER_PID" 2>/dev/null ) & FIN_ALARM=$!; }
stop_finish_alarm(){ [ -n "${FIN_ALARM:-}" ] || return 0; local s; kill -TERM "$FIN_ALARM" 2>/dev/null; wait "$FIN_ALARM" 2>/dev/null; s=$(tr -dc '0-9' < "$ENCL/fin.sleeper" 2>/dev/null); [ -n "$s" ] && kill -TERM "$s" 2>/dev/null; sleep 0.1
  FIN_CENSUS=; kill -0 "$FIN_ALARM" 2>/dev/null && FIN_CENSUS="$FIN_CENSUS $FIN_ALARM"; [ -n "$s" ] && kill -0 "$s" 2>/dev/null && FIN_CENSUS="$FIN_CENSUS $s"; echo "  finish alarm stopped: shell=$FIN_ALARM sleeper=${s:-none} census_after=[${FIN_CENSUS:-empty}]"; FIN_ALARM=; }
finish(){ # finish <code> — E3/E7/E10/A05/A06: assertions passing is not a handoff; survivors / non-free lane lock / new pattern matches / watchdog or controller residue force 4
  local code=$1; trap ':' TERM; FINISHED=1   # no-op handler (not SIG_IGN): a late TERM cannot abort cleanup; children keep default TERM so bounds stay TERM-then-KILL
  resolve_pending_enclosure; resolve_pending_controller; owned_cleanup; controller_cleanup; stop_watchdog; start_finish_alarm
  [ "$code" = 0 ] && { [ "$RUN" -lt "$PLANNED" ] || [ "$STRIKE" = 1 ]; } && code=1
  local surv newpat lockst prelockst; surv=$(owned_live | tr '\n' ' '); newpat=$(detect | grep -vxF -f "$CTL/pre-snapshot.txt" | tr '\n' ' '); lockst=$(flock -n "$LANE_LOCK" true && echo FREE || echo HELD)
  prelockst=$(if [ -e "$PRE_LOCK" ]; then flock -n "$PRE_LOCK" true && echo FREE || echo HELD; else echo absent; fi)   # A03(V57): the predecessor's private lock is part of the handoff (probe only an existing file — never created here)
  if [ -n "$surv" ] || [ -n "$newpat" ] || [ "$lockst" != FREE ] || [ "$prelockst" = HELD ] || [ -n "$WD_CENSUS" ] || [ -n "${CTRL_CENSUS:-}" ]; then say "HANDOFF FAILURE: owned survivors [$surv] new pattern matches [$newpat] lane lock $lockst predecessor lock $prelockst watchdog census [${WD_CENSUS:-empty}] controller census [${CTRL_CENSUS:-empty}] → aggregate 4 (no further set may start)"; code=4; fi
  [ "$(left)" -lt 0 ] && { say "AGGREGATE DEADLINE EXCEEDED before publication ($(now)s > ${BUDGET}s)"; [ "$code" = 0 ] && code=3; }
  say "SET=$SET controls_run=$RUN/$PLANNED strike=$STRIKE wall=$(now)s of ${BUDGET}s (reserve ${RESERVE}s) aggregate_exit=$code (pre-publication); lane lock: $lockst; predecessor lock: $prelockst; current_authority_file=[$(tr -dc '0-9' < "$CURF" 2>/dev/null)] (must be empty); canonical lock file: $([ -e /home/user/workspace/execution/test-validation.lock ] && echo exists || echo absent) (never opened)"
  publish_results "$code"; code=$PUB_CODE
  [ "$(left)" -lt 0 ] && [ "$code" = 0 ] && { echo "AGGREGATE DEADLINE EXCEEDED after publication ($(now)s > ${BUDGET}s) → 3"; code=3; }   # A05: post-publication elapsed check
  stop_finish_alarm; [ -n "${FIN_CENSUS:-}" ] && { echo "finish alarm residue [$FIN_CENSUS] → 4"; code=4; }
  exit "$code"; }
abort(){ trap ':' TERM; FINISHED=1; stop_watchdog; say "ABORT (precondition, no ownership acquired, NO signals sent to anything but this driver's own watchdog shell/sleeper): $*"; say "SET=$SET controls_run=0/$PLANNED aggregate_exit=2 wall=$(now)s"; publish_results 2; exit 2; }
on_cancel(){ trap ':' TERM; say "DEADLINE CANCELLATION: SIGTERM received at t=$(now)s during control ${CUR:-none} (watchdog escalation or external) → aggregate 3; pending enclosure, owned work, controllers, watchdog, publication all run inside the reserve"; finish 3; }   # E7/A03/A06
on_exit(){ local st=$?; [ "$FINISHED" = 1 ] && exit "$st"; trap ':' TERM; say "ABNORMAL EXIT (status $st before finish — e.g. an unbound variable) → bounded owner cleanup, aggregate 4"; finish 4; }   # A01/D-02: abnormal termination still enters bounded owner cleanup
trap on_cancel TERM; trap on_exit EXIT
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
  enclose "$CUR" "$(clip "$bound")" "${KA:-5}" env "$@" bash "$runner" >"$CTL/$CUR.driver.log" 2>&1   # E1/E3/E8: exclusive fail-closed enclosure; KA = kill-after grace
  O=$(new_out "$parent" "$before"); record_from_run "$O"; say "  $CUR runner exit=$RC out=${O:-NONE} enclosure_group=${ENC_PGID:-unconfirmed}"; [ -n "$O" ] || { say "  FAIL: no new output dir"; STRIKE=1; O=/nonexistent; }
  [ -d "$O" ] || return 0
  if [ "$runner" = "$RUNNER" ]; then   # E9: receipt/publication predicates apply to the SUCCESSOR format only (v5.7: RECEIPT.txt, SHA256SUMS.outer, PUBLICATION.txt)
    expect "$O/RECEIPT.txt" '^receipt_status=ok$' "$CUR receipt ok (frozen manifest, post-hash receipt)"
    expect "$O/PUBLICATION.txt" '^publication_status=ok deadline_exceeded_at_publication=no$' "$CUR publication ok (receipt + outer manifest written, verified, inside deadline)"
    ( cd "$O" && sha256sum -c --quiet SHA256SUMS.outer && sha256sum -c --quiet SHA256SUMS ) 2>/dev/null && say "  PASS: $CUR outer+inner manifests re-verify (immutable publication)" || { say "  FAIL: $CUR manifest re-verification"; STRIKE=1; }
    grep -q 'SHA256SUMS' "$O/SHA256SUMS" 2>/dev/null && { say "  FAIL: $CUR inner manifest inventories a manifest/temporary (A02)"; STRIKE=1; } || say "  PASS: $CUR inner manifest lists no manifest/temporary entry (A02)"
  else   # E9: frozen v5.3.1 predecessor writes exit-codes.txt + inner SHA256SUMS only (predecessor L156–L157); never require RECEIPT.txt from it
    expect "$O/exit-codes.txt" '^final=[0-9]+ first_exit=' "$CUR predecessor exit-codes present (v5.3.1 format)"
    expect "$O/stamp.txt" "^lock acquired pid=[0-9]+ fd9=$PRE_LOCK " "$CUR predecessor private lock opened at the enumerated stubs path (A03(V57): predecessor L52/L164, write set of CONTROL_REQUEST_14)"
    [ -s "$O/SHA256SUMS" ] && say "  PASS: $CUR predecessor inner manifest present (v5.3.1 format; NOT re-verified: v5.3.1 has the known post-hash stamp mutation, R54-A-03/R54B-03)" || { say "  FAIL: $CUR predecessor inner manifest missing"; STRIKE=1; }
  fi; }
OUT57=$RLANE/runner-selftest-r57; OUT531=/home/user/workspace/execution/s2-setup-prep/runner-selftest-r531

say "S2-V60 controls set=$SET start $(date -u +%FT%TZ) budget=${BUDGET}s results=$CTL pid=$$ pgid=$MY_PGID timeout_impl=$(timeout --version 2>/dev/null | head -1) runner_sha256=$(sha256sum "$RUNNER" | cut -c1-64) pre_runner_sha256=$(sha256sum "$PRE_RUNNER" | cut -c1-64) stubs=$(cd "$STUBS" && sha256sum *.sh | cut -c1-16 | tr '\n' ' ')"
detect > "$CTL/pre-snapshot.txt"
say "pre-snapshot pattern matches (never signalled): [$(tr '\n' ' ' < "$CTL/pre-snapshot.txt")]"
[ -s "$CTL/pre-snapshot.txt" ] && abort "pre-existing pattern matches [$(tr '\n' ' ' < "$CTL/pre-snapshot.txt")] — not ours; refusing without cleanup"
[ -f "$RUNNER" ] && [ -f "$PRE_RUNNER" ] && [ -d "$STUBS" ] || abort "runner/pre-runner/stubs missing"
# E3/E7/A04: aggregate watchdog — reads ONLY the current validated authority ($CURF), never historical id files; OWNS its sleeper (trap kills `$!` on TERM,
# pid published for the stop census); re-checks that its parent is still THIS driver before every signal (no signal to a reused pid after an abnormal exit).
# Escalation: TERM(current enclosure)@BUDGET-RESERVE → KILL(current enclosure)@BUDGET-RESERVE/2 → TERM(driver)@+1 s so finish() runs inside the reserve.
wd_target(){ local g; g=$(tr -dc '0-9' < "$CURF" 2>/dev/null); [ -n "$g" ] && [ "$g" != "$MY_PGID" ] && [ "$g" != "$PARENT_PGID" ] && [ -n "$(rec_alive "g$g")" ] && echo "$g"; }
wd_parent_ok(){ [ "$(ps -o ppid= -p "$1" 2>/dev/null | tr -d ' ')" = "$DRIVER_PID" ]; }   # A01(V57): wd_parent_ok <self> — <self> is the watchdog/alarm shell's OWN pid captured in that shell ($BASHPID inside the $(…) would name the substitution subshell, whose parent is never the driver)
( WD_SELF=$BASHPID; trap 'kill $! 2>/dev/null; exit 0' TERM; trap - EXIT   # A01(V57): stable self identity captured first
  sleep "$WD_TERM_AT" & echo $! > "$ENCL/wd.sleeper"; wait $!; wd_parent_ok "$WD_SELF" || exit 0
  g=$(wd_target); echo "WATCHDOG fired at $(date -u +%FT%TZ) (t=${WD_TERM_AT}s) current_authority=${g:-none} → TERM group" | tee -a "$R"; [ -n "$g" ] && kill -TERM -- "-$g" 2>/dev/null
  sleep $(( WD_KILL_AT - WD_TERM_AT )) & echo $! > "$ENCL/wd.sleeper"; wait $!; wd_parent_ok "$WD_SELF" || exit 0
  g=$(wd_target); if [ -n "$g" ]; then echo "WATCHDOG escalation at t=${WD_KILL_AT}s: current_authority=$g still live → KILL group" | tee -a "$R"; kill -KILL -- "-$g" 2>/dev/null; else echo "WATCHDOG escalation at t=${WD_KILL_AT}s: no live current authority → nothing to KILL" | tee -a "$R"; fi
  sleep $(( WD_CANCEL_AT - WD_KILL_AT )) & echo $! > "$ENCL/wd.sleeper"; wait $!; wd_parent_ok "$WD_SELF" || exit 0
  echo "WATCHDOG: cancelling the driver (TERM pid=$DRIVER_PID, parent identity re-checked) at t=${WD_CANCEL_AT}s — reserve kept for owned cleanup/publication" | tee -a "$R"; kill -TERM "$DRIVER_PID" 2>/dev/null ) & WATCHDOG=$!
case $SET in k) PLANNED=6;; new1) PLANNED=5;; new2) PLANNED=1;; neg) PLANNED=3;; neg2) PLANNED=6;; probe) PLANNED=1;; wdtest) PLANNED=1;; wdcancel) PLANNED=1;; *) abort "unknown CTL_SET=$SET";; esac
[ "$INJECT_FAIL" = 1 ] && say "NEGATIVE MODE: an impossible expectation is injected after the first control (expected aggregate exit 1)"

if [ "$SET" = k ]; then
  # ---------- K1 predecessor MECHANISM counterexample (v5.1 shape; unchanged from s2-runner53)
  need K1-predecessor-mechanism 8; K1=$CTL/k1; mkdir -p "$K1"
  enclose k1 2 5 bash "$R60/controls-proposed/k1-predecessor-mechanism.sh" "$K1" "$STUBS" >"$K1/driver.log" 2>&1; rc=$RC; record_from_run "$K1"; say "  K1 enclosure group=${ENC_PGID:-unconfirmed} (exclusive; predecessor internals unchanged)"
  say "  K1 outer exit=$rc; stamp:"; sed 's/^/    /' "$K1/stamp.txt" | tee -a "$R"; surv=$(owned_live | tr '\n' ' ')
  say "  K1 recorded-owned processes alive after runner exit: [$surv]"
  [ "$rc" = 124 ] && say "  PASS: outer timeout fired (124)" || { say "  FAIL: outer exit $rc"; STRIKE=1; }
  [ -f "$K1/50-fixture-stop.log" ] && say "  PASS(counterexample): fixture stop ran under a live step-40 child" || { say "  FAIL: fixture stop log missing"; STRIKE=1; }
  [ -n "$surv" ] && say "  PASS(counterexample): step-40 child tree survived the runner" || { say "  FAIL: no survivor observed"; STRIKE=1; }
  [ "$INJECT_FAIL" = 1 ] && expect "$K1/stamp.txt" '^THIS-LINE-CANNOT-EXIST' "N2 injected impossible expectation"
  owned_cleanup
  # ---------- K2 stub success
  need K2-stub-success 15; CUR=k2; run_runner "$RUNNER" "$OUT57" 15 S2_RUNNER_STUBS=$STUBS
  expect "$O/exit-codes.txt" '^final=0 first_exit=0 cleanup_exit=0 signal=none reap=ok' "K2 result registers"
  expect "$O/exit-codes.txt" 'deadline_exceeded=no guard_spec=0 refusal_hosted=64 refusal_noconfirm=64 fixture=0 composition=0 s1_r4_discriminator=0 fixture_stop=0 survivors=none' "K2 all steps reached, refusals 64/64, stop 0, deadline kept"
  expect "$O/stamp.txt" 'STUB MODE — NOT EVIDENCE' "K2 stub banner"
  expect "$O/stamp.txt" 'head=d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c tree=c0ab87d4dc584b2a7ccad53db16fa551b93fe359 dirty_lines=0' "K2 real head/tree/clean check"
  expect "$O/stamp.txt" 'REAP ok: no owned-work process survives \(owned groups \[none\] retired \[[0-9 ]+\], anchored scan\)' "K2 every step group retired (active set empty) before fixture stop (O1/P2, E9)"
  expect "$O/stamp.txt" 'owned_groups=\[none\] retired_groups=\[[0-9 ]+\]' "K2 end line: no active group remains, retired list present (active-vs-retired authority)"
  [ "$(ls "$O"/.pgid/*.ack 2>/dev/null | wc -l)" -eq 10 ] && say "  PASS: K2 every leader was acked before exec (10 ack files: 10,20,21,30,31,32,40,45,50,51)" || { say "  FAIL: K2 ack files missing ($(ls "$O"/.pgid 2>/dev/null | tr '\n' ' '))"; STRIKE=1; }
  expect "$O/20-refusal-hosted.log" 'S1-GUARD REFUSED URL_HOST' "K2 real harness offline refusal (hosted URL)"
  expect "$O/21-refusal-noconfirm.log" 'S1-GUARD REFUSED CONFIRM' "K2 real harness offline refusal (no confirm)"
  expect "$O/30-fixture-init.log" "fd9=$LANE_LOCK" "K2 fixture init inherited fd 9 (private lock)"
  expect "$O/40-composition.log" 'fd9=closed' "K2 harness saw fd 9 closed"
  expect "$O/40-composition.log" 'CHECKPOINT_DISABLE=1' "K2 harness inherited CHECKPOINT_DISABLE=1 (E6)"
  expect "$O/s1-r4/s1-r4-discriminator.log" 'CHECKPOINT_DISABLE=1' "K2 discriminator inherited CHECKPOINT_DISABLE=1 (E6)"
  expect "$O/50-fixture-stop.log" 'CHECKPOINT_DISABLE=1' "K2 cleanup client inherited CHECKPOINT_DISABLE=1 (E6)"
  expect "$O/stamp.txt" '^50-fixture-stop: group [0-9]+ census empty after exit' "K2 owned stop client fully reaped (P3)"
  [ "$RC" = 0 ] || { say "  FAIL: exit $RC"; STRIKE=1; }; owned_cleanup
  # ---------- K3 TERM during step 40 (v60 K3-PLACEMENT: evidence-placed, not elapsed-time-placed). A controller-listed step-40 controller (N5b shape) waits
  # (bounded 8 s, 0.1 s poll) for the runner's OWN evidence that step 40 is ACTIVE — the adoption ack `.pgid/40-composition.pgid.ack` (runner L155) AND the
  # harness workload line `stub harness … mode=sleep` in 40-composition.log — then validates that the runner pid (its `lock acquired pid=` stamp) is in the
  # CURRENT enclosure authority and sends ONE TERM to that pid. A timed-out wait sends nothing → STRIKE (refused timed-out synchronization). The enclosure
  # bound (12 s) is now only the fail-safe; the interruption is expected from the controller, so the outer status is the runner's own 143 (as N5b).
  need K3-term-during-step40 18; CUR=k3; before=$(ls -1d "$OUT57"/*/ 2>/dev/null); ctrl_arm k3-step40-controller p owned   # A05: latched acquisition (p<pid>:<start>, owned + controller-listed)
  ( for ((i=0;i<80;i++)); do d=$(comm -13 <(echo "$before") <(ls -1d "$OUT57"/*/ 2>/dev/null) | tail -1); [ -n "$d" ] && [ -e "$d/.pgid/40-composition.pgid.ack" ] && grep -q '^stub harness .* mode=sleep' "$d/40-composition.log" 2>/dev/null && break; sleep 0.1; done
    if [ "$i" -ge 80 ]; then echo "step-40 controller: ACTIVE STEP 40 NOT SEEN within 8 s (ack + harness line) → no signal sent (refused timed-out synchronization)"; exit 1; fi
    p=$(sed -n 's/^lock acquired pid=\([0-9]*\) .*/\1/p' "$d/stamp.txt" 2>/dev/null | head -1); cur=$(tr -dc '0-9' < "$CURF" 2>/dev/null); ppg=$(ps -o pgid= -p "$p" 2>/dev/null | tr -d ' ')
    if [ -n "$p" ] && [ -n "$cur" ] && [ "$ppg" = "$cur" ]; then echo "step-40 controller: step 40 ACTIVE after $((i/10)).$((i%10))s in $d (adoption ack + harness workload line); runner pid=$p validated in CURRENT enclosure $cur → TERM"; kill -TERM "$p"; exit 0
    else echo "step-40 controller: runner pid=${p:-NONE} pgid=${ppg:-NONE} NOT in CURRENT enclosure ${cur:-NONE} → no signal sent"; exit 2; fi ) >"$CTL/k3.step40-controller.log" 2>&1 & K3C=$!; ctrl_book "$K3C" || say "  FAIL: step-40 controller pid=$K3C could not be booked"
  run_runner "$RUNNER" "$OUT57" 12 STUB_HARNESS_MODE=sleep STUB_HARNESS_SLEEP=30 S2_RUNNER_STUBS=$STUBS; wait "$K3C" 2>/dev/null; k3c=$?; sed 's/^/    /' "$CTL/k3.step40-controller.log" | tee -a "$R"
  [ "$k3c" = 0 ] && say "  PASS: step-40 controller saw the ACTIVE step and signalled a validated pid" || { say "  FAIL: step-40 controller rc=$k3c (no valid signal was sent; any interruption came from the outer bound)"; STRIKE=1; }
  surv=$(owned_live | tr '\n' ' '); say "  K3 recorded-owned alive after runner exit: [$surv]"
  expect "$O/stamp.txt" "^SIGNAL SIGTERM .* during step '40-composition'" "K3 TERM arrived during the ACTIVE composition step (placement confirmed by the runner's stamp, not inferred)"
  expect "$O/exit-codes.txt" '^final=143 first_exit=143 cleanup_exit=0 signal=TERM reap=ok' "K3 signal exit recorded as first exit; cleanup class 0"
  expect "$O/exit-codes.txt" 'composition=interrupted\(TERM\) s1_r4_discriminator=notrun fixture_stop=0 survivors=none' "K3 step interrupted, stop 0, no survivors"
  [ -z "$surv" ] && say "  PASS: no step-40 child survives" || { say "  FAIL: survivors [$surv]"; STRIKE=1; }
  o1=$(grep -n '^SIGNAL SIGTERM' "$O/stamp.txt" | cut -d: -f1 | head -1); o2=$(grep -n '^REAP ok' "$O/stamp.txt" | cut -d: -f1 | head -1); o3=$(grep -n '^50 fixture-stop' "$O/stamp.txt" | cut -d: -f1 | head -1)
  [ -n "$o1" ] && [ -n "$o2" ] && [ -n "$o3" ] && [ "$o1" -lt "$o2" ] && [ "$o2" -lt "$o3" ] && say "  PASS: ordering SIGNAL($o1) < REAP ok($o2) < fixture stop($o3)" || { say "  FAIL: ordering signal=$o1 reap=$o2 stop=$o3"; STRIKE=1; }
  expect "$O/stamp.txt" 'LOCK: held by runner through cleanup \(HELD\)' "K3 lock held through cleanup"
  say "  K3 timing: $(grep -o 'cleanup_seconds=[0-9.]*' "$O/exit-codes.txt") $(grep -o 'cleanup_seconds_total=[0-9.]*' "$O/RECEIPT.txt")"
  [ "$RC" = 143 ] || { say "  FAIL: outer exit $RC (expected 143: the TERM is delivered to the runner pid by its validated controller; 124 would mean the 12 s fail-safe bound fired instead)"; STRIKE=1; }; owned_cleanup
  # ---------- K4 escapee → quarantine 72
  need K4-escapee-quarantine 25; CUR=k4; KA=20 run_runner "$RUNNER" "$OUT57" 3 STUB_HARNESS_MODE=escape STUB_HARNESS_SLEEP=40 S2_RUNNER_STUBS=$STUBS
  say "  K4 recorded-owned alive after runner exit (expected: the quarantined escapee): [$(owned_live | tr '\n' ' ')]"
  expect "$O/exit-codes.txt" '^final=143 first_exit=143 cleanup_exit=72 signal=TERM reap=FAILED' "K4 quarantine class 72 separate from first exit 143"
  expect "$O/exit-codes.txt" 'fixture_stop=REFUSED survivors=present' "K4 fixture stop REFUSED, survivors present"
  expect "$O/QUARANTINE.txt" 's2r53-stub-escapee' "K4 QUARANTINE.txt lists the escapee"
  expect "$O/stamp.txt" 'LOCK: held by runner through cleanup \(HELD\); NOT safely handed off' "K4 lock not declared handed off"
  [ -f "$O/50-fixture-stop.log" ] && { say "  FAIL: fixture stop ran after failed reap"; STRIKE=1; } || say "  PASS: no fixture stop after failed reap"
  say "  K4 timing: $(grep -o 'cleanup_seconds=[0-9.]*' "$O/exit-codes.txt") (reap 10+5 s)"
  [ "$RC" = 124 ] || { say "  FAIL: outer exit $RC"; STRIKE=1; }; owned_cleanup
  # ---------- K5 normal-path stop failure → 71
  need K5-stop-failure 15; CUR=k5; run_runner "$RUNNER" "$OUT57" 15 STUB_STOP_RC=1 S2_RUNNER_STUBS=$STUBS
  expect "$O/exit-codes.txt" '^final=71 first_exit=0 cleanup_exit=71 signal=none reap=ok' "K5 cleanup class 71 with first exit 0 preserved"
  expect "$O/exit-codes.txt" 'fixture_stop=1 survivors=none' "K5 stop exit 1 recorded"
  [ "$RC" = 71 ] || { say "  FAIL: exit $RC"; STRIKE=1; }; owned_cleanup
  # ---------- K6 first failing step preserved
  need K6-first-failure 10; CUR=k6; run_runner "$RUNNER" "$OUT57" 10 STUB_GUARD_RC=3 S2_RUNNER_STUBS=$STUBS
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
  need K7-v5.5-leader-exits-first 6; CUR=k7; run_runner "$RUNNER" "$OUT57" 6 STUB_HARNESS_MODE=leader-exit STUB_HARNESS_SLEEP=30 S2_RUNNER_STUBS=$STUBS
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
  need K8-v5.5-inner-timeout-grandchild 8; CUR=k8; run_runner "$RUNNER" "$OUT57" 8 STUB_HARNESS_MODE=grandchild STUB_HARNESS_SLEEP=30 STUB_STEP40_BOUND=2 S2_RUNNER_STUBS=$STUBS
  sp=$(grep -ohE 'spawned pid=[0-9]+' "$O"/40-composition.log 2>/dev/null | grep -oE '[0-9]+$'); say "  K8 spawned grandchild pid=[$sp] alive after runner exit: $(alive "$sp" && echo YES || echo no)"
  expect "$O/stamp.txt" '^40-composition: leader pid=[0-9]+ exited rc=124 but group [0-9]+ still has members' "K8 inner 124 with a live group member detected (O1/B01)"
  expect "$O/exit-codes.txt" '^final=124 first_exit=124 cleanup_exit=0 signal=none reap=ok' "K8 first exit 124 preserved, cleanup clean"
  expect "$O/exit-codes.txt" 'fixture_stop=0 survivors=none' "K8 fixture stopped after reap, no survivors"
  alive "$sp" && { say "  FAIL: grandchild still alive"; STRIKE=1; } || say "  PASS: grandchild gone"
  [ "$RC" = 124 ] || { say "  FAIL: exit $RC"; STRIKE=1; }; owned_cleanup
  # ---------- K9: unnamed setsid escapee (own session, cmd 'sleep') — DOCUMENTED BOUNDARY of v5.4 (no OS-level boundary): expected to be missed
  need K9-v5.5-unnamed-setsid-escape-boundary 6; CUR=k9; run_runner "$RUNNER" "$OUT57" 6 STUB_HARNESS_MODE=escape-unnamed STUB_HARNESS_SLEEP=30 S2_RUNNER_STUBS=$STUBS
  sp=$(grep -ohE 'spawned pid=[0-9]+' "$O"/40-composition.log 2>/dev/null | grep -oE '[0-9]+$'); say "  K9 escaped unnamed pid=[$sp] alive after runner exit: $(alive "$sp" && echo YES || echo no)"
  expect "$O/exit-codes.txt" '^final=0 first_exit=0 cleanup_exit=0 signal=none reap=ok' "K9 v5.4 reports success (predicted: the escapee is invisible to group+pattern ownership)"
  alive "$sp" && say "  BOUNDARY CONFIRMED (not an ownership pass): unnamed setsid escapee survives undetected — see FINDINGS_MAP K9/OS-boundary proposal" || { say "  FAIL: prediction wrong — escapee did not survive (investigate before trusting the boundary statement)"; STRIKE=1; }
  owned_cleanup

elif [ "$SET" = new2 ]; then
  # ---------- K10: hanging fixture stop → clipped stop bound, 124, cleanup class 71, first exit 0 preserved, deadline kept
  need K10-v5.5-hanging-stop 40; CUR=k10; run_runner "$RUNNER" "$OUT57" 35 STUB_STOP_HANG=60 S2_RUNNER_STUBS=$STUBS
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
  ctrl_arm n1-decoy p owned; bash -c 'exec -a s2r53-stub-escapee sleep 25' </dev/null >/dev/null 2>&1 & DECOY=$!; ctrl_book "$DECOY" || say "  FAIL: decoy pid=$DECOY could not be booked (identity gone or registry write failed)"; sleep 0.3   # A02/A05(V57): p<pid>:<start> record, owned AND controller-listed, latched across the spawn
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

elif [ "$SET" = probe ]; then
  # ---------- P1: one trivial enclosed control (N6's inner target; exercises the fail-closed enclosure on a fast command)
  need P1-probe 4; CUR=p1; enclose p1 "$(clip 2)" 1 sleep 0.2; rc=$RC
  [ "$rc" = 0 ] && [ -n "$ENC_PGID" ] && say "  PASS: probe enclosure rc=0 group=$ENC_PGID (registered+current+acked before exec)" || { say "  FAIL: probe rc=$rc group=${ENC_PGID:-unconfirmed}"; STRIKE=1; }
  [ -s "$CURF" ] && { say "  FAIL: current authority not cleared after retirement"; STRIKE=1; } || say "  PASS: current authority cleared at retirement"
  owned_cleanup

elif [ "$SET" = wdtest ]; then
  # ---------- W1: watchdog escalation self-test (N7's inner target). The enclosed workload IGNORES TERM (`trap "" TERM; exec sleep`) and its enclosure
  # kill-grace (10 s) lies beyond the watchdog's KILL time, so ONLY the watchdog's KILL escalation can end it: TERM@WD_TERM_AT (ignored) → KILL@WD_KILL_AT.
  # Deterministic by schedule, independent of the timeout implementation's TERM-forwarding behaviour (either the enclosure leader exits at TERM and the
  # group survives, or it waits — both leave a live current authority for the KILL stage). The driver polls the authority until WD_KILL_AT+3 s.
  need W1-watchdog-escalation $((BUDGET-RESERVE-3)); CUR=w1; t1=$(now); enclose w1 "$BUDGET" 10 bash -c 'trap "" TERM; exec sleep "$1"' _ "$BUDGET"; rc=$RC
  say "  W1 enclosure leader returned rc=$rc at t=$(now)s (TERM scheduled at ${WD_TERM_AT}s, KILL at ${WD_KILL_AT}s)"
  while [ -n "$(tr -dc '0-9' < "$CURF" 2>/dev/null)" ] && [ -n "$(rec_alive "g${ENC_PGID:-0}")" ] && awk -v n="$(now)" -v k="$WD_KILL_AT" 'BEGIN{exit !(n < k+3)}'; do sleep 0.2; done
  [ -n "$(rec_alive "g${ENC_PGID:-0}")" ] && : || : > "$CURF"; t2=$(now); el=$(awk -v a="$t1" -v b="$t2" 'BEGIN{printf "%.1f", b-a}'); say "  W1 group ${ENC_PGID:-none} empty at t=${t2}s (elapsed ${el}s)"
  [ "$rc" != 0 ] && say "  PASS: enclosure ended nonzero by the watchdog" || { say "  FAIL: enclosure rc=0"; STRIKE=1; }
  grep -q "^WATCHDOG fired .* current_authority=${ENC_PGID:-NONE} " "$R" && say "  PASS: watchdog TERM targeted the CURRENT validated authority $ENC_PGID" || { say "  FAIL: watchdog TERM line/target mismatch"; STRIKE=1; }
  grep -q "^WATCHDOG escalation at t=${WD_KILL_AT}s: current_authority=${ENC_PGID:-NONE} still live → KILL group" "$R" && say "  PASS: KILL escalation exercised against the same authority (TERM was ignored by design)" || { say "  FAIL: no KILL escalation line"; STRIKE=1; }
  awk -v e="$t2" -v w="$WD_KILL_AT" 'BEGIN{exit !(e>=w-1.5 && e<=w+3)}' && say "  PASS: group gone inside [${WD_KILL_AT}-1.5, ${WD_KILL_AT}+3] s" || { say "  FAIL: timing t=$t2 s"; STRIKE=1; }
  [ -z "$(rec_alive "g${ENC_PGID:-0}")" ] && say "  PASS: no member of the enclosure survives the escalation" || { say "  FAIL: members survive"; STRIKE=1; }
  owned_cleanup

elif [ "$SET" = wdcancel ]; then
  # ---------- C1: total cancellation self-test (N8's inner target). The driver itself blocks (owned controller sleeper, `wait` builtin so the trap can run)
  # until the watchdog's third stage TERMs the DRIVER; on_cancel → finish 3 must run pending/owned/controller cleanup, stop the watchdog and publish inside the reserve.
  need C1-driver-cancellation $((BUDGET-RESERVE-3)); CUR=c1
  ctrl_arm c1-sleeper p owned; sleep "$BUDGET" </dev/null >/dev/null 2>&1 & ctrl_book $! || say "  FAIL: C1 sleeper could not be booked"; say "  C1 blocking on controller sleeper pid=$! until the watchdog cancels this driver at t=${WD_CANCEL_AT}s"   # A05(V57): latched acquisition
  wait $!; say "  FAIL: C1 wait returned without cancellation (rc=$?)"; STRIKE=1
  owned_cleanup

elif [ "$SET" = neg2 ]; then
  # ---------- N4: caller-group decoy — a process in the DRIVER's own group, unrecorded as owned work, name outside every pattern, must survive a normal (K2-like)
  # and an exceptional (K3-like TERM into step 40) runner cleanup, the driver's owned cleanup, and the active-vs-retired checks. It IS a controller resource (A06):
  # its state is acknowledged before use and controller_cleanup ends it on every exit path.
  need N4-caller-group-decoy 34
  ctrl_arm n4-decoy p; bash -c 'exec -a s2r56-caller-decoy sleep 60' </dev/null >/dev/null 2>&1 & DECOY=$!; ctrl_book "$DECOY" || say "  FAIL: decoy pid=$DECOY could not be booked as a controller resource"   # A05(V57): controller-listed BEFORE the 0.2 s acknowledgement wait (never owned work)
  sleep 0.2; dpg=$(ps -o pgid= -p "$DECOY" 2>/dev/null | tr -d ' ')
  if alive "$DECOY" && [ "$dpg" = "$MY_PGID" ]; then say "  decoy ACKNOWLEDGED: pid=$DECOY alive in the driver's own group $dpg (controller-listed, NOT owned-work, outside every pattern)"
  else say "  FAIL: decoy not in the expected state (alive=$(alive "$DECOY" && echo yes || echo no) group=$dpg driver=$MY_PGID) → N4 not exercised"; STRIKE=1; fi
  CUR=n4a; run_runner "$RUNNER" "$OUT57" 15 S2_RUNNER_STUBS=$STUBS
  expect "$O/exit-codes.txt" '^final=0 first_exit=0 cleanup_exit=0 signal=none reap=ok' "N4a normal path final=0"
  alive "$DECOY" && say "  PASS: decoy survived the normal-path runner cleanup" || { say "  FAIL: decoy killed by normal path"; STRIKE=1; }
  owned_cleanup
  CUR=n4b; KA=8 run_runner "$RUNNER" "$OUT57" 4 STUB_HARNESS_MODE=sleep STUB_HARNESS_SLEEP=30 S2_RUNNER_STUBS=$STUBS   # outer TERM at 4 s while step 40 sleeps (K3 shape)
  expect "$O/stamp.txt" "^SIGNAL SIGTERM .* during step '40-composition'" "N4b TERM reached the sleeping composition step (A06: scenario confirmed, not inferred)"
  expect "$O/exit-codes.txt" '^final=143 first_exit=143 cleanup_exit=0 signal=TERM reap=ok' "N4b exceptional (TERM) path: signal exit, cleanup clean"
  [ "$RC" = 124 ] || { say "  FAIL: N4b outer exit $RC (expected 124)"; STRIKE=1; }
  alive "$DECOY" && say "  PASS: decoy survived the exceptional-path runner cleanup (group signals hit only self-published groups)" || { say "  FAIL: decoy killed by exceptional path"; STRIKE=1; }
  owned_cleanup
  alive "$DECOY" && say "  PASS: decoy survived the driver's owned cleanup (identity-validated records only)" || { say "  FAIL: decoy killed by owned cleanup"; STRIKE=1; }
  [ "$(grep -c '^g' "$OWNED")" = 0 ] && say "  PASS: no retired group remains a record/target after prune (active-vs-retired)" || { say "  FAIL: stale group records: $(grep '^g' "$OWNED" | tr '\n' ' ')"; STRIKE=1; }
  [ -s "$CURF" ] && { say "  FAIL: current authority not cleared"; STRIKE=1; } || say "  PASS: current authority empty between controls (watchdog has no stale target)"
  kill -TERM "$DECOY" 2>/dev/null; wait "$DECOY" 2>/dev/null; alive "$DECOY" && { say "  FAIL: decoy could not be ended by its owner"; STRIKE=1; } || say "  decoy ended by the driver itself (its controller); controller registry keeps the record for the finally census"
  # ---------- N5a: deterministic PUBLICATION FAILURE (stub seam STUB_PUBLISH_FAIL=10-guard-spec): the leader cannot publish → exits 70 before exec;
  # the runner refuses 70; the guard-spec workload NEVER ran; nothing survives; receipt/publication ok.
  need N5a-publication-failure 10; CUR=n5a; run_runner "$RUNNER" "$OUT57" 8 STUB_PUBLISH_FAIL=10-guard-spec S2_RUNNER_STUBS=$STUBS
  expect "$O/stamp.txt" '^SEAM: 10-guard-spec publish target made unwritable' "N5a seam engaged"
  expect "$O/stamp.txt" '^10-guard-spec: leader pid=[0-9]+ exited rc=70 WITHOUT an adoptable published identity' "N5a leader self-exited 70 (publish failed → no exec)"
  expect "$O/exit-codes.txt" '^final=70 first_exit=70 cleanup_exit=0 signal=none reap=ok' "N5a refused 70, cleanup clean"
  expect "$O/exit-codes.txt" 'guard_spec=notrun refusal_hosted=notrun .* fixture_stop=notrun survivors=none' "N5a no later step, no fixture stop, no survivors"
  grep -q 'stub guard spec' "$O/10-guard-spec.log" 2>/dev/null && { say "  FAIL: guard-spec workload RAN despite publication failure"; STRIKE=1; } || say "  PASS: guard-spec workload never started (no stub output)"
  [ "$RC" = 70 ] || { say "  FAIL: exit $RC"; STRIKE=1; }; owned_cleanup
  # ---------- N5b: deterministic INTERRUPTION between publication and adoption (stub seam STUB_HOLD_ACK=40-composition). A controller-listed seam
  # controller waits for the runner's SEAM stamp; ONLY if the seam was seen does it TERM the runner pid, and only after validating that the pid belongs to
  # the CURRENT enclosure authority (D-04). A timed-out wait sends nothing and is reported → STRIKE (A06: refuse timed-out synchronization).
  need N5b-startup-interruption 16; CUR=n5b; before=$(ls -1d "$OUT57"/*/ 2>/dev/null); ctrl_arm n5b-seam-controller p owned   # A05(V57): latched acquisition
  ( for ((i=0;i<100;i++)); do d=$(comm -13 <(echo "$before") <(ls -1d "$OUT57"/*/ 2>/dev/null) | tail -1); [ -n "$d" ] && grep -q '^SEAM: 40-composition identity [0-9]* read; HOLDING' "$d/stamp.txt" 2>/dev/null && break; sleep 0.1; done
    if [ "$i" -ge 100 ]; then echo "seam controller: SEAM NOT SEEN within 10 s → no signal sent (refused timed-out synchronization)"; exit 1; fi
    p=$(sed -n 's/^lock acquired pid=\([0-9]*\) .*/\1/p' "$d/stamp.txt" 2>/dev/null | head -1); cur=$(tr -dc '0-9' < "$CURF" 2>/dev/null); ppg=$(ps -o pgid= -p "$p" 2>/dev/null | tr -d ' ')
    if [ -n "$p" ] && [ -n "$cur" ] && [ "$ppg" = "$cur" ]; then echo "seam controller: seam seen after $((i/10)).$((i%10))s in $d; runner pid=$p validated in CURRENT enclosure $cur → TERM"; kill -TERM "$p"; exit 0
    else echo "seam controller: runner pid=${p:-NONE} pgid=${ppg:-NONE} NOT in CURRENT enclosure ${cur:-NONE} → no signal sent"; exit 2; fi ) >"$CTL/n5b.seam-controller.log" 2>&1 & SEAMC=$!; ctrl_book "$SEAMC" || say "  FAIL: seam controller pid=$SEAMC could not be booked"
  run_runner "$RUNNER" "$OUT57" 12 STUB_HOLD_ACK=40-composition S2_RUNNER_STUBS=$STUBS; wait "$SEAMC" 2>/dev/null; src=$?; sed 's/^/    /' "$CTL/n5b.seam-controller.log" | tee -a "$R"
  [ "$src" = 0 ] && say "  PASS: seam controller saw the seam and signalled a validated pid" || { say "  FAIL: seam controller rc=$src (no valid signal was sent; any interruption came from the outer bound)"; STRIKE=1; }
  expect "$O/stamp.txt" '^SEAM: 40-composition identity [0-9]+ read; HOLDING before adoption/ack' "N5b seam engaged (published, not yet adopted)"
  expect "$O/stamp.txt" "^SIGNAL SIGTERM .* during step '40-composition'" "N5b TERM arrived during the held step"
  expect "$O/stamp.txt" "^HALT: in-flight step '40-composition' pid=[0-9]+ had a PUBLISHED but unadopted identity [0-9]+ → adopted now and signalled as a group" "N5b published identity resolved at interruption (adopted, group-signalled)"
  expect "$O/exit-codes.txt" '^final=143 first_exit=143 cleanup_exit=0 signal=TERM reap=ok' "N5b signal exit, reap ok, cleanup clean"
  expect "$O/exit-codes.txt" 'composition=interrupted\(TERM\) s1_r4_discriminator=notrun fixture_stop=0 survivors=none' "N5b step interrupted, fixture stopped, no survivors"
  grep -q 'stub harness' "$O/40-composition.log" 2>/dev/null && { say "  FAIL: harness workload RAN before adoption"; STRIKE=1; } || say "  PASS: harness workload never started (unacked leader never exec'd)"
  [ "$RC" = 143 ] || { say "  FAIL: exit $RC"; STRIKE=1; }; owned_cleanup
  # ---------- N6: intentional HANDOFF FAILURE — a controller-listed holder (own session) takes the lane-private lock and ACKNOWLEDGES readiness by writing
  # its pid under the lock; the driver waits for that ack (bounded, refuses on timeout). A nested child driver (set probe) passes its only control; the child's
  # final gate must return 4 with 'lane lock HELD', evidence preserved; the holder is then ended by its controller and the lock re-observed FREE.
  need N6-handoff-failure-lock-held 18; rm -f "$ENCL/n6.holder.ready"; ctrl_arm n6-holder g owned   # A05(V57): latched acquisition (session record)
  setsid flock "$LANE_LOCK" bash -c 'echo $$ > "$1"; exec sleep 40' _ "$ENCL/n6.holder.ready" </dev/null >/dev/null 2>&1 & HOLDER=$!; ctrl_book "$HOLDER" || say "  FAIL: holder session $HOLDER could not be booked"   # the lock fd is inherited by the sleep: the whole holder SESSION is the controller resource
  for ((i=0;i<30;i++)); do [ -s "$ENCL/n6.holder.ready" ] && break; sleep 0.1; done
  if [ -s "$ENCL/n6.holder.ready" ] && ! flock -n "$LANE_LOCK" true 2>/dev/null; then say "  holder ACKNOWLEDGED: session pid=$HOLDER holds the lane lock (ready written under the lock by pid $(cat "$ENCL/n6.holder.ready"))"
    enclose n6 "$(clip 12)" 5 env CTL_SET=probe CTL_BUDGET=20 bash "$0" >"$CTL/n6.child.log" 2>&1; rc=$RC; say "  N6 child driver exit=$rc (expected 4)"; grep -h 'HANDOFF FAILURE' "$CTL/n6.child.log" | head -1 | sed 's/^/    /' | tee -a "$R"
    [ "$rc" = 4 ] && say "  PASS: aggregate 4 on a non-free lane lock" || { say "  FAIL: exit $rc"; STRIKE=1; }
    grep -q 'HANDOFF FAILURE: .* lane lock HELD' "$CTL/n6.child.log" && say "  PASS: gate names the held lane lock" || { say "  FAIL: no lock handoff line"; STRIKE=1; }
    grep -q 'PASS: probe enclosure rc=0' "$CTL/n6.child.log" && grep -q 'controls_run=1/1' "$CTL/n6.child.log" && say "  PASS: assertions passed yet handoff refused (assertions ≠ handoff)" || { say "  FAIL: probe control did not complete as expected"; STRIKE=1; }
    grep -q 'CONTROLS_RECEIPT: publication_status=ok aggregate_exit=4' "$CTL/n6.child.log" && say "  PASS: child evidence published with aggregate 4" || { say "  FAIL: child publication line missing"; STRIKE=1; }
  else say "  FAIL: holder readiness not acknowledged within 3 s (ready=$([ -s "$ENCL/n6.holder.ready" ] && echo yes || echo no)) → N6 NOT exercised (refused timed-out synchronization)"; STRIKE=1; fi
  kill -TERM -- "-$HOLDER" 2>/dev/null; wait "$HOLDER" 2>/dev/null; sleep 0.2; flock -n "$LANE_LOCK" true 2>/dev/null && say "  holder ended by its controller; lane lock FREE again" || { say "  FAIL: lane lock still held after holder cleanup"; STRIKE=1; }
  owned_cleanup
  # ---------- N7: watchdog TERM→KILL escalation against the CURRENT authority and closed sleeper stop (nested wdtest driver)
  need N7-watchdog-escalation 28; CUR=n7
  enclose n7 "$(clip 24)" 3 env CTL_SET=wdtest CTL_BUDGET=20 bash "$0" >"$CTL/n7.child.log" 2>&1; rc=$RC; say "  N7 child driver exit=$rc (expected 0)"
  [ "$rc" = 0 ] && say "  PASS: wdtest child exit 0" || { say "  FAIL: exit $rc"; STRIKE=1; }
  grep -q '^WATCHDOG fired .* current_authority=[0-9]* → TERM group' "$CTL/n7.child.log" && grep -q '^WATCHDOG escalation at t=[0-9]*s: current_authority=[0-9]* still live → KILL group' "$CTL/n7.child.log" && say "  PASS: TERM then KILL escalation recorded against the current authority" || { say "  FAIL: escalation lines missing"; STRIKE=1; }
  grep -q 'watchdog stopped: shell=[0-9]* sleeper=[0-9]* census_after=\[empty\]' "$CTL/n7.child.log" && say "  PASS: watchdog shell and owned sleeper both gone (closed stop, no residue)" || { say "  FAIL: watchdog census not empty"; STRIKE=1; }
  grep -q 'PASS: KILL escalation exercised' "$CTL/n7.child.log" && grep -q 'PASS: no member of the enclosure survives' "$CTL/n7.child.log" && say "  PASS: child observed escalation and empty census" || { say "  FAIL: child escalation checks"; STRIKE=1; }
  owned_cleanup
  # ---------- N8: total cancellation — the nested wdcancel driver is TERMed by ITS OWN watchdog's third stage; on_cancel must complete cleanup, controllers, watchdog stop and publication with aggregate 3
  need N8-driver-cancellation 28; CUR=n8
  enclose n8 "$(clip 24)" 3 env CTL_SET=wdcancel CTL_BUDGET=20 bash "$0" >"$CTL/n8.child.log" 2>&1; rc=$RC; say "  N8 child driver exit=$rc (expected 3)"
  [ "$rc" = 3 ] && say "  PASS: aggregate 3 after cancellation" || { say "  FAIL: exit $rc"; STRIKE=1; }
  grep -q '^WATCHDOG: cancelling the driver (TERM pid=[0-9]*, parent identity re-checked)' "$CTL/n8.child.log" && grep -q '^DEADLINE CANCELLATION: SIGTERM received' "$CTL/n8.child.log" && say "  PASS: watchdog cancellation reached the driver's handler" || { say "  FAIL: cancellation lines missing"; STRIKE=1; }
  grep -q 'controllers ended: census_after=\[empty\]' "$CTL/n8.child.log" && grep -q 'watchdog stopped: shell=[0-9]* sleeper=[0-9]* census_after=\[empty\]' "$CTL/n8.child.log" && say "  PASS: controller sleeper and watchdog ended on the cancellation path" || { say "  FAIL: cancellation-path cleanup census"; STRIKE=1; }
  grep -q 'CONTROLS_RECEIPT: publication_status=ok aggregate_exit=3' "$CTL/n8.child.log" && say "  PASS: publication completed inside the reserve with aggregate 3" || { say "  FAIL: child publication line missing"; STRIKE=1; }
  owned_cleanup
fi
say; say "SET $SET: all planned controls executed; strike=$STRIKE"; finish 0
