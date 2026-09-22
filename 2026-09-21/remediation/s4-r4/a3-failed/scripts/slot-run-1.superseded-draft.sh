#!/usr/bin/env bash
# S4 R4 validation run #1 — to be started ONLY after the parent grants the slot:
#   flock -n /home/user/workspace/execution/test-validation.lock \
#     bash /home/user/workspace/execution/s4-r4/scripts/slot-run-1.sh
# Holds the lock for the whole run; each step stamps its own meta/log via
# run-slot.sh (lock not re-taken). Continues past failures so every step is
# recorded; exit code = number of failed steps (0 = all passed).
set -u
export S4R4_LOCK_HELD_BY_PARENT_SHELL=1
ROOT=/home/user/workspace
WT=$ROOT/worktrees/s4-r4
EV=$ROOT/execution/s4-r4
# Durable-execution bookkeeping: the launcher (launch-slot-run-1.sh) starts this
# script detached via setsid so a tool-call process-group teardown cannot kill
# it. A final exit record is ALWAYS written (also on SIGTERM/SIGKILL of a child),
# so "finished" is judged from logs/slot-run-1.exit.json, not from log presence.
RUN_START=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo $$ > "$EV/logs/slot-run-1.pid"
write_exit_record() {
  local rc=$1
  python3 - "$EV/logs/slot-run-1.exit.json" "$rc" "$RUN_START" "$FAILED" <<'PY'
import json,sys,subprocess,os,datetime
out,rc,start,failed=sys.argv[1:]
wt="/home/user/workspace/worktrees/s4-r4"
sh=lambda c: subprocess.run(c,shell=True,capture_output=True,text=True,cwd=wt).stdout.strip()
json.dump({"run":"slot-run-1","pid":os.getppid(),"start_utc":start,
 "end_utc":datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
 "exit_code":int(rc),"failed_steps":int(failed),
 "head_at_end":sh("git rev-parse HEAD"),"tree_at_end":sh("git rev-parse HEAD^{tree}"),
 "dirty_at_end":sh("git status --porcelain"),
 "lock":"/home/user/workspace/execution/test-validation.lock held by launcher flock -n for the whole run"},
 open(out,"w"),indent=2)
PY
}
trap 'write_exit_record 143; exit 143' TERM
trap 'write_exit_record 130; exit 130' INT
RUN=$EV/scripts/run-slot.sh
CHROME=/home/user/.cache/ms-playwright/chromium-1217/chrome-linux64/chrome
FAILED=0
# Stop on first unexplained failure (parent A3 grant): record and exit.
step() {
  "$RUN" "$@"
  local rc=$?
  if [ "$rc" -ne 0 ]; then
    echo "STEP FAILED: $1 (exit $rc) — stopping run for diagnosis"
    FAILED=$((FAILED+1))
    write_exit_record "$rc"
    exit "$rc"
  fi
}
cd "$WT" || exit 70
export PATH="$WT/node_modules/.bin:/home/user/.local/tgp-gitleaks:$PATH"

step 01-npm-ci 600 npm ci --no-audit --no-fund
step 02-prettier-check 120 npx prettier --check background.js shared/session.js shared/log.js shared/replay/engine.js test/refresh-admission-epoch.spec.js test/session-ownership.spec.js
step 03-vitest-focused 300 npx vitest run test/refresh-admission-epoch.spec.js test/session-ownership.spec.js test/refresh-coalesce.spec.js test/session-lifecycle.spec.js test/session-refresh-path.spec.js test/auth-body-deadline.spec.js test/start-import-hardening.spec.js test/ingest-auth.spec.js test/ingest-settlement.spec.js test/ingest-legacy-settlement.spec.js
step 04-vitest-full 600 npm test
if [ ! -x /home/user/.local/tgp-gitleaks/gitleaks ]; then
  step 05-gitleaks-install 300 bash scripts/install-gitleaks.sh /home/user/.local/tgp-gitleaks
fi
step 06-gates 600 npm run gates
# L1-S4-PROBES (23:50Z) already ran coalescer + stale/success on this exact head
# (2bcf1563) and on base 84471e99 — reused, not repeated. Remaining mode: reject.
BASE=$EV/artifacts/base-84471e99-export
step 07-probe-stale-reject-candidate 60 node "$EV/scripts/stale-caller-probe.mjs" "$WT" reject
PROBE_HEAD=84471e99b278e964f7cb3f6bf9c78491064c41b7 "$RUN" 08-probe-stale-reject-base 60 node "$EV/scripts/stale-caller-probe.mjs" "$BASE" reject; echo "base stale/reject exit=$? (expected 1)"
step 13-package 120 npm run package
ZIP=$(ls -t dist/*.zip 2>/dev/null | head -1)
if [ -n "$ZIP" ]; then
  mkdir -p "$EV/artifacts"; cp "$ZIP" "$EV/artifacts/"
  step 14-browser-proof-positive 300 node scripts/browser-load-proof.mjs --zip "$ZIP" --out "$EV/artifacts/browser-proof-positive.json" --chrome "$CHROME"
  # Negative control is designed to FAIL; record its exit without counting it.
  "$RUN" 15-browser-proof-negative-control 300 node scripts/browser-load-proof.mjs --zip "$ZIP" --out "$EV/artifacts/browser-proof-negative-control.json" --chrome "$CHROME" --negative-control; echo "negative control exit=$? (expected non-zero)"
else
  echo "STEP FAILED: no zip produced"; FAILED=$((FAILED+1))
fi
echo "slot-run-1 finished; failed steps: $FAILED"
write_exit_record "$FAILED"
exit "$FAILED"
