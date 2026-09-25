#!/usr/bin/env bash
# S8C_REVIEW_MINIMUM_CORRECTION_GRANT (amended 05:16Z, relay 05:16Z): seven-path ordinary follow-up gate. Canonical lock
# nonblocking in this process; scoped prettier (pinned 3.9.9 prefix, write then check) + eslint on the changed files; the
# four native unit suites with default Jest config; genuine hooked ordinary commit (heap 4096). Stop on any failure. No PG.
set -uo pipefail
C=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c/review-correction; W=/home/user/workspace/worktrees/64e33dc7-s8c
B=/home/user/workspace/execution/64e33dc7/recovery-reset/s8c/tools/prettier-3.9.9; LOCK=/home/user/workspace/execution/test-validation.lock
PARENT=af9f7f5438fa545394b6d28792411439ded66caf
ALLOWED='src/scout/reconstruct/native/native-contract.ts
src/scout/reconstruct/native/native-provenance.ts
src/scout/reconstruct/native/native-rules.ts
src/scout/reconstruct/native/native-writers.ts
test/rls-g2-s8c.spec.ts
test/scout/reconstruct/native/native-rules.spec.ts
test/scout/reconstruct/native/native-writers.spec.ts'
SUITES='test/scout/reconstruct/native/native-writers.spec.ts test/scout/reconstruct/native/native-rules.spec.ts test/scout/reconstruct/native/engine-handoff.spec.ts test/scout/reconstruct/native/native-families.spec.ts'
mkdir -p "$C/run"; LOG=$C/run/s8c-review-gate.log; ts(){ date -u +%FT%TZ; }; log(){ echo "$(ts) $*" | tee -a "$LOG"; }
die(){ log "STOP rc=$1 stage=$2 $3"; log "RELEASING (fd9 closes at exit; lock file preserved)"; exit "$1"; }
[ "${S8C_REVIEW_RELAY:-}" = 1 ] || { echo "REFUSED: relay flag" >&2; exit 70; }
[ -e "$LOCK" ] || exit 75; exec 9>>"$LOCK"; flock -n 9 || { echo "REFUSED: lock busy (live holder)" >&2; exit 75; }
log "ACQUIRED pid=$$ fd9 inode=$(stat -c %i "$LOCK") lslocks=$(lslocks 2>/dev/null | grep -c test-validation.lock) postgres=$(pgrep -c -x postgres || true)"
cd "$W" || die 71 pre "cd"
[ "$(git rev-parse HEAD)" = "$PARENT" ] || die 71 pre "HEAD is not $PARENT"
CHANGED=$( (git diff --name-only; git diff --cached --name-only; git ls-files --others --exclude-standard) | sort -u)
[ "$CHANGED" = "$ALLOWED" ] || die 71 pre "delta is not exactly the seven granted paths: [$(echo "$CHANGED" | tr '\n' ' ')]"
export npm_config_prefix="$B" npm_config_offline=true NODE_OPTIONS=--max-old-space-size=4096
[ "$(npx --no-install prettier --version 2>/dev/null)" = "3.9.9" ] || die 71 pre "prettier prefix not 3.9.9"
npx --no-install prettier --write $CHANGED > "$C/run/prettier-write.log" 2>&1; rc=$?; log "PRETTIER_WRITE rc=$rc"; [ $rc -eq 0 ] || die 76 prettier "see run/prettier-write.log"
git diff > "$C/run/delta-from-af9f7f54.7path.patch"; log "DELTA $(sha256sum "$C/run/delta-from-af9f7f54.7path.patch" | cut -c1-64) $(git diff --shortstat)"
npx --no-install prettier --check $CHANGED > "$C/run/prettier-check.log" 2>&1; rc=$?; log "PRETTIER_CHECK rc=$rc"; [ $rc -eq 0 ] || die 76 prettier "see run/prettier-check.log"
timeout -k 30 1200 npx eslint --no-warn-ignored --max-warnings 0 $CHANGED > "$C/run/eslint.log" 2>&1; rc=$?; log "ESLINT rc=$rc"; [ $rc -eq 0 ] || die 77 eslint "see run/eslint.log"
timeout -k 30 1800 npx jest --ci --runTestsByPath $SUITES > "$C/run/jest-native-4.log" 2>&1; rc=$?
log "JEST_NATIVE_4 rc=$rc $(grep -E '^(Tests|Test Suites):' "$C/run/jest-native-4.log" | tr '\n' ' ')"; [ $rc -eq 0 ] || die 78 jest "see run/jest-native-4.log (failure preserved; no auto replay)"
git add -- $CHANGED || die 72 stage "git add"; log "STAGED_TREE=$(git write-tree)"
GIT_AUTHOR_NAME='Bradley Gleave' GIT_AUTHOR_EMAIL='bradley@bradleytgpcoaching.com' GIT_COMMITTER_NAME='Bradley Gleave' GIT_COMMITTER_EMAIL='bradley@bradleytgpcoaching.com' \
  timeout -k 30 1800 git commit -F "$C/commit-message.txt" > "$C/run/commit.raw.log" 2>&1; rc=$?
log "COMMIT rc=$rc hook_lines=$(grep -cE '✔️|🥊|❌' "$C/run/commit.raw.log")"; [ $rc -eq 0 ] || die 73 commit "hooked commit failed; see run/commit.raw.log (no --no-verify)"
git log -1 --format=%B | grep -qE '^[A-Za-z-]+: ' && die 73 commit "trailer-like line"
HEAD=$(git rev-parse HEAD); [ "$(git rev-parse HEAD^)" = "$PARENT" ] || die 73 commit "parent is not $PARENT"
log "HEAD=$HEAD tree=$(git rev-parse 'HEAD^{tree}') parent=$PARENT author=$(git log -1 --format='%an <%ae>') committer=$(git log -1 --format='%cn <%ce>') porcelain=$(git status --porcelain --untracked-files=all | wc -l) files=$(git diff-tree --no-commit-id -r --name-only "$PARENT" "$HEAD" | tr '\n' ' ')"
log "RELEASED head=$HEAD tree=$(git rev-parse 'HEAD^{tree}') $(ts) (fd9 closes at exit; lock file preserved)"
