#!/usr/bin/env bash
# S8-C source-gate slot runner (PREPARED, NOT EXECUTED; runs only after the parent's explicit source relay).
# Scope: donor node_modules copy, builder-local prettier@3.9.9 prefix copy, scoped format/lint/R75, tsc (heap 4096),
# affected default Jest, genuine lefthook commit as Bradley Gleave (no trailers, no --no-verify), then fill-pins.sh and a
# versioned export. Generator stage runs ONLY when the parent separately relays it (S8C_GENERATOR_RELAY=1): it executes
# the unchanged `npm run contract:importer` and records the derived artifact delta; no script/version/spec edits.
# NO PG, initdb, bootstrap, migration, prisma migrate, or rls Jest here. Lock: canonical nonblocking flock held to exit.
set -uo pipefail
G=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c/gates
W=/home/user/workspace/worktrees/64e33dc7-s8c
DONOR_NM=/home/user/workspace/worktrees/64e33dc7-env/node_modules
PREFIX_SRC=/home/user/workspace/execution/64e33dc7/recovery-reset/tools/prettier-3.9.9
PREFIX_MANIFEST=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256
B=/home/user/workspace/execution/64e33dc7/recovery-reset/s8c/tools/prettier-3.9.9
LOCK=/home/user/workspace/execution/test-validation.lock
BASE=93389265a846095b846fa8f1fb0dad782fb6ee9f
EXPECT_NM_LOCK=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44
EXPECT_PKG_LOCK=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55
EXPECT_LAUNCHER=6e922134a3c76fd4de202959bb6aef50bde0c994148075003a15569b7197906e
LOG=$G/run/s8c-source-slot.log; mkdir -p "$G/run"
ts(){ date -u +%FT%TZ; }; log(){ echo "$(ts) $*" | tee -a "$LOG"; }
die(){ log "STOP rc=$1 stage=$2 $3"; log "RELEASING (fd9 closes at exit; lock file preserved)"; exit "$1"; }
sha(){ sha256sum "$1" | cut -c1-64; }
[ "${S8C_SOURCE_RELAY:-}" = 1 ] || { echo "REFUSED: no explicit parent source relay (S8C_SOURCE_RELAY=1 unset)" >&2; exit 70; }
[ -e "$LOCK" ] || { echo "REFUSED: canonical lock file absent (never created here)" >&2; exit 75; }
exec 9>>"$LOCK"; flock -n 9 || { echo "REFUSED: lock busy ($(lslocks 2>/dev/null | grep -c test-validation.lock) holders)" >&2; exit 75; }
log "ACQUIRED pid=$$ fd9 inode=$(stat -c %i "$LOCK") lslocks=$(lslocks 2>/dev/null | grep -c test-validation.lock)"
cd "$W" || die 71 pre "worktree missing"
# --- preconditions
[ "$(git rev-parse HEAD)" = "$BASE" ] || die 71 pre "HEAD != base (already committed? use fill-pins.sh instead)"
[ "$(git rev-parse --abbrev-ref HEAD)" = exec64/s8c-replacement ] || die 71 pre "wrong branch"
[ "$(sha package-lock.json)" = "$EXPECT_PKG_LOCK" ] || die 71 pre "package-lock.json drift"
git status --porcelain --untracked-files=all | awk '{print $2}' | sort > "$G/run/changed-files.txt"
SCOPE_RE='^(src/scout/reconstruct/(native/|families\.ts|mapping-spec\.ts)|src/scout/scout-reconstruct\.(dto|service)\.ts|test/scout/reconstruct/native/|test/rls-g2-s8c\.spec\.ts|test/scout/g2-s8c-db-guard\.spec\.ts|test/utils/g2-s8c-)'
[ "${S8C_GENERATOR_RELAY:-}" = 1 ] && SCOPE_RE="${SCOPE_RE%)}|docs/contracts/importer-openapi\.json)"
grep -qvE "$SCOPE_RE" "$G/run/changed-files.txt" && die 71 pre "changed file outside S8-C writable scope: $(grep -vE "$SCOPE_RE" "$G/run/changed-files.txt" | tr '\n' ' ')"
[ "$(git diff HEAD --stat -- src/scout/reconstruct/mapping-spec.ts | tail -1 | grep -oE '[0-9]+ insertion' | cut -d' ' -f1)" = 2 ] && [ -z "$(git diff HEAD -- src/scout/reconstruct/mapping-spec.ts | grep -E '^-[^-]')" ] || die 71 pre "mapping-spec.ts must be exactly +2 additive lines"
ls "$W/.git" >/dev/null 2>&1 || die 71 pre "not a worktree"
GITDIR=$(git rev-parse --git-common-dir); [ -x "$GITDIR/hooks/pre-commit" ] && grep -q lefthook "$GITDIR/hooks/pre-commit" || die 71 pre "lefthook pre-commit hook missing in $GITDIR/hooks"
log "PRECONDITIONS_OK changed=$(wc -l < "$G/run/changed-files.txt") files"
# --- donor node_modules copy (RUNTIME_SETUP_RECEIPT steps 2-3)
[ "$(sha "$DONOR_NM/.package-lock.json")" = "$EXPECT_NM_LOCK" ] || die 71 donor "donor hidden lock drift"
if [ -e node_modules ]; then
  [ "${S8C_RERUN:-}" = 1 ] || die 71 donor "node_modules already present; refuse to overwrite"
  log "DONOR_EXISTS (rerun after in-scope remediation; copy from attempt 1 re-verified, not re-copied)"
else timeout -k 30 900 cp -a "$DONOR_NM" node_modules || die 71 donor "cp -a rc=$?"; fi
[ "$(sha node_modules/.package-lock.json)" = "$EXPECT_NM_LOCK" ] || die 71 donor "copied hidden lock drift"
[ -z "$(find node_modules -maxdepth 1 -type l)" ] || die 71 donor "symlinks at node_modules top level"
[ -e node_modules/.bin/prettier ] && die 71 donor "unexpected node_modules/.bin/prettier"
log "DONOR_COPY_OK entries=$(ls node_modules | wc -l) size=$(du -sh node_modules | cut -f1) client_dts=$(sha node_modules/.prisma/client/index.d.ts)"
# --- builder-local prettier prefix (FORMATTER_TOOLING_RECEIPT steps 1-4)
if [ -e "$B" ]; then log "PREFIX_EXISTS $B (re-verified, not re-copied)"; else mkdir -p "$(dirname "$B")"; cp -a "$PREFIX_SRC" "$B" || die 71 prettier "prefix cp -a rc=$?"; fi
( cd "$B" && sha256sum -c --quiet "$PREFIX_MANIFEST" ) || die 71 prettier "prefix manifest mismatch"
[ "$(readlink "$B/bin/prettier")" = ../lib/node_modules/prettier/bin/prettier.cjs ] || die 71 prettier "launcher symlink"
[ "$(sha "$B/lib/node_modules/prettier/bin/prettier.cjs")" = "$EXPECT_LAUNCHER" ] || die 71 prettier "launcher sha"
export npm_config_prefix="$B" npm_config_offline=true
V=$(npx --no-install prettier --version 2>&1); [ "$V" = 3.9.9 ] || die 71 prettier "npx prettier version '$V'"
log "PREFIX_VERIFY rc=0 ok_lines=$(wc -l < "$PREFIX_MANIFEST") NPX_PRETTIER_VERSION=$V"
# --- scoped formatting: check; if needed, --write ONLY the S8-C-owned changed files, then re-check (S7-L precedent)
FMT_FILES=$(grep -E '\.(ts|cjs|js)$' "$G/run/changed-files.txt" | tr '\n' ' ')
timeout -k 30 300 npx --no-install prettier --check $FMT_FILES > "$G/run/prettier-check-1.log" 2>&1; rc=$?; log "PRETTIER_CHECK_1 rc=$rc"
if [ $rc -ne 0 ]; then
  timeout -k 30 300 npx --no-install prettier --write $FMT_FILES > "$G/run/prettier-write.log" 2>&1 || die 72 prettier "write rc=$?"
  git status --porcelain --untracked-files=all | awk '{print $2}' | sort | diff - "$G/run/changed-files.txt" >/dev/null || die 72 prettier "formatting touched a file outside the changed set"
  timeout -k 30 300 npx --no-install prettier --check $FMT_FILES > "$G/run/prettier-check-2.log" 2>&1 || die 72 prettier "re-check rc=$?"
  log "PRETTIER_WRITE files=$(grep -c . "$G/run/prettier-write.log") then PRETTIER_CHECK_2 rc=0"
fi
# --- generator transfer (ONLY under a separate explicit relay; unchanged script, derived artifact only)
if [ "${S8C_GENERATOR_RELAY:-}" = 1 ]; then
  ART=docs/contracts/importer-openapi.json; before=$(sha $ART)
  git diff --quiet -- scripts/export-importer-contract.ts package.json || die 72 generator "generator script/package modified; not owned"
  timeout -k 30 600 npm run -s contract:importer > "$G/run/contract-regenerate.log" 2>&1 || die 72 generator "rc=$?"
  after=$(sha $ART); git diff HEAD -- $ART > "$G/run/contract-delta.patch"
  log "CONTRACT_REGEN rc=0 before=$before after=$after delta_lines=$(grep -cE '^[+-][^+-]' "$G/run/contract-delta.patch") programs_added=$(grep -cE '^\+.*"programs"' "$G/run/contract-delta.patch")"
  [ -z "$(git status --porcelain --untracked-files=all | awk '{print $2}' | grep -vxF -f "$G/run/changed-files.txt" | grep -vx $ART)" ] || die 72 generator "generation touched files other than $ART"
else log "GENERATOR_SKIPPED (no S8C_GENERATOR_RELAY; contract artifact left untouched, importer-contract.spec expected to fail on the enum until generation — recorded, not masked)"; fi
# --- R75 / tsc / eslint on the staged set
git add -A -- $(cat "$G/run/changed-files.txt") ${S8C_GENERATOR_RELAY:+docs/contracts/importer-openapi.json} || die 72 stage "git add"
timeout -k 30 300 node scripts/check-r75.js --mode=staged > "$G/run/r75.log" 2>&1 || die 72 r75 "rc=$?"; log "R75 rc=0"
NODE_OPTIONS=--max-old-space-size=4096 timeout -k 30 1200 npx --no-install tsc --noEmit > "$G/run/tsc.log" 2>&1 || die 72 tsc "rc=$? $(head -5 "$G/run/tsc.log" | tr '\n' ' ')"; log "TSC rc=0 heap=4096"
timeout -k 30 600 npx --no-install eslint --no-warn-ignored --max-warnings 0 $(git diff --cached --name-only | grep -E '\.(ts|cjs|js)$') > "$G/run/eslint.log" 2>&1 || die 72 eslint "rc=$?"; log "ESLINT rc=0"
# --- affected default Jest (no rls config, no PG): native unit specs + accepted reconstruct/entities/contract/module-graph specs
timeout -k 30 1500 ./node_modules/.bin/jest --ci --runInBand 'test/scout/reconstruct/' 'test/scout/entities/' 'test/scout/g2-s8c-db-guard' 'test/contracts/importer-contract' 'test/module-graph' --testPathIgnorePatterns '\.live\.spec\.ts$' > "$G/run/jest-affected.log" 2>&1; rc=$?
log "JEST_AFFECTED rc=$rc $(grep -E '^(Tests|Test Suites):' "$G/run/jest-affected.log" | tr '\n' ' ')"
[ $rc -eq 0 ] || die 72 jest "affected default Jest failed; failures preserved in run/jest-affected.log"
# --- genuine hooked commit
log "STAGED_TREE=$(git write-tree)"
GIT_AUTHOR_NAME='Bradley Gleave' GIT_AUTHOR_EMAIL='bradley@bradleytgpcoaching.com' GIT_COMMITTER_NAME='Bradley Gleave' GIT_COMMITTER_EMAIL='bradley@bradleytgpcoaching.com' \
  timeout -k 30 1800 git commit -F "$G/commit-message.txt" > "$G/run/commit.raw.log" 2>&1; rc=$?
log "COMMIT rc=$rc hooks: $(grep -ciE 'lefthook|pre-commit' "$G/run/commit.raw.log") hook lines"
[ $rc -eq 0 ] || die 73 commit "hooked commit failed; see run/commit.raw.log (no --no-verify retry)"
unset npm_config_prefix npm_config_offline
HEAD=$(git rev-parse HEAD); log "HEAD=$HEAD tree=$(git rev-parse 'HEAD^{tree}') author=$(git log -1 --format='%an <%ae>') committer=$(git log -1 --format='%cn <%ce>') porcelain=$(git status --porcelain --untracked-files=all | wc -l)"
git log -1 --format=%B | grep -qE '^[A-Za-z-]+: ' && die 73 commit "trailer-like line in commit message"
( cd "$G/run" && sha256sum -- * > RECEIPTS.sha256 )
log "RELEASED head=$HEAD tree=$(git rev-parse 'HEAD^{tree}') $(ts) (fd9 closes at exit; lock file preserved). NEXT (lock-free): fill-pins.sh, versioned export checkpoints/v3 with bundle; parent dispatches dual review; PG only under a separate grant."
exit 0
