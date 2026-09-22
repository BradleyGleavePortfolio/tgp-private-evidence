#!/usr/bin/env bash
# PROPOSED, NOT EXECUTED (OP88-S2-V56 / S2-RUNNER-V5.6-PREP, 2026-09-22). Successor of s2-runner55/controls-proposed/run-controls-v55.sh
# (a5a2d73f…) — v56 delta, each item bound to a frozen v5.5 finding (FINDINGS_MAP_V56.md):
#   E7 (A-03 / B-03) ONE current validated enclosure authority: $ENCL/CURRENT is written on adoption and truncated at retirement; the watchdog
#      reads ONLY that file (never `ls -t *.pgid` history), re-validates liveness and own/parent exclusion. prune_groups also retires DEAD plain-pid
#      records (history kept). The watchdog owns its sleeper (pid file) and stop_watchdog() TERMs/reaps shell+sleeper and takes a census that
#      feeds the handoff gate. Escalation: TERM current enclosure at BUDGET-RESERVE, KILL at BUDGET-RESERVE/2, then TERM the DRIVER itself
#      (trap → finish 3) so cleanup/publication run inside the reserve: the aggregate deadline reaches active work and driver completion.
#   E8 (A-02) enclose() uses the runner's fail-closed leader contract (publish → registered+CURRENT → ack → exec): an unconfirmed enclosure is a
#      STRIKE, its leader gets a bounded pid-only TERM/KILL and is recorded; it is never accepted as rc-0/empty.
#   E9 (A-04 / B-02) K2 asserts the v5.5/v5.6 predicate `owned groups [none] retired [...]`; run_runner applies RECEIPT/PUBLICATION/outer-manifest
#      requirements only to the successor runner and checks the frozen v5.3.1 predecessor's ACTUAL format (exit-codes.txt + inner SHA256SUMS only).
#   E10 (A-05 mirror) finish/abort publish under one bounded kill-after timeout, check the write status, write CONTROLS_RECEIPT.txt (hashed by
#      nothing) and classify the aggregate exit AFTER publication (failed publication is never 0).
#   New sets: probe (1 trivial enclosed control; N6 target), wdtest (watchdog self-test; N7 target), neg2 = N4 caller-group decoy through normal AND
#      exceptional cleanup + active-vs-retired authority checks, N5a deterministic publication failure (STUB_PUBLISH_FAIL seam), N5b deterministic
#      interruption between publication and adoption (STUB_HOLD_ACK seam + driver-owned seam controller sending TERM), N6 private-lane lock held by
#      a separately owned controller at the final gate → 4, N7 watchdog fires/escalates/no sleeper residue. No probabilistic sleep is a race proof.
#   Lane: execution/op88/s2-v56; runner-selftest-r56/. Predecessor 37-file re-verification must run from the manifest's own directory (request text).
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
# No DB, no network, no canonical lock (lane-private $STUBS/test-validation.lock), no product/source writes. 'pre' controls run the FROZEN
# v5.3.1 bytes read-only to reproduce the finding; their outputs land under s2-setup-prep/runner-selftest-r531/ (additive; the 37 frozen files
# are untouched). One invocation = one set. CTL_BUDGET default 60.
set -u
R56=/home/user/workspace/execution/op88/s2-v56; RUNNER=$R56/run-composition-r56-v5.6-when-granted.sh; STUBS=$R56/controls-proposed/stubs
PRE_RUNNER=/home/user/workspace/execution/s2-setup-prep/run-composition-r53-v5.3.1-when-granted.sh   # frozen v5.3.1 fb0d7ce4…, read-only; path pin unchanged
SET=${CTL_SET:-k}; BUDGET=${CTL_BUDGET:-60}; RESERVE=8; INJECT_FAIL=${CTL_INJECT_FAIL:-0}
CTL=$R56/controls-proposed/results/$SET-$(date -u +%Y%m%dT%H%M%SZ)-$$; mkdir -p "$CTL"; R=$CTL/CONTROLS_RESULT.txt; OWNED=$CTL/owned-pids.txt; : > "$OWNED"; HIST=$CTL/owned-history.txt; : > "$HIST"
MY_PGID=$(ps -o pgid= -p $$ | tr -d ' '); PARENT_PGID=$(ps -o pgid= -p $PPID 2>/dev/null | tr -d ' '); ENCL=$CTL/.encl; mkdir -p "$ENCL"
CURF=$ENCL/CURRENT; : > "$CURF"   # E7: the single current validated enclosure authority (one pgid or empty); the ONLY watchdog target source
T0=$(date +%s.%N); STRIKE=0; RUN=0; PLANNED=0; WATCHDOG=; WD_CENSUS=; DRIVER_PID=$$; CUR=none
WD_TERM_AT=$((BUDGET-RESERVE)); WD_KILL_AT=$((BUDGET-RESERVE/2)); WD_CANCEL_AT=$((WD_KILL_AT+1))   # E7 escalation schedule (s from T0)
ACK_TICKS=150   # E8: 3 s leader ack wait (×0.02 s); the driver's identity poll is ≤ 2 s
LEADER='echo $$ > "$1" || exit 70; i=0; while [ ! -e "$1.ack" ]; do i=$((i+1)); [ "$i" -gt "$2" ] && exit 70; sleep 0.02; done; shift 2; exec timeout --foreground -k "$@"'   # E8: same contract as the runner (with kill-after)
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
prune_groups(){ # E4/E7: drop g<pgid> records whose census is empty AND plain-pid records that are dead (history retained in $HIST); clear CURRENT if its group is gone
  local x keep=; while read -r x; do case $x in g*) pgrep -g "${x#g}" >/dev/null 2>&1 && keep="$keep$x\n";; '') ;; *) kill -0 "$x" 2>/dev/null && keep="$keep$x\n";; esac; done < "$OWNED"; printf "%b" "$keep" > "$OWNED"
  local c; c=$(tr -dc '0-9' < "$CURF" 2>/dev/null); [ -n "$c" ] && ! pgrep -g "$c" >/dev/null 2>&1 && : > "$CURF"; :; }
enclose(){ # enclose <name> <bound> <grace> <cmd...> : run cmd in an exclusive self-published group under the fail-closed leader contract (E1/E3/E8); sets ENC_PGID, RC
  local name=$1 bound=$2 grace=$3; shift 3; local idf="$ENCL/$name.pgid" pid pg= i e; rm -f "$idf" "$idf.ack"
  setsid bash -c "$LEADER" _ "$idf" "$ACK_TICKS" "$grace" "$bound" "$@" & pid=$!; ENC_PGID=
  for ((i=0;i<40;i++)); do [ -f "$idf" ] && [ -s "$idf" ] && { pg=$(tr -dc '0-9' < "$idf" 2>/dev/null); break; }; kill -0 "$pid" 2>/dev/null || { sleep 0.05; [ -f "$idf" ] && [ -s "$idf" ] && pg=$(tr -dc '0-9' < "$idf" 2>/dev/null); break; }; sleep 0.05; done   # regular non-empty file only
  if [ -n "$pg" ] && [ "$pg" = "$pid" ] && [ "$pg" != "$MY_PGID" ] && [ "$pg" != "$PARENT_PGID" ]; then
    record "g$pg"; printf '%s\n' "$pg" > "$CURF"   # E7: registered AND current BEFORE the ack — the leader cannot exec until it is the validated authority
    if : > "$idf.ack" 2>/dev/null; then ENC_PGID=$pg; else say "  ENCLOSURE ACK WRITE FAILED for $name (group $pg) → leader self-exits 70 without exec; group halted; STRIKE"; STRIKE=1; ENC_PGID=$pg; kill -TERM -- "-$pg" 2>/dev/null; fi
  else
    say "  ENCLOSURE IDENTITY NOT CONFIRMED for $name (pid=$pid published='${pg:-none}') → STRIKE; bounded TERM/KILL by pid only (never a group); unacked leader never exec'd"; STRIKE=1; record "$pid"
    if kill -0 "$pid" 2>/dev/null; then kill -TERM "$pid" 2>/dev/null; e=$(( $(date +%s)+3 )); while kill -0 "$pid" 2>/dev/null && [ "$(date +%s)" -lt "$e" ]; do sleep 0.1; done; kill -0 "$pid" 2>/dev/null && kill -KILL "$pid" 2>/dev/null; fi
  fi
  wait "$pid"; RC=$?
  if [ -n "$ENC_PGID" ]; then
    if pgrep -g "$ENC_PGID" >/dev/null 2>&1; then say "  enclosure $name (group $ENC_PGID) still has members after exit rc=$RC: [$(pgrep -g "$ENC_PGID" -a | tr '\n' ';')] → retained as owned survivors (authority kept until cleaned)"
    else : > "$CURF"; fi   # E7: retired at confirmed-empty census → no longer the watchdog target; prune_groups drops the g record
  fi
}
stop_watchdog(){ # E7: TERM/reap the watchdog shell AND its owned sleeper; census afterwards feeds the handoff gate
  [ -n "$WATCHDOG" ] || return 0; local s e; s=$(tr -dc '0-9' < "$ENCL/wd.sleeper" 2>/dev/null)
  kill -TERM "$WATCHDOG" 2>/dev/null; [ -n "$s" ] && kill -TERM "$s" 2>/dev/null; wait "$WATCHDOG" 2>/dev/null
  e=$(( $(date +%s)+2 )); while { kill -0 "$WATCHDOG" 2>/dev/null || { [ -n "$s" ] && kill -0 "$s" 2>/dev/null; }; } && [ "$(date +%s)" -lt "$e" ]; do sleep 0.05; done
  WD_CENSUS=; kill -0 "$WATCHDOG" 2>/dev/null && WD_CENSUS="$WD_CENSUS $WATCHDOG"; [ -n "$s" ] && kill -0 "$s" 2>/dev/null && WD_CENSUS="$WD_CENSUS $s"
  say "  watchdog stopped: shell=$WATCHDOG sleeper=${s:-none} census_after=[${WD_CENSUS:-empty}]"; WATCHDOG=; }
publish_results(){ # publish_results <code> : E10 — bounded kill-after manifest, status-checked; CONTROLS_RECEIPT.txt hashed by nothing; returns the classified code
  local code=$1 prc=0 pb pub=ok; pb=$(left); [ "$pb" -gt 5 ] && pb=5
  if [ "$pb" -le 0 ]; then prc=deadline
  else timeout -k 1 "$pb" bash -c 'cd "$1" && find . -type f ! -name SHA256SUMS ! -name CONTROLS_RECEIPT.txt -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS.tmp && mv -f SHA256SUMS.tmp SHA256SUMS' _ "$CTL" || prc=$?; rm -f "$CTL/SHA256SUMS.tmp"; fi
  [ "$prc" = 0 ] && [ -s "$CTL/SHA256SUMS" ] || pub="FAILED(rc=$prc)"
  [ "$pub" = ok ] || { [ "$code" = 0 ] && code=4; }
  { echo "publication_status=$pub"; echo "aggregate_exit=$code"; echo "set=$SET controls_run=$RUN/$PLANNED strike=$STRIKE wall=$(now)s budget=${BUDGET}s"; echo "utc=$(date -u +%FT%TZ)"; } > "$CTL/CONTROLS_RECEIPT.txt" 2>/dev/null || { [ "$code" = 0 ] && code=4; }
  echo "CONTROLS_RECEIPT: publication_status=$pub aggregate_exit=$code (classified after publication)"; PUB_CODE=$code; }
owned_live(){ # expand records: plain pids (alive) + live members of recorded groups; exclude pre-snapshot pids, self, own/parent groups (E1/E4)
  local x; { while read -r x; do case $x in g*) { [ "${x#g}" = "$MY_PGID" ] || [ "${x#g}" = "$PARENT_PGID" ]; } || pgrep -g "${x#g}" 2>/dev/null;; '') ;; *) kill -0 "$x" 2>/dev/null && echo "$x";; esac; done < "$OWNED"; } | sort -un | grep -vxF -f "$CTL/pre-snapshot.txt" | awk -v me=$$ -v pp=$PPID '$1!=me && $1!=pp'
}
owned_cleanup(){ local pids; pids=$(owned_live | tr '\n' ' ')
  if [ -n "$pids" ]; then say "  owned cleanup: TERM recorded pids [$pids] $(ps -o pid=,pgid=,cmd= -p $(echo $pids | tr ' ' ',') 2>/dev/null | tr '\n' ';')"; kill -TERM $pids 2>/dev/null; sleep 0.5
    pids=$(owned_live | tr '\n' ' '); [ -n "$pids" ] && { say "  owned cleanup: KILL recorded pids [$pids]"; kill -KILL $pids 2>/dev/null; sleep 0.3; }; fi
  say "  recorded-owned alive after cleanup: [$(owned_live | tr '\n' ' ')]; pattern-detected (report only): [$(detect | tr '\n' ' ')]"; prune_groups; }
finish(){ # finish <code> — E3/E7/E10: assertions passing is not a handoff; survivors / non-free lane lock / new pattern matches / watchdog residue force 4
  local code=$1; trap ':' TERM; owned_cleanup; stop_watchdog   # no-op handler (not SIG_IGN): a late TERM cannot abort cleanup, and children (timeout/bash) keep default TERM so bounds stay TERM-then-KILL
  [ "$code" = 0 ] && { [ "$RUN" -lt "$PLANNED" ] || [ "$STRIKE" = 1 ]; } && code=1
  local surv newpat lockst; surv=$(owned_live | tr '\n' ' '); newpat=$(detect | grep -vxF -f "$CTL/pre-snapshot.txt" | tr '\n' ' '); lockst=$(flock -n "$STUBS/test-validation.lock" true && echo FREE || echo HELD)
  if [ -n "$surv" ] || [ -n "$newpat" ] || [ "$lockst" != FREE ] || [ -n "$WD_CENSUS" ]; then say "HANDOFF FAILURE: owned survivors [$surv] new pattern matches [$newpat] lane lock $lockst watchdog census [${WD_CENSUS:-empty}] → aggregate 4 (no further set may start)"; code=4; fi
  [ "$(left)" -lt 0 ] && { say "AGGREGATE DEADLINE EXCEEDED before publication ($(now)s > ${BUDGET}s)"; [ "$code" = 0 ] && code=3; }
  say "SET=$SET controls_run=$RUN/$PLANNED strike=$STRIKE wall=$(now)s of ${BUDGET}s (reserve ${RESERVE}s) aggregate_exit=$code (pre-publication); lane lock: $lockst; current_authority_file=[$(tr -dc '0-9' < "$CURF" 2>/dev/null)] (must be empty); canonical lock file: $([ -e /home/user/workspace/execution/test-validation.lock ] && echo exists || echo absent) (never opened)"
  publish_results "$code"; exit "$PUB_CODE"; }
abort(){ trap ':' TERM; stop_watchdog; say "ABORT (precondition, no ownership acquired, NO signals sent to anything but this driver's own watchdog shell/sleeper): $*"; say "SET=$SET controls_run=0/$PLANNED aggregate_exit=2 wall=$(now)s"; publish_results 2; exit 2; }
on_cancel(){ trap ':' TERM; say "DEADLINE CANCELLATION: SIGTERM received at t=$(now)s during control ${CUR:-none} (watchdog escalation or external) → aggregate 3; owned cleanup + publication run inside the reserve"; finish 3; }   # E7: cancellation reaches driver completion
trap on_cancel TERM
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
  if [ "$runner" = "$RUNNER" ]; then   # E9: receipt/publication predicates apply to the SUCCESSOR format only (v5.6: RECEIPT.txt, SHA256SUMS.outer, PUBLICATION.txt)
    expect "$O/RECEIPT.txt" '^receipt_status=ok$' "$CUR receipt ok (frozen manifest, post-hash receipt)"
    expect "$O/PUBLICATION.txt" '^publication_status=ok deadline_exceeded_at_publication=no$' "$CUR publication ok (receipt + outer manifest written, verified, inside deadline)"
    ( cd "$O" && sha256sum -c --quiet SHA256SUMS.outer && sha256sum -c --quiet SHA256SUMS ) 2>/dev/null && say "  PASS: $CUR outer+inner manifests re-verify (immutable publication)" || { say "  FAIL: $CUR manifest re-verification"; STRIKE=1; }
  else   # E9: frozen v5.3.1 predecessor writes exit-codes.txt + inner SHA256SUMS only (predecessor L156–L157); never require RECEIPT.txt from it
    expect "$O/exit-codes.txt" '^final=[0-9]+ first_exit=' "$CUR predecessor exit-codes present (v5.3.1 format)"
    [ -s "$O/SHA256SUMS" ] && say "  PASS: $CUR predecessor inner manifest present (v5.3.1 format; NOT re-verified: v5.3.1 has the known post-hash stamp mutation, R54-A-03/R54B-03)" || { say "  FAIL: $CUR predecessor inner manifest missing"; STRIKE=1; }
  fi; }
OUT56=$R56/runner-selftest-r56; OUT531=/home/user/workspace/execution/s2-setup-prep/runner-selftest-r531

say "S2-R56 controls set=$SET start $(date -u +%FT%TZ) budget=${BUDGET}s results=$CTL pid=$$ pgid=$MY_PGID timeout_impl=$(timeout --version 2>/dev/null | head -1) runner_sha256=$(sha256sum "$RUNNER" | cut -c1-64) pre_runner_sha256=$(sha256sum "$PRE_RUNNER" | cut -c1-64) stubs=$(cd "$STUBS" && sha256sum *.sh | cut -c1-16 | tr '\n' ' ')"
detect > "$CTL/pre-snapshot.txt"
say "pre-snapshot pattern matches (never signalled): [$(tr '\n' ' ' < "$CTL/pre-snapshot.txt")]"
[ -s "$CTL/pre-snapshot.txt" ] && abort "pre-existing pattern matches [$(tr '\n' ' ' < "$CTL/pre-snapshot.txt")] — not ours; refusing without cleanup"
[ -f "$RUNNER" ] && [ -f "$PRE_RUNNER" ] && [ -d "$STUBS" ] || abort "runner/pre-runner/stubs missing"
# E3/E7: aggregate watchdog — reads ONLY the current validated authority ($CURF), never historical id files; owns its sleeper (pid file); escalates
# TERM(current enclosure)@BUDGET-RESERVE → KILL(current enclosure)@BUDGET-RESERVE/2 → TERM(driver)@+1 s so finish() runs inside the reserve.
wd_target(){ local g; g=$(tr -dc '0-9' < "$CURF" 2>/dev/null); [ -n "$g" ] && [ "$g" != "$MY_PGID" ] && [ "$g" != "$PARENT_PGID" ] && pgrep -g "$g" >/dev/null 2>&1 && echo "$g"; }
( trap - TERM; sleep "$WD_TERM_AT" & echo $! > "$ENCL/wd.sleeper"; wait $!
  g=$(wd_target); echo "WATCHDOG fired at $(date -u +%FT%TZ) (t=${WD_TERM_AT}s) current_authority=${g:-none} → TERM group" | tee -a "$R"; [ -n "$g" ] && kill -TERM -- "-$g" 2>/dev/null
  sleep $(( WD_KILL_AT - WD_TERM_AT )) & echo $! > "$ENCL/wd.sleeper"; wait $!
  g=$(wd_target); [ -n "$g" ] && { echo "WATCHDOG escalation at t=${WD_KILL_AT}s: current_authority=$g still live → KILL group" | tee -a "$R"; kill -KILL -- "-$g" 2>/dev/null; }
  sleep 1 & echo $! > "$ENCL/wd.sleeper"; wait $!
  echo "WATCHDOG: cancelling the driver (TERM pid=$DRIVER_PID) at t=${WD_CANCEL_AT}s — reserve kept for owned cleanup/publication" | tee -a "$R"; kill -TERM "$DRIVER_PID" 2>/dev/null ) & WATCHDOG=$!
case $SET in k) PLANNED=6;; new1) PLANNED=5;; new2) PLANNED=1;; neg) PLANNED=3;; neg2) PLANNED=5;; probe) PLANNED=1;; wdtest) PLANNED=1;; *) abort "unknown CTL_SET=$SET";; esac
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
  need K2-stub-success 15; CUR=k2; run_runner "$RUNNER" "$OUT56" 15 S2_RUNNER_STUBS=$STUBS
  expect "$O/exit-codes.txt" '^final=0 first_exit=0 cleanup_exit=0 signal=none reap=ok' "K2 result registers"
  expect "$O/exit-codes.txt" 'deadline_exceeded=no guard_spec=0 refusal_hosted=64 refusal_noconfirm=64 fixture=0 composition=0 s1_r4_discriminator=0 fixture_stop=0 survivors=none' "K2 all steps reached, refusals 64/64, stop 0, deadline kept"
  expect "$O/stamp.txt" 'STUB MODE — NOT EVIDENCE' "K2 stub banner"
  expect "$O/stamp.txt" 'head=d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c tree=c0ab87d4dc584b2a7ccad53db16fa551b93fe359 dirty_lines=0' "K2 real head/tree/clean check"
  expect "$O/stamp.txt" 'REAP ok: no owned-work process survives \(owned groups \[none\] retired \[[0-9 ]+\], anchored scan\)' "K2 every step group retired (active set empty) before fixture stop (O1/P2, E9)"
  expect "$O/stamp.txt" 'owned_groups=\[none\] retired_groups=\[[0-9 ]+\]' "K2 end line: no active group remains, retired list present (active-vs-retired authority)"
  [ "$(ls "$O"/.pgid/*.ack 2>/dev/null | wc -l)" -eq 10 ] && say "  PASS: K2 every leader was acked before exec (10 ack files: 10,20,21,30,31,32,40,45,50,51)" || { say "  FAIL: K2 ack files missing ($(ls "$O"/.pgid 2>/dev/null | tr '\n' ' '))"; STRIKE=1; }
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
  need K3-term-during-step40 12; CUR=k3; KA=8 run_runner "$RUNNER" "$OUT56" 3 STUB_HARNESS_MODE=sleep STUB_HARNESS_SLEEP=30 S2_RUNNER_STUBS=$STUBS
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
  need K4-escapee-quarantine 25; CUR=k4; KA=20 run_runner "$RUNNER" "$OUT56" 3 STUB_HARNESS_MODE=escape STUB_HARNESS_SLEEP=40 S2_RUNNER_STUBS=$STUBS
  say "  K4 recorded-owned alive after runner exit (expected: the quarantined escapee): [$(owned_live | tr '\n' ' ')]"
  expect "$O/exit-codes.txt" '^final=143 first_exit=143 cleanup_exit=72 signal=TERM reap=FAILED' "K4 quarantine class 72 separate from first exit 143"
  expect "$O/exit-codes.txt" 'fixture_stop=REFUSED survivors=present' "K4 fixture stop REFUSED, survivors present"
  expect "$O/QUARANTINE.txt" 's2r53-stub-escapee' "K4 QUARANTINE.txt lists the escapee"
  expect "$O/stamp.txt" 'LOCK: held by runner through cleanup \(HELD\); NOT safely handed off' "K4 lock not declared handed off"
  [ -f "$O/50-fixture-stop.log" ] && { say "  FAIL: fixture stop ran after failed reap"; STRIKE=1; } || say "  PASS: no fixture stop after failed reap"
  say "  K4 timing: $(grep -o 'cleanup_seconds=[0-9.]*' "$O/exit-codes.txt") (reap 10+5 s)"
  [ "$RC" = 124 ] || { say "  FAIL: outer exit $RC"; STRIKE=1; }; owned_cleanup
  # ---------- K5 normal-path stop failure → 71
  need K5-stop-failure 15; CUR=k5; run_runner "$RUNNER" "$OUT56" 15 STUB_STOP_RC=1 S2_RUNNER_STUBS=$STUBS
  expect "$O/exit-codes.txt" '^final=71 first_exit=0 cleanup_exit=71 signal=none reap=ok' "K5 cleanup class 71 with first exit 0 preserved"
  expect "$O/exit-codes.txt" 'fixture_stop=1 survivors=none' "K5 stop exit 1 recorded"
  [ "$RC" = 71 ] || { say "  FAIL: exit $RC"; STRIKE=1; }; owned_cleanup
  # ---------- K6 first failing step preserved
  need K6-first-failure 10; CUR=k6; run_runner "$RUNNER" "$OUT56" 10 STUB_GUARD_RC=3 S2_RUNNER_STUBS=$STUBS
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
  need K7-v5.5-leader-exits-first 6; CUR=k7; run_runner "$RUNNER" "$OUT56" 6 STUB_HARNESS_MODE=leader-exit STUB_HARNESS_SLEEP=30 S2_RUNNER_STUBS=$STUBS
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
  need K8-v5.5-inner-timeout-grandchild 8; CUR=k8; run_runner "$RUNNER" "$OUT56" 8 STUB_HARNESS_MODE=grandchild STUB_HARNESS_SLEEP=30 STUB_STEP40_BOUND=2 S2_RUNNER_STUBS=$STUBS
  sp=$(grep -ohE 'spawned pid=[0-9]+' "$O"/40-composition.log 2>/dev/null | grep -oE '[0-9]+$'); say "  K8 spawned grandchild pid=[$sp] alive after runner exit: $(alive "$sp" && echo YES || echo no)"
  expect "$O/stamp.txt" '^40-composition: leader pid=[0-9]+ exited rc=124 but group [0-9]+ still has members' "K8 inner 124 with a live group member detected (O1/B01)"
  expect "$O/exit-codes.txt" '^final=124 first_exit=124 cleanup_exit=0 signal=none reap=ok' "K8 first exit 124 preserved, cleanup clean"
  expect "$O/exit-codes.txt" 'fixture_stop=0 survivors=none' "K8 fixture stopped after reap, no survivors"
  alive "$sp" && { say "  FAIL: grandchild still alive"; STRIKE=1; } || say "  PASS: grandchild gone"
  [ "$RC" = 124 ] || { say "  FAIL: exit $RC"; STRIKE=1; }; owned_cleanup
  # ---------- K9: unnamed setsid escapee (own session, cmd 'sleep') — DOCUMENTED BOUNDARY of v5.4 (no OS-level boundary): expected to be missed
  need K9-v5.5-unnamed-setsid-escape-boundary 6; CUR=k9; run_runner "$RUNNER" "$OUT56" 6 STUB_HARNESS_MODE=escape-unnamed STUB_HARNESS_SLEEP=30 S2_RUNNER_STUBS=$STUBS
  sp=$(grep -ohE 'spawned pid=[0-9]+' "$O"/40-composition.log 2>/dev/null | grep -oE '[0-9]+$'); say "  K9 escaped unnamed pid=[$sp] alive after runner exit: $(alive "$sp" && echo YES || echo no)"
  expect "$O/exit-codes.txt" '^final=0 first_exit=0 cleanup_exit=0 signal=none reap=ok' "K9 v5.4 reports success (predicted: the escapee is invisible to group+pattern ownership)"
  alive "$sp" && say "  BOUNDARY CONFIRMED (not an ownership pass): unnamed setsid escapee survives undetected — see FINDINGS_MAP K9/OS-boundary proposal" || { say "  FAIL: prediction wrong — escapee did not survive (investigate before trusting the boundary statement)"; STRIKE=1; }
  owned_cleanup

elif [ "$SET" = new2 ]; then
  # ---------- K10: hanging fixture stop → clipped stop bound, 124, cleanup class 71, first exit 0 preserved, deadline kept
  need K10-v5.5-hanging-stop 40; CUR=k10; run_runner "$RUNNER" "$OUT56" 35 STUB_STOP_HANG=60 S2_RUNNER_STUBS=$STUBS
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

elif [ "$SET" = probe ]; then
  # ---------- P1: one trivial enclosed control (N6's inner target; exercises the fail-closed enclosure on a fast command)
  need P1-probe 4; CUR=p1; enclose p1 "$(clip 2)" 1 sleep 0.2; rc=$RC
  [ "$rc" = 0 ] && [ -n "$ENC_PGID" ] && say "  PASS: probe enclosure rc=0 group=$ENC_PGID (acked before exec)" || { say "  FAIL: probe rc=$rc group=${ENC_PGID:-unconfirmed}"; STRIKE=1; }
  [ -s "$CURF" ] && { say "  FAIL: current authority not cleared after retirement"; STRIKE=1; } || say "  PASS: current authority cleared at retirement"
  owned_cleanup

elif [ "$SET" = wdtest ]; then
  # ---------- W1: watchdog self-test (N7's inner target). Deliberately UNCLIPPED enclosure bound > WD_TERM_AT so the watchdog, not clip, ends it.
  # Deterministic by schedule (fires at BUDGET-RESERVE from T0), not by a race. Expected: enclosure rc != 0 at ≈WD_TERM_AT, 'WATCHDOG fired' with the
  # current authority, current authority cleared afterwards, then finish stops the watchdog with an empty census and exits 0 inside the budget.
  need W1-watchdog-fires $((BUDGET-RESERVE-1)); CUR=w1; t1=$(now); enclose w1 "$BUDGET" 2 sleep "$BUDGET"; rc=$RC; t2=$(now)
  el=$(awk -v a="$t1" -v b="$t2" 'BEGIN{printf "%.1f", b-a}'); say "  W1 enclosure rc=$rc after ${el}s (watchdog TERM scheduled at t=${WD_TERM_AT}s)"
  [ "$rc" != 0 ] && say "  PASS: enclosure ended nonzero by the watchdog" || { say "  FAIL: enclosure rc=0"; STRIKE=1; }
  grep -q "^WATCHDOG fired .* current_authority=${ENC_PGID:-NONE} " "$R" && say "  PASS: watchdog targeted the CURRENT validated authority $ENC_PGID" || { say "  FAIL: watchdog line/target mismatch"; STRIKE=1; }
  awk -v e="$el" -v w="$WD_TERM_AT" 'BEGIN{exit !(e>=w-1.5 && e<=w+3)}' && say "  PASS: fired inside [${WD_TERM_AT}-1.5, ${WD_TERM_AT}+3] s" || { say "  FAIL: timing $el s"; STRIKE=1; }
  [ -s "$CURF" ] && { say "  FAIL: authority not cleared"; STRIKE=1; } || say "  PASS: authority cleared after the watchdog-terminated enclosure retired"
  owned_cleanup

elif [ "$SET" = neg2 ]; then
  # ---------- N4: caller-group decoy — a process in the DRIVER's own group, unrecorded, name outside every pattern, must survive a normal (K2-like)
  # and an exceptional (K3-like TERM) runner cleanup, the driver's owned cleanup, and the active-vs-retired checks; then the driver ends it itself.
  need N4-caller-group-decoy 34
  bash -c 'exec -a s2r56-caller-decoy sleep 60' </dev/null >/dev/null 2>&1 & DECOY=$!; sleep 0.2; dpg=$(ps -o pgid= -p "$DECOY" | tr -d ' ')
  [ "$dpg" = "$MY_PGID" ] && say "  decoy pid=$DECOY in the driver's own group $dpg (UNRECORDED, outside every pattern)" || { say "  FAIL: decoy group $dpg != driver group $MY_PGID"; STRIKE=1; }
  CUR=n4a; run_runner "$RUNNER" "$OUT56" 15 S2_RUNNER_STUBS=$STUBS
  expect "$O/exit-codes.txt" '^final=0 first_exit=0 cleanup_exit=0 signal=none reap=ok' "N4a normal path final=0"
  alive "$DECOY" && say "  PASS: decoy survived the normal-path runner cleanup" || { say "  FAIL: decoy killed by normal path"; STRIKE=1; }
  owned_cleanup
  CUR=n4b; KA=8 run_runner "$RUNNER" "$OUT56" 4 STUB_HARNESS_MODE=sleep STUB_HARNESS_SLEEP=30 S2_RUNNER_STUBS=$STUBS   # outer TERM at 4 s while step 40 sleeps (K3 shape)
  expect "$O/exit-codes.txt" '^final=143 first_exit=143 cleanup_exit=0 signal=TERM reap=ok' "N4b exceptional (TERM) path: signal exit, cleanup clean"
  [ "$RC" = 124 ] || { say "  FAIL: N4b outer exit $RC (expected 124)"; STRIKE=1; }
  alive "$DECOY" && say "  PASS: decoy survived the exceptional-path runner cleanup (group signals hit only self-published groups)" || { say "  FAIL: decoy killed by exceptional path"; STRIKE=1; }
  owned_cleanup
  alive "$DECOY" && say "  PASS: decoy survived the driver's owned cleanup (record-based only)" || { say "  FAIL: decoy killed by owned cleanup"; STRIKE=1; }
  [ "$(grep -c '^g' "$OWNED")" = 0 ] && say "  PASS: no retired group remains a record/target after prune (active-vs-retired)" || { say "  FAIL: stale group records: $(grep '^g' "$OWNED" | tr '\n' ' ')"; STRIKE=1; }
  [ -s "$CURF" ] && { say "  FAIL: current authority not cleared"; STRIKE=1; } || say "  PASS: current authority empty between controls (watchdog has no stale target)"
  kill -TERM "$DECOY" 2>/dev/null; wait "$DECOY" 2>/dev/null; alive "$DECOY" && { say "  FAIL: decoy could not be ended by its owner"; STRIKE=1; } || say "  decoy ended by the driver itself (its owner)"
  # ---------- N5a: deterministic PUBLICATION FAILURE (stub seam STUB_PUBLISH_FAIL=10-guard-spec): the leader cannot publish → exits 70 before exec;
  # the runner refuses 70; the guard-spec workload NEVER ran; nothing survives; receipt/publication ok.
  need N5a-publication-failure 10; CUR=n5a; run_runner "$RUNNER" "$OUT56" 8 STUB_PUBLISH_FAIL=10-guard-spec S2_RUNNER_STUBS=$STUBS
  expect "$O/stamp.txt" '^SEAM: 10-guard-spec publish target made unwritable' "N5a seam engaged"
  expect "$O/stamp.txt" '^10-guard-spec: leader pid=[0-9]+ exited rc=70 WITHOUT an adoptable published identity' "N5a leader self-exited 70 (publish failed → no exec)"
  expect "$O/exit-codes.txt" '^final=70 first_exit=70 cleanup_exit=0 signal=none reap=ok' "N5a refused 70, cleanup clean"
  expect "$O/exit-codes.txt" 'guard_spec=notrun refusal_hosted=notrun .* fixture_stop=notrun survivors=none' "N5a no later step, no fixture stop, no survivors"
  grep -q 'stub guard spec' "$O/10-guard-spec.log" 2>/dev/null && { say "  FAIL: guard-spec workload RAN despite publication failure"; STRIKE=1; } || say "  PASS: guard-spec workload never started (no stub output)"
  [ "$RC" = 70 ] || { say "  FAIL: exit $RC"; STRIKE=1; }; owned_cleanup
  # ---------- N5b: deterministic INTERRUPTION between publication and adoption (stub seam STUB_HOLD_ACK=40-composition). A driver-owned seam
  # controller waits for the runner's SEAM stamp line, then TERMs the runner pid (read from its own 'lock acquired pid=' stamp). Expected: the runner
  # adopts the published-but-unacked identity, group-signals it, reaps, stops the fixture, exits 143; the harness workload NEVER ran.
  need N5b-startup-interruption 16; CUR=n5b; before=$(ls -1d "$OUT56"/*/ 2>/dev/null)
  ( for ((i=0;i<100;i++)); do d=$(comm -13 <(echo "$before") <(ls -1d "$OUT56"/*/ 2>/dev/null) | tail -1); [ -n "$d" ] && grep -q '^SEAM: 40-composition identity [0-9]* read; HOLDING' "$d/stamp.txt" 2>/dev/null && break; sleep 0.1; done
    p=$(sed -n 's/^lock acquired pid=\([0-9]*\) .*/\1/p' "$d/stamp.txt" 2>/dev/null | head -1); echo "seam controller: seam seen after $((i/10)).$((i%10))s in ${d:-NONE}; TERM runner pid=${p:-NONE}"; [ -n "$p" ] && kill -TERM "$p" ) >"$CTL/n5b.seam-controller.log" 2>&1 & SEAMC=$!; record "$SEAMC"
  run_runner "$RUNNER" "$OUT56" 12 STUB_HOLD_ACK=40-composition S2_RUNNER_STUBS=$STUBS; wait "$SEAMC" 2>/dev/null; sed 's/^/    /' "$CTL/n5b.seam-controller.log" | tee -a "$R"
  expect "$O/stamp.txt" '^SEAM: 40-composition identity [0-9]+ read; HOLDING before adoption/ack' "N5b seam engaged (published, not yet adopted)"
  expect "$O/stamp.txt" "^SIGNAL SIGTERM .* during step '40-composition'" "N5b TERM arrived during the held step"
  expect "$O/stamp.txt" "^HALT: in-flight step '40-composition' pid=[0-9]+ had a PUBLISHED but unadopted identity [0-9]+ → adopted now and signalled as a group" "N5b published identity resolved at interruption (adopted, group-signalled)"
  expect "$O/exit-codes.txt" '^final=143 first_exit=143 cleanup_exit=0 signal=TERM reap=ok' "N5b signal exit, reap ok, cleanup clean"
  expect "$O/exit-codes.txt" 'composition=interrupted\(TERM\) s1_r4_discriminator=notrun fixture_stop=0 survivors=none' "N5b step interrupted, fixture stopped, no survivors"
  grep -q 'stub harness' "$O/40-composition.log" 2>/dev/null && { say "  FAIL: harness workload RAN before adoption"; STRIKE=1; } || say "  PASS: harness workload never started (unacked leader never exec'd)"
  [ "$RC" = 143 ] || { say "  FAIL: exit $RC"; STRIKE=1; }; owned_cleanup
  # ---------- N6: intentional HANDOFF FAILURE — a separately owned controller (own session) holds the private lane lock while a nested child driver
  # (set probe) passes its only control; the child's final gate must return 4 with 'lane lock HELD', evidence preserved; the controller is then ended
  # by its owner (this driver) and the lock re-observed FREE.
  need N6-handoff-failure-lock-held 18
  setsid bash -c 'exec flock "$1" sleep 40' _ "$STUBS/test-validation.lock" </dev/null >/dev/null 2>&1 & HOLDER=$!; sleep 0.3
  flock -n "$STUBS/test-validation.lock" true 2>/dev/null && { say "  FAIL: lane lock not held by the controller"; STRIKE=1; } || say "  controller pid=$HOLDER (own session, separately owned, NOT recorded) holds the lane lock"
  enclose n6 "$(clip 12)" 5 env CTL_SET=probe CTL_BUDGET=20 bash "$0" >"$CTL/n6.child.log" 2>&1; rc=$RC; say "  N6 child driver exit=$rc (expected 4)"; grep -h 'HANDOFF FAILURE' "$CTL/n6.child.log" | head -1 | sed 's/^/    /' | tee -a "$R"
  [ "$rc" = 4 ] && say "  PASS: aggregate 4 on a non-free lane lock" || { say "  FAIL: exit $rc"; STRIKE=1; }
  grep -q 'HANDOFF FAILURE: .* lane lock HELD' "$CTL/n6.child.log" && say "  PASS: gate names the held lane lock" || { say "  FAIL: no lock handoff line"; STRIKE=1; }
  grep -q 'PASS: probe enclosure rc=0' "$CTL/n6.child.log" && grep -q 'controls_run=1/1' "$CTL/n6.child.log" && say "  PASS: assertions passed yet handoff refused (assertions ≠ handoff)" || { say "  FAIL: probe control did not complete as expected"; STRIKE=1; }
  grep -q 'CONTROLS_RECEIPT: publication_status=ok aggregate_exit=4' "$CTL/n6.child.log" && say "  PASS: child evidence published with aggregate 4" || { say "  FAIL: child publication line missing"; STRIKE=1; }
  kill -TERM -- "-$HOLDER" 2>/dev/null; wait "$HOLDER" 2>/dev/null; sleep 0.2; flock -n "$STUBS/test-validation.lock" true 2>/dev/null && say "  controller ended by its owner; lane lock FREE again" || { say "  FAIL: lane lock still held after controller cleanup"; STRIKE=1; }
  owned_cleanup
  # ---------- N7: watchdog fires on schedule against the CURRENT authority, escalation path recorded, no sleeper residue after stop (nested wdtest driver)
  need N7-watchdog-fires-no-sleeper 28; CUR=n7
  enclose n7 "$(clip 24)" 3 env CTL_SET=wdtest CTL_BUDGET=20 bash "$0" >"$CTL/n7.child.log" 2>&1; rc=$RC; say "  N7 child driver exit=$rc (expected 0)"
  [ "$rc" = 0 ] && say "  PASS: wdtest child exit 0" || { say "  FAIL: exit $rc"; STRIKE=1; }
  grep -q '^WATCHDOG fired .* current_authority=[0-9]* → TERM group' "$CTL/n7.child.log" && say "  PASS: watchdog fired against the current authority" || { say "  FAIL: no watchdog line"; STRIKE=1; }
  grep -q 'watchdog stopped: shell=[0-9]* sleeper=[0-9]* census_after=\[empty\]' "$CTL/n7.child.log" && say "  PASS: watchdog shell and owned sleeper both gone (no sleeper residue)" || { say "  FAIL: watchdog census not empty"; STRIKE=1; }
  grep -q 'PASS: watchdog targeted the CURRENT validated authority' "$CTL/n7.child.log" && grep -q 'PASS: authority cleared' "$CTL/n7.child.log" && say "  PASS: current-authority target and retirement observed in child" || { say "  FAIL: child authority checks"; STRIKE=1; }
  owned_cleanup
fi
say; say "SET $SET: all planned controls executed; strike=$STRIKE"; finish 0
