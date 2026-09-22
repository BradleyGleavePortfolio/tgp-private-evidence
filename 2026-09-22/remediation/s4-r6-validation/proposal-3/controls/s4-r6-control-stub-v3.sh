#!/usr/bin/env bash
# S4 R6 V3 — control stub runner (kind=CONTROL only). Launched by the V3 launcher exactly like
# the real runner, sources the SAME library (actual `step` wrapper with nested `timeout`, session
# census/reap, latch, expect_exit, publish_exit_record). Never opens the canonical lock, never
# touches the worktree, no network; the only workloads are `sleep`/`true` inside the owned session.
set -u
ROOT=/home/user/workspace
V3=$ROOT/execution/s4-r6-validation/v3
RUN_ID=${S4R6_RUN_ID:-}; OUT=${S4R6_OUT:-}; TOKEN=${S4R6_LAUNCH_TOKEN:-}; KIND=${S4R6_KIND:-}; SCENARIO=${S4R6_SCENARIO:-}
[[ -n $RUN_ID && -n $OUT && -d $OUT && -f $OUT/LAUNCH_TOKEN && $(cat "$OUT/LAUNCH_TOKEN") == "$TOKEN" && $TOKEN == "$RUN_ID" ]] || { echo "REFUSE: not launched through the V3 launcher" >&2; exit 71; }
[[ $KIND == CONTROL ]] || { echo "REFUSE: control stub only runs as kind=CONTROL" >&2; exit 71; }
# scenario 'refuse' models a fast leader refusal (e.g. lock busy) BEFORE any handshake/output.
[[ $SCENARIO == refuse ]] && { echo "CONTROL refuse: exiting 71 immediately"; exit 71; }
[[ $(ps -o sid= -p $$ | tr -d ' ') == "$$" && $(ps -o pgid= -p $$ | tr -d ' ') == "$$" ]] || { echo "REFUSE: not session/group leader" >&2; exit 73; }
echo "$$" > "$OUT/RUNNER_PID"
SID=$$; SOURCE_CHECK=0
mkdir "$OUT/steps" || exit 70
. "$V3/runner/s4-r6-lib-v3.sh"
RUN_START=$(now)
INTERRUPTED=""
on_signal() { INTERRUPTED=$1; block "SIGNAL_$1" 143 "outer interruption" 143; reap_owned "signal"; }
trap 'on_signal TERM' TERM; trap 'on_signal INT' INT
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
    # (S4R6_OUTER_S=4). The session-wide TERM must end the step group; the deferred trap then
    # latches SIGNAL_TERM after the step's own primary failure and the record is still written.
    step C-live-step 1 60 /tmp sleep 300
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
RESULT=$(publish_exit_record "$RESULT" "$CLEAN_RC" true n/a n/a 0 "$RUN_START" "$RUN_END" "" "" "" "$V3/controls/s4-r6-control-stub-v3.sh" "" "" "" "" "$WRITE_SENTINEL")
echo "CONTROL RESULT=$RESULT first_fail=${FIRST_FAIL:-none}(validation_exit=${FIRST_FAIL_RC:-} observed=${FIRST_FAIL_OBSERVED:-}) cleanup_exit=$CLEAN_RC"
exit "$(result_exit "$RESULT")"
