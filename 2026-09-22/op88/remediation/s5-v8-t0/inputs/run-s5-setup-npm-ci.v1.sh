#!/usr/bin/env bash
# S5-R4 TIER2 SETUP-ONLY V1 — proportionate adaptation of the audited S6 setup 91fe0f1b (run-c5-setup-npm-ci.v3.sh):
# exactly one `npm ci --ignore-scripts` from the committed backend lockfile in the isolated s5-r4 worktree.
# Adapted ONLY: backend pins (HEAD 143d451e, lock blob 354de3da), the EXPECTED dirty patch (2 test files, fingerprint
# 6850b32e… before AND after), `--ignore-scripts` (skips `postinstall: prisma generate` and `prepare: lefthook install`:
# no Prisma engine download, no hook install, no hidden installation), and the strict identity list
# (jest 30.4.2, ts-jest 29.4.9, typescript 5.9.3, jest-circus, jest-runtime, @jest/core, babel-jest, @babel/core,
# @prisma/client 6.19.3 package present without a generated client). Mechanics (owned pgid, budget TERM/KILL,
# fail-closed reap, ancestor gate, lock fd closed in child, FIRST_EXIT vs FINAL) are unchanged from 91fe0f1b.
# NOT LAUNCHED until the parent grants it. No tests, no scripts, no Prisma generate, no hooks, no commit.
# Invoke (parent-granted; external bound 1200 s install + 60 s cleanup + 30 s kill margin):
#   mkdir -p /home/user/workspace/execution/s5-r4/logs/setup-v1 && \
#   setsid nohup timeout -k 30 1290 bash /home/user/workspace/execution/s5-r4/setup-v1/run-s5-setup-npm-ci.v1.sh \
#     > /home/user/workspace/execution/s5-r4/logs/setup-v1/run-setup.out 2>&1 < /dev/null &
set -u
WT=/home/user/workspace/worktrees/s5-r4
EX=/home/user/workspace/execution/s5-r4
LOGS=$EX/logs/setup-v1
LOCK=/home/user/workspace/execution/test-validation.lock
EXIT_RECORD=$LOGS/setup.EXIT_RECORD
PIN_HEAD=143d451ead6ccdbebd92ca3031ba7a89867d6cfc
PIN_LOCK_BLOB=354de3dae19449970497da6e4d87f0a1225a8f43
PIN_DIRTY_FINGERPRINT=6850b32ef19436abe5b02f96c770f4c36ca8bea070e0c759310f17234c616aa0
PIN_DIRTY_STATUS=$' M test/rls-g2-pg17-etq0.spec.ts\n M test/utils/g2-pg17-bootstrap.sh'
INSTALL_BUDGET=1200; INSTALL_GRACE=30
START=$(date +%s)
export CI=1 NODE_OPTIONS=--max-old-space-size=2048 TZ=UTC
CPU="taskset -c 0,1"
OWNED_PGIDS=""; CUR_PID=""; CUR_PGID=""; FIRST_EXIT=""; CLEANUP_FAILURES=0; ACCOUNTED=0

ts() { date -u +%FT%TZ; }
rec() { echo "$(ts) step=$1 rc=$2 elapsed=$(( $(date +%s) - START ))s ${3:-}" >> "$EXIT_RECORD"; }
alive() { kill -0 "$1" 2>/dev/null || return 1; [ "$(ps -o stat= -p "$1" 2>/dev/null | cut -c1)" != "Z" ]; }
ancestor_inventory() { ( cd /home/user/node_modules 2>/dev/null && ls -A --time-style=+%s -l | awk '{print $6, $7}' | sort ) | sha256sum | cut -d' ' -f1; }
dirty_fingerprint() { ( cd "$WT" && { git diff HEAD; printf '%s\n' "$(git status --porcelain --untracked-files=all)"; } | sha256sum | cut -c1-64 ); }
reap_group() { local pg=$1 grace=$2 label=$3
  case " $OWNED_PGIDS " in *" $pg "*) ;; *) echo "$(ts) REFUSE reap of unowned pgid=$pg ($label)" >> "$EXIT_RECORD"; return 2;; esac
  local m; m=$(pgrep -g "$pg" || true); [ -z "$m" ] && { echo "$(ts) cleanup label=$label pgid=$pg members=none cleanup_exit=0" >> "$EXIT_RECORD"; return 0; }
  echo "$(ts) cleanup label=$label pgid=$pg TERM members=[${m//$'\n'/,}]" >> "$EXIT_RECORD"; kill -TERM -- "-$pg" 2>/dev/null
  local i=0; while [ $i -lt "$grace" ] && pgrep -g "$pg" >/dev/null 2>&1; do sleep 1; i=$((i+1)); done
  if pgrep -g "$pg" >/dev/null 2>&1; then echo "$(ts) cleanup label=$label pgid=$pg KILL" >> "$EXIT_RECORD"; kill -KILL -- "-$pg" 2>/dev/null; sleep 1; fi
  m=$(pgrep -g "$pg" || true); [ -n "$m" ] && { echo "$(ts) cleanup label=$label SURVIVORS=[${m//$'\n'/,}] cleanup_exit=1" >> "$EXIT_RECORD"; return 1; }
  echo "$(ts) cleanup label=$label pgid=$pg members=none cleanup_exit=0" >> "$EXIT_RECORD"; return 0; }
final_accounting() {
  [ "$ACCOUNTED" = 1 ] && return; ACCOUNTED=1
  if [ -n "${ANCESTOR_BEFORE:-}" ]; then local a; a=$(ancestor_inventory)
    if [ "$a" = "$ANCESTOR_BEFORE" ]; then echo "$(ts) ancestor_inventory_before=$ANCESTOR_BEFORE after=$a UNCHANGED" >> "$EXIT_RECORD"
    else echo "$(ts) ancestor_inventory_before=$ANCESTOR_BEFORE after=$a CHANGED — GATE FAILED (this runner never writes there)" >> "$EXIT_RECORD"; CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); fi; fi
  local pg; for pg in $OWNED_PGIDS; do local m; m=$(pgrep -g "$pg" || true); echo "$(ts) final owned pgid=$pg members=[${m//$'\n'/,}]" >> "$EXIT_RECORD"; [ -n "$m" ] && CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); done
  echo "$(ts) CLEANUP_FAILURES=$CLEANUP_FAILURES" >> "$EXIT_RECORD"
  ( cd "$WT" 2>/dev/null && echo "$(ts) dirty_fingerprint_after=$(dirty_fingerprint) status_lines=$(git status --porcelain | wc -l) node_modules_present=$([ -d node_modules ] && echo yes || echo no) hooks_pre_commit=$([ -e .git/hooks/pre-commit ] && echo PRESENT || echo absent) generated_client=$([ -d node_modules/.prisma/client ] && echo PRESENT || echo absent)" >> "$EXIT_RECORD" )
  echo "$(ts) lock held until exit (fd 9)" >> "$EXIT_RECORD"; }
finish() { final_accounting
  if [ "$CLEANUP_FAILURES" -gt 0 ]; then echo "FINAL rc=$(( $1 == 0 ? 90 : $1 )) (primary rc=$1 in FIRST_EXIT; CLEANUP_FAILURES=$CLEANUP_FAILURES => fail-closed; node_modules state must be treated as unverified)" >> "$EXIT_RECORD"; [ "$1" -eq 0 ] && exit 90 || exit "$1"; fi
  echo "FINAL rc=$1" >> "$EXIT_RECORD"; exit "$1"; }
on_signal() { trap '' TERM INT HUP; echo "$(ts) RUNNER-SIGNAL child_pid=${CUR_PID:-none} pgid=${CUR_PGID:-none}" >> "$EXIT_RECORD"
  [ -n "$CUR_PGID" ] && reap_group "$CUR_PGID" 20 "runner-signal"
  [ -n "$FIRST_EXIT" ] || FIRST_EXIT="npm-ci rc=143 how=runner-signal"; echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"; echo "$(ts) install INCOMPLETE; node_modules state undefined — report, do not retry without a new grant" >> "$EXIT_RECORD"; finish 143; }
trap on_signal TERM INT HUP; trap final_accounting EXIT
die() { rec "$1" "$2" "${3:-}"; echo "STOP_FIRST_FAILURE step=$1 rc=$2" >> "$EXIT_RECORD"; [ -n "$FIRST_EXIT" ] || FIRST_EXIT="$1 rc=$2 how=exited"; echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"; finish "$2"; }

mkdir -p "$LOGS/npm-logs"
echo "$(ts) START pid=$$ pgid=$(ps -o pgid= $$ | tr -d ' ') ppid=$PPID runner_sha256=$(sha256sum "$0" | cut -c1-64)" > "$EXIT_RECORD"
exec 9>"$LOCK"; flock -n 9 || die lock-busy 75; echo "$(ts) lock acquired fd=9 path=$LOCK" >> "$EXIT_RECORD"
cd "$WT" || die cd 1
[ "$PWD" = "$WT" ] || die cwd 1

# provenance before (dirty patch is EXPECTED and pinned; anything else is a refusal)
ANCESTOR_BEFORE=$(ancestor_inventory); DIRTY_BEFORE=$(dirty_fingerprint)
{ echo "cwd=$PWD"; echo "HEAD=$(git rev-parse HEAD)"; echo "TREE=$(git rev-parse HEAD^{tree})"
  echo "lock_blob=$(git ls-files -s package-lock.json | awk '{print $2}')"; echo "lock_sha256=$(sha256sum package-lock.json | cut -d' ' -f1)"
  echo "package_json_sha256=$(sha256sum package.json | cut -d' ' -f1)"; echo "lockfileVersion=$(grep -m1 '"lockfileVersion"' package-lock.json)"
  echo "dirty_fingerprint_before=$DIRTY_BEFORE (expected $PIN_DIRTY_FINGERPRINT)"
  echo "node=$(node -v) node_path=$(command -v node) npm=$(npm -v) npm_path=$(command -v npm)"
  echo "node_modules_present_before=$([ -d node_modules ] && echo yes || echo no) hooks_pre_commit_before=$([ -e .git/hooks/pre-commit ] && echo PRESENT || echo absent)"
  echo "ancestor_package_json_absent=$([ ! -e /home/user/package.json ] && echo yes || echo NO)"
  echo "ancestor_node_modules=$(ls -ld /home/user/node_modules 2>&1) entries=$(ls -A /home/user/node_modules 2>/dev/null | wc -l) inventory_before=$ANCESTOR_BEFORE (platform-owned; read-only for this runner)"
  echo "npm_cache=$(npm config get cache 2>/dev/null)"; echo "registry=$(npm config get registry 2>/dev/null)"
  echo "npm_debug_log_dir_before=$(ls /home/user/.npm/_logs 2>/dev/null | wc -l) files"
  git status --porcelain | sed 's/^/status: /'; } > "$LOGS/setup.provenance.txt" 2>&1
[ "$(git rev-parse HEAD)" = "$PIN_HEAD" ] || die provenance-head 2
[ "$(git ls-files -s package-lock.json | awk '{print $2}')" = "$PIN_LOCK_BLOB" ] || die provenance-lock-blob 2
[ "$(git status --porcelain)" = "$PIN_DIRTY_STATUS" ] || die provenance-dirty-status-not-the-pinned-patch 2
[ "$DIRTY_BEFORE" = "$PIN_DIRTY_FINGERPRINT" ] || die provenance-dirty-fingerprint 2
[ ! -d node_modules ] || die provenance-node-modules-already-present-one-install-only 2
[ ! -e /home/user/package.json ] || die provenance-ancestor-package-json-present 2
rec provenance 0

# the one install, in its own owned process group, lifecycle scripts ignored, raw npm logs kept in the evidence dir
setsid $CPU npm ci --no-audit --no-fund --ignore-scripts --loglevel=error --logs-dir="$LOGS/npm-logs" --logs-max=10 > "$LOGS/setup.npm-ci.out" 2>&1 < /dev/null 9>&- &
CUR_PID=$!; sleep 0.2; CUR_PGID=$(ps -o pgid= "$CUR_PID" 2>/dev/null | tr -d ' '); [ -z "$CUR_PGID" ] && CUR_PGID=$CUR_PID; OWNED_PGIDS="$CUR_PGID"
echo "$(ts) npm-ci START child_pid=$CUR_PID child_pgid=$CUR_PGID budget=${INSTALL_BUDGET}s grace=${INSTALL_GRACE}s cmd=[npm ci --no-audit --no-fund --ignore-scripts --loglevel=error]" >> "$EXIT_RECORD"
w=0; while alive "$CUR_PID" && [ $w -lt "$INSTALL_BUDGET" ]; do sleep 2; w=$((w+2)); done
HOW=exited
if alive "$CUR_PID"; then HOW=budget-TERM; echo "$(ts) npm-ci BUDGET reached: TERM owned pgid=$CUR_PGID" >> "$EXIT_RECORD"; kill -TERM -- "-$CUR_PGID" 2>/dev/null
  g=0; while alive "$CUR_PID" && [ $g -lt "$INSTALL_GRACE" ]; do sleep 1; g=$((g+1)); done
  if alive "$CUR_PID"; then HOW=budget-KILL; kill -KILL -- "-$CUR_PGID" 2>/dev/null; fi; fi
wait "$CUR_PID"; RC=$?
echo "$(ts) npm-ci first_exit rc=$RC how=$HOW npm_logs=[$(ls "$LOGS/npm-logs" 2>/dev/null | tr '\n' ',')]" >> "$EXIT_RECORD"
reap_group "$CUR_PGID" 10 "post:npm-ci"; CE=$?; echo "$(ts) npm-ci cleanup_exit=$CE" >> "$EXIT_RECORD"; [ "$CE" -eq 0 ] || CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); CUR_PID=""; CUR_PGID=""
FIRST_EXIT="npm-ci rc=$RC how=$HOW"
[ "$RC" -eq 0 ] || die npm-ci "$RC" "how=$HOW (node_modules may be partial: report; no retry)"

# provenance after: dirty patch unchanged (node_modules is gitignored), lockfile unchanged, strict identities, no hooks, no generated client
{ echo "tree_status_after:"; git status --porcelain; echo "lock_sha256_after=$(sha256sum package-lock.json | cut -d' ' -f1)"; echo "dirty_fingerprint_after=$(dirty_fingerprint)"
  echo "node_modules_top_entries=$(ls -A node_modules | wc -l)"; echo "node_modules_bytes=$(du -sb node_modules 2>/dev/null | cut -f1)"
  echo "node_modules_package_lock_sha256=$(sha256sum node_modules/.package-lock.json 2>/dev/null | cut -c1-64)"
  echo "bins: $(cd node_modules/.bin 2>/dev/null && ls jest tsc eslint prettier lefthook prisma 2>&1 | tr '\n' ' ')"
  echo "generated_client_absent=$([ ! -d node_modules/.prisma/client ] && echo yes || echo NO) hooks_pre_commit=$([ -e .git/hooks/pre-commit ] && echo PRESENT || echo absent)"; } > "$LOGS/setup.after.txt" 2>&1
[ "$(git status --porcelain)" = "$PIN_DIRTY_STATUS" ] || die after-dirty-status-changed 6
[ "$(dirty_fingerprint)" = "$PIN_DIRTY_FINGERPRINT" ] || die after-dirty-fingerprint-changed 6
[ ! -e .git/hooks/pre-commit ] || die after-hooks-installed-despite-ignore-scripts 6
node -e '
const p=require("path"); const wt=process.argv[1]; let bad=0;
const want={"jest":"30.4.2","ts-jest":"29.4.9","typescript":"5.9.3","@prisma/client":"6.19.3","prisma":"6.19.3","lefthook":"2.1.9","eslint":"10.5.0"};
for (const m of ["jest","jest-circus","jest-runtime","@jest/core","ts-jest","typescript","babel-jest","@babel/core","@prisma/client","prisma","lefthook","eslint"]) {
  let r; try { r=require.resolve(m+"/package.json",{paths:[wt]}); } catch(e){ console.log(`BAD ${m} unresolved`); bad++; continue; }
  const v=require(r).version; const inside=r.startsWith(p.join(wt,"node_modules")+p.sep); const pinOk=!(m in want)||want[m]===v;
  console.log(`${inside&&pinOk?"OK ":"BAD"} ${m}@${v}${m in want?" (pin "+want[m]+")":""} ${r}`); if(!inside||!pinOk) bad++; }
try { require.resolve("prettier/package.json",{paths:[wt]}); console.log("NOTE prettier resolves (unexpected: not in application lock)"); } catch(e){ console.log("NOTE prettier absent from application lock (expected; hook-formatter resolution is a separate grant)"); }
process.exit(bad?1:0)' "$WT" > "$LOGS/setup.module-paths.txt" 2>&1 || die after-strict-resolution 5
rec after-checks 0
echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"; echo "$(ts) primary setup rc=0 (node_modules present in $WT; pinned dirty patch unchanged; strict identities OK; no hooks; no generated client) — FINAL decided by cleanup/ancestor gates" >> "$EXIT_RECORD"
finish 0
