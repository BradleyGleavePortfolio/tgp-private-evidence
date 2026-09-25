#!/usr/bin/env bash
# S9-A gate under the canonical slot — EXEC-1910A060 lane A-NEW-1 (1910a060/SCOPE.md "A-NEW-1", heavy sequence step 2).
# Derived from the historical, incomplete daceddc8/s9/gate/s9a-gate.sh (consumed at 18:27Z; its gate.log is preserved
# untouched and is NOT a successful proof). Same step list; fresh environment and namespace only:
#   - worktree /home/user/workspace/worktrees/1910a060-s9a (standalone clone), branch exec1910/s9a, base H=1c5fbb04
#   - evidence 1910a060/s9a/gate/** (this dir), never daceddc8/**
#   - canonical lock = current runtime lock, inode pinned from 1910a060/runtime/LOCK_ESTABLISHED.txt (never replaced)
#   - node_modules donor and prettier 3.9.9 prefix are relayed by the parent (RT-NEW-1 output), verified here, never installed here
#   - lefthook hooks installed into THIS clone's .git/hooks from the copied node_modules (genuine hooks; no bypass)
# Steps: relay+sentinel -> lock (flock -n fd9, in-process, held to exit) -> preconditions (HEAD==H, branch, exactly the 4
# untracked files at their frozen shas, no node_modules, schema pin) -> cp -a donor node_modules (pins) -> lefthook install
# (hook shas) -> verified prettier 3.9.9 prefix -> scoped prettier check/format on the 4 files -> scoped eslint -> tsc --noEmit
# (heap 4096) -> jest --ci affected suites (default config, no PG) -> stage exactly 4 paths -> one genuine hooked Bradley commit
# -> receipts -> release. No push, no npm install, no contract regen, no PG. Any failure stops and is preserved; no rerun.
# Usage (parent relay only): S9A_GATE_RELAY=1 S9A_DONOR=<abs path to node_modules> S9A_PRETTIER_PREFIX=<abs prefix dir> \
#        timeout -k 30 3600 bash /home/user/workspace/tgp-private-evidence/execution/1910a060/s9a/gate/s9a-gate-1910.sh
set -uo pipefail
E=/home/user/workspace/tgp-private-evidence/execution/1910a060/s9a/gate
FREEZE=/home/user/workspace/tgp-private-evidence/execution/1910a060/s9a/freeze
W=/home/user/workspace/worktrees/1910a060-s9a
LOCK=/home/user/workspace/execution/test-validation.lock
LOCK_RECORD=/home/user/workspace/tgp-private-evidence/execution/1910a060/runtime/LOCK_ESTABLISHED.txt
PREFIX_MANIFEST=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256
H=1c5fbb0441178e0cfe6e9f8d72e955c645c265e9
BRANCH=exec1910/s9a
LOG=$E/gate.log
FILES="src/scout/reconciliation/types.ts src/scout/reconciliation/coverage.ts src/scout/reconciliation/reconcile.ts test/scout/reconciliation/reconcile.spec.ts"
STAGED_EXPECT="src/scout/reconciliation/coverage.ts src/scout/reconciliation/reconcile.ts src/scout/reconciliation/types.ts test/scout/reconciliation/reconcile.spec.ts "
SUITES="test/scout/reconciliation/reconcile.spec.ts test/scout/lifecycle/arbiter.spec.ts test/scout/lifecycle/lifecycle.service.spec.ts test/invariants/locked_defaults.spec.ts test/contracts/importer-contract.spec.ts test/doctrine-cleanup.spec.ts test/ci/delivery-artifact.spec.ts test/deploy-readiness.spec.ts test/dependency-compatibility.spec.ts test/scout/g2-s8c-db-guard.spec.ts"
# Frozen source pins (S9_A_SOURCE_READY.md, verified by reviews A/B Phase 1 and by SOURCE_RECOVERED.md)
SHA_TYPES=eff1479cd2b735aacadc42ee3e2280dcfaf2e4fcc27a1fb90fd2c2bf2db1dbfa
SHA_COVERAGE=c6b224fa860261d6240c5bd62b07d419c6b9346c0b0de4eaac64dd9215926701
SHA_RECONCILE=83d7673b024513bbee938bf4a5467c4faa9306739f15ae53b69722936d7d9e1f
SHA_SPEC=99068057b0b99d95c9601c02130e4eca2b3b07acd0e0088fae146cb2f54edb74
# Environment pins for base H (schema at 1c5fbb04; generated client and hidden lock as recorded for that schema/lockfile
# in daceddc8/runtime and the 18:27Z gate.log; prettier 3.9.9 prefix manifest; lefthook 2.1.9 hook bodies).
SCHEMA_SHA=0eb41f9a88ef3b77266e908a5ea814206c188d1bdb031bd96d746491fee84015
PKG_LOCK_SHA=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55
NM_HIDDEN_LOCK=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44
CLIENT_INDEX_DTS=9042e713ba5678c99959a345b7b18a60dfc186b2c7d890b8d9c3ed5c8f4edcc6
CLIENT_SCHEMA=b84392033ab86776533007505c31f57930307a210844067a7407ed20d25abf3e
HOOK_PRECOMMIT=3b741de3dd006d6265c6ca6698b7b5ce8aa9a2a5ba2743a8615d85e72b4a140d
HOOK_COMMITMSG=71029ce88d76d5b885e12f978093ad3e046e93f5c5fc629b6fbba635d9f8a61b
ts(){ date -u +%FT%TZ; }
log(){ echo "$(ts) $*" | tee -a "$LOG"; }
sha(){ sha256sum "$1" | cut -c1-64; }
mkdir -p "$E"
# ---- 0 relay + one-shot sentinel (a refusal before ACQUIRED does not consume the grant)
[ "${S9A_GATE_RELAY:-}" = 1 ] || { echo "REFUSED: S9A_GATE_RELAY=1 (parent relay) not set" >&2; exit 78; }
[ -n "${S9A_DONOR:-}" ] && [ -d "$S9A_DONOR" ] || { echo "REFUSED: S9A_DONOR (node_modules donor dir) not set or absent" >&2; exit 78; }
[ -n "${S9A_PRETTIER_PREFIX:-}" ] && [ -d "$S9A_PRETTIER_PREFIX" ] || { echo "REFUSED: S9A_PRETTIER_PREFIX not set or absent" >&2; exit 78; }
DONOR=$S9A_DONOR; B=$S9A_PRETTIER_PREFIX
[ ! -e "$E/STARTED" ] || { echo "REFUSED: $E/STARTED exists; this gate is one-shot, do not loop" >&2; exit 76; }
# ---- lock: existing canonical file, recorded inode, nonblocking flock in this process
[ -e "$LOCK" ] || { log "REFUSED lock file absent"; exit 75; }
REC_INODE=$(sed -n 's/.*inode=\([0-9]*\).*/\1/p' "$LOCK_RECORD" | head -1)
CUR_INODE=$(stat -c %i "$LOCK")
[ -n "$REC_INODE" ] && [ "$CUR_INODE" = "$REC_INODE" ] || { log "REFUSED lock inode $CUR_INODE != recorded $REC_INODE"; exit 75; }
exec 9>>"$LOCK"; flock -n 9 || { log "REFUSED canonical lock busy (live holder); not waiting, not stealing"; exit 75; }
date -u +%FT%TZ > "$E/STARTED"
log "ACQUIRED pid=$$ fd9 inode=$CUR_INODE lslocks=$(lslocks 2>/dev/null | grep -c test-validation || true) donor=$DONOR prefix=$B"
STAGE=preflight
finish(){ unset npm_config_prefix; log "RELEASING stage=$STAGE rc=$1 (fd9 closes at exit; lock file preserved)"; printf 'RC=%s STAGE=%s END=%s\n' "$1" "$STAGE" "$(ts)" > "$E/TERMINAL"; exit "$1"; }
export NODE_OPTIONS=--max-old-space-size=4096 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false PRISMA_HIDE_UPDATE_MESSAGE=1
export GIT_AUTHOR_NAME="Bradley Gleave" GIT_AUTHOR_EMAIL=bradley@bradleytgpcoaching.com GIT_COMMITTER_NAME="Bradley Gleave" GIT_COMMITTER_EMAIL=bradley@bradleytgpcoaching.com
log "node=$(node --version) npm=$(npm --version)"
cd "$W" || finish 70
[ "$(git rev-parse HEAD)" = "$H" ] || { log "PRECONDITION_FAIL HEAD != $H"; finish 70; }
[ "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH" ] || { log "PRECONDITION_FAIL branch != $BRANCH"; finish 70; }
[ -z "$(git config --get core.hooksPath)" ] || { log "PRECONDITION_FAIL core.hooksPath set"; finish 70; }
[ "$(git status --porcelain --untracked-files=all | sed 's/^?? //' | sort | tr '\n' ' ')" = "$STAGED_EXPECT" ] \
  || { log "PRECONDITION_FAIL untracked set: $(git status --porcelain --untracked-files=all | tr '\n' ' ')"; finish 70; }
[ "$(sha src/scout/reconciliation/types.ts)" = "$SHA_TYPES" ] || { log "PRECONDITION_FAIL types.ts sha"; finish 70; }
[ "$(sha src/scout/reconciliation/coverage.ts)" = "$SHA_COVERAGE" ] || { log "PRECONDITION_FAIL coverage.ts sha"; finish 70; }
[ "$(sha src/scout/reconciliation/reconcile.ts)" = "$SHA_RECONCILE" ] || { log "PRECONDITION_FAIL reconcile.ts sha"; finish 70; }
[ "$(sha test/scout/reconciliation/reconcile.spec.ts)" = "$SHA_SPEC" ] || { log "PRECONDITION_FAIL spec sha"; finish 70; }
for f in $FILES; do cmp -s "$f" "$FREEZE/preformat-$(basename "$f")" || { log "PRECONDITION_FAIL $f != freeze copy"; finish 70; }; done
[ ! -e node_modules ] || { log "PRECONDITION_FAIL node_modules already present"; finish 70; }
[ "$(sha prisma/schema.prisma)" = "$SCHEMA_SHA" ] || { log "PRECONDITION_FAIL prisma/schema.prisma sha"; finish 70; }
[ "$(sha package-lock.json)" = "$PKG_LOCK_SHA" ] || { log "PRECONDITION_FAIL package-lock.json sha"; finish 70; }
[ "$(sha docs/decisions/2026-09-25-s9-reconciliation.md)" = cda68d826be08e5bf5cd1152ecbb092b10dfc373c7234bd73943815d0d07bab1 ] || { log "PRECONDITION_FAIL S9-0 doc sha"; finish 70; }
for hk in pre-commit commit-msg; do [ ! -e ".git/hooks/$hk" ] || { log "PRECONDITION_FAIL .git/hooks/$hk already present"; finish 70; }; done
pgrep -af "jest|tsc|prisma|postgres|prettier|lefthook|eslint" | grep -v "$$" | grep -v s9a-gate | tee -a "$LOG" | grep -q . && log "WARN other heavy processes present (recorded)"
# ---- 1 node_modules from the relayed donor (pinned to base H's schema + lockfile); donor is read-only here
STAGE=node_modules
DONOR_REPO=$(dirname "$DONOR")
log "DONOR_HEAD=$(git -C "$DONOR_REPO" rev-parse HEAD 2>/dev/null || echo n/a) DONOR_HIDDEN_LOCK=$(sha "$DONOR/.package-lock.json" 2>/dev/null || echo absent) DONOR_CLIENT_INDEX_DTS=$(sha "$DONOR/.prisma/client/index.d.ts" 2>/dev/null || echo absent) DONOR_CLIENT_SCHEMA=$(sha "$DONOR/.prisma/client/schema.prisma" 2>/dev/null || echo absent) DONOR_ENTRIES=$(ls "$DONOR" | wc -l)"
[ "$(sha "$DONOR/.package-lock.json")" = "$NM_HIDDEN_LOCK" ] || { log "PRECONDITION_FAIL donor hidden lock != $NM_HIDDEN_LOCK (donor must be npm ci of package-lock $PKG_LOCK_SHA)"; finish 71; }
GEN_NEEDED=0
if [ "$(sha "$DONOR/.prisma/client/index.d.ts" 2>/dev/null)" != "$CLIENT_INDEX_DTS" ] || [ "$(sha "$DONOR/.prisma/client/schema.prisma" 2>/dev/null)" != "$CLIENT_SCHEMA" ]; then
  GEN_NEEDED=1; log "DONOR_CLIENT_MISMATCH donor prisma client is not base-H's (e.g. S8-F schema donor); in-lane prisma generate from the committed schema $SCHEMA_SHA will follow the copy (RT-2 S7-L precedent), result must equal $CLIENT_INDEX_DTS / $CLIENT_SCHEMA"
fi
DSIG_BEFORE=$(find "$DONOR" -maxdepth 1 -printf '%p %T@\n' | sort | sha256sum | cut -c1-64)
t0=$(date +%s); cp -a "$DONOR" node_modules; rc=$?
log "CP_A rc=$rc secs=$(( $(date +%s)-t0 )) NM_ENTRIES=$(ls node_modules | wc -l) NM_HIDDEN_LOCK=$(sha node_modules/.package-lock.json 2>/dev/null || echo absent) NM_CLIENT_INDEX_DTS=$(sha node_modules/.prisma/client/index.d.ts 2>/dev/null || echo absent)"
[ $rc = 0 ] || finish 71
[ ! -L node_modules ] || { log "PRECONDITION_FAIL node_modules is a symlink"; finish 71; }
[ "$(sha node_modules/.package-lock.json)" = "$NM_HIDDEN_LOCK" ] || { log "PRECONDITION_FAIL copied hidden lock"; finish 71; }
[ "$(find "$DONOR" -maxdepth 1 -printf '%p %T@\n' | sort | sha256sum | cut -c1-64)" = "$DSIG_BEFORE" ] || log "WARN donor top-level signature changed during copy (recorded)"
if [ $GEN_NEEDED = 1 ]; then
  STAGE=prisma_generate
  timeout --foreground 600 npx --no-install prisma generate > "$E/prisma-generate.log" 2>&1; rc=$?; log "PRISMA_GENERATE_INLANE rc=$rc (writes only $W/node_modules/.prisma, never the donor)"; [ $rc = 0 ] || finish 71
  [ -z "$(git status --porcelain | grep -v '^??')" ] || { log "PRECONDITION_FAIL prisma generate touched a tracked file"; finish 71; }
fi
log "NM_CLIENT_INDEX_DTS=$(sha node_modules/.prisma/client/index.d.ts 2>/dev/null || echo absent) NM_CLIENT_SCHEMA=$(sha node_modules/.prisma/client/schema.prisma 2>/dev/null || echo absent)"
[ "$(sha node_modules/.prisma/client/index.d.ts)" = "$CLIENT_INDEX_DTS" ] && [ "$(sha node_modules/.prisma/client/schema.prisma)" = "$CLIENT_SCHEMA" ] || { log "PRECONDITION_FAIL in-lane prisma client != base-H pins; refusing (no repin)"; finish 71; }
[ ! -e node_modules/.bin/prettier ] || { log "PRECONDITION_FAIL prettier inside product tree"; finish 71; }
for b in tsc jest eslint lefthook; do [ -x node_modules/.bin/$b ] || { log "PRECONDITION_FAIL node_modules/.bin/$b missing"; finish 71; }; done
log "LEFTHOOK_VERSION=$(./node_modules/.bin/lefthook version 2>&1 | head -1)"
# ---- 2 genuine hooks into THIS clone (lefthook 2.1.9 from the copied node_modules; nothing shared)
STAGE=hooks
npx --no-install lefthook install > "$E/lefthook-install.log" 2>&1; rc=$?; log "LEFTHOOK_INSTALL rc=$rc"; [ $rc = 0 ] || finish 71
for hk in pre-commit commit-msg; do [ -x ".git/hooks/$hk" ] || { log "HOOK_FAIL .git/hooks/$hk missing or not executable"; finish 71; }; done
HP=$(sha .git/hooks/pre-commit); HC=$(sha .git/hooks/commit-msg)
log "HOOK_PRECOMMIT=$HP expect=$HOOK_PRECOMMIT HOOK_COMMITMSG=$HC expect=$HOOK_COMMITMSG"
[ "$HP" = "$HOOK_PRECOMMIT" ] && [ "$HC" = "$HOOK_COMMITMSG" ] || { log "HOOK_FAIL hook bodies differ from recorded lefthook 2.1.9 hooks; refusing (no repin here)"; finish 71; }
[ -z "$(git config --get core.hooksPath)" ] || { log "HOOK_FAIL core.hooksPath became set"; finish 71; }
# ---- 3 prettier prefix: reuse the relayed verified isolated copy (never re-copied, never installed here)
STAGE=prettier-prefix
( cd "$B" && sha256sum -c "$PREFIX_MANIFEST" ) > "$E/prettier-prefix-verify.log" 2>&1; rc=$?
log "PREFIX_VERIFY rc=$rc ok_lines=$(grep -c ': OK$' "$E/prettier-prefix-verify.log") manifest_lines=$(wc -l < "$PREFIX_MANIFEST") readlink=$(readlink "$B/bin/prettier")"
[ $rc = 0 ] && [ "$(readlink "$B/bin/prettier")" = "../lib/node_modules/prettier/bin/prettier.cjs" ] || finish 71
export npm_config_prefix="$B"
V=$(npx --no-install prettier --version 2>>"$LOG"); log "NPX_PRETTIER_VERSION=$V"; [ "$V" = 3.9.9 ] || finish 71
# ---- 4 scoped prettier on exactly the 4 files (layout only; reviews A/B verified token-stream identity)
STAGE=prettier
npx --no-install prettier --check $FILES > "$E/prettier-check-1.log" 2>&1; rc=$?; log "PRETTIER_CHECK_1 rc=$rc"
if [ $rc != 0 ]; then
  TOFIX=$(grep '^\[warn\] ' "$E/prettier-check-1.log" | sed 's/^\[warn\] //' | grep -v 'Code style issues' | grep -v 'Run Prettier' || true)
  log "PRETTIER_TOFIX=$(echo $TOFIX)"
  for f in $TOFIX; do case " $FILES " in *" $f "*) ;; *) log "PRETTIER_SCOPE_FAIL $f not in FILES"; finish 72;; esac; done
  npx --no-install prettier --write $TOFIX > "$E/prettier-write-1.log" 2>&1 || { log "PRETTIER_WRITE_FAIL"; finish 72; }
  npx --no-install prettier --check $FILES > "$E/prettier-check-2.log" 2>&1; rc=$?; log "PRETTIER_CHECK_2 rc=$rc"; [ $rc = 0 ] || finish 72
fi
for f in $FILES; do log "POSTFORMAT $f sha256=$(sha "$f") lines=$(wc -l < "$f")"; cp "$f" "$E/postformat-$(basename "$f")"; done
[ "$(git status --porcelain --untracked-files=all | sed 's/^?? //' | sort | tr '\n' ' ')" = "$STAGED_EXPECT" ] || { log "SCOPE_FAIL tracked file changed by formatting: $(git status --porcelain | tr '\n' ' ')"; finish 72; }
# ---- 5 scoped eslint
STAGE=eslint
npx --no-install eslint --no-warn-ignored --max-warnings 0 $FILES > "$E/eslint.raw.log" 2>&1; rc=$?; log "ESLINT rc=$rc"; [ $rc = 0 ] || { tail -40 "$E/eslint.raw.log" >> "$LOG"; finish 74; }
# ---- 6 tsc (whole repo; tsconfig has no include so test/ is type-checked)
STAGE=tsc
npx --no-install tsc --noEmit > "$E/tsc.raw.log" 2>&1; rc=$?; log "TSC rc=$rc lines=$(wc -l < "$E/tsc.raw.log")"; [ $rc = 0 ] || { tail -40 "$E/tsc.raw.log" >> "$LOG"; finish 73; }
# ---- 7 jest, affected suites (default config, no PG)
STAGE=jest
./node_modules/.bin/jest --ci $SUITES > "$E/jest.raw.log" 2>&1; rc=$?; log "JEST rc=$rc"
grep -E '^(Tests|Test Suites|Snapshots|Time):' "$E/jest.raw.log" | tee -a "$LOG"
[ $rc = 0 ] || { grep -E '✕|●' "$E/jest.raw.log" | head -40 >> "$LOG"; finish 73; }
# ---- 8 stage exactly the 4 paths + one genuine hooked commit (hooks run R75 staged, tsc, eslint, prettier --check, prod-readiness-quick, commit-msg)
STAGE=stage
git add -- $FILES
[ "$(git diff --cached --name-only | sort | tr '\n' ' ')" = "$STAGED_EXPECT" ] || { log "STAGED_SET_FAIL"; finish 70; }
TREE=$(git write-tree); log "STAGED_TREE=$TREE"
for f in $FILES; do log "STAGED_BLOB $f $(git rev-parse ":$f")"; done
STAGE=commit
git commit -F "$E/commit-message.txt" > "$E/commit-attempt-1.raw.log" 2>&1; rc=$?
tail -25 "$E/commit-attempt-1.raw.log" >> "$LOG"; log "GIT_COMMIT rc=$rc"; [ $rc = 0 ] || finish 76
HEAD=$(git rev-parse HEAD); HTREE=$(git rev-parse 'HEAD^{tree}')
log "HEAD=$HEAD TREE=$HTREE author=$(git log -1 --format='%an <%ae> / %cn <%ce> / %cI') parent=$(git rev-parse HEAD^)"
[ "$(git rev-parse HEAD^)" = "$H" ] && [ -z "$(git status --porcelain --untracked-files=all)" ] || { log "LINEAGE_FAIL"; finish 76; }
[ "$(git diff --name-only "$H" HEAD | sort | tr '\n' ' ')" = "$STAGED_EXPECT" ] || { log "DELTA_FAIL"; finish 76; }
[ "$(git log -1 --format='%an <%ae>|%cn <%ce>')" = "Bradley Gleave <bradley@bradleytgpcoaching.com>|Bradley Gleave <bradley@bradleytgpcoaching.com>" ] || { log "IDENTITY_FAIL"; finish 76; }
git log -1 --format=%B HEAD > "$E/committed-message.txt"
grep -iqE 'co-authored-by|generated' "$E/committed-message.txt" && { log "TRAILER_FAIL"; finish 76; }
# ---- 9 receipts
STAGE=receipts
git diff --binary "$H" HEAD > "$E/s9a-${H:0:12}-to-${HEAD:0:12}.patch"
git diff --name-status "$H" HEAD > "$E/MANIFEST-name-status-${H:0:12}-to-${HEAD:0:12}.txt"
{ echo "base_H=$H"; echo "head=$HEAD"; echo "tree=$HTREE"; for f in $FILES; do echo "blob $f $(git rev-parse HEAD:$f) sha256=$(sha "$f") preformat_sha256=$(sha "$FREEZE/preformat-$(basename "$f")")"; done; echo "branch=$(git rev-parse --abbrev-ref HEAD)"; git log -1 --format='author=%an <%ae>%ncommitter=%cn <%ce>%ndate=%cI'; echo "hooks pre-commit=$HP commit-msg=$HC"; echo "prettier=$V prefix=$B"; echo "donor=$DONOR hidden_lock=$NM_HIDDEN_LOCK client_index_dts=$CLIENT_INDEX_DTS"; echo "lock_inode=$CUR_INODE"; } > "$E/HEAD-${HEAD:0:12}.txt"
( cd "$E" && sha256sum * > SHA256SUMS ) 2>/dev/null
STAGE=done; log "DONE head=$HEAD tree=$HTREE (not pushed; parent owns landing)"; finish 0
