#!/usr/bin/env bash
# land-s8f-1910.sh: LAND-PREP-1910 (EXEC-1910A060, Tier T3). Exact nonproduction landing of S8-F e1ec2fec, plus the
# S9-A ordinary fast-forward path. PREPARED, NOT EXECUTED by the preparer (only `bash -n` was run). The parent is the
# sole landing authority and runs each mode separately, once, after the prerequisites in RECIPE.md.
#
# Modes (each writes only a new run dir under landing/run/ and, for compose/stage, landing/state/):
#   predict            read-only. Scratch bare repo in /tmp. Re-proves the merge-tree prediction against the live remote.
#   classify HEAD      read-only. Frontier moved or a candidate is no longer FF: classify the exact changed dependency.
#                      Always exits 79 (parent must disposition). Never composes, never replays.
#   compose            canonical lock. Fresh standalone clone, `git merge --no-ff --no-commit` S8-F onto the tip, tree
#                      must equal the prediction, one genuine hooked Bradley commit. No jest (docs-only sibling; see
#                      RECIPE.md section 4), no contract regen, no install, no generate, no PG. Nothing is pushed.
#   stage              push land/s8-f-accepted = e1ec2fec and land/s8-f = M (ordinary, absent-or-equal), open ONE PR.
#   ff                 after acceptance + CI green once: ordinary FF push of M to integration/importer. main untouched.
#   s9a-stage HEAD     S9-A pure fast-forward candidate: push land/s9-a = HEAD, open ONE PR.
#   s9a-ff HEAD        after acceptance + CI green once: ordinary FF push of HEAD to integration/importer.
#
# Invariants: Bradley Gleave <bradley@bradleytgpcoaching.com> author+committer; no trailers; no banned tokens; no
# --no-verify, no amend, no force, no '+' remote refspec, no ref deletion, no merge button, never refs/heads/main; the
# first failure stops (nonzero) with state preserved; no mode loops or retries; CI is observed once per PR head.
set -uo pipefail
export GIT_OPTIONAL_LOCKS=0

# ---------- fixed identities (observed 2026-09-25 21:15-21:24Z; see analysis/) ----------
GH_REPO=BradleyGleavePortfolio/growth-project-backend
ORIGIN_URL=https://github.com/$GH_REPO.git
TARGET_REF=refs/heads/integration/importer
FORBIDDEN_REF=refs/heads/main
TIP=1c5fbb0441178e0cfe6e9f8d72e955c645c265e9           # integration/importer now (S9-0 doc on 1c10e2a1)
TIP_TREE=82b56ad373c9cb4888b7c9b79544fbbb6f55c0d6
P=1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47             # S8-F parent == merge base == main
MAIN_EXPECT=1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47
H=e1ec2fecb71f315b6721d426ba0dacb84f304498             # exact accepted-candidate S8-F bytes (reused, never rebuilt)
H_TREE=2fe0201ff132dfdc53ea82b3f26ed0fc8d1c65d6
BUNDLE=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8f/checkpoints/v1/s8f-e1ec2fec.bundle
BUNDLE_SHA=a69b4fc837506cf868135894d2b6f497455de8d787ae8f2e78ea9eab4364c467
BUNDLE_REF=refs/heads/exec-dace/s8f
PRED_TREE=23614f0b7dc33dc37b90cf4f27fcb8331912e60f      # git merge-tree --write-tree 1c5fbb04 e1ec2fec (both orders)
DOC=docs/decisions/2026-09-25-s9-reconciliation.md; DOC_BLOB=c3423725ed51b68967074a97a0975a7245543c22
CONTRACT=docs/contracts/importer-openapi.json; CONTRACT_BLOB=8ebf936a9f12087a807cb37b069592d0c1e96cb2
SCHEMA_SHA=0eb41f9a88ef3b77266e908a5ea814206c188d1bdb031bd96d746491fee84015
PKG_LOCK_SHA=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55
MIGRATIONS=172
# CORRECTION-1 (pre-run, parent LAND-S8F-1): lefthook 2.1.9 hook bodies embed the owning clone's absolute node_modules
# path, so raw hashes differ per clone (historical shared-clone 3b741de3/71029ce8). Comparison is path-normalized against
# the reference clone's hooks (same method as s9a/gate/s9a-gate-1910.sh): substitute each clone's absolute root with
# @CLONE_ROOT@, require equality, lefthook 2.1.9, and own-clone lefthook binary reference.
HOOK_REF_ROOT=/home/user/workspace/worktrees/1910a060-s8f
LEFTHOOK_EXPECT=2.1.9
LOCK=/home/user/workspace/execution/test-validation.lock; LOCK_INODE=667698
DONOR_REPO=/home/user/workspace/worktrees/1910a060-s8f       # RT-NEW-1 clone; binding for the S8-F PG proof: READ ONLY
PFX=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9
PFX_MANIFEST=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256
W=/home/user/workspace/worktrees/1910a060-land-s8f            # fresh standalone composition clone (created by compose)
BR=land1910/s8f
S9A_REPO=/home/user/workspace/worktrees/1910a060-s9a
S9A_PATHS="src/scout/reconciliation/coverage.ts src/scout/reconciliation/reconcile.ts src/scout/reconciliation/types.ts test/scout/reconciliation/reconcile.spec.ts"
LANDING=/home/user/workspace/tgp-private-evidence/execution/1910a060/landing
SELECT=$LANDING/analysis/select_suites.py
NAME="Bradley Gleave"; EMAIL=bradley@bradleytgpcoaching.com; WHO="$NAME <$EMAIL>"
BANNED_RE='claude|anthropic|openai|gpt[- ]|computer[- ]agent|perplexity|co-authored[- ]by|generated with|🤖|ai assist|\b(ai|agent)\b'

# ---------- helpers ----------
ts(){ date -u +%FT%TZ; }
sha(){ sha256sum "$1" | cut -c1-64; }
RUN_DIR=""
log(){ echo "$(ts) $*" | tee -a "$RUN_DIR/run.log"; }
refuse(){ local rc=$1; shift; log "REFUSED rc=$rc: $*"; exit "$rc"; }
new_run(){ RUN_DIR=$LANDING/run/$1-$(date -u +%Y%m%dT%H%M%SZ); mkdir -p "$RUN_DIR" || exit 70; log "RUN $1 pid=$$ user=$(id -un) node=$(node -v 2>/dev/null || echo n/a) git=$(git --version)"; }
is_sha(){ [[ "$1" =~ ^[0-9a-f]{40}$ ]]; }
remote_sha(){ git ls-remote "$ORIGIN_URL" "$1" 2>>"$RUN_DIR/run.log" | awk -v r="$1" '$2==r{print $1}'; }
refuse_bypass_env(){
  [ "${LEFTHOOK:-}" = 0 ] && refuse 71 "LEFTHOOK=0 would skip genuine hooks"
  [ -n "${LEFTHOOK_BIN:-}${LEFTHOOK_EXCLUDE:-}" ] && refuse 71 "LEFTHOOK_BIN/LEFTHOOK_EXCLUDE set"
  [ -n "${GIT_DIR:-}${GIT_WORK_TREE:-}${GIT_INDEX_FILE:-}" ] && refuse 71 "GIT_DIR/GIT_WORK_TREE/GIT_INDEX_FILE set"
  [ -n "$(git config --global --get core.hooksPath 2>/dev/null || true)" ] && refuse 71 "global core.hooksPath set"
  return 0
}
remote_state(){ # records and checks target/main/land refs; $1 = expected integration tip
  RT=$(remote_sha "$TARGET_REF"); RM=$(remote_sha "$FORBIDDEN_REF")
  git ls-remote "$ORIGIN_URL" 'refs/heads/land/*' >"$RUN_DIR/ls-remote-land.txt" 2>>"$RUN_DIR/run.log"
  log "REMOTE integration/importer=$RT main=$RM land_refs=$(wc -l <"$RUN_DIR/ls-remote-land.txt")"
  [ -n "$RT" ] || refuse 72 "ls-remote returned no integration/importer (credentials?)"
  [ "$RM" = "$MAIN_EXPECT" ] || refuse 72 "main is $RM, not $MAIN_EXPECT; parent must disposition (this recipe never writes main)"
  [ "$RT" = "$1" ] || refuse 79 "FRONTIER_MOVED integration/importer=$RT != expected $1; run 'classify' and stop (no blind replay)"
}
land_ref_absent_or(){ # $1 = land ref name, $2 = allowed sha
  local cur; cur=$(awk -v r="refs/heads/$1" '$2==r{print $1}' "$RUN_DIR/ls-remote-land.txt")
  [ -z "$cur" ] || [ "$cur" = "$2" ] || refuse 76 "remote $1 exists at $cur, not $2 (no force; parent must disposition)"
}
push_land_ref(){ # $1 = repo dir, $2 = sha, $3 = land/<name>
  case "$3" in land/*) ;; *) refuse 64 "push_land_ref writes land/* only";; esac
  local cur; cur=$(remote_sha "refs/heads/$3")
  if [ -n "$cur" ]; then [ "$cur" = "$2" ] || refuse 76 "remote $3 at $cur != $2"; log "PUSH skip $3 already $2"; return 0; fi
  git -C "$1" push "$ORIGIN_URL" "$2:refs/heads/$3" >>"$RUN_DIR/push.log" 2>&1 || refuse 76 "push $3 failed (no retry)"
  [ "$(remote_sha "refs/heads/$3")" = "$2" ] || refuse 76 "ls-remote $3 != $2 after push"
  log "PUSH $3 = $2 (ordinary, ls-remote verified)"
}
check_commit_hygiene(){ # $1 = repo dir, $2 = range base, $3 = head: identity, no trailers, no banned tokens
  local c bad
  bad=$(git -C "$1" log --format='%H%x09%an <%ae>%x09%cn <%ce>' "$2..$3" | awk -F'\t' -v w="$WHO" '$2!=w || $3!=w')
  [ -z "$bad" ] || refuse 73 "identity mismatch: $bad"
  for c in $(git -C "$1" rev-list "$2..$3"); do
    [ -z "$(git -C "$1" log -1 --format='%(trailers:only,unfold)' "$c" | tr -d '[:space:]')" ] || refuse 73 "$c has trailers"
    git -C "$1" log -1 --format=%B "$c" | grep -iqE "$BANNED_RE" && refuse 73 "$c message has a banned token"
  done
  log "HYGIENE ok $(git -C "$1" rev-list --count "$2..$3") commit(s) ${2:0:8}..${3:0:8}"
}
check_acceptance(){ # $1 = record path, $2.. = shas it must name
  local f=$1; shift
  [ -n "$f" ] && [ -f "$f" ] || refuse 75 "acceptance record missing (${f:-unset})"
  local s; for s in "$@"; do grep -q "$s" "$f" || refuse 75 "record $f does not name $s"; done
  grep -Eq '\bACCEPT(ED)?\b' "$f" || refuse 75 "record $f has no ACCEPT verdict"
  grep -Eiq '\bNOT ACCEPT|\bREJECT|\bNO-GO\b' "$f" && refuse 75 "record $f contains a negative verdict"
  log "ACCEPTANCE record=$f sha256=$(sha "$f") names=[$*]"
}
check_pr_ci(){ # $1 = PR number, $2 = expected head sha. Observed ONCE; not green => stop (no re-stage loop).
  local j="$RUN_DIR/pr$1-checks.json" head
  head=$(gh pr view "$1" -R "$GH_REPO" --json headRefOid --jq .headRefOid) || refuse 77 "gh pr view failed"
  [ "$head" = "$2" ] || refuse 77 "PR #$1 head $head != $2"
  gh pr checks "$1" -R "$GH_REPO" --json name,state,bucket,workflow,link >"$j" 2>>"$RUN_DIR/run.log"
  python3 - "$j" <<'PY' >>"$RUN_DIR/run.log" 2>&1 || refuse 77 "PR CI not green or still pending (see $j); parent dispositions, no re-run loop"
import json, sys
checks = json.load(open(sys.argv[1]))
# Base integration/importer: CI, Dependency Audit, H4 deploy readiness, pr-size-labeler (Migration Dry-Run only on
# migration paths; neither candidate has migrations). Same set PR #541 showed: 8 pass + deploy-readiness-gate skipping.
required = {"build-and-test", "rls-floor-guard", "rls-live-tests", "mwb-3-live-tests",
            "npm audit (high+critical, whole graph)", "test-deploy-readiness", "size-label"}
names = {c["name"]: c for c in checks}
bad = [f"required {r}: {names.get(r, {}).get('bucket', 'absent')}" for r in sorted(required)
       if r not in names or names[r]["bucket"] != "pass"]
bad += [f"{c['name']}: {c['bucket']}" for c in checks if c["bucket"] not in ("pass", "skipping")]
for c in checks:
    print(f"CHECK {c['bucket']:8} {c['workflow']} | {c['name']}")
if bad:
    print("CI_NOT_GREEN", bad); sys.exit(1)
print("CI_GREEN")
PY
  log "CI PR#$1 green at $2"
}
ff_push(){ # $1 = repo dir, $2 = expected current tip, $3 = new sha
  [ "$(remote_sha "$TARGET_REF")" = "$2" ] || refuse 78 "integration/importer moved before FF push; no push"
  git -C "$1" merge-base --is-ancestor "$2" "$3" || refuse 78 "$3 is not a fast-forward of $2"
  git -C "$1" push "$ORIGIN_URL" "$3:$TARGET_REF" >>"$RUN_DIR/push.log" 2>&1 || refuse 78 "FF push rejected (no retry, no force)"
  local now; now=$(remote_sha "$TARGET_REF"); [ "$now" = "$3" ] || refuse 78 "ls-remote integration/importer=$now, expected $3"
  log "LANDED integration/importer $2 -> $3 (ordinary FF, ls-remote verified)"
  gh api "repos/$GH_REPO/commits/$3" --jq '"remote author=\(.commit.author.name) <\(.commit.author.email)> committer=\(.commit.committer.name) <\(.commit.committer.email)> tree=\(.commit.tree.sha)"' | tee -a "$RUN_DIR/run.log"
  local m; m=$(remote_sha "$FORBIDDEN_REF"); [ "$m" = "$MAIN_EXPECT" ] && log "MAIN unchanged $m" || log "ALERT main=$m != $MAIN_EXPECT (not written by this run)"
}
take_lock(){
  [ -e "$LOCK" ] || refuse 75 "canonical lock file absent (never created here)"
  [ "$(stat -c %i "$LOCK")" = "$LOCK_INODE" ] || refuse 75 "lock inode $(stat -c %i "$LOCK") != $LOCK_INODE"
  exec 9>>"$LOCK"; flock -n 9 || refuse 75 "canonical lock busy; not waiting, not stealing"
  log "LOCK acquired fd9 inode=$LOCK_INODE (released at exit; file preserved)"
}
scratch(){ # scratch bare repo outside the workspace, objects only: live tip from origin + S8-F from the verified bundle
  [ "$(sha "$BUNDLE")" = "$BUNDLE_SHA" ] || refuse 70 "bundle sha256 mismatch"
  SX=$(mktemp -d /tmp/land1910-scratch-XXXXXX)/r.git; git init -q --bare "$SX" || refuse 70 "scratch init"
  git -C "$SX" fetch -q --no-tags "$ORIGIN_URL" "$TARGET_REF:refs/remotes/origin/integration/importer" >>"$RUN_DIR/run.log" 2>&1 || refuse 72 "fetch tip"
  git -C "$SX" fetch -q --no-tags "$BUNDLE" "$BUNDLE_REF:refs/heads/s8f" >>"$RUN_DIR/run.log" 2>&1 || refuse 70 "fetch bundle"
  [ "$(git -C "$SX" rev-parse refs/heads/s8f)" = "$H" ] || refuse 70 "bundle head != $H"
  log "SCRATCH $SX tip=$(git -C "$SX" rev-parse refs/remotes/origin/integration/importer) s8f=$H"
}

MODE=${1:-}; shift || true
case "$MODE" in
# =====================================================================================================================
predict)
  new_run predict
  RT=$(remote_sha "$TARGET_REF"); log "REMOTE integration/importer=$RT main=$(remote_sha "$FORBIDDEN_REF")"
  scratch
  [ "$(git -C "$SX" rev-parse refs/remotes/origin/integration/importer)" = "$TIP" ] || { log "FRONTIER_MOVED tip != $TIP; use: classify $H"; exit 79; }
  [ "$(git -C "$SX" merge-base "$TIP" "$H")" = "$P" ] || refuse 74 "merge-base != $P"
  A=$(git -C "$SX" merge-tree --write-tree "$TIP" "$H"); ra=$?; B=$(git -C "$SX" merge-tree --write-tree "$H" "$TIP"); rb=$?
  log "MERGE_TREE tip,s8f rc=$ra out=[$(echo $A)] s8f,tip rc=$rb out=[$(echo $B)]"
  [ $ra = 0 ] && [ $rb = 0 ] && [ "$A" = "$PRED_TREE" ] && [ "$B" = "$PRED_TREE" ] || refuse 74 "prediction differs from $PRED_TREE"
  [ "$(git -C "$SX" diff --name-status "$H" "$PRED_TREE")" = $'A\t'"$DOC" ] || refuse 74 "tree vs S8-F is not exactly +$DOC"
  [ "$(git -C "$SX" diff --raw "$TIP" "$PRED_TREE")" = "$(git -C "$SX" diff --raw "$P" "$H")" ] || refuse 74 "tree vs tip != S8-F delta (UNION not exact)"
  [ "$(git -C "$SX" rev-parse "$PRED_TREE:$DOC")" = "$DOC_BLOB" ] && [ "$(git -C "$SX" rev-parse "$PRED_TREE:$CONTRACT")" = "$CONTRACT_BLOB" ] || refuse 74 "doc/contract blob"
  log "PREDICT_OK tree=$PRED_TREE = exact union (S8-F 17 paths + $DOC); read-only; nothing written remotely"; exit 0 ;;
# =====================================================================================================================
classify)
  CAND=${1:-}; is_sha "$CAND" || { echo "usage: classify <full candidate head sha>" >&2; exit 64; }
  new_run classify
  scratch
  NT=$(git -C "$SX" rev-parse refs/remotes/origin/integration/importer)
  git -C "$SX" cat-file -e "$CAND^{commit}" 2>/dev/null || git -C "$SX" fetch -q --no-tags "$S9A_REPO" "refs/heads/exec1910/s9a:refs/heads/s9a" >>"$RUN_DIR/run.log" 2>&1
  git -C "$SX" cat-file -e "$CAND^{commit}" 2>/dev/null || refuse 70 "candidate $CAND not available (S8-F bundle or $S9A_REPO branch exec1910/s9a)"
  MB=$(git -C "$SX" merge-base "$NT" "$CAND"); log "CLASSIFY tip=$NT candidate=$CAND merge_base=$MB tip_descends_from_$TIP=$(git -C "$SX" merge-base --is-ancestor "$TIP" "$NT" && echo yes || echo NO)"
  git -C "$SX" log --format='%H %P | %an <%ae> | %s' "$MB..$NT" >"$RUN_DIR/tip-commits.txt"
  git -C "$SX" diff --name-only "$MB" "$CAND" >"$RUN_DIR/side-candidate-paths.txt"
  git -C "$SX" diff --name-only "$MB" "$NT" >"$RUN_DIR/side-tip-paths.txt"
  git -C "$SX" diff --name-status "$MB" "$NT" >"$RUN_DIR/tip-delta-name-status.txt"
  comm -12 <(sort "$RUN_DIR/side-candidate-paths.txt") <(sort "$RUN_DIR/side-tip-paths.txt") >"$RUN_DIR/overlap-paths.txt"
  NTREE=$(git -C "$SX" merge-tree --write-tree --name-only "$NT" "$CAND" 2>&1); rc=$?
  echo "$NTREE" >"$RUN_DIR/merge-tree.txt"; log "MERGE_TREE rc=$rc first_line=$(echo "$NTREE" | head -1) overlap_paths=$(wc -l <"$RUN_DIR/overlap-paths.txt")"
  if [ $rc = 0 ]; then
    X=$(mktemp -d /tmp/land1910-tree-XXXXXX); git -C "$SX" archive "$(echo "$NTREE" | head -1)" | tar -x -C "$X"
    python3 "$SELECT" "$X" "$RUN_DIR/side-candidate-paths.txt" "$RUN_DIR/side-tip-paths.txt" >"$RUN_DIR/selection-conservative.txt" 2>&1
    log "SELECTION conservative superset: $(tail -n +1 "$RUN_DIR/selection-conservative.txt" | grep -c '^SELECT ') suites (manual narrowing per RECIPE.md section 7 and analysis/L2-2-DISPOSITION.md required)"
    git -C "$SX" diff --name-only "$MB" "$CAND" -- prisma/migrations "$CONTRACT" | sed 's/^/CANDIDATE_PINNED /' >>"$RUN_DIR/run.log"
    git -C "$SX" diff --name-only "$MB" "$NT" -- prisma/migrations "$CONTRACT" prisma/schema.prisma package.json package-lock.json | sed 's/^/TIP_PINNED_CHANGE /' >>"$RUN_DIR/run.log"
  fi
  log "FRONTIER_CLASSIFIED: parent must disposition (new bounded composition grant with exact tree + suite set). Nothing composed."
  exit 79 ;;
# =====================================================================================================================
compose)
  new_run compose
  [ "${COMPOSE_GRANT:-}" = 1 ] || refuse 78 "COMPOSE_GRANT=1 (parent grant) not set"
  for v in DONOR_NM_LOCK_SHA DONOR_CLIENT_DTS_SHA DONOR_CLIENT_SCHEMA_SHA; do [ -n "${!v:-}" ] || refuse 70 "$v not relayed (take it from the RT-NEW-1 receipt)"; done
  refuse_bypass_env
  [ ! -e "$W" ] || refuse 76 "$W exists: compose is one-shot; parent must disposition the previous attempt (never deleted here)"
  [ ! -e "$LANDING/state/compose-s8f.env" ] || refuse 76 "state/compose-s8f.env exists; one-shot"
  take_lock
  remote_state "$TIP"; land_ref_absent_or land/s8-f-accepted "$H"; land_ref_absent_or land/s8-f "__none__"
  [ "$(sha "$BUNDLE")" = "$BUNDLE_SHA" ] || refuse 70 "bundle sha256 mismatch"
  # --- fresh standalone clone (own .git, hooks, index); objects: tip from origin, S8-F only from the verified bundle
  mkdir -p "$(dirname "$W")"; git init -q -b "$BR" "$W" || refuse 70 "git init"
  cd "$W" || refuse 70 "cd $W"
  git config user.name "$NAME"; git config user.email "$EMAIL"; git config remote.origin.url "$ORIGIN_URL"
  git config remote.origin.fetch '+refs/heads/integration/importer:refs/remotes/origin/integration/importer'
  [ -z "$(git config --get core.hooksPath || true)" ] || refuse 71 "core.hooksPath set"
  timeout --foreground 900 git fetch -q --no-tags origin >>"$RUN_DIR/run.log" 2>&1 || refuse 72 "fetch integration/importer"
  [ "$(git rev-parse refs/remotes/origin/integration/importer)" = "$TIP" ] && [ "$(git rev-parse "$TIP^{tree}")" = "$TIP_TREE" ] || refuse 72 "fetched tip/tree mismatch"
  git bundle verify "$BUNDLE" >>"$RUN_DIR/run.log" 2>&1 || refuse 70 "bundle verify"
  git fetch -q --no-tags "$BUNDLE" "$BUNDLE_REF:refs/heads/s8f-accepted" >>"$RUN_DIR/run.log" 2>&1 || refuse 70 "bundle fetch"
  [ "$(git rev-parse refs/heads/s8f-accepted)" = "$H" ] && [ "$(git rev-parse "$H^{tree}")" = "$H_TREE" ] && [ "$(git rev-parse "$H^@")" = "$P" ] || refuse 70 "S8-F head/tree/parent mismatch"
  check_commit_hygiene "$W" "$P" "$H"
  [ "$(ls .git/hooks | grep -vc '\.sample$')" = 0 ] || refuse 71 "fresh clone already has non-sample hooks"
  git update-ref "refs/heads/$BR" "$TIP" && git reset -q --hard HEAD || refuse 70 "checkout tip"
  [ "$(git rev-parse HEAD)" = "$TIP" ] && [ "$(git rev-parse --abbrev-ref HEAD)" = "$BR" ] || refuse 70 "branch not at tip"
  [ "$(sha prisma/schema.prisma)" = "$SCHEMA_SHA" ] && [ "$(sha package-lock.json)" = "$PKG_LOCK_SHA" ] || refuse 70 "schema/lockfile pins at tip"
  git diff --quiet "$TIP" "$H" -- prisma package.json package-lock.json || refuse 70 "S8-F changes prisma/package files (unexpected)"
  # --- runtime: copy (never install) node_modules from the RT-NEW-1 donor; donor is read-only
  D=$DONOR_REPO/node_modules
  [ "$(git -C "$DONOR_REPO" rev-parse HEAD)" = "$H" ] || refuse 71 "donor clone HEAD != $H"
  [ -d "$D" ] && [ ! -L "$D" ] || refuse 71 "donor node_modules absent or symlink"
  [ "$(sha "$D/.package-lock.json")" = "$DONOR_NM_LOCK_SHA" ] && [ "$(sha "$D/.prisma/client/index.d.ts")" = "$DONOR_CLIENT_DTS_SHA" ] \
    && [ "$(sha "$D/.prisma/client/schema.prisma")" = "$DONOR_CLIENT_SCHEMA_SHA" ] || refuse 71 "donor pins != relayed RT-NEW-1 receipt"
  cp -a "$D" node_modules || refuse 71 "cp -a node_modules"
  [ "$(sha node_modules/.package-lock.json)" = "$DONOR_NM_LOCK_SHA" ] && [ "$(sha node_modules/.prisma/client/index.d.ts)" = "$DONOR_CLIENT_DTS_SHA" ] || refuse 71 "copied pins"
  [ ! -e node_modules/.bin/prettier ] || refuse 71 "prettier inside product tree"
  for b in tsc eslint lefthook; do [ -x node_modules/.bin/$b ] || refuse 71 "node_modules/.bin/$b missing"; done
  npx --no-install lefthook install >"$RUN_DIR/lefthook-install.log" 2>&1 || refuse 71 "lefthook install"
  for hk in pre-commit commit-msg; do [ -x ".git/hooks/$hk" ] || refuse 71 ".git/hooks/$hk missing or not executable"; [ -f "$HOOK_REF_ROOT/.git/hooks/$hk" ] || refuse 71 "reference hook $HOOK_REF_ROOT/.git/hooks/$hk absent"; done
  LHV=$(./node_modules/.bin/lefthook version 2>&1 | head -1 | tr -d '[:space:]'); log "LEFTHOOK_VERSION=$LHV expect=$LEFTHOOK_EXPECT"
  [ "$LHV" = "$LEFTHOOK_EXPECT" ] || refuse 71 "lefthook version != $LEFTHOOK_EXPECT"
  normhook(){ sed "s|$2|@CLONE_ROOT@|g" "$1" | sha256sum | cut -c1-64; }
  HP=$(sha .git/hooks/pre-commit); HC=$(sha .git/hooks/commit-msg)
  RP=$(sha "$HOOK_REF_ROOT/.git/hooks/pre-commit"); RC_=$(sha "$HOOK_REF_ROOT/.git/hooks/commit-msg")
  NP=$(normhook .git/hooks/pre-commit "$W"); NC=$(normhook .git/hooks/commit-msg "$W")
  NRP=$(normhook "$HOOK_REF_ROOT/.git/hooks/pre-commit" "$HOOK_REF_ROOT"); NRC=$(normhook "$HOOK_REF_ROOT/.git/hooks/commit-msg" "$HOOK_REF_ROOT")
  log "HOOK_RAW own pre-commit=$HP commit-msg=$HC | ref($HOOK_REF_ROOT) pre-commit=$RP commit-msg=$RC_"
  log "HOOK_NORMALIZED own pre-commit=$NP commit-msg=$NC | ref pre-commit=$NRP commit-msg=$NRC"
  [ "$NP" = "$NRP" ] && [ "$NC" = "$NRC" ] || refuse 71 "path-normalized hook bodies differ from the reference lefthook $LEFTHOOK_EXPECT hooks"
  for hk in pre-commit commit-msg; do
    grep -qF "$W/node_modules/lefthook-linux-x64/bin/lefthook" ".git/hooks/$hk" || refuse 71 ".git/hooks/$hk does not reference $W/node_modules/lefthook-linux-x64/bin/lefthook"
    ! grep -qF "$HOOK_REF_ROOT" ".git/hooks/$hk" || refuse 71 ".git/hooks/$hk references the reference clone root"
  done
  log "HOOK_OK own hooks reference $W/node_modules/lefthook-linux-x64/bin/lefthook"
  ( cd "$PFX" && sha256sum -c --quiet "$PFX_MANIFEST" ) >"$RUN_DIR/prefix-verify.log" 2>&1 && [ "$(wc -l <"$PFX_MANIFEST")" = 56 ] || refuse 71 "prettier prefix manifest"
  export NODE_OPTIONS=--max-old-space-size=4096 npm_config_prefix="$PFX" npm_config_offline=true npm_config_update_notifier=false \
         npm_config_fund=false npm_config_audit=false PRISMA_HIDE_UPDATE_MESSAGE=1
  export GIT_AUTHOR_NAME="$NAME" GIT_AUTHOR_EMAIL="$EMAIL" GIT_COMMITTER_NAME="$NAME" GIT_COMMITTER_EMAIL="$EMAIL"
  V=$(npx --no-install prettier --version 2>>"$RUN_DIR/run.log"); [ "$V" = 3.9.9 ] || refuse 71 "prettier '$V'"
  git status --porcelain --untracked-files=no | grep -q . && refuse 71 "tracked files dirty before merge"
  log "RUNTIME wt=$W branch=$BR nm_lock=$DONOR_NM_LOCK_SHA client=$DONOR_CLIENT_DTS_SHA prettier=$V hooks ok"
  # --- mechanical composition: exact union, no edit
  git merge --no-ff --no-commit refs/heads/s8f-accepted >"$RUN_DIR/merge.log" 2>&1 || refuse 74 "git merge --no-commit failed (state preserved, no abort)"
  [ "$(git rev-parse MERGE_HEAD)" = "$H" ] || refuse 74 "MERGE_HEAD != $H"
  [ -z "$(git diff --name-only --diff-filter=U)" ] || refuse 74 "unmerged paths"
  ST=$(git write-tree); [ "$ST" = "$PRED_TREE" ] || refuse 74 "staged tree $ST != predicted $PRED_TREE"
  [ "$(git diff --cached --name-only "$TIP" | sort)" = "$(git diff --name-only "$P" "$H" | sort)" ] || refuse 74 "staged set != S8-F's 17 paths"
  [ "$(git rev-parse ":$CONTRACT")" = "$CONTRACT_BLOB" ] && [ "$(git rev-parse ":$DOC")" = "$DOC_BLOB" ] || refuse 74 "contract/doc blob"
  git diff --quiet || refuse 74 "worktree != index"
  log "MERGED (uncommitted) tree=$ST; no jest (0 composition-affected suites, RECIPE.md 4), no regen (generator inputs identical)"
  # --- one genuine hooked commit (pre-commit: R75 staged, tsc, eslint, prettier, prod-readiness-quick; commit-msg: R3)
  MSG=$RUN_DIR/commit-message.txt
  printf 'Merge S8-F native readers (%s) into integration/importer\n\nComposes the accepted S8-F candidate %s (tree %s, parent %s) with the S9-0 decision\nrecord on %s. The merged tree %s is the exact union: the 17 S8-F paths byte for byte\nplus %s. No composition edit and no regeneration.\nNon-production branch. Production promotion stays the separate owner stage.\n' \
    "${H:0:8}" "${H:0:8}" "${H_TREE:0:8}" "${P:0:8}" "${TIP:0:8}" "${PRED_TREE:0:8}" "$DOC" >"$MSG"
  grep -iqE "$BANNED_RE" "$MSG" && refuse 80 "commit message has a banned token"
  timeout -k 30 2400 git commit -F "$MSG" >"$RUN_DIR/commit.raw.log" 2>&1; rc=$?
  tail -40 "$RUN_DIR/commit.raw.log" >>"$RUN_DIR/run.log"; [ $rc = 0 ] || refuse 80 "hooked commit rc=$rc (genuine hooks; no bypass; state preserved)"
  M=$(git rev-parse HEAD); MT=$(git rev-parse 'HEAD^{tree}')
  [ "$(git rev-list --parents -n1 HEAD)" = "$M $TIP $H" ] || refuse 80 "parents != ($TIP, $H)"
  [ "$MT" = "$PRED_TREE" ] || refuse 80 "committed tree $MT != $PRED_TREE (hook rewrote bytes?)"
  check_commit_hygiene "$W" "$TIP" "$M"
  [ -z "$(git status --porcelain --untracked-files=no)" ] || refuse 80 "worktree not clean after commit"
  # --- export
  X=$RUN_DIR/export; mkdir -p "$X" "$LANDING/state"
  git bundle create "$X/land-s8f-${M:0:12}.bundle" "$TIP..refs/heads/$BR" >>"$RUN_DIR/run.log" 2>&1 && git bundle verify "$X/land-s8f-${M:0:12}.bundle" >>"$RUN_DIR/run.log" 2>&1 || refuse 80 "bundle export"
  git diff --name-status "$TIP" "$M" >"$X/name-status-vs-tip.txt"; git diff --name-status "$H" "$M" >"$X/name-status-vs-s8f.txt"
  { echo "tip=$TIP"; echo "s8f=$H tree=$H_TREE"; echo "merge=$M"; echo "tree=$MT"; echo "contract_blob=$CONTRACT_BLOB"; echo "doc_blob=$DOC_BLOB"
    git log -1 --format='author=%an <%ae>%ncommitter=%cn <%ce>%ndate=%cI' "$M"; echo "hooks raw pre-commit=$HP commit-msg=$HC normalized pre-commit=$NP commit-msg=$NC (== ref $HOOK_REF_ROOT normalized) lefthook=$LHV prettier=$V"; } >"$X/COMPOSE_RECEIPT.txt"
  ( cd "$X" && sha256sum ./* >SHA256SUMS )
  printf 'TIP=%s\nS8F=%s\nMERGE=%s\nTREE=%s\nWT=%s\nRECEIPT=%s\n' "$TIP" "$H" "$M" "$MT" "$W" "$X/COMPOSE_RECEIPT.txt" >"$LANDING/state/compose-s8f.env"
  log "DONE compose merge=$M tree=$MT (not pushed)"; exit 0 ;;
# =====================================================================================================================
stage)
  new_run stage
  [ "${STAGE_GRANT:-}" = 1 ] || refuse 78 "STAGE_GRANT=1 (parent grant) not set"
  S=$LANDING/state/compose-s8f.env; [ -f "$S" ] || refuse 70 "no compose state"
  M=$(sed -n 's/^MERGE=//p' "$S"); is_sha "$M" || refuse 70 "bad MERGE in state"
  [ ! -e "$LANDING/state/stage-s8f.env" ] || refuse 76 "already staged (one PR, CI once)"
  [ "$(git -C "$W" rev-parse "refs/heads/$BR")" = "$M" ] && [ "$(git -C "$W" rev-parse "$M^{tree}")" = "$PRED_TREE" ] || refuse 70 "clone branch/tree != state"
  remote_state "$TIP"; land_ref_absent_or land/s8-f-accepted "$H"; land_ref_absent_or land/s8-f "$M"
  push_land_ref "$W" "$H" land/s8-f-accepted
  push_land_ref "$W" "$M" land/s8-f
  BODY=$RUN_DIR/pr-body.md
  printf '%s\n' "Exact composition of the accepted S8-F candidate \`$H\` (tree \`$H_TREE\`) onto integration/importer \`$TIP\`." "" \
    "- Merge \`$M\`, parents (\`$TIP\`, \`$H\`), tree \`$PRED_TREE\` = the 17 S8-F paths byte for byte plus \`$DOC\`." \
    "- \`land/s8-f-accepted\` preserves the exact candidate bytes. No migration, no contract change against the S8-F tree." \
    "- Landing: one ordinary fast-forward push of this exact head after green CI. The merge button is not used. Non-production. \`main\` is untouched." >"$BODY"
  grep -iqE "$BANNED_RE" "$BODY" && refuse 80 "PR body has a banned token"
  URL=$(gh pr create -R "$GH_REPO" --base integration/importer --head land/s8-f --title "Land S8-F native readers onto integration/importer" --body-file "$BODY" 2>>"$RUN_DIR/run.log") || refuse 77 "gh pr create failed"
  PR=${URL##*/}; log "PR $URL"
  printf 'MERGE=%s\nPR=%s\nURL=%s\n' "$M" "$PR" "$URL" >"$LANDING/state/stage-s8f.env"
  log "DONE stage PR #$PR (CI observed once by 'ff' after it completes)"; exit 0 ;;
# =====================================================================================================================
ff)
  new_run ff
  [ "${FF_GRANT:-}" = 1 ] || refuse 78 "FF_GRANT=1 (parent grant) not set"
  M=$(sed -n 's/^MERGE=//p' "$LANDING/state/stage-s8f.env" 2>/dev/null); PR=$(sed -n 's/^PR=//p' "$LANDING/state/stage-s8f.env" 2>/dev/null)
  is_sha "$M" && [ -n "$PR" ] || refuse 70 "no stage state"
  check_acceptance "${ACCEPT_RECORD:-}" "$H"          # S8-F PG proof + source/binding reviews accepted for e1ec2fec
  check_acceptance "${LAND_RECORD:-}" "$M"            # parent landing GO for this exact composition
  remote_state "$TIP"
  [ "$(remote_sha refs/heads/land/s8-f)" = "$M" ] || refuse 77 "land/s8-f != $M"
  check_pr_ci "$PR" "$M"
  ff_push "$W" "$TIP" "$M"
  log "PR #$PR state=$(gh pr view "$PR" -R "$GH_REPO" --json state --jq .state) (expected MERGED by FF)"; exit 0 ;;
# =====================================================================================================================
s9a-stage|s9a-ff)
  S9=${1:-}; is_sha "$S9" || { echo "usage: $MODE <full S9-A head sha>" >&2; exit 64; }
  new_run "$MODE"
  G=$([ "$MODE" = s9a-stage ] && echo "${STAGE_GRANT:-}" || echo "${FF_GRANT:-}"); [ "$G" = 1 ] || refuse 78 "grant not set"
  cd "$S9A_REPO" || refuse 70 "cd $S9A_REPO"
  [ "$(git rev-parse HEAD)" = "$S9" ] && [ -z "$(git status --porcelain --untracked-files=all)" ] || refuse 70 "S9-A clone HEAD != $S9 or not clean"
  # Pure FF only: exactly one commit on the CURRENT tip, exactly the 4 reconciliation paths, no merges.
  remote_state "$TIP"
  [ "$(git rev-parse "$S9^@")" = "$TIP" ] || refuse 79 "S9-A parent != tip: not a pure FF; run 'classify $S9' (composition needed)"
  [ "$(git diff --name-only "$TIP" "$S9" | sort | tr '\n' ' ')" = "$S9A_PATHS " ] || refuse 74 "S9-A paths != the 4 reconciliation paths"
  git diff --quiet "$TIP" "$S9" -- prisma docs package.json package-lock.json || refuse 74 "S9-A touches pinned files"
  check_commit_hygiene "$S9A_REPO" "$TIP" "$S9"
  if [ "$MODE" = s9a-stage ]; then
    [ ! -e "$LANDING/state/stage-s9a.env" ] || refuse 76 "already staged"
    land_ref_absent_or land/s9-a "$S9"; push_land_ref "$S9A_REPO" "$S9" land/s9-a
    BODY=$RUN_DIR/pr-body.md
    printf '%s\n' "S9-A pure reconciliation functions \`$S9\` as one ordinary fast-forward of integration/importer \`$TIP\`." "" \
      "- Exactly 4 new paths under src/scout/reconciliation and test/scout/reconciliation. No migration, contract or module wiring." \
      "- Landing: one ordinary fast-forward push of this exact head after green CI. The merge button is not used. Non-production. \`main\` is untouched." >"$BODY"
    grep -iqE "$BANNED_RE" "$BODY" && refuse 80 "PR body has a banned token"
    URL=$(gh pr create -R "$GH_REPO" --base integration/importer --head land/s9-a --title "Land S9-A reconciliation functions onto integration/importer" --body-file "$BODY" 2>>"$RUN_DIR/run.log") || refuse 77 "gh pr create failed"
    printf 'HEAD=%s\nPR=%s\nURL=%s\n' "$S9" "${URL##*/}" "$URL" >"$LANDING/state/stage-s9a.env"; log "DONE s9a-stage $URL"; exit 0
  fi
  PR=$(sed -n 's/^PR=//p' "$LANDING/state/stage-s9a.env" 2>/dev/null); [ -n "$PR" ] || refuse 70 "no s9a stage state"
  check_acceptance "${ACCEPT_RECORD:-}" "$S9"          # S9-A gate + reviews accepted for this exact head
  check_acceptance "${LAND_RECORD:-}" "$S9"            # parent landing GO
  [ "$(remote_sha refs/heads/land/s9-a)" = "$S9" ] || refuse 77 "land/s9-a != $S9"
  check_pr_ci "$PR" "$S9"
  ff_push "$S9A_REPO" "$TIP" "$S9"; exit 0 ;;
*) echo "usage: $0 predict | classify <sha> | compose | stage | ff | s9a-stage <sha> | s9a-ff <sha>" >&2; exit 64 ;;
esac
