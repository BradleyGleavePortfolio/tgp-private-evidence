#!/usr/bin/env bash
# S7-L minimum-correction follow-up under the canonical slot (S7L_MINIMUM_CORRECTION_GRANT.md, activation 04:55Z).
# Lock taken IN THIS PROCESS (flock -n fd 9), held until exit; lock file preserved; refuses a live holder.
# Steps: preconditions (HEAD == 839b54c5, exactly the 3 granted paths modified) -> verified isolated prettier 3.9.9 prefix
# (reuse, never re-copied) -> prettier check/format on the 3 files -> eslint on the 3 files -> R75 staged -> the changed
# lifecycle unit spec only -> checkpoint -> genuine hooked ordinary Bradley commit (heap 4096, offline npx, no bypass)
# -> v2 export (thin + full-history bundle, patch, manifest, HEAD file) -> release. No contract regen, no 48-suite rerun, no PG.
set -uo pipefail
L=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l
C=$L/correction; W=/home/user/workspace/worktrees/64e33dc7-s7l
RUNTIME_ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset
B=$RUNTIME_ROOT/s7l/tools/prettier-3.9.9
LOCK=/home/user/workspace/execution/test-validation.lock
BASE=93389265a846095b846fa8f1fb0dad782fb6ee9f
PARENT=839b54c53ccb252f95b4ec63df0b08595bbe7698
PARENT_TREE=f02205c60ad0bfeb24ce82d74b0025ee9a185df6
LOG=$C/slot-4.log
FILES="src/scout/lifecycle/lifecycle.service.ts test/rls-g2-s7l.spec.ts test/scout/lifecycle/lifecycle.service.spec.ts"
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
[ "$(git status --porcelain --untracked-files=all | sed 's/^ M //' | sort | tr '\n' ' ')" = "src/scout/lifecycle/lifecycle.service.ts test/rls-g2-s7l.spec.ts test/scout/lifecycle/lifecycle.service.spec.ts " ] \
  || { log "PRECONDITION_FAIL modified set is not exactly the three granted paths: $(git status --porcelain --untracked-files=all | tr '\n' ' ')"; finish 70; }
pgrep -af "jest|tsc|prisma|postgres|prettier" | grep -v "$$" | grep -v slot-4 | tee -a "$LOG" | grep -q . && log "WARN other heavy processes present (recorded)"
git diff > "$C/f1-f2-source-delta-preformat.patch"
# ---- 1 prettier prefix: reuse the verified builder-local isolated copy (never re-copied)
STAGE=prettier-prefix
[ -d "$B" ] || { log "PREFIX_ABSENT $B"; finish 71; }
( cd "$B" && sha256sum -c /home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256 ) > "$C/prettier-prefix-verify.log" 2>&1; rc=$?
log "PREFIX_VERIFY rc=$rc ok_lines=$(grep -c ': OK$' "$C/prettier-prefix-verify.log") readlink=$(readlink "$B/bin/prettier")"
[ $rc = 0 ] && [ "$(readlink "$B/bin/prettier")" = "../lib/node_modules/prettier/bin/prettier.cjs" ] || finish 71
export npm_config_prefix="$B"
V=$(npx --no-install prettier --version 2>>"$LOG"); log "NPX_PRETTIER_VERSION=$V"; [ "$V" = 3.9.9 ] || finish 71
[ ! -e "$W/node_modules/.bin/prettier" ] || { log "PRECONDITION_FAIL prettier inside product tree"; finish 71; }
# ---- 2 formatting on the three files only
STAGE=prettier
npx --no-install prettier --check $FILES > "$C/prettier-check-1.log" 2>&1; rc=$?; log "PRETTIER_CHECK_1 rc=$rc"
if [ $rc != 0 ]; then
  TOFIX=$(grep '^\[warn\] ' "$C/prettier-check-1.log" | sed 's/^\[warn\] //' | grep -v 'Code style issues' | grep -v 'Run Prettier' || true)
  log "PRETTIER_WRITE files: $(echo $TOFIX | tr '\n' ' ')"
  npx --no-install prettier --write $TOFIX > "$C/prettier-write-1.log" 2>&1 || { log "PRETTIER_WRITE_FAIL"; finish 72; }
  npx --no-install prettier --check $FILES > "$C/prettier-check-2.log" 2>&1; rc=$?; log "PRETTIER_CHECK_2 rc=$rc"; [ $rc = 0 ] || finish 72
fi
git add -- $FILES
[ "$(git diff --cached --name-only | sort | tr '\n' ' ')" = "src/scout/lifecycle/lifecycle.service.ts test/rls-g2-s7l.spec.ts test/scout/lifecycle/lifecycle.service.spec.ts " ] || { log "STAGED_SET_FAIL"; finish 70; }
# ---- 3 scoped lint / R75 / changed unit spec
STAGE=eslint
npx eslint --no-warn-ignored --max-warnings 0 $FILES > "$C/eslint.raw.log" 2>&1; rc=$?; log "ESLINT rc=$rc"; [ $rc = 0 ] || finish 74
STAGE=r75
node scripts/check-r75.js --mode=staged > "$C/r75.log" 2>&1; rc=$?; log "R75 rc=$rc"; [ $rc = 0 ] || finish 74
STAGE=jest-lifecycle
./node_modules/.bin/jest --ci test/scout/lifecycle/lifecycle.service.spec.ts > "$C/jest-lifecycle-unit.raw.log" 2>&1; rc=$?
log "JEST_LIFECYCLE rc=$rc $(grep -E '^Tests:' "$C/jest-lifecycle-unit.raw.log")"; grep -n "FUTURE deadline" "$C/jest-lifecycle-unit.raw.log" | head -2 >> "$LOG"; [ $rc = 0 ] || finish 73
# ---- 4 checkpoint + genuine hooked commit
STAGE=checkpoint
bash "$L/checkpoint.sh" correction-01-precommit >> "$LOG" 2>&1 || finish 75
TREE=$(git write-tree); log "STAGED_TREE=$TREE"
STAGE=commit
git commit -F "$C/commit-message.txt" > "$C/commit-attempt-1.raw.log" 2>&1; rc=$?
tail -12 "$C/commit-attempt-1.raw.log" >> "$LOG"; log "GIT_COMMIT rc=$rc"; [ $rc = 0 ] || finish 76
HEAD=$(git rev-parse HEAD); HTREE=$(git rev-parse 'HEAD^{tree}')
log "HEAD=$HEAD TREE=$HTREE author=$(git log -1 --format='%an <%ae> / %cn <%ce>') parent=$(git rev-parse HEAD^) grandparent=$(git rev-parse HEAD^^)"
[ "$(git rev-parse HEAD^)" = "$PARENT" ] && [ "$(git rev-parse HEAD^^)" = "$BASE" ] && [ -z "$(git status --porcelain --untracked-files=all)" ] || { log "LINEAGE_FAIL"; finish 76; }
# ---- 5 v2 export (new versioned location; earlier exports untouched)
STAGE=export; E=$L/bundle/v2; mkdir -p "$E"
git bundle create "$E/s7l-v2-${HEAD:0:12}.bundle" "$BASE..HEAD" >> "$LOG" 2>&1 && git bundle verify "$E/s7l-v2-${HEAD:0:12}.bundle" >> "$LOG" 2>&1; log "BUNDLE_THIN rc=$?"
git bundle create "$E/s7l-v2-${HEAD:0:12}-full-history.bundle" HEAD exec64/s7l-replacement >> "$LOG" 2>&1 && git bundle verify "$E/s7l-v2-${HEAD:0:12}-full-history.bundle" >> "$LOG" 2>&1; log "BUNDLE_FULL rc=$?"
git diff --name-status "$PARENT" HEAD > "$E/MANIFEST-name-status-${PARENT:0:12}-to-${HEAD:0:12}.txt"
git diff --binary "$PARENT" HEAD > "$E/s7l-v2-followup-${PARENT:0:12}-to-${HEAD:0:12}.patch"
git diff --binary "$BASE" HEAD > "$E/s7l-v2-cumulative-${BASE:0:12}-to-${HEAD:0:12}.patch"
{ echo "base=$BASE"; echo "parent=$PARENT"; echo "parent_tree=$PARENT_TREE"; echo "head=$HEAD"; echo "tree=$HTREE"; echo "branch=$(git rev-parse --abbrev-ref HEAD)"; git log -1 --format='author=%an <%ae>%ncommitter=%cn <%ce>%ndate=%cI'; } > "$E/HEAD-${HEAD:0:12}.txt"
( cd "$E" && sha256sum * > SHA256SUMS )
STAGE=done; log "DONE head=$HEAD tree=$HTREE"; finish 0
