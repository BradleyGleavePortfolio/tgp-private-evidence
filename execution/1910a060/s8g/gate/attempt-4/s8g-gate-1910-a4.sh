#!/usr/bin/env bash
# S8-G gate ATTEMPT 4 under the canonical slot (attempt 3 deliberately aborted by the builder before commit to fold in dev-loop iteration 2, the 55643-refusal test-util change). Attempt-3 header:
# S8-G gate ATTEMPT 3 under the canonical slot (attempt 2 stopped at jest-targeted rc=73: reconstruct-run.spec fixture spec lacked the required clientSourceId rules; FIX-2). Attempt-2 header:
# S8-G gate ATTEMPT 2 under the canonical slot — EXEC-1910A060 lane G-NEW-1. Attempt 1 (../gate.log) stopped at tsc rc=73 on one
# TS2352 in reconstruct-run.spec.ts L77 (fixed outside the run: `s[k as keyof Staged]`); the lock was released, state preserved
# (../POSTFAIL-tree.txt). This attempt REUSES the node_modules copy and the lefthook hooks attempt 1 installed in the clone,
# verifying them against the same pins instead of re-copying/re-installing; every other stage is identical. Runs only on
# explicit parent disposition (S8G_GATE_RELAY=2).
# Original header:
# Modeled on 1910a060/s9a/gate/s9a-gate-1910.sh (rc 0 at 21:35Z). Differences: 14 candidate paths (2 modified + 12 new),
# lock is POLLED (nonblocking flock every 5 s, logged each minute, bounded) because the S8-F composition may still hold it
# at launch — never stolen; prettier scope excludes the .sh (no parser) and includes the .cjs; targeted jest THEN the full
# default suite once; post-commit derivation of the nine PG-binding pins into a receipt (no runner edit, no PG proof).
# Steps: relay+sentinel -> lock -> preconditions (HEAD==H, branch, exactly the 14 paths at their frozen shas, no
# node_modules, schema/lock pins) -> cp -a donor node_modules (pins; no prisma generate expected) -> lefthook install (path-
# normalized hook check vs the S8-F clone) -> verified prettier 3.9.9 prefix -> scoped prettier check/format/check ->
# scoped eslint --max-warnings 0 -> whole-repo tsc --noEmit -> jest targeted -> jest full default -> stage exactly 14 paths
# -> one genuine hooked Bradley commit -> post checks -> receipts -> release. No push, no npm install, no PG. Any failure
# stops with state preserved (no fix-and-retry inside the run).
# Usage (parent relay only): S8G_GATE_RELAY=1 S8G_DONOR=<abs node_modules> S8G_PRETTIER_PREFIX=<abs prefix dir> \
#        timeout -k 30 7200 bash /home/user/workspace/tgp-private-evidence/execution/1910a060/s8g/gate/s8g-gate-1910.sh
set -uo pipefail
E=/home/user/workspace/tgp-private-evidence/execution/1910a060/s8g/gate/attempt-4
FREEZE=$E/freeze
W=/home/user/workspace/worktrees/1910a060-s8g
LOCK=/home/user/workspace/execution/test-validation.lock
LOCK_RECORD=/home/user/workspace/tgp-private-evidence/execution/1910a060/runtime/LOCK_ESTABLISHED.txt
PREFIX_MANIFEST=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256
H=62471b116267fdec6746073c4b4c80a154d09834
BRANCH=exec1910/s8g
LOG=$E/gate.log
LOCK_WAIT_MAX=${S8G_LOCK_WAIT_MAX:-5400}   # seconds to poll for the slot before refusing (grant not consumed by a refusal)
FILES="src/scout/reconstruct/orchestration/run-context.ts src/scout/reconstruct/orchestration/family-plan.ts src/scout/scout-reconstruct.service.ts src/scout/lifecycle/lifecycle.service.ts test/scout/orchestration/family-plan.spec.ts test/scout/orchestration/reconstruct-run.spec.ts test/scout/orchestration/settle-hook.spec.ts test/scout/g2-s8g-db-guard.spec.ts test/rls-g2-s8g.spec.ts test/utils/g2-s8g-db.ts test/utils/g2-s8g-pg-harness.ts test/utils/g2-s8g-harness.ts test/utils/g2-s8g-worker.cjs test/utils/g2-s8g-bootstrap.sh"
# prettier: everything but the shell script (prettier has no parser for .sh; the .cjs infers babel)
PRETTIER_FILES=$(for f in $FILES; do case "$f" in *.sh) ;; *) printf '%s ' "$f";; esac; done)
# eslint: the TS files and the .cjs (CI's `eslint .` lints both; *.js is globally ignored, *.cjs is not)
ESLINT_FILES=$(for f in $FILES; do case "$f" in *.sh) ;; *) printf '%s ' "$f";; esac; done)
STAGED_EXPECT=$(printf '%s\n' $FILES | sort | tr '\n' ' ')
TARGETED="test/scout/orchestration test/scout/g2-s8g-db-guard.spec.ts"
# Environment pins for base H=62471b11 (S8-F merge; schema blob 2e328bbc identical to 1c5fbb04; donor generated from that schema; lockfile; prettier 3.9.9)
SCHEMA_SHA=0eb41f9a88ef3b77266e908a5ea814206c188d1bdb031bd96d746491fee84015
PKG_LOCK_SHA=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55
NM_HIDDEN_LOCK=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44
CLIENT_INDEX_DTS=9042e713ba5678c99959a345b7b18a60dfc186b2c7d890b8d9c3ed5c8f4edcc6
CLIENT_SCHEMA=b84392033ab86776533007505c31f57930307a210844067a7407ed20d25abf3e
HOOK_REF_ROOT=/home/user/workspace/worktrees/1910a060-s8f
LEFTHOOK_EXPECT=2.1.9
ts(){ date -u +%FT%TZ; }
log(){ echo "$(ts) $*" | tee -a "$LOG"; }
sha(){ sha256sum "$1" | cut -c1-64; }
fz(){ echo "$FREEZE/$(echo "$1" | tr '/' '_')"; }
mkdir -p "$E"
# ---- 0 relay + one-shot sentinel (a refusal before ACQUIRED does not consume the grant)
[ "${S8G_GATE_RELAY:-}" = 4 ] || { echo "REFUSED: S8G_GATE_RELAY=4 (parent disposition: dev loop → one gate) not set" >&2; exit 78; }
[ -n "${S8G_DONOR:-}" ] && [ -d "$S8G_DONOR" ] || { echo "REFUSED: S8G_DONOR (node_modules donor dir) not set or absent" >&2; exit 78; }
[ -n "${S8G_PRETTIER_PREFIX:-}" ] && [ -d "$S8G_PRETTIER_PREFIX" ] || { echo "REFUSED: S8G_PRETTIER_PREFIX not set or absent" >&2; exit 78; }
DONOR=$S8G_DONOR; B=$S8G_PRETTIER_PREFIX
[ ! -e "$E/STARTED" ] || { echo "REFUSED: $E/STARTED exists; this gate is one-shot, do not loop" >&2; exit 76; }
[ -f "$E/PREFORMAT.sha256" ] && [ -f "$E/commit-message.txt" ] || { echo "REFUSED: PREFORMAT.sha256 / commit-message.txt missing" >&2; exit 78; }
# ---- lock: existing canonical file, recorded inode, nonblocking flock polled in this process (never blocking, never stealing)
[ -e "$LOCK" ] || { log "REFUSED lock file absent"; exit 75; }
REC_INODE=$(sed -n 's/.*inode=\([0-9]*\).*/\1/p' "$LOCK_RECORD" | head -1)
CUR_INODE=$(stat -c %i "$LOCK")
[ -n "$REC_INODE" ] && [ "$CUR_INODE" = "$REC_INODE" ] || { log "REFUSED lock inode $CUR_INODE != recorded $REC_INODE"; exit 75; }
exec 9>>"$LOCK"
waited=0
until flock -n 9; do
  [ $waited -lt "$LOCK_WAIT_MAX" ] || { log "REFUSED canonical lock still busy after ${waited}s (holder: $(lslocks 2>/dev/null | grep test-validation | awk '{print $2}' | tr '\n' ' ')); not stealing"; exit 75; }
  [ $((waited % 60)) -ne 0 ] || log "WAITING lock busy ${waited}s holder_pid=$(lslocks 2>/dev/null | grep test-validation | awk '{print $2}' | tr '\n' ' ') inode=$(stat -c %i "$LOCK")"
  sleep 5; waited=$((waited+5))
  [ "$(stat -c %i "$LOCK")" = "$REC_INODE" ] || { log "REFUSED lock inode changed while waiting"; exit 75; }
done
date -u +%FT%TZ > "$E/STARTED"
log "ACQUIRED pid=$$ fd9 inode=$CUR_INODE waited=${waited}s lslocks=$(lslocks 2>/dev/null | grep -c test-validation || true) donor=$DONOR prefix=$B"
STAGE=preflight
finish(){ unset npm_config_prefix; log "RELEASING stage=$STAGE rc=$1 (fd9 closes at exit; lock file preserved)"; printf 'RC=%s STAGE=%s END=%s\n' "$1" "$STAGE" "$(ts)" > "$E/TERMINAL"; ( cd "$E" && sha256sum $(ls -p | grep -v /) > SHA256SUMS ) 2>/dev/null; exit "$1"; }
export NODE_OPTIONS=--max-old-space-size=4096 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false PRISMA_HIDE_UPDATE_MESSAGE=1
export GIT_AUTHOR_NAME="Bradley Gleave" GIT_AUTHOR_EMAIL=bradley@bradleytgpcoaching.com GIT_COMMITTER_NAME="Bradley Gleave" GIT_COMMITTER_EMAIL=bradley@bradleytgpcoaching.com
log "node=$(node --version) npm=$(npm --version)"
cd "$W" || finish 70
[ "$(git rev-parse HEAD)" = "$H" ] || { log "PRECONDITION_FAIL HEAD != $H"; finish 70; }
[ "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH" ] || { log "PRECONDITION_FAIL branch != $BRANCH"; finish 70; }
[ -z "$(git config --get core.hooksPath)" ] || { log "PRECONDITION_FAIL core.hooksPath set"; finish 70; }
[ "$(git status --porcelain --untracked-files=all | awk '{print $2}' | sort | tr '\n' ' ')" = "$STAGED_EXPECT" ] \
  || { log "PRECONDITION_FAIL working set: $(git status --porcelain --untracked-files=all | tr '\n' ' ')"; finish 70; }
[ -z "$(git diff --cached --name-only)" ] || { log "PRECONDITION_FAIL index not empty"; finish 70; }
[ "$(git status --porcelain -- src/scout/scout-reconstruct.service.ts src/scout/lifecycle/lifecycle.service.ts | grep -c '^ M ')" = 2 ] || { log "PRECONDITION_FAIL the two product files are not plain modifications"; finish 70; }
while read -r want f; do
  [ "$(sha "$f")" = "$want" ] || { log "PRECONDITION_FAIL $f sha != frozen $want"; finish 70; }
  cmp -s "$f" "$(fz "$f")" || { log "PRECONDITION_FAIL $f != freeze copy"; finish 70; }
done < "$E/PREFORMAT.sha256"
[ "$(wc -l < "$E/PREFORMAT.sha256")" = 14 ] || { log "PRECONDITION_FAIL PREFORMAT.sha256 line count"; finish 70; }
[ -x test/utils/g2-s8g-bootstrap.sh ] || { log "PRECONDITION_FAIL bootstrap not executable"; finish 70; }
NM_REUSE=0; if [ -e node_modules ]; then [ ! -L node_modules ] && [ "$(sha node_modules/.package-lock.json)" = "$NM_HIDDEN_LOCK" ] && [ "$(sha node_modules/.prisma/client/index.d.ts)" = "$CLIENT_INDEX_DTS" ] || { log "PRECONDITION_FAIL existing node_modules is not the pinned attempt-1 copy"; finish 70; }; NM_REUSE=1; log "NM_REUSE attempt-1 copy pinned (hidden lock + client)"; fi
[ "$(sha prisma/schema.prisma)" = "$SCHEMA_SHA" ] || { log "PRECONDITION_FAIL prisma/schema.prisma sha"; finish 70; }
[ "$(sha package-lock.json)" = "$PKG_LOCK_SHA" ] || { log "PRECONDITION_FAIL package-lock.json sha"; finish 70; }
[ -z "$(git diff --name-only "$H" -- prisma)" ] && [ -z "$(git status --porcelain -- prisma)" ] || { log "PRECONDITION_FAIL prisma tree touched"; finish 70; }
HOOK_REUSE=0; for hk in pre-commit commit-msg; do [ -e ".git/hooks/$hk" ] && HOOK_REUSE=1; done; [ $HOOK_REUSE = 0 ] || log "HOOK_REUSE attempt-1 hooks present; verified below instead of reinstalled"
bash -n test/utils/g2-s8g-bootstrap.sh && node --check test/utils/g2-s8g-worker.cjs || { log "PRECONDITION_FAIL syntax"; finish 70; }
pgrep -af "jest|tsc|prisma|postgres|prettier|lefthook|eslint" | grep -v "$$" | grep -v s8g-gate | tee -a "$LOG" | grep -q . && log "WARN other heavy processes present (recorded)"
# ---- 1 node_modules from the relayed donor (pinned to base H's schema + lockfile); donor is read-only here
STAGE=node_modules
DONOR_REPO=$(dirname "$DONOR")
log "DONOR_HEAD=$(git -C "$DONOR_REPO" rev-parse HEAD 2>/dev/null || echo n/a) DONOR_HIDDEN_LOCK=$(sha "$DONOR/.package-lock.json" 2>/dev/null || echo absent) DONOR_CLIENT_INDEX_DTS=$(sha "$DONOR/.prisma/client/index.d.ts" 2>/dev/null || echo absent) DONOR_CLIENT_SCHEMA=$(sha "$DONOR/.prisma/client/schema.prisma" 2>/dev/null || echo absent) DONOR_ENTRIES=$(ls "$DONOR" | wc -l)"
[ "$(sha "$DONOR/.package-lock.json")" = "$NM_HIDDEN_LOCK" ] || { log "PRECONDITION_FAIL donor hidden lock != $NM_HIDDEN_LOCK"; finish 71; }
GEN_NEEDED=0
if [ "$(sha "$DONOR/.prisma/client/index.d.ts" 2>/dev/null)" != "$CLIENT_INDEX_DTS" ] || [ "$(sha "$DONOR/.prisma/client/schema.prisma" 2>/dev/null)" != "$CLIENT_SCHEMA" ]; then
  GEN_NEEDED=1; log "DONOR_CLIENT_MISMATCH donor prisma client is not base-H's; in-lane prisma generate from the committed schema $SCHEMA_SHA will follow the copy, result must equal $CLIENT_INDEX_DTS / $CLIENT_SCHEMA"
fi
DSIG_BEFORE=$(find "$DONOR" -maxdepth 1 -printf '%p %T@\n' | sort | sha256sum | cut -c1-64)
t0=$(date +%s); if [ $NM_REUSE = 1 ]; then rc=0; else cp -a "$DONOR" node_modules; rc=$?; fi
log "CP_A rc=$rc secs=$(( $(date +%s)-t0 )) NM_ENTRIES=$(ls node_modules | wc -l) NM_HIDDEN_LOCK=$(sha node_modules/.package-lock.json 2>/dev/null || echo absent) NM_CLIENT_INDEX_DTS=$(sha node_modules/.prisma/client/index.d.ts 2>/dev/null || echo absent)"
[ $rc = 0 ] || finish 71
[ ! -L node_modules ] || { log "PRECONDITION_FAIL node_modules is a symlink"; finish 71; }
[ "$(sha node_modules/.package-lock.json)" = "$NM_HIDDEN_LOCK" ] || { log "PRECONDITION_FAIL copied hidden lock"; finish 71; }
[ "$(find "$DONOR" -maxdepth 1 -printf '%p %T@\n' | sort | sha256sum | cut -c1-64)" = "$DSIG_BEFORE" ] || log "WARN donor top-level signature changed during copy (recorded)"
if [ $GEN_NEEDED = 1 ]; then
  STAGE=prisma_generate
  timeout --foreground 600 npx --no-install prisma generate > "$E/prisma-generate.log" 2>&1; rc=$?; log "PRISMA_GENERATE_INLANE rc=$rc"; [ $rc = 0 ] || finish 71
  [ "$(git status --porcelain --untracked-files=all | awk '{print $2}' | sort | tr '\n' ' ')" = "$STAGED_EXPECT" ] || { log "PRECONDITION_FAIL prisma generate touched a tracked file"; finish 71; }
fi
log "NM_CLIENT_INDEX_DTS=$(sha node_modules/.prisma/client/index.d.ts 2>/dev/null || echo absent) NM_CLIENT_SCHEMA=$(sha node_modules/.prisma/client/schema.prisma 2>/dev/null || echo absent)"
[ "$(sha node_modules/.prisma/client/index.d.ts)" = "$CLIENT_INDEX_DTS" ] && [ "$(sha node_modules/.prisma/client/schema.prisma)" = "$CLIENT_SCHEMA" ] || { log "PRECONDITION_FAIL in-lane prisma client != base-H pins; refusing (no repin)"; finish 71; }
[ ! -e node_modules/.bin/prettier ] || { log "PRECONDITION_FAIL prettier inside product tree"; finish 71; }
for b in tsc jest eslint lefthook ts-node; do [ -x node_modules/.bin/$b ] || { log "PRECONDITION_FAIL node_modules/.bin/$b missing"; finish 71; }; done
log "LEFTHOOK_VERSION=$(./node_modules/.bin/lefthook version 2>&1 | head -1)"
# ---- 2 genuine hooks into THIS clone (lefthook 2.1.9 from the copied node_modules; nothing shared)
STAGE=hooks
if [ $HOOK_REUSE = 1 ]; then rc=0; echo reused > "$E/lefthook-install.log"; else npx --no-install lefthook install > "$E/lefthook-install.log" 2>&1; rc=$?; fi; log "LEFTHOOK_INSTALL rc=$rc reuse=$HOOK_REUSE"; [ $rc = 0 ] || finish 71
for hk in pre-commit commit-msg; do [ -x ".git/hooks/$hk" ] || { log "HOOK_FAIL .git/hooks/$hk missing or not executable"; finish 71; }; done
LHV=$(./node_modules/.bin/lefthook version 2>&1 | head -1 | tr -d '[:space:]'); log "LEFTHOOK_VERSION_CHECK=$LHV expect=$LEFTHOOK_EXPECT"
[ "$LHV" = "$LEFTHOOK_EXPECT" ] || { log "HOOK_FAIL lefthook version != $LEFTHOOK_EXPECT"; finish 71; }
HP=$(sha .git/hooks/pre-commit); HC=$(sha .git/hooks/commit-msg)
normhook(){ sed "s|$2|@CLONE_ROOT@|g" "$1" | sha256sum | cut -c1-64; }
for hk in pre-commit commit-msg; do [ -f "$HOOK_REF_ROOT/.git/hooks/$hk" ] || { log "HOOK_FAIL reference hook $HOOK_REF_ROOT/.git/hooks/$hk absent"; finish 71; }; done
RP=$(sha "$HOOK_REF_ROOT/.git/hooks/pre-commit"); RC_=$(sha "$HOOK_REF_ROOT/.git/hooks/commit-msg")
NP=$(normhook .git/hooks/pre-commit "$W"); NC=$(normhook .git/hooks/commit-msg "$W")
NRP=$(normhook "$HOOK_REF_ROOT/.git/hooks/pre-commit" "$HOOK_REF_ROOT"); NRC=$(normhook "$HOOK_REF_ROOT/.git/hooks/commit-msg" "$HOOK_REF_ROOT")
log "HOOK_RAW own pre-commit=$HP commit-msg=$HC | ref($HOOK_REF_ROOT) pre-commit=$RP commit-msg=$RC_"
log "HOOK_NORMALIZED own pre-commit=$NP commit-msg=$NC | ref pre-commit=$NRP commit-msg=$NRC"
[ "$NP" = "$NRP" ] && [ "$NC" = "$NRC" ] || { log "HOOK_FAIL path-normalized hook bodies differ from the reference lefthook $LEFTHOOK_EXPECT hooks; refusing"; finish 71; }
for hk in pre-commit commit-msg; do
  grep -qF "$W/node_modules/lefthook-linux-x64/bin/lefthook" ".git/hooks/$hk" || { log "HOOK_FAIL .git/hooks/$hk does not reference $W/node_modules/lefthook-linux-x64/bin/lefthook"; finish 71; }
  ! grep -qF "$HOOK_REF_ROOT" ".git/hooks/$hk" || { log "HOOK_FAIL .git/hooks/$hk references the reference clone root"; finish 71; }
done
log "HOOK_OK own hooks reference $W/node_modules/lefthook-linux-x64/bin/lefthook"
[ -z "$(git config --get core.hooksPath)" ] || { log "HOOK_FAIL core.hooksPath became set"; finish 71; }
# ---- 3 prettier prefix: reuse the relayed verified isolated copy (never re-copied, never installed here)
STAGE=prettier-prefix
( cd "$B" && sha256sum -c "$PREFIX_MANIFEST" ) > "$E/prettier-prefix-verify.log" 2>&1; rc=$?
log "PREFIX_VERIFY rc=$rc ok_lines=$(grep -c ': OK$' "$E/prettier-prefix-verify.log") manifest_lines=$(wc -l < "$PREFIX_MANIFEST") readlink=$(readlink "$B/bin/prettier")"
[ $rc = 0 ] && [ "$(readlink "$B/bin/prettier")" = "../lib/node_modules/prettier/bin/prettier.cjs" ] || finish 71
export npm_config_prefix="$B"
V=$(npx --no-install prettier --version 2>>"$LOG"); log "NPX_PRETTIER_VERSION=$V"; [ "$V" = 3.9.9 ] || finish 71
# ---- 4 scoped prettier on the 13 prettier-parsable candidate files (layout only)
STAGE=prettier
npx --no-install prettier --check $PRETTIER_FILES > "$E/prettier-check-1.log" 2>&1; rc=$?; log "PRETTIER_CHECK_1 rc=$rc"
if [ $rc != 0 ]; then
  grep -q '^\[error\]' "$E/prettier-check-1.log" && { log "PRETTIER_ERROR (parser/config), not a style diff"; tail -20 "$E/prettier-check-1.log" >> "$LOG"; finish 72; }
  TOFIX=$(grep '^\[warn\] ' "$E/prettier-check-1.log" | sed 's/^\[warn\] //' | grep -v 'Code style issues' | grep -v 'Run Prettier' || true)
  log "PRETTIER_TOFIX=$(echo $TOFIX)"
  for f in $TOFIX; do case " $PRETTIER_FILES " in *" $f "*) ;; *) log "PRETTIER_SCOPE_FAIL $f not in scope"; finish 72;; esac; done
  npx --no-install prettier --write $TOFIX > "$E/prettier-write-1.log" 2>&1 || { log "PRETTIER_WRITE_FAIL"; finish 72; }
  npx --no-install prettier --check $PRETTIER_FILES > "$E/prettier-check-2.log" 2>&1; rc=$?; log "PRETTIER_CHECK_2 rc=$rc"; [ $rc = 0 ] || finish 72
fi
mkdir -p "$E/postformat"
for f in $FILES; do log "POSTFORMAT $f sha256=$(sha "$f") lines=$(wc -l < "$f")"; cp "$f" "$E/postformat/$(echo "$f" | tr '/' '_')"; done
[ "$(git status --porcelain --untracked-files=all | awk '{print $2}' | sort | tr '\n' ' ')" = "$STAGED_EXPECT" ] || { log "SCOPE_FAIL formatting changed the working set: $(git status --porcelain | tr '\n' ' ')"; finish 72; }
# ---- 5 scoped eslint (13 files: TS + .cjs)
STAGE=eslint
npx --no-install eslint --no-warn-ignored --max-warnings 0 $ESLINT_FILES > "$E/eslint.raw.log" 2>&1; rc=$?; log "ESLINT rc=$rc"; [ $rc = 0 ] || { tail -60 "$E/eslint.raw.log" >> "$LOG"; finish 74; }
# ---- 6 tsc (whole repo; tsconfig has no include so test/ is type-checked)
STAGE=tsc
npx --no-install tsc --noEmit > "$E/tsc.raw.log" 2>&1; rc=$?; log "TSC rc=$rc lines=$(wc -l < "$E/tsc.raw.log")"; [ $rc = 0 ] || { tail -60 "$E/tsc.raw.log" >> "$LOG"; finish 73; }
# ---- 7a jest targeted (default config, no PG): the three orchestration specs + the s8g db guard
STAGE=jest-targeted
timeout --foreground 1200 ./node_modules/.bin/jest --ci $TARGETED > "$E/jest-targeted.raw.log" 2>&1; rc=$?; log "JEST_TARGETED rc=$rc"
grep -E '^(Tests|Test Suites|Snapshots|Time):' "$E/jest-targeted.raw.log" | tee -a "$LOG"
[ $rc = 0 ] || { grep -E '✕|●' "$E/jest-targeted.raw.log" | head -60 >> "$LOG"; finish 73; }
# ---- 7b jest full default suite once (jest.config.js excludes test/rls-*.spec.ts and test/rls/**; no PG)
STAGE=jest-full
timeout --foreground 3000 ./node_modules/.bin/jest --ci > "$E/jest-full.raw.log" 2>&1; rc=$?; log "JEST_FULL rc=$rc"
grep -E '^(Tests|Test Suites|Snapshots|Time):' "$E/jest-full.raw.log" | tee -a "$LOG"
[ $rc = 0 ] || { grep -E '✕|●' "$E/jest-full.raw.log" | head -60 >> "$LOG"; finish 73; }
grep -q 'rls-g2-s8g' "$E/jest-full.raw.log" && { log "SCOPE_FAIL guarded live spec ran in the default suite"; finish 73; }
[ "$(git status --porcelain --untracked-files=all | awk '{print $2}' | sort | tr '\n' ' ')" = "$STAGED_EXPECT" ] || { log "SCOPE_FAIL tests changed the working set"; finish 73; }
# ---- 8 stage exactly the 14 paths + one genuine hooked commit (hooks: R75 staged, tsc, eslint, prettier --check, prod-readiness-quick; commit-msg R3)
STAGE=stage
git add -- $FILES
[ "$(git diff --cached --name-only | sort | tr '\n' ' ')" = "$STAGED_EXPECT" ] || { log "STAGED_SET_FAIL $(git diff --cached --name-only | tr '\n' ' ')"; finish 70; }
[ -z "$(git status --porcelain --untracked-files=all | grep -v '^[AM]  ')" ] || { log "STAGED_SET_FAIL unstaged residue"; finish 70; }
TREE=$(git write-tree); log "STAGED_TREE=$TREE"
for f in $FILES; do log "STAGED_BLOB $f $(git rev-parse ":$f") mode=$(git ls-files -s -- "$f" | cut -c1-6)"; done
STAGE=commit
git commit -F "$E/commit-message.txt" > "$E/commit-attempt-1.raw.log" 2>&1; rc=$?
tail -30 "$E/commit-attempt-1.raw.log" >> "$LOG"; log "GIT_COMMIT rc=$rc"; [ $rc = 0 ] || finish 76
HEAD=$(git rev-parse HEAD); HTREE=$(git rev-parse 'HEAD^{tree}')
log "HEAD=$HEAD TREE=$HTREE author=$(git log -1 --format='%an <%ae> / %cn <%ce> / %cI') parent=$(git rev-parse HEAD^)"
[ "$(git rev-parse HEAD^)" = "$H" ] && [ -z "$(git status --porcelain --untracked-files=all)" ] || { log "LINEAGE_FAIL"; finish 76; }
[ "$(git diff --name-only "$H" HEAD | sort | tr '\n' ' ')" = "$STAGED_EXPECT" ] || { log "DELTA_FAIL"; finish 76; }
[ -z "$(git diff --name-only "$H" HEAD -- prisma)" ] || { log "DELTA_FAIL prisma"; finish 76; }
[ "$(git log -1 --format='%an <%ae>|%cn <%ce>')" = "Bradley Gleave <bradley@bradleytgpcoaching.com>|Bradley Gleave <bradley@bradleytgpcoaching.com>" ] || { log "IDENTITY_FAIL"; finish 76; }
[ "$(git rev-list --count "$H"..HEAD)" = 1 ] || { log "LINEAGE_FAIL more than one commit"; finish 76; }
git log -1 --format=%B HEAD > "$E/committed-message.txt"
grep -iqE 'co-authored-by|generated' "$E/committed-message.txt" && { log "TRAILER_FAIL"; finish 76; }
# ---- 9 receipts (+ the nine PG-binding pins derivable from the committed head; the runner itself is NOT filled here)
STAGE=receipts
git diff --binary "$H" HEAD > "$E/s8g-a4-${H:0:12}-to-${HEAD:0:12}.patch"
git diff --name-status "$H" HEAD > "$E/MANIFEST-name-status-${H:0:12}-to-${HEAD:0:12}.txt"
{ echo "base_H=$H"; echo "head=$HEAD"; echo "tree=$HTREE"; for f in $FILES; do echo "blob $f $(git rev-parse HEAD:$f) sha256=$(sha "$f") preformat_sha256=$(sha "$(fz "$f")")"; done; echo "branch=$(git rev-parse --abbrev-ref HEAD)"; git log -1 --format='author=%an <%ae>%ncommitter=%cn <%ce>%ndate=%cI'; echo "hooks raw pre-commit=$HP commit-msg=$HC normalized pre-commit=$NP commit-msg=$NC ref_root=$HOOK_REF_ROOT lefthook=$LHV"; echo "prettier=$V prefix=$B"; echo "donor=$DONOR hidden_lock=$NM_HIDDEN_LOCK client_index_dts=$CLIENT_INDEX_DTS"; echo "lock_inode=$CUR_INODE lock_waited_s=$waited"; } > "$E/HEAD-${HEAD:0:12}.txt"
{ echo "# nine PG-binding pins derived read-only from committed head $HEAD (binding/v1/s8g-pg-proof.sh.unfilled NOT edited here)"
  echo "EXPECT_HEAD=$HEAD"; echo "EXPECT_TREE=$HTREE"
  echo "EXPECT_SPEC_BLOB=$(git rev-parse HEAD:test/rls-g2-s8g.spec.ts)"; echo "EXPECT_BOOTSTRAP_BLOB=$(git rev-parse HEAD:test/utils/g2-s8g-bootstrap.sh)"
  echo "EXPECT_DB_BLOB=$(git rev-parse HEAD:test/utils/g2-s8g-db.ts)"; echo "EXPECT_PGH_BLOB=$(git rev-parse HEAD:test/utils/g2-s8g-pg-harness.ts)"
  echo "EXPECT_HARNESS_BLOB=$(git rev-parse HEAD:test/utils/g2-s8g-harness.ts)"; echo "EXPECT_WORKER_BLOB=$(git rev-parse HEAD:test/utils/g2-s8g-worker.cjs)"
  echo "EXPECT_FIXTURE_SHA=$(sha /home/user/workspace/tgp-private-evidence/execution/1910a060/s8g/binding/v1/s8g-fixture.sh)"; } > "$E/BINDING-PINS-${HEAD:0:12}.txt"
STAGE=done; log "DONE head=$HEAD tree=$HTREE (not pushed; parent owns landing)"; finish 0
