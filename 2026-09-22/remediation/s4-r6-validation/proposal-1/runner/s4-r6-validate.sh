#!/usr/bin/env bash
# S4 R6 — named immutable native validation runner for exact head 91990ae9 (V1).
#
# Invoke ONLY under a named parent grant, as its own process group so the parent
# can bound it:   setsid bash runner/s4-r6-validate.sh <RUN_ID>
# Everything this runner spawns is a descendant of $$; cleanup signals ONLY that
# subtree (never platform/unowned processes). The canonical heavy lock is held
# for the whole run via flock -n (exit 75 and nothing runs if busy).
#
# Fail-closed: the first failed REQUIRED step stops all later steps (no stale
# dist, no browser on an unvalidated package). The first failure exit is
# preserved separately from the cleanup exit. Unexpected outcomes (count
# mismatch, discriminator sign) are recorded as ANOMALIES; a run with anomalies
# is never reported as SUCCESS. No retries, no forceExit, no hidden install
# beyond the two named setup steps (npm ci from the locked lockfile; pinned,
# checksum-verified gitleaks 8.30.0 — the ONLY network use, both in S1x).
set -u
RUN_ID=${1:?run id required}
ROOT=/home/user/workspace
WT=$ROOT/worktrees/s4-r6
VAL=$ROOT/execution/s4-r6-validation
OUT=$VAL/runs/$RUN_ID
LOCK=$ROOT/execution/test-validation.lock
PRED=$ROOT/execution/s4-r6/predecessor-88287cff
PROBES=$ROOT/execution/s4-r6/probes
TOOLING=$VAL/tooling/gitleaks
CHROME=${TGP_CHROME:-/home/user/.cache/ms-playwright/chromium-1217/chrome-linux64/chrome}

EXPECT_HEAD=91990ae9aec72f47a67591892ac09fa1f59d2f16
EXPECT_TREE=840fb2855953d5363fbd144e11b3f81763d9cef7
EXPECT_PARENT=88287cff47240aa58b5f0fea5da08670f1e87df6
EXPECT_BASE=0111be661922234d670bbf23e23d270eec1b4a4e
EXPECT_LOCK_SHA=262d4b692e9cc1a7908435c36b8a4077d2dc130d37421a7a76175e4acc9cdae8
EXPECT_NODE=v20.20.1
EXPECT_NPM=10.8.2
EXPECT_FULL_TESTS=1742   # R4 1714 + R5 25 + R6 3 (arithmetic, not proof; mismatch = anomaly)
EXPECT_PREFLIGHT_TESTS=19

mkdir -p "$OUT/steps" "$OUT/dist" || exit 70
SUMMARY=$OUT/EXIT_RECORD.json
FIRST_FAIL=""; FIRST_FAIL_RC=""; ANOMALIES=(); STEPS_JSON=()
RUN_START=$(date -u +%FT%TZ)

# ---- lock --------------------------------------------------------------------
exec 9>"$LOCK"
if ! flock -n 9; then
  echo "LOCK BUSY: $LOCK — refusing to run ($RUN_ID)" >&2
  exit 75
fi
echo "$$ $RUN_ID $(date -u +%FT%TZ)" >&9
LOCK_HOLDER=$$

# Outer TERM/INT (parent bounding the group): mark INTERRUPTED so every later
# required step is NOTRUN, terminate owned descendants, then fall through to the
# normal cleanup + exit record (the interruption is the recorded first failure).
INTERRUPTED=""
on_signal() {
  INTERRUPTED=$1; echo "[$(date -u +%FT%TZ)] received $1 — halting owned work" | tee -a "$OUT/anomalies.log"
  [[ -z $FIRST_FAIL ]] && { FIRST_FAIL="SIGNAL_$1"; FIRST_FAIL_RC=143; }
  for p in $(descendants $$); do kill -TERM "$p" 2>/dev/null; done
}
trap 'on_signal TERM' TERM
trap 'on_signal INT' INT
sha() { sha256sum "$1" 2>/dev/null | cut -d' ' -f1; }
# All live descendants of a pid (recursive pgrep -P; no pstree dependency).
descendants() { local p; for p in $(pgrep -P "$1" 2>/dev/null); do echo "$p"; descendants "$p"; done; }
now() { date -u +%FT%TZ; }
head_state() {
  git -C "$WT" rev-parse HEAD; git -C "$WT" rev-parse 'HEAD^{tree}'; git -C "$WT" status --porcelain | wc -l | tr -d ' '
}

# step <id> <required:1|0> <timeout-s> <cwd> <command...>
# Records head/tree/dirty before and after, start/end, exit, timeout flag.
step() {
  local id=$1 required=$2 tmo=$3 cwd=$4; shift 4
  local log=$OUT/steps/$id.log meta=$OUT/steps/$id.json
  if [[ -n $FIRST_FAIL && $required == 1 ]]; then
    printf '{"step":"%s","status":"NOTRUN","reason":"earlier required failure %s"}\n' "$id" "$FIRST_FAIL" > "$meta"
    STEPS_JSON+=("$(cat "$meta")"); return 0
  fi
  read -r h0 t0 d0 < <(head_state | tr '\n' ' ')
  local start; start=$(now); local s0; s0=$(date +%s)
  echo "[$start] $id cwd=$cwd head=$h0 tree=$t0 dirty=$d0 :: $*" | tee "$log"
  ( cd "$cwd" && timeout --kill-after=30 "$tmo" "$@" ) >>"$log" 2>&1
  local rc=$?
  local end; end=$(now); local dur=$(( $(date +%s) - s0 ))
  read -r h1 t1 d1 < <(head_state | tr '\n' ' ')
  local timed_out=false; [[ $rc == 124 || $rc == 137 ]] && timed_out=true
  local status=PASS; [[ $rc != 0 ]] && status=FAIL
  printf '{"step":"%s","required":%s,"status":"%s","exit":%s,"timed_out":%s,"timeout_s":%s,"start":"%s","end":"%s","duration_s":%s,"head_before":"%s","tree_before":"%s","dirty_before":%s,"head_after":"%s","tree_after":"%s","dirty_after":%s,"cwd":"%s","command":%s,"log":"%s"}\n' \
    "$id" "$required" "$status" "$rc" "$timed_out" "$tmo" "$start" "$end" "$dur" "$h0" "$t0" "$d0" "$h1" "$t1" "$d1" "$cwd" "$(printf '%s ' "$@" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read().strip()))')" "$log" > "$meta"
  STEPS_JSON+=("$(cat "$meta")")
  echo "[$end] $id exit=$rc (${dur}s)" | tee -a "$log"
  if [[ $rc != 0 && $required == 1 && -z $FIRST_FAIL ]]; then FIRST_FAIL=$id; FIRST_FAIL_RC=$rc; fi
  if [[ $h1 != "$EXPECT_HEAD" || $d1 != 0 ]]; then ANOMALIES+=("$id: worktree not at expected clean head afterwards (head=$h1 dirty=$d1)"); [[ -z $FIRST_FAIL ]] && { FIRST_FAIL=$id; FIRST_FAIL_RC=98; }; fi
  return $rc
}
anomaly() { ANOMALIES+=("$1"); echo "ANOMALY: $1" | tee -a "$OUT/anomalies.log"; }

# ---- S00 preconditions (no mutation) ------------------------------------------
{
  H=$(git -C "$WT" rev-parse HEAD); T=$(git -C "$WT" rev-parse 'HEAD^{tree}'); D=$(git -C "$WT" status --porcelain | wc -l | tr -d ' ')
  P=$(git -C "$WT" rev-parse HEAD^); NODE=$(node --version); NPM=$(npm --version); LOCKSHA=$(sha "$WT/package-lock.json")
  ok=1
  [[ $H == "$EXPECT_HEAD" ]] || { echo "PRECONDITION head $H != $EXPECT_HEAD"; ok=0; }
  [[ $T == "$EXPECT_TREE" ]] || { echo "PRECONDITION tree $T"; ok=0; }
  [[ $P == "$EXPECT_PARENT" ]] || { echo "PRECONDITION parent $P"; ok=0; }
  [[ $D == 0 ]] || { echo "PRECONDITION dirty=$D"; ok=0; }
  git -C "$WT" merge-base --is-ancestor "$EXPECT_BASE" HEAD || { echo "PRECONDITION base not ancestor"; ok=0; }
  [[ $(git -C "$WT" rev-parse --is-shallow-repository) == false ]] || { echo "PRECONDITION shallow"; ok=0; }
  [[ $NODE == "$EXPECT_NODE" ]] || { echo "PRECONDITION node $NODE"; ok=0; }
  [[ $NPM == "$EXPECT_NPM" ]] || { echo "PRECONDITION npm $NPM"; ok=0; }
  [[ $LOCKSHA == "$EXPECT_LOCK_SHA" ]] || { echo "PRECONDITION package-lock $LOCKSHA"; ok=0; }
  [[ ! -e $WT/node_modules ]] || { echo "PRECONDITION node_modules already present (not a fresh setup; refuse)"; ok=0; }
  [[ ! -e $WT/dist ]] || { echo "PRECONDITION stale dist present in worktree"; ok=0; }
  [[ -x $CHROME ]] || echo "NOTE: Chrome binary missing at $CHROME — browser steps will report runtime-unavailable (not product failure)"
  if pgrep -f "tgp-browser-proof-|tgp-pipe-discriminator-" >/dev/null; then echo "PRECONDITION leftover proof Chrome processes present (unowned; NOT signalled; refuse)"; ok=0; fi
  echo "runner_sha256=$(sha "$VAL/runner/s4-r6-validate.sh") pipe_probe_sha256=$(sha "$VAL/runner/chrome-pipe-discriminator.mjs") chrome=$CHROME chrome_sha256=$( [[ -x $CHROME ]] && sha "$CHROME" || echo missing )"
  echo "predecessor_export_background_sha256=$(sha "$PRED/background.js") (expect 5a6a4b8b091b302a1acbb60ee23e5d10ddebf439eec1f22942d43e89634ff721)"
  [[ $ok == 1 ]]
} > "$OUT/steps/S00-preconditions.log" 2>&1
S00=$?; cat "$OUT/steps/S00-preconditions.log"
if [[ $S00 != 0 ]]; then FIRST_FAIL=S00-preconditions; FIRST_FAIL_RC=$S00; fi

# ---- S1x setup (the only install/network) -------------------------------------
step S10-npm-ci 1 300 "$WT" npm ci --no-audit --no-fund --loglevel=info
if [[ -z $FIRST_FAIL ]]; then
  {
    echo "node_modules/.package-lock.json sha256=$(sha "$WT/node_modules/.package-lock.json")"
    ( cd "$WT" && npm ls --all --json 2>/dev/null | sha256sum | cut -d' ' -f1 | sed 's/^/npm_ls_all_json_sha256=/' )
    echo "hook_installed=$( [[ -f $WT/.git/hooks/pre-commit ]] && grep -q lefthook "$WT/.git/hooks/pre-commit" && echo yes || echo NO )"
    echo "lefthook_version=$( cd "$WT" && npx --no-install lefthook version 2>/dev/null )"
    echo "vitest_version=$( cd "$WT" && npx --no-install vitest --version 2>/dev/null )"
    echo "eslint=$( cd "$WT" && npx --no-install eslint --version 2>/dev/null ) prettier=$( cd "$WT" && npx --no-install prettier --version 2>/dev/null ) tsc=$( cd "$WT" && npx --no-install tsc --version 2>/dev/null )"
  } > "$OUT/steps/S10b-toolchain-provenance.log" 2>&1
  grep -q 'hook_installed=yes' "$OUT/steps/S10b-toolchain-provenance.log" || anomaly "S10: lefthook pre-commit hook NOT installed by prepare"
fi
step S11-gitleaks-install 1 120 "$WT" bash scripts/install-gitleaks.sh "$TOOLING"
export PATH="$TOOLING:$PATH"
[[ -z $FIRST_FAIL ]] && { gv=$(gitleaks version 2>/dev/null); [[ $gv == 8.30.0 ]] || anomaly "S11: gitleaks version '$gv' != 8.30.0"; }

# ---- S2x deterministic gates (hook-equivalents; 0/6 ran at commit) -------------
export RATIO_BASE=$EXPECT_BASE
step S20-gates 1 300 "$WT" npm run gates
step S21-secrets-exact-range 1 120 "$WT" bash scripts/secrets-scan.sh pr "$EXPECT_PARENT" "$EXPECT_HEAD"
step S22-secrets-full-history 1 120 "$WT" bash scripts/secrets-scan.sh history

# ---- S3x real Vitest ----------------------------------------------------------
step S30-focused-vitest 1 300 "$WT" npx --no-install vitest run --reporter=default --reporter=json --outputFile.json="$OUT/steps/S30-focused.vitest.json" \
  test/session-ownership-preflight.spec.js test/refresh-admission-epoch.spec.js test/session-ownership.spec.js \
  test/refresh-coalesce.spec.js test/ingest-auth.spec.js test/session-refresh-path.spec.js \
  test/session-establishment.spec.js test/start-import-hardening.spec.js test/session-lifecycle.spec.js
if [[ -z $FIRST_FAIL ]]; then
  pf=$(python3 -c 'import json,sys;d=json.load(open(sys.argv[1]));f=[x for x in d["testResults"] if x["name"].endswith("session-ownership-preflight.spec.js")];print(sum(len(x["assertionResults"]) for x in f))' "$OUT/steps/S30-focused.vitest.json" 2>/dev/null)
  [[ $pf == "$EXPECT_PREFLIGHT_TESTS" ]] || anomaly "S30: preflight spec case count '$pf' != $EXPECT_PREFLIGHT_TESTS"
fi
step S31-full-suite 1 900 "$WT" npx --no-install vitest run --passWithNoTests=false --reporter=default --reporter=json --outputFile.json="$OUT/steps/S31-full.vitest.json"
if [[ -z $FIRST_FAIL ]]; then
  tot=$(python3 -c 'import json,sys;d=json.load(open(sys.argv[1]));print(d["numTotalTests"],d["numPassedTests"],d["numFailedTests"],d["numPendingTests"],d.get("numTodoTests",0))' "$OUT/steps/S31-full.vitest.json" 2>/dev/null)
  echo "full_counts(total passed failed pending todo)=$tot" | tee -a "$OUT/steps/S31-full-suite.log"
  read -r total passed failed pending todo <<<"$tot"
  [[ ${total:-0} == "$EXPECT_FULL_TESTS" ]] || anomaly "S31: total tests '${total:-?}' != expected $EXPECT_FULL_TESTS (arithmetic expectation; explain, do not relabel)"
  [[ ${pending:-0} == 0 && ${todo:-0} == 0 ]] || anomaly "S31: skipped/todo present pending=$pending todo=$todo"
fi

# ---- S4x offline discriminators in-slot (record; already run offline) ----------
step S40-a01-late-reporting-candidate-fixed 1 60 "$WT" node "$PROBES/a01-late-reporting-discriminator.mjs" "$WT" --expect fixed
step S41-a01-late-reporting-predecessor-defect 1 60 "$WT" node "$PROBES/a01-late-reporting-discriminator.mjs" "$PRED" --expect defect
step S42-r5-a01-barrier-candidate-fixed 1 60 "$WT" node "$PROBES/reused/a01-preflight-barrier-discriminator.mjs" "$WT" --expect fixed
step S43-r5-a02-queued-refresh-candidate-fixed 1 60 "$WT" node "$PROBES/reused/a02-queued-refresh-discriminator.mjs" "$WT" --expect fixed
step S44-r5B-bound-admission-candidate 1 60 "$WT" node "$PROBES/reused/bound-admission-probe.mjs" "$WT"
# Sign check: the candidate must FAIL the defect expectation (exit 1, not 0/2).
if [[ -z $FIRST_FAIL ]]; then
  step S45-a01-late-reporting-candidate-expect-defect-must-fail 0 60 "$WT" node "$PROBES/a01-late-reporting-discriminator.mjs" "$WT" --expect defect
  [[ $? == 1 ]] || anomaly "S45: inverted expectation on candidate did not exit 1 (expected FAIL_DEFECT_NOT_OBSERVED)"
fi

# ---- S5x package --------------------------------------------------------------
step S50-package 1 120 "$WT" node scripts/package-extension.mjs --root "$WT" --out "$OUT/dist"
ZIP=$(ls "$OUT"/dist/*.zip 2>/dev/null | head -1); INV=${ZIP%.zip}.inventory.json
if [[ -z $FIRST_FAIL ]]; then
  {
    echo "zip=$ZIP sha256=$(sha "$ZIP")"
    python3 - "$INV" "$WT" "$EXPECT_HEAD" <<'PY'
import json,sys,subprocess,hashlib
inv=json.load(open(sys.argv[1])); wt=sys.argv[2]; head=sys.argv[3]
src=inv.get("source",{}); print("inventory.source=",src)
ok = src.get("head")==head and src.get("clean") is True
files = inv.get("files") or inv.get("entries") or []
mism=[]
for f in files:
    p=f.get("path") or f.get("name"); h=f.get("sha256")
    blob=subprocess.run(["git","-C",wt,"show",f"HEAD:{p}"],capture_output=True).stdout
    if hashlib.sha256(blob).hexdigest()!=h: mism.append(p)
print("shipped_files=",len(files),"blob_mismatches=",mism)
print("PACKAGE_BOUND_TO_HEAD" if ok and files and not mism else "PACKAGE_NOT_BOUND")
PY
  } > "$OUT/steps/S50b-package-binding.log" 2>&1
  grep -q PACKAGE_BOUND_TO_HEAD "$OUT/steps/S50b-package-binding.log" || { anomaly "S50: package inventory not bound to exact head / blob mismatch"; FIRST_FAIL=${FIRST_FAIL:-S50b-package-binding}; FIRST_FAIL_RC=${FIRST_FAIL_RC:-97}; }
fi

# ---- S6x browser ---------------------------------------------------------------
HARNESS_BLOCKED=""
step S60-chrome-pipe-cold 1 60 "$WT" node "$VAL/runner/chrome-pipe-discriminator.mjs" --chrome "$CHROME" --label cold --out "$OUT/steps/S60-pipe-cold.json"
step S61-chrome-pipe-warm 1 60 "$WT" node "$VAL/runner/chrome-pipe-discriminator.mjs" --chrome "$CHROME" --label warm --out "$OUT/steps/S61-pipe-warm.json"
if [[ $FIRST_FAIL == S60-chrome-pipe-cold || $FIRST_FAIL == S61-chrome-pipe-warm ]]; then
  HARNESS_BLOCKED="transport: --remote-debugging-pipe produced no CDP response (see S60/S61 json). HARNESS/RUNTIME BLOCK, not product failure, no retry."
fi
step S62-browser-positive 1 180 "$WT" env TGP_CHROME="$CHROME" node scripts/browser-load-proof.mjs --zip "$ZIP" --out "$OUT/steps/S62-browser-load-proof.json"
step S63-browser-negative 1 180 "$WT" env TGP_CHROME="$CHROME" node scripts/browser-load-proof.mjs --negative-control --zip "$ZIP" --out "$OUT/steps/S63-browser-load-proof.negative-control.json"
if [[ -f $OUT/steps/S63-browser-load-proof.negative-control.json ]]; then
  # A proper negative: the named mutation is recorded AND the intended failure
  # signature (no receiver) AND the intended syntax exception were observed, with
  # zero unrelated failures. Exit status alone is insufficient (S4-R5-A-E01).
  python3 - "$OUT/steps/S63-browser-load-proof.negative-control.json" <<'PY' > "$OUT/steps/S63b-negative-criterion.log" 2>&1
import json,sys; e=json.load(open(sys.argv[1])); n=e.get("negativeControl",{}); m=e.get("mutation")
print("mutation=",m); print("negativeControl=",n)
proper = bool(m and m.get("file")=="content/main.js" and m.get("sha256AfterMutation") and n.get("detected") is True and n.get("syntaxExceptionSeen") is True and not n.get("unrelatedFailures"))
print("PROPER_NEGATIVE_ESTABLISHED" if proper else "NEGATIVE_NOT_ESTABLISHED")
PY
  grep -q PROPER_NEGATIVE_ESTABLISHED "$OUT/steps/S63b-negative-criterion.log" || anomaly "S63: negative control not established by full criterion (detected+syntaxExceptionSeen+mutation+no unrelated failures)"
fi

# ---- S7x cleanup (owned subtree only) -----------------------------------------
CLEAN_RC=0
{
  echo "[$(now)] cleanup: owned descendants of $$"
  desc=$(pgrep -P $$ | tr '\n' ' '); echo "direct children: ${desc:-none}"
  for pid in $(descendants $$); do
    cmd=$(tr '\0' ' ' < /proc/$pid/cmdline 2>/dev/null | cut -c1-120)
    echo "TERM owned pid $pid :: $cmd"; kill -TERM "$pid" 2>/dev/null
  done
  sleep 5
  for pid in $(descendants $$); do
    echo "KILL surviving owned pid $pid"; kill -KILL "$pid" 2>/dev/null; CLEAN_RC=1
  done
  left=$(pgrep -af "tgp-browser-proof-|tgp-pipe-discriminator-" || true)
  if [[ -n $left ]]; then echo "SURVIVOR proof Chrome (NOT signalled if not owned): $left"; CLEAN_RC=2; else echo "no proof-profile Chrome survivors"; fi
  echo "worktree after run: head=$(git -C "$WT" rev-parse HEAD) dirty=$(git -C "$WT" status --porcelain | wc -l | tr -d ' ')"
  echo "node_modules retained (evidence of setup; NOT removed): $( [[ -d $WT/node_modules ]] && echo yes || echo no )"
  echo "[$(now)] cleanup exit=$CLEAN_RC"
} > "$OUT/steps/S70-cleanup.log" 2>&1
cat "$OUT/steps/S70-cleanup.log"

# ---- S8x exit record -----------------------------------------------------------
RESULT=SUCCESS
[[ -n $FIRST_FAIL ]] && RESULT=FAILED
[[ -n $HARNESS_BLOCKED ]] && RESULT=HARNESS_BLOCKED
[[ $RESULT == SUCCESS && ${#ANOMALIES[@]} -gt 0 ]] && RESULT=ANOMALY
python3 - "$SUMMARY" "$RUN_ID" "$RESULT" "$FIRST_FAIL" "${FIRST_FAIL_RC:-}" "$CLEAN_RC" "$RUN_START" "$(now)" "$LOCK_HOLDER" "$HARNESS_BLOCKED" "$EXPECT_HEAD" "$EXPECT_TREE" "$VAL/runner/s4-r6-validate.sh" "$VAL/runner/chrome-pipe-discriminator.mjs" "$CHROME" "${ZIP:-}" <<'PY' "${ANOMALIES[@]}" --STEPS-- "${STEPS_JSON[@]}"
import json,sys,hashlib
a=sys.argv; out,run_id,result,first_fail,first_rc,clean_rc,start,end,holder,blocked,head,tree,runner,pipe,chrome,zipp=a[1:17]
rest=a[17:]; i=rest.index("--STEPS--"); anomalies=rest[:i]; steps=[json.loads(s) for s in rest[i+1:]]
def h(p):
    try: return hashlib.sha256(open(p,'rb').read()).hexdigest()
    except Exception as e: return f"missing:{e}"
json.dump({"run_id":run_id,"result":result,"result_semantics":{"SUCCESS":"all required steps exit 0, no anomalies — still NOT acceptance; two independent attestations required","ANOMALY":"all required steps exit 0 but unexpected observations recorded; not success","FAILED":"first required failure recorded; later required steps NOTRUN","HARNESS_BLOCKED":"browser transport dead; not a product failure; no retry"},
 "first_failure":{"step":first_fail or None,"exit":int(first_rc) if first_rc else None},"cleanup_exit":int(clean_rc),
 "harness_blocked":blocked or None,"anomalies":anomalies,"expected_head":head,"expected_tree":tree,
 "lock":{"path":"/home/user/workspace/execution/test-validation.lock","holder_pid":int(holder),"mode":"flock -n held for whole run"},
 "runner_sha256":h(runner),"pipe_probe_sha256":h(pipe),"chrome":{"path":chrome,"sha256":h(chrome)},"zip":{"path":zipp or None,"sha256":h(zipp) if zipp else None},
 "start_utc":start,"end_utc":end,"steps":steps},open(out,"w"),indent=2)
PY
echo "$RESULT $(now) first_fail=${FIRST_FAIL:-none} cleanup_exit=$CLEAN_RC" > "$OUT/RUN_COMPLETE.sentinel"
echo "RESULT=$RESULT first_fail=${FIRST_FAIL:-none}(${FIRST_FAIL_RC:-}) anomalies=${#ANOMALIES[@]} cleanup_exit=$CLEAN_RC record=$SUMMARY"
# Real first exit is preserved in EXIT_RECORD.json; the process exit is the first
# required failure code (or 0), never the cleanup code.
[[ -n $FIRST_FAIL ]] && exit "${FIRST_FAIL_RC:-1}"
[[ $RESULT == SUCCESS ]] && exit 0
exit 3   # ANOMALY: required steps passed but unexpected observations exist
