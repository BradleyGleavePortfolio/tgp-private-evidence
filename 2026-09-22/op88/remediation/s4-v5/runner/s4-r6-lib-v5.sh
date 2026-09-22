# S4 R6 validation V5 — shared step wrapper / ownership / publication library.
# V5 changes versus V4 (frozen reviews S4-V4-A-01, S4-V4-B-03 / S4-V4-A-N01):
#  * A-01: STEP_ACTIVE stays set through head-state collection, metadata writes AND the primary
#    latch; pending signals are folded in only after the step's own exit is latched. A signal that
#    arrives after deferral ends is handled by the no-active-step path (after the primary), never before.
#  * B-03/N01: EXIT_RECORD.lock names the actual holder (launcher pid from S4R6_LEASE_PID, lease path
#    and kind from the launch environment); the runner only verified inherited fd 9.
#  * Control-only synchronisation seam (S4R6_SEAM=step-after-reap, KIND=CONTROL only): a self-TERM
#    inside the metadata zone gives the A-01 discriminator a deterministic second signal.
# Sourced by runner/s4-r6-validate-v5.sh (kind=VALIDATION) AND by controls/s4-r6-control-stub-v5.sh
# (kind=CONTROL) so the safety controls exercise the ACTUAL nested step wrapper, census, reap,
# latch and record writer — not a re-implementation. No product code, no lock handling here.
#
# Requires from the caller: OUT, RUN_ID, KIND, SID (== $$ of the sourcing session leader),
# SOURCE_CHECK (1: enforce worktree identity after every step; 0: controls), and when
# SOURCE_CHECK=1: WT, EXPECT_HEAD, EXPECT_TREE.
now() { date -u +%FT%TZ; }
sha() { sha256sum "$1" 2>/dev/null | cut -d' ' -f1; }
FIRST_FAIL=""; FIRST_FAIL_RC=""; FIRST_FAIL_REASON=""; FIRST_FAIL_OBSERVED=""; BLOCKS=(); WARNINGS=(); STEPS_JSON=()
REAP_FOUND=0
STEP_ACTIVE=""; PENDING_SIGNAL=""; INTERRUPTED=""

# ---- latch (VPA-05; exit truth A-04) --------------------------------------------------
# block <step> <validation-rc> <reason> [observed-rc]: latch the FIRST blocking failure; later
# steps become NOTRUN. <validation-rc> is the nonzero exit the run must report; <observed-rc>
# is the raw command exit actually seen (kept separately, may be 0 for a violated predicate).
block() {
  local obs=${4:-$2}
  BLOCKS+=("$1 rc=$2 observed=$obs: $3"); echo "BLOCK $1 rc=$2 observed=$obs: $3" | tee -a "$OUT/blocks.log"
  [[ -z $FIRST_FAIL ]] && { FIRST_FAIL=$1; FIRST_FAIL_RC=$2; FIRST_FAIL_REASON=$3; FIRST_FAIL_OBSERVED=$obs; }
  [[ $FIRST_FAIL_RC == 0 || -z $FIRST_FAIL_RC ]] && FIRST_FAIL_RC=89   # a latched failure is never exit 0
  return 0
}
warn() { WARNINGS+=("$1"); echo "WARN $1" | tee -a "$OUT/warnings.log"; }
# expect_exit <step> <observed-rc> <wanted-rc> <what>: expected-negative predicate. A violated
# predicate blocks with validation exit 89 while the observed rc (possibly 0) is retained.
expect_exit() {
  local id=$1 obs=$2 want=$3 what=$4
  [[ $obs == 99 ]] && return 0   # NOTRUN
  if [[ $obs == "$want" ]]; then echo "PREDICATE_OK $id observed=$obs wanted=$want ($what)" | tee -a "$OUT/predicates.log"; return 0; fi
  echo "PREDICATE_VIOLATED $id observed=$obs wanted=$want ($what)" | tee -a "$OUT/predicates.log"
  block "$id" 89 "expected-negative predicate violated: observed rc=$obs, wanted rc=$want ($what)" "$obs"
}

# ---- ownership census / reap (VPA-01, A-01/F-01) -------------------------------------------
# The owned boundary is the SESSION created by the launcher's setsid (SID == $$). `timeout`
# puts every step into its own process group inside that session; a session census sees
# those groups, reparented orphans, npm/Vitest workers, node probes and Chrome alike. Only
# processes that call setsid() themselves escape (recorded limitation; none of the native
# consumers spawn detached). pgrep runs as a direct child (no subshell) and excludes itself.
census() { pgrep -s "$SID" > "$1.raw" 2>/dev/null; grep -vx "$$" "$1.raw" > "$1" || :; rm -f "$1.raw"; }
# signal_listed <file> <SIG>: signal every distinct foreign process group in the session
# (-pgid, reaches members that appeared between census and kill) and then every listed PID.
signal_listed() {
  local f=$1 sig=$2 p g
  while read -r p; do g=$(ps -o pgid= -p "$p" 2>/dev/null | tr -d ' '); [[ -n $g && $g != "$$" ]] && kill "-$sig" -- "-$g" 2>/dev/null; done < "$f"
  while read -r p; do kill "-$sig" "$p" 2>/dev/null; done < "$f"
  return 0
}
# reap_owned <label>: TERM owned orphans, wait ≤10 s, KILL, wait ≤5 s, verify session empty.
# Sets REAP_FOUND to the number found before signalling. Returns 0 only if verifiably empty.
reap_owned() {
  local label=$1            # S4-V3-A-01: declare first; the dependent path is a SEPARATE command
  local f=$OUT/steps/reap-$label.txt i
  census "$f"; REAP_FOUND=$(wc -l < "$f" | tr -d ' ')
  [[ -s $f ]] || { echo "$(now) $label: no owned orphans (session $SID)" >> "$OUT/reaps.log"; return 0; }
  { echo "$(now) $label: owned orphans found=$REAP_FOUND:"; while read -r p; do printf '  pid=%s pgid=%s :: ' "$p" "$(ps -o pgid= -p "$p" 2>/dev/null | tr -d ' ')"; tr '\0' ' ' < /proc/$p/cmdline 2>/dev/null | cut -c1-160; echo; done < "$f"; } >> "$OUT/reaps.log"
  signal_listed "$f" TERM
  for ((i=0;i<10;i++)); do census "$f"; [[ -s $f ]] || break; sleep 1; done
  if [[ -s $f ]]; then signal_listed "$f" KILL; for ((i=0;i<5;i++)); do census "$f"; [[ -s $f ]] || break; sleep 1; done; fi
  if [[ -s $f ]]; then echo "$(now) $label: SURVIVORS after KILL: $(tr '\n' ' ' < "$f")" >> "$OUT/reaps.log"; return 1; fi
  echo "$(now) $label: reaped $REAP_FOUND, session verified empty" >> "$OUT/reaps.log"; return 0
}

# ---- signals (S4-V3-A-02) -----------------------------------------------------------------------
# Bash runs a pending trap when the foreground command completes, BEFORE the next command, and
# restores $? afterwards. While a step is active the handler therefore only records the signal
# (one assignment, no latch, no re-entrant cleanup); `step` then captures the actual command exit,
# latches it as the PRIMARY failure and records the signal as the SECONDARY block. With no active
# step the signal itself is the primary failure and cleanup runs immediately.
on_signal() {
  if [[ -n $STEP_ACTIVE ]]; then PENDING_SIGNAL=$1; INTERRUPTED=$1; return 0; fi
  INTERRUPTED=$1; block "SIGNAL_$1" 143 "outer interruption with no active step" 143; reap_owned "signal"
}
install_signal_traps() { trap 'on_signal TERM' TERM; trap 'on_signal INT' INT; }

head_state() {
  if [[ ${SOURCE_CHECK:-0} == 1 ]]; then git -C "$WT" rev-parse HEAD; git -C "$WT" rev-parse 'HEAD^{tree}'; git -C "$WT" status --porcelain | wc -l | tr -d ' '
  else echo n/a; echo n/a; echo 0; fi
}

# step <id> <required:1|0> <timeout-s> <cwd> <command...>
# required=1: nonzero exit blocks (latched FIRST, before any cleanup/source finding of the same
# step, so the primary command failure is what the run reports). required=0: the caller applies
# expect_exit. Always: bounded by timeout(+30 s KILL) in its own process group, lock fd closed for
# the child (9>&-), worktree identity stamped before/after, owned orphans reaped and verified.
step() {
  local id=$1 required=$2 tmo=$3 cwd=$4; shift 4
  local log=$OUT/steps/$id.log meta=$OUT/steps/$id.json
  if [[ -n $FIRST_FAIL ]]; then
    printf '{"step":"%s","status":"NOTRUN","reason":"latched by %s (%s)"}\n' "$id" "$FIRST_FAIL" "$FIRST_FAIL_REASON" > "$meta"
    STEPS_JSON+=("$(cat "$meta")"); return 99
  fi
  read -r h0 t0 d0 < <(head_state | tr '\n' ' ')
  local start; start=$(now); local s0; s0=$(date +%s)
  echo "[$start] $id cwd=$cwd head=$h0 dirty=$d0 :: $*" | tee "$log"
  STEP_ACTIVE=$id; PENDING_SIGNAL=""
  ( cd "$cwd" && exec timeout --kill-after=30 "$tmo" "$@" ) >>"$log" 2>&1 9>&-
  local rc=$?
  local end; end=$(now); local dur=$(( $(date +%s) - s0 ))
  local reap_ok=true; reap_owned "$id" || reap_ok=false     # still "active": a signal here is recorded, not re-entered
  # S4-V4-A-01: deferral is NOT ended here. STEP_ACTIVE stays set through head-state, metadata and the
  # primary latch below; a signal in that zone is recorded into PENDING_SIGNAL and folded in as SECONDARY.
  local pending=$PENDING_SIGNAL; PENDING_SIGNAL=""
  # control-only deterministic seam (A-01 discriminator): second TERM to ourselves inside the metadata zone
  if [[ ${KIND:-} == CONTROL && ${S4R6_SEAM:-} == step-after-reap ]]; then echo "SEAM step-after-reap: kill -TERM $$ (metadata zone, before primary latch)" | tee -a "$log"; kill -TERM "$$"; fi
  local found=$REAP_FOUND
  read -r h1 t1 d1 < <(head_state | tr '\n' ' ')
  local timed_out=false; [[ $rc == 124 || $rc == 137 ]] && timed_out=true
  local status=PASS; [[ $rc != 0 ]] && status=FAIL; [[ $required == 0 ]] && status="EXIT_$rc"
  local cmdjson; cmdjson=$(printf '%s ' "$@" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read().strip()))')
  printf '{"step":"%s","required":%s,"status":"%s","exit":%s,"timed_out":%s,"signal_during_step":"%s","timeout_s":%s,"start":"%s","end":"%s","duration_s":%s,"head_before":"%s","dirty_before":%s,"head_after":"%s","tree_after":"%s","dirty_after":%s,"owned_orphans_found":%s,"orphans_reaped_verified":%s,"cwd":"%s","command":%s,"log":"%s"}\n' \
    "$id" "$required" "$status" "$rc" "$timed_out" "$pending" "$tmo" "$start" "$end" "$dur" "$h0" "$d0" "$h1" "$t1" "$d1" "$found" "$reap_ok" "$cwd" "$cmdjson" "$log" > "$meta"
  STEPS_JSON+=("$(cat "$meta")")
  echo "[$end] $id exit=$rc (${dur}s) orphans_found=$found reaped_verified=$reap_ok" | tee -a "$log"
  [[ $rc == 0 || $required == 0 ]] || block "$id" "$rc" "required step failed${pending:+ (outer $pending received during step)}" "$rc"   # PRIMARY latch
  [[ -z $pending ]] || block "SIGNAL_$pending" 143 "outer interruption received during step $id (secondary; primary is the step's own exit)" 143
  [[ $reap_ok == true ]] || block "$id" 96 "owned orphan(s) survived TERM/KILL — cleanup unverified" "$rc"
  if [[ ${SOURCE_CHECK:-0} == 1 ]]; then [[ $h1 == "$EXPECT_HEAD" && $d1 == 0 ]] || block "$id" 98 "worktree not at exact clean head afterwards (head=$h1 dirty=$d1)" "$rc"; fi
  # S4-V4-A-01: end deferral only now. A signal recorded during the metadata/latch zone is blocked here as
  # a further SECONDARY block; a signal arriving after this line takes the no-active-step path (also after
  # the primary). Nothing is dropped and nothing precedes the step's own latched exit.
  STEP_ACTIVE=""
  if [[ -n $PENDING_SIGNAL ]]; then local late=$PENDING_SIGNAL; PENDING_SIGNAL=""; block "SIGNAL_$late" 143 "outer interruption received while latching step $id (secondary; primary already latched)" 143; fi
  return $rc
}

# ---- durable record + sentinel (VPA-02; JSON-safe: every value goes through argv) ---------------
# publish_exit_record <RESULT> <CLEAN_RC> <SOURCE_OK:true|false> <FH> <FT> <FD> <RUN_START> <RUN_END>
#                     <HARNESS_BLOCKED> <EXPECT_HEAD> <EXPECT_TREE> <RUNNER_PATH> <PIPE_PATH> <CHROME> <ZIP> <ZIP_SHA> <WRITE_SENTINEL:1|0>
# Writes EXIT_RECORD.json.tmp → parses → renames → (if WRITE_SENTINEL=1) sentinel. Echoes the
# final result name (may become FAILED_PUBLICATION). Never SUCCESS without a parsed record.
publish_exit_record() {
  local result=$1 clean_rc=$2 source_ok=$3 fh=$4 ft=$5 fd=$6 start=$7 end=$8 blocked=$9 head=${10} tree=${11} runner=${12} pipe=${13} chrome=${14} zipp=${15} zsha=${16} write_sentinel=${17}
  local summary=$OUT/EXIT_RECORD.json
  # S4-V4-B-03 / A-N01: the lease holder is the LAUNCHER (S4R6_LEASE_PID); path/kind come from the launch environment.
  python3 - "$summary.tmp" "$RUN_ID" "$KIND" "$result" "$FIRST_FAIL" "${FIRST_FAIL_RC:-}" "$FIRST_FAIL_REASON" "${FIRST_FAIL_OBSERVED:-}" "$clean_rc" "$source_ok" "$fh" "$ft" "$fd" "$start" "$end" "$SID" "$blocked" "$head" "$tree" "$runner" "$pipe" "$chrome" "$zipp" "$zsha" "${S4R6_LEASE_PATH:-}" "${S4R6_LEASE:-}" "${S4R6_LEASE_PID:-}" "${BLOCKS[@]}" --WARN-- "${WARNINGS[@]}" --STEPS-- "${STEPS_JSON[@]}" <<'PY'
import json,sys,hashlib
a=sys.argv[1:]; (out,run_id,kind,result,ff,ffrc,ffreason,ffobs,clean_rc,source_ok,fh,ft,fd,start,end,sid,blocked,head,tree,runner,pipe,chrome,zipp,zsha,lease_path,lease_kind,lease_pid)=a[:27]
rest=a[27:]; w=rest.index("--WARN--"); s=rest.index("--STEPS--"); blocks=rest[:w]; warns=rest[w+1:s]; steps=[json.loads(x) for x in rest[s+1:]]
def h(p):
    try: return hashlib.sha256(open(p,'rb').read()).hexdigest()
    except Exception as e: return f"missing:{e}"
def num(x):
    try: return int(x)
    except Exception: return None
json.dump({"kind":kind,"run_id":run_id,"result":result,
 "result_semantics":{"SUCCESS":"every required step exit 0, expected-negatives correct, all joins/pins verified, owned session verifiably empty, source clean at exact head, this record parsed — builder evidence only, NOT acceptance",
   "WARNINGS":"as SUCCESS but informational warnings recorded; not success","FAILED":"first blocking failure latched; dependents NOTRUN","HARNESS_BLOCKED":"browser transport/runtime unavailable; not a product failure; no retry",
   "FAILED_CLEANUP":"steps passed but owned-process cleanup not verified or unowned proof Chrome present","FAILED_SOURCE_STATE":"steps passed but worktree not clean at exact head afterwards","FAILED_PUBLICATION":"record could not be written/parsed; no sentinel"},
 "first_failure":{"step":ff or None,"validation_exit":num(ffrc),"observed_exit":num(ffobs),"reason":ffreason or None},"blocks":blocks,"warnings":warns,
 "cleanup":{"exit":num(clean_rc),"owned_sid":num(sid),"final_source":{"head":fh,"tree":ft,"dirty":num(fd),"clean_at_exact_head":source_ok=="true"}},
 "harness_blocked":blocked or None,"expected_head":head or None,"expected_tree":tree or None,
 "lock":{"path":lease_path or None,"kind":lease_kind or None,"holder":"launcher","holder_pid":num(lease_pid),"runner_sid":num(sid),"mode":("canonical lock: flock -n held by launcher pid %s from before spawn through verified supervisor cleanup; runner verified inherited fd 9 only; step children 9>&-" % lease_pid) if kind=="VALIDATION" else ("private control lease held by launcher pid %s; runner verified inherited fd 9 only; controls never open the canonical lock" % lease_pid)},
 "runner_sha256":h(runner) if runner else None,"pipe_v5_sha256":h(pipe) if pipe else None,"chrome":{"path":chrome or None,"sha256":h(chrome) if chrome else None},"zip":{"path":zipp or None,"actual_sha256":zsha or None},
 "start_utc":start,"end_utc":end,"steps":steps},open(out,"w"),indent=2)
PY
  local pub_rc=$?
  if [[ $pub_rc == 0 ]] && python3 -c 'import json,sys;json.load(open(sys.argv[1]))' "$summary.tmp" 2>/dev/null && mv "$summary.tmp" "$summary"; then
    if [[ $write_sentinel == 1 ]]; then echo "$result $(now) first_fail=${FIRST_FAIL:-none} cleanup_exit=$clean_rc" > "$OUT/RUN_COMPLETE.sentinel"; fi
    echo "$result"
  else
    echo "exit record could not be written/parsed — NO sentinel" | tee -a "$OUT/blocks.log" >&2
    echo FAILED_PUBLICATION
  fi
}
# result_exit <RESULT>: process exit for a result name (first failure's validation exit for FAILED)
result_exit() {
  case $1 in
    SUCCESS) echo 0;; WARNINGS) echo 3;; FAILED_CLEANUP) echo 4;; FAILED_SOURCE_STATE) echo 6;; FAILED_PUBLICATION) echo 7;; HARNESS_BLOCKED) echo 8;;
    *) if [[ -n ${FIRST_FAIL_RC:-} && $FIRST_FAIL_RC != 0 ]]; then echo "$FIRST_FAIL_RC"; else echo 1; fi;;
  esac
}
