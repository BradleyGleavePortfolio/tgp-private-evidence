#!/usr/bin/env bash
# EXEC-42D8C5B5 GH-LANES out-of-band acceptance (automates REVIEW_A "Delta review (0c97a84f)" checklist items 1-5).
# Usage: gh-accept.sh <run_id> <target_sha40> EXPECT_TOTAL_s11=N EXPECT_TOTAL_s10b=N EXPECT_guard=N [EXPECT_<stage>=N ...]
#   run with bash api_credentials ["github"] (gh api through the proxy; git objects from the public GitHub remote).
# Env: ACCEPT_PKG_LOCK_SHA256 (default = accepted tree b7fed5ed...9c55).
# Everything read is downloaded under ghlanes/runs/<label>/accept-<run_id>-a<attempt>-<utc>/ (never overwritten).
# Artifact provenance: exactly the required artifact names, each from this run id/head, created inside its producing job's
# window in the accepted attempt, zip sha256 = GitHub digest, RECEIPTS.sha256 valid, RESULT GH_RUN = run URL + accepted attempt.
# Output: one "CHECK ok ..." line per verified item, then ACCEPT (exit 0); any failure prints "REJECT <reason>" (exit 1;
# usage/tooling errors exit 2). Trust anchors are fixed here, never read from the run: harness, repo, workflow path.
set -uo pipefail
APPROVED_HARNESS=0c97a84f1ca833bacdd7c20c2cfabf20430504a9
REPO=BradleyGleavePortfolio/growth-project-backend
URL=https://github.com/$REPO.git
WF_PATH=.github/workflows/proof-lanes.yml
PKG_ACCEPT=${ACCEPT_PKG_LOCK_SHA256:-b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55}
EVID=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)   # execution/42d8c5b5
OUTLOG=""
say(){ echo "$*"; [ -n "$OUTLOG" ] && echo "$*" >>"$OUTLOG"; }
ok(){ say "CHECK ok $*"; }
reject(){ say "REJECT $*"; exit 1; }
usage(){ echo "usage: gh-accept.sh <run_id> <target_sha40> EXPECT_TOTAL_s11=N EXPECT_TOTAL_s10b=N EXPECT_guard=N [EXPECT_<stage>=N ...]" >&2; exit 2; }
[ $# -ge 2 ] || usage
RUN_ID=$1; TARGET=$2; shift 2
[[ "$RUN_ID" =~ ^[0-9]+$ ]] || usage
[[ "$TARGET" =~ ^[0-9a-f]{40}$ ]] || usage
declare -A PIN=()
for kv in "$@"; do [[ "$kv" =~ ^(EXPECT_[A-Za-z0-9_-]+)=([0-9]+)$ ]] || { echo "bad pin '$kv'" >&2; usage; }
  [ -z "${PIN[${BASH_REMATCH[1]}]:-}" ] || { echo "duplicate pin ${BASH_REMATCH[1]}" >&2; usage; }; PIN[${BASH_REMATCH[1]}]=$((10#${BASH_REMATCH[2]})); done
for k in EXPECT_TOTAL_s11 EXPECT_TOTAL_s10b EXPECT_guard; do [ -n "${PIN[$k]:-}" ] || { echo "minimum pin $k missing" >&2; usage; }; done
for t in gh git jq unzip sha256sum; do command -v $t >/dev/null || { echo "missing tool $t" >&2; exit 2; }; done
api(){ timeout 120 gh api "$@"; }

# ---- 4a. run metadata (fetched first: it names the run commit and label)
RJ=$(api "repos/$REPO/actions/runs/$RUN_ID") || reject "run $RUN_ID not readable via gh api"
BR=$(jq -r .head_branch <<<"$RJ"); HEAD_SHA=$(jq -r .head_sha <<<"$RJ"); ATT=$(jq -r .run_attempt <<<"$RJ")
case "$BR" in proof/run/?*) ;; *) reject "run branch '$BR' is not proof/run/*";; esac
LABEL=${BR#proof/run/}; [[ "$LABEL" =~ ^[A-Za-z0-9._/-]+$ ]] && [[ "$LABEL" != *..* ]] || reject "unsafe label '$LABEL'"
D=$EVID/ghlanes/runs/$LABEL/accept-$RUN_ID-a$ATT-$(date -u +%Y%m%dT%H%M%SZ); mkdir -p "$D" || { echo "cannot create $D" >&2; exit 2; }
OUTLOG=$D/ACCEPTANCE.txt; : >"$OUTLOG"
say "gh-accept run=$RUN_ID target=$TARGET approved_harness=$APPROVED_HARNESS pins=[$(for k in $(printf '%s\n' "${!PIN[@]}" | sort); do printf '%s=%s ' "$k" "${PIN[$k]}"; done)] dir=$D"
say "gh-accept.sh sha256=$(sha256sum "${BASH_SOURCE[0]}" | cut -c1-64)"
echo "$RJ" >"$D/run.json"

# ---- 1. independent git objects: run commit parent + diff, approved harness present
G=$D/git; git init -q --bare "$G"
timeout 300 git -C "$G" fetch -q --no-tags "$URL" "$HEAD_SHA" "$APPROVED_HARNESS" 2>"$D/git-fetch.err" \
  || reject "cannot fetch run commit $HEAD_SHA / approved harness from $URL"
[ "$(git -C "$G" cat-file -t "$APPROVED_HARNESS^{tree}" 2>/dev/null)" = tree ] || reject "approved harness tree not available"
ok "1a approved harness $APPROVED_HARNESS present (tree $(git -C "$G" rev-parse "$APPROVED_HARNESS^{tree}"))"
[[ "$HEAD_SHA" =~ ^[0-9a-f]{40}$ ]] && [ "$(git -C "$G" cat-file -t "$HEAD_SHA")" = commit ] || reject "run head_sha $HEAD_SHA is not a commit"
LS=$(timeout 60 git ls-remote "$URL" "refs/heads/$BR" | cut -f1); [ "$LS" = "$HEAD_SHA" ] || reject "branch $BR now points to '${LS:-none}', not run head $HEAD_SHA"
ok "1b run head_sha $HEAD_SHA is the tip of $BR"
PAR=$(git -C "$G" rev-list --parents -n1 "$HEAD_SHA"); set -- $PAR; [ $# = 2 ] || reject "run commit has $(( $# - 1 )) parents (need exactly 1)"
[ "$2" = "$APPROVED_HARNESS" ] || reject "run commit parent $2 != approved harness $APPROVED_HARNESS"
ok "1c run commit has exactly one parent = $APPROVED_HARNESS"
DIFF=$(git -C "$G" diff --name-only "$APPROVED_HARNESS" "$HEAD_SHA"); echo "$DIFF" >"$D/run-commit-diff.txt"
[ "$DIFF" = PROOF_TARGET ] || reject "run commit diff vs approved harness is [$(tr '\n' ' ' <<<"$DIFF")], not PROOF_TARGET only"
ok "1d git diff --name-only $APPROVED_HARNESS $HEAD_SHA = PROOF_TARGET only"
git -C "$G" show "$HEAD_SHA:PROOF_TARGET" >"$D/PROOF_TARGET" || reject "PROOF_TARGET unreadable"
git -C "$G" show "$APPROVED_HARNESS:proof/lanes.sh" >"$D/lanes.sh.approved" || reject "approved lanes.sh unreadable"

# ---- 2. PROOF_TARGET content
PTL1=$(sed -n 1p "$D/PROOF_TARGET" | tr -d '\r')
[ "$PTL1" = "$TARGET" ] || reject "PROOF_TARGET line 1 '$PTL1' != target $TARGET"
ok "2a PROOF_TARGET names target $TARGET"
declare -A PT=()
while IFS= read -r l; do l=${l%$'\r'}; [ -z "$l" ] && continue; case "$l" in \#*) continue;; esac
  [[ "$l" =~ ^([A-Za-z0-9_-]+)=(.*)$ ]] || reject "PROOF_TARGET line '$l' malformed"
  [ -z "${PT[${BASH_REMATCH[1]}]+x}" ] || reject "PROOF_TARGET duplicate key ${BASH_REMATCH[1]}"; PT[${BASH_REMATCH[1]}]=${BASH_REMATCH[2]}
done < <(sed -n '2,$p' "$D/PROOF_TARGET")
[ "${PT[HARNESS_SHA]:-}" = "$APPROVED_HARNESS" ] || reject "PROOF_TARGET HARNESS_SHA='${PT[HARNESS_SHA]:-}' != approved"
ok "2b PROOF_TARGET HARNESS_SHA = approved harness"
[ -z "${PT[STAGES]+x}" ] && [ -z "${PT[PARTIAL]+x}" ] || reject "PROOF_TARGET has STAGES/PARTIAL (diagnostic run, not authoritative)"
ok "2c STAGES and PARTIAL absent (authoritative FULL request)"
[ -z "${PT[PKG_LOCK_SHA256]+x}" ] || [ "${PT[PKG_LOCK_SHA256]}" = "$PKG_ACCEPT" ] || reject "PROOF_TARGET PKG_LOCK_SHA256 ${PT[PKG_LOCK_SHA256]} != accepted $PKG_ACCEPT"
for k in "${!PT[@]}"; do case "$k" in HARNESS_SHA|PKG_LOCK_SHA256|EXPECT_*) ;; *) reject "PROOF_TARGET unexpected key $k";; esac; done
# ---- 3. pins: PROOF_TARGET's EXPECT_* set must equal the supplied pins exactly
for k in "${!PT[@]}"; do case "$k" in EXPECT_*) [ "${PIN[$k]:-}" = "${PT[$k]}" ] || reject "PROOF_TARGET pin $k=${PT[$k]} not among the supplied pins";; esac; done
for k in "${!PIN[@]}"; do [ "${PT[$k]:-}" = "${PIN[$k]}" ] || reject "supplied pin $k=${PIN[$k]} absent or different in PROOF_TARGET ('${PT[$k]:-}')"; done
ok "3a PROOF_TARGET pin set == supplied pins (${#PIN[@]})"

# target tree + manifest from the approved harness's own lane tables
timeout 300 git -C "$G" fetch -q --no-tags --depth=1 "$URL" "$TARGET" 2>>"$D/git-fetch.err" || reject "target $TARGET not fetchable"
TTREE=$(git -C "$G" rev-parse "$TARGET^{tree}"); TPKG=$(git -C "$G" show "$TARGET:package-lock.json" | sha256sum | cut -c1-64)
[ "$TPKG" = "$PKG_ACCEPT" ] || reject "target package-lock $TPKG != accepted $PKG_ACCEPT"
ok "2d target tree $TTREE, package-lock $TPKG = accepted"
( . "$D/lanes.sh.approved"; manifest "$G" "$TARGET" "" ) >"$D/manifest.txt" 2>"$D/manifest.err" || reject "manifest: $(cat "$D/manifest.err")"
for k in "${!PIN[@]}"; do case "$k" in
  EXPECT_TOTAL_*) grep -q "^${k#EXPECT_TOTAL_} [^ ]* run$" "$D/manifest.txt" || reject "pin $k names a lane with no stage";;
  EXPECT_*) grep -q "^[^ ]* ${k#EXPECT_} run$" "$D/manifest.txt" || reject "pin $k names a stage not run at target";; esac; done
ok "3b manifest (approved lane tables x target tree): $(awk '{printf "%s/%s:%s ", $1,$2,$3}' "$D/manifest.txt")"

# ---- 4. run + job conclusions (this attempt)
[ "$(jq -r .path <<<"$RJ")" = "$WF_PATH" ] && [ "$(jq -r .event <<<"$RJ")" = push ] && [ "$(jq -r .repository.full_name <<<"$RJ")" = "$REPO" ] || reject "run is not a push run of $WF_PATH in $REPO"
[ "$(jq -r .status <<<"$RJ")" = completed ] && [ "$(jq -r .conclusion <<<"$RJ")" = success ] || reject "run status=$(jq -r .status <<<"$RJ") conclusion=$(jq -r .conclusion <<<"$RJ") (need completed/success)"
ok "4a run $RUN_ID attempt $ATT: push of $WF_PATH on $BR, completed/success, head_sha=$HEAD_SHA"
api "repos/$REPO/actions/runs/$RUN_ID/attempts/$ATT/jobs?per_page=100" >"$D/jobs.json" || reject "jobs unreadable"
REQ=("preflight" "aggregate" "lane s11 ALL" "lane s10b ALL"); while read -r L N S; do [ "$S" = run ] && REQ+=("stage $L $N"); done <"$D/manifest.txt"
for j in "${REQ[@]}"; do C=$(jq -r --arg n "$j" '[.jobs[] | select(.name==$n)] | if length==1 then .[0].conclusion else "count=\(length)" end' "$D/jobs.json")
  [ "$C" = success ] || reject "required job '$j' conclusion=$C"; done
NJ=$(jq '.jobs | length' "$D/jobs.json"); NBAD=$(jq '[.jobs[] | select(.conclusion!="success")] | length' "$D/jobs.json")
[ "$NBAD" = 0 ] && [ "$NJ" = "${#REQ[@]}" ] || reject "jobs: $NJ total, $NBAD not success (expected exactly ${#REQ[@]} required jobs)"
ok "4b all ${#REQ[@]} required jobs success: $(printf '%s; ' "${REQ[@]}")"

field(){ grep -m1 "^$1=" "$2" | cut -d= -f2-; }
# ---- 4c. artifacts: provenance bound to THIS run id + accepted attempt (REVIEW_A "Acceptor review" A)
# Expected artifact name -> producing job of the accepted attempt.
declare -A AJOB=([preflight]="preflight" [summary]="aggregate" [lane-s11]="lane s11 ALL" [lane-s10b]="lane s10b ALL")
while read -r L N S; do [ "$S" = run ] && AJOB["stage-$L-$N"]="stage $L $N"; done <"$D/manifest.txt"
RUN_URL="https://github.com/$REPO/actions/runs/$RUN_ID"; GH_RUN_WANT="$RUN_URL attempt=$ATT"
RSTART=$(jq -r .run_started_at <<<"$RJ"); ISO='^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$'
[[ "$RSTART" =~ $ISO ]] || reject "run_started_at '$RSTART' malformed (attempt window inconclusive)"
# every job of the listing must belong to this run id, this attempt and the run head
jq -e --argjson r "$RUN_ID" --argjson a "$ATT" --arg h "$HEAD_SHA" 'all(.jobs[]; .run_id==$r and .run_attempt==$a and .head_sha==$h)' "$D/jobs.json" >/dev/null \
  || reject "job listing contains jobs from another run/attempt/head"
jwin(){ jq -r --arg n "$1" '.jobs[] | select(.name==$n) | "\(.started_at) \(.completed_at)"' "$D/jobs.json"; }
api "repos/$REPO/actions/runs/$RUN_ID/artifacts?per_page=100" >"$D/artifacts.json" || reject "artifacts unreadable"
NA=$(jq '.artifacts | length' "$D/artifacts.json"); [ "$(jq -r '.total_count' "$D/artifacts.json")" = "$NA" ] || reject "artifact listing incomplete (total_count != listed)"
DUP=$(jq -r '.artifacts[].name' "$D/artifacts.json" | sort | uniq -d | paste -sd' ' -); [ -z "$DUP" ] || reject "duplicate artifact names: $DUP"
GOTN=$(jq -r '.artifacts[].name' "$D/artifacts.json" | LC_ALL=C sort | paste -sd' ' -); WANTN=$(printf '%s\n' "${!AJOB[@]}" | LC_ALL=C sort | paste -sd' ' -)
[ "$GOTN" = "$WANTN" ] || reject "artifact names [$GOTN] != required set [$WANTN] (missing/extra)"
declare -A AWIN=()
while IFS=$'\t' read -r AID NAME WRID ASHA EXP DIG CRE; do
  [[ "$AID" =~ ^[0-9]+$ ]] && [[ "$DIG" =~ ^sha256:[0-9a-f]{64}$ ]] && [[ "$CRE" =~ $ISO ]] || reject "artifact $NAME metadata malformed (id=$AID digest=$DIG created_at=$CRE)"
  [ "$WRID" = "$RUN_ID" ] || reject "artifact $NAME workflow_run.id $WRID != $RUN_ID"
  [ "$ASHA" = "$HEAD_SHA" ] || reject "artifact $NAME head_sha $ASHA != run head"; [ "$EXP" = false ] || reject "artifact $NAME expired"
  J=${AJOB[$NAME]}; read -r JS JC <<<"$(jwin "$J")"
  [[ "$JS" =~ $ISO ]] && [[ "$JC" =~ $ISO ]] || reject "artifact $NAME: producing job '$J' of attempt $ATT has no complete window (linkage inconclusive)"
  [[ ! "$CRE" < "$RSTART" ]] && [[ ! "$CRE" < "$JS" ]] && [[ ! "$CRE" > "$JC" ]] || reject "artifact $NAME created_at $CRE outside attempt-$ATT job '$J' window [$JS, $JC] (run_started_at $RSTART)"
  api "repos/$REPO/actions/artifacts/$AID/zip" >"$D/$NAME.zip" || reject "artifact $NAME download failed"
  ZD=$(sha256sum "$D/$NAME.zip" | cut -c1-64); [ "sha256:$ZD" = "$DIG" ] || reject "artifact $NAME zip sha256 $ZD != GitHub digest ${DIG#sha256:}"
  mkdir -p "$D/art/$NAME" && unzip -q -o "$D/$NAME.zip" -d "$D/art/$NAME" || reject "artifact $NAME unzip failed"
  AWIN[$NAME]="$JS $JC"
done < <(jq -r '.artifacts[] | [(.id|tostring), .name, (.workflow_run.id|tostring), .workflow_run.head_sha, (.expired|tostring), (.digest // "none"), .created_at] | @tsv' "$D/artifacts.json")
ok "4c $NA artifacts = required set, unique names, all workflow_run.id=$RUN_ID head=$HEAD_SHA, each created inside its attempt-$ATT job window, zip sha256 = GitHub digest"
# receipts: checksum manifest complete + valid; recorded run/attempt/run-commit/harness-script binding
ST_SHA=$(git -C "$G" show "$APPROVED_HARNESS:proof/stage.sh" | sha256sum | cut -c1-64); LA_SHA=$(sha256sum <"$D/lanes.sh.approved" | cut -c1-64)
for NAME in $(printf '%s\n' "${!AJOB[@]}" | LC_ALL=C sort); do A=$D/art/$NAME
  case "$NAME" in
    preflight) P=$A/PREFLIGHT; [ -f "$P" ] && [ "$(find "$A" -type f | wc -l)" = 1 ] || reject "preflight artifact must contain only PREFLIGHT"
      grep -qx "TARGET=$TARGET" "$P" && grep -qx "HARNESS_SHA=$APPROVED_HARNESS" "$P" && grep -qx "RUN_COMMIT=$HEAD_SHA" "$P" && grep -qx MODE=FULL "$P" && grep -qx "TREE=$TTREE" "$P" && [ "$(tail -1 "$P")" = PREFLIGHT_OK ] \
        || reject "preflight receipt target/harness/run-commit/mode/tree mismatch"; continue;;
    summary) [ -f "$A/SUMMARY.md" ] && [ "$(find "$A" -type f | wc -l)" = 1 ] || reject "summary artifact must contain only SUMMARY.md"
      grep -qxF -- "- run: $RUN_URL" "$A/SUMMARY.md" || reject "summary run URL != $RUN_URL"; continue;;
  esac
  [ -f "$A/RECEIPTS.sha256" ] || reject "$NAME: RECEIPTS.sha256 missing"
  LISTED=$(awk '{print $2}' "$A/RECEIPTS.sha256" | LC_ALL=C sort | paste -sd' ' -); PRESENT=$(cd "$A" && find . -type f ! -name RECEIPTS.sha256 | sed 's|^\./||' | LC_ALL=C sort | paste -sd' ' -)
  [ "$LISTED" = "$PRESENT" ] || reject "$NAME: RECEIPTS.sha256 lists [$LISTED] but artifact holds [$PRESENT]"
  (cd "$A" && sha256sum --quiet --strict -c RECEIPTS.sha256) >"$D/receipts-check-$NAME.txt" 2>&1 || reject "$NAME: receipt checksum failure: $(tr '\n' ' ' <"$D/receipts-check-$NAME.txt")"
  R=$A/RESULT; [ -f "$R" ] || reject "$NAME: RESULT missing"
  [ "$(grep -c '^GH_RUN=' "$R")" = 1 ] && [ "$(field GH_RUN "$R")" = "$GH_RUN_WANT" ] || reject "$NAME: RESULT GH_RUN='$(field GH_RUN "$R")' != '$GH_RUN_WANT'"
  [ "$(field HARNESS_COMMIT "$R")" = "$HEAD_SHA" ] || reject "$NAME: RESULT HARNESS_COMMIT $(field HARNESS_COMMIT "$R") != run head $HEAD_SHA"
  [ "$(field STAGE_SH_SHA256 "$R")" = "$ST_SHA" ] && [ "$(field LANES_SH_SHA256 "$R")" = "$LA_SHA" ] || reject "$NAME: RESULT stage.sh/lanes.sh sha256 != approved harness files"
  case "$NAME" in lane-*) WL=${NAME#lane-}; WJ=ALL;; stage-s11-*) WL=s11; WJ=${NAME#stage-s11-};; stage-s10b-*) WL=s10b; WJ=${NAME#stage-s10b-};; esac
  [ "$(field LANE "$R")" = "$WL" ] && [ "$(field JOB_STAGES "$R")" = "$WJ" ] || reject "$NAME: RESULT LANE/JOB_STAGES $(field LANE "$R")/$(field JOB_STAGES "$R") != $WL/$WJ"
  RS=$(field START "$R"); RE=$(field END "$R"); read -r JS JC <<<"${AWIN[$NAME]}"
  [[ "$RS" =~ $ISO ]] && [[ "$RE" =~ $ISO ]] && [[ ! "$RS" < "$JS" ]] && [[ ! "$RE" > "$JC" ]] || reject "$NAME: RESULT START/END $RS..$RE outside job window [$JS, $JC]"
done
ok "4e receipts: RECEIPTS.sha256 complete+valid in all $(( ${#AJOB[@]} - 2 )) job artifacts; every RESULT GH_RUN='$GH_RUN_WANT', HARNESS_COMMIT=run head, stage.sh/lanes.sh = approved, LANE/JOB_STAGES = artifact, START/END in job window; preflight RUN_COMMIT=run head; summary run URL = $RUN_URL"

# ---- 4d. summary
S=$D/art/summary/SUMMARY.md; [ -f "$S" ] || reject "SUMMARY.md missing"
grep -qx '# proof-lanes summary — mode FULL' "$S" || reject "summary is not mode FULL"
grep -qx '\*\*VERDICT: PASS\*\*' "$S" || reject "summary verdict is not PASS"
grep -qF -- "- harness_sha: \`$APPROVED_HARNESS\`  run commit: \`$HEAD_SHA\`" "$S" || reject "summary harness_sha/run commit mismatch"
grep -qF -- "- target HEAD: \`$TARGET\`  TREE: \`$TTREE\`" "$S" || reject "summary target HEAD/TREE mismatch"
grep -qx "Pins checked: ${#PIN[@]}" "$S" || reject "summary 'Pins checked' != ${#PIN[@]}"
for k in "${!PIN[@]}"; do grep -qx -- "- $k=${PIN[$k]} got ${PIN[$k]}" "$S" || reject "summary does not show pin $k=${PIN[$k]} checked with that value"; done
ok "4d summary: mode FULL, VERDICT: PASS, harness_sha+run commit+target HEAD/TREE match, ${#PIN[@]} pins checked with expected values"

# ---- 5. serial lane receipts
sr(){ grep -m1 "^STAGE_RESULT name=$1 " "$2" | grep -oE "(^| )$3=[^ ]+" | head -1 | sed 's/^ //' | cut -d= -f2-; }
BIND=""
for L in s11 s10b; do R=$D/art/lane-$L/RESULT; [ -f "$R" ] || reject "lane $L RESULT missing"
  [ "$(field RC "$R")" = 0 ] && [ "$(field STAGE "$R")" = done ] && [ "$(field JOB_STAGES "$R")" = ALL ] || reject "lane $L: RC/STAGE/JOB_STAGES = $(field RC "$R")/$(field STAGE "$R")/$(field JOB_STAGES "$R")"
  [ "$(field HEAD "$R")" = "$TARGET" ] && [ "$(field TREE "$R")" = "$TTREE" ] && [ "$(field PKG_LOCK_SHA256 "$R")" = "$PKG_ACCEPT" ] || reject "lane $L: HEAD/TREE/pkg-lock mismatch"
  B="$(field TREE "$R") $(field PKG_LOCK_SHA256 "$R") $(field CLIENT_INDEX_DTS_SHA256 "$R") $(field MIGRATIONS_AT_HEAD "$R") $(field LAST_MIGRATION_AT_HEAD "$R") $(field MIGRATIONS_APPLIED "$R")"
  [ -z "$BIND" ] || [ "$B" = "$BIND" ] || reject "lane $L binding differs from s11 ($B vs $BIND)"; BIND=$B
  WANT="bootstrap $(awk -v l=$L '$1==l{print $2}' "$D/manifest.txt" | paste -sd' ' -)"
  GOT=$(grep '^STAGE_RESULT ' "$R" | grep -oE 'name=[^ ]+' | cut -d= -f2 | paste -sd' ' -)
  [ "$GOT" = "$WANT" ] || reject "lane $L stage order [$GOT] != [$WANT]"
  [ "$(sr bootstrap "$R" status)" = PASS ] && [ "$(sr bootstrap "$R" exact_set)" = yes ] || reject "lane $L bootstrap not PASS/exact_set=yes"
  MA=$D/art/lane-$L/migrations-applied.txt; MH=$D/art/lane-$L/migrations-at-head.txt
  [ -f "$MA" ] && cmp -s "$MA" "$MH" && [ "$(wc -l <"$MA")" = "$(field MIGRATIONS_AT_HEAD "$R")" ] && [ -z "$(uniq -d "$MA")" ] || reject "lane $L migration name files differ / wrong count / duplicates"
  [ "$(git -C "$G" ls-tree -d --name-only "$TARGET:prisma/migrations" | LC_ALL=C sort)" = "$(cat "$MH")" ] || reject "lane $L migrations-at-head != target tree's prisma/migrations"
  SP=0; ST=0; DESC=""
  while read -r _ N MS; do
    if [ "$MS" = skip-absent ]; then [ "$(sr "$N" "$R" status)" = SKIP_ABSENT_AT_HEAD ] || reject "lane $L/$N expected SKIP_ABSENT_AT_HEAD"; DESC="$DESC $N=SKIP_ABSENT"; continue; fi
    P=$(sr "$N" "$R" passed); T=$(sr "$N" "$R" total)
    [ "$(sr "$N" "$R" status)" = PASS ] && [ "$(sr "$N" "$R" failed)" = 0 ] && [ "$(sr "$N" "$R" skipped)" = 0 ] && [ "$(sr "$N" "$R" todo)" = 0 ] && [ -n "$T" ] && [ "$T" -gt 0 ] && [ "$P" = "$T" ] \
      || reject "lane $L/$N: status=$(sr "$N" "$R" status) passed=$P total=$T failed=$(sr "$N" "$R" failed) skipped=$(sr "$N" "$R" skipped) todo=$(sr "$N" "$R" todo)"
    [ -z "${PIN[EXPECT_$N]:-}" ] || [ "$T" = "${PIN[EXPECT_$N]}" ] || reject "lane $L/$N total $T != pin ${PIN[EXPECT_$N]}"
    FR=$D/art/stage-$L-$N/RESULT; [ -f "$FR" ] || reject "fast signal stage-$L-$N RESULT missing"
    [ "$(field RC "$FR")" = 0 ] && [ "$(sr "$N" "$FR" status)" = PASS ] && [ "$(sr "$N" "$FR" total)" = "$T" ] && [ "$(sr "$N" "$FR" passed)" = "$T" ] && [ "$(field HEAD "$FR")" = "$TARGET" ] && [ "$(field TREE "$FR")" = "$TTREE" ] \
      || reject "fast signal $L/$N disagrees with serial lane ($(sr "$N" "$FR" status) $(sr "$N" "$FR" passed)/$(sr "$N" "$FR" total) vs $T)"
    SP=$((SP + P)); ST=$((ST + T)); DESC="$DESC $N=$P/$T"
  done < <(awk -v l=$L '$1==l' "$D/manifest.txt")
  grep -qx "TOTAL passed=$SP failed=0 skipped=0 total=$ST" "$R" && [ "$ST" -gt 0 ] || reject "lane $L TOTAL line != $SP/$ST"
  [ "$ST" = "${PIN[EXPECT_TOTAL_$L]}" ] || reject "lane $L total $ST != pin EXPECT_TOTAL_$L=${PIN[EXPECT_TOTAL_$L]}"
  ok "5 lane $L serial receipt: RC 0 done JOB_STAGES=ALL, order [$GOT], bootstrap exact_set=yes ($(wc -l <"$MA") migrations = target dir),$DESC, TOTAL $SP/$ST = pin; fast signals agree"
done
ok "5 binding consistent across lanes: TREE/pkg-lock/client/migrations = $BIND"
say "ACCEPT run=$RUN_ID attempt=$ATT run_commit=$HEAD_SHA harness=$APPROVED_HARNESS target=$TARGET tree=$TTREE s11=${PIN[EXPECT_TOTAL_s11]} s10b=${PIN[EXPECT_TOTAL_s10b]} evidence=$D"
exit 0
