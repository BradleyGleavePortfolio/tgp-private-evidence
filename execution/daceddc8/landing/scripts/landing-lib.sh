#!/usr/bin/env bash
# landing-lib.sh: shared constants, refusals and helpers for LAND-PREP-1 (EXEC-DACEDDC8).
# Sourced by land-first.sh, compose-second.sh and land-second.sh. It is never run on its own.
# DRAFT, NOT EXECUTED by the planner. The parent (or a parent-granted landing executor) runs it.
#
# Invariants these helpers enforce:
#  - Bradley Gleave <bradley@bradleytgpcoaching.com> is author AND committer of every commit in range
#  - no trailers and no banned identity tokens in any message
#  - ordinary pushes only: no force, no '+' refspec, no deletion, no bypass
#  - never touch backend main (production; PR #530 is owner-reserved)
#  - the first failure stops the run with a nonzero code; nothing loops

set -uo pipefail

# ---------- fixed identities (observed 2026-09-25T16:46Z, see ../analysis/) ----------
REPO=/home/user/workspace/growth-project-backend
GH_REPO=BradleyGleavePortfolio/growth-project-backend
TARGET_REF=refs/heads/integration/importer
FORBIDDEN_REF=refs/heads/main
BASE=93389265a846095b846fa8f1fb0dad782fb6ee9f          # integration/importer at plan time
MAIN_AT_PLAN=c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7   # backend main, never written
S7L_PARENT=a68cdac70d81aea384fdc99c01c9c983a08e80eb     # tree 6c00e248
S8C_PARENT=87018a421f5be1064767d2cdd32e75ca935f7cdb     # tree cec7d05a
S7L_FOLLOWUP_PATH=test/utils/g2-s7l-worker.cjs     # committed in df713fd9
S8C_FOLLOWUP_PATH=test/utils/g2-s8c-bootstrap.sh    # committed in e0cee7e0
S7L_OBSERVED_HEAD=df713fd9217df524915348ef8a42c797f288dde1   # informational; the head is always a parameter
S8C_MIN_ANCESTOR=e0cee7e04bef88811310f6dde1fd921f45d103ad    # S8-C head must contain the bootstrap follow-up
# Lane-private proof-harness paths (only default-Jest-excluded rls spec, g2 utils, lane db-guard spec).
S7L_PRIVATE_RE='^(test/utils/g2-s7l-[^/]+|test/rls-g2-s7l\.spec\.ts|test/scout/g2-s7l-db-guard\.spec\.ts)$'
S8C_PRIVATE_RE='^(test/utils/g2-s8c-[^/]+|test/rls-g2-s8c\.spec\.ts|test/scout/g2-s8c-db-guard\.spec\.ts)$'

S7L_WT=/home/user/workspace/worktrees/64e33dc7-s7l
S8C_WT=/home/user/workspace/worktrees/64e33dc7-s8c
S7L_BRANCH=exec64/s7l-replacement
S8C_BRANCH=exec64/s8c-replacement
# Textual merge of the two parents (git merge-tree --write-tree a68cdac7 87018a42; order-independent).
PRE_FOLLOWUP_MERGED_TREE=bb5436dd249744c52d5d1d0a30618a81c2b62829
CONTRACT=docs/contracts/importer-openapi.json
CONTRACT_MERGED_BLOB=f9109c068a542c8f833d7c0185e4ec9882afe201
CONTRACT_MERGED_SHA256=77d5ffd10efefb4400b87c1d802d8c6f2bb92a4182f4d067a9e9fe217ed50f09
CONTRACT_S7L_BLOB=3c1fd2ac528ef19bb565f4b6f073a2155e8bab3f
CONTRACT_S8C_BLOB=493234f13d48087424022fea3ba1be113ccea088
COMBINED_SCHEMA_SHA256=0eb41f9a88ef3b77266e908a5ea814206c188d1bdb031bd96d746491fee84015   # == S7-L schema
NM_LOCK_SHA256=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44
S7L_CLIENT_SHA256=9042e713ba5678c99959a345b7b18a60dfc186b2c7d890b8d9c3ed5c8f4edcc6
S7L_CLIENT_SCHEMA_SHA256=b84392033ab86776533007505c31f57930307a210844067a7407ed20d25abf3e
HOOK_PRECOMMIT_SHA256=3b741de3dd006d6265c6ca6698b7b5ce8aa9a2a5ba2743a8615d85e72b4a140d
HOOK_COMMITMSG_SHA256=71029ce88d76d5b885e12f978093ad3e046e93f5c5fc629b6fbba635d9f8a61b
RUNTIME_ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset
PFX_MANIFEST=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256
LOCK=/home/user/workspace/execution/test-validation.lock
LANDING_DIR=/home/user/workspace/tgp-private-evidence/execution/daceddc8/landing
AUTHOR_NAME="Bradley Gleave"
AUTHOR_EMAIL=bradley@bradleytgpcoaching.com
# Same token set as the repo commit-msg hook (lefthook no-ai-tokens), applied before we ever commit/push.
BANNED_RE='claude|anthropic|openai|gpt[- ]|computer[- ]agent|perplexity|co-authored[- ]by|generated with|🤖|ai assist|\b(ai|agent)\b'

# L2-2: default-config specs whose source reads repository state the other lane can change.
FS_PINNED_SPEC_RE="prisma/migrations|['\"/]migrations['\"]|docs/contracts|importer-openapi|EXPECTED_MIGRATIONS|BASE_HEAD"

export GIT_OPTIONAL_LOCKS=0

ts(){ date -u +%FT%TZ; }
sha(){ sha256sum "$1" | cut -c1-64; }
: "${RUN_DIR:=}"
log(){ if [ -n "$RUN_DIR" ]; then echo "$(ts) $*" | tee -a "$RUN_DIR/run.log"; else echo "$(ts) $*"; fi; }
refuse(){ local rc=$1; shift; log "REFUSED rc=$rc: $*"; exit "$rc"; }

new_run_dir(){ # $1 = step name
  RUN_DIR="$LANDING_DIR/run/$1-$(date -u +%Y%m%dT%H%M%SZ)"
  [ -e "$RUN_DIR" ] && refuse 70 "run dir already exists: $RUN_DIR"
  mkdir -p "$RUN_DIR" || refuse 70 "cannot create $RUN_DIR"
  log "RUN $1 pid=$$ script=$0 script_sha=$(sha "$0") lib_sha=$(sha "${BASH_SOURCE[0]}")"
}

lane_vars(){ # $1 = s7l|s8c -> LANE_PARENT(anchor) LANE_MIN LANE_PRIVATE_RE LANE_FOLLOWUP LANE_SLICE LANE_LABEL LANE_WT LANE_BRANCH
  case "$1" in
    s7l) LANE_PARENT=$S7L_PARENT; LANE_MIN=; LANE_PRIVATE_RE=$S7L_PRIVATE_RE; LANE_FOLLOWUP=$S7L_FOLLOWUP_PATH; LANE_SLICE=s7-l
         LANE_LABEL="S7-L server-owned run lifecycle"; LANE_WT=$S7L_WT; LANE_BRANCH=$S7L_BRANCH ;;
    s8c) LANE_PARENT=$S8C_PARENT; LANE_MIN=$S8C_MIN_ANCESTOR; LANE_PRIVATE_RE=$S8C_PRIVATE_RE; LANE_FOLLOWUP=$S8C_FOLLOWUP_PATH; LANE_SLICE=s8-c
         LANE_LABEL="S8-C native reconstruct writers"; LANE_WT=$S8C_WT; LANE_BRANCH=$S8C_BRANCH ;;
    *) refuse 64 "lane must be s7l or s8c, got '$1'" ;;
  esac
}
other_lane(){ [ "$1" = s7l ] && echo s8c || echo s7l; }

is_full_sha(){ [[ "$1" =~ ^[0-9a-f]{40}$ ]]; }

refuse_bypass_env(){
  [ "${LEFTHOOK:-}" = 0 ] && refuse 71 "LEFTHOOK=0 would skip genuine hooks"
  [ -n "${LEFTHOOK_BIN:-}" ] && refuse 71 "LEFTHOOK_BIN override set"
  [ -n "${LEFTHOOK_EXCLUDE:-}" ] && refuse 71 "LEFTHOOK_EXCLUDE set"
  [ -n "${GIT_DIR:-}${GIT_WORK_TREE:-}${GIT_INDEX_FILE:-}" ] && refuse 71 "GIT_DIR/GIT_WORK_TREE/GIT_INDEX_FILE set"
  [ -n "$(git -C "$REPO" config --get core.hooksPath || true)" ] && refuse 71 "core.hooksPath is set"
  return 0
}

verify_hooks(){
  local hd; hd="$(git -C "$REPO" rev-parse --git-common-dir)/hooks"
  case "$hd" in /*) ;; *) hd="$REPO/$hd" ;; esac
  [ "$(sha "$hd/pre-commit")" = "$HOOK_PRECOMMIT_SHA256" ] || refuse 71 "pre-commit hook sha mismatch"
  [ "$(sha "$hd/commit-msg")" = "$HOOK_COMMITMSG_SHA256" ] || refuse 71 "commit-msg hook sha mismatch"
  log "HOOKS pre-commit=$HOOK_PRECOMMIT_SHA256 commit-msg=$HOOK_COMMITMSG_SHA256"
}

remote_sha(){ # $1 = full ref; prints sha or empty
  git -C "$REPO" ls-remote origin "$1" | awk -v r="$1" '$2==r{print $1}'
}

fetch_objects(){ # ordinary fetch of the target ref so ancestry checks use real remote objects
  git -C "$REPO" fetch --no-tags origin "+$TARGET_REF:refs/remotes/origin/integration/importer" >>"$RUN_DIR/fetch.log" 2>&1 \
    || refuse 72 "fetch of $TARGET_REF failed"
}
# (The '+' above is a LOCAL remote-tracking fetch refspec, standard git behaviour; it never writes a remote.)

check_main_untouched(){
  local m; m=$(remote_sha "$FORBIDDEN_REF")
  [ "$m" = "$MAIN_AT_PLAN" ] || log "NOTE backend main is $m (plan saw $MAIN_AT_PLAN); this run never writes main"
}

# Every commit in (base, head] must be Bradley author+committer, no trailers, no banned tokens.
check_identity_range(){ # $1=base $2=head
  local bad
  bad=$(git -C "$REPO" log --format='%H%x09%an <%ae>%x09%cn <%ce>' "$1..$2" \
        | awk -F'\t' -v w="$AUTHOR_NAME <$AUTHOR_EMAIL>" '$2!=w || $3!=w')
  [ -z "$bad" ] || refuse 73 "identity mismatch in $1..$2: $bad"
  local c
  for c in $(git -C "$REPO" rev-list "$1..$2"); do
    [ -z "$(git -C "$REPO" log -1 --format='%(trailers:only,unfold)' "$c" | tr -d '[:space:]')" ] || refuse 73 "commit $c carries trailers"
    git -C "$REPO" log -1 --format='%B' "$c" | grep -iqE "$BANNED_RE" && refuse 73 "commit $c message has a banned token"
  done
  log "IDENTITY ok for $(git -C "$REPO" rev-list --count "$1..$2") commits in ${1:0:8}..${2:0:8}"
}

# Candidate lineage (LAND-1 revision). Each lane has a reviewed ANCHOR (the source-accepted head analysed by
# LAND-PREP-1: S7-L a68cdac7, S8-C 87018a42) and an optional MIN ancestor (S8-C e0cee7e0, the committed bootstrap
# follow-up). The candidate head is a PARAMETER because S8-C will get a new harness-correction head.
# The rules:
#  - the anchor, and MIN if set, are ancestors of the head;
#  - every commit in BASE..head is single-parent (no merges);
#  - anchor..head touches only lane-private proof-harness paths (LANE_PRIVATE_RE), none of them in the static import
#    closure of the 27 composition suites (analysis/composition-suite-closure.txt), and never the contract;
#  - the head's contract blob equals the analysed one;
#  - the lane branch points at the head;
#  - identity, no trailers and R3-clean over BASE..head.
check_candidate_lineage(){ # $1=lane $2=head
  lane_vars "$1"; local h=$2 p
  is_full_sha "$h" || refuse 64 "$1 head must be a full 40-hex sha"
  git -C "$REPO" cat-file -e "$h^{commit}" 2>/dev/null || refuse 74 "$1 head $h not present locally"
  git -C "$REPO" merge-base --is-ancestor "$LANE_PARENT" "$h" || refuse 74 "$1 anchor $LANE_PARENT is not an ancestor of $h"
  if [ -n "$LANE_MIN" ]; then git -C "$REPO" merge-base --is-ancestor "$LANE_MIN" "$h" || refuse 74 "$1 required ancestor $LANE_MIN missing"; fi
  git -C "$REPO" merge-base --is-ancestor "$BASE" "$h" || refuse 74 "$1 head does not descend from $BASE"
  [ -z "$(git -C "$REPO" rev-list --merges "$BASE..$h")" ] || refuse 74 "$1 has merge commits over base"
  local paths; paths=$(git -C "$REPO" diff --name-only "$LANE_PARENT" "$h")
  for p in $paths; do
    [[ "$p" =~ $LANE_PRIVATE_RE ]] || refuse 74 "$1 post-anchor path $p is not a lane-private proof-harness path"
    grep -qxF "$p" "$LANDING_DIR/analysis/composition-suite-closure.txt" && refuse 74 "$1 post-anchor path $p is inside the composition suites' import closure"
  done
  [ "$(git -C "$REPO" rev-parse "$h:$CONTRACT")" = "$( [ "$1" = s7l ] && echo $CONTRACT_S7L_BLOB || echo $CONTRACT_S8C_BLOB)" ] \
    || refuse 74 "$1 contract blob changed since the plan's merge-tree analysis"
  local br; br=$(git -C "$REPO" rev-parse "refs/heads/$LANE_BRANCH" 2>/dev/null || true)
  [ "$br" = "$h" ] || refuse 74 "$1 local branch $LANE_BRANCH is at ${br:-absent}, not $h"
  check_identity_range "$BASE" "$h"
  LANE_POST_ANCHOR_PATHS=$paths
  log "LINEAGE $1 head=$h tree=$(git -C "$REPO" rev-parse "$h^{tree}") anchor=$LANE_PARENT min=${LANE_MIN:-none} post_anchor=[$(echo $paths)]"
}

# Acceptance record: an existing file naming the exact full head sha and an ACCEPT verdict.
check_acceptance(){ # $1=lane $2=head $3=record path
  [ -n "${3:-}" ] && [ -f "$3" ] || refuse 75 "$1 acceptance record missing (${3:-unset})"
  grep -q "$2" "$3" || refuse 75 "$1 acceptance record does not name $2"
  grep -Eq '\bACCEPT(ED)?\b' "$3" || refuse 75 "$1 acceptance record has no ACCEPT verdict"
  grep -Eiq '\bNOT ACCEPT|\bREJECT|\bNO-GO\b' "$3" && refuse 75 "$1 acceptance record contains a negative verdict; parent must disposition"
  log "ACCEPTANCE $1 record=$3 sha=$(sha "$3")"
}

# Ordinary push of an exact sha to a land/ ref: the ref must be absent or already equal. No force, no '+'.
push_land_ref(){ # $1=sha $2=branch name (land/...)
  case "$2" in land/*) ;; *) refuse 64 "push_land_ref only writes land/* (got $2)" ;; esac
  local cur; cur=$(remote_sha "refs/heads/$2")
  if [ -n "$cur" ]; then
    [ "$cur" = "$1" ] || refuse 76 "remote $2 exists at $cur, not $1 (no force, parent must disposition)"
    log "PUSH skip $2 already at $1"; return 0
  fi
  git -C "$REPO" push origin "$1:refs/heads/$2" >>"$RUN_DIR/push.log" 2>&1 || refuse 76 "push to $2 failed"
  [ "$(remote_sha "refs/heads/$2")" = "$1" ] || refuse 76 "ls-remote $2 != $1 after push"
  log "PUSH $2 = $1 (ls-remote verified)"
}

# CI verdict for a PR: every check pass/skipping, except the known class-C Danger PR-title failure.
check_pr_ci(){ # $1=pr number $2=expected head sha $3=1 if migration checks are expected
  local j="$RUN_DIR/pr$1-checks.json" head
  head=$(gh pr view "$1" -R "$GH_REPO" --json headRefOid --jq .headRefOid) || refuse 77 "gh pr view $1 failed"
  [ "$head" = "$2" ] || refuse 77 "PR $1 head $head != $2"
  gh pr checks "$1" -R "$GH_REPO" --json name,state,bucket,workflow,link >"$j" 2>>"$RUN_DIR/gh.log"
  python3 - "$j" "$3" <<'PY' >>"$RUN_DIR/run.log" 2>&1 || refuse 77 "PR CI not green (see $j)"
import json, sys
checks = json.load(open(sys.argv[1])); want_mig = sys.argv[2] == "1"
danger = {"danger", "danger dry-run (dangerfile.js)"}
# LAND-1 correction. On a PR whose base is integration/importer, only these workflows trigger: CI,
# Dependency Audit, H4 deploy readiness, pr-size-labeler and Migration Dry-Run (paths). Danger, CodeQL,
# R75 / R100.A2, SBOM and Infra Lint trigger only for PRs whose base is main. Their results previously
# attributed to #538 came from draft PR #530 (integration/importer -> main) being synchronized at 22:46Z;
# see ci/s7-l/CHECKS.md. If a main-only check does appear, it must pass, except the Danger title rule.
required = {"build-and-test", "rls-floor-guard", "rls-live-tests", "mwb-3-live-tests",
            "npm audit (high+critical, whole graph)", "test-deploy-readiness", "size-label"}
if want_mig:
    required |= {"Forward migrations apply cleanly",
                 "New migrations are reversible (or explicitly marked IRREVERSIBLE)",
                 "Schema parity (deferred to BL-MIGRATION-REBASELINE)"}
names = {c["name"]: c for c in checks}
bad = []
for r in sorted(required):
    if r not in names or names[r]["bucket"] != "pass":
        bad.append(f"required {r}: {names.get(r, {}).get('bucket', 'absent')}")
for c in checks:
    if c["name"] in danger:
        continue
    if c["bucket"] not in ("pass", "skipping"):
        bad.append(f"{c['name']}: {c['bucket']}")
for c in checks:
    print(f"CHECK {c['bucket']:8} {c['workflow']} | {c['name']}")
if bad:
    print("CI_NOT_GREEN", bad); sys.exit(1)
print("CI_GREEN (Danger title check excluded as known class C)")
PY
  # Danger may only fail on the PR-title rule; anything else in Danger is not class C.
  local run_ids id
  run_ids=$(python3 -c "import json,re,sys;[print(re.search(r'/runs/(\d+)/',c['link']).group(1)) for c in json.load(open('$j')) if c['name'] in ('danger','danger dry-run (dangerfile.js)') and c['bucket']=='fail']")
  for id in $run_ids; do
    gh run view "$id" -R "$GH_REPO" --log-failed >"$RUN_DIR/danger-$id.log" 2>&1 || true
    grep -q 'PR title is not Conventional Commits format' "$RUN_DIR/danger-$id.log" \
      && grep -q 'there is 1 fail' "$RUN_DIR/danger-$id.log" \
      || refuse 77 "Danger run $id failed for something other than the single PR-title rule"
  done
  log "CI PR#$1 green at $2 (danger title failures, if any, verified class C)"
}

# The only write to integration/importer: an ordinary fast-forward push of an exact sha, then ls-remote verification.
ff_push_integration(){ # $1=expected current remote tip $2=new sha
  [ "$(remote_sha "$TARGET_REF")" = "$1" ] || refuse 78 "integration/importer moved: $(remote_sha "$TARGET_REF") != $1"
  git -C "$REPO" merge-base --is-ancestor "$1" "$2" || refuse 78 "$2 is not a fast-forward of $1"
  git -C "$REPO" push origin "$2:$TARGET_REF" >>"$RUN_DIR/push.log" 2>&1 || refuse 78 "FF push rejected (no retry, no force)"
  local now; now=$(remote_sha "$TARGET_REF")
  [ "$now" = "$2" ] || refuse 78 "ls-remote integration/importer = $now, expected $2"
  log "LANDED integration/importer $1 -> $2 (ordinary FF, ls-remote verified)"
  gh api "repos/$GH_REPO/commits/$2" --jq '"remote commit author=\(.commit.author.name) <\(.commit.author.email)> committer=\(.commit.committer.name) <\(.commit.committer.email)> tree=\(.commit.tree.sha)"' \
    | tee -a "$RUN_DIR/run.log"
  check_main_untouched
}
