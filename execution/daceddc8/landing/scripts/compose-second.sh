#!/usr/bin/env bash
# compose-second.sh: compose the SECOND candidate onto the landed FIRST head. It makes one genuine-hook merge
# commit as Bradley, regenerates and checks the contract, and runs the affected Jest suites. No push.
# DRAFT, NOT EXECUTED by the planner (LAND-PREP-1). It runs only under a parent composition grant and in the
# canonical heavy slot (queue item 6). The canonical lock is taken nonblocking in THIS process and held to exit.
#
# Usage (recommended: SECOND=s7l after FIRST=s8c landed; the symmetric SECOND=s8c is supported):
#   SECOND=s7l SECOND_HEAD=<40-hex> FIRST_HEAD=<40-hex, == remote integration/importer> \
#     timeout -k 30 5400 bash compose-second.sh
#
# The first failure stops the run. State is preserved for disposition: there is no merge --abort, no retry and no
# cleanup of the worktree.
# Exit codes: 64 usage, 70 env/runtime, 71 hooks/bypass, 72 fetch, 73 identity/contract, 74 lineage/merge,
#             75 lock, 79 jest, 80 commit.
. "$(dirname "$(readlink -f "$0")")/landing-lib.sh"

: "${SECOND:=s7l}"; : "${SECOND_HEAD:?SECOND_HEAD required}"; : "${FIRST_HEAD:?FIRST_HEAD required}"
FIRST=$(other_lane "$SECOND")
new_run_dir "compose-second-$SECOND"
SUITES_FILE="$LANDING_DIR/analysis/composition-jest-suites.txt"
[ "$(wc -l <"$SUITES_FILE")" = 27 ] || refuse 64 "suite list is not the planned 27 entries"

# ---------- 0. refusals before the slot ----------
refuse_bypass_env
verify_hooks
fetch_objects
TIP=$(remote_sha "$TARGET_REF")
[ "$TIP" = "$FIRST_HEAD" ] || refuse 74 "integration/importer is $TIP; FIRST ($FIRST) must already be landed at $FIRST_HEAD"
check_candidate_lineage "$FIRST" "$FIRST_HEAD"
check_candidate_lineage "$SECOND" "$SECOND_HEAD"
lane_vars "$SECOND"; SLICE=$LANE_SLICE; LABEL=$LANE_LABEL; PFX_LANE=$SECOND
git -C "$REPO" merge-base --is-ancestor "$SECOND_HEAD" "$FIRST_HEAD" && refuse 74 "SECOND already contained in FIRST"
[ "$(git -C "$REPO" merge-base "$FIRST_HEAD" "$SECOND_HEAD")" = "$BASE" ] || refuse 74 "merge-base != $BASE"

# ---------- 1. predicted merge (read-only object computation) ----------
PRED=$(git -C "$REPO" merge-tree --write-tree --name-only "$FIRST_HEAD" "$SECOND_HEAD" 2>"$RUN_DIR/merge-tree.err"); rc=$?
PRED_TREE=$(printf '%s\n' "$PRED" | head -1)
[ $rc = 0 ] || refuse 74 "merge-tree reports conflicts rc=$rc: $(printf '%s' "$PRED" | tr '\n' ' ')"
DELTA=$(git -C "$REPO" diff --name-only "$PRE_FOLLOWUP_MERGED_TREE" "$PRED_TREE" | sort | tr '\n' ' ')
case "$DELTA" in
  ""|"$S7L_FOLLOWUP_PATH "|"$S8C_FOLLOWUP_PATH "|"$S7L_FOLLOWUP_PATH $S8C_FOLLOWUP_PATH ") ;;
  *) refuse 74 "predicted tree differs from the plan's merge beyond the two follow-ups: [$DELTA]" ;;
esac
[ "$(git -C "$REPO" rev-parse "$PRED_TREE:$CONTRACT")" = "$CONTRACT_MERGED_BLOB" ] || refuse 73 "predicted contract blob != $CONTRACT_MERGED_BLOB"
log "PREDICTED tree=$PRED_TREE delta_vs_plan=[${DELTA:-none}] contract_blob=$CONTRACT_MERGED_BLOB"

# ---------- 2. canonical heavy slot ----------
[ -e "$LOCK" ] || refuse 75 "canonical lock file absent: $LOCK (never created or replaced here)"
exec 9>>"$LOCK"; flock -n 9 || refuse 75 "canonical lock busy; not waiting"
log "SLOT acquired pid=$$ fd9 inode=$(stat -c %i "$LOCK")"
P=$(pgrep -af 'jest|tsc|prisma|postgres|prettier|lefthook' | grep -v -e "$$" -e compose-second || true)
[ -z "$P" ] || refuse 70 "relevant live processes: $P"

# ---------- 3. fresh composition worktree + runtime (no install, no generate) ----------
WT=/home/user/workspace/worktrees/daceddc8-land-$SLICE
BR=land/$SLICE
[ -e "$WT" ] && refuse 70 "$WT exists"
git -C "$REPO" rev-parse -q --verify "refs/heads/$BR" >/dev/null && refuse 70 "local branch $BR exists"
git -C "$REPO" worktree add -b "$BR" "$WT" "$FIRST_HEAD" >>"$RUN_DIR/worktree.log" 2>&1 || refuse 70 "worktree add failed"
cd "$WT" || refuse 70 "cd $WT"
# The combined schema is byte-identical to S7-L's, so S7-L's generated client is the correct one in either order.
SRC_NM=$S7L_WT/node_modules
[ -d "$SRC_NM" ] && [ ! -L "$SRC_NM" ] || refuse 70 "$SRC_NM missing or a symlink"
[ "$(sha "$SRC_NM/.package-lock.json")" = "$NM_LOCK_SHA256" ] || refuse 70 "source hidden lock mismatch"
[ "$(sha "$SRC_NM/.prisma/client/index.d.ts")" = "$S7L_CLIENT_SHA256" ] || refuse 70 "source client != $S7L_CLIENT_SHA256"
[ "$(sha "$SRC_NM/.prisma/client/schema.prisma")" = "$S7L_CLIENT_SCHEMA_SHA256" ] || refuse 70 "source client schema mismatch"
cp -a "$SRC_NM" "$WT/node_modules" || refuse 70 "cp -a node_modules failed"
[ "$(sha node_modules/.package-lock.json)" = "$NM_LOCK_SHA256" ] && [ "$(sha node_modules/.prisma/client/index.d.ts)" = "$S7L_CLIENT_SHA256" ] \
  || refuse 70 "copied runtime identity mismatch"
PFX=$RUNTIME_ROOT/$PFX_LANE/tools/prettier-3.9.9
( cd "$PFX" && sha256sum -c --quiet "$PFX_MANIFEST" ) >"$RUN_DIR/prefix-verify.log" 2>&1 || refuse 70 "prettier prefix manifest check failed"
[ "$(wc -l <"$PFX_MANIFEST")" = 56 ] || refuse 70 "prefix manifest is not 56 files"
[ "$(readlink "$PFX/bin/prettier")" = ../lib/node_modules/prettier/bin/prettier.cjs ] || refuse 70 "prettier bin link wrong"
export NODE_OPTIONS=--max-old-space-size=4096 npm_config_prefix="$PFX" npm_config_offline=true \
       npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false PRISMA_HIDE_UPDATE_MESSAGE=1
export GIT_AUTHOR_NAME="$AUTHOR_NAME" GIT_AUTHOR_EMAIL="$AUTHOR_EMAIL" GIT_COMMITTER_NAME="$AUTHOR_NAME" GIT_COMMITTER_EMAIL="$AUTHOR_EMAIL"
V=$(npx --no-install prettier --version 2>>"$RUN_DIR/run.log"); [ "$V" = 3.9.9 ] || refuse 70 "npx prettier is '$V'"
log "RUNTIME wt=$WT branch=$BR node=$(node -v) nm_lock=$NM_LOCK_SHA256 client=$S7L_CLIENT_SHA256 prettier=$V prefix=$PFX heap=4096"

# ---------- 4. merge without committing (the commit below runs the genuine pre-commit + commit-msg hooks) ----------
git merge --no-ff --no-commit "$SECOND_HEAD" >"$RUN_DIR/merge.log" 2>&1; rc=$?
[ $rc = 0 ] || refuse 74 "git merge --no-commit rc=$rc (state preserved, no abort)"
[ "$(git rev-parse MERGE_HEAD)" = "$SECOND_HEAD" ] || refuse 74 "MERGE_HEAD != SECOND_HEAD"
[ -z "$(git diff --name-only --diff-filter=U)" ] || refuse 74 "unmerged paths present"
STAGED_TREE=$(git write-tree)
[ "$STAGED_TREE" = "$PRED_TREE" ] || refuse 74 "staged merge tree $STAGED_TREE != predicted $PRED_TREE"
[ "$(sha prisma/schema.prisma)" = "$COMBINED_SCHEMA_SHA256" ] || refuse 74 "combined schema sha mismatch"
log "MERGED (uncommitted) tree=$STAGED_TREE"

# ---------- 5. contract regeneration from the combined real DTOs (unchanged S7-L generator) + determinism ----------
BEFORE=$(sha "$CONTRACT")
timeout -k 10 900 npm run contract:importer >"$RUN_DIR/contract-regen-1.log" 2>&1; rc=$?
AFTER=$(sha "$CONTRACT")
log "CONTRACT_REGEN_1 rc=$rc before=$BEFORE after=$AFTER expected=$CONTRACT_MERGED_SHA256 version=$(node -e 'console.log(require("./docs/contracts/importer-openapi.json").info.version)')"
[ $rc = 0 ] || refuse 73 "generator failed"
if [ "$AFTER" != "$CONTRACT_MERGED_SHA256" ]; then
  git diff -- "$CONTRACT" >"$RUN_DIR/contract-regen-vs-textual.diff"
  refuse 73 "regenerated contract differs from the textual merge; diff preserved; landing-changed bytes need parent classification"
fi
SCRATCH=$RUN_DIR/contract-scratch.json
IMPORTER_CONTRACT_OUT=$SCRATCH timeout -k 10 900 npm run contract:importer >"$RUN_DIR/contract-regen-2.log" 2>&1; rc=$?
[ $rc = 0 ] && cmp -s "$SCRATCH" "$CONTRACT" || refuse 73 "second cold-process regeneration differs (nondeterminism) rc=$rc"
git diff --quiet -- "$CONTRACT" || refuse 73 "worktree contract differs from the staged merge (index)"
log "CONTRACT deterministic: two cold-process runs byte-identical to the textual merge blob $CONTRACT_MERGED_BLOB"

# ---------- 6. affected Jest suites (import closure spans both candidates), heap 4096 ----------
mapfile -t SUITES <"$SUITES_FILE"
for s in "${SUITES[@]}"; do [ -f "$s" ] || refuse 79 "suite missing: $s"; done
timeout -k 30 2400 ./node_modules/.bin/jest --ci --runTestsByPath "${SUITES[@]}" >"$RUN_DIR/jest-affected.raw.log" 2>&1; rc=$?
log "JEST rc=$rc $(grep -E '^(Test Suites|Tests):' "$RUN_DIR/jest-affected.raw.log" | tr '\n' ' ')"
[ $rc = 0 ] || refuse 79 "affected Jest failed (raw log preserved)"
git diff --quiet || refuse 79 "a gate modified tracked files (worktree != staged merge)"
[ "$(git write-tree)" = "$PRED_TREE" ] || refuse 79 "index drifted from the predicted tree"

# ---------- 7. genuine hooked merge commit (lefthook pre-commit: R75, tsc, eslint, prettier; commit-msg: R3) ----------
SHORT2=${SECOND_HEAD:0:8}; SHORT1=${FIRST_HEAD:0:8}
MSG=$RUN_DIR/commit-message.txt
if [ "$SECOND" = s7l ]; then
  printf 'Merge %s (%s) into integration/importer\n\nComposes the accepted S7-L candidate onto the landed S8-C head %s. docs/contracts/importer-openapi.json\nis regenerated from the combined DTOs by the unchanged S7-L generator and is byte-identical to the textual\nmerge. It adds programs to the two reconstruct family enums under contract version 2.0.0-c1-s2.0.\nNon-production branch. Production promotion stays the separate owner stage.\n' "$LABEL" "$SHORT2" "$SHORT1" >"$MSG"
else
  printf 'Merge %s (%s) into integration/importer\n\nComposes the accepted S8-C candidate onto the landed S7-L head %s. docs/contracts/importer-openapi.json\nis regenerated from the combined DTOs by the unchanged S7-L generator and is byte-identical to the textual\nmerge. It adds programs to the two reconstruct family enums under contract version 2.0.0-c1-s2.0.\nNon-production branch. Production promotion stays the separate owner stage.\n' "$LABEL" "$SHORT2" "$SHORT1" >"$MSG"
fi
grep -iqE "$BANNED_RE" "$MSG" && refuse 80 "commit message contains a banned token"
timeout -k 30 2400 git commit -F "$MSG" >"$RUN_DIR/commit.raw.log" 2>&1; rc=$?
tail -40 "$RUN_DIR/commit.raw.log" >>"$RUN_DIR/run.log"
[ $rc = 0 ] || refuse 80 "hooked commit rc=$rc (hooks are genuine; no bypass; state preserved)"
M=$(git rev-parse HEAD); MT=$(git rev-parse 'HEAD^{tree}')
[ "$(git rev-list --parents -n1 HEAD)" = "$M $FIRST_HEAD $SECOND_HEAD" ] || refuse 80 "merge parents are not (FIRST_HEAD, SECOND_HEAD)"
[ "$MT" = "$PRED_TREE" ] || refuse 80 "committed tree $MT != predicted $PRED_TREE (a hook rewrote bytes?)"
check_identity_range "$FIRST_HEAD" "$M"
[ -z "$(git status --porcelain --untracked-files=no)" ] || refuse 80 "worktree not clean after commit"
log "COMMITTED merge=$M tree=$MT parents=$FIRST_HEAD,$SECOND_HEAD"

# ---------- 8. export ----------
X=$RUN_DIR/export; mkdir -p "$X" "$LANDING_DIR/state"
git bundle create "$X/land-$SLICE-${M:0:12}.bundle" "$BASE..$M" >>"$RUN_DIR/run.log" 2>&1 \
  && git bundle verify "$X/land-$SLICE-${M:0:12}.bundle" >>"$RUN_DIR/run.log" 2>&1 || refuse 80 "bundle export failed"
git diff --name-status "$FIRST_HEAD" "$M" >"$X/name-status-vs-first.txt"
{ echo "base=$BASE"; echo "first=$FIRST $FIRST_HEAD"; echo "second=$SECOND $SECOND_HEAD"; echo "merge=$M"; echo "tree=$MT"
  echo "contract_blob=$(git rev-parse "$M:$CONTRACT") sha256=$CONTRACT_MERGED_SHA256"; git log -1 --format='author=%an <%ae>%ncommitter=%cn <%ce>%ndate=%cI' "$M"; } >"$X/COMPOSE_RECEIPT.txt"
( cd "$X" && sha256sum ./* >SHA256SUMS )
printf 'SECOND=%s\nSECOND_HEAD=%s\nFIRST_HEAD=%s\nMERGE=%s\nTREE=%s\nRECEIPT=%s\n' "$SECOND" "$SECOND_HEAD" "$FIRST_HEAD" "$M" "$MT" "$X/COMPOSE_RECEIPT.txt" \
  >"$LANDING_DIR/state/compose-$SECOND.env"
unset npm_config_prefix
log "DONE compose merge=$M tree=$MT (lock fd9 released at exit; lock file preserved)"
exit 0
