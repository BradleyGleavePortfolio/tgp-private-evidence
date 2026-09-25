#!/usr/bin/env bash
# land-second.sh: stage and land the composed SECOND candidate (the merge commit from compose-second.sh) by ordinary
# fast-forward of integration/importer. DRAFT, NOT EXECUTED by the planner (LAND-PREP-1). Parent-executed. No lock.
#
#   SECOND=s8c [DRAFT=1] bash land-second.sh stage     (LAND-1 order; SECOND=s7l is the symmetric case)
#   SECOND=s8c FIXUP_HEAD=<40-hex> REVIEW_RECORD=<path naming FIXUP_HEAD with GO> bash land-second.sh advance
#       LAND-2 L2-1 option (a): ordinary FF of land/<slice> from MERGE to ONE reviewed, hooked, test-only fix-up commit
#       (FIXUP_PATH only) on top of MERGE, then mark the PR ready. The landing head becomes FIXUP_HEAD.
#   SECOND=s8c ACCEPT_RECORD=<path naming SECOND_HEAD with ACCEPT> bash land-second.sh ff
# The SECOND_HEAD, FIRST_HEAD and MERGE values come only from state/compose-<lane>.env, which compose-second.sh
# writes. Environment overrides are refused.
. "$(dirname "$(readlink -f "$0")")/landing-lib.sh"

STEP=${1:-}; case "$STEP" in stage|advance|ff) ;; *) refuse 64 "usage: land-second.sh stage|advance|ff" ;; esac
FIXUP_PATH=test/scout/g2-s8c-db-guard.spec.ts   # the only path the L2-1 fix-up may touch
: "${SECOND:=s8c}"; lane_vars "$SECOND"
new_run_dir "land-second-$STEP-$SECOND"
CS="$LANDING_DIR/state/compose-$SECOND.env"; [ -f "$CS" ] || refuse 70 "no compose state $CS"
[ -z "${MERGE:-}${SECOND_HEAD:-}${FIRST_HEAD:-}" ] || refuse 64 "do not pass MERGE/SECOND_HEAD/FIRST_HEAD; they come from $CS"
get(){ grep "^$1=" "$CS" | cut -d= -f2-; }
SECOND_HEAD=$(get SECOND_HEAD); FIRST_HEAD=$(get FIRST_HEAD); MERGE=$(get MERGE); TREE=$(get TREE); RECEIPT=$(get RECEIPT)
for v in "$SECOND_HEAD" "$FIRST_HEAD" "$MERGE" "$TREE"; do is_full_sha "$v" || refuse 70 "bad sha in state: $v"; done
[ -f "$RECEIPT" ] || refuse 70 "compose receipt missing"
FIRST=$(other_lane "$SECOND")
STATE="$LANDING_DIR/state/second-$SECOND.env"

refuse_bypass_env
fetch_objects
TIP=$(remote_sha "$TARGET_REF")
[ "$TIP" = "$FIRST_HEAD" ] || refuse 78 "integration/importer is $TIP, expected landed FIRST $FIRST_HEAD"
check_candidate_lineage "$FIRST" "$FIRST_HEAD"
check_candidate_lineage "$SECOND" "$SECOND_HEAD"
lane_vars "$SECOND"
[ "$(git -C "$REPO" rev-list --parents -n1 "$MERGE")" = "$MERGE $FIRST_HEAD $SECOND_HEAD" ] || refuse 74 "merge parents mismatch"
[ "$(git -C "$REPO" rev-parse "$MERGE^{tree}")" = "$TREE" ] || refuse 74 "merge tree mismatch"
[ "$(git -C "$REPO" rev-parse "$MERGE:$CONTRACT")" = "$CONTRACT_MERGED_BLOB" ] || refuse 73 "contract blob in merge != $CONTRACT_MERGED_BLOB"
git -C "$REPO" merge-base --is-ancestor "$MERGE" "refs/heads/land/$LANE_SLICE" || refuse 74 "local land/$LANE_SLICE does not contain MERGE"
check_identity_range "$FIRST_HEAD" "$MERGE"
check_main_untouched
MIG=0; [ "$SECOND" = s7l ] && MIG=1   # S7-L carries 20270123000000_scout_run_lifecycle_expand -> Migration Dry-Run runs
if [ "$SECOND" = s7l ]; then TITLE="Land S7-L: server-owned import run lifecycle, composed with S8-C (${SECOND_HEAD:0:8})"
else TITLE="Land S8-C: native reconstruct writers, composed with S7-L (${SECOND_HEAD:0:8})"; fi

if [ "$STEP" = stage ]; then
  [ -e "$STATE" ] && refuse 70 "state $STATE exists; no re-stage"
  # LAND-2 grants only land/<slice>. The land/<slice>-accepted convenience ref is opt-in (PUSH_ACCEPTED_REF=1).
  [ "${PUSH_ACCEPTED_REF:-0}" = 1 ] && push_land_ref "$SECOND_HEAD" "land/$LANE_SLICE-accepted"
  push_land_ref "$MERGE" "land/$LANE_SLICE"
  BODY="$RUN_DIR/pr-body.md"
  cat >"$BODY" <<EOF
Composition of the accepted $LANE_LABEL candidate \`$SECOND_HEAD\` onto the landed \`integration/importer\` head \`$FIRST_HEAD\`. It is one ordinary merge commit, \`$MERGE\` (tree \`$TREE\`), made by Bradley Gleave with the genuine hooks.

- The textual merge is conflict-free. The only path both candidates touch is \`$CONTRACT\`. It was regenerated from the combined DTOs with the unchanged S7-L generator and is byte-identical to the textual merge (blob \`${CONTRACT_MERGED_BLOB:0:12}\`). A cold-process regeneration also matched.
- Local composition gates: the hooks ran R75, tsc (heap 4096), eslint and prettier 3.9.9, and the 27 Jest suites whose import closure spans both candidates passed. Receipt: \`$(basename "$(dirname "$(dirname "$RECEIPT")")")\`.
- Landing: an ordinary fast-forward push of this exact merge after green CI. The GitHub merge button is not used. Non-production. \`main\` is untouched (#530 stays owner-reserved).
- Danger, CodeQL, R75, SBOM and Infra Lint trigger only for PRs whose base is \`main\`, so they do not run here (see #539).
EOF
  DRAFT_FLAG=(); [ "${DRAFT:-0}" = 1 ] && DRAFT_FLAG=(--draft)
  URL=$(gh pr create -R "$GH_REPO" --base integration/importer --head "land/$LANE_SLICE" --title "$TITLE" \
        --body-file "$BODY" "${DRAFT_FLAG[@]}" 2>>"$RUN_DIR/gh.log") || refuse 77 "gh pr create failed"
  printf 'SECOND=%s\nMERGE=%s\nPR=%s\nURL=%s\n' "$SECOND" "$MERGE" "${URL##*/}" "$URL" >"$STATE"
  log "STAGED PR #${URL##*/} $URL"
  exit 0
fi

[ -f "$STATE" ] || refuse 70 "no stage state $STATE"
[ "$(grep '^MERGE=' "$STATE" | cut -d= -f2)" = "$MERGE" ] || refuse 70 "stage state merge mismatch"
PR=$(grep '^PR=' "$STATE" | cut -d= -f2); [[ "$PR" =~ ^[0-9]+$ ]] || refuse 70 "bad PR in state"

if [ "$STEP" = advance ]; then
  grep -q '^LANDING_HEAD=' "$STATE" && refuse 70 "advance already recorded in $STATE (no second advance)"
  : "${FIXUP_HEAD:?FIXUP_HEAD required}"; is_full_sha "$FIXUP_HEAD" || refuse 64 "FIXUP_HEAD must be 40-hex"
  git -C "$REPO" cat-file -e "$FIXUP_HEAD^{commit}" 2>/dev/null || refuse 74 "FIXUP_HEAD not present locally"
  [ "$(git -C "$REPO" rev-list --parents -n1 "$FIXUP_HEAD")" = "$FIXUP_HEAD $MERGE" ] || refuse 74 "FIXUP_HEAD is not a single-parent child of MERGE"
  [ "$(git -C "$REPO" diff --name-only "$MERGE" "$FIXUP_HEAD")" = "$FIXUP_PATH" ] || refuse 74 "fix-up touches more than $FIXUP_PATH"
  check_identity_range "$MERGE" "$FIXUP_HEAD"
  [ "$(git -C "$REPO" rev-parse "refs/heads/land/$LANE_SLICE")" = "$FIXUP_HEAD" ] || refuse 74 "local land/$LANE_SLICE != FIXUP_HEAD"
  CWT=/home/user/workspace/worktrees/daceddc8-land-$LANE_SLICE
  [ "$(git -C "$CWT" rev-parse HEAD)" = "$FIXUP_HEAD" ] && [ -z "$(git -C "$CWT" status --porcelain --untracked-files=no)" ] \
    || refuse 74 "composition worktree not clean at FIXUP_HEAD"
  [ -n "${REVIEW_RECORD:-}" ] && [ -f "$REVIEW_RECORD" ] || refuse 75 "review record missing"
  grep -q "$FIXUP_HEAD" "$REVIEW_RECORD" || refuse 75 "review record does not name $FIXUP_HEAD"
  grep -Eq '\bGO\b' "$REVIEW_RECORD" || refuse 75 "review record has no GO"
  grep -Eq '\bNO-GO\b' "$REVIEW_RECORD" && refuse 75 "review record contains NO-GO"
  [ "$(remote_sha "refs/heads/land/$LANE_SLICE")" = "$MERGE" ] || refuse 76 "remote land/$LANE_SLICE is not at MERGE"
  git -C "$REPO" push origin "$FIXUP_HEAD:refs/heads/land/$LANE_SLICE" >>"$RUN_DIR/push.log" 2>&1 || refuse 76 "FF push of land/$LANE_SLICE rejected (no force)"
  [ "$(remote_sha "refs/heads/land/$LANE_SLICE")" = "$FIXUP_HEAD" ] || refuse 76 "ls-remote land/$LANE_SLICE != FIXUP_HEAD"
  log "PUSH land/$LANE_SLICE $MERGE -> $FIXUP_HEAD (ordinary FF, ls-remote verified)"
  sleep 5
  [ "$(gh pr view "$PR" -R "$GH_REPO" --json headRefOid --jq .headRefOid)" = "$FIXUP_HEAD" ] || refuse 77 "PR head did not advance"
  gh pr ready "$PR" -R "$GH_REPO" >>"$RUN_DIR/gh.log" 2>&1 || refuse 77 "gh pr ready failed"
  printf 'LANDING_HEAD=%s\nADVANCED_AT=%s\nREVIEW_RECORD=%s\n' "$FIXUP_HEAD" "$(ts)" "$REVIEW_RECORD" >>"$STATE"
  log "ADVANCED PR #$PR head=$FIXUP_HEAD ready (CI now running; run 'ff' when green)"
  exit 0
fi
[ -z "${FIXUP_HEAD:-}" ] || refuse 64 "FIXUP_HEAD is only accepted by 'advance'"
LANDING_HEAD=$(grep '^LANDING_HEAD=' "$STATE" | cut -d= -f2); LANDING_HEAD=${LANDING_HEAD:-$MERGE}
if [ "$LANDING_HEAD" != "$MERGE" ]; then
  [ "$(git -C "$REPO" rev-list --parents -n1 "$LANDING_HEAD")" = "$LANDING_HEAD $MERGE" ] || refuse 74 "LANDING_HEAD not a child of MERGE"
  [ "$(git -C "$REPO" diff --name-only "$MERGE" "$LANDING_HEAD")" = "$FIXUP_PATH" ] || refuse 74 "LANDING_HEAD delta != $FIXUP_PATH"
  check_identity_range "$MERGE" "$LANDING_HEAD"
fi
check_acceptance "$SECOND" "$SECOND_HEAD" "${ACCEPT_RECORD:-}"
[ "$(remote_sha "refs/heads/land/$LANE_SLICE")" = "$LANDING_HEAD" ] || refuse 76 "land/$LANE_SLICE moved"
check_pr_ci "$PR" "$LANDING_HEAD" "$MIG"
if [ "$(gh pr view "$PR" -R "$GH_REPO" --json isDraft --jq .isDraft)" = true ]; then
  gh pr ready "$PR" -R "$GH_REPO" >>"$RUN_DIR/gh.log" 2>&1 || refuse 77 "gh pr ready failed"
fi
ff_push_integration "$FIRST_HEAD" "$LANDING_HEAD"
git -C "$REPO" merge-base --is-ancestor "$SECOND_HEAD" "$(remote_sha "$TARGET_REF")" || refuse 78 "SECOND_HEAD not contained after landing"
sleep 5
log "PR #$PR state=$(gh pr view "$PR" -R "$GH_REPO" --json state --jq .state)"
printf 'LANDED_TIP=%s\nLANDED_AT=%s\n' "$LANDING_HEAD" "$(ts)" >>"$STATE"
log "DONE ff second=$SECOND integration/importer=$LANDING_HEAD"
