#!/usr/bin/env bash
# S9-A gate under the canonical slot (grant S9-A-1, daceddc8/SCOPE.md; parent relay 11:24 PDT: H = 1c5fbb04).
# Derived from the consumed 64e33dc7/s7l/worker-correction/s7l-worker-gate.sh template.
# Lock taken IN THIS PROCESS (flock -n fd 9), held until exit; lock file preserved; refuses a live holder.
# Steps: preconditions (HEAD == H, branch exec-dace/s9-a2, exactly the 4 untracked S9-A files at their reviewed shas,
# no node_modules) -> cp -a node_modules from the landed S8-C worktree (composed prisma client) -> verified isolated
# prettier 3.9.9 prefix (reuse, never re-copied) -> scoped prettier check/format on the 4 files -> scoped eslint ->
# tsc --noEmit (heap 4096) -> jest --ci affected suites -> one genuine hooked ordinary Bradley commit (heap 4096,
# offline npx, no bypass; R75/tsc/eslint/prettier via the hook) -> receipts -> release. No push, no install, no regen.
set -uo pipefail
E=/home/user/workspace/tgp-private-evidence/execution/daceddc8/s9/gate
W=/home/user/workspace/worktrees/daceddc8-s9a
DONOR=/home/user/workspace/worktrees/daceddc8-land-s8-c/node_modules
B=/home/user/workspace/execution/64e33dc7/recovery-reset/s7l/tools/prettier-3.9.9
PREFIX_MANIFEST=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256
LOCK=/home/user/workspace/execution/test-validation.lock
H=1c5fbb0441178e0cfe6e9f8d72e955c645c265e9
LOG=$E/gate.log
FILES="src/scout/reconciliation/types.ts src/scout/reconciliation/coverage.ts src/scout/reconciliation/reconcile.ts test/scout/reconciliation/reconcile.spec.ts"
SUITES="test/scout/reconciliation/reconcile.spec.ts test/scout/lifecycle/arbiter.spec.ts test/scout/lifecycle/lifecycle.service.spec.ts test/invariants/locked_defaults.spec.ts test/contracts/importer-contract.spec.ts test/doctrine-cleanup.spec.ts test/ci/delivery-artifact.spec.ts test/deploy-readiness.spec.ts test/dependency-compatibility.spec.ts test/scout/g2-s8c-db-guard.spec.ts"
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
[ "$(git rev-parse HEAD)" = "$H" ] || { log "PRECONDITION_FAIL HEAD != $H"; finish 70; }
[ "$(git rev-parse --abbrev-ref HEAD)" = exec-dace/s9-a2 ] || { log "PRECONDITION_FAIL branch"; finish 70; }
[ "$(git status --porcelain --untracked-files=all | sed 's/^?? //' | sort | tr '\n' ' ')" = "src/scout/reconciliation/coverage.ts src/scout/reconciliation/reconcile.ts src/scout/reconciliation/types.ts test/scout/reconciliation/reconcile.spec.ts " ] \
  || { log "PRECONDITION_FAIL untracked set: $(git status --porcelain --untracked-files=all | tr '\n' ' ')"; finish 70; }
[ "$(sha src/scout/reconciliation/types.ts)" = eff1479cd2b735aacadc42ee3e2280dcfaf2e4fcc27a1fb90fd2c2bf2db1dbfa ] || { log "PRECONDITION_FAIL types.ts sha"; finish 70; }
[ "$(sha src/scout/reconciliation/coverage.ts)" = c6b224fa860261d6240c5bd62b07d419c6b9346c0b0de4eaac64dd9215926701 ] || { log "PRECONDITION_FAIL coverage.ts sha"; finish 70; }
[ "$(sha src/scout/reconciliation/reconcile.ts)" = 83d7673b024513bbee938bf4a5467c4faa9306739f15ae53b69722936d7d9e1f ] || { log "PRECONDITION_FAIL reconcile.ts sha"; finish 70; }
[ "$(sha test/scout/reconciliation/reconcile.spec.ts)" = 99068057b0b99d95c9601c02130e4eca2b3b07acd0e0088fae146cb2f54edb74 ] || { log "PRECONDITION_FAIL spec sha"; finish 70; }
[ ! -e node_modules ] || { log "PRECONDITION_FAIL node_modules already present"; finish 70; }
[ "$(git -C "$(dirname "$DONOR")" rev-parse HEAD)" = "$H" ] || log "WARN donor worktree HEAD != H (recorded)"
pgrep -af "jest|tsc|prisma|postgres|prettier|lefthook|eslint" | grep -v "$$" | grep -v s9a-gate | tee -a "$LOG" | grep -q . && log "WARN other heavy processes present (recorded)"
for f in $FILES; do cp "$f" "$E/preformat-$(basename "$f")"; done
# ---- 1 node_modules from the landed S8-C worktree (composed schema's prisma client)
STAGE=node_modules
log "DONOR_HIDDEN_LOCK=$(sha "$DONOR/.package-lock.json" 2>/dev/null || echo absent) DONOR_CLIENT_INDEX_DTS=$(sha "$DONOR/.prisma/client/index.d.ts" 2>/dev/null || echo absent) DONOR_ENTRIES=$(ls "$DONOR" | wc -l)"
cp -a "$DONOR" node_modules; rc=$?; log "CP_A rc=$rc NM_ENTRIES=$(ls node_modules | wc -l) NM_HIDDEN_LOCK=$(sha node_modules/.package-lock.json 2>/dev/null || echo absent) NM_CLIENT_INDEX_DTS=$(sha node_modules/.prisma/client/index.d.ts 2>/dev/null || echo absent)"
[ $rc = 0 ] || finish 71
[ ! -e node_modules/.bin/prettier ] || { log "PRECONDITION_FAIL prettier inside product tree"; finish 71; }
for b in tsc jest eslint lefthook; do [ -x node_modules/.bin/$b ] || { log "PRECONDITION_FAIL node_modules/.bin/$b missing"; finish 71; }; done
# ---- 2 prettier prefix: reuse the verified isolated copy (never re-copied)
STAGE=prettier-prefix
( cd "$B" && sha256sum -c "$PREFIX_MANIFEST" ) > "$E/prettier-prefix-verify.log" 2>&1; rc=$?
log "PREFIX_VERIFY rc=$rc ok_lines=$(grep -c ': OK$' "$E/prettier-prefix-verify.log") readlink=$(readlink "$B/bin/prettier")"
[ $rc = 0 ] && [ "$(readlink "$B/bin/prettier")" = "../lib/node_modules/prettier/bin/prettier.cjs" ] || finish 71
export npm_config_prefix="$B"
V=$(npx --no-install prettier --version 2>>"$LOG"); log "NPX_PRETTIER_VERSION=$V"; [ "$V" = 3.9.9 ] || finish 71
# ---- 3 scoped prettier on exactly the 4 files
STAGE=prettier
npx --no-install prettier --check $FILES > "$E/prettier-check-1.log" 2>&1; rc=$?; log "PRETTIER_CHECK_1 rc=$rc"
if [ $rc != 0 ]; then
  TOFIX=$(grep '^\[warn\] ' "$E/prettier-check-1.log" | sed 's/^\[warn\] //' | grep -v 'Code style issues' | grep -v 'Run Prettier' || true)
  log "PRETTIER_TOFIX=$(echo $TOFIX)"
  npx --no-install prettier --write $TOFIX > "$E/prettier-write-1.log" 2>&1 || { log "PRETTIER_WRITE_FAIL"; finish 72; }
  npx --no-install prettier --check $FILES > "$E/prettier-check-2.log" 2>&1; rc=$?; log "PRETTIER_CHECK_2 rc=$rc"; [ $rc = 0 ] || finish 72
fi
for f in $FILES; do log "POSTFORMAT $f sha256=$(sha "$f") lines=$(wc -l < "$f")"; done
# ---- 4 scoped eslint
STAGE=eslint
npx --no-install eslint --no-warn-ignored --max-warnings 0 $FILES > "$E/eslint.raw.log" 2>&1; rc=$?; log "ESLINT rc=$rc"; [ $rc = 0 ] || finish 74
# ---- 5 tsc (whole repo; tsconfig has no include so test/ is type-checked)
STAGE=tsc
npx --no-install tsc --noEmit > "$E/tsc.raw.log" 2>&1; rc=$?; log "TSC rc=$rc lines=$(wc -l < "$E/tsc.raw.log")"; [ $rc = 0 ] || { tail -40 "$E/tsc.raw.log" >> "$LOG"; finish 73; }
# ---- 6 jest, affected suites (default config, no PG)
STAGE=jest
./node_modules/.bin/jest --ci $SUITES > "$E/jest.raw.log" 2>&1; rc=$?; log "JEST rc=$rc"
grep -E '^(Tests|Test Suites|Snapshots|Time):' "$E/jest.raw.log" | tee -a "$LOG"
[ $rc = 0 ] || { grep -E '✕|●' "$E/jest.raw.log" | head -40 >> "$LOG"; finish 73; }
# ---- 7 stage + genuine hooked commit
STAGE=stage
git add -- $FILES
[ "$(git diff --cached --name-only | sort | tr '\n' ' ')" = "src/scout/reconciliation/coverage.ts src/scout/reconciliation/reconcile.ts src/scout/reconciliation/types.ts test/scout/reconciliation/reconcile.spec.ts " ] || { log "STAGED_SET_FAIL"; finish 70; }
TREE=$(git write-tree); log "STAGED_TREE=$TREE"
for f in $FILES; do log "STAGED_BLOB $f $(git rev-parse ":$f")"; done
STAGE=commit
git commit -F "$E/commit-message.txt" > "$E/commit-attempt-1.raw.log" 2>&1; rc=$?
tail -25 "$E/commit-attempt-1.raw.log" >> "$LOG"; log "GIT_COMMIT rc=$rc"; [ $rc = 0 ] || finish 76
HEAD=$(git rev-parse HEAD); HTREE=$(git rev-parse 'HEAD^{tree}')
log "HEAD=$HEAD TREE=$HTREE author=$(git log -1 --format='%an <%ae> / %cn <%ce> / %cI') parent=$(git rev-parse HEAD^)"
[ "$(git rev-parse HEAD^)" = "$H" ] && [ -z "$(git status --porcelain --untracked-files=all)" ] || { log "LINEAGE_FAIL"; finish 76; }
[ "$(git diff --name-only "$H" HEAD | sort | tr '\n' ' ')" = "src/scout/reconciliation/coverage.ts src/scout/reconciliation/reconcile.ts src/scout/reconciliation/types.ts test/scout/reconciliation/reconcile.spec.ts " ] || { log "DELTA_FAIL"; finish 76; }
git log -1 --format=%B HEAD > "$E/committed-message.txt"
grep -iqE 'co-authored-by|generated' "$E/committed-message.txt" && { log "TRAILER_FAIL"; finish 76; }
# ---- 8 receipts
STAGE=receipts
git diff --binary "$H" HEAD > "$E/s9a-${H:0:12}-to-${HEAD:0:12}.patch"
git diff --name-status "$H" HEAD > "$E/MANIFEST-name-status-${H:0:12}-to-${HEAD:0:12}.txt"
{ echo "base_H=$H"; echo "head=$HEAD"; echo "tree=$HTREE"; for f in $FILES; do echo "blob $f $(git rev-parse HEAD:$f) sha256=$(sha "$f")"; done; echo "branch=$(git rev-parse --abbrev-ref HEAD)"; git log -1 --format='author=%an <%ae>%ncommitter=%cn <%ce>%ndate=%cI'; } > "$E/HEAD-${HEAD:0:12}.txt"
( cd "$E" && sha256sum * > SHA256SUMS ) 2>/dev/null
STAGE=done; log "DONE head=$HEAD tree=$HTREE"; finish 0
