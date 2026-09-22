#!/usr/bin/env bash
# S4 R4 validation run (SLOT A3-S4-VALIDATION) — fail-closed runner.
# Started ONLY via launch-slot-run-2.sh (setsid + outer `timeout` + `flock -n`
# on the canonical lock held for the whole run). Every positive step must exit
# 0; the predecessor discriminator must exit NON-zero AND show its intended
# predicate; the browser negative control must exit 0 with "DETECTED". Any
# other outcome stops the run immediately with an exit record.
set -u
export S4R4_LOCK_HELD_BY_PARENT_SHELL=1
ROOT=/home/user/workspace
WT=$ROOT/worktrees/s4-r4
EV=$ROOT/execution/s4-r4
LOGS=$EV/logs
RUN=$EV/scripts/run-slot.sh
CHROME=/home/user/.cache/ms-playwright/chromium-1217/chrome-linux64/chrome
EXPECT_HEAD=2bcf1563d85bc2109e99805e4ce1b06fce4dcdb3
EXPECT_TREE=3e23f91824689d1f179a116af948eae0ed5ae170
BASE_COMMIT=84471e99b278e964f7cb3f6bf9c78491064c41b7
BASE=$EV/artifacts/base-84471e99-export
RUN_START=$(date -u +%Y-%m-%dT%H:%M:%SZ)
FAILED=0; LAST_STEP=preflight
mkdir -p "$LOGS" "$EV/artifacts"
echo $$ > "$LOGS/slot-run-2.pid"
write_exit_record() {
  local rc=$1
  python3 - "$LOGS/slot-run-2.exit.json" "$rc" "$RUN_START" "$FAILED" "$LAST_STEP" <<'PY'
import json,sys,subprocess,os,datetime
out,rc,start,failed,last=sys.argv[1:]
wt="/home/user/workspace/worktrees/s4-r4"
sh=lambda c: subprocess.run(c,shell=True,capture_output=True,text=True,cwd=wt).stdout.strip()
json.dump({"run":"slot-run-2 (SLOT A3-S4-VALIDATION)","runner_pid":os.getppid(),"start_utc":start,
 "end_utc":datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
 "exit_code":int(rc),"failed_steps":int(failed),"last_step":last,
 "verdict":"PASS — all steps reached and satisfied" if int(rc)==0 else "FAIL/STOPPED — see last_step and its log",
 "head_at_end":sh("git rev-parse HEAD"),"tree_at_end":sh("git rev-parse HEAD^{tree}"),
 "dirty_at_end":sh("git status --porcelain"),
 "lock":"/home/user/workspace/execution/test-validation.lock held by launcher flock -n for the whole run",
 "note":"absence of this file = run did not finish (unknown), never a pass"},open(out,"w"),indent=2)
PY
}
trap 'echo "TERM received (outer timeout or kill) during $LAST_STEP"; write_exit_record 143; exit 143' TERM
trap 'write_exit_record 130; exit 130' INT
fail() { echo "RUN STOPPED at $LAST_STEP: $*"; FAILED=$((FAILED+1)); write_exit_record 1; exit 1; }
step() { LAST_STEP=$1; "$RUN" "$@"; local rc=$?; [ "$rc" -eq 0 ] || fail "positive step exited $rc"; }
log_has() { grep -q -- "$2" "$LOGS/$1.log"; }

cd "$WT" || { echo "cannot cd $WT"; exit 70; }
export PATH="$WT/node_modules/.bin:/home/user/.local/tgp-gitleaks:$PATH"

# 00 preflight: exact frozen identity, clean tree, attributed base export.
LAST_STEP=00-preflight
[ "$(git rev-parse HEAD)" = "$EXPECT_HEAD" ] || fail "head is $(git rev-parse HEAD), expected $EXPECT_HEAD"
[ "$(git rev-parse 'HEAD^{tree}')" = "$EXPECT_TREE" ] || fail "tree mismatch"
[ -z "$(git status --porcelain)" ] || fail "working tree dirty: $(git status --porcelain | tr '\n' ' ')"
for f in shared/session.js background.js shared/replay/engine.js test/helpers/background-mock.js; do
  a=$(git show "$BASE_COMMIT:$f" | sha256sum | cut -d' ' -f1); b=$(sha256sum "$BASE/$f" | cut -d' ' -f1)
  [ "$a" = "$b" ] || fail "base export $f does not match git $BASE_COMMIT"
done
echo "[preflight ok] head=$EXPECT_HEAD tree=$EXPECT_TREE clean; base export verified against $BASE_COMMIT"

step 01-npm-ci 600 npm ci --no-audit --no-fund
step 02-prettier-check 120 npx prettier --check background.js shared/session.js shared/log.js shared/replay/engine.js test/refresh-admission-epoch.spec.js test/session-ownership.spec.js
step 03-vitest-focused 300 npx vitest run test/refresh-admission-epoch.spec.js test/session-ownership.spec.js test/refresh-coalesce.spec.js test/session-lifecycle.spec.js test/session-refresh-path.spec.js test/auth-body-deadline.spec.js test/start-import-hardening.spec.js test/ingest-auth.spec.js test/ingest-settlement.spec.js test/ingest-legacy-settlement.spec.js
step 04-vitest-full 600 npm test
if [ ! -x /home/user/.local/tgp-gitleaks/gitleaks ]; then
  step 05-gitleaks-install 300 bash scripts/install-gitleaks.sh /home/user/.local/tgp-gitleaks
fi
step 06-gates 600 npm run gates

# 07/08 remaining auth discriminator (reject mode). The coalescer and
# stale/success pair were already attributed on this exact head and base under
# L1-S4-PROBES (logs/L1-05..08) and are reused, not repeated.
step 07-probe-stale-reject-candidate 60 node "$EV/scripts/stale-caller-probe.mjs" "$WT" reject
log_has 07-probe-stale-reject-candidate '"pass": true' || fail "candidate probe exited 0 but did not print pass:true"
LAST_STEP=08-probe-stale-reject-base
PROBE_HEAD=$BASE_COMMIT "$RUN" 08-probe-stale-reject-base 60 node "$EV/scripts/stale-caller-probe.mjs" "$BASE" reject
rc=$?
[ "$rc" -eq 1 ] || fail "base discriminator exited $rc, expected exactly 1"
log_has 08-probe-stale-reject-base '"pass": false' || fail "base probe lacks pass:false"
log_has 08-probe-stale-reject-base '"authRequiredCount": 1' || fail "base probe did not show the intended predicate authRequiredCount=1"
log_has 08-probe-stale-reject-base '"hasSession": false' || fail "base probe did not show the intended predicate hasSession=false"
! log_has 08-probe-stale-reject-base 'Cannot find module' || fail "base probe crashed (module not found), not a discriminator"
! log_has 08-probe-stale-reject-base 'probe observation did not arrive' || fail "base probe timed out, not a discriminator"
echo "[08 ok] predecessor fails on the intended A-02 predicate (exit 1, authRequired=1, hasSession=false)"

# 09 package — never reuse stale dist.
LAST_STEP=09-package
rm -rf "$WT/dist"
step 09-package 120 npm run package
ZIPS=$(ls "$WT"/dist/*.zip 2>/dev/null | wc -l)
[ "$ZIPS" -eq 1 ] || fail "expected exactly 1 freshly built zip in dist/, found $ZIPS"
ZIP=$(ls "$WT"/dist/*.zip)
cp "$ZIP" "$WT"/dist/*.inventory.json "$EV/artifacts/"
echo "[09 ok] fresh package $(basename "$ZIP") sha256=$(sha256sum "$ZIP" | cut -d' ' -f1)"

step 10-browser-proof-positive 300 node scripts/browser-load-proof.mjs --zip "$ZIP" --out "$EV/artifacts/browser-proof-positive.json" --chrome "$CHROME"
! log_has 10-browser-proof-positive 'GAP: no Chrome' || fail "browser proof did not run (no Chrome)"
step 11-browser-proof-negative-control 300 node scripts/browser-load-proof.mjs --zip "$ZIP" --out "$EV/artifacts/browser-proof-negative-control.json" --chrome "$CHROME" --negative-control
log_has 11-browser-proof-negative-control 'negative control: DETECTED' || fail "negative control did not fail on the intended check"

# 12 freeze: final-head bundle (head must still be the frozen one) + hashes.
LAST_STEP=12-freeze
[ "$(git rev-parse HEAD)" = "$EXPECT_HEAD" ] && [ -z "$(git status --porcelain)" ] || fail "head/tree changed during run"
git bundle create "$EV/artifacts/s4-r4-final-$EXPECT_HEAD.bundle" 0111be661922234d670bbf23e23d270eec1b4a4e..execute/20260921-s4-r4 || fail "bundle create"
git bundle verify "$EV/artifacts/s4-r4-final-$EXPECT_HEAD.bundle" || fail "bundle verify"
( cd "$EV/artifacts" && sha256sum *.zip *.inventory.json *.bundle browser-proof-*.json > SHA256SUMS ) || fail "hashing"
echo "slot-run-2 finished; all steps satisfied"
write_exit_record 0
exit 0
