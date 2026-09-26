#!/usr/bin/env bash
# S9-B gate under the canonical slot — EXEC-1910A060 lane B-NEW-1 (1910a060/SCOPE.md "S9B-BUILD"; runs after S9-A M2).
# Modeled step-for-step on the accepted 1910a060/s9a/gate/s9a-gate-1910.sh (be88909f). Differences are scope only:
#   - worktree /home/user/workspace/worktrees/1910a060-s9b (standalone clone), branch exec1910/s9b, base = M2 (S9-A
#     be88909f composed onto integration/importer 62471b11), pinned as BASE in PINS.env and filled by the parent at relay
#   - the four S9-A files are TRACKED at M2 (post-format bytes) and must be clean; the pre-format read-only copies this
#     lane used for imports must be gone (the parent replaces them when re-basing the clone; this driver never edits them)
#   - owned paths: 10 new files (+ the S9-0 doc with Addendum A when S9B_INCLUDE_ADDENDUM=1; reviewer disposition pending)
#   - evidence 1910a060/s9b/gate/** (this dir); PINS.env beside this script carries every hash
#   - canonical lock = current runtime lock, inode pinned (PINS.env LOCK_INODE) AND cross-checked against LOCK_ESTABLISHED.txt
#   - node_modules donor (worktrees/1910a060-s8f/node_modules) and the verified prettier 3.9.9 prefix are relayed by the
#     parent, verified here, never installed here; lefthook hooks are installed into THIS clone's .git/hooks (path-normalized
#     comparison against the S8-F reference clone's hooks; genuine hooks, no bypass)
# Steps: relay+sentinel -> lock (flock -n fd9, in-process, held to exit) -> preconditions (HEAD==BASE, branch, exact status
# set, owned shas, S9-A tracked+clean at accepted shas, no node_modules, schema/lockfile pins, migration set, doc sha per
# addendum mode, hooks absent) -> cp -a donor node_modules (pins; in-lane prisma generate only on client mismatch) ->
# lefthook install (normalized hook shas) -> verified prettier prefix -> prettier check/format on OWNED paths only ->
# eslint (owned .ts/.cjs) -> tsc --noEmit whole repo (heap 4096) -> R75 checker (working tree) -> jest --ci targeted ->
# jest --ci full default config once (no PG; rls-* excluded by jest.config.js) -> stage exactly the owned paths -> R75 staged
# -> one genuine hooked Bradley commit -> receipts -> release. No push, no npm install, no contract regen, no PG. Any failure
# stops and is preserved; no rerun (STARTED sentinel).
# Usage (parent relay only):
#   S9B_GATE_RELAY=1 S9B_BASE=<M2 40-hex> S9B_INCLUDE_ADDENDUM=<1|0> \
#   S9B_DONOR=/home/user/workspace/worktrees/1910a060-s8f/node_modules \
#   S9B_PRETTIER_PREFIX=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 \
#   timeout -k 30 7200 bash /home/user/workspace/tgp-private-evidence/execution/1910a060/s9b/gate/s9b-gate-1910.sh
# (S9B_BASE may instead be filled into PINS.env BASE=; the env var wins when both are set and equal, refuses if they differ.)
set -uo pipefail
E=/home/user/workspace/tgp-private-evidence/execution/1910a060/s9b/gate
W=/home/user/workspace/worktrees/1910a060-s9b
LOCK=/home/user/workspace/execution/test-validation.lock
LOCK_RECORD=/home/user/workspace/tgp-private-evidence/execution/1910a060/runtime/LOCK_ESTABLISHED.txt
PREFIX_MANIFEST=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256
LOG=$E/gate.log
# shellcheck source=PINS.env
. "$E/PINS.env" || { echo "REFUSED: cannot source $E/PINS.env" >&2; exit 78; }
# ---- owned paths (10 new files; the doc is appended when the addendum is included). Order = git sort order for STAGED_EXPECT.
NEW_FILES="src/scout/reconciliation/facts.service.ts src/scout/reconciliation/reconciliation.module.ts test/rls-g2-s9.spec.ts test/scout/g2-s9-db-guard.spec.ts test/scout/reconciliation/facts.service.spec.ts test/utils/g2-s9-bootstrap.sh test/utils/g2-s9-db.ts test/utils/g2-s9-harness.ts test/utils/g2-s9-pg-harness.ts test/utils/g2-s9-worker.cjs"
DOC=docs/decisions/2026-09-25-s9-reconciliation.md
S9A_FILES="src/scout/reconciliation/types.ts src/scout/reconciliation/coverage.ts src/scout/reconciliation/reconcile.ts test/scout/reconciliation/reconcile.spec.ts"
ESLINT_FILES="src/scout/reconciliation/facts.service.ts src/scout/reconciliation/reconciliation.module.ts test/rls-g2-s9.spec.ts test/scout/g2-s9-db-guard.spec.ts test/scout/reconciliation/facts.service.spec.ts test/utils/g2-s9-db.ts test/utils/g2-s9-harness.ts test/utils/g2-s9-pg-harness.ts test/utils/g2-s9-worker.cjs"
# targeted suites: own unit + guard specs, the frozen S9-A spec against the committed bytes, and the neighbouring db guards
SUITES="test/scout/reconciliation/facts.service.spec.ts test/scout/g2-s9-db-guard.spec.ts test/scout/reconciliation/reconcile.spec.ts test/scout/g2-s8c-db-guard.spec.ts test/scout/g2-s7l-db-guard.spec.ts test/scout/g2-s8b-db-guard.spec.ts test/invariants/locked_defaults.spec.ts test/doctrine-cleanup.spec.ts"
ts(){ date -u +%FT%TZ; }
log(){ echo "$(ts) $*" | tee -a "$LOG"; }
sha(){ sha256sum "$1" | cut -c1-64; }
is40(){ [[ "$1" =~ ^[0-9a-f]{40}$ ]]; }
mkdir -p "$E"
# ---- 0 relay + one-shot sentinel (a refusal before ACQUIRED does not consume the grant)
[ "${S9B_GATE_RELAY:-}" = 1 ] || { echo "REFUSED: S9B_GATE_RELAY=1 (parent relay) not set" >&2; exit 78; }
[ -n "${S9B_DONOR:-}" ] && [ -d "$S9B_DONOR" ] || { echo "REFUSED: S9B_DONOR (node_modules donor dir) not set or absent" >&2; exit 78; }
[ -n "${S9B_PRETTIER_PREFIX:-}" ] && [ -d "$S9B_PRETTIER_PREFIX" ] || { echo "REFUSED: S9B_PRETTIER_PREFIX not set or absent" >&2; exit 78; }
case "${S9B_INCLUDE_ADDENDUM:-}" in 1|0) ;; *) echo "REFUSED: S9B_INCLUDE_ADDENDUM must be 1 (commit Addendum A) or 0 (doc left at landed bytes); reviewer disposition pending" >&2; exit 78;; esac
if [ -n "${S9B_BASE:-}" ]; then
  if [ "$BASE" != __FILL_M2__ ] && [ "$BASE" != "$S9B_BASE" ]; then echo "REFUSED: S9B_BASE=$S9B_BASE differs from PINS.env BASE=$BASE" >&2; exit 78; fi
  H=$S9B_BASE
else H=$BASE; fi
is40 "$H" || { echo "REFUSED: BASE is unfilled or not a 40-hex sha ($H); fill PINS.env BASE= or pass S9B_BASE=<M2>" >&2; exit 78; }
for v in SHA_FACTS_SERVICE SHA_MODULE SHA_FACTS_SPEC SHA_G2_DB SHA_G2_PGH SHA_G2_HARNESS SHA_G2_WORKER SHA_G2_BOOTSTRAP SHA_G2_GUARD_SPEC SHA_RLS_SPEC SHA_DOC_LANDED SHA_DOC_ADDENDUM SHA_S9A_TYPES SHA_S9A_COVERAGE SHA_S9A_RECONCILE SHA_S9A_SPEC SCHEMA_SHA PKG_LOCK_SHA NM_HIDDEN_LOCK CLIENT_INDEX_DTS CLIENT_SCHEMA; do
  [[ "${!v}" =~ ^[0-9a-f]{64}$ ]] || { echo "REFUSED: PINS.env $v is not a 64-hex sha256 (${!v})" >&2; exit 78; }
done
DONOR=$S9B_DONOR; B=$S9B_PRETTIER_PREFIX; ADD=$S9B_INCLUDE_ADDENDUM
if [ "$ADD" = 1 ]; then FILES="$NEW_FILES $DOC"; MSG=$E/commit-message.txt; DOC_EXPECT=$SHA_DOC_ADDENDUM; else FILES="$NEW_FILES"; MSG=$E/commit-message-no-addendum.txt; DOC_EXPECT=$SHA_DOC_LANDED; fi
PRETTIER_FILES=$(for f in $FILES; do case "$f" in *.sh) ;; *) printf '%s ' "$f";; esac; done)
STAGED_EXPECT=$(printf '%s\n' $FILES | sort | tr '\n' ' ')
STATUS_EXPECT=$( { for f in $NEW_FILES; do echo "?? $f"; done; [ "$ADD" = 1 ] && echo " M $DOC"; } | sort | tr '\n' '|')
[ -f "$MSG" ] || { echo "REFUSED: commit message $MSG absent" >&2; exit 78; }
[ ! -e "$E/STARTED" ] || { echo "REFUSED: $E/STARTED exists; this gate is one-shot, do not loop" >&2; exit 76; }
# ---- lock: existing canonical file, recorded inode (PINS.env and LOCK_ESTABLISHED.txt must agree), nonblocking flock here
[ -e "$LOCK" ] || { log "REFUSED lock file absent"; exit 75; }
REC_INODE=$(sed -n 's/.*inode=\([0-9]*\).*/\1/p' "$LOCK_RECORD" | head -1)
CUR_INODE=$(stat -c %i "$LOCK")
[ -n "$REC_INODE" ] && [ "$CUR_INODE" = "$REC_INODE" ] && [ "$CUR_INODE" = "$LOCK_INODE" ] || { log "REFUSED lock inode $CUR_INODE != recorded $REC_INODE / pinned $LOCK_INODE"; exit 75; }
exec 9>>"$LOCK"; flock -n 9 || { log "REFUSED canonical lock busy (live holder); not waiting, not stealing"; exit 75; }
date -u +%FT%TZ > "$E/STARTED"
log "ACQUIRED pid=$$ fd9 inode=$CUR_INODE lslocks=$(lslocks 2>/dev/null | grep -c test-validation || true) donor=$DONOR prefix=$B base=$H addendum=$ADD"
STAGE=preflight
finish(){ unset npm_config_prefix; log "RELEASING stage=$STAGE rc=$1 (fd9 closes at exit; lock file preserved)"; printf 'RC=%s STAGE=%s END=%s\n' "$1" "$STAGE" "$(ts)" > "$E/TERMINAL"; exit "$1"; }
export NODE_OPTIONS=--max-old-space-size=4096 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false PRISMA_HIDE_UPDATE_MESSAGE=1
export GIT_AUTHOR_NAME="Bradley Gleave" GIT_AUTHOR_EMAIL=bradley@bradleytgpcoaching.com GIT_COMMITTER_NAME="Bradley Gleave" GIT_COMMITTER_EMAIL=bradley@bradleytgpcoaching.com
log "node=$(node --version) npm=$(npm --version)"
cd "$W" || finish 70
[ "$(git rev-parse HEAD)" = "$H" ] || { log "PRECONDITION_FAIL HEAD $(git rev-parse HEAD) != BASE $H"; finish 70; }
[ "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH" ] || { log "PRECONDITION_FAIL branch != $BRANCH"; finish 70; }
[ -z "$(git config --get core.hooksPath)" ] || { log "PRECONDITION_FAIL core.hooksPath set"; finish 70; }
STATUS_NOW=$(git status --porcelain --untracked-files=all | sort | tr '\n' '|')
[ "$STATUS_NOW" = "$STATUS_EXPECT" ] || { log "PRECONDITION_FAIL status set: [$STATUS_NOW] expected [$STATUS_EXPECT]"; finish 70; }
chk(){ [ "$(sha "$1")" = "$2" ] || { log "PRECONDITION_FAIL $1 sha $(sha "$1") != $2"; finish 70; }; }
chk src/scout/reconciliation/facts.service.ts "$SHA_FACTS_SERVICE"
chk src/scout/reconciliation/reconciliation.module.ts "$SHA_MODULE"
chk test/scout/reconciliation/facts.service.spec.ts "$SHA_FACTS_SPEC"
chk test/utils/g2-s9-db.ts "$SHA_G2_DB"
chk test/utils/g2-s9-pg-harness.ts "$SHA_G2_PGH"
chk test/utils/g2-s9-harness.ts "$SHA_G2_HARNESS"
chk test/utils/g2-s9-worker.cjs "$SHA_G2_WORKER"
chk test/utils/g2-s9-bootstrap.sh "$SHA_G2_BOOTSTRAP"
chk test/scout/g2-s9-db-guard.spec.ts "$SHA_G2_GUARD_SPEC"
chk test/rls-g2-s9.spec.ts "$SHA_RLS_SPEC"
chk "$DOC" "$DOC_EXPECT"
[ "$(git show "$H:$DOC" | sha256sum | cut -c1-64)" = "$SHA_DOC_LANDED" ] || { log "PRECONDITION_FAIL committed doc at BASE != landed bytes $SHA_DOC_LANDED"; finish 70; }
if [ "$ADD" = 1 ]; then
  [ "$(git diff --numstat -- "$DOC" | cut -f1,2)" = "$(printf '%s\t0' "$DOC_ADDED_LINES")" ] || { log "PRECONDITION_FAIL doc delta is not +$DOC_ADDED_LINES/-0: $(git diff --numstat -- "$DOC")"; finish 70; }
fi
# S9-A composed at BASE: tracked, clean, accepted post-format bytes; no pre-format copies left behind
for f in $S9A_FILES; do git ls-files --error-unmatch "$f" > /dev/null 2>&1 || { log "PRECONDITION_FAIL $f not tracked at BASE (S9-A not composed?)"; finish 70; }; done
[ -z "$(git status --porcelain -- $S9A_FILES)" ] || { log "PRECONDITION_FAIL S9-A files modified in working tree: $(git status --porcelain -- $S9A_FILES | tr '\n' ' ')"; finish 70; }
chk src/scout/reconciliation/types.ts "$SHA_S9A_TYPES"
chk src/scout/reconciliation/coverage.ts "$SHA_S9A_COVERAGE"
chk src/scout/reconciliation/reconcile.ts "$SHA_S9A_RECONCILE"
chk test/scout/reconciliation/reconcile.spec.ts "$SHA_S9A_SPEC"
[ ! -e node_modules ] || { log "PRECONDITION_FAIL node_modules already present"; finish 70; }
chk prisma/schema.prisma "$SCHEMA_SHA"
chk package-lock.json "$PKG_LOCK_SHA"
MIG_N=$(find prisma/migrations -mindepth 1 -maxdepth 1 -type d | wc -l); MIG_LAST=$(find prisma/migrations -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | tail -1)
[ "$MIG_N" = "$MIGRATION_DIRS" ] && [ "$MIG_LAST" = "$LAST_MIGRATION" ] || { log "PRECONDITION_FAIL migrations dirs=$MIG_N last=$MIG_LAST (pins $MIGRATION_DIRS/$LAST_MIGRATION; harness constants would need a rebase edit)"; finish 70; }
grep -q "EXPECTED_MIGRATIONS = $MIGRATION_DIRS;" test/utils/g2-s9-pg-harness.ts && grep -q "S7L_MIGRATION = '$LAST_MIGRATION'" test/utils/g2-s9-pg-harness.ts || { log "PRECONDITION_FAIL harness constants != migration pins"; finish 70; }
[ -z "$(git diff --name-only "$H" HEAD -- prisma)" ] || { log "PRECONDITION_FAIL prisma tree delta"; finish 70; }
for hk in pre-commit commit-msg; do [ ! -e ".git/hooks/$hk" ] || { log "PRECONDITION_FAIL .git/hooks/$hk already present"; finish 70; }; done
bash -n test/utils/g2-s9-bootstrap.sh || { log "PRECONDITION_FAIL bootstrap.sh syntax"; finish 70; }
node --check test/utils/g2-s9-worker.cjs || { log "PRECONDITION_FAIL worker.cjs syntax"; finish 70; }
pgrep -af "jest|tsc|prisma|postgres|prettier|lefthook|eslint" | grep -v "$$" | grep -v s9b-gate | tee -a "$LOG" | grep -q . && log "WARN other heavy processes present (recorded)"
# ---- 1 node_modules from the relayed donor (pinned to BASE's schema + lockfile); donor is read-only here
STAGE=node_modules
DONOR_REPO=$(dirname "$DONOR")
log "DONOR_HEAD=$(git -C "$DONOR_REPO" rev-parse HEAD 2>/dev/null || echo n/a) DONOR_HIDDEN_LOCK=$(sha "$DONOR/.package-lock.json" 2>/dev/null || echo absent) DONOR_CLIENT_INDEX_DTS=$(sha "$DONOR/.prisma/client/index.d.ts" 2>/dev/null || echo absent) DONOR_CLIENT_SCHEMA=$(sha "$DONOR/.prisma/client/schema.prisma" 2>/dev/null || echo absent) DONOR_ENTRIES=$(ls "$DONOR" | wc -l)"
[ "$(sha "$DONOR/.package-lock.json")" = "$NM_HIDDEN_LOCK" ] || { log "PRECONDITION_FAIL donor hidden lock != $NM_HIDDEN_LOCK (donor must be npm ci of package-lock $PKG_LOCK_SHA)"; finish 71; }
GEN_NEEDED=0
if [ "$(sha "$DONOR/.prisma/client/index.d.ts" 2>/dev/null)" != "$CLIENT_INDEX_DTS" ] || [ "$(sha "$DONOR/.prisma/client/schema.prisma" 2>/dev/null)" != "$CLIENT_SCHEMA" ]; then
  GEN_NEEDED=1; log "DONOR_CLIENT_MISMATCH donor prisma client is not BASE's; in-lane prisma generate from the committed schema $SCHEMA_SHA will follow the copy (RT-2 S7-L precedent), result must equal $CLIENT_INDEX_DTS / $CLIENT_SCHEMA"
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
  [ "$(git status --porcelain --untracked-files=all | sort | tr '\n' '|')" = "$STATUS_EXPECT" ] || { log "PRECONDITION_FAIL prisma generate changed the status set"; finish 71; }
fi
log "NM_CLIENT_INDEX_DTS=$(sha node_modules/.prisma/client/index.d.ts 2>/dev/null || echo absent) NM_CLIENT_SCHEMA=$(sha node_modules/.prisma/client/schema.prisma 2>/dev/null || echo absent)"
[ "$(sha node_modules/.prisma/client/index.d.ts)" = "$CLIENT_INDEX_DTS" ] && [ "$(sha node_modules/.prisma/client/schema.prisma)" = "$CLIENT_SCHEMA" ] || { log "PRECONDITION_FAIL in-lane prisma client != BASE pins; refusing (no repin)"; finish 71; }
[ ! -e node_modules/.bin/prettier ] || { log "PRECONDITION_FAIL prettier inside product tree"; finish 71; }
for b in tsc jest eslint lefthook; do [ -x node_modules/.bin/$b ] || { log "PRECONDITION_FAIL node_modules/.bin/$b missing"; finish 71; }; done
log "LEFTHOOK_VERSION=$(./node_modules/.bin/lefthook version 2>&1 | head -1)"
# ---- 2 genuine hooks into THIS clone (lefthook from the copied node_modules; nothing shared)
STAGE=hooks
npx --no-install lefthook install > "$E/lefthook-install.log" 2>&1; rc=$?; log "LEFTHOOK_INSTALL rc=$rc"; [ $rc = 0 ] || finish 71
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
V=$(npx --no-install prettier --version 2>>"$LOG"); log "NPX_PRETTIER_VERSION=$V"; [ "$V" = "$PRETTIER_EXPECT" ] || finish 71
# ---- 4 prettier on OWNED paths only (.sh excluded: no prettier parser; layout only, hand-written source expected to reflow)
STAGE=prettier
log "PRETTIER_FILES=$PRETTIER_FILES"
npx --no-install prettier --check $PRETTIER_FILES > "$E/prettier-check-1.log" 2>&1; rc=$?; log "PRETTIER_CHECK_1 rc=$rc"
if [ $rc != 0 ]; then
  TOFIX=$(grep '^\[warn\] ' "$E/prettier-check-1.log" | sed 's/^\[warn\] //' | grep -v 'Code style issues' | grep -v 'Run Prettier' || true)
  log "PRETTIER_TOFIX=$(echo $TOFIX)"
  [ -n "$TOFIX" ] || { log "PRETTIER_FAIL check failed without a [warn] list (parser/config error):"; tail -20 "$E/prettier-check-1.log" >> "$LOG"; finish 72; }
  for f in $TOFIX; do case " $PRETTIER_FILES " in *" $f "*) ;; *) log "PRETTIER_SCOPE_FAIL $f not in owned prettier set"; finish 72;; esac; done
  npx --no-install prettier --write $TOFIX > "$E/prettier-write-1.log" 2>&1 || { log "PRETTIER_WRITE_FAIL"; finish 72; }
  npx --no-install prettier --check $PRETTIER_FILES > "$E/prettier-check-2.log" 2>&1; rc=$?; log "PRETTIER_CHECK_2 rc=$rc"; [ $rc = 0 ] || finish 72
fi
mkdir -p "$E/postformat"
for f in $FILES; do log "POSTFORMAT $f sha256=$(sha "$f") lines=$(wc -l < "$f")"; cp "$f" "$E/postformat/$(basename "$f")"; done
[ "$(git status --porcelain --untracked-files=all | sort | tr '\n' '|')" = "$STATUS_EXPECT" ] || { log "SCOPE_FAIL status set changed by formatting: $(git status --porcelain | tr '\n' ' ')"; finish 72; }
if [ "$ADD" = 1 ]; then
  [ "$(git diff --numstat -- "$DOC" | cut -f2)" = 0 ] || { log "SCOPE_FAIL prettier touched landed doc text (deletions != 0): $(git diff --numstat -- "$DOC")"; finish 72; }
  log "DOC_DELTA_POSTFORMAT $(git diff --numstat -- "$DOC" | cut -f1,2 | tr '\t' /) (pre-format $DOC_ADDED_LINES/0; additions may differ only by prettier reflow of Addendum A)"
fi
# ---- 5 eslint on owned .ts/.cjs (repo config: no-unused-vars is warn, --max-warnings 0 makes it fatal)
STAGE=eslint
npx --no-install eslint --no-warn-ignored --max-warnings 0 $ESLINT_FILES > "$E/eslint.raw.log" 2>&1; rc=$?; log "ESLINT rc=$rc"; [ $rc = 0 ] || { tail -60 "$E/eslint.raw.log" >> "$LOG"; finish 74; }
# ---- 6 tsc (whole repo; tsconfig has no include so test/ is type-checked)
STAGE=tsc
npx --no-install tsc --noEmit > "$E/tsc.raw.log" 2>&1; rc=$?; log "TSC rc=$rc lines=$(wc -l < "$E/tsc.raw.log")"; [ $rc = 0 ] || { tail -60 "$E/tsc.raw.log" >> "$LOG"; finish 73; }
# ---- 7 R75 banned-cast checker on the working tree (the hook repeats it in staged mode)
STAGE=r75
node scripts/check-r75.js > "$E/r75.raw.log" 2>&1; rc=$?; log "R75_WORKTREE rc=$rc"; [ $rc = 0 ] || { tail -40 "$E/r75.raw.log" >> "$LOG"; finish 74; }
# ---- 8 jest targeted (default config, no PG), then the full default suite once
STAGE=jest
./node_modules/.bin/jest --ci $SUITES > "$E/jest.raw.log" 2>&1; rc=$?; log "JEST_TARGETED rc=$rc"
grep -E '^(Tests|Test Suites|Snapshots|Time):' "$E/jest.raw.log" | tee -a "$LOG"
[ $rc = 0 ] || { grep -E '✕|●' "$E/jest.raw.log" | head -60 >> "$LOG"; finish 73; }
STAGE=jest_full
t0=$(date +%s); timeout --foreground 4200 ./node_modules/.bin/jest --ci > "$E/jest-full.raw.log" 2>&1; rc=$?; log "JEST_FULL rc=$rc secs=$(( $(date +%s)-t0 ))"
grep -E '^(Tests|Test Suites|Snapshots|Time):' "$E/jest-full.raw.log" | tee -a "$LOG"
[ $rc = 0 ] || { grep -E '✕|●' "$E/jest-full.raw.log" | head -60 >> "$LOG"; finish 73; }
[ "$(git status --porcelain --untracked-files=all | sort | tr '\n' '|')" = "$STATUS_EXPECT" ] || { log "SCOPE_FAIL status set changed by tests: $(git status --porcelain | tr '\n' ' ')"; finish 73; }
# ---- 9 stage exactly the owned paths + R75 staged + one genuine hooked commit
STAGE=stage
git add -- $FILES
[ "$(git diff --cached --name-only | sort | tr '\n' ' ')" = "$STAGED_EXPECT" ] || { log "STAGED_SET_FAIL $(git diff --cached --name-only | tr '\n' ' ')"; finish 70; }
TREE=$(git write-tree); log "STAGED_TREE=$TREE"
for f in $FILES; do log "STAGED_BLOB $f $(git rev-parse ":$f")"; done
node scripts/check-r75.js --mode=staged > "$E/r75-staged.raw.log" 2>&1; rc=$?; log "R75_STAGED rc=$rc"; [ $rc = 0 ] || { tail -40 "$E/r75-staged.raw.log" >> "$LOG"; finish 74; }
STAGE=commit
git commit -F "$MSG" > "$E/commit-attempt-1.raw.log" 2>&1; rc=$?
tail -25 "$E/commit-attempt-1.raw.log" >> "$LOG"; log "GIT_COMMIT rc=$rc"; [ $rc = 0 ] || finish 76
HEAD=$(git rev-parse HEAD); HTREE=$(git rev-parse 'HEAD^{tree}')
log "HEAD=$HEAD TREE=$HTREE author=$(git log -1 --format='%an <%ae> / %cn <%ce> / %cI') parent=$(git rev-parse HEAD^)"
[ "$(git rev-parse HEAD^)" = "$H" ] && [ -z "$(git status --porcelain --untracked-files=all)" ] || { log "LINEAGE_FAIL"; finish 76; }
[ "$(git diff --name-only "$H" HEAD | sort | tr '\n' ' ')" = "$STAGED_EXPECT" ] || { log "DELTA_FAIL"; finish 76; }
[ -z "$(git diff --name-only "$H" HEAD -- prisma src/scout/lifecycle src/scout/reconstruct $S9A_FILES)" ] || { log "DELTA_FAIL forbidden path in delta"; finish 76; }
[ "$(git log -1 --format='%an <%ae>|%cn <%ce>')" = "Bradley Gleave <bradley@bradleytgpcoaching.com>|Bradley Gleave <bradley@bradleytgpcoaching.com>" ] || { log "IDENTITY_FAIL"; finish 76; }
git log -1 --format=%B HEAD > "$E/committed-message.txt"
grep -iqE 'co-authored-by|generated' "$E/committed-message.txt" && { log "TRAILER_FAIL"; finish 76; }
# ---- 10 receipts
STAGE=receipts
git diff --binary "$H" HEAD > "$E/s9b-${H:0:12}-to-${HEAD:0:12}.patch"
git diff --name-status "$H" HEAD > "$E/MANIFEST-name-status-${H:0:12}-to-${HEAD:0:12}.txt"
{ echo "base_M2=$H"; echo "head=$HEAD"; echo "tree=$HTREE"; echo "addendum_included=$ADD"; for f in $FILES; do echo "blob $f $(git rev-parse HEAD:$f) sha256=$(sha "$f")"; done; for f in $S9A_FILES; do echo "s9a_unchanged $f $(git rev-parse HEAD:$f) sha256=$(sha "$f")"; done; echo "branch=$(git rev-parse --abbrev-ref HEAD)"; git log -1 --format='author=%an <%ae>%ncommitter=%cn <%ce>%ndate=%cI'; echo "hooks raw pre-commit=$HP commit-msg=$HC normalized pre-commit=$NP commit-msg=$NC ref_root=$HOOK_REF_ROOT lefthook=$LHV"; echo "prettier=$V prefix=$B"; echo "donor=$DONOR hidden_lock=$NM_HIDDEN_LOCK client_index_dts=$CLIENT_INDEX_DTS"; echo "lock_inode=$CUR_INODE"; } > "$E/HEAD-${HEAD:0:12}.txt"
( cd "$E" && sha256sum * postformat/* > SHA256SUMS ) 2>/dev/null
STAGE=done; log "DONE head=$HEAD tree=$HTREE (not pushed; parent owns landing; PG proof is a separate grant via ../binding)"; finish 0
