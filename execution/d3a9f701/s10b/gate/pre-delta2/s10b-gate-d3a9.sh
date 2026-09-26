#!/usr/bin/env bash
# S10-B gate under the canonical slot — EXEC-D3A9F701 (S10-B run declaration + observation persistence; D-S10-8 S10-B row,
# docs/decisions/2026-09-26-s10-induction.md L355). SOURCE ONLY: NOT RUN, NOT GRANTED.
# Derived by substitution from the accepted S9-C gate d3a9f701/s9c/gate-3/s9c-gate-d3a9.sh. Differences:
#   - worktree /home/user/workspace/worktrees/d3a9-s10b, branch exec-d3a9/s10b, BASE = the S10-A landing commit (one commit
#     on S10A_PARENT = e6f20300 (the S9-C landing merge) adding exactly the 14 S10-A FREEZE paths, verified against FREEZE.sha256); BASE/BASE_TREE/MIGRATIONS_TREE
#     are __FILL__ pins (the parent moves the clone onto BASE first: README.md "Parent steps before relay")
#   - owned paths: PINS.env OWNED_PINS (1 ` M` prisma/schema.prisma + 15 `??`); no doc, no contract artifact
#   - S10-B changes the schema and adds ONE migration: BASE schema = 0eb41f9a (pure +63/-0 addition), BASE migrations 172
#     ending at S7-L, working tree 173 ending at the S10-B dir; the prisma delta is exactly schema + migration.sql + down.sql
#   - the donor client matches the OLD schema, so `prisma generate` ALWAYS runs, and only in the isolated copy:
#     `cp -a $DONOR $W/node_modules` (real dir, no symlink), then `$W/node_modules/.bin/prisma generate --schema
#     prisma/schema.prisma` from cwd $W, which writes $W/node_modules/.prisma/client (the @prisma/client in the copy is a real
#     directory inside $W, checked). The donor's .prisma tree signature and client shas are measured before the copy and
#     after the generate and must be unchanged; the in-lane client must carry the three S10-B models and differ from the donor
#   - contract: S10-B does not own OpenAPI bytes (S10-C regenerates). The re-export goes to a SCRATCH path
#     (IMPORTER_CONTRACT_OUT=$E/contract-regen.json, supported by scripts/export-importer-contract.ts) and must be
#     byte-identical to BASE's artifact; the canonical file stays byte-identical to BASE and is never in the delta
#   - lessons: (1) no `cmd | grep -q` pipelines under pipefail anywhere — outputs are captured, then grepped as here-strings
#     or files; (2) pre-existing .git/hooks/{pre-commit,commit-msg} refuse with rc 70 and a pointer to the documented
#     set-aside step (README.md); (3) commit-message.txt must exist in this dir; (4) R75 --mode=staged runs twice: early
#     (post-format bytes, index restored) and on the final staged set before the commit; (5) forced in-lane generate above
#   - targeted jest = the 5 S10-A specs + observation.{service,controller}.spec.ts, then the full default suite once
# Steps: relay+pins -> ALL pin/shape preconditions (pre-sentinel, read-only; refusals do not consume) -> sentinel -> lock
# (flock -n fd9, inode pinned + LOCK_ESTABLISHED.txt) -> re-verify HEAD/status/hooks/owned bytes -> cp -a donor ->
# forced in-lane prisma generate + donor-unchanged -> lefthook install (normalized hook shas) -> verified prettier prefix ->
# preformat copies -> prettier owned .ts/.cjs -> R75 early (staged, then index restored) -> eslint -> tsc -> contract
# no-change (scratch export + contract spec) -> jest targeted (7) -> jest full -> stage -> R75 staged -> one hooked Bradley
# commit -> receipts -> release. No push, no npm install, no PG. Any failure stops and is preserved; no rerun (STARTED).
# Usage (parent relay only; README.md has the pre-relay steps):
#   S10B_GATE_RELAY=1 S10B_BASE=<S10-A landing sha> \
#   S10B_DONOR=/home/user/workspace/worktrees/1910a060-s8f/node_modules \
#   S10B_PRETTIER_PREFIX=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 \
#   timeout -k 30 7200 bash /home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10b/gate/s10b-gate-d3a9.sh
# Fill help (read-only, no lock, no relay): bash .../s10b-gate-d3a9.sh --fill-help <S10-A landing sha>
set -uo pipefail
E=/home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10b/gate
W=/home/user/workspace/worktrees/d3a9-s10b
LOCK=/home/user/workspace/execution/test-validation.lock
LOCK_RECORD=/home/user/workspace/tgp-private-evidence/execution/d3a9f701/runtime/LOCK_ESTABLISHED.txt
PREFIX_MANIFEST=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256
LOG=$E/gate.log
# shellcheck source=PINS.env
. "$E/PINS.env" || { echo "REFUSED: cannot source $E/PINS.env" >&2; exit 78; }
S10B_MIG_DIR=prisma/migrations/$LAST_MIGRATION
REQUIRED_OWNED="prisma/schema.prisma $S10B_MIG_DIR/migration.sql $S10B_MIG_DIR/down.sql test/rls-g2-s10b.spec.ts test/utils/g2-s10b-bootstrap.sh test/utils/g2-s10b-db.ts test/utils/g2-s10b-harness.ts test/utils/g2-s10b-pg-harness.ts test/utils/g2-s10b-worker.cjs test/utils/g2-s10b-fixtures.ts"
ts(){ date -u +%FT%TZ; }
log(){ echo "$(ts) $*" | tee -a "$LOG"; }
sha(){ sha256sum "$1" | cut -c1-64; }
is40(){ [[ "$1" =~ ^[0-9a-f]{40}$ ]]; }
is64(){ [[ "$1" =~ ^[0-9a-f]{64}$ ]]; }
flat(){ echo "$1" | sed 's|/|__|g'; }
# ---- --fill-help: read-only git queries only (no lock, no sentinel, no writes). Prints the PINS.env lines to paste.
if [ "${1:-}" = --fill-help ]; then
  B_=${2:-}; is40 "$B_" || { echo "usage: $0 --fill-help <40-hex S10-A landing sha>  (git -C <landing clone> rev-parse HEAD after land-s10a.sh; or git ls-remote origin refs/heads/land/s10a)" >&2; exit 2; }
  export GIT_OPTIONAL_LOCKS=0
  git -C "$W" cat-file -e "$B_^{commit}" 2>/dev/null || { echo "BASE $B_ not in $W: git -C $W fetch origin refs/heads/land/s10a (or fetch from /home/user/workspace/worktrees/d3a9-s10a)" >&2; exit 3; }
  echo "BASE=$B_"; echo "BASE_TREE=$(git -C "$W" rev-parse "$B_^{tree}")"; echo "MIGRATIONS_TREE=$(git -C "$W" rev-parse "$B_:prisma/migrations")"
  echo "# checks: BASE^=$(git -C "$W" rev-parse "$B_^") (want $S10A_PARENT)  schema_blob=$(git -C "$W" rev-parse "$B_:prisma/schema.prisma") (want $BASE_SCHEMA_BLOB)  contract_blob=$(git -C "$W" rev-parse "$B_:$CONTRACT") (want $CONTRACT_BLOB)"
  echo "# delta $S10A_PARENT..BASE ($(git -C "$W" diff --name-only "$S10A_PARENT" "$B_" | wc -l) paths, want $S10A_FREEZE_COUNT):"
  while read -r _ s p; do [ -n "${p:-}" ] || continue; got=$(git -C "$W" show "$B_:$p" 2>/dev/null | sha256sum | cut -c1-64); [ "$got" = "$s" ] && echo "#   OK $p" || echo "#   MISMATCH $p committed=$got freeze=$s"; done < "$S10A_FREEZE"
  echo "# clone: HEAD=$(git -C "$W" rev-parse HEAD) branch=$(git -C "$W" rev-parse --abbrev-ref HEAD) hooks=[$(ls "$W/.git/hooks" 2>/dev/null | grep -v '\.sample$' | tr '\n' ' ')] node_modules=$( [ -e "$W/node_modules" ] && echo PRESENT || echo absent)"
  exit 0
fi
mkdir -p "$E"
# ---- 0 relay + one-shot sentinel (a refusal before ACQUIRED does not consume the grant)
[ "${S10B_GATE_RELAY:-}" = 1 ] || { echo "REFUSED: S10B_GATE_RELAY=1 (parent relay) not set" >&2; exit 78; }
[ -n "${S10B_DONOR:-}" ] && [ -d "$S10B_DONOR" ] || { echo "REFUSED: S10B_DONOR (node_modules donor dir) not set or absent" >&2; exit 78; }
[ -n "${S10B_PRETTIER_PREFIX:-}" ] && [ -d "$S10B_PRETTIER_PREFIX" ] || { echo "REFUSED: S10B_PRETTIER_PREFIX not set or absent" >&2; exit 78; }
is40 "$BASE" || { echo "REFUSED: PINS.env BASE is not a 40-hex sha ($BASE); run --fill-help" >&2; exit 78; }
[ -n "${S10B_BASE:-}" ] && [ "$S10B_BASE" = "$BASE" ] || { echo "REFUSED: S10B_BASE (${S10B_BASE:-unset}) must be relayed and equal PINS.env BASE=$BASE" >&2; exit 78; }
H=$BASE
for v in BASE_TREE MIGRATIONS_TREE S10A_PARENT HARNESS_BASE_HEAD BASE_SCHEMA_BLOB CONTRACT_BLOB; do is40 "${!v}" || { echo "REFUSED: PINS.env $v not 40-hex (${!v})" >&2; exit 78; }; done
for v in S10A_FREEZE_SHA BASE_SCHEMA_SHA PKG_LOCK_SHA PKG_JSON_SHA NM_HIDDEN_LOCK DONOR_CLIENT_INDEX_DTS DONOR_CLIENT_SCHEMA SHA_CONTRACT_JSON; do
  is64 "${!v}" || { echo "REFUSED: PINS.env $v is not a 64-hex sha256 (${!v})" >&2; exit 78; }
done
for v in CLIENT_INDEX_DTS CLIENT_SCHEMA; do [ "${!v}" = RECORD ] || is64 "${!v}" || { echo "REFUSED: PINS.env $v must be RECORD or 64-hex (${!v})" >&2; exit 78; }; done
for v in SCHEMA_ADDED_LINES BASE_MIGRATION_DIRS MIGRATION_DIRS S10A_FREEZE_COUNT LOCK_INODE; do [[ "${!v}" =~ ^[1-9][0-9]*$ ]] || { echo "REFUSED: PINS.env $v not a positive integer" >&2; exit 78; }; done
[ "$MIGRATION_DIRS" = $((BASE_MIGRATION_DIRS + 1)) ] || { echo "REFUSED: MIGRATION_DIRS must be BASE_MIGRATION_DIRS + 1" >&2; exit 78; }
# HARNESS_BASE_HEAD (harness BASE_HEAD literal, a4af8e33) is kept as an ANCESTOR of BASE; checked with git merge-base --is-ancestor before the lock (review B2)
[ -f "$S10A_FREEZE" ] && [ "$(sha "$S10A_FREEZE")" = "$S10A_FREEZE_SHA" ] || { echo "REFUSED: S10-A FREEZE $S10A_FREEZE absent or sha != $S10A_FREEZE_SHA" >&2; exit 78; }
S10A_FILES=$(awk '$1=="POST"{print $3}' "$S10A_FREEZE" | tr '\n' ' ')
[ "$(echo $S10A_FILES | wc -w)" = "$S10A_FREEZE_COUNT" ] || { echo "REFUSED: FREEZE lists $(echo $S10A_FILES | wc -w) paths, want $S10A_FREEZE_COUNT" >&2; exit 78; }
# OWNED_PINS: every sha filled, mode 644/755, state M/N, no duplicates, required S10-B paths present, nothing forbidden
MOD_FILES=""; NEW_FILES=""
while read -r s m st p; do [ -n "${p:-}" ] || continue
  is64 "$s" || { echo "REFUSED: PINS.env OWNED_PINS sha for $p not filled ($s)" >&2; exit 78; }
  case "$m" in 644|755) ;; *) echo "REFUSED: PINS.env OWNED_PINS mode for $p ($m)" >&2; exit 78;; esac
  case "$st" in M) MOD_FILES="$MOD_FILES $p";; N) NEW_FILES="$NEW_FILES $p";; *) echo "REFUSED: PINS.env OWNED_PINS state for $p ($st; M or N)" >&2; exit 78;; esac
done <<< "$OWNED_PINS"
DUPS=$(printf '%s\n' $MOD_FILES $NEW_FILES | sort | uniq -d)
[ -z "$DUPS" ] || { echo "REFUSED: PINS.env OWNED_PINS has duplicate paths: $DUPS" >&2; exit 78; }
for p in $REQUIRED_OWNED; do case " $MOD_FILES $NEW_FILES " in *" $p "*) ;; *) echo "REFUSED: PINS.env OWNED_PINS lacks required S10-B path $p" >&2; exit 78;; esac; done
for p in $MOD_FILES $NEW_FILES; do
  for fp in $FORBIDDEN_DELTA_PATHS $S10A_FILES $CONTRACT; do case "$p" in "$fp"|"$fp"/*) echo "REFUSED: owned $p is under forbidden $fp" >&2; exit 78;; esac; done
  case "$p" in prisma/*) case "$p" in prisma/schema.prisma|"$S10B_MIG_DIR/migration.sql"|"$S10B_MIG_DIR/down.sql") ;; *) echo "REFUSED: owned prisma path $p is not schema/migration.sql/down.sql" >&2; exit 78;; esac;; esac
done
[ -n "$SUITES" ] || { echo "REFUSED: PINS.env SUITES empty" >&2; exit 78; }
for s in $SUITES; do [ -f "$W/$s" ] || { echo "REFUSED: suite $s absent in $W (S10-A specs arrive with BASE)" >&2; exit 78; }; done
DONOR=$S10B_DONOR; B=$S10B_PRETTIER_PREFIX
FILES="$MOD_FILES $NEW_FILES"; MSG=$E/commit-message.txt
# prettier: owned .ts/.cjs only (the lefthook prettier glob never includes .prisma/.sql/.sh; prisma/migrations is .prettierignored)
PRETTIER_FILES=$(for f in $FILES; do case "$f" in *.ts|*.cjs) printf '%s ' "$f";; esac; done)
ESLINT_FILES=$PRETTIER_FILES
NOFMT_FILES=$(for f in $FILES; do case "$f" in *.ts|*.cjs) ;; *) printf '%s ' "$f";; esac; done)
STAGED_EXPECT=$(printf '%s\n' $FILES | sort | tr '\n' ' ')
STATUS_EXPECT=$( { for f in $MOD_FILES; do echo " M $f"; done; for f in $NEW_FILES; do echo "?? $f"; done; } | sort | tr '\n' '|')
N_SUITES=$(echo $SUITES | wc -w)
[ -f "$MSG" ] && [ -s "$MSG" ] || { echo "REFUSED: commit message $MSG absent or empty" >&2; exit 78; }
MSGTXT=$(cat "$MSG")
! grep -iqE 'claude|anthropic|openai|gpt[- ]|computer[- ]agent|perplexity|co-authored[- ]by|signed-off-by|generated with|🤖|ai assist|\b(ai|agent)\b' <<<"$MSGTXT" || { echo "REFUSED: commit-message.txt carries a banned token or trailer" >&2; exit 78; }
# ---- preconditions run BEFORE the sentinel and the lock (review B1): every pin/shape refusal here exits without writing
# STARTED or TERMINAL, so a stale pin never consumes the one-shot grant. finish() is redefined after ACQUIRED.
STAGE=preflight-prelock
LOG=$E/prelock.log; export GIT_OPTIONAL_LOCKS=0   # pre-lock: own log (gate.log stays the run log), no optional git index writes
[ ! -e "$E/STARTED" ] || { echo "REFUSED: $E/STARTED exists; this gate is one-shot, do not loop" >&2; exit 76; }   # early (re-checked before the lock)
finish(){ log "REFUSED_PRELOCK stage=$STAGE rc=$1 (no lock taken, STARTED not written; the grant is not consumed)"; exit "$1"; }
export NODE_OPTIONS=--max-old-space-size=4096 npm_config_offline=true npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false \
       PRISMA_HIDE_UPDATE_MESSAGE=1 CHECKPOINT_DISABLE=1 PRISMA_GENERATE_SKIP_AUTOINSTALL=1
export GIT_AUTHOR_NAME="Bradley Gleave" GIT_AUTHOR_EMAIL=bradley@bradleytgpcoaching.com GIT_COMMITTER_NAME="Bradley Gleave" GIT_COMMITTER_EMAIL=bradley@bradleytgpcoaching.com
log "node=$(node --version) npm=$(npm --version)"
cd "$W" || finish 70
st_now(){ git status --porcelain --untracked-files=all | sort | tr '\n' '|'; }
[ "$(git rev-parse HEAD)" = "$H" ] || { log "PRECONDITION_FAIL HEAD $(git rev-parse HEAD) != BASE $H (move the clone onto BASE first: README.md)"; finish 70; }
[ "$(git rev-parse 'HEAD^{tree}')" = "$BASE_TREE" ] || { log "PRECONDITION_FAIL BASE tree $(git rev-parse 'HEAD^{tree}') != $BASE_TREE"; finish 70; }
[ "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH" ] || { log "PRECONDITION_FAIL branch != $BRANCH"; finish 70; }
[ "$(git rev-parse HEAD^)" = "$S10A_PARENT" ] || { log "PRECONDITION_FAIL BASE^ $(git rev-parse HEAD^) != $S10A_PARENT (S10-A must be ONE commit on $S10A_PARENT)"; finish 70; }
git merge-base --is-ancestor "$HARNESS_BASE_HEAD" "$BASE" || { log "PRECONDITION_FAIL harness base $HARNESS_BASE_HEAD is not an ancestor of BASE $BASE"; finish 78; }
git merge-base --is-ancestor "$HARNESS_BASE_HEAD" "$S10A_PARENT" || { log "PRECONDITION_FAIL harness base $HARNESS_BASE_HEAD is not an ancestor of S10A_PARENT $S10A_PARENT"; finish 78; }
[ -z "$(git config --get core.hooksPath)" ] || { log "PRECONDITION_FAIL core.hooksPath set"; finish 70; }
[ -z "$(git diff --cached --name-only)" ] || { log "PRECONDITION_FAIL index not clean vs HEAD (staged or intent-to-add entries): $(git diff --cached --name-only | tr '\n' ' ')"; finish 70; }
[ ! -e "$(git rev-parse --git-path MERGE_HEAD)" ] || { log "PRECONDITION_FAIL MERGE_HEAD present"; finish 70; }
STATUS_NOW=$(st_now)
[ "$STATUS_NOW" = "$STATUS_EXPECT" ] || { log "PRECONDITION_FAIL status set: [$STATUS_NOW] expected [$STATUS_EXPECT]"; finish 70; }
chk(){ [ "$(sha "$1")" = "$2" ] || { log "PRECONDITION_FAIL $1 sha $(sha "$1") != $2"; finish 70; }; }
while read -r s m st p; do [ -n "${p:-}" ] || continue
  chk "$p" "$s"
  [ "$(stat -c %a "$p")" = "$m" ] || { log "PRECONDITION_FAIL $p mode $(stat -c %a "$p") != $m"; finish 70; }
done <<< "$OWNED_PINS"
# S10-A at BASE: exactly the 14 FREEZE paths over S10A_PARENT, tracked, committed bytes = FREEZE, clean in the working tree
S10A_DELTA=$(git diff --name-only "$S10A_PARENT" HEAD | sort | tr '\n' ' ')
[ "$S10A_DELTA" = "$(printf '%s\n' $S10A_FILES | sort | tr '\n' ' ')" ] || { log "PRECONDITION_FAIL $S10A_PARENT..BASE delta [$S10A_DELTA] != the $S10A_FREEZE_COUNT FREEZE paths"; finish 70; }
while read -r tag s p; do [ "$tag" = POST ] || continue
  git ls-files --error-unmatch "$p" > /dev/null 2>&1 || { log "PRECONDITION_FAIL S10-A $p not tracked at BASE"; finish 70; }
  [ "$(git show "HEAD:$p" | sha256sum | cut -c1-64)" = "$s" ] || { log "PRECONDITION_FAIL S10-A $p committed bytes != FREEZE $s"; finish 70; }
  chk "$p" "$s"
done < "$S10A_FREEZE"
[ -z "$(git status --porcelain -- $S10A_FILES)" ] || { log "PRECONDITION_FAIL S10-A files modified in working tree"; finish 70; }
[ ! -e node_modules ] && [ ! -L node_modules ] || { log "PRECONDITION_FAIL node_modules already present (parent must set the clone's copy aside first: README.md)"; finish 70; }
# schema: BASE bytes pinned; the working schema is BASE + a pure addition of SCHEMA_ADDED_LINES lines
[ "$(git rev-parse "HEAD:prisma/schema.prisma")" = "$BASE_SCHEMA_BLOB" ] && [ "$(git show HEAD:prisma/schema.prisma | sha256sum | cut -c1-64)" = "$BASE_SCHEMA_SHA" ] || { log "PRECONDITION_FAIL schema at BASE != $BASE_SCHEMA_BLOB / $BASE_SCHEMA_SHA"; finish 70; }
[ "$(git diff --numstat -- prisma/schema.prisma | cut -f1,2)" = "$(printf '%s\t0' "$SCHEMA_ADDED_LINES")" ] || { log "PRECONDITION_FAIL schema delta is not +$SCHEMA_ADDED_LINES/-0: $(git diff --numstat -- prisma/schema.prisma)"; finish 70; }
SCHEMA_NOW=$(cat prisma/schema.prisma)
for m_ in $S10B_MODELS; do grep -qE "^model $m_ \{" <<<"$SCHEMA_NOW" || { log "PRECONDITION_FAIL working schema lacks model $m_"; finish 70; }; done
chk package-lock.json "$PKG_LOCK_SHA"; chk package.json "$PKG_JSON_SHA"
[ -z "$(git status --porcelain --untracked-files=all -- package.json package-lock.json)" ] || { log "PRECONDITION_FAIL package manifests dirty"; finish 70; }
PRISMA_ST=$(git status --porcelain --untracked-files=all -- prisma | sort | tr '\n' '|')
[ "$PRISMA_ST" = "$(printf '%s\n' " M prisma/schema.prisma" "?? $S10B_MIG_DIR/down.sql" "?? $S10B_MIG_DIR/migration.sql" | sort | tr '\n' '|')" ] || { log "PRECONDITION_FAIL prisma status [$PRISMA_ST] != schema M + the S10-B migration.sql/down.sql"; finish 70; }
# migrations: BASE 172 ending at S7-L (tree pinned); working tree 173 ending at the S10-B dir
[ "$(git rev-parse HEAD:prisma/migrations)" = "$MIGRATIONS_TREE" ] || { log "PRECONDITION_FAIL prisma/migrations tree at BASE != $MIGRATIONS_TREE"; finish 70; }
BMIG=$(git ls-tree -d --name-only HEAD prisma/migrations/ | sed 's|^prisma/migrations/||' | sort)
[ "$(wc -l <<<"$BMIG")" = "$BASE_MIGRATION_DIRS" ] && [ "$(tail -1 <<<"$BMIG")" = "$BASE_LAST_MIGRATION" ] || { log "PRECONDITION_FAIL BASE migrations $(wc -l <<<"$BMIG")/$(tail -1 <<<"$BMIG") != $BASE_MIGRATION_DIRS/$BASE_LAST_MIGRATION"; finish 70; }
WMIG=$(find prisma/migrations -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
[ "$(wc -l <<<"$WMIG")" = "$MIGRATION_DIRS" ] && [ "$(tail -1 <<<"$WMIG")" = "$LAST_MIGRATION" ] || { log "PRECONDITION_FAIL working migrations $(wc -l <<<"$WMIG")/$(tail -1 <<<"$WMIG") != $MIGRATION_DIRS/$LAST_MIGRATION"; finish 70; }
[ "$(comm -13 <(echo "$BMIG") <(echo "$WMIG"))" = "$LAST_MIGRATION" ] && [ -z "$(comm -23 <(echo "$BMIG") <(echo "$WMIG"))" ] || { log "PRECONDITION_FAIL working migrations are not BASE + exactly $LAST_MIGRATION"; finish 70; }
[ "$(ls -A "$S10B_MIG_DIR" | sort | tr '\n' ' ')" = "down.sql migration.sql " ] || { log "PRECONDITION_FAIL $S10B_MIG_DIR must hold exactly migration.sql + down.sql"; finish 70; }
# harness literals (working bytes; the binding re-checks the committed bytes): 173, S10-B dir, base pin
BOOT=$(cat test/utils/g2-s10b-bootstrap.sh); PGH=$(cat test/utils/g2-s10b-pg-harness.ts); DBTS=$(cat test/utils/g2-s10b-db.ts)
grep -qx "EXPECTED_MIGRATIONS=$MIGRATION_DIRS" <<<"$BOOT" && grep -qx "S10B_MIGRATION=$LAST_MIGRATION" <<<"$BOOT" && grep -qx "S7L_MIGRATION=$BASE_LAST_MIGRATION" <<<"$BOOT" \
  && grep -qx "BASE_HEAD=$HARNESS_BASE_HEAD" <<<"$BOOT" || { log "PRECONDITION_FAIL g2-s10b-bootstrap.sh constants != pins"; finish 70; }
grep -qF "export const EXPECTED_MIGRATIONS = $MIGRATION_DIRS;" <<<"$PGH" && grep -qF "export const S10B_MIGRATION = '$LAST_MIGRATION';" <<<"$PGH" || { log "PRECONDITION_FAIL g2-s10b-pg-harness.ts constants != pins"; finish 70; }
grep -qF "G2_S10B_BASE_HEAD = '$HARNESS_BASE_HEAD'" <<<"$DBTS" || { log "PRECONDITION_FAIL g2-s10b-db.ts G2_S10B_BASE_HEAD != $HARNESS_BASE_HEAD"; finish 70; }
# contract: not owned; BASE blob pinned; working file = BASE bytes
[ "$(git rev-parse "HEAD:$CONTRACT")" = "$CONTRACT_BLOB" ] && [ "$(sha "$CONTRACT")" = "$SHA_CONTRACT_JSON" ] || { log "PRECONDITION_FAIL $CONTRACT at BASE/working != $CONTRACT_BLOB / $SHA_CONTRACT_JSON"; finish 70; }
# hooks: pre-existing hooks are a refusal, never overwritten (lesson 2). Set-aside is a PARENT step, README.md.
# symlink-aware (review A B-1): an occupied path is refused whether it is a file, a directory or a symlink (dangling or not);
# the hooks dir itself must be the plain .git/hooks directory of this clone.
[ "$(git rev-parse --git-path hooks)" = .git/hooks ] && [ -d .git/hooks ] && [ ! -L .git/hooks ] || { log "PRECONDITION_FAIL hooks dir is not the plain .git/hooks directory ($(git rev-parse --git-path hooks))"; finish 70; }
for hk in pre-commit commit-msg; do hp=.git/hooks/$hk; if [ -e "$hp" ] || [ -L "$hp" ]; then
  if [ -L "$hp" ]; then what="symlink -> $(readlink "$hp")"; elif [ -f "$hp" ]; then what="file sha256 $(sha "$hp")"; else what="non-regular path"; fi
  log "PRECONDITION_FAIL $hp already occupied ($what); parent must set it aside per README.md 'Hook set-aside' and relay again"; finish 70; fi; done
bash -n test/utils/g2-s10b-bootstrap.sh || { log "PRECONDITION_FAIL bootstrap.sh syntax"; finish 70; }
node --check test/utils/g2-s10b-worker.cjs || { log "PRECONDITION_FAIL worker.cjs syntax"; finish 70; }
log "PRECONDITIONS_OK (pre-lock) base=$H base_parent=$S10A_PARENT harness_base=$HARNESS_BASE_HEAD"
LOG=$E/gate.log; unset GIT_OPTIONAL_LOCKS
[ ! -e "$E/STARTED" ] || { echo "REFUSED: $E/STARTED exists; this gate is one-shot, do not loop" >&2; exit 76; }
# ---- lock: existing canonical file, recorded inode (PINS.env and LOCK_ESTABLISHED.txt must agree), nonblocking flock here
[ -e "$LOCK" ] || { log "REFUSED lock file absent"; exit 75; }
REC_INODE=$(sed -n 's/.*inode=\([0-9]*\).*/\1/p' "$LOCK_RECORD" | head -1)
CUR_INODE=$(stat -c %i "$LOCK")
[ -n "$REC_INODE" ] && [ "$CUR_INODE" = "$REC_INODE" ] && [ "$CUR_INODE" = "$LOCK_INODE" ] || { log "REFUSED lock inode $CUR_INODE != recorded $REC_INODE / pinned $LOCK_INODE"; exit 75; }
exec 9>>"$LOCK"; flock -n 9 || { log "REFUSED canonical lock busy (live holder); not waiting, not stealing"; exit 75; }
date -u +%FT%TZ > "$E/STARTED"
LSL=$(lslocks 2>/dev/null); log "ACQUIRED pid=$$ fd9 inode=$CUR_INODE lslocks=$(grep -c test-validation <<<"$LSL") donor=$DONOR prefix=$B base=$H"
STAGE=preflight
finish(){ unset npm_config_prefix; log "RELEASING stage=$STAGE rc=$1 (fd9 closes at exit; lock file preserved)"; printf 'RC=%s STAGE=%s END=%s\n' "$1" "$STAGE" "$(ts)" > "$E/TERMINAL"; exit "$1"; }
# re-verify, under the lock, the state that could have moved between the pre-lock checks and ACQUIRED
[ "$(git rev-parse HEAD)" = "$H" ] && [ "$(st_now)" = "$STATUS_EXPECT" ] && [ -z "$(git diff --cached --name-only)" ] || { log "PRECONDITION_FAIL HEAD/status/index moved after the pre-lock checks"; finish 70; }
for hk in pre-commit commit-msg; do { [ -e ".git/hooks/$hk" ] || [ -L ".git/hooks/$hk" ]; } && { log "PRECONDITION_FAIL .git/hooks/$hk appeared after the pre-lock checks"; finish 70; }; done
[ ! -e node_modules ] && [ ! -L node_modules ] || { log "PRECONDITION_FAIL node_modules appeared after the pre-lock checks"; finish 70; }
while read -r s m st p; do [ -n "${p:-}" ] || continue; chk "$p" "$s"; done <<< "$OWNED_PINS"
HEAVY=$(pgrep -af "jest|tsc|prisma|postgres|prettier|lefthook|eslint" | grep -v -e "^$$ " -e s10b-gate || true)
[ -z "$HEAVY" ] || { printf '%s\n' "$HEAVY" >> "$LOG"; log "WARN other heavy processes present (recorded)"; }
# ---- 1 node_modules: isolated real copy of the relayed donor (donor is read-only here)
STAGE=node_modules
DONOR_REPO=$(dirname "$DONOR")
dsig(){ find "$DONOR/.prisma" "$DONOR/@prisma/client" -printf '%P %s %T@ %m\n' 2>/dev/null | sort | sha256sum | cut -c1-64; }
D_IDX0=$(sha "$DONOR/.prisma/client/index.d.ts" 2>/dev/null || echo absent); D_SCH0=$(sha "$DONOR/.prisma/client/schema.prisma" 2>/dev/null || echo absent); D_SIG0=$(dsig)
log "DONOR_HEAD=$(git -C "$DONOR_REPO" rev-parse HEAD 2>/dev/null || echo n/a) DONOR_HIDDEN_LOCK=$(sha "$DONOR/.package-lock.json" 2>/dev/null || echo absent) DONOR_CLIENT_INDEX_DTS=$D_IDX0 DONOR_CLIENT_SCHEMA=$D_SCH0 DONOR_PRISMA_SIG=$D_SIG0 DONOR_ENTRIES=$(ls "$DONOR" | wc -l)"
[ "$(sha "$DONOR/.package-lock.json")" = "$NM_HIDDEN_LOCK" ] || { log "PRECONDITION_FAIL donor hidden lock != $NM_HIDDEN_LOCK"; finish 71; }
[ "$D_IDX0" = "$DONOR_CLIENT_INDEX_DTS" ] && [ "$D_SCH0" = "$DONOR_CLIENT_SCHEMA" ] || { log "PRECONDITION_FAIL donor client != pinned pre-S10-B client ($DONOR_CLIENT_INDEX_DTS / $DONOR_CLIENT_SCHEMA); not the expected donor"; finish 71; }
t0=$(date +%s); cp -a "$DONOR" node_modules; rc=$?
log "CP_A rc=$rc secs=$(( $(date +%s)-t0 )) NM_ENTRIES=$(ls node_modules | wc -l) NM_HIDDEN_LOCK=$(sha node_modules/.package-lock.json 2>/dev/null || echo absent) df_avail=$(df -Pk . | awk 'NR==2{print $4}')K"
[ $rc = 0 ] || finish 71
[ -d node_modules ] && [ ! -L node_modules ] || { log "PRECONDITION_FAIL node_modules is not a real directory"; finish 71; }
[ "$(sha node_modules/.package-lock.json)" = "$NM_HIDDEN_LOCK" ] || { log "PRECONDITION_FAIL copied hidden lock"; finish 71; }
# the generate target must resolve inside $W: @prisma/client, .prisma and prisma are real dirs in the copy, not links to the donor
for d in node_modules/@prisma/client node_modules/.prisma node_modules/.prisma/client node_modules/prisma; do
  [ -d "$d" ] && [ ! -L "$d" ] || { log "PRECONDITION_FAIL $d missing or a symlink"; finish 71; }
  case "$(readlink -f "$d")" in "$W"/*) ;; *) log "PRECONDITION_FAIL $d resolves outside $W"; finish 71;; esac
done
ABS_LINKS=$(find node_modules/.prisma node_modules/@prisma node_modules/prisma -type l -lname '/*' 2>/dev/null)
[ -z "$ABS_LINKS" ] || { log "PRECONDITION_FAIL absolute symlinks in the copied prisma tree: $(echo $ABS_LINKS)"; finish 71; }
PV=$(./node_modules/.bin/prisma --version 2>/dev/null); PV=$(awk '/^prisma /{print $3}' <<<"$PV")
[ "$PV" = "$PRISMA_EXPECT" ] || { log "PRECONDITION_FAIL prisma CLI $PV != $PRISMA_EXPECT"; finish 71; }
# ---- 1b forced in-lane prisma generate (lesson 5): the donor client is the pre-S10-B client; tsc/jest need the three models
STAGE=prisma_generate
timeout --foreground 600 ./node_modules/.bin/prisma generate --schema prisma/schema.prisma > "$E/prisma-generate.log" 2>&1; rc=$?
log "PRISMA_GENERATE_INLANE rc=$rc cwd=$W cli=$W/node_modules/.bin/prisma out=$W/node_modules/.prisma/client (never the donor)"; [ $rc = 0 ] || { tail -30 "$E/prisma-generate.log" >> "$LOG"; finish 71; }
D_IDX1=$(sha "$DONOR/.prisma/client/index.d.ts" 2>/dev/null || echo absent); D_SCH1=$(sha "$DONOR/.prisma/client/schema.prisma" 2>/dev/null || echo absent); D_SIG1=$(dsig)
[ "$D_IDX1" = "$D_IDX0" ] && [ "$D_SCH1" = "$D_SCH0" ] && [ "$D_SIG1" = "$D_SIG0" ] || { log "DONOR_CHANGED donor .prisma/@prisma/client changed during the gate (index $D_IDX0->$D_IDX1 schema $D_SCH0->$D_SCH1 sig $D_SIG0->$D_SIG1); refusing"; finish 71; }
log "DONOR_UNCHANGED index=$D_IDX1 schema=$D_SCH1 sig=$D_SIG1"
[ "$(st_now)" = "$STATUS_EXPECT" ] || { log "PRECONDITION_FAIL prisma generate changed the status set"; finish 71; }
NM_IDX=$(sha node_modules/.prisma/client/index.d.ts 2>/dev/null || echo absent); NM_SCH=$(sha node_modules/.prisma/client/schema.prisma 2>/dev/null || echo absent)
ENGINE=libquery_engine-debian-openssl-3.0.x.so.node
NM_ENG=$(sha "node_modules/.prisma/client/$ENGINE" 2>/dev/null || echo absent); PIN_ENG=$(sha "node_modules/@prisma/engines/$ENGINE" 2>/dev/null || echo absent)
log "NM_CLIENT_INDEX_DTS=$NM_IDX NM_CLIENT_SCHEMA=$NM_SCH NM_CLIENT_ENGINE=$NM_ENG PINNED_ENGINE=$PIN_ENG"
[ "$NM_IDX" != absent ] && [ "$NM_IDX" != "$DONOR_CLIENT_INDEX_DTS" ] || { log "PRECONDITION_FAIL in-lane client index.d.ts absent or still the donor's pre-S10-B client"; finish 71; }
[ "$NM_ENG" = "$PIN_ENG" ] && [ "$NM_ENG" != absent ] || { log "PRECONDITION_FAIL in-lane client engine != pinned @prisma/engines copy"; finish 71; }
CSCH=$(cat node_modules/.prisma/client/schema.prisma 2>/dev/null)
for m_ in $S10B_MODELS; do grep -qE "^model $m_ \{" <<<"$CSCH" || { log "PRECONDITION_FAIL in-lane client schema lacks model $m_"; finish 71; }; done
[ "$CLIENT_INDEX_DTS" = RECORD ] || [ "$NM_IDX" = "$CLIENT_INDEX_DTS" ] || { log "PRECONDITION_FAIL in-lane client index.d.ts != pinned $CLIENT_INDEX_DTS"; finish 71; }
[ "$CLIENT_SCHEMA" = RECORD ] || [ "$NM_SCH" = "$CLIENT_SCHEMA" ] || { log "PRECONDITION_FAIL in-lane client schema.prisma != pinned $CLIENT_SCHEMA"; finish 71; }
log "POSTGEN_CLIENT index_dts=$NM_IDX schema=$NM_SCH (binding EXPECT_NM_CLIENT_SHA = index_dts)"
[ ! -e node_modules/.bin/prettier ] || { log "PRECONDITION_FAIL prettier inside product tree"; finish 71; }
for b in tsc jest eslint lefthook ts-node prisma; do [ -x node_modules/.bin/$b ] || { log "PRECONDITION_FAIL node_modules/.bin/$b missing"; finish 71; }; done
# ---- 2 genuine hooks into THIS clone (lefthook from the copied node_modules; nothing shared)
STAGE=hooks
npx --no-install lefthook install > "$E/lefthook-install.log" 2>&1; rc=$?; log "LEFTHOOK_INSTALL rc=$rc"; [ $rc = 0 ] || finish 71
for hk in pre-commit commit-msg; do [ -x ".git/hooks/$hk" ] || { log "HOOK_FAIL .git/hooks/$hk missing or not executable"; finish 71; }; done
LHV=$(./node_modules/.bin/lefthook version 2>&1); LHV=$(head -1 <<<"$LHV" | tr -d '[:space:]'); log "LEFTHOOK_VERSION_CHECK=$LHV expect=$LEFTHOOK_EXPECT"
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
# ---- 4 preformat copies of EVERY owned path (before any write), then prettier on owned .ts/.cjs only
STAGE=preformat
mkdir -p "$E/preformat"
for f in $FILES; do cp -p "$f" "$E/preformat/$(flat "$f")" || { log "PREFORMAT_COPY_FAIL $f"; finish 72; }; log "PREFORMAT $f sha256=$(sha "$f") lines=$(wc -l < "$f")"; done
STAGE=prettier
log "PRETTIER_FILES=$PRETTIER_FILES"
npx --no-install prettier --check $PRETTIER_FILES > "$E/prettier-check-1.log" 2>&1; rc=$?; log "PRETTIER_CHECK_1 rc=$rc"
if [ $rc != 0 ]; then
  TOFIX=$(sed -n 's/^\[warn\] //p' "$E/prettier-check-1.log" | grep -v -e 'Code style issues' -e 'Run Prettier' || true)
  log "PRETTIER_TOFIX=$(echo $TOFIX)"
  [ -n "$TOFIX" ] || { log "PRETTIER_FAIL check failed without a [warn] list (parser/config error):"; tail -20 "$E/prettier-check-1.log" >> "$LOG"; finish 72; }
  for f in $TOFIX; do case " $PRETTIER_FILES " in *" $f "*) ;; *) log "PRETTIER_SCOPE_FAIL $f not in owned prettier set"; finish 72;; esac; done
  npx --no-install prettier --write $TOFIX > "$E/prettier-write-1.log" 2>&1 || { log "PRETTIER_WRITE_FAIL"; finish 72; }
  npx --no-install prettier --check $PRETTIER_FILES > "$E/prettier-check-2.log" 2>&1; rc=$?; log "PRETTIER_CHECK_2 rc=$rc"; [ $rc = 0 ] || finish 72
fi
mkdir -p "$E/postformat"
for f in $FILES; do log "POSTFORMAT $f sha256=$(sha "$f") lines=$(wc -l < "$f")"; cp -p "$f" "$E/postformat/$(flat "$f")"; done
[ "$(st_now)" = "$STATUS_EXPECT" ] || { log "SCOPE_FAIL status set changed by formatting: $(git status --porcelain | tr '\n' ' ')"; finish 72; }
for f in $NOFMT_FILES; do [ "$(sha "$f")" = "$(printf '%s\n' "$OWNED_PINS" | awk -v p="$f" '$4==p{print $1}')" ] || { log "SCOPE_FAIL non-prettier owned file $f changed during formatting"; finish 72; }; done
[ "$(sha "$CONTRACT")" = "$SHA_CONTRACT_JSON" ] || { log "SCOPE_FAIL contract artifact changed during formatting"; finish 72; }
# ---- 4b R75 early on the post-format bytes (lesson 4: gate-1 of S9-C lost a full jest run to a late R75 stop).
#      Stage the owned set, run the staged checker, then restore the index to BASE (status set re-verified).
STAGE=r75_early
git add -- $FILES || { log "R75_EARLY stage failed"; git reset -q; finish 74; }
node scripts/check-r75.js --mode=staged > "$E/r75-early.raw.log" 2>&1; rc=$?
git reset -q || { log "R75_EARLY index restore failed"; finish 74; }
log "R75_EARLY rc=$rc (index restored)"; [ $rc = 0 ] || { tail -40 "$E/r75-early.raw.log" >> "$LOG"; finish 74; }
[ -z "$(git diff --cached --name-only)" ] && [ "$(st_now)" = "$STATUS_EXPECT" ] || { log "SCOPE_FAIL index/status not restored after R75 early"; finish 74; }
# ---- 5 eslint on owned .ts/.cjs (repo config: --max-warnings 0)
STAGE=eslint
npx --no-install eslint --no-warn-ignored --max-warnings 0 $ESLINT_FILES > "$E/eslint.raw.log" 2>&1; rc=$?; log "ESLINT rc=$rc files=$(echo $ESLINT_FILES | wc -w)"; [ $rc = 0 ] || { tail -60 "$E/eslint.raw.log" >> "$LOG"; finish 74; }
# ---- 6 tsc (whole repo, against the in-lane regenerated client)
STAGE=tsc
npx --no-install tsc --noEmit > "$E/tsc.raw.log" 2>&1; rc=$?; log "TSC rc=$rc lines=$(wc -l < "$E/tsc.raw.log")"; [ $rc = 0 ] || { tail -60 "$E/tsc.raw.log" >> "$LOG"; finish 73; }
# ---- 7 contract NO-change (D-S10-8: OpenAPI bytes are not S10-B's; S10-C regenerates). Scratch export, canonical untouched.
STAGE=contract
git show "HEAD:$CONTRACT" > "$E/importer-openapi.base.json"
IMPORTER_CONTRACT_OUT="$E/contract-regen.json" timeout --foreground 900 npm run -s contract:importer > "$E/contract-gen.log" 2>&1; rc=$?
log "CONTRACT_GEN rc=$rc out=$E/contract-regen.json sha256=$(sha "$E/contract-regen.json" 2>/dev/null || echo absent)"
[ $rc = 0 ] || { tail -40 "$E/contract-gen.log" >> "$LOG"; finish 73; }
cmp -s "$E/contract-regen.json" "$E/importer-openapi.base.json" || { log "CONTRACT_CHANGE the S10-B tree regenerates a different importer contract than BASE (S10-B must not change routes in the contract; scratch copy preserved); refusing"; finish 73; }
[ "$(sha "$CONTRACT")" = "$SHA_CONTRACT_JSON" ] && [ -z "$(git status --porcelain -- "$CONTRACT")" ] || { log "CONTRACT_DRIFT canonical $CONTRACT touched"; finish 73; }
[ "$(st_now)" = "$STATUS_EXPECT" ] || { log "SCOPE_FAIL status set changed by contract export"; finish 73; }
log "CONTRACT_NO_CHANGE sha256=$SHA_CONTRACT_JSON (scratch regen byte-identical to BASE)"
./node_modules/.bin/jest --ci --runTestsByPath test/contracts/importer-contract.spec.ts > "$E/jest-contract.raw.log" 2>&1; rc=$?; log "JEST_CONTRACT rc=$rc"
grep -E '^(Tests|Test Suites):' "$E/jest-contract.raw.log" | tee -a "$LOG"
[ $rc = 0 ] || { grep -E '✕|●' "$E/jest-contract.raw.log" | head -60 >> "$LOG"; finish 73; }
[ "$(sha "$CONTRACT")" = "$SHA_CONTRACT_JSON" ] || { log "CONTRACT_DRIFT contract spec changed $CONTRACT"; finish 73; }
# ---- 8 jest targeted (default config, no PG), then the full default suite once (test/rls-*.spec.ts are ignored there)
STAGE=jest
./node_modules/.bin/jest --ci --runTestsByPath $SUITES > "$E/jest.raw.log" 2>&1; rc=$?; log "JEST_TARGETED rc=$rc suites_expected=$N_SUITES"
grep -E '^(Tests|Test Suites|Snapshots|Time):' "$E/jest.raw.log" | tee -a "$LOG"
[ $rc = 0 ] || { grep -E '✕|●' "$E/jest.raw.log" | head -60 >> "$LOG"; finish 73; }
grep -qE "^Test Suites: +$N_SUITES passed, $N_SUITES total" "$E/jest.raw.log" || { log "JEST_TARGETED_COUNT_FAIL expected $N_SUITES suites passed"; finish 73; }
STAGE=jest_full
t0=$(date +%s); timeout --foreground 4200 ./node_modules/.bin/jest --ci > "$E/jest-full.raw.log" 2>&1; rc=$?; log "JEST_FULL rc=$rc secs=$(( $(date +%s)-t0 ))"
grep -E '^(Tests|Test Suites|Snapshots|Time):' "$E/jest-full.raw.log" | tee -a "$LOG"
[ $rc = 0 ] || { grep -E '✕|●' "$E/jest-full.raw.log" | head -60 >> "$LOG"; finish 73; }
[ "$(st_now)" = "$STATUS_EXPECT" ] || { log "SCOPE_FAIL status set changed by tests: $(git status --porcelain | tr '\n' ' ')"; finish 73; }
[ "$(sha "$CONTRACT")" = "$SHA_CONTRACT_JSON" ] || { log "CONTRACT_DRIFT tests changed $CONTRACT"; finish 73; }
[ "$(sha node_modules/.prisma/client/index.d.ts)" = "$NM_IDX" ] || { log "SCOPE_FAIL in-lane client changed during tests"; finish 73; }
# ---- 9 stage exactly the owned paths + R75 staged + one genuine hooked commit
STAGE=stage
git add -- $FILES
[ "$(git diff --cached --name-only | sort | tr '\n' ' ')" = "$STAGED_EXPECT" ] || { log "STAGED_SET_FAIL $(git diff --cached --name-only | tr '\n' ' ')"; finish 70; }
while read -r s m st p; do [ -n "${p:-}" ] || continue
  LS=$(git ls-files -s -- "$p"); [ "${LS%% *}" = "100$m" ] || { log "STAGED_MODE_FAIL $p index mode ${LS%% *} != 100$m"; finish 70; }
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
FORB=$(git diff --name-only "$H" HEAD -- $FORBIDDEN_DELTA_PATHS $S10A_FILES "$CONTRACT")
[ -z "$FORB" ] || { log "DELTA_FAIL forbidden path in delta: $(echo $FORB)"; finish 76; }
PD=$(git diff --name-only "$H" HEAD -- prisma | sort | tr '\n' ' ')
[ "$PD" = "$S10B_MIG_DIR/down.sql $S10B_MIG_DIR/migration.sql prisma/schema.prisma " ] || { log "DELTA_FAIL prisma delta [$PD]"; finish 76; }
[ -z "$(git diff --name-only --diff-filter=DMR "$H" HEAD -- prisma/migrations)" ] || { log "DELTA_FAIL an accepted migration was modified/renamed/deleted"; finish 76; }
[ "$(git diff --numstat "$H" HEAD -- prisma/schema.prisma | cut -f1,2)" = "$(printf '%s\t0' "$SCHEMA_ADDED_LINES")" ] || { log "DELTA_FAIL committed schema delta != +$SCHEMA_ADDED_LINES/-0"; finish 76; }
[ "$(git ls-tree -d --name-only HEAD prisma/migrations/ | wc -l)" = "$MIGRATION_DIRS" ] || { log "DELTA_FAIL committed migrations != $MIGRATION_DIRS"; finish 76; }
[ "$(git rev-parse "HEAD:$CONTRACT")" = "$CONTRACT_BLOB" ] || { log "DELTA_FAIL committed contract blob != BASE"; finish 76; }
[ "$(git log -1 --format='%an <%ae>|%cn <%ce>')" = "Bradley Gleave <bradley@bradleytgpcoaching.com>|Bradley Gleave <bradley@bradleytgpcoaching.com>" ] || { log "IDENTITY_FAIL"; finish 76; }
git log -1 --format=%B HEAD > "$E/committed-message.txt"
! grep -iqE 'co-authored-by|signed-off-by|generated' "$E/committed-message.txt" || { log "TRAILER_FAIL"; finish 76; }
# ---- 10 receipts (the binding fills EXPECT_HEAD / EXPECT_TREE / six blobs / EXPECT_NM_CLIENT_SHA / EXPECT_MIGRATIONS_TREE from here)
STAGE=receipts
git diff --binary "$H" HEAD > "$E/s10b-${H:0:12}-to-${HEAD:0:12}.patch"
git diff --name-status "$H" HEAD > "$E/MANIFEST-name-status-${H:0:12}-to-${HEAD:0:12}.txt"
{ echo "base=$H"; echo "base_tree=$BASE_TREE"; echo "base_parent=$S10A_PARENT"; echo "head=$HEAD"; echo "tree=$HTREE"
  echo "migrations_tree=$(git rev-parse HEAD:prisma/migrations) dirs=$MIGRATION_DIRS last=$LAST_MIGRATION"
  echo "schema_delta=$(git diff --numstat "$H" HEAD -- prisma/schema.prisma | cut -f1,2 | tr '\t' /) schema_sha256=$(sha prisma/schema.prisma)"
  for f in $FILES; do echo "blob $f $(git rev-parse HEAD:$f) sha256=$(sha "$f")"; done
  for f in $S10A_FILES; do echo "unchanged $f $(git rev-parse HEAD:$f) sha256=$(sha "$f")"; done
  echo "contract_unchanged blob=$CONTRACT_BLOB sha256=$SHA_CONTRACT_JSON scratch_regen=identical"
  echo "postgen_client index_dts=$NM_IDX schema=$NM_SCH engine=$NM_ENG (in $W/node_modules/.prisma/client; donor unchanged $D_IDX1/$D_SCH1)"
  echo "branch=$(git rev-parse --abbrev-ref HEAD)"; git log -1 --format='author=%an <%ae>%ncommitter=%cn <%ce>%ndate=%cI'
  echo "hooks raw pre-commit=$HP commit-msg=$HC normalized pre-commit=$NP commit-msg=$NC ref_root=$HOOK_REF_ROOT lefthook=$LHV"
  echo "prettier=$V prefix=$B"; echo "donor=$DONOR hidden_lock=$NM_HIDDEN_LOCK"; echo "lock_inode=$CUR_INODE"; } > "$E/HEAD-${HEAD:0:12}.txt"
( cd "$E" && sha256sum * preformat/* postformat/* > SHA256SUMS ) 2>/dev/null
STAGE=done; log "DONE head=$HEAD tree=$HTREE (not pushed; parent owns landing; PG proof is a separate grant via ../binding/v1)"; finish 0
