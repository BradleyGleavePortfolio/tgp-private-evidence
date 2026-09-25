#!/usr/bin/env bash
# S8C-BC-6 (LAND-2 CI red, L2-1 class B, closure option (a)): one-file test-only correction on land/s8-c on top of 2542af44.
# Canonical lock nonblocking (yield rc 75); exact parent + one-file delta; scoped prettier 3.9.9 (pinned prefix, offline) +
# eslint; one genuine hooked Bradley commit (heap 4096); then, still under the slot, the corrected spec plus the L2-2
# default-config sweep (every spec reading prisma/migrations, docs/contracts or BASE_HEAD/EXPECTED_MIGRATIONS pins).
# No push. Stop on first failure (the sweep runs to completion and records; a red suite is reported, not retried).
set -uo pipefail
C=/home/user/workspace/tgp-private-evidence/execution/daceddc8/landing/ci/s8-c/bc6; W=/home/user/workspace/worktrees/daceddc8-land-s8-c
B=/home/user/workspace/execution/64e33dc7/recovery-reset/s8c/tools/prettier-3.9.9; LOCK=/home/user/workspace/execution/test-validation.lock
PARENT=2542af44ab5b4d296f84e9f5f311632f7f5aeb25; FILE=test/scout/g2-s8c-db-guard.spec.ts
LOG=$C/run/s8c-bc6-gate.log; ts(){ date -u +%FT%TZ; }; log(){ echo "$(ts) $*" | tee -a "$LOG"; }
die(){ log "STOP rc=$1 stage=$2 $3"; log "RELEASING (fd9 closes at exit; lock file preserved)"; exit "$1"; }
[ "${S8C_BC6_RELAY:-}" = 1 ] || { echo "REFUSED: relay flag" >&2; exit 70; }
[ -e "$LOG" ] && { echo "REFUSED: $LOG exists; the gate runs once" >&2; exit 70; }
[ -e "$LOCK" ] || exit 75; exec 9>>"$LOCK"; flock -n 9 || { echo "REFUSED: lock busy (live holder)" >&2; exit 75; }
log "ACQUIRED pid=$$ fd9 inode=$(stat -c %i "$LOCK") lslocks=$(lslocks 2>/dev/null | grep -c test-validation.lock) postgres=$(pgrep -c -x postgres || true)"
cd "$W" || die 71 pre "cd"
[ "$(git rev-parse HEAD)" = "$PARENT" ] && [ "$(git branch --show-current)" = "land/s8-c" ] || die 71 pre "HEAD/branch is not $PARENT land/s8-c"
CHANGED=$( (git diff --name-only; git diff --cached --name-only; git ls-files --others --exclude-standard) | sort -u)
[ "$CHANGED" = "$FILE" ] || die 71 pre "delta is not exactly $FILE: [$(echo "$CHANGED" | tr '\n' ' ')]"
git diff > "$C/run/delta-from-2542af44.1file.patch"; log "DELTA $(sha256sum "$C/run/delta-from-2542af44.1file.patch" | cut -c1-64) numstat=$(git diff --numstat -- "$FILE" | cut -f1,2 | tr '\t' /) blob=$(git hash-object "$FILE")"
# unchanged pins and neighbours
for s in "const BASE_HEAD = '93389265a846095b846fa8f1fb0dad782fb6ee9f';" "const EXPECTED_MIGRATIONS = 171;" "const S8B_MIGRATION = '20270122000000_scout_native_provenance_expand';" 'expect(bootstrap).toContain(`BASE_HEAD=${BASE_HEAD}\n`);' 'expect(harness).toContain(`export const EXPECTED_MIGRATIONS = ${EXPECTED_MIGRATIONS};`);'; do grep -qF -- "$s" "$FILE" || die 76 content "pin line missing: $s"; done
[ "$(git diff -- "$FILE" | grep -c '^-[^-]' )" -le 9 ] || die 76 content "removed more than the three scan lines + comment/scan setup"
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
log "HEAD=$HEAD tree=$(git rev-parse 'HEAD^{tree}') parent=$PARENT spec_blob=$(git rev-parse HEAD:$FILE) author=$(git log -1 --format='%an <%ae>') committer=$(git log -1 --format='%cn <%ce>') porcelain=$(git status --porcelain --untracked-files=all | wc -l) files=$(git diff-tree --no-commit-id -r --name-only "$PARENT" "$HEAD" | tr '\n' ' ')"
# sweep (still holding fd9): corrected spec alone, then the L2-2 set, default config, --ci, heap 4096
log "SPEC_START"; timeout -k 30 900 ./node_modules/.bin/jest --ci --runTestsByPath "$FILE" > "$C/run/jest-guard-spec.log" 2>&1; rc=$?; log "SPEC_END rc=$rc $(grep -E '^Tests:' "$C/run/jest-guard-spec.log" | tr -s ' ')"
SPEC_RC=$rc
mapfile -t SUITES < "$C/sweep-suites.txt"; log "SWEEP_START suites=${#SUITES[@]}"
timeout -k 30 2400 ./node_modules/.bin/jest --ci --runTestsByPath "${SUITES[@]}" > "$C/run/jest-sweep.log" 2>&1; rc=$?
log "SWEEP_END rc=$rc $(grep -E '^(Test Suites|Tests):' "$C/run/jest-sweep.log" | tr -s ' ' | tr '\n' ';')"
grep -E '^(PASS|FAIL) ' "$C/run/jest-sweep.log" | sed 's/ ([0-9.]* s)$//' | sort > "$C/run/jest-sweep.suites.txt"
[ "$(git rev-parse HEAD)" = "$HEAD" ] && [ -z "$(git status --porcelain --untracked-files=all)" ] || log "NOTE worktree changed during sweep"
(cd "$C/run" && sha256sum *.log *.patch *.txt > RECEIPTS.sha256)
log "RELEASED head=$HEAD spec_rc=$SPEC_RC sweep_rc=$rc $(ts) (fd9 closes at exit; lock file preserved)"
[ $SPEC_RC -eq 0 ] && [ $rc -eq 0 ] || exit 77
