#!/usr/bin/env bash
# Resume after in-scope Jest remediation (parent mail 21:45): only the new source bytes' necessary checks + the failed /
# newly affected Jest suites, then the genuine hooked commit (hooks run prettier/eslint/tsc/R75 fully). No regeneration.
set -uo pipefail
G=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c/gates; W=/home/user/workspace/worktrees/64e33dc7-s8c
B=/home/user/workspace/execution/64e33dc7/recovery-reset/s8c/tools/prettier-3.9.9; LOCK=/home/user/workspace/execution/test-validation.lock
LOG=$G/run/s8c-gates-resume.log; ts(){ date -u +%FT%TZ; }; log(){ echo "$(ts) $*" | tee -a "$LOG"; }
die(){ log "STOP rc=$1 stage=$2 $3"; log "RELEASING (fd9 closes at exit; lock file preserved)"; exit "$1"; }
[ -e "$LOCK" ] || exit 75; exec 9>>"$LOCK"; flock -n 9 || { echo "REFUSED: lock busy" >&2; exit 75; }
log "ACQUIRED pid=$$ fd9 inode=$(stat -c %i "$LOCK") lslocks=$(lslocks 2>/dev/null | grep -c test-validation.lock)"
cd "$W" || exit 71
CHANGED=$(git diff --name-only; git diff --cached --name-only; git ls-files --others --exclude-standard); CHANGED=$(echo "$CHANGED" | sort -u)
echo "$CHANGED" > "$G/run/resume-changed-files.txt"; log "RESUME_CHANGED $(echo "$CHANGED" | tr '\n' ' ')"
export npm_config_prefix="$B" npm_config_offline=true
# Grant: "Use heap 4096 for TypeScript and genuine hooks" — the hook's own `npx tsc --noEmit` inherits this; attempt 6
# (run/attempt-6-resume2/commit.raw.log) OOMed at the default heap after R75/prettier/eslint passed.
export NODE_OPTIONS=--max-old-space-size=4096
if [ "${S8C_COMMIT_ONLY:-}" = 1 ]; then
  [ "$(git write-tree)" = "${S8C_EXPECT_STAGED_TREE:?}" ] || die 71 pre "staged tree changed since the last gated run"
  log "COMMIT_ONLY staged_tree=$(git write-tree) (bytes unchanged since attempt 6; gates not replayed, hooks run fully)"
fi
[ "$(npx --no-install prettier --version)" = 3.9.9 ] || die 71 prettier "version"
if [ "${S8C_COMMIT_ONLY:-}" != 1 ]; then
FMT=$(echo "$CHANGED" | grep -E '\.(ts|cjs|js)$' | tr '\n' ' ')
timeout -k 30 300 npx --no-install prettier --check $FMT > "$G/run/prettier-check-resume-1.log" 2>&1; rc=$?; log "PRETTIER_CHECK rc=$rc"
if [ $rc -ne 0 ]; then timeout -k 30 300 npx --no-install prettier --write $FMT > "$G/run/prettier-write-resume.log" 2>&1 || die 72 prettier "write"; timeout -k 30 300 npx --no-install prettier --check $FMT > "$G/run/prettier-check-resume-2.log" 2>&1 || die 72 prettier "recheck"; log "PRETTIER_WRITE then CHECK_2 rc=0"; fi
timeout -k 30 600 npx --no-install eslint --no-warn-ignored --max-warnings 0 $FMT > "$G/run/eslint-resume.log" 2>&1 || die 72 eslint "rc=$? $(head -8 "$G/run/eslint-resume.log" | tr '\n' ' ')"; log "ESLINT rc=0 (changed files)"
# failed suites + suites importing families.ts / native-families.ts (registry consumers)
SUITES=${S8C_SUITES:-'test/scout/reconstruct/mapping-spec.equivalence.spec.ts test/scout/reconstruct/mapping-spec.spec.ts test/scout/reconstruct/mapping-spec.third-source.spec.ts test/scout/reconstruct/native/ test/scout/reconstruct/conformance-alpha test/scout/reconstruct/source-mapper-registry.spec.ts test/scout/reconstruct/scout-reconstruct.service.spec.ts test/scout/reconstruct/scout-reconstruct.families.spec.ts test/scout/reconstruct/truecoach- test/scout/g2-s8c-db-guard'}
timeout -k 30 1500 ./node_modules/.bin/jest --ci --runInBand $SUITES --testPathIgnorePatterns '\.live\.spec\.ts$' > "$G/run/jest-resume.log" 2>&1; rc=$?
log "JEST_RESUME rc=$rc $(grep -E '^(Tests|Test Suites):' "$G/run/jest-resume.log" | tr '\n' ' ')"
grep -E '^(PASS|FAIL) ' "$G/run/jest-resume.log" | sort -u | tee -a "$LOG" >/dev/null
if [ $rc -ne 0 ]; then
  FAILS=$(grep -E '^FAIL ' "$G/run/jest-resume.log" | sort -u | awk '{print $2}' | tr '\n' ' ')
  if [ "${S8C_ALLOW_KNOWN_FAIL:-}" = "$FAILS" ]; then log "JEST_KNOWN_FAIL_ONLY '$FAILS' (reported unowned-test assumption; parent decision) — proceeding to hooked commit with the failure preserved"; else die 72 jest "failures: $FAILS"; fi
fi
fi
git add -A -- $CHANGED || die 72 stage "git add"; log "STAGED_TREE=$(git write-tree)"
GIT_AUTHOR_NAME='Bradley Gleave' GIT_AUTHOR_EMAIL='bradley@bradleytgpcoaching.com' GIT_COMMITTER_NAME='Bradley Gleave' GIT_COMMITTER_EMAIL='bradley@bradleytgpcoaching.com' \
  timeout -k 30 1800 git commit -F "$G/commit-message.txt" > "$G/run/commit.raw.log" 2>&1; rc=$?
log "COMMIT rc=$rc hook_lines=$(grep -ciE 'lefthook|pre-commit|prettier|eslint|tsc|r75' "$G/run/commit.raw.log")"
[ $rc -eq 0 ] || die 73 commit "hooked commit failed; see run/commit.raw.log (no --no-verify)"
unset npm_config_prefix npm_config_offline
HEAD=$(git rev-parse HEAD); git log -1 --format=%B | grep -qE '^[A-Za-z-]+: ' && die 73 commit "trailer-like line"
log "HEAD=$HEAD tree=$(git rev-parse 'HEAD^{tree}') author=$(git log -1 --format='%an <%ae>') committer=$(git log -1 --format='%cn <%ce>') porcelain=$(git status --porcelain --untracked-files=all | wc -l)"
( cd "$G/run" && sha256sum -- * > RECEIPTS.sha256 2>/dev/null )
log "RELEASED head=$HEAD tree=$(git rev-parse 'HEAD^{tree}') $(ts) (fd9 closes at exit; lock file preserved)"
