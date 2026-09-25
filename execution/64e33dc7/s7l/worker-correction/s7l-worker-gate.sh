#!/usr/bin/env bash
# S7-L worker runtime-identity correction follow-up under the canonical slot (grant S7L-WC-1, daceddc8/SCOPE.md;
# parent slot relay 16:42Z). Derived from the consumed s7l/runtime-correction/slot-5-runtime-correction.sh template.
# Lock taken IN THIS PROCESS (flock -n fd 9), held until exit; lock file preserved; refuses a live holder.
# Steps: preconditions (HEAD == a68cdac7, exactly test/utils/g2-s7l-worker.cjs modified) -> verified isolated prettier
# 3.9.9 prefix (reuse, never re-copied) -> prettier check/format on the one file -> eslint on the one file -> checkpoint ->
# genuine hooked ordinary Bradley commit (heap 4096, offline npx, no bypass; R75 via hook) -> v4 export (thin +
# full-history bundle, patches, manifest, HEAD file) -> release. No unit/PG/48-suite run, no regen, no install.
set -uo pipefail
L=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l
C=$L/worker-correction; W=/home/user/workspace/worktrees/64e33dc7-s7l
RUNTIME_ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset
B=$RUNTIME_ROOT/s7l/tools/prettier-3.9.9
LOCK=/home/user/workspace/execution/test-validation.lock
BASE=93389265a846095b846fa8f1fb0dad782fb6ee9f
V1=839b54c53ccb252f95b4ec63df0b08595bbe7698
V2=54970cd937afc8dea689b33243961abfef8b9dd6
PARENT=a68cdac70d81aea384fdc99c01c9c983a08e80eb
PARENT_TREE=6c00e2483d0407e1ba8b8e97d03ff0e1ea2b88eb
LOG=$C/gate.log
FILES="test/utils/g2-s7l-worker.cjs"
ts(){ date -u +%FT%TZ; }
log(){ echo "$(ts) $*" | tee -a "$LOG"; }
sha(){ sha256sum "$1" | cut -c1-64; }
[ -e "$LOCK" ] || { log "REFUSED lock file absent"; exit 75; }
exec 9>>"$LOCK"; flock -n 9 || { log "REFUSED canonical lock busy (live holder); not waiting"; exit 75; }
log "ACQUIRED pid=$$ fd9 inode=$(stat -c %i "$LOCK") lslocks=$(lslocks 2>/dev/null | grep -c test-validation || true)"
STAGE=preflight
finish(){ unset npm_config_prefix; log "RELEASING stage=$STAGE rc=$1 (fd9 closes at exit; lock file preserved)"; exit "$1"; }
export NODE_OPTIONS=--max-old-space-size=4096 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false PRISMA_HIDE_UPDATE_MESSAGE=1
export GIT_AUTHOR_NAME="Bradley Gleave" GIT_AUTHOR_EMAIL=bradley@bradleytgpcoaching.com GIT_COMMITTER_NAME="Bradley Gleave" GIT_COMMITTER_EMAIL=bradley@bradleytgpcoaching.com
cd "$W" || finish 70
[ "$(git rev-parse HEAD)" = "$PARENT" ] || { log "PRECONDITION_FAIL HEAD != $PARENT"; finish 70; }
[ "$(git rev-parse 'HEAD^{tree}')" = "$PARENT_TREE" ] || { log "PRECONDITION_FAIL parent tree"; finish 70; }
[ "$(git status --porcelain --untracked-files=all | sed 's/^ M //' | sort | tr '\n' ' ')" = "test/utils/g2-s7l-worker.cjs " ] \
  || { log "PRECONDITION_FAIL modified set is not exactly the one granted path: $(git status --porcelain --untracked-files=all | tr '\n' ' ')"; finish 70; }
log "NM_HIDDEN_LOCK=$(sha node_modules/.package-lock.json 2>/dev/null || echo absent)"
log "NM_CLIENT_INDEX_DTS=$(sha node_modules/.prisma/client/index.d.ts 2>/dev/null || echo absent)"
pgrep -af "jest|tsc|prisma|postgres|prettier|lefthook|eslint" | grep -v "$$" | grep -v s7l-worker-gate | tee -a "$LOG" | grep -q . && log "WARN other heavy processes present (recorded)"
git diff > "$C/p2-source-delta-preformat.patch"
# ---- 1 prettier prefix: reuse the verified isolated copy (never re-copied)
STAGE=prettier-prefix
[ -d "$B" ] || { log "PREFIX_ABSENT $B"; finish 71; }
( cd "$B" && sha256sum -c /home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256 ) > "$C/prettier-prefix-verify.log" 2>&1; rc=$?
log "PREFIX_VERIFY rc=$rc ok_lines=$(grep -c ': OK$' "$C/prettier-prefix-verify.log") readlink=$(readlink "$B/bin/prettier")"
[ $rc = 0 ] && [ "$(readlink "$B/bin/prettier")" = "../lib/node_modules/prettier/bin/prettier.cjs" ] || finish 71
export npm_config_prefix="$B"
V=$(npx --no-install prettier --version 2>>"$LOG"); log "NPX_PRETTIER_VERSION=$V"; [ "$V" = 3.9.9 ] || finish 71
[ ! -e "$W/node_modules/.bin/prettier" ] || { log "PRECONDITION_FAIL prettier inside product tree"; finish 71; }
# ---- 2 formatting on the one file only
STAGE=prettier
npx --no-install prettier --check $FILES > "$C/prettier-check-1.log" 2>&1; rc=$?; log "PRETTIER_CHECK_1 rc=$rc"
if [ $rc != 0 ]; then
  TOFIX=$(grep '^\[warn\] ' "$C/prettier-check-1.log" | sed 's/^\[warn\] //' | grep -v 'Code style issues' | grep -v 'Run Prettier' || true)
  log "PRETTIER_WRITE files: $(echo $TOFIX | tr '\n' ' ')"
  npx --no-install prettier --write $TOFIX > "$C/prettier-write-1.log" 2>&1 || { log "PRETTIER_WRITE_FAIL"; finish 72; }
  npx --no-install prettier --check $FILES > "$C/prettier-check-2.log" 2>&1; rc=$?; log "PRETTIER_CHECK_2 rc=$rc"; [ $rc = 0 ] || finish 72
fi
node --check $FILES >> "$LOG" 2>&1 || { log "NODE_CHECK_FAIL"; finish 72; }
git add -- $FILES
[ "$(git diff --cached --name-only | sort | tr '\n' ' ')" = "test/utils/g2-s7l-worker.cjs " ] || { log "STAGED_SET_FAIL"; finish 70; }
# ---- 3 scoped lint only (the hook's eslint/prettier globs do not include *.cjs, so this is the only lint of the file;
#        R75 supplied by the genuine hook; no unit/PG run granted)
STAGE=eslint
npx --no-install eslint --no-warn-ignored --max-warnings 0 $FILES > "$C/eslint.raw.log" 2>&1; rc=$?; log "ESLINT rc=$rc"; [ $rc = 0 ] || finish 74
# ---- 4 checkpoint + genuine hooked commit
STAGE=checkpoint
bash "$L/checkpoint.sh" worker-correction-02-formatted-precommit >> "$LOG" 2>&1 || finish 75
TREE=$(git write-tree); log "STAGED_TREE=$TREE WORKER_BLOB=$(git rev-parse ":$FILES") WORKER_SHA=$(sha $FILES)"
STAGE=commit
git commit -F "$C/commit-message.txt" > "$C/commit-attempt-1.raw.log" 2>&1; rc=$?
tail -12 "$C/commit-attempt-1.raw.log" >> "$LOG"; log "GIT_COMMIT rc=$rc"; [ $rc = 0 ] || finish 76
HEAD=$(git rev-parse HEAD); HTREE=$(git rev-parse 'HEAD^{tree}')
log "HEAD=$HEAD TREE=$HTREE author=$(git log -1 --format='%an <%ae> / %cn <%ce>') parent=$(git rev-parse HEAD^) gp=$(git rev-parse HEAD^^) ggp=$(git rev-parse HEAD^^^) base=$(git rev-parse HEAD^^^^)"
[ "$(git rev-parse HEAD^)" = "$PARENT" ] && [ "$(git rev-parse HEAD^^)" = "$V2" ] && [ "$(git rev-parse HEAD^^^)" = "$V1" ] && [ "$(git rev-parse HEAD^^^^)" = "$BASE" ] && [ -z "$(git status --porcelain --untracked-files=all)" ] || { log "LINEAGE_FAIL"; finish 76; }
[ "$(git diff --name-only "$PARENT" HEAD | tr '\n' ' ')" = "test/utils/g2-s7l-worker.cjs " ] || { log "DELTA_FAIL"; finish 76; }
# ---- 5 v4 export (new versioned location; earlier exports untouched)
STAGE=export; E=$L/bundle/v4; mkdir -p "$E"
git bundle create "$E/s7l-v4-${HEAD:0:12}.bundle" "$BASE..HEAD" >> "$LOG" 2>&1 && git bundle verify "$E/s7l-v4-${HEAD:0:12}.bundle" >> "$LOG" 2>&1; log "BUNDLE_THIN rc=$?"
git bundle create "$E/s7l-v4-${HEAD:0:12}-full-history.bundle" HEAD exec64/s7l-replacement >> "$LOG" 2>&1 && git bundle verify "$E/s7l-v4-${HEAD:0:12}-full-history.bundle" >> "$LOG" 2>&1; log "BUNDLE_FULL rc=$?"
git diff --name-status "$PARENT" HEAD > "$E/MANIFEST-name-status-${PARENT:0:12}-to-${HEAD:0:12}.txt"
git diff --binary "$PARENT" HEAD > "$E/s7l-v4-followup-${PARENT:0:12}-to-${HEAD:0:12}.patch"
git diff --binary "$BASE" HEAD > "$E/s7l-v4-cumulative-${BASE:0:12}-to-${HEAD:0:12}.patch"
{ echo "base=$BASE"; echo "parent=$PARENT"; echo "parent_tree=$PARENT_TREE"; echo "head=$HEAD"; echo "tree=$HTREE"; echo "worker_blob=$(git rev-parse HEAD:$FILES)"; echo "branch=$(git rev-parse --abbrev-ref HEAD)"; git log -1 --format='author=%an <%ae>%ncommitter=%cn <%ce>%ndate=%cI'; } > "$E/HEAD-${HEAD:0:12}.txt"
( cd "$E" && sha256sum * > SHA256SUMS )
STAGE=done; log "DONE head=$HEAD tree=$HTREE"; finish 0
