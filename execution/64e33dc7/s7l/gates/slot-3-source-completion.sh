#!/usr/bin/env bash
# S7-L source completion under the canonical slot (S7L_SOURCE_GATES_GRANT.md completion relay 04:25Z).
# The lock is taken IN THIS PROCESS (flock -n on fd 9) and held until exit (through cleanup/export); no separate holder.
# Steps: prettier prefix copy+verify -> prettier check/format (owned staged files only) -> contract regeneration for the
# granted ingest 409 documentation -> targeted contract spec -> R75/eslint on touched files -> checkpoint draft-04 ->
# genuine hooked Bradley commit (heap 4096, offline npx, no --no-verify) -> head/tree/bundle export -> release.
set -uo pipefail
L=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l
G=$L/gates; W=/home/user/workspace/worktrees/64e33dc7-s7l
RUNTIME_ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset
SRC_PREFIX=$RUNTIME_ROOT/tools/prettier-3.9.9
B=$RUNTIME_ROOT/s7l/tools/prettier-3.9.9
LOCK=/home/user/workspace/execution/test-validation.lock
BASE=93389265a846095b846fa8f1fb0dad782fb6ee9f
LOG=$G/slot-3.log
ts(){ date -u +%FT%TZ; }
log(){ echo "$(ts) $*" | tee -a "$LOG"; }
sha(){ sha256sum "$1" | cut -c1-64; }
[ -e "$LOCK" ] || { log "REFUSED lock file absent"; exit 75; }
exec 9>>"$LOCK"; flock -n 9 || { log "REFUSED canonical lock busy (live holder); not waiting"; exit 75; }
log "RUN2 (run 1 stopped at stage prettier rc=72: wrong file filter, formatting of 11 ts/cjs files already written) ACQUIRED pid=$$ fd9 inode=$(stat -c %i "$LOCK") lslocks=$(lslocks 2>/dev/null | grep -c test-validation || true)"
STAGE=preflight; rc=0
finish(){ log "RELEASING stage=$STAGE rc=$1 (fd9 closes at exit; lock file preserved)"; exit "$1"; }
export NODE_OPTIONS=--max-old-space-size=4096 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false PRISMA_HIDE_UPDATE_MESSAGE=1
export GIT_AUTHOR_NAME="Bradley Gleave" GIT_AUTHOR_EMAIL=bradley@bradleytgpcoaching.com GIT_COMMITTER_NAME="Bradley Gleave" GIT_COMMITTER_EMAIL=bradley@bradleytgpcoaching.com
cd "$W" || finish 70
[ "$(git rev-parse HEAD)" = "$BASE" ] || { log "PRECONDITION_FAIL HEAD != base"; finish 70; }
pgrep -af "jest|tsc|prisma|postgres|prettier" | grep -v "$$" | grep -v slot-3 | tee -a "$LOG" | grep -q . && log "WARN other heavy processes present (recorded)"
# ---- 1 prettier prefix: builder-local isolated copy, verified against the receipt manifest
STAGE=prettier-copy
if [ -e "$B" ]; then log "PREFIX_EXISTS $B (copied by run 1 at 04:27:23Z; re-verified below, not re-copied)"; else
mkdir -p "$(dirname "$B")" && cp -a "$SRC_PREFIX" "$B" || { log "COPY_FAIL"; finish 71; }; fi
( cd "$B" && sha256sum -c /home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256 ) > "$G/prettier-prefix-verify.log" 2>&1; rc=$?
log "PREFIX_VERIFY rc=$rc ok_lines=$(grep -c ': OK$' "$G/prettier-prefix-verify.log") readlink=$(readlink "$B/bin/prettier") launcher_sha=$(sha "$B/lib/node_modules/prettier/bin/prettier.cjs")"
[ $rc = 0 ] && [ "$(readlink "$B/bin/prettier")" = "../lib/node_modules/prettier/bin/prettier.cjs" ] || finish 71
export npm_config_prefix="$B"
V=$(npx --no-install prettier --version 2>>"$LOG"); log "NPX_PRETTIER_VERSION=$V"; [ "$V" = 3.9.9 ] || finish 71
# ---- 2 formatting: check the owned staged files; write only those (all staged paths are S7-L-owned)
STAGE=prettier
git add -A
# same file set the lefthook prettier command receives: glob '*.{ts,tsx,js,jsx,json,md,yml,yaml}' (run 1 passed .prisma/.sh too -> parser errors, rc 2; see prettier-check-2.log)
FILES=$(git diff --cached --name-only --diff-filter=ACMR "$BASE" | grep -E '\.(ts|tsx|js|jsx|json|md|yml|yaml)$')
echo "$FILES" > "$G/slot-3-staged-files.txt"
npx --no-install prettier --check $FILES > "$G/prettier-check-3.log" 2>&1; rc=$?; log "PRETTIER_CHECK_3 rc=$rc $(grep -c '^\[warn\]' "$G/prettier-check-3.log") warn lines"
if [ $rc != 0 ]; then
  TOFIX=$(grep '^\[warn\] ' "$G/prettier-check-3.log" | sed 's/^\[warn\] //' | grep -v 'Code style issues' | grep -v 'Run Prettier' || true)
  log "PRETTIER_WRITE files: $(echo $TOFIX | tr '\n' ' ')"
  npx --no-install prettier --write $TOFIX > "$G/prettier-write-2.log" 2>&1 || { log "PRETTIER_WRITE_FAIL"; finish 72; }
  npx --no-install prettier --check $FILES > "$G/prettier-check-4.log" 2>&1; rc=$?; log "PRETTIER_CHECK_4 rc=$rc"; [ $rc = 0 ] || finish 72
fi
# ---- 3 contract regeneration (owned generator, real DTOs incl. the granted ingest 409 decorator)
STAGE=contract-regen
BEFORE=$(sha docs/contracts/importer-openapi.json)
npm run contract:importer > "$G/contract-regenerate-2.log" 2>&1; rc=$?; AFTER=$(sha docs/contracts/importer-openapi.json)
log "CONTRACT_REGEN rc=$rc before=$BEFORE after=$AFTER version=$(node -e 'console.log(require("./docs/contracts/importer-openapi.json").info.version)') ingest409=$(node -e 'const c=require("./docs/contracts/importer-openapi.json");console.log(JSON.stringify(c.paths["/api/scout/ingest"].post.responses["409"].content["application/json"].schema.allOf[1].properties.code.enum))')"
[ $rc = 0 ] || finish 73
# ---- 4 targeted contract spec + R75/eslint on all staged files (formatting may have touched them)
STAGE=targeted-gates
git add -A
./node_modules/.bin/jest --ci test/contracts/importer-contract.spec.ts > "$G/jest-contract-rerun-2.raw.log" 2>&1; rc=$?; log "JEST_CONTRACT rc=$rc $(grep -E '^Tests:' "$G/jest-contract-rerun-2.raw.log")"; [ $rc = 0 ] || finish 74
node scripts/check-r75.js --mode=staged >> "$G/r75.log" 2>&1; rc=$?; log "R75 rc=$rc"; [ $rc = 0 ] || finish 74
TS=$(git diff --cached --name-only --diff-filter=ACMR "$BASE" | grep -E '\.(ts|cjs|js)$')
npx eslint --no-warn-ignored --max-warnings 0 $TS > "$G/eslint-final.raw.log" 2>&1; rc=$?; log "ESLINT rc=$rc"; [ $rc = 0 ] || finish 74
# ---- 5 checkpoint of the exact bytes before the hooked commit
STAGE=checkpoint
bash "$L/checkpoint.sh" draft-04-precommit >> "$LOG" 2>&1 || finish 75
TREE=$(git write-tree); log "STAGED_TREE=$TREE"
# ---- 6 genuine hooked commit (lefthook pre-commit + commit-msg; heap 4096; offline npx; no bypass)
STAGE=commit
git commit -F "$G/commit-message.txt" > "$G/commit-attempt-3.raw.log" 2>&1; rc=$?
tail -12 "$G/commit-attempt-3.raw.log" >> "$LOG"; log "GIT_COMMIT rc=$rc"
[ $rc = 0 ] || finish 76
HEAD=$(git rev-parse HEAD); HTREE=$(git rev-parse 'HEAD^{tree}')
log "HEAD=$HEAD TREE=$HTREE author=$(git log -1 --format='%an <%ae> / %cn <%ce>') parent=$(git rev-parse HEAD^)"
[ "$HTREE" = "$TREE" ] || log "WARN committed tree differs from pre-commit write-tree (hook rewrote bytes?)"
[ -z "$(git status --porcelain --untracked-files=all)" ] || log "WARN worktree not clean after commit: $(git status --porcelain | head -5 | tr '\n' ';')"
# ---- 7 export: self-contained bundle + manifest
STAGE=export
mkdir -p "$L/bundle"
git bundle create "$L/bundle/s7l-${HEAD:0:12}.bundle" "$BASE..HEAD" >> "$LOG" 2>&1 && git bundle verify "$L/bundle/s7l-${HEAD:0:12}.bundle" >> "$LOG" 2>&1; log "BUNDLE rc=$?"
git diff --name-status "$BASE" HEAD > "$L/bundle/MANIFEST-name-status-${HEAD:0:12}.txt"
git diff --binary "$BASE" HEAD > "$L/bundle/s7l-${HEAD:0:12}.patch"
{ echo "base=$BASE"; echo "head=$HEAD"; echo "tree=$HTREE"; echo "branch=$(git rev-parse --abbrev-ref HEAD)"; git log -1 --format='author=%an <%ae>%ncommitter=%cn <%ce>%ndate=%cI'; } > "$L/bundle/HEAD-${HEAD:0:12}.txt"
( cd "$L/bundle" && sha256sum * > SHA256SUMS )
STAGE=done; unset npm_config_prefix
log "DONE head=$HEAD tree=$HTREE"
finish 0
