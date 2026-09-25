#!/usr/bin/env bash
# S8C-BC-3 (class B harness-only closure): one-file ordinary follow-up gate, run ONLY after diagnostic (a) ended rc=0
# and the parent slot order allows. Canonical lock nonblocking in this process (yield rc 75 to any holder); exact parent
# + one-file delta; scoped prettier --check and eslint (pinned isolated prettier prefix, offline npm); one genuine hooked
# Bradley commit (heap 4096). No Jest, PG, generator, install or extra gates. Stop on first failure; never rerun.
set -uo pipefail
C=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c/harness-correction; W=/home/user/workspace/worktrees/64e33dc7-s8c
B=/home/user/workspace/execution/64e33dc7/recovery-reset/s8c/tools/prettier-3.9.9; LOCK=/home/user/workspace/execution/test-validation.lock
PARENT=e0cee7e04bef88811310f6dde1fd921f45d103ad; FILE=test/utils/g2-s8c-harness.ts
mkdir -p "$C/run"; LOG=$C/run/s8c-harness-gate.log; ts(){ date -u +%FT%TZ; }; log(){ echo "$(ts) $*" | tee -a "$LOG"; }
die(){ log "STOP rc=$1 stage=$2 $3"; log "RELEASING (fd9 closes at exit; lock file preserved)"; exit "$1"; }
[ "${S8C_HARNESS_RELAY:-}" = 1 ] || { echo "REFUSED: relay flag" >&2; exit 70; }
[ -e "$LOG" ] && { echo "REFUSED: $LOG exists; the gate runs once" >&2; exit 70; }
grep -q '^DIAG_A_END rc=0' "$C/diagnostic/a/diag-a.log" 2>/dev/null || { echo "REFUSED: diagnostic (a) not ended rc=0" >&2; exit 70; }
[ -e "$LOCK" ] || exit 75; exec 9>>"$LOCK"; flock -n 9 || { echo "REFUSED: lock busy (live holder)" >&2; exit 75; }
log "ACQUIRED pid=$$ fd9 inode=$(stat -c %i "$LOCK") lslocks=$(lslocks 2>/dev/null | grep -c test-validation.lock) postgres=$(pgrep -c -x postgres || true)"
cd "$W" || die 71 pre "cd"
[ "$(git rev-parse HEAD)" = "$PARENT" ] || die 71 pre "HEAD is not $PARENT"
CHANGED=$( (git diff --name-only; git diff --cached --name-only; git ls-files --others --exclude-standard) | sort -u)
[ "$CHANGED" = "$FILE" ] || die 71 pre "delta is not exactly $FILE: [$(echo "$CHANGED" | tr '\n' ' ')]"
[ "$(git diff --numstat -- "$FILE" | cut -f1,2)" = "$(printf '8\t3')" ] || log "NOTE numstat differs from prepared +8/-3: $(git diff --numstat -- "$FILE" | cut -f1,2 | tr '\t' /)"
git diff > "$C/run/delta-from-e0cee7e0.1file.patch"; log "DELTA $(sha256sum "$C/run/delta-from-e0cee7e0.1file.patch" | cut -c1-64) blob=$(git hash-object "$FILE")"
grep -q 'primary_muscle,updated_at)' "$FILE" || die 76 content "updated_at column missing from catalog INSERT"
[ "$(git diff -- "$FILE" | grep -c '^[-+]' )" -le 20 ] || die 76 content "delta larger than the prepared one-function change"
export npm_config_prefix="$B" npm_config_offline=true NODE_OPTIONS=--max-old-space-size=4096
[ "$(npx --no-install prettier --version 2>/dev/null)" = "3.9.9" ] || die 71 pre "prettier prefix not 3.9.9"
npx --no-install prettier --check "$FILE" > "$C/run/prettier-check.log" 2>&1; rc=$?; log "PRETTIER_CHECK rc=$rc"; [ $rc -eq 0 ] || die 76 format "see run/prettier-check.log"
timeout -k 30 600 ./node_modules/.bin/eslint --no-warn-ignored --max-warnings 0 "$FILE" > "$C/run/eslint.log" 2>&1; rc=$?; log "ESLINT rc=$rc"; [ $rc -eq 0 ] || die 76 lint "see run/eslint.log"
git add -- "$FILE" || die 72 stage "git add"; log "STAGED_TREE=$(git write-tree)"
GIT_AUTHOR_NAME='Bradley Gleave' GIT_AUTHOR_EMAIL='bradley@bradleytgpcoaching.com' GIT_COMMITTER_NAME='Bradley Gleave' GIT_COMMITTER_EMAIL='bradley@bradleytgpcoaching.com' \
  timeout -k 30 1800 git commit -F "$C/commit-message.txt" > "$C/run/commit.raw.log" 2>&1; rc=$?
log "COMMIT rc=$rc hook_lines=$(grep -cE '✔️|🥊|❌' "$C/run/commit.raw.log")"; [ $rc -eq 0 ] || die 73 commit "hooked commit failed; see run/commit.raw.log (no --no-verify, no rerun)"
git log -1 --format=%B | grep -qE '^[A-Za-z-]+: ' && die 73 commit "trailer-like line"
HEAD=$(git rev-parse HEAD); [ "$(git rev-parse HEAD^)" = "$PARENT" ] || die 73 commit "parent is not $PARENT"
log "HEAD=$HEAD tree=$(git rev-parse 'HEAD^{tree}') parent=$PARENT harness_blob=$(git rev-parse HEAD:$FILE) author=$(git log -1 --format='%an <%ae>') committer=$(git log -1 --format='%cn <%ce>') porcelain=$(git status --porcelain --untracked-files=all | wc -l) files=$(git diff-tree --no-commit-id -r --name-only "$PARENT" "$HEAD" | tr '\n' ' ')"
log "RELEASED head=$HEAD tree=$(git rev-parse 'HEAD^{tree}') $(ts) (fd9 closes at exit; lock file preserved)"
