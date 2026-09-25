#!/usr/bin/env bash
# land-ff.sh: land a commit that already sits on top of the current integration/importer tip, by ordinary FF.
# LAND-3 and later. No composition, no merge commit, no lock (no local gates run here; remote CI is the gate).
#
#   SLUG=s9-0 HEAD_SHA=<40-hex> EXPECTED_TIP=<40-hex current remote tip> TITLE="Land S9-0: ..." \
#     [ALLOWED_PATH_RE='^docs/'] bash land-ff.sh stage     # push land/<slug>, open PR (base integration/importer)
#   SLUG=s9-0 bash land-ff.sh ff                           # CI green -> FF integration/importer -> verify
#
# stage refuses unless all of these hold:
#   - HEAD_SHA descends from EXPECTED_TIP;
#   - no merges in EXPECTED_TIP..HEAD_SHA;
#   - every commit has Bradley as author and committer, no trailers, and no banned tokens;
#   - every changed path matches ALLOWED_PATH_RE;
#   - the remote tip equals EXPECTED_TIP;
#   - land/<slug> is absent or already equal to HEAD_SHA.
# ff reads state/ff-<slug>.env only. Environment overrides are refused. It re-checks the remote tip, the PR head and
# CI, then makes one ordinary push. It never writes main, never forces, and never uses the merge button.
. "$(dirname "$(readlink -f "$0")")/landing-lib.sh"

STEP=${1:-}; case "$STEP" in stage|ff) ;; *) refuse 64 "usage: land-ff.sh stage|ff" ;; esac
: "${SLUG:?SLUG required}"; [[ "$SLUG" =~ ^[a-z0-9][a-z0-9.-]*$ ]] || refuse 64 "bad SLUG"
new_run_dir "land-ff-$STEP-$SLUG"
STATE="$LANDING_DIR/state/ff-$SLUG.env"; mkdir -p "$LANDING_DIR/state"
refuse_bypass_env
fetch_objects

if [ "$STEP" = stage ]; then
  : "${HEAD_SHA:?}" "${EXPECTED_TIP:?}" "${TITLE:?}"; ALLOWED_PATH_RE=${ALLOWED_PATH_RE:-'^docs/'}
  is_full_sha "$HEAD_SHA" && is_full_sha "$EXPECTED_TIP" || refuse 64 "HEAD_SHA/EXPECTED_TIP must be 40-hex"
  [ -e "$STATE" ] && refuse 70 "state $STATE exists; no re-stage"
  git -C "$REPO" cat-file -e "$HEAD_SHA^{commit}" 2>/dev/null || refuse 74 "HEAD_SHA not present locally"
  [ "$(remote_sha "$TARGET_REF")" = "$EXPECTED_TIP" ] || refuse 78 "remote integration/importer != $EXPECTED_TIP"
  [ "$HEAD_SHA" != "$EXPECTED_TIP" ] || refuse 74 "HEAD_SHA equals the tip (nothing to land)"
  git -C "$REPO" merge-base --is-ancestor "$EXPECTED_TIP" "$HEAD_SHA" || refuse 74 "HEAD_SHA does not descend from $EXPECTED_TIP"
  [ -z "$(git -C "$REPO" rev-list --merges "$EXPECTED_TIP..$HEAD_SHA")" ] || refuse 74 "merge commits in range"
  check_identity_range "$EXPECTED_TIP" "$HEAD_SHA"
  PATHS=$(git -C "$REPO" diff --name-only "$EXPECTED_TIP" "$HEAD_SHA")
  [ -n "$PATHS" ] || refuse 74 "empty diff"
  for p in $PATHS; do [[ "$p" =~ $ALLOWED_PATH_RE ]] || refuse 74 "path $p outside ALLOWED_PATH_RE=$ALLOWED_PATH_RE"; done
  git -C "$REPO" diff --name-only "$EXPECTED_TIP" "$HEAD_SHA" >"$RUN_DIR/paths.txt"
  MIG=0; grep -q '^prisma/migrations/' "$RUN_DIR/paths.txt" && MIG=1
  push_land_ref "$HEAD_SHA" "land/$SLUG"
  BODY=$RUN_DIR/pr-body.md
  cat >"$BODY" <<EOF
Exact bytes \`$HEAD_SHA\` (tree \`$(git -C "$REPO" rev-parse "$HEAD_SHA^{tree}")\`) on top of \`integration/importer\` \`$EXPECTED_TIP\`. This is a fast-forward: $(git -C "$REPO" rev-list --count "$EXPECTED_TIP..$HEAD_SHA") commit(s), Bradley Gleave, no trailers.

- Paths: $(wc -l <"$RUN_DIR/paths.txt"), all matching \`$ALLOWED_PATH_RE\`.
- Landing: one ordinary fast-forward push of this exact head after green CI. The GitHub merge button is not used. Non-production. \`main\` is untouched (#530 stays owner-reserved).
EOF
  URL=$(gh pr create -R "$GH_REPO" --base integration/importer --head "land/$SLUG" --title "$TITLE" --body-file "$BODY" 2>>"$RUN_DIR/gh.log") \
    || refuse 77 "gh pr create failed"
  printf 'SLUG=%s\nHEAD_SHA=%s\nEXPECTED_TIP=%s\nMIG=%s\nPR=%s\nURL=%s\n' "$SLUG" "$HEAD_SHA" "$EXPECTED_TIP" "$MIG" "${URL##*/}" "$URL" >"$STATE"
  log "STAGED PR #${URL##*/} $URL head=$HEAD_SHA base_tip=$EXPECTED_TIP mig=$MIG"
  exit 0
fi

[ -z "${HEAD_SHA:-}${EXPECTED_TIP:-}" ] || refuse 64 "ff takes values only from $STATE"
[ -f "$STATE" ] || refuse 70 "no stage state $STATE"
get(){ grep "^$1=" "$STATE" | cut -d= -f2-; }
HEAD_SHA=$(get HEAD_SHA); EXPECTED_TIP=$(get EXPECTED_TIP); MIG=$(get MIG); PR=$(get PR)
grep -q '^LANDED_TIP=' "$STATE" && refuse 70 "already landed per $STATE"
[[ "$PR" =~ ^[0-9]+$ ]] || refuse 70 "bad PR in state"
[ "$(remote_sha "refs/heads/land/$SLUG")" = "$HEAD_SHA" ] || refuse 76 "land/$SLUG moved"
check_identity_range "$EXPECTED_TIP" "$HEAD_SHA"
check_pr_ci "$PR" "$HEAD_SHA" "$MIG"
if [ "$(gh pr view "$PR" -R "$GH_REPO" --json isDraft --jq .isDraft)" = true ]; then
  gh pr ready "$PR" -R "$GH_REPO" >>"$RUN_DIR/gh.log" 2>&1 || refuse 77 "gh pr ready failed"
fi
ff_push_integration "$EXPECTED_TIP" "$HEAD_SHA"
sleep 5
log "PR #$PR state=$(gh pr view "$PR" -R "$GH_REPO" --json state --jq .state)"
printf 'LANDED_TIP=%s\nLANDED_AT=%s\n' "$HEAD_SHA" "$(ts)" >>"$STATE"
log "DONE ff $SLUG integration/importer=$HEAD_SHA"
