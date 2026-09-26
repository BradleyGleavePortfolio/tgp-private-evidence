#!/usr/bin/env bash
# S9-C gate under the canonical slot — EXEC-D3A9F701 (S9-C wiring; D-S9-8 S9-C row + Gen row carried by this slice).
# Derived step-for-step from the accepted 1910a060/s9b/gate/s9b-gate-1910.sh (S9-B head 1e6e5735, landed as 5407efae),
# INCLUDING the accepted d3a9 narrow fix (no R75 working-tree call: check-r75.js has only --mode=staged|range; R75 is
# enforced by --mode=staged at STAGE=stage and by the pre-commit hook). Differences are scope only:
#   - worktree /home/user/workspace/worktrees/d3a9-s9c-r2 (standalone clone), branch exec-d3a9/s9c-r2, BASE = 5407efae
#     (S9-B landing merge, tree 3e2028e9), pinned in PINS.env (S9C_BASE, if relayed, must equal it)
#   - owned paths: PINS.env OWNED_PINS (freeze-1: 11 ` M` incl. docs/contracts/importer-openapi.json from npm run
#     contract:importer + 8 `??`) + the S9 decision doc (` M`, append-only Addendum B: +DOC_ADDED_LINES/-0, BASE bytes a
#     byte-prefix before and after prettier and in the commit). STATUS_EXPECT / STAGED_EXPECT are derived from that list.
#   - the S9-A-tracked checks are replaced by: the 10 other S9-B paths (git diff --name-only 9497ca52 1e6e5735, minus the
#     doc) tracked + clean at BASE at the S9-B receipt sha256/blobs and UNCHANGED by S9-C; prisma unchanged; migrations
#     172 dirs ending at the pin that test/utils/g2-s9c-pg-harness.ts carries
#   - NEW STEP after tsc: `npm run -s contract:importer`, then docs/contracts/importer-openapi.json must be byte-unchanged
#     (regen-stable) and test/contracts/importer-contract.spec.ts must pass
#   - every owned file is copied to preformat/ BEFORE any prettier write (S9-B lesson); POSTFORMAT recorded after
#   - evidence d3a9f701/s9c/gate/** (this dir); PINS.env beside this script carries every hash
# Steps: relay+sentinel -> lock (flock -n fd9, inode pinned + LOCK_ESTABLISHED.txt) -> preconditions -> cp -a donor
# node_modules -> lefthook install (normalized hook shas) -> verified prettier prefix -> preformat copies -> prettier
# check/format OWNED paths only -> eslint (owned .ts/.cjs) -> tsc --noEmit (heap 4096) -> contract regen-stable + contract
# spec -> jest --ci targeted -> jest --ci full default once -> stage exactly the owned paths -> R75 staged -> one
# genuine hooked Bradley commit -> receipts -> release. No push, no npm install, no PG. Any failure stops and is
# preserved; no rerun (STARTED sentinel).
# Usage (parent relay only):
#   S9C_GATE_RELAY=1 S9C_BASE=5407efae319fd913e973c87f3be0d49786c4a3e0 \
#   S9C_DONOR=/home/user/workspace/worktrees/1910a060-s8f/node_modules \
#   S9C_PRETTIER_PREFIX=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 \
#   timeout -k 30 7200 bash /home/user/workspace/tgp-private-evidence/execution/d3a9f701/s9c/gate/s9c-gate-d3a9.sh
set -uo pipefail
E=/home/user/workspace/tgp-private-evidence/execution/d3a9f701/s9c/gate
W=/home/user/workspace/worktrees/d3a9-s9c-r2
LOCK=/home/user/workspace/execution/test-validation.lock
LOCK_RECORD=/home/user/workspace/tgp-private-evidence/execution/d3a9f701/runtime/LOCK_ESTABLISHED.txt
PREFIX_MANIFEST=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256
LOG=$E/gate.log
# shellcheck source=PINS.env
. "$E/PINS.env" || { echo "REFUSED: cannot source $E/PINS.env" >&2; exit 78; }
# ---- owned paths come from PINS.env OWNED_PINS ("<sha> <mode> <M|N> <path>"; M = ` M`, N = `??`); DOC (PINS.env) is
# always owned as ` M` (append-only Addendum B). The contract artifact and the S9-C harness files must be in the set.
CONTRACT=docs/contracts/importer-openapi.json
REQUIRED_OWNED="$CONTRACT test/rls-g2-s9c.spec.ts test/utils/g2-s9c-bootstrap.sh test/utils/g2-s9c-db.ts test/utils/g2-s9c-harness.ts test/utils/g2-s9c-pg-harness.ts test/utils/g2-s9c-worker.cjs"
S9A_FILES="src/scout/reconciliation/types.ts src/scout/reconciliation/coverage.ts src/scout/reconciliation/reconcile.ts test/scout/reconciliation/reconcile.spec.ts"
# SUITES (targeted jest, explicit paths) = PINS.env SUITES
ts(){ date -u +%FT%TZ; }
log(){ echo "$(ts) $*" | tee -a "$LOG"; }
sha(){ sha256sum "$1" | cut -c1-64; }
is40(){ [[ "$1" =~ ^[0-9a-f]{40}$ ]]; }
is64(){ [[ "$1" =~ ^[0-9a-f]{64}$ ]]; }
flat(){ echo "$1" | sed 's|/|__|g'; }
mkdir -p "$E"
# ---- 0 relay + one-shot sentinel (a refusal before ACQUIRED does not consume the grant)
[ "${S9C_GATE_RELAY:-}" = 1 ] || { echo "REFUSED: S9C_GATE_RELAY=1 (parent relay) not set" >&2; exit 78; }
[ -n "${S9C_DONOR:-}" ] && [ -d "$S9C_DONOR" ] || { echo "REFUSED: S9C_DONOR (node_modules donor dir) not set or absent" >&2; exit 78; }
[ -n "${S9C_PRETTIER_PREFIX:-}" ] && [ -d "$S9C_PRETTIER_PREFIX" ] || { echo "REFUSED: S9C_PRETTIER_PREFIX not set or absent" >&2; exit 78; }
is40 "$BASE" || { echo "REFUSED: PINS.env BASE is not a 40-hex sha ($BASE)" >&2; exit 78; }
if [ -n "${S9C_BASE:-}" ] && [ "$S9C_BASE" != "$BASE" ]; then echo "REFUSED: S9C_BASE=$S9C_BASE differs from PINS.env BASE=$BASE" >&2; exit 78; fi
H=$BASE
is40 "$BASE_TREE" && is40 "$MIGRATIONS_TREE" && is40 "$DOC_LANDED_BLOB" || { echo "REFUSED: PINS.env BASE_TREE/MIGRATIONS_TREE/DOC_LANDED_BLOB not 40-hex" >&2; exit 78; }
for v in SHA_CONTRACT_JSON SHA_DOC_LANDED SHA_DOC_ADDENDUM SCHEMA_SHA PKG_LOCK_SHA NM_HIDDEN_LOCK CLIENT_INDEX_DTS CLIENT_SCHEMA; do
  is64 "${!v}" || { echo "REFUSED: PINS.env $v is not a 64-hex sha256 (${!v})" >&2; exit 78; }
done
[[ "$DOC_ADDED_LINES" =~ ^[1-9][0-9]*$ ]] && [[ "$DOC_LANDED_BYTES" =~ ^[1-9][0-9]*$ ]] || { echo "REFUSED: PINS.env DOC_ADDED_LINES/DOC_LANDED_BYTES unfilled or not a positive integer" >&2; exit 78; }
# OWNED_PINS: every sha filled, mode 644/755, state M/N, no duplicates, DOC not listed, required S9-C paths present
MOD_FILES=""; NEW_FILES=""
while read -r s m st p; do [ -n "${p:-}" ] || continue
  is64 "$s" || { echo "REFUSED: PINS.env OWNED_PINS sha for $p not filled ($s)" >&2; exit 78; }
  case "$m" in 644|755) ;; *) echo "REFUSED: PINS.env OWNED_PINS mode for $p ($m)" >&2; exit 78;; esac
  case "$st" in M) MOD_FILES="$MOD_FILES $p";; N) NEW_FILES="$NEW_FILES $p";; *) echo "REFUSED: PINS.env OWNED_PINS state for $p ($st; M or N)" >&2; exit 78;; esac
  [ "$p" != "$DOC" ] || { echo "REFUSED: the doc is pinned by SHA_DOC_ADDENDUM, not OWNED_PINS" >&2; exit 78; }
done <<< "$OWNED_PINS"
[ -z "$(printf '%s\n' $MOD_FILES $NEW_FILES | sort | uniq -d)" ] || { echo "REFUSED: PINS.env OWNED_PINS has duplicate paths" >&2; exit 78; }
for p in $REQUIRED_OWNED; do case " $MOD_FILES $NEW_FILES " in *" $p "*) ;; *) echo "REFUSED: PINS.env OWNED_PINS lacks required S9-C path $p" >&2; exit 78;; esac; done
for p in $MOD_FILES $NEW_FILES; do for fp in $FORBIDDEN_DELTA_PATHS; do case "$p" in "$fp"|"$fp"/*)
  case " $FORBIDDEN_EXCEPTIONS " in *" $p "*) ;; *) echo "REFUSED: owned $p is under forbidden $fp and not in FORBIDDEN_EXCEPTIONS" >&2; exit 78;; esac;; esac; done; done
for p in $FORBIDDEN_EXCEPTIONS; do case " $MOD_FILES $NEW_FILES " in *" $p "*) ;; *) echo "REFUSED: FORBIDDEN_EXCEPTIONS entry $p is not an owned path" >&2; exit 78;; esac; done
[ -n "$SUITES" ] || { echo "REFUSED: PINS.env SUITES empty" >&2; exit 78; }
[ "$(printf '%s\n' "$OWNED_PINS" | awk -v p="$CONTRACT" '$4==p{print $1}')" = "$SHA_CONTRACT_JSON" ] || { echo "REFUSED: SHA_CONTRACT_JSON != OWNED_PINS sha of $CONTRACT" >&2; exit 78; }
[ "$(printf '%s\n' "$S9B_PINS" | awk 'NF' | wc -l)" = 10 ] || { echo "REFUSED: PINS.env S9B_PINS must list the 10 S9-B code/test paths" >&2; exit 78; }
S9B_FILES=$(printf '%s\n' "$S9B_PINS" | awk 'NF{print $3}' | tr '\n' ' ')
DONOR=$S9C_DONOR; B=$S9C_PRETTIER_PREFIX
FILES="$MOD_FILES $NEW_FILES $DOC"; MSG=$E/commit-message.txt
# prettier: owned .ts/.cjs/.md; never .sh (no parser) nor the contract artifact (.prettierignore, byte-pinned generator output)
PRETTIER_FILES=$(for f in $FILES; do case "$f" in *.sh|"$CONTRACT") ;; *) printf '%s ' "$f";; esac; done)
ESLINT_FILES=$(for f in $FILES; do case "$f" in *.ts|*.cjs) printf '%s ' "$f";; esac; done)
STAGED_EXPECT=$(printf '%s\n' $FILES | sort | tr '\n' ' ')
STATUS_EXPECT=$( { for f in $MOD_FILES $DOC; do echo " M $f"; done; for f in $NEW_FILES; do echo "?? $f"; done; } | sort | tr '\n' '|')
N_SUITES=$(echo $SUITES | wc -w)
[ -f "$MSG" ] || { echo "REFUSED: commit message $MSG absent" >&2; exit 78; }
[ ! -e "$E/STARTED" ] || { echo "REFUSED: $E/STARTED exists; this gate is one-shot, do not loop" >&2; exit 76; }
# ---- lock: existing canonical file, recorded inode (PINS.env and LOCK_ESTABLISHED.txt must agree), nonblocking flock here
[ -e "$LOCK" ] || { log "REFUSED lock file absent"; exit 75; }
REC_INODE=$(sed -n 's/.*inode=\([0-9]*\).*/\1/p' "$LOCK_RECORD" | head -1)
CUR_INODE=$(stat -c %i "$LOCK")
[ -n "$REC_INODE" ] && [ "$CUR_INODE" = "$REC_INODE" ] && [ "$CUR_INODE" = "$LOCK_INODE" ] || { log "REFUSED lock inode $CUR_INODE != recorded $REC_INODE / pinned $LOCK_INODE"; exit 75; }
exec 9>>"$LOCK"; flock -n 9 || { log "REFUSED canonical lock busy (live holder); not waiting, not stealing"; exit 75; }
date -u +%FT%TZ > "$E/STARTED"
log "ACQUIRED pid=$$ fd9 inode=$CUR_INODE lslocks=$(lslocks 2>/dev/null | grep -c test-validation || true) donor=$DONOR prefix=$B base=$H"
STAGE=preflight
finish(){ unset npm_config_prefix; log "RELEASING stage=$STAGE rc=$1 (fd9 closes at exit; lock file preserved)"; printf 'RC=%s STAGE=%s END=%s\n' "$1" "$STAGE" "$(ts)" > "$E/TERMINAL"; exit "$1"; }
export NODE_OPTIONS=--max-old-space-size=4096 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false PRISMA_HIDE_UPDATE_MESSAGE=1
export GIT_AUTHOR_NAME="Bradley Gleave" GIT_AUTHOR_EMAIL=bradley@bradleytgpcoaching.com GIT_COMMITTER_NAME="Bradley Gleave" GIT_COMMITTER_EMAIL=bradley@bradleytgpcoaching.com
log "node=$(node --version) npm=$(npm --version)"
cd "$W" || finish 70
[ "$(git rev-parse HEAD)" = "$H" ] || { log "PRECONDITION_FAIL HEAD $(git rev-parse HEAD) != BASE $H"; finish 70; }
[ "$(git rev-parse 'HEAD^{tree}')" = "$BASE_TREE" ] || { log "PRECONDITION_FAIL BASE tree $(git rev-parse 'HEAD^{tree}') != $BASE_TREE"; finish 70; }
[ "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH" ] || { log "PRECONDITION_FAIL branch != $BRANCH"; finish 70; }
[ -z "$(git config --get core.hooksPath)" ] || { log "PRECONDITION_FAIL core.hooksPath set"; finish 70; }
[ -z "$(git diff --cached --name-only)" ] || { log "PRECONDITION_FAIL index not clean vs HEAD (staged or intent-to-add entries): $(git diff --cached --name-only | tr '\n' ' ')"; finish 70; }
STATUS_NOW=$(git status --porcelain --untracked-files=all | sort | tr '\n' '|')
[ "$STATUS_NOW" = "$STATUS_EXPECT" ] || { log "PRECONDITION_FAIL status set: [$STATUS_NOW] expected [$STATUS_EXPECT]"; finish 70; }
chk(){ [ "$(sha "$1")" = "$2" ] || { log "PRECONDITION_FAIL $1 sha $(sha "$1") != $2"; finish 70; }; }
while read -r s m st p; do [ -n "${p:-}" ] || continue
  chk "$p" "$s"
  [ "$(stat -c %a "$p")" = "$m" ] || { log "PRECONDITION_FAIL $p mode $(stat -c %a "$p") != $m"; finish 70; }
done <<< "$OWNED_PINS"
# S9 decision doc: landed bytes at BASE; working copy = BASE bytes (byte-prefix) + Addendum B, +DOC_ADDED_LINES/-0
[ "$(git rev-parse "$H:$DOC")" = "$DOC_LANDED_BLOB" ] && [ "$(git show "$H:$DOC" | sha256sum | cut -c1-64)" = "$SHA_DOC_LANDED" ] || { log "PRECONDITION_FAIL committed doc at BASE != landed bytes $SHA_DOC_LANDED"; finish 70; }
chk "$DOC" "$SHA_DOC_ADDENDUM"
docprefix(){ [ "$(head -c "$DOC_LANDED_BYTES" "$DOC" | sha256sum | cut -c1-64)" = "$SHA_DOC_LANDED" ]; }
docprefix || { log "PRECONDITION_FAIL BASE doc bytes are not a byte-prefix of the working doc"; finish 70; }
[ "$(git diff --numstat -- "$DOC" | cut -f1,2)" = "$(printf '%s\t0' "$DOC_ADDED_LINES")" ] || { log "PRECONDITION_FAIL doc delta is not +$DOC_ADDED_LINES/-0: $(git diff --numstat -- "$DOC")"; finish 70; }
# the 10 other S9-B paths (and the S9-A four) at BASE: tracked, clean, accepted bytes
while read -r s b p; do [ -n "$p" ] || continue
  git ls-files --error-unmatch "$p" > /dev/null 2>&1 || { log "PRECONDITION_FAIL S9-B $p not tracked at BASE"; finish 70; }
  [ "$(git rev-parse "$H:$p")" = "$b" ] || { log "PRECONDITION_FAIL S9-B $p blob at BASE $(git rev-parse "$H:$p") != $b"; finish 70; }
  chk "$p" "$s"
done <<< "$S9B_PINS"
[ -z "$(git status --porcelain -- $S9B_FILES $S9A_FILES)" ] || { log "PRECONDITION_FAIL S9-B/S9-A files modified in working tree: $(git status --porcelain -- $S9B_FILES $S9A_FILES | tr '\n' ' ')"; finish 70; }
[ "$(git diff --name-only "$S9B_RANGE_FROM" "$S9B_RANGE_TO" | sort | tr '\n' ' ')" = "$(printf '%s\n' $S9B_FILES $DOC | sort | tr '\n' ' ')" ] || { log "PRECONDITION_FAIL S9-B range $S9B_RANGE_FROM..$S9B_RANGE_TO != the 11 pinned S9-B paths"; finish 70; }
[ ! -e node_modules ] || { log "PRECONDITION_FAIL node_modules already present (parent must set the clone's copy aside first)"; finish 70; }
chk prisma/schema.prisma "$SCHEMA_SHA"
chk package-lock.json "$PKG_LOCK_SHA"
[ "$(git rev-parse HEAD:prisma/migrations)" = "$MIGRATIONS_TREE" ] || { log "PRECONDITION_FAIL prisma/migrations tree at BASE != $MIGRATIONS_TREE"; finish 70; }
[ -z "$(git status --porcelain --untracked-files=all -- prisma package.json package-lock.json)" ] || { log "PRECONDITION_FAIL prisma/package manifests dirty in working tree"; finish 70; }
MIG_N=$(find prisma/migrations -mindepth 1 -maxdepth 1 -type d | wc -l); MIG_LAST=$(find prisma/migrations -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | tail -1)
[ "$MIG_N" = "$MIGRATION_DIRS" ] && [ "$MIG_LAST" = "$LAST_MIGRATION" ] || { log "PRECONDITION_FAIL migrations dirs=$MIG_N last=$MIG_LAST (pins $MIGRATION_DIRS/$LAST_MIGRATION; harness constants would need a rebase edit)"; finish 70; }
grep -q "export const EXPECTED_MIGRATIONS = $MIGRATION_DIRS;" test/utils/g2-s9c-pg-harness.ts && grep -q "export const S7L_MIGRATION = '$LAST_MIGRATION';" test/utils/g2-s9c-pg-harness.ts || { log "PRECONDITION_FAIL g2-s9c-pg-harness.ts constants != migration pins"; finish 70; }
grep -qx "EXPECTED_MIGRATIONS=$MIGRATION_DIRS" test/utils/g2-s9c-bootstrap.sh && grep -qx "S7L_MIGRATION=$LAST_MIGRATION" test/utils/g2-s9c-bootstrap.sh || { log "PRECONDITION_FAIL g2-s9c-bootstrap.sh constants != migration pins"; finish 70; }
for hk in pre-commit commit-msg; do [ ! -e ".git/hooks/$hk" ] || { log "PRECONDITION_FAIL .git/hooks/$hk already present"; finish 70; }; done
bash -n test/utils/g2-s9c-bootstrap.sh || { log "PRECONDITION_FAIL bootstrap.sh syntax"; finish 70; }
node --check test/utils/g2-s9c-worker.cjs || { log "PRECONDITION_FAIL worker.cjs syntax"; finish 70; }
pgrep -af "jest|tsc|prisma|postgres|prettier|lefthook|eslint" | grep -v "$$" | grep -v s9c-gate | tee -a "$LOG" | grep -q . && log "WARN other heavy processes present (recorded)"
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
for b in tsc jest eslint lefthook ts-node; do [ -x node_modules/.bin/$b ] || { log "PRECONDITION_FAIL node_modules/.bin/$b missing"; finish 71; }; done
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
# ---- 4 preformat copies of EVERY owned path (before any write), then prettier on OWNED paths only
STAGE=preformat
mkdir -p "$E/preformat"
for f in $FILES; do cp -p "$f" "$E/preformat/$(flat "$f")" || { log "PREFORMAT_COPY_FAIL $f"; finish 72; }; log "PREFORMAT $f sha256=$(sha "$f") lines=$(wc -l < "$f")"; done
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
for f in $FILES; do log "POSTFORMAT $f sha256=$(sha "$f") lines=$(wc -l < "$f")"; cp -p "$f" "$E/postformat/$(flat "$f")"; done
[ "$(git status --porcelain --untracked-files=all | sort | tr '\n' '|')" = "$STATUS_EXPECT" ] || { log "SCOPE_FAIL status set changed by formatting: $(git status --porcelain | tr '\n' ' ')"; finish 72; }
[ "$(sha "$CONTRACT")" = "$SHA_CONTRACT_JSON" ] || { log "SCOPE_FAIL contract artifact changed during formatting"; finish 72; }
[ "$(sha test/utils/g2-s9c-bootstrap.sh)" = "$(printf '%s\n' "$OWNED_PINS" | awk '$4=="test/utils/g2-s9c-bootstrap.sh"{print $1}')" ] || { log "SCOPE_FAIL bootstrap.sh changed during formatting"; finish 72; }
[ "$(git diff --numstat -- "$DOC" | cut -f2)" = 0 ] && docprefix || { log "SCOPE_FAIL prettier touched landed doc text (deletions != 0 or BASE bytes no longer a prefix): $(git diff --numstat -- "$DOC")"; finish 72; }
log "DOC_DELTA_POSTFORMAT $(git diff --numstat -- "$DOC" | cut -f1,2 | tr '\t' /) (pre-format $DOC_ADDED_LINES/0; additions may differ only by prettier reflow of Addendum B)"
# ---- 5 eslint on owned .ts/.cjs (repo config: no-unused-vars is warn, --max-warnings 0 makes it fatal)
STAGE=eslint
npx --no-install eslint --no-warn-ignored --max-warnings 0 $ESLINT_FILES > "$E/eslint.raw.log" 2>&1; rc=$?; log "ESLINT rc=$rc files=$(echo $ESLINT_FILES | wc -w)"; [ $rc = 0 ] || { tail -60 "$E/eslint.raw.log" >> "$LOG"; finish 74; }
# ---- 6 tsc (whole repo; tsconfig has no include so test/ is type-checked)
STAGE=tsc
npx --no-install tsc --noEmit > "$E/tsc.raw.log" 2>&1; rc=$?; log "TSC rc=$rc lines=$(wc -l < "$E/tsc.raw.log")"; [ $rc = 0 ] || { tail -60 "$E/tsc.raw.log" >> "$LOG"; finish 73; }
# ---- 7 R75 banned-cast checker: no working-tree mode at BASE (accepted S9-B d3a9 narrow fix); enforced at STAGE=stage + hook
STAGE=r75
log "R75_WORKTREE not run: scripts/check-r75.js at BASE has only --mode=staged|range (no worktree mode; S9B-GATE-2 rc=2). R75 is enforced by --mode=staged at STAGE=stage and by the pre-commit hook."
# ---- 8 contract: re-export must be byte-stable (the committed artifact is generator output, never hand-edited)
STAGE=contract
cp -p "$CONTRACT" "$E/importer-openapi.before.json"
timeout --foreground 900 npm run -s contract:importer > "$E/contract-gen.log" 2>&1; rc=$?
log "CONTRACT_GEN rc=$rc $(tail -1 "$E/contract-gen.log") sha256=$(sha "$CONTRACT")"
[ $rc = 0 ] || { tail -40 "$E/contract-gen.log" >> "$LOG"; finish 73; }
cmp -s "$CONTRACT" "$E/importer-openapi.before.json" && [ "$(sha "$CONTRACT")" = "$SHA_CONTRACT_JSON" ] || { cp -p "$CONTRACT" "$E/importer-openapi.after.json"; git diff --stat -- "$CONTRACT" >> "$LOG"; log "CONTRACT_DRIFT npm run contract:importer changed $CONTRACT (not regen-stable; after-copy preserved); refusing"; finish 73; }
[ "$(git status --porcelain --untracked-files=all | sort | tr '\n' '|')" = "$STATUS_EXPECT" ] || { log "SCOPE_FAIL status set changed by contract export: $(git status --porcelain | tr '\n' ' ')"; finish 73; }
log "CONTRACT_STABLE sha256=$SHA_CONTRACT_JSON"
./node_modules/.bin/jest --ci --runTestsByPath test/contracts/importer-contract.spec.ts > "$E/jest-contract.raw.log" 2>&1; rc=$?; log "JEST_CONTRACT rc=$rc"
grep -E '^(Tests|Test Suites):' "$E/jest-contract.raw.log" | tee -a "$LOG"
[ $rc = 0 ] || { grep -E '✕|●' "$E/jest-contract.raw.log" | head -60 >> "$LOG"; finish 73; }
[ "$(sha "$CONTRACT")" = "$SHA_CONTRACT_JSON" ] || { log "CONTRACT_DRIFT contract spec changed $CONTRACT"; finish 73; }
# ---- 9 jest targeted (default config, no PG), then the full default suite once
STAGE=jest
./node_modules/.bin/jest --ci --runTestsByPath $SUITES > "$E/jest.raw.log" 2>&1; rc=$?; log "JEST_TARGETED rc=$rc suites_expected=$N_SUITES"
grep -E '^(Tests|Test Suites|Snapshots|Time):' "$E/jest.raw.log" | tee -a "$LOG"
[ $rc = 0 ] || { grep -E '✕|●' "$E/jest.raw.log" | head -60 >> "$LOG"; finish 73; }
grep -qE "^Test Suites: +$N_SUITES passed, $N_SUITES total" "$E/jest.raw.log" || { log "JEST_TARGETED_COUNT_FAIL expected $N_SUITES suites passed"; finish 73; }
STAGE=jest_full
t0=$(date +%s); timeout --foreground 4200 ./node_modules/.bin/jest --ci > "$E/jest-full.raw.log" 2>&1; rc=$?; log "JEST_FULL rc=$rc secs=$(( $(date +%s)-t0 ))"
grep -E '^(Tests|Test Suites|Snapshots|Time):' "$E/jest-full.raw.log" | tee -a "$LOG"
[ $rc = 0 ] || { grep -E '✕|●' "$E/jest-full.raw.log" | head -60 >> "$LOG"; finish 73; }
[ "$(git status --porcelain --untracked-files=all | sort | tr '\n' '|')" = "$STATUS_EXPECT" ] || { log "SCOPE_FAIL status set changed by tests: $(git status --porcelain | tr '\n' ' ')"; finish 73; }
[ "$(sha "$CONTRACT")" = "$SHA_CONTRACT_JSON" ] || { log "CONTRACT_DRIFT tests changed $CONTRACT"; finish 73; }
# ---- 10 stage exactly the owned paths + R75 staged + one genuine hooked commit
STAGE=stage
git add -- $FILES
[ "$(git diff --cached --name-only | sort | tr '\n' ' ')" = "$STAGED_EXPECT" ] || { log "STAGED_SET_FAIL $(git diff --cached --name-only | tr '\n' ' ')"; finish 70; }
while read -r s m st p; do [ -n "${p:-}" ] || continue
  [ "$(git ls-files -s -- "$p" | cut -d' ' -f1)" = "100$m" ] || { log "STAGED_MODE_FAIL $p index mode $(git ls-files -s -- "$p" | cut -d' ' -f1) != 100$m"; finish 70; }
done <<< "$OWNED_PINS"
TREE=$(git write-tree); log "STAGED_TREE=$TREE"
for f in $FILES; do log "STAGED_BLOB $f $(git rev-parse ":$f")"; done
node scripts/check-r75.js --mode=staged > "$E/r75-staged.raw.log" 2>&1; rc=$?; log "R75_STAGED rc=$rc"; [ $rc = 0 ] || { tail -40 "$E/r75-staged.raw.log" >> "$LOG"; finish 74; }
STAGE=commit
git commit -F "$MSG" > "$E/commit-attempt-1.raw.log" 2>&1; rc=$?
tail -25 "$E/commit-attempt-1.raw.log" >> "$LOG"; log "GIT_COMMIT rc=$rc"; [ $rc = 0 ] || finish 76
HEAD=$(git rev-parse HEAD); HTREE=$(git rev-parse 'HEAD^{tree}')
log "HEAD=$HEAD TREE=$HTREE author=$(git log -1 --format='%an <%ae> / %cn <%ce> / %cI') parent=$(git rev-parse HEAD^)"
[ "$(git rev-parse HEAD^)" = "$H" ] && [ -z "$(git status --porcelain --untracked-files=all)" ] || { log "LINEAGE_FAIL"; finish 76; }
[ "$HTREE" = "$TREE" ] || { log "TREE_FAIL committed tree $HTREE != staged tree $TREE (hook modified the index?)"; finish 76; }
[ "$(git diff --name-only "$H" HEAD | sort | tr '\n' ' ')" = "$STAGED_EXPECT" ] || { log "DELTA_FAIL"; finish 76; }
FORB=$(git diff --name-only "$H" HEAD -- $FORBIDDEN_DELTA_PATHS $S9B_FILES $S9A_FILES | while read -r p; do case " $FORBIDDEN_EXCEPTIONS " in *" $p "*) ;; *) echo "$p";; esac; done)
[ -z "$FORB" ] || { log "DELTA_FAIL forbidden path in delta: $(echo $FORB)"; finish 76; }
[ "$(git diff --numstat "$H" HEAD -- "$DOC" | cut -f2)" = 0 ] && [ "$(git show "HEAD:$DOC" | head -c "$DOC_LANDED_BYTES" | sha256sum | cut -c1-64)" = "$SHA_DOC_LANDED" ] || { log "DELTA_FAIL committed doc is not BASE bytes + appended Addendum B"; finish 76; }
[ "$(git log -1 --format='%an <%ae>|%cn <%ce>')" = "Bradley Gleave <bradley@bradleytgpcoaching.com>|Bradley Gleave <bradley@bradleytgpcoaching.com>" ] || { log "IDENTITY_FAIL"; finish 76; }
git log -1 --format=%B HEAD > "$E/committed-message.txt"
grep -iqE 'co-authored-by|generated' "$E/committed-message.txt" && { log "TRAILER_FAIL"; finish 76; }
# ---- 11 receipts
STAGE=receipts
git diff --binary "$H" HEAD > "$E/s9c-${H:0:12}-to-${HEAD:0:12}.patch"
git diff --name-status "$H" HEAD > "$E/MANIFEST-name-status-${H:0:12}-to-${HEAD:0:12}.txt"
{ echo "base=$H"; echo "base_tree=$BASE_TREE"; echo "head=$HEAD"; echo "tree=$HTREE"; echo "doc_delta=$(git diff --numstat "$H" HEAD -- "$DOC" | cut -f1,2 | tr '\t' /)"
  for f in $FILES; do echo "blob $f $(git rev-parse HEAD:$f) sha256=$(sha "$f")"; done
  for f in $S9B_FILES $S9A_FILES; do echo "unchanged $f $(git rev-parse HEAD:$f) sha256=$(sha "$f")"; done
  echo "contract_regen_stable sha256=$SHA_CONTRACT_JSON"
  echo "branch=$(git rev-parse --abbrev-ref HEAD)"; git log -1 --format='author=%an <%ae>%ncommitter=%cn <%ce>%ndate=%cI'
  echo "hooks raw pre-commit=$HP commit-msg=$HC normalized pre-commit=$NP commit-msg=$NC ref_root=$HOOK_REF_ROOT lefthook=$LHV"
  echo "prettier=$V prefix=$B"; echo "donor=$DONOR hidden_lock=$NM_HIDDEN_LOCK client_index_dts=$CLIENT_INDEX_DTS"; echo "lock_inode=$CUR_INODE"; } > "$E/HEAD-${HEAD:0:12}.txt"
( cd "$E" && sha256sum * preformat/* postformat/* > SHA256SUMS ) 2>/dev/null
STAGE=done; log "DONE head=$HEAD tree=$HTREE (not pushed; parent owns landing; PG proof is a separate grant via ../binding/v1)"; finish 0
