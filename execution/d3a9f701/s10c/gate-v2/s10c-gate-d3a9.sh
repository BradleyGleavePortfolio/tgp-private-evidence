#!/usr/bin/env bash
# S10-C gate under the canonical slot — EXEC-D3A9F701 (S10-C settle-basis write, status preference, coverage wiring and
# ObservationModule registration; D-S10-7 S10-C row, docs/decisions/2026-09-26-s10-induction.md L356). SOURCE ONLY: NOT RUN,
# NOT GRANTED. Derived by substitution from the FINAL S10-B gate d3a9f701/s10b/gate/s10b-gate-d3a9.sh (all review fixes and
# DELTA-2 included; that gate ran rc 0 and landed a2c74e90). Differences (DELTA-from-s10b.diff):
#   - worktree /home/user/workspace/worktrees/d3a9-s10c, branch exec-d3a9/s10c; BASE = integration/importer tip at gate time
#     (__FILL__; today a2c74e90 -> 384035ec (D1) -> 711c1f8f (S11-0 doc)). No parent-shape pin: S10B_HEAD (a2c74e90) and
#     HARNESS_BASE_HEAD (a4af8e33) must each be an ANCESTOR of BASE (git merge-base --is-ancestor), BASE..S10B_HEAD touches no
#     prisma and none of the owned paths, and the 29 S10-A/S10-B FROZEN paths carry their a2c74e90 bytes at BASE
#   - owned paths: PINS.env OWNED_PINS (9 ` M` incl. test/rls-g2-s9c.spec.ts + test/scout/orchestration/settle-hook.spec.ts (v2) + 3 `??`, filled by --fill-help); no prisma change at all
#     (schema = S10-B bytes, 173 migrations, prisma status and prisma delta empty)
#   - donor = the pre-S10-B client, so the in-lane `prisma generate` is still forced; the post-gen client is compared with
#     the S10-B gate's post-gen client (same schema bytes) and recorded (POSTGEN_MATCHES_S10B)
#   - contract (D-S10-7: S10-C regenerates importer-openapi.json): scratch export; IF the bytes differ from BASE they are
#     copied to the canonical path and committed (contract_state=changed), ELSE the canonical file stays BASE bytes
#     (contract_state=unchanged). Recorded either way; the contract spec runs after the decision
#   - targeted jest = 4 S10-C unit specs + observation.{service,controller} + module-graph (7), then the full default suite
#   - receipt records it() counts of test/rls-g2-s10b.spec.ts (24 pinned) and test/rls-g2-s10c.spec.ts (for the binding)
#   - commit line passes NODE_OPTIONS=--max-old-space-size=4096 explicitly (hooked tsc)
#   Carried unchanged: symlink-aware hook refusal, all pin/shape checks pre-sentinel (prelock.log, no grant consumed), O_EXCL
#   STARTED, TERMINAL-exists refusal, under-lock rechecks (HEAD/status/index/hooks/hooksPath/node_modules/owned bytes), no
#   `cmd | grep -q` pipelines, in-clone generate only, R75 early + staged, one hooked Bradley commit, no push, no PG.
# Usage (parent relay only; README.md has the pre-relay steps):
#   S10C_GATE_RELAY=1 S10C_BASE=<integration/importer tip sha> \
#   S10C_DONOR=/home/user/workspace/worktrees/1910a060-s8f/node_modules \
#   S10C_PRETTIER_PREFIX=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 \
#   timeout -k 30 7200 bash /home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10c/gate-v2/s10c-gate-d3a9.sh
# Fill help (read-only, no lock, no relay): bash .../s10c-gate-d3a9.sh --fill-help <BASE sha>
set -uo pipefail
E=/home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10c/gate-v2   # v2 run location (run-1 in s10c/gate/ consumed: rc 73 jest_full; left untouched)
W=/home/user/workspace/worktrees/d3a9-s10c
LOCK=/home/user/workspace/execution/test-validation.lock
LOCK_RECORD=/home/user/workspace/tgp-private-evidence/execution/d3a9f701/runtime/LOCK_ESTABLISHED.txt
PREFIX_MANIFEST=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256
LOG=$E/gate.log
# shellcheck source=PINS.env
. "$E/PINS.env" || { echo "REFUSED: cannot source $E/PINS.env" >&2; exit 78; }
REQUIRED_OWNED="src/scout/reconciliation/facts.service.ts src/scout/reconciliation/types.ts src/scout/lifecycle/lifecycle.service.ts src/scout/scout.module.ts src/scout/induction/observation.module.ts test/scout/lifecycle/lifecycle.service.spec.ts test/scout/reconciliation/facts.service.spec.ts test/scout/reconciliation/facts.service.coverage.spec.ts test/scout/induction/s10c-wiring.spec.ts test/rls-g2-s10c.spec.ts test/rls-g2-s9c.spec.ts test/scout/orchestration/settle-hook.spec.ts"   # 12: parent 22:34 added the S9-C live spec (superseded assertions L289/L297/L444-448 only); v2 (parent 23:11) added the S8-G settle-hook unit spec (fake tx gains scoutRunObservation/scoutRunSettledBasis)
GEN_OWNER_OPTIONAL="scripts/importer-contract.ts test/contracts/importer-contract.spec.ts"   # D-S10-7 generator owner; allowed only if listed in OWNED_PINS
OPTIONAL_OWNED="$GEN_OWNER_OPTIONAL"
S10B_SPEC=test/rls-g2-s10b.spec.ts; S10C_SPEC=test/rls-g2-s10c.spec.ts
ts(){ date -u +%FT%TZ; }
log(){ echo "$(ts) $*" | tee -a "$LOG"; }
sha(){ sha256sum "$1" | cut -c1-64; }
is40(){ [[ "$1" =~ ^[0-9a-f]{40}$ ]]; }
is64(){ [[ "$1" =~ ^[0-9a-f]{64}$ ]]; }
flat(){ echo "$1" | sed 's|/|__|g'; }
itc(){ local t; t=$(cat "$1" 2>/dev/null) || { echo x; return; }; grep -cE '^\s*it\(' <<<"$t" || true; }
# ---- --fill-help: read-only git queries only (no lock, no sentinel, no writes). Prints the PINS.env lines to paste.
if [ "${1:-}" = --fill-help ]; then
  B_=${2:-}; is40 "$B_" || { echo "usage: $0 --fill-help <40-hex integration/importer tip>  (git -C $W ls-remote origin refs/heads/integration/importer)" >&2; exit 2; }
  export GIT_OPTIONAL_LOCKS=0; cd "$W" || exit 3
  git cat-file -e "$B_^{commit}" 2>/dev/null || { echo "BASE $B_ not in $W: git -C $W fetch origin integration/importer" >&2; exit 3; }
  echo "BASE=$B_"; echo "BASE_TREE=$(git rev-parse "$B_^{tree}")"; echo "MIGRATIONS_TREE=$(git rev-parse "$B_:prisma/migrations")"
  a1=no; git merge-base --is-ancestor "$S10B_HEAD" "$B_" && a1=yes; a2=no; git merge-base --is-ancestor "$HARNESS_BASE_HEAD" "$B_" && a2=yes
  echo "# checks: S10B_HEAD ancestor=$a1 HARNESS_BASE ancestor=$a2 (want yes/yes)  log $S10B_HEAD..BASE: $(git log --format=%h "$S10B_HEAD..$B_" 2>/dev/null | tr '\n' ' ')"
  echo "#   prisma delta S10B..BASE=[$(git diff --name-only "$S10B_HEAD" "$B_" -- prisma | tr '\n' ' ')] (want empty)  migrations dirs at BASE=$(git ls-tree -d --name-only "$B_" prisma/migrations/ | wc -l) (want $MIGRATION_DIRS)"
  echo "#   owned paths touched S10B..BASE=[$(git diff --name-only "$S10B_HEAD" "$B_" -- $REQUIRED_OWNED $OPTIONAL_OWNED $CONTRACT | tr '\n' ' ')] (want empty; else rebase the candidate)"
  echo "#   schema_blob=$(git rev-parse "$B_:prisma/schema.prisma") (want $SCHEMA_BLOB)  contract_blob=$(git rev-parse "$B_:$CONTRACT") (want $CONTRACT_BLOB)"
  nbad=0; while read -r tag s b p; do [ "$tag" = FROZEN ] || continue; [ "$(git rev-parse "$B_:$p" 2>/dev/null)" = "$b" ] || { echo "#   FROZEN MISMATCH $p"; nbad=$((nbad+1)); }; done < "$FROZEN"; echo "#   frozen mismatches at BASE: $nbad (want 0)"
  echo "# clone: HEAD=$(git rev-parse HEAD) branch=$(git rev-parse --abbrev-ref HEAD) hooks=[$(ls .git/hooks 2>/dev/null | grep -v '\.sample$' | tr '\n' ' ')] hooksPath=[$(git config --get core.hooksPath)] node_modules=$( { [ -e node_modules ] || [ -L node_modules ]; } && echo PRESENT || echo absent)"
  ST=$(git status --porcelain --untracked-files=all)
  echo "# OWNED_PINS from the working tree (paste after fix-1; state from git status):"
  echo "OWNED_PINS='$(for p in $REQUIRED_OWNED $OPTIONAL_OWNED; do
      line=$(awk -v p="$p" 'substr($0,4)==p' <<<"$ST"); x=${line:0:2}
      case "$x" in " M") s=M;; "??") s=N;; "") case " $OPTIONAL_OWNED " in *" $p "*) continue;; esac; s="UNCHANGED(refused)";; *) s="STATE[$x](refused)";; esac
      printf '%s %s %s %s\n' "$( [ -f "$p" ] && sha "$p" || echo absent)" "$(stat -c %a "$p" 2>/dev/null || echo x)" "$s" "$p"; done)'"
  echo "# status entries NOT in the owned set (the gate refuses while any remain; README.md Open decision 1):"
  while IFS= read -r l; do [ -n "$l" ] || continue; p=${l:3}; case " $REQUIRED_OWNED $OPTIONAL_OWNED " in *" $p "*) ;; *) echo "#   EXTRA [$l]";; esac; done <<<"$ST"
  echo "# it() counts (working): $S10B_SPEC=$(itc "$S10B_SPEC") (want $EXPECT_IT_S10B)  $S10C_SPEC=$(itc "$S10C_SPEC")"
  exit 0
fi
mkdir -p "$E"
# ---- 0 relay + pins (a refusal before ACQUIRED does not consume the grant)
[ "${S10C_GATE_RELAY:-}" = 1 ] || { echo "REFUSED: S10C_GATE_RELAY=1 (parent relay) not set" >&2; exit 78; }
[ -n "${S10C_DONOR:-}" ] && [ -d "$S10C_DONOR" ] || { echo "REFUSED: S10C_DONOR (node_modules donor dir) not set or absent" >&2; exit 78; }
[ -n "${S10C_PRETTIER_PREFIX:-}" ] && [ -d "$S10C_PRETTIER_PREFIX" ] || { echo "REFUSED: S10C_PRETTIER_PREFIX not set or absent" >&2; exit 78; }
is40 "$BASE" || { echo "REFUSED: PINS.env BASE is not a 40-hex sha ($BASE); run --fill-help" >&2; exit 78; }
[ -n "${S10C_BASE:-}" ] && [ "$S10C_BASE" = "$BASE" ] || { echo "REFUSED: S10C_BASE (${S10C_BASE:-unset}) must be relayed and equal PINS.env BASE=$BASE" >&2; exit 78; }
H=$BASE
for v in BASE_TREE MIGRATIONS_TREE S10B_HEAD HARNESS_BASE_HEAD SCHEMA_BLOB CONTRACT_BLOB; do is40 "${!v}" || { echo "REFUSED: PINS.env $v not 40-hex (${!v})" >&2; exit 78; }; done
for v in FROZEN_SHA SCHEMA_SHA PKG_LOCK_SHA PKG_JSON_SHA NM_HIDDEN_LOCK DONOR_CLIENT_INDEX_DTS DONOR_CLIENT_SCHEMA S10B_CLIENT_INDEX_DTS S10B_CLIENT_SCHEMA SHA_CONTRACT_JSON; do
  is64 "${!v}" || { echo "REFUSED: PINS.env $v is not a 64-hex sha256 (${!v})" >&2; exit 78; }
done
for v in CLIENT_INDEX_DTS CLIENT_SCHEMA; do [ "${!v}" = RECORD ] || is64 "${!v}" || { echo "REFUSED: PINS.env $v must be RECORD or 64-hex (${!v})" >&2; exit 78; }; done
for v in MIGRATION_DIRS FROZEN_COUNT LOCK_INODE EXPECT_IT_S10B; do [[ "${!v}" =~ ^[1-9][0-9]*$ ]] || { echo "REFUSED: PINS.env $v not a positive integer" >&2; exit 78; }; done
[ "$EXPECT_IT_S10C" = RECORD ] || [[ "$EXPECT_IT_S10C" =~ ^[1-9][0-9]*$ ]] || { echo "REFUSED: PINS.env EXPECT_IT_S10C must be RECORD or a positive integer" >&2; exit 78; }
[ "$CONTRACT_MODE" = REGEN_COMMIT_IF_CHANGED ] || { echo "REFUSED: PINS.env CONTRACT_MODE must be REGEN_COMMIT_IF_CHANGED" >&2; exit 78; }
[ -f "$FROZEN" ] && [ ! -L "$FROZEN" ] && [ "$(sha "$FROZEN")" = "$FROZEN_SHA" ] || { echo "REFUSED: FROZEN $FROZEN absent, a symlink or sha != $FROZEN_SHA" >&2; exit 78; }
FROZEN_FILES=$(awk '$1=="FROZEN"{print $4}' "$FROZEN" | tr '\n' ' ')
[ "$(echo $FROZEN_FILES | wc -w)" = "$FROZEN_COUNT" ] || { echo "REFUSED: FROZEN lists $(echo $FROZEN_FILES | wc -w) paths, want $FROZEN_COUNT" >&2; exit 78; }
# OWNED_PINS: every sha filled, mode 644/755, state M/N, no duplicates, required S10-C paths present, nothing forbidden/frozen
MOD_FILES=""; NEW_FILES=""
while read -r s m st p; do [ -n "${p:-}" ] || continue
  is64 "$s" || { echo "REFUSED: PINS.env OWNED_PINS sha for $p not filled ($s)" >&2; exit 78; }
  case "$m" in 644|755) ;; *) echo "REFUSED: PINS.env OWNED_PINS mode for $p ($m)" >&2; exit 78;; esac
  case "$st" in M) MOD_FILES="$MOD_FILES $p";; N) NEW_FILES="$NEW_FILES $p";; *) echo "REFUSED: PINS.env OWNED_PINS state for $p ($st; M or N)" >&2; exit 78;; esac
done <<< "$OWNED_PINS"
DUPS=$(printf '%s\n' $MOD_FILES $NEW_FILES | sort | uniq -d)
[ -z "$DUPS" ] || { echo "REFUSED: PINS.env OWNED_PINS has duplicate paths: $DUPS" >&2; exit 78; }
for p in $REQUIRED_OWNED; do case " $MOD_FILES $NEW_FILES " in *" $p "*) ;; *) echo "REFUSED: PINS.env OWNED_PINS lacks required S10-C path $p" >&2; exit 78;; esac; done
for p in $MOD_FILES $NEW_FILES; do
  for fp in $FORBIDDEN_DELTA_PATHS $FROZEN_FILES $CONTRACT; do case "$p" in "$fp"|"$fp"/*) echo "REFUSED: owned $p is under forbidden/frozen $fp (the contract artifact is gate-managed, never listed)" >&2; exit 78;; esac; done
  case "$p" in docs/*) echo "REFUSED: owned $p under docs/ (S10-C owns no doc bytes; the contract is gate-managed)" >&2; exit 78;;
    scripts/*|test/contracts/*) case " $GEN_OWNER_OPTIONAL " in *" $p "*) ;; *) echo "REFUSED: owned $p is not a generator-owner path" >&2; exit 78;; esac;; esac
done
[ -n "$SUITES" ] || { echo "REFUSED: PINS.env SUITES empty" >&2; exit 78; }
for s in $SUITES; do [ -f "$W/$s" ] || { echo "REFUSED: suite $s absent in $W" >&2; exit 78; }; done
DONOR=$S10C_DONOR; B=$S10C_PRETTIER_PREFIX
FILES="$MOD_FILES $NEW_FILES"
# two messages: the one used is chosen at the contract step (the regen decides whether the artifact is in the commit)
MSG_UNCHANGED=$E/commit-message-contract-unchanged.txt; MSG_CHANGED=$E/commit-message-contract-changed.txt; MSG=$MSG_UNCHANGED
# prettier/eslint: owned .ts/.cjs only (same as S10-B; the contract JSON is .prettierignored and never reflowed)
PRETTIER_FILES=$(for f in $FILES; do case "$f" in *.ts|*.cjs) printf '%s ' "$f";; esac; done)
ESLINT_FILES=$PRETTIER_FILES
NOFMT_FILES=$(for f in $FILES; do case "$f" in *.ts|*.cjs) ;; *) printf '%s ' "$f";; esac; done)
mkexpect(){ STAGED_EXPECT=$(printf '%s\n' $FILES | sort | tr '\n' ' ')
  STATUS_EXPECT=$( { for f in $MOD_FILES; do echo " M $f"; done; for f in $NEW_FILES; do echo "?? $f"; done; } | sort | tr '\n' '|'); }
mkexpect
N_SUITES=$(echo $SUITES | wc -w)
for m_ in "$MSG_UNCHANGED" "$MSG_CHANGED"; do
  [ -f "$m_" ] && [ ! -L "$m_" ] && [ -s "$m_" ] || { echo "REFUSED: commit message $m_ absent, a symlink or empty" >&2; exit 78; }
  MSGTXT=$(cat "$m_")
  ! grep -iqE 'claude|anthropic|openai|gpt[- ]|computer[- ]agent|perplexity|co-authored[- ]by|signed-off-by|generated with|🤖|ai assist|\b(ai|agent)\b' <<<"$MSGTXT" || { echo "REFUSED: $m_ carries a banned token or trailer" >&2; exit 78; }
done
# ---- preconditions run BEFORE the sentinel and the lock (review B1): every pin/shape refusal here exits without writing
# STARTED or TERMINAL, so a stale pin never consumes the one-shot grant. finish() is redefined after ACQUIRED.
STAGE=preflight-prelock
LOG=$E/prelock.log; export GIT_OPTIONAL_LOCKS=0   # pre-lock: own log (gate.log stays the run log), no optional git index writes
[ ! -e "$E/STARTED" ] && [ ! -L "$E/STARTED" ] || { echo "REFUSED: $E/STARTED exists; this gate is one-shot, do not loop" >&2; exit 76; }   # early (re-checked before the lock)
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
git merge-base --is-ancestor "$S10B_HEAD" "$BASE" || { log "PRECONDITION_FAIL S10-B landing $S10B_HEAD is not an ancestor of BASE $BASE"; finish 78; }
git merge-base --is-ancestor "$HARNESS_BASE_HEAD" "$BASE" || { log "PRECONDITION_FAIL harness base $HARNESS_BASE_HEAD is not an ancestor of BASE $BASE"; finish 78; }
[ -z "$(git config --get core.hooksPath)" ] || { log "PRECONDITION_FAIL core.hooksPath set"; finish 70; }
[ -z "$(git diff --cached --name-only)" ] || { log "PRECONDITION_FAIL index not clean vs HEAD (staged or intent-to-add entries): $(git diff --cached --name-only | tr '\n' ' ')"; finish 70; }
[ ! -e "$(git rev-parse --git-path MERGE_HEAD)" ] || { log "PRECONDITION_FAIL MERGE_HEAD present"; finish 70; }
STATUS_NOW=$(st_now)
[ "$STATUS_NOW" = "$STATUS_EXPECT" ] || { log "PRECONDITION_FAIL status set: [$STATUS_NOW] expected [$STATUS_EXPECT]"; finish 70; }
chk(){ [ "$(sha "$1")" = "$2" ] || { log "PRECONDITION_FAIL $1 sha $(sha "$1") != $2"; finish 70; }; }
while read -r s m st p; do [ -n "${p:-}" ] || continue
  chk "$p" "$s"
  [ -f "$p" ] && [ ! -L "$p" ] || { log "PRECONDITION_FAIL owned $p is not a regular file"; finish 70; }
  [ "$(stat -c %a "$p")" = "$m" ] || { log "PRECONDITION_FAIL $p mode $(stat -c %a "$p") != $m"; finish 70; }
done <<< "$OWNED_PINS"
for p in $MOD_FILES; do git cat-file -e "HEAD:$p" 2>/dev/null || { log "PRECONDITION_FAIL M path $p not tracked at BASE"; finish 70; }; done
for p in $NEW_FILES; do ! git cat-file -e "HEAD:$p" 2>/dev/null || { log "PRECONDITION_FAIL N path $p already tracked at BASE"; finish 70; }; done
# S10B_HEAD..BASE: no prisma, no owned path, no contract change (else the candidate must be rebased; not the gate's job)
[ -z "$(git diff --name-only "$S10B_HEAD" HEAD -- prisma)" ] || { log "PRECONDITION_FAIL prisma changed between S10-B and BASE: $(git diff --name-only "$S10B_HEAD" HEAD -- prisma | tr '\n' ' ')"; finish 70; }
OVL=$(git diff --name-only "$S10B_HEAD" HEAD -- $FILES "$CONTRACT")
[ -z "$OVL" ] || { log "PRECONDITION_FAIL owned/contract paths changed between S10-B and BASE (rebase the candidate first): $(echo $OVL)"; finish 70; }
# FROZEN: the S10-A/S10-B surfaces other than observation.module.ts carry their a2c74e90 bytes at BASE and in the working tree
while read -r tag s b p; do [ "$tag" = FROZEN ] || continue
  [ "$(git rev-parse "HEAD:$p" 2>/dev/null)" = "$b" ] || { log "PRECONDITION_FAIL frozen $p blob at BASE != $b"; finish 70; }
  chk "$p" "$s"
done < "$FROZEN"
[ -z "$(git status --porcelain --untracked-files=all -- $FROZEN_FILES)" ] || { log "PRECONDITION_FAIL frozen S10-A/S10-B files dirty in the working tree"; finish 70; }
[ ! -e node_modules ] && [ ! -L node_modules ] || { log "PRECONDITION_FAIL node_modules already present (parent must set the clone's copy aside first: README.md)"; finish 70; }
# schema/migrations: NO change in S10-C (S10-B bytes, 173 dirs ending at the S10-B dir, prisma status empty)
[ "$(git rev-parse "HEAD:prisma/schema.prisma")" = "$SCHEMA_BLOB" ] && chk prisma/schema.prisma "$SCHEMA_SHA" || { log "PRECONDITION_FAIL schema at BASE != $SCHEMA_BLOB"; finish 70; }
SCHEMA_NOW=$(cat prisma/schema.prisma)
for m_ in $S10B_MODELS; do grep -qE "^model $m_ \{" <<<"$SCHEMA_NOW" || { log "PRECONDITION_FAIL schema lacks model $m_"; finish 70; }; done
[ -z "$(git status --porcelain --untracked-files=all -- prisma)" ] || { log "PRECONDITION_FAIL prisma/ not clean (S10-C changes no prisma): $(git status --porcelain --untracked-files=all -- prisma | tr '\n' ' ')"; finish 70; }
chk package-lock.json "$PKG_LOCK_SHA"; chk package.json "$PKG_JSON_SHA"
[ -z "$(git status --porcelain --untracked-files=all -- package.json package-lock.json)" ] || { log "PRECONDITION_FAIL package manifests dirty"; finish 70; }
[ "$(git rev-parse HEAD:prisma/migrations)" = "$MIGRATIONS_TREE" ] || { log "PRECONDITION_FAIL prisma/migrations tree at BASE != $MIGRATIONS_TREE"; finish 70; }
BMIG=$(git ls-tree -d --name-only HEAD prisma/migrations/ | sed 's|^prisma/migrations/||' | sort)
[ "$(wc -l <<<"$BMIG")" = "$MIGRATION_DIRS" ] && [ "$(tail -1 <<<"$BMIG")" = "$LAST_MIGRATION" ] || { log "PRECONDITION_FAIL BASE migrations $(wc -l <<<"$BMIG")/$(tail -1 <<<"$BMIG") != $MIGRATION_DIRS/$LAST_MIGRATION"; finish 70; }
WMIG=$(find prisma/migrations -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
[ "$WMIG" = "$BMIG" ] || { log "PRECONDITION_FAIL working migrations dirs != BASE"; finish 70; }
# harness literals (frozen bytes; the binding re-checks at HEAD): 173, S10-B dir, harness base pin
BOOT=$(cat test/utils/g2-s10b-bootstrap.sh); PGH=$(cat test/utils/g2-s10b-pg-harness.ts); DBTS=$(cat test/utils/g2-s10b-db.ts)
grep -qx "EXPECTED_MIGRATIONS=$MIGRATION_DIRS" <<<"$BOOT" && grep -qx "S10B_MIGRATION=$LAST_MIGRATION" <<<"$BOOT" \
  && grep -qx "BASE_HEAD=$HARNESS_BASE_HEAD" <<<"$BOOT" || { log "PRECONDITION_FAIL g2-s10b-bootstrap.sh constants != pins"; finish 70; }
grep -qF "export const EXPECTED_MIGRATIONS = $MIGRATION_DIRS;" <<<"$PGH" && grep -qF "export const S10B_MIGRATION = '$LAST_MIGRATION';" <<<"$PGH" || { log "PRECONDITION_FAIL g2-s10b-pg-harness.ts constants != pins"; finish 70; }
grep -qF "G2_S10B_BASE_HEAD = '$HARNESS_BASE_HEAD'" <<<"$DBTS" || { log "PRECONDITION_FAIL g2-s10b-db.ts G2_S10B_BASE_HEAD != $HARNESS_BASE_HEAD"; finish 70; }
# live specs: the S10-B spec is frozen at 24 it(); the S10-C spec count is recorded (or enforced) for the binding
IT_S10B=$(itc "$S10B_SPEC"); IT_S10C=$(itc "$S10C_SPEC")
[ "$IT_S10B" = "$EXPECT_IT_S10B" ] || { log "PRECONDITION_FAIL it() count $S10B_SPEC=$IT_S10B != $EXPECT_IT_S10B"; finish 70; }
[[ "$IT_S10C" =~ ^[1-9][0-9]*$ ]] || { log "PRECONDITION_FAIL it() count $S10C_SPEC=$IT_S10C"; finish 70; }
[ "$EXPECT_IT_S10C" = RECORD ] || [ "$IT_S10C" = "$EXPECT_IT_S10C" ] || { log "PRECONDITION_FAIL it() count $S10C_SPEC=$IT_S10C != $EXPECT_IT_S10C"; finish 70; }
SC=$(cat "$S10C_SPEC"); ! grep -qE '\b(it|describe|test)\.(skip|only|todo)\b|\b(xit|fit|xdescribe|fdescribe)\(' <<<"$SC" || { log "PRECONDITION_FAIL $S10C_SPEC has skip/only/todo"; finish 70; }
# contract: BASE blob pinned; working file = BASE bytes before the regen step
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
log "PRECONDITIONS_OK (pre-lock) base=$H s10b_head=$S10B_HEAD harness_base=$HARNESS_BASE_HEAD owned=$(echo $FILES | wc -w) frozen=$FROZEN_COUNT it_s10b=$IT_S10B it_s10c=$IT_S10C"
LOG=$E/gate.log; unset GIT_OPTIONAL_LOCKS
[ ! -e "$E/STARTED" ] && [ ! -L "$E/STARTED" ] || { echo "REFUSED: $E/STARTED exists; this gate is one-shot, do not loop" >&2; exit 76; }
[ ! -e "$E/TERMINAL" ] && [ ! -L "$E/TERMINAL" ] || { echo "REFUSED: $E/TERMINAL exists (or is a symlink) without STARTED" >&2; exit 76; }
# ---- lock: existing canonical file, recorded inode (PINS.env and LOCK_ESTABLISHED.txt must agree), nonblocking flock here
[ -e "$LOCK" ] || { log "REFUSED lock file absent"; exit 75; }
REC_INODE=$(sed -n 's/.*inode=\([0-9]*\).*/\1/p' "$LOCK_RECORD" | head -1)
CUR_INODE=$(stat -c %i "$LOCK")
[ -n "$REC_INODE" ] && [ "$CUR_INODE" = "$REC_INODE" ] && [ "$CUR_INODE" = "$LOCK_INODE" ] || { log "REFUSED lock inode $CUR_INODE != recorded $REC_INODE / pinned $LOCK_INODE"; exit 75; }
exec 9>>"$LOCK"; flock -n 9 || { log "REFUSED canonical lock busy (live holder); not waiting, not stealing"; exit 75; }
( set -C; date -u +%FT%TZ > "$E/STARTED" ) 2>/dev/null || { log "REFUSED $E/STARTED appeared (or is a symlink) at lock time; one-shot not consumed here"; exit 76; }   # O_EXCL: refuses any existing path incl. dangling symlink
LSL=$(lslocks 2>/dev/null); log "ACQUIRED pid=$$ fd9 inode=$CUR_INODE lslocks=$(grep -c test-validation <<<"$LSL") donor=$DONOR prefix=$B base=$H"
STAGE=preflight
finish(){ unset npm_config_prefix; log "RELEASING stage=$STAGE rc=$1 (fd9 closes at exit; lock file preserved)"; printf 'RC=%s STAGE=%s END=%s\n' "$1" "$STAGE" "$(ts)" > "$E/TERMINAL"; exit "$1"; }
# re-verify, under the lock, the state that could have moved between the pre-lock checks and ACQUIRED
[ "$(git rev-parse HEAD)" = "$H" ] && [ "$(st_now)" = "$STATUS_EXPECT" ] && [ -z "$(git diff --cached --name-only)" ] || { log "PRECONDITION_FAIL HEAD/status/index moved after the pre-lock checks"; finish 70; }
for hk in pre-commit commit-msg; do { [ -e ".git/hooks/$hk" ] || [ -L ".git/hooks/$hk" ]; } && { log "PRECONDITION_FAIL .git/hooks/$hk appeared after the pre-lock checks"; finish 70; }; done
[ ! -e node_modules ] && [ ! -L node_modules ] || { log "PRECONDITION_FAIL node_modules appeared after the pre-lock checks"; finish 70; }
[ "$(git rev-parse --git-path hooks)" = .git/hooks ] && [ -d .git/hooks ] && [ ! -L .git/hooks ] && [ -z "$(git config --get core.hooksPath)" ] || { log "PRECONDITION_FAIL hooks dir changed after the pre-lock checks (not the plain .git/hooks directory, or core.hooksPath set)"; finish 70; }
while read -r s m st p; do [ -n "${p:-}" ] || continue; chk "$p" "$s"; done <<< "$OWNED_PINS"
while read -r tag s b p; do [ "$tag" = FROZEN ] || continue; chk "$p" "$s"; done < "$FROZEN"
[ "$(sha "$CONTRACT")" = "$SHA_CONTRACT_JSON" ] || { log "PRECONDITION_FAIL contract bytes moved after the pre-lock checks"; finish 70; }
HEAVY=$(pgrep -af "jest|tsc|prisma|postgres|prettier|lefthook|eslint" | grep -v -e "^$$ " -e s10c-gate || true)
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
# ---- 1b forced in-lane prisma generate (lesson 5): the donor client is the pre-S10-B client; tsc/jest need the three S10-B models
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
PG_MATCH=no; [ "$NM_IDX" = "$S10B_CLIENT_INDEX_DTS" ] && [ "$NM_SCH" = "$S10B_CLIENT_SCHEMA" ] && PG_MATCH=yes
log "POSTGEN_MATCHES_S10B=$PG_MATCH (S10-B gate post-gen $S10B_CLIENT_INDEX_DTS / $S10B_CLIENT_SCHEMA from the same schema bytes; recorded, not enforced unless CLIENT_* pinned)"
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
# ---- 7 contract REGEN (D-S10-7: S10-C regenerates importer-openapi.json). Scratch export first; commit it only if it moves.
STAGE=contract
git show "HEAD:$CONTRACT" > "$E/importer-openapi.base.json"
IMPORTER_CONTRACT_OUT="$E/contract-regen.json" timeout --foreground 900 npm run -s contract:importer > "$E/contract-gen.log" 2>&1; rc=$?
log "CONTRACT_GEN rc=$rc out=$E/contract-regen.json sha256=$(sha "$E/contract-regen.json" 2>/dev/null || echo absent)"
[ $rc = 0 ] && [ -s "$E/contract-regen.json" ] || { tail -40 "$E/contract-gen.log" >> "$LOG"; finish 73; }
node -e 'JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"))' "$E/contract-regen.json" || { log "CONTRACT_FAIL scratch export is not valid JSON"; finish 73; }
[ "$(sha "$CONTRACT")" = "$SHA_CONTRACT_JSON" ] && [ -z "$(git status --porcelain -- "$CONTRACT")" ] || { log "CONTRACT_DRIFT canonical $CONTRACT touched by the scratch export"; finish 73; }
PATHS_DIFF=$(node -e 'const f=require("fs"),a=Object.keys(JSON.parse(f.readFileSync(process.argv[1],"utf8")).paths||{}),b=Object.keys(JSON.parse(f.readFileSync(process.argv[2],"utf8")).paths||{});console.log("added=["+b.filter(x=>!a.includes(x)).join(",")+"] removed=["+a.filter(x=>!b.includes(x)).join(",")+"]")' "$E/importer-openapi.base.json" "$E/contract-regen.json" 2>&1)
if cmp -s "$E/contract-regen.json" "$E/importer-openapi.base.json"; then
  CONTRACT_STATE=unchanged; CONTRACT_SHA_NOW=$SHA_CONTRACT_JSON; CONTRACT_BLOB_NOW=$CONTRACT_BLOB; MSG=$MSG_UNCHANGED
  log "CONTRACT_STATE=unchanged sha256=$SHA_CONTRACT_JSON blob=$CONTRACT_BLOB (scratch regen byte-identical to BASE; canonical untouched, not in the delta)"
else
  CONTRACT_STATE=changed
  cat "$E/contract-regen.json" > "$CONTRACT" || { log "CONTRACT_FAIL copy scratch -> $CONTRACT"; finish 73; }   # cat >: keeps the tracked file's inode/mode
  CONTRACT_SHA_NOW=$(sha "$CONTRACT"); CONTRACT_BLOB_NOW=$(git hash-object "$CONTRACT"); MSG=$MSG_CHANGED
  cmp -s "$CONTRACT" "$E/contract-regen.json" || { log "CONTRACT_FAIL canonical != scratch after copy"; finish 73; }
  MOD_FILES="$MOD_FILES $CONTRACT"; FILES="$MOD_FILES $NEW_FILES"; NOFMT_FILES="$NOFMT_FILES $CONTRACT "; mkexpect
  cp -p "$CONTRACT" "$E/postformat/$(flat "$CONTRACT")"
  log "CONTRACT_STATE=changed base_sha256=$SHA_CONTRACT_JSON new_sha256=$CONTRACT_SHA_NOW new_blob=$CONTRACT_BLOB_NOW numstat=$(git diff --numstat -- "$CONTRACT" | cut -f1,2 | tr '\t' /) paths $PATHS_DIFF (committed with the owned set)"
fi
[ "$(st_now)" = "$STATUS_EXPECT" ] || { log "SCOPE_FAIL status set after the contract step: [$(st_now)] expected [$STATUS_EXPECT]"; finish 73; }
./node_modules/.bin/jest --ci --runTestsByPath test/contracts/importer-contract.spec.ts > "$E/jest-contract.raw.log" 2>&1; rc=$?; log "JEST_CONTRACT rc=$rc state=$CONTRACT_STATE"
grep -E '^(Tests|Test Suites):' "$E/jest-contract.raw.log" | tee -a "$LOG"
[ $rc = 0 ] || { grep -E '✕|●' "$E/jest-contract.raw.log" | head -60 >> "$LOG"; finish 73; }
[ "$(sha "$CONTRACT")" = "$CONTRACT_SHA_NOW" ] || { log "CONTRACT_DRIFT contract spec changed $CONTRACT"; finish 73; }
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
[ "$(sha "$CONTRACT")" = "$CONTRACT_SHA_NOW" ] || { log "CONTRACT_DRIFT tests changed $CONTRACT"; finish 73; }
[ "$(sha node_modules/.prisma/client/index.d.ts)" = "$NM_IDX" ] || { log "SCOPE_FAIL in-lane client changed during tests"; finish 73; }
# ---- 9 stage exactly the owned paths (+ the contract iff changed) + R75 staged + one genuine hooked commit
STAGE=stage
git add -- $FILES
[ "$(git diff --cached --name-only | sort | tr '\n' ' ')" = "$STAGED_EXPECT" ] || { log "STAGED_SET_FAIL $(git diff --cached --name-only | tr '\n' ' ')"; finish 70; }
while read -r s m st p; do [ -n "${p:-}" ] || continue
  LS=$(git ls-files -s -- "$p"); [ "${LS%% *}" = "100$m" ] || { log "STAGED_MODE_FAIL $p index mode ${LS%% *} != 100$m"; finish 70; }
done <<< "$OWNED_PINS"
if [ "$CONTRACT_STATE" = changed ]; then LS=$(git ls-files -s -- "$CONTRACT"); [ "${LS%% *}" = 100644 ] && [ "$(git rev-parse ":$CONTRACT")" = "$CONTRACT_BLOB_NOW" ] || { log "STAGED_CONTRACT_FAIL"; finish 70; }; fi
TREE=$(git write-tree); log "STAGED_TREE=$TREE"
for f in $FILES; do log "STAGED_BLOB $f $(git rev-parse ":$f")"; done
node scripts/check-r75.js --mode=staged > "$E/r75-staged.raw.log" 2>&1; rc=$?; log "R75_STAGED rc=$rc"; [ $rc = 0 ] || { tail -40 "$E/r75-staged.raw.log" >> "$LOG"; finish 74; }
STAGE=commit
log "COMMIT_MESSAGE file=$MSG sha256=$(sha "$MSG") contract_state=$CONTRACT_STATE"
[ "$(sha .git/hooks/pre-commit)" = "$HP" ] && [ "$(sha .git/hooks/commit-msg)" = "$HC" ] && [ -z "$(git config --get core.hooksPath)" ] && [ "$(git rev-parse --git-path hooks)" = .git/hooks ] && [ -d .git/hooks ] && [ ! -L .git/hooks ] && [ -f .git/hooks/pre-commit ] && [ ! -L .git/hooks/pre-commit ] && [ -f .git/hooks/commit-msg ] && [ ! -L .git/hooks/commit-msg ] || { log "HOOK_FAIL hook shas / core.hooksPath / plain .git/hooks changed before git commit (pre-commit=$(sha .git/hooks/pre-commit) want $HP; commit-msg=$(sha .git/hooks/commit-msg) want $HC)"; finish 71; }
NODE_OPTIONS=--max-old-space-size=4096 git commit -F "$MSG" > "$E/commit-attempt-1.raw.log" 2>&1; rc=$?
tail -25 "$E/commit-attempt-1.raw.log" >> "$LOG"; log "GIT_COMMIT rc=$rc (NODE_OPTIONS=--max-old-space-size=4096 on the commit line)"; [ $rc = 0 ] || finish 76
HEAD=$(git rev-parse HEAD); HTREE=$(git rev-parse 'HEAD^{tree}')
log "HEAD=$HEAD TREE=$HTREE author=$(git log -1 --format='%an <%ae> / %cn <%ce> / %cI') parent=$(git rev-parse HEAD^)"
[ "$(git rev-parse HEAD^)" = "$H" ] && [ -z "$(git status --porcelain --untracked-files=all)" ] || { log "LINEAGE_FAIL"; finish 76; }
[ "$HTREE" = "$TREE" ] || { log "TREE_FAIL committed tree $HTREE != staged tree $TREE (hook modified the index?)"; finish 76; }
DELTA=$(git diff --name-only "$H" HEAD | sort | tr '\n' ' ')
[ "$DELTA" = "$STAGED_EXPECT" ] || { log "DELTA_FAIL [$DELTA]"; finish 76; }
FORB=$(git diff --name-only "$H" HEAD -- $FORBIDDEN_DELTA_PATHS $FROZEN_FILES)
[ -z "$FORB" ] || { log "DELTA_FAIL forbidden/frozen path in delta: $(echo $FORB)"; finish 76; }
[ -z "$(git diff --name-only "$H" HEAD -- prisma)" ] || { log "DELTA_FAIL prisma changed (S10-C changes no prisma)"; finish 76; }
[ "$(git rev-parse HEAD:prisma/migrations)" = "$MIGRATIONS_TREE" ] && [ "$(git ls-tree -d --name-only HEAD prisma/migrations/ | wc -l)" = "$MIGRATION_DIRS" ] || { log "DELTA_FAIL committed migrations tree/count != BASE"; finish 76; }
[ "$(git rev-parse "HEAD:$CONTRACT")" = "$CONTRACT_BLOB_NOW" ] || { log "DELTA_FAIL committed contract blob != $CONTRACT_BLOB_NOW ($CONTRACT_STATE)"; finish 76; }
if [ "$CONTRACT_STATE" = changed ]; then [ "$CONTRACT_BLOB_NOW" != "$CONTRACT_BLOB" ] || { log "DELTA_FAIL contract marked changed but blob = BASE"; finish 76; }; fi
[ "$(git log -1 --format='%an <%ae>|%cn <%ce>')" = "Bradley Gleave <bradley@bradleytgpcoaching.com>|Bradley Gleave <bradley@bradleytgpcoaching.com>" ] || { log "IDENTITY_FAIL"; finish 76; }
git log -1 --format=%B HEAD > "$E/committed-message.txt"
! grep -iqE 'co-authored-by|signed-off-by|generated' "$E/committed-message.txt" || { log "TRAILER_FAIL"; finish 76; }
IT_S10B_H=$(git show "HEAD:$S10B_SPEC" > "$E/.it-s10b" && itc "$E/.it-s10b"); IT_S10C_H=$(git show "HEAD:$S10C_SPEC" > "$E/.it-s10c" && itc "$E/.it-s10c")
[ "$IT_S10B_H" = "$EXPECT_IT_S10B" ] && [ "$IT_S10C_H" = "$IT_S10C" ] || { log "DELTA_FAIL committed it() counts $IT_S10B_H/$IT_S10C_H != $EXPECT_IT_S10B/$IT_S10C"; finish 76; }
# ---- 10 receipts (the binding fills EXPECT_BASE / EXPECT_HEAD / EXPECT_TREE / EXPECT_DELTA / S10-C spec blob / client /
#      it() counts / contract state from here)
STAGE=receipts
git diff --binary "$H" HEAD > "$E/s10c-${H:0:12}-to-${HEAD:0:12}.patch"
git diff --name-status "$H" HEAD > "$E/MANIFEST-name-status-${H:0:12}-to-${HEAD:0:12}.txt"
{ echo "base=$H"; echo "base_tree=$BASE_TREE"; echo "s10b_head=$S10B_HEAD (ancestor of base)"; echo "harness_base=$HARNESS_BASE_HEAD (ancestor of base)"; echo "head=$HEAD"; echo "tree=$HTREE"
  echo "migrations_tree=$(git rev-parse HEAD:prisma/migrations) dirs=$MIGRATION_DIRS last=$LAST_MIGRATION prisma_delta=none"
  echo "delta=$DELTA"
  for f in $FILES; do echo "blob $f $(git rev-parse HEAD:$f) sha256=$(sha "$f")"; done
  for f in $FROZEN_FILES; do echo "unchanged $f $(git rev-parse HEAD:$f) sha256=$(sha "$f")"; done
  echo "contract_state=$CONTRACT_STATE blob=$CONTRACT_BLOB_NOW sha256=$CONTRACT_SHA_NOW base_blob=$CONTRACT_BLOB base_sha256=$SHA_CONTRACT_JSON paths $PATHS_DIFF"
  echo "postgen_client index_dts=$NM_IDX schema=$NM_SCH engine=$NM_ENG matches_s10b=$PG_MATCH (in $W/node_modules/.prisma/client; donor unchanged $D_IDX1/$D_SCH1)"
  echo "it_count $S10B_SPEC=$IT_S10B_H $S10C_SPEC=$IT_S10C_H total=$((IT_S10B_H + IT_S10C_H))"
  echo "branch=$(git rev-parse --abbrev-ref HEAD)"; git log -1 --format='author=%an <%ae>%ncommitter=%cn <%ce>%ndate=%cI'
  echo "hooks raw pre-commit=$HP commit-msg=$HC normalized pre-commit=$NP commit-msg=$NC ref_root=$HOOK_REF_ROOT lefthook=$LHV"
  echo "prettier=$V prefix=$B"; echo "donor=$DONOR hidden_lock=$NM_HIDDEN_LOCK"; echo "lock_inode=$CUR_INODE"; } > "$E/HEAD-${HEAD:0:12}.txt"
( cd "$E" && sha256sum * preformat/* postformat/* > SHA256SUMS ) 2>/dev/null
STAGE=done; log "DONE head=$HEAD tree=$HTREE contract_state=$CONTRACT_STATE (not pushed; parent owns landing; PG proof is a separate grant via ../binding/v1)"; finish 0
