#!/usr/bin/env bash
# S4 R6 — native validation runner V5 for exact head 91990ae9 (execution-only successor of V4).
# V5 versus V4: paths/names only (v4 -> v5, lib/pipe file names, PIN_PIPE_V5 same bytes c261ffb4…). The
# truthful lock attribution (S4-V4-B-03) lives in the shared library's record writer; steps, pins,
# criteria, joins and the latch are unchanged from V4.
# Launch ONLY through v5/launcher/s4-r6-launch-v5.sh (fresh exclusive run dir, launch
# token, own session, mandatory outer deadline, canonical lease held by the launcher).
# Direct invocation refuses. Step wrapper / census / reap / latch / signals / record writer live
# in runner/s4-r6-lib-v5.sh so the safety controls exercise the identical code.
# V4 (S4-V3-A-04): the runner no longer takes the canonical lock itself. The launcher (outside the
# killable workload) holds it from before spawn until verified supervisor cleanup; the runner only
# VERIFIES the inherited lease (fd 9 → lock path, holder pid == parent, lease flag) and refuses otherwise.
#
# V3 closed the combined V2 findings (A-01..05 / F-01..03) on top of the V2 closures; V4 adds S4-V3-A-01..04:
#  VPA-01 ownership: the owned boundary is this runner's SESSION (SID == $$, guaranteed by the
#          launcher's setsid); `timeout` puts each step into its own process group INSIDE that
#          session, so a `pgrep -s` census sees step groups, reparented orphans, npm/Vitest
#          workers and Chrome; after every step owned orphans are TERM→wait→KILL→verified;
#          unverified = blocking. Step children never inherit the lock descriptor (9>&-).
#  VPA-02 truth: SUCCESS requires cleanup verified, final source clean at exact head, and
#          a parsed durable exit record; sentinel is written only after that record.
#  VPA-03 launch: token/session/deadline come from the launcher; every pre/post command
#          runs as a bounded step.
#  VPA-04 joins: fresh exclusive output; exactly the newly produced inventory/ZIP pair;
#          actual ZIP sha256 == inventory.zip.sha256; files[] == HEAD blobs; browser
#          receipts must name the same actual ZIP hash; probe/predecessor pins enforced.
#  VPA-05 latch: blocking prerequisite failures (hook, gitleaks version, evidence parse/
#          count, discriminator sign, package/negative joins, cleanup) set the latch so
#          dependent steps are NOTRUN, with reason and actual exit preserved.
set -u
ROOT=/home/user/workspace
WT=$ROOT/worktrees/s4-r6
VAL=$ROOT/execution/s4-r6-validation
V5=$VAL/v5
PRED=$ROOT/execution/s4-r6/predecessor-88287cff
PROBES=$ROOT/execution/s4-r6/probes
TOOLING=$VAL/tooling/gitleaks
LOCK=$ROOT/execution/test-validation.lock
CHROME=${TGP_CHROME:-/home/user/.cache/ms-playwright/chromium-1217/chrome-linux64/chrome}
PIPE=$V5/runner/chrome-pipe-discriminator-v5.mjs

EXPECT_HEAD=91990ae9aec72f47a67591892ac09fa1f59d2f16
EXPECT_TREE=840fb2855953d5363fbd144e11b3f81763d9cef7
EXPECT_PARENT=88287cff47240aa58b5f0fea5da08670f1e87df6
EXPECT_BASE=0111be661922234d670bbf23e23d270eec1b4a4e
EXPECT_LOCK_SHA=262d4b692e9cc1a7908435c36b8a4077d2dc130d37421a7a76175e4acc9cdae8
EXPECT_NODE=v20.20.1
EXPECT_NPM=10.8.2
EXPECT_FULL_TESTS=1742        # R4 1714 + R5 25 + R6 3 — arithmetic expectation; mismatch BLOCKS and must be explained, never relabelled
EXPECT_PREFLIGHT_TESTS=19
# Approved input pins (execution/s4-r6/SHA256SUMS; pipe helper bytes identical to V2 c261ffb4…)
PIN_A01_LATE=890d45f782b4ae7ae3492e0c22ad65e37aea719dc945981bff0c68e1fd172fbc
PIN_R5_A01=d1e1d428c257115e0e3aaeaecd25e9a85705c28114d0af8c5ad154c246d5d342
PIN_R5_A02=934658813355cb8e6b4a23bc18f21cddc3ae546b2fdfc338213f9f4738045d16
PIN_R5_B=ae6d3e124a5fb8416d057d3aea9de18da0a1f9b056cb1afd7910ecd5262e3cef
PIN_PIPE_V5=c261ffb408dc5a724a17c5ad0889b500918fde5d1aa29420b39ced4c4d04531b

# ---- launch contract ------------------------------------------------------------
RUN_ID=${S4R6_RUN_ID:-}; OUT=${S4R6_OUT:-}; TOKEN=${S4R6_LAUNCH_TOKEN:-}; KIND=${S4R6_KIND:-}
[[ -n $RUN_ID && -n $OUT && -d $OUT && -f $OUT/LAUNCH_TOKEN && $(cat "$OUT/LAUNCH_TOKEN") == "$TOKEN" && $TOKEN == "$RUN_ID" ]] || { echo "REFUSE: not launched through the V5 launcher (token/out mismatch)" >&2; exit 71; }
[[ $KIND == VALIDATION ]] || { echo "REFUSE: real runner only runs as kind=VALIDATION (got '$KIND'); control runs use the control stub" >&2; exit 71; }
[[ $(ps -o sid= -p $$ | tr -d ' ') == "$$" && $(ps -o pgid= -p $$ | tr -d ' ') == "$$" ]] || { echo "REFUSE: runner is not its own session/group leader" >&2; exit 73; }
echo "$$" > "$OUT/RUNNER_PID"   # ownership handshake: launcher requires this to equal the pid it spawned (setsid exec-in-place)
[[ ! -e $OUT/RUN_COMPLETE.sentinel && ! -e $OUT/EXIT_RECORD.json && ! -e $OUT/steps && ! -e $OUT/dist ]] || { echo "REFUSE: run directory is not fresh" >&2; exit 71; }
SID=$$; SOURCE_CHECK=1
mkdir "$OUT/steps" "$OUT/dist" || exit 70
. "$V5/runner/s4-r6-lib-v5.sh"
RUN_START=$(now)

# ---- canonical lease: VERIFIED, not taken (S4-V3-A-04) -----------------------------------------
# The launcher holds `flock` on fd 9 of $LOCK and passes the descriptor by inheritance. Verify:
# lease flag, holder pid == our parent and alive, fd 9 refers to the canonical lock path. Step
# children still run with 9>&- so no workload can carry the lease beyond the supervisor.
LEASE_PID=${S4R6_LEASE_PID:-}
[[ ${S4R6_LEASE:-} == canonical-held-by-launcher && -n $LEASE_PID && $LEASE_PID == "$PPID" ]] || { echo "REFUSE: canonical lease not held by launching parent (S4R6_LEASE='${S4R6_LEASE:-}', pid='${LEASE_PID}', ppid=$PPID)" >&2; exit 75; }
kill -0 "$LEASE_PID" 2>/dev/null || { echo "REFUSE: lease holder $LEASE_PID not alive" >&2; exit 75; }
[[ $(readlink /proc/$$/fd/9 2>/dev/null) == "$LOCK" ]] || { echo "REFUSE: fd 9 is not the canonical lock ($(readlink /proc/$$/fd/9 2>/dev/null))" >&2; exit 75; }
echo "$$ $RUN_ID $(now) lease-holder=$LEASE_PID" >&9
install_signal_traps

# ---- S00 preconditions and input pins (read-only) ---------------------------------
{
  ok=1; H=$(git -C "$WT" rev-parse HEAD); T=$(git -C "$WT" rev-parse 'HEAD^{tree}'); D=$(git -C "$WT" status --porcelain | wc -l | tr -d ' '); P=$(git -C "$WT" rev-parse HEAD^)
  chk() { [[ $1 == "$2" ]] || { echo "PRECONDITION $3: '$1' != '$2'"; ok=0; }; }
  chk "$H" "$EXPECT_HEAD" head; chk "$T" "$EXPECT_TREE" tree; chk "$P" "$EXPECT_PARENT" parent; chk "$D" 0 dirty
  git -C "$WT" merge-base --is-ancestor "$EXPECT_BASE" HEAD || { echo "PRECONDITION base not ancestor"; ok=0; }
  chk "$(git -C "$WT" rev-parse --is-shallow-repository)" false shallow
  chk "$(node --version)" "$EXPECT_NODE" node; chk "$(npm --version)" "$EXPECT_NPM" npm
  chk "$(sha "$WT/package-lock.json")" "$EXPECT_LOCK_SHA" package-lock
  [[ ! -e $WT/node_modules ]] || { echo "PRECONDITION node_modules present (refuse; fresh npm ci required)"; ok=0; }
  [[ ! -e $WT/dist ]] || { echo "PRECONDITION stale dist in worktree"; ok=0; }
  chk "$(sha "$PROBES/a01-late-reporting-discriminator.mjs")" "$PIN_A01_LATE" pin_a01_late
  chk "$(sha "$PROBES/reused/a01-preflight-barrier-discriminator.mjs")" "$PIN_R5_A01" pin_r5_a01
  chk "$(sha "$PROBES/reused/a02-queued-refresh-discriminator.mjs")" "$PIN_R5_A02" pin_r5_a02
  chk "$(sha "$PROBES/reused/bound-admission-probe.mjs")" "$PIN_R5_B" pin_r5_b
  chk "$(sha "$PIPE")" "$PIN_PIPE_V5" pin_pipe_v5
  # Predecessor export must equal the 88287cff tree file-for-file (the one added
  # spec copy is excluded); compared by git blob id, not by advertised prose.
  pred_mism=$(cd "$PRED" && find . -type f ! -name 'R6-CANDIDATE-COPY.*' | sed 's|^\./||' | sort | while read -r f; do
      exp=$(git -C "$WT" rev-parse -q --verify "88287cff:$f" 2>/dev/null); act=$(git -C "$WT" hash-object "$PRED/$f"); [[ $exp == "$act" ]] || echo "$f"; done | wc -l)
  pred_count=$(cd "$PRED" && find . -type f ! -name 'R6-CANDIDATE-COPY.*' | wc -l); tree_count=$(git -C "$WT" ls-tree -r --name-only 88287cff | wc -l)
  chk "$pred_mism" 0 predecessor_blob_mismatches; chk "$pred_count" "$tree_count" predecessor_file_count
  [[ -x $CHROME ]] || echo "NOTE: Chrome missing at $CHROME — S60 will fail as runtime-unavailable (not product failure)"
  if pgrep -f "tgp-browser-proof-|tgp-pipe-discriminator-" >/dev/null; then echo "PRECONDITION leftover proof-Chrome processes (UNOWNED, not signalled; refuse)"; ok=0; fi
  echo "runner_sha256=$(sha "$V5/runner/s4-r6-validate-v5.sh") lib_sha256=$(sha "$V5/runner/s4-r6-lib-v5.sh") pipe_v5_sha256=$(sha "$PIPE") chrome=$CHROME chrome_sha256=$( [[ -x $CHROME ]] && sha "$CHROME" || echo missing ) sid=$SID lease_holder=$LEASE_PID run=$RUN_ID kind=$KIND"
  [[ $ok == 1 ]]
} > "$OUT/steps/S00-preconditions.log" 2>&1
S00=$?; cat "$OUT/steps/S00-preconditions.log"
[[ $S00 == 0 ]] || block S00-preconditions "$S00" "precondition/pin mismatch (see S00 log)"

# ---- S1x setup (the ONLY install/network) -------------------------------------------
step S10-npm-ci 1 300 "$WT" npm ci --no-audit --no-fund --loglevel=info
step S10b-toolchain-provenance 1 120 "$WT" bash -c '
  echo "node_modules_package_lock_sha256=$(sha256sum node_modules/.package-lock.json | cut -d" " -f1)"
  echo "npm_ls_all_json_sha256=$(npm ls --all --json 2>/dev/null | sha256sum | cut -d" " -f1)"
  if [[ -f .git/hooks/pre-commit ]] && grep -q lefthook .git/hooks/pre-commit; then echo hook_installed=yes; else echo hook_installed=NO; exit 90; fi
  echo "lefthook_version=$(npx --no-install lefthook version 2>/dev/null)"
  echo "vitest_version=$(npx --no-install vitest --version 2>/dev/null)"
  echo "eslint=$(npx --no-install eslint --version 2>/dev/null) prettier=$(npx --no-install prettier --version 2>/dev/null) tsc=$(npx --no-install tsc --version 2>/dev/null)"'
step S11-gitleaks-install 1 120 "$WT" bash scripts/install-gitleaks.sh "$TOOLING"
export PATH="$TOOLING:$PATH"
step S11b-gitleaks-version 1 30 "$WT" bash -c '[[ $(gitleaks version) == 8.30.0 ]] || { echo "gitleaks version $(gitleaks version) != 8.30.0"; exit 91; }; echo gitleaks_version=8.30.0'

# ---- S2x deterministic gates (hook-equivalents; historical 0/6 retained) -------------
export RATIO_BASE=$EXPECT_BASE
step S20-gates 1 300 "$WT" npm run gates
step S21-secrets-exact-range 1 120 "$WT" bash scripts/secrets-scan.sh pr "$EXPECT_PARENT" "$EXPECT_HEAD"
step S22-secrets-full-history 1 120 "$WT" bash scripts/secrets-scan.sh history

# ---- S3x real Vitest ------------------------------------------------------------------
step S30-focused-vitest 1 300 "$WT" npx --no-install vitest run --reporter=default --reporter=json --outputFile.json="$OUT/steps/S30-focused.vitest.json" \
  test/session-ownership-preflight.spec.js test/refresh-admission-epoch.spec.js test/session-ownership.spec.js \
  test/refresh-coalesce.spec.js test/ingest-auth.spec.js test/session-refresh-path.spec.js \
  test/session-establishment.spec.js test/start-import-hardening.spec.js test/session-lifecycle.spec.js
step S30b-focused-evidence 1 30 "$WT" python3 - "$OUT/steps/S30-focused.vitest.json" "$EXPECT_PREFLIGHT_TESTS" <<'PY'
import json,sys
d=json.load(open(sys.argv[1])); want=int(sys.argv[2])
pre=[x for x in d["testResults"] if x["name"].endswith("session-ownership-preflight.spec.js")]
n=sum(len(x["assertionResults"]) for x in pre); failed=[a["fullName"] for x in d["testResults"] for a in x["assertionResults"] if a["status"]!="passed"]
print({"numTotalTests":d["numTotalTests"],"numPassed":d["numPassedTests"],"numFailed":d["numFailedTests"],"pending":d["numPendingTests"],"preflight_cases":n,"non_passed":failed})
sys.exit(0 if (n==want and not failed and d["numFailedTests"]==0 and d["numPendingTests"]==0) else 92)
PY
step S31-full-suite 1 900 "$WT" npx --no-install vitest run --passWithNoTests=false --reporter=default --reporter=json --outputFile.json="$OUT/steps/S31-full.vitest.json"
step S31b-full-evidence 1 30 "$WT" python3 - "$OUT/steps/S31-full.vitest.json" "$EXPECT_FULL_TESTS" <<'PY'
import json,sys
d=json.load(open(sys.argv[1])); want=int(sys.argv[2])
c={k:d.get(k) for k in ("numTotalTests","numPassedTests","numFailedTests","numPendingTests","numTodoTests","numTotalTestSuites","numFailedTestSuites")}
print(c)
ok = d["numFailedTests"]==0 and d.get("numFailedTestSuites",0)==0 and d["numPendingTests"]==0 and d.get("numTodoTests",0)==0 and d["numTotalTests"]==want
if d["numTotalTests"]!=want: print(f"COUNT_MISMATCH total={d['numTotalTests']} expected={want} (arithmetic expectation; explain, do not relabel)")
sys.exit(0 if ok else 93)
PY

# ---- S4x offline discriminators in-slot (pins enforced in S00) -------------------------
step S40-a01-late-reporting-candidate-fixed 1 60 "$WT" node "$PROBES/a01-late-reporting-discriminator.mjs" "$WT" --expect fixed
step S41-a01-late-reporting-predecessor-defect 1 60 "$WT" node "$PROBES/a01-late-reporting-discriminator.mjs" "$PRED" --expect defect
step S42-r5-a01-barrier-candidate-fixed 1 60 "$WT" node "$PROBES/reused/a01-preflight-barrier-discriminator.mjs" "$WT" --expect fixed
step S43-r5-a02-queued-refresh-candidate-fixed 1 60 "$WT" node "$PROBES/reused/a02-queued-refresh-discriminator.mjs" "$WT" --expect fixed
step S44-r5B-bound-admission-candidate 1 60 "$WT" node "$PROBES/reused/bound-admission-probe.mjs" "$WT"
# Expected-negative: the candidate must FAIL the defect expectation with exit 1 exactly.
step S45-a01-late-reporting-candidate-expect-defect-must-fail 0 60 "$WT" node "$PROBES/a01-late-reporting-discriminator.mjs" "$WT" --expect defect
rc45=$?; expect_exit S45-a01-late-reporting-candidate-expect-defect-must-fail "$rc45" 1 "candidate must FAIL the defect expectation: exit 1 = FAIL_DEFECT_NOT_OBSERVED"

# ---- S5x package + exact joins (VPA-04) ----------------------------------------------------
step S50-package 1 120 "$WT" node scripts/package-extension.mjs --root "$WT" --out "$OUT/dist"
ZIP=""; ZIP_SHA=""
step S50b-package-binding 1 60 "$WT" python3 - "$OUT/dist" "$WT" "$EXPECT_HEAD" "$OUT/steps/S50b-package-identity.json" <<'PY'
import json,sys,os,subprocess,hashlib,glob
dist,wt,head,outp=sys.argv[1:5]
invs=glob.glob(os.path.join(dist,"*.inventory.json")); zips=glob.glob(os.path.join(dist,"*.zip"))
if len(invs)!=1 or len(zips)!=1: print("NOT_EXACTLY_ONE_PAIR",invs,zips); sys.exit(94)
inv=json.load(open(invs[0])); zpath=os.path.join(dist,inv["zip"]["file"])
if os.path.abspath(zpath)!=os.path.abspath(zips[0]): print("ZIP_NAME_MISMATCH",zpath,zips[0]); sys.exit(94)
actual=hashlib.sha256(open(zpath,"rb").read()).hexdigest()
src=inv.get("source",{}); mism=[]
for f in inv["files"]:
    blob=subprocess.run(["git","-C",wt,"show",f"HEAD:{f['path']}"],capture_output=True).stdout
    if hashlib.sha256(blob).hexdigest()!=f["sha256"]: mism.append(f["path"])
ok = actual==inv["zip"]["sha256"] and src.get("head")==head and src.get("clean") is True and inv["files"] and not mism and os.path.getsize(zpath)==inv["zip"]["bytes"]
rec={"zip":zpath,"actual_sha256":actual,"inventory_zip_sha256":inv["zip"]["sha256"],"bytes":os.path.getsize(zpath),"source":src,"shipped_files":len(inv["files"]),"blob_mismatches":mism,"bound":ok}
json.dump(rec,open(outp,"w"),indent=2); print(rec)
sys.exit(0 if ok else 94)
PY
if [[ -z $FIRST_FAIL ]]; then
  ZIP=$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["zip"])' "$OUT/steps/S50b-package-identity.json")
  ZIP_SHA=$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["actual_sha256"])' "$OUT/steps/S50b-package-identity.json")
fi

# ---- S6x browser ------------------------------------------------------------------------------
step S60-chrome-pipe-trial1 1 60 "$WT" node "$PIPE" --chrome "$CHROME" --label trial1-fresh-profile --out "$OUT/steps/S60-pipe-trial1.json"
step S61-chrome-pipe-trial2 1 60 "$WT" node "$PIPE" --chrome "$CHROME" --label trial2-fresh-profile --out "$OUT/steps/S61-pipe-trial2.json"
HARNESS_BLOCKED=""
if [[ $FIRST_FAIL == S60-chrome-pipe-trial1 || $FIRST_FAIL == S61-chrome-pipe-trial2 ]] && [[ $FIRST_FAIL_RC == 1 || $FIRST_FAIL_RC == 2 ]]; then
  HARNESS_BLOCKED="transport/runtime: --remote-debugging-pipe gave no CDP response or Chrome unavailable (rc=$FIRST_FAIL_RC; see S60/S61 json). Harness block, not a product failure; no retry."
fi
step S62-browser-positive 1 180 "$WT" env TGP_CHROME="$CHROME" node scripts/browser-load-proof.mjs --zip "$ZIP" --out "$OUT/steps/S62-browser-load-proof.json"
step S62b-positive-join 1 30 "$WT" python3 - "$OUT/steps/S62-browser-load-proof.json" "$ZIP" "$ZIP_SHA" <<'PY'
import json,sys,os
e=json.load(open(sys.argv[1])); zpath,zsha=sys.argv[2],sys.argv[3]; p=e.get("package",{}); inv=p.get("inventory") or {}
join = p.get("sha256")==zsha and os.path.abspath(p.get("path",""))==os.path.abspath(zpath) and inv.get("zipSha256")==zsha and (inv.get("source") or {}).get("head")=="91990ae9aec72f47a67591892ac09fa1f59d2f16"
fails=[c["name"] for c in e.get("checks",[]) if not c.get("pass")]
print({"kind":e.get("kind"),"package_sha256":p.get("sha256"),"inventory_zipSha256":inv.get("zipSha256"),"joined":join,"failed_checks":fails})
sys.exit(0 if (join and e.get("kind")=="browser-load-proof" and not fails) else 95)
PY
step S63-browser-negative 0 180 "$WT" env TGP_CHROME="$CHROME" node scripts/browser-load-proof.mjs --negative-control --zip "$ZIP" --out "$OUT/steps/S63-browser-load-proof.negative-control.json"
rc63=$?
if [[ $rc63 != 99 ]]; then
step S63b-negative-criterion 1 30 "$WT" python3 - "$OUT/steps/S63-browser-load-proof.negative-control.json" "$ZIP" "$ZIP_SHA" "$rc63" <<'PY'
import json,sys,os
e=json.load(open(sys.argv[1])); zpath,zsha,rc=sys.argv[2],sys.argv[3],int(sys.argv[4]); p=e.get("package",{}); inv=p.get("inventory") or {}
n=e.get("negativeControl") or {}; m=e.get("mutation") or {}
join = p.get("sha256")==zsha and os.path.abspath(p.get("path",""))==os.path.abspath(zpath) and inv.get("zipSha256")==zsha
proper = rc==0 and e.get("kind")=="browser-load-proof:negative-control" and join and m.get("file")=="content/main.js" and bool(m.get("sha256AfterMutation")) and m.get("appended") and n.get("detected") is True and n.get("syntaxExceptionSeen") is True and not n.get("unrelatedFailures")
print({"harness_exit":rc,"joined_to_same_original_zip":join,"mutation":m,"negativeControl":n,"PROPER_NEGATIVE_ESTABLISHED":proper})
sys.exit(0 if proper else 97)
PY
fi

# ---- S7x final cleanup (owned session) + source state (VPA-01/02) ---------------------------------
CLEAN_RC=0
reap_owned final || CLEAN_RC=1
census "$OUT/steps/final-census.txt"; [[ -s $OUT/steps/final-census.txt ]] && CLEAN_RC=1
if pgrep -f "tgp-browser-proof-|tgp-pipe-discriminator-" > "$OUT/steps/final-proof-chrome-scan.txt"; then
  # Any such process NOT in our session is unowned: never signalled, recorded, and blocks success.
  echo "proof-profile Chrome processes present after cleanup (owned ones already reaped; these are UNOWNED or unreaped): $(tr '\n' ' ' < "$OUT/steps/final-proof-chrome-scan.txt")" | tee -a "$OUT/reaps.log"; CLEAN_RC=2
fi
read -r FH FT FD < <(head_state | tr '\n' ' ')
SOURCE_OK=false; [[ $FH == "$EXPECT_HEAD" && $FT == "$EXPECT_TREE" && $FD == 0 ]] && SOURCE_OK=true
RUN_END=$(now)

# ---- S8x classification, durable record, sentinel (VPA-02) ----------------------------------------
RESULT=SUCCESS
if [[ -n $FIRST_FAIL ]]; then RESULT=FAILED; [[ -n $HARNESS_BLOCKED ]] && RESULT=HARNESS_BLOCKED
elif [[ $CLEAN_RC != 0 ]]; then RESULT=FAILED_CLEANUP
elif [[ $SOURCE_OK != true ]]; then RESULT=FAILED_SOURCE_STATE
elif [[ ${#WARNINGS[@]} -gt 0 ]]; then RESULT=WARNINGS; fi
RESULT=$(publish_exit_record "$RESULT" "$CLEAN_RC" "$SOURCE_OK" "$FH" "$FT" "$FD" "$RUN_START" "$RUN_END" "$HARNESS_BLOCKED" "$EXPECT_HEAD" "$EXPECT_TREE" "$V5/runner/s4-r6-validate-v5.sh" "$PIPE" "$CHROME" "${ZIP:-}" "${ZIP_SHA:-}" 1)
echo "RESULT=$RESULT first_fail=${FIRST_FAIL:-none}(validation_exit=${FIRST_FAIL_RC:-} observed=${FIRST_FAIL_OBSERVED:-}) blocks=${#BLOCKS[@]} warnings=${#WARNINGS[@]} cleanup_exit=$CLEAN_RC source_ok=$SOURCE_OK record=$OUT/EXIT_RECORD.json"
exit "$(result_exit "$RESULT")"
