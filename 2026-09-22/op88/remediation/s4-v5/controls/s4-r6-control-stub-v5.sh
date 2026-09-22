#!/usr/bin/env bash
# S4 R6 V5 — control stub runner (kind=CONTROL only). Launched by the V5 launcher exactly like
# the real runner, sources the SAME library (actual `step` wrapper with nested `timeout`, session
# census/reap, latch, signals, expect_exit, publish_exit_record) and verifies the inherited lease
# exactly as the real runner does — against the PRIVATE control lease, never the canonical lock.
# Never touches the worktree, no network; the only workloads are `sleep`/`true`/`flock -n` inside
# the owned session.
set -u
ROOT=/home/user/workspace
V5=$ROOT/execution/s4-r6-validation/v5
RUN_ID=${S4R6_RUN_ID:-}; OUT=${S4R6_OUT:-}; TOKEN=${S4R6_LAUNCH_TOKEN:-}; KIND=${S4R6_KIND:-}; SCENARIO=${S4R6_SCENARIO:-}
[[ -n $RUN_ID && -n $OUT && -d $OUT && -f $OUT/LAUNCH_TOKEN && $(cat "$OUT/LAUNCH_TOKEN") == "$TOKEN" && $TOKEN == "$RUN_ID" ]] || { echo "REFUSE: not launched through the V5 launcher" >&2; exit 71; }
[[ $KIND == CONTROL ]] || { echo "REFUSE: control stub only runs as kind=CONTROL" >&2; exit 71; }
# scenario 'refuse' models a fast leader refusal (e.g. lock busy) BEFORE any handshake/output.
[[ $SCENARIO == refuse ]] && { echo "CONTROL refuse: exiting 71 immediately"; exit 71; }
[[ $(ps -o sid= -p $$ | tr -d ' ') == "$$" && $(ps -o pgid= -p $$ | tr -d ' ') == "$$" ]] || { echo "REFUSE: not session/group leader" >&2; exit 73; }
echo "$$" > "$OUT/RUNNER_PID"
# private lease verification — same predicate shape as the real runner (S4-V3-A-04)
LEASE_PATH=${S4R6_LEASE_PATH:-}; LEASE_PID=${S4R6_LEASE_PID:-}
[[ ${S4R6_LEASE:-} == private-held-by-launcher && -n $LEASE_PID && $LEASE_PID == "$PPID" && $LEASE_PATH == "$V5/control-runs/.private-control-lease.lock" ]] || { echo "REFUSE: private lease not held by launching parent" >&2; exit 75; }
[[ $(readlink /proc/$$/fd/9 2>/dev/null) == "$LEASE_PATH" ]] || { echo "REFUSE: fd 9 is not the private lease" >&2; exit 75; }
SID=$$; SOURCE_CHECK=0
mkdir "$OUT/steps" || exit 70
. "$V5/runner/s4-r6-lib-v5.sh"
RUN_START=$(now)
install_signal_traps
echo "CONTROL scenario=$SCENARIO sid=$SID run=$RUN_ID"
WRITE_SENTINEL=1
case $SCENARIO in
  nested-orphan-after-exit)
    # The command exits 0 but leaves a TERM-immune, reparented grandchild inside the step's own
    # `timeout` process group. The post-step session census must find it (found=1), TERM must not
    # suffice, KILL must, and the session must verify empty.
    step C-nested-orphan 1 20 /tmp bash -c '( trap "" TERM; sleep 300 & ); exit 0'
    ;;
  live-step-interrupt)
    # A live step (sleep 300 under the wrapper's `timeout`) while the launcher deadline fires
    # (S4R6_OUTER_S=4). The session-wide TERM ends the step group; the pending trap only records
    # the signal while the step is active, `step` latches the step's actual exit as PRIMARY and the
    # signal as SECONDARY (S4-V3-A-02), and the record is still written.
    step C-live-step 1 60 /tmp sleep 300
    ;;
  live-step-double-term)
    # S4-V4-A-01 discriminator. Same live step and launcher deadline as above, plus the control-only lib
    # seam (S4R6_SEAM=step-after-reap, passed by the driver): after the step's reap and BEFORE its primary
    # latch the stub sends itself a second TERM inside the metadata zone. V5 must still latch the step's
    # own exit as PRIMARY (blocks[0]=C-live-step) and record BOTH signals as secondary SIGNAL_TERM blocks
    # (>= 2, all after the primary; one of them 'while latching'). Under the V4 ordering the second TERM
    # would have become blocks[0] and stolen the first-failure latch.
    step C-live-step 1 60 /tmp sleep 300
    ;;
  lease-held-by-supervisor)
    # While the workload runs, an OUTSIDE `flock -n` on the private lease must fail (exit 3 here):
    # the launcher, not the workload, holds exclusion. The step child runs with 9>&- so it cannot
    # cheat via the inherited descriptor. Expected-negative predicate: observed 3.
    step C-lease-outside-probe 0 20 /tmp bash -c 'flock -n "$1" true && exit 0 || exit 3' _ "$LEASE_PATH"
    expect_exit C-lease-outside-probe $? 3 "control: outside flock -n on the private lease must be refused while the launcher holds it"
    ;;
  predicate-rc0)
    # Expected-negative predicate violated by an observed exit 0: the run must report a nonzero
    # validation exit (89) while retaining observed_exit=0.
    step C-expected-negative 0 20 /tmp true
    expect_exit C-expected-negative $? 1 "control: command must exit 1 but exits 0"
    ;;
  record-without-sentinel)
    # A parsed SUCCESS record but no sentinel: the launcher must classify FAILED_PUBLICATION even
    # though the runner exits 0 and its record says SUCCESS.
    step C-trivial 1 20 /tmp true
    WRITE_SENTINEL=0
    ;;
  *) echo "REFUSE: unknown control scenario '$SCENARIO'" >&2; exit 71;;
esac
CLEAN_RC=0; reap_owned final || CLEAN_RC=1
census "$OUT/steps/final-census.txt"; [[ -s $OUT/steps/final-census.txt ]] && CLEAN_RC=1
RUN_END=$(now)
RESULT=SUCCESS
if [[ -n $FIRST_FAIL ]]; then RESULT=FAILED; elif [[ $CLEAN_RC != 0 ]]; then RESULT=FAILED_CLEANUP; fi
RESULT=$(publish_exit_record "$RESULT" "$CLEAN_RC" true n/a n/a 0 "$RUN_START" "$RUN_END" "" "" "" "$V5/controls/s4-r6-control-stub-v5.sh" "" "" "" "" "$WRITE_SENTINEL")
echo "CONTROL RESULT=$RESULT first_fail=${FIRST_FAIL:-none}(validation_exit=${FIRST_FAIL_RC:-} observed=${FIRST_FAIL_OBSERVED:-}) cleanup_exit=$CLEAN_RC"
exit "$(result_exit "$RESULT")"
