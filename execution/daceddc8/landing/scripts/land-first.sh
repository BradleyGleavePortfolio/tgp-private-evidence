#!/usr/bin/env bash
# land-first.sh: land the FIRST accepted candidate onto integration/importer by ordinary fast-forward.
# DRAFT, NOT EXECUTED by the planner (LAND-PREP-1). Parent-executed. No lock, no local heavy work.
#
# Usage (recommended order: FIRST=s8c; the symmetric FIRST=s7l is also supported, see PLAN.md section 1):
#   FIRST=s8c FIRST_HEAD=<40-hex> bash land-first.sh preflight
#   FIRST=s8c FIRST_HEAD=<40-hex> [DRAFT=1] bash land-first.sh stage
#       Pushes land/<slice>-accepted and land/<slice> at the exact head, then opens the PR to integration/importer.
#       DRAFT=1 lets the parent run CI while the PG proof or acceptance is pending. It is still a non-production
#       remote write, so use it only if the parent authorises CI before acceptance (PROD-CI-1 precedent).
#   FIRST=s8c FIRST_HEAD=<40-hex> ACCEPT_RECORD=<path> bash land-first.sh ff
#       Requires acceptance, PR head == exact head, green CI (Danger title = class C), and remote tip == BASE.
#       Then it does one ordinary FF push and verifies with ls-remote.
#
# Exit codes: 64 usage, 70 env, 72 fetch, 73 identity, 74 lineage, 75 acceptance, 76 push, 77 CI, 78 FF.
. "$(dirname "$(readlink -f "$0")")/landing-lib.sh"

STEP=${1:-}; case "$STEP" in preflight|stage|ff) ;; *) refuse 64 "usage: land-first.sh preflight|stage|ff" ;; esac
: "${FIRST:=s8c}"; : "${FIRST_HEAD:?FIRST_HEAD (full sha of the accepted first candidate) is required}"
lane_vars "$FIRST"
new_run_dir "land-first-$STEP-$FIRST"
STATE="$LANDING_DIR/state/first-$FIRST.env"; mkdir -p "$LANDING_DIR/state"

# ---- common preflight (every step) ----
refuse_bypass_env
fetch_objects
TIP=$(remote_sha "$TARGET_REF")
[ "$TIP" = "$BASE" ] || refuse 78 "integration/importer is $TIP, expected $BASE (FIRST lands only on the plan base)"
[ "$(git -C "$REPO" rev-parse refs/remotes/origin/integration/importer)" = "$BASE" ] || refuse 72 "fetched tracking ref != $BASE"
check_candidate_lineage "$FIRST" "$FIRST_HEAD"
git -C "$REPO" merge-base --is-ancestor "$BASE" "$FIRST_HEAD" || refuse 74 "not a fast-forward of $BASE"
[ -z "$(git -C "$LANE_WT" status --porcelain --untracked-files=no)" ] || refuse 74 "$LANE_WT has tracked modifications; exact head not proven clean"
[ "$(git -C "$LANE_WT" rev-parse HEAD)" = "$FIRST_HEAD" ] || refuse 74 "$LANE_WT HEAD != FIRST_HEAD"
check_main_untouched
SHORT=${FIRST_HEAD:0:8}
if [ "$FIRST" = s8c ]; then
  TITLE="Land S8-C: native reconstruct writers for workouts and programs ($SHORT)"
  MIG=0
else
  TITLE="Land S7-L: server-owned import run lifecycle ($SHORT)"
  MIG=1
fi
log "PREFLIGHT ok first=$FIRST head=$FIRST_HEAD tree=$(git -C "$REPO" rev-parse "$FIRST_HEAD^{tree}") tip=$TIP title='$TITLE'"
[ "$STEP" = preflight ] && { log "DONE preflight"; exit 0; }

if [ "$STEP" = stage ]; then
  [ -e "$STATE" ] && refuse 70 "state $STATE exists; a stage already ran (parent must disposition, no re-stage)"
  push_land_ref "$FIRST_HEAD" "land/$LANE_SLICE-accepted"
  push_land_ref "$FIRST_HEAD" "land/$LANE_SLICE"
  BODY="$RUN_DIR/pr-body.md"
  cat >"$BODY" <<EOF
Exact candidate bytes for $LANE_LABEL, head \`$FIRST_HEAD\` (tree \`$(git -C "$REPO" rev-parse "$FIRST_HEAD^{tree}")\`). This is a fast-forward of \`integration/importer\` \`${BASE:0:8}\`.

- Lineage: \`${LANE_PARENT:0:8}\` plus one test-only follow-up (\`$LANE_FOLLOWUP\`).
- Author and committer: Bradley Gleave. No trailers.
- Landing: an ordinary fast-forward push of this exact head after acceptance and green CI. The GitHub merge button is not used.
- Scope: \`integration/importer\` only. It is non-production. Nothing here targets \`main\`, which stays the owner-reserved production boundary (#530).
- The Danger PR-title failure is the known class C.
EOF
  DRAFT_FLAG=(); [ "${DRAFT:-0}" = 1 ] && DRAFT_FLAG=(--draft)
  URL=$(gh pr create -R "$GH_REPO" --base integration/importer --head "land/$LANE_SLICE" --title "$TITLE" \
        --body-file "$BODY" "${DRAFT_FLAG[@]}" 2>>"$RUN_DIR/gh.log") || refuse 77 "gh pr create failed"
  PR=${URL##*/}
  printf 'FIRST=%s\nFIRST_HEAD=%s\nPR=%s\nURL=%s\n' "$FIRST" "$FIRST_HEAD" "$PR" "$URL" >"$STATE"
  log "STAGED PR #$PR $URL draft=${DRAFT:-0}"
  exit 0
fi

# ---- ff ----
[ -f "$STATE" ] || refuse 70 "no stage state $STATE"
[ "$FIRST_HEAD" = "$(grep '^FIRST_HEAD=' "$STATE" | cut -d= -f2)" ] || refuse 70 "state head mismatch"
[ "$FIRST" = "$(grep '^FIRST=' "$STATE" | cut -d= -f2)" ] || refuse 70 "state lane mismatch"
PR=$(grep '^PR=' "$STATE" | cut -d= -f2); [[ "$PR" =~ ^[0-9]+$ ]] || refuse 70 "bad PR number in state"
check_acceptance "$FIRST" "$FIRST_HEAD" "${ACCEPT_RECORD:-}"
[ "$(remote_sha "refs/heads/land/$LANE_SLICE")" = "$FIRST_HEAD" ] || refuse 76 "land/$LANE_SLICE moved"
check_pr_ci "$PR" "$FIRST_HEAD" "$MIG"
if [ "$(gh pr view "$PR" -R "$GH_REPO" --json isDraft --jq .isDraft)" = true ]; then
  gh pr ready "$PR" -R "$GH_REPO" >>"$RUN_DIR/gh.log" 2>&1 || refuse 77 "gh pr ready failed"
  log "PR #$PR marked ready (after acceptance)"
fi
ff_push_integration "$BASE" "$FIRST_HEAD"
sleep 5
log "PR #$PR state=$(gh pr view "$PR" -R "$GH_REPO" --json state --jq .state) (GitHub marks MERGED when head is contained in base)"
printf 'LANDED_TIP=%s\nLANDED_AT=%s\n' "$FIRST_HEAD" "$(ts)" >>"$STATE"
log "DONE ff first=$FIRST integration/importer=$FIRST_HEAD"
