#!/usr/bin/env bash
# C5-S6 SETUP-ONLY V3 — successor of 6fa69510… closing the parent's two allocation questions and B-04:
#   (1) a nonzero post-install reap_group (cleanup_exit) or any owned survivor now FAILS CLOSED (FINAL rc 90 when the
#       primary npm rc was 0); the primary rc stays in FIRST_EXIT. V2 line 82 only logged cleanup_exit.
#   (2) ancestor-inventory equality (/home/user/node_modules names+mtimes) is now a GATE, not a report: CHANGED => FINAL != 0.
#   (3) lock fd 9 closed in the npm child (9>&-), so a quarantined survivor cannot keep the canonical lock.
#   Everything else (one install, guards, budgets, raw npm logs, strict resolution) unchanged from V2.
# C5-S6 SETUP-ONLY — exactly one `npm ci` from the committed lockfile on d51 in the isolated worktree.
# NOT LAUNCHED until the parent grants it. Runs no tests, no scripts of ours, touches nothing outside $WT/node_modules
# (+ npm's own cache under $HOME/.npm and the raw npm logs redirected into our evidence dir).
# Invoke (parent-granted; external bound 1200 s install + 60 s cleanup margin):
#   mkdir -p /home/user/workspace/execution/s6-diagnostic/logs/setup-v3 && \
#   setsid nohup timeout -k 30 1290 bash /home/user/workspace/execution/s6-diagnostic/v3/run-c5-setup-npm-ci.v3.sh \
#     > /home/user/workspace/execution/s6-diagnostic/logs/setup-v3/run-setup.out 2>&1 < /dev/null &
# Guards: canonical lock held by this runner (fd 9) through cleanup; cwd == $WT; HEAD == d51; tree clean before;
# node_modules ABSENT before (one install, never a second); /home/user/package.json absent; the platform-owned
# /home/user/node_modules (pre-existing, 212 links, Sep 20) is inventoried before/after and must be UNCHANGED —
# it is never deleted, moved or treated as a project install. After: tree still clean, node_modules present,
# lockfile unchanged, STRICT resolution of relevant modules into $WT/node_modules recorded.
set -u
WT=/home/user/workspace/worktrees/s6-diagnostic
EX=/home/user/workspace/execution/s6-diagnostic
LOGS=$EX/logs/setup-v3
LOCK=/home/user/workspace/execution/test-validation.lock
EXIT_RECORD=$LOGS/setup.EXIT_RECORD
INSTALL_BUDGET=1200; INSTALL_GRACE=30
START=$(date +%s)
export CI=1 NODE_OPTIONS=--max-old-space-size=2048 TZ=UTC
CPU="taskset -c 0,1"
OWNED_PGIDS=""; CUR_PID=""; CUR_PGID=""; FIRST_EXIT=""; CLEANUP_FAILURES=0; ACCOUNTED=0

ts() { date -u +%FT%TZ; }
rec() { echo "$(ts) step=$1 rc=$2 elapsed=$(( $(date +%s) - START ))s ${3:-}" >> "$EXIT_RECORD"; }
alive() { kill -0 "$1" 2>/dev/null || return 1; [ "$(ps -o stat= -p "$1" 2>/dev/null | cut -c1)" != "Z" ]; }
ancestor_inventory() { ( cd /home/user/node_modules 2>/dev/null && ls -A --time-style=+%s -l | awk '{print $6, $7}' | sort ) | sha256sum | cut -d' ' -f1; }
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
  ( cd "$WT" 2>/dev/null && echo "$(ts) tree_status_lines=$(git status --porcelain | wc -l) node_modules_present=$([ -d node_modules ] && echo yes || echo no)" >> "$EXIT_RECORD" )
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
echo "$(ts) START pid=$$ pgid=$(ps -o pgid= $$ | tr -d ' ') ppid=$PPID" > "$EXIT_RECORD"
exec 9>"$LOCK"; flock -n 9 || die lock-busy 75; echo "$(ts) lock acquired fd=9 path=$LOCK" >> "$EXIT_RECORD"
cd "$WT" || die cd 1
[ "$PWD" = "$WT" ] || die cwd 1

# provenance before
ANCESTOR_BEFORE=$(ancestor_inventory)
{ echo "cwd=$PWD"; echo "HEAD=$(git rev-parse HEAD)"; echo "TREE=$(git rev-parse HEAD^{tree})"
  echo "lock_blob=$(git ls-files -s package-lock.json | awk '{print $2}')"; echo "lock_sha256=$(sha256sum package-lock.json | cut -d' ' -f1)"
  echo "package_json_sha256=$(sha256sum package.json | cut -d' ' -f1)"; echo "lockfileVersion=$(grep -m1 '"lockfileVersion"' package-lock.json)"
  echo "node=$(node -v) node_path=$(command -v node) npm=$(npm -v) npm_path=$(command -v npm)"
  echo "node_modules_present_before=$([ -d node_modules ] && echo yes || echo no)"
  echo "ancestor_package_json_absent=$([ ! -e /home/user/package.json ] && echo yes || echo NO)"
  echo "ancestor_node_modules=$(ls -ld /home/user/node_modules 2>&1) entries=$(ls -A /home/user/node_modules 2>/dev/null | wc -l) inventory_before=$ANCESTOR_BEFORE (platform-owned; read-only for this runner)"
  echo "npm_cache=$(npm config get cache 2>/dev/null)"; echo "registry=$(npm config get registry 2>/dev/null)"
  git status --porcelain | sed 's/^/status: /'; } > "$LOGS/setup.provenance.txt" 2>&1
[ "$(git rev-parse HEAD)" = "d51a191098f483cea9abec6cc7e9f3beffd18c06" ] || die provenance-head 2
[ -z "$(git status --porcelain)" ] || die provenance-tree-not-clean 2
[ ! -d node_modules ] || die provenance-node-modules-already-present-one-install-only 2
[ ! -e /home/user/package.json ] || die provenance-ancestor-package-json-present 2
rec provenance 0

# the one install, in its own owned process group, raw npm logs kept in evidence dir
setsid $CPU npm ci --no-audit --no-fund --loglevel=error --logs-dir="$LOGS/npm-logs" --logs-max=10 > "$LOGS/setup.npm-ci.out" 2>&1 < /dev/null 9>&- &
CUR_PID=$!; sleep 0.2; CUR_PGID=$(ps -o pgid= "$CUR_PID" 2>/dev/null | tr -d ' '); [ -z "$CUR_PGID" ] && CUR_PGID=$CUR_PID; OWNED_PGIDS="$CUR_PGID"
echo "$(ts) npm-ci START child_pid=$CUR_PID child_pgid=$CUR_PGID budget=${INSTALL_BUDGET}s grace=${INSTALL_GRACE}s cmd=[npm ci --no-audit --no-fund --loglevel=error]" >> "$EXIT_RECORD"
w=0; while alive "$CUR_PID" && [ $w -lt "$INSTALL_BUDGET" ]; do sleep 2; w=$((w+2)); done
HOW=exited
if alive "$CUR_PID"; then HOW=budget-TERM; echo "$(ts) npm-ci BUDGET reached: TERM owned pgid=$CUR_PGID" >> "$EXIT_RECORD"; kill -TERM -- "-$CUR_PGID" 2>/dev/null
  g=0; while alive "$CUR_PID" && [ $g -lt "$INSTALL_GRACE" ]; do sleep 1; g=$((g+1)); done
  if alive "$CUR_PID"; then HOW=budget-KILL; kill -KILL -- "-$CUR_PGID" 2>/dev/null; fi; fi
wait "$CUR_PID"; RC=$?
echo "$(ts) npm-ci first_exit rc=$RC how=$HOW" >> "$EXIT_RECORD"
reap_group "$CUR_PGID" 10 "post:npm-ci"; CE=$?; echo "$(ts) npm-ci cleanup_exit=$CE" >> "$EXIT_RECORD"; [ "$CE" -eq 0 ] || CLEANUP_FAILURES=$((CLEANUP_FAILURES+1)); CUR_PID=""; CUR_PGID=""
FIRST_EXIT="npm-ci rc=$RC how=$HOW"
[ "$RC" -eq 0 ] || die npm-ci "$RC" "how=$HOW (node_modules may be partial: report; no retry)"

# provenance after: clean tree, lockfile unchanged, strict resolution into $WT/node_modules, versions
{ echo "tree_status_after:"; git status --porcelain; echo "lock_sha256_after=$(sha256sum package-lock.json | cut -d' ' -f1)"
  echo "node_modules_top_entries=$(ls -A node_modules | wc -l)"; echo "node_modules_bytes=$(du -sb node_modules 2>/dev/null | cut -f1)"
  echo "npm_ls_summary: $(npm ls --depth=0 2>/dev/null | tail -1)"; } > "$LOGS/setup.after.txt" 2>&1
[ -z "$(git status --porcelain)" ] || die after-tree-not-clean 6
node -e '
const p=require("path"); const wt=process.argv[1]; let bad=0;
for (const m of ["react","react-test-renderer","react-native","@testing-library/react-native","@tanstack/react-query","@tanstack/query-core","@tanstack/react-query-persist-client","@tanstack/query-persist-client-core","@tanstack/query-async-storage-persister","@react-native-async-storage/async-storage","jest-expo","jest","jest-circus","jest-runtime","@jest/core","babel-jest","@babel/core","babel-preset-expo","zustand","scheduler"]) {
  let r; try { r=require.resolve(m+"/package.json",{paths:[wt]}); } catch(e){ console.log(`BAD ${m} unresolved`); bad++; continue; }
  const v=require(r).version; const inside=r.startsWith(p.join(wt,"node_modules")+p.sep);
  console.log(`${inside?"OK ":"BAD"} ${m}@${v} ${r}`); if(!inside) bad++; }
process.exit(bad?1:0)' "$WT" > "$LOGS/setup.module-paths.txt" 2>&1 || die after-strict-resolution 5
rec after-checks 0
echo "FIRST_EXIT $FIRST_EXIT" >> "$EXIT_RECORD"; echo "$(ts) primary setup rc=0 (node_modules present in $WT; tree clean; strict resolution OK) — FINAL decided by cleanup/ancestor gates" >> "$EXIT_RECORD"
finish 0
