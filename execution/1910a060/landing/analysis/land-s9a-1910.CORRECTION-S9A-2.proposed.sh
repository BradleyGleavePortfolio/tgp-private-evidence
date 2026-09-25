#!/usr/bin/env bash
# land-s9a-1910.sh: LAND-PREP-S9A (EXEC-1910A060, Tier T3). Exact nonproduction composition of the accepted S9-A
# candidate be88909f onto the new integration frontier M = 62471b11 (the S8-F landing merge). Derived from
# land-s8f-1910.sh (sha256 2adc7e10…, incl. CORRECTION-1 path-normalized hook check). PREPARED; only `predict` and
# `classify` (read-only) were run by the preparer. compose/stage/ff need separate parent grants.
#
# Modes (each writes only a new run dir under landing/run/ and, for compose/stage, landing/state/):
#   predict        read-only. Scratch bare repo in /tmp. Proves merge-tree both orders == PRED_TREE and the exact union.
#                  Tip == M: PREDICT_OK. Tip == 1c5fbb04 and land/s8-f == M (S8-F ff pending): PREDICT_OK_PENDING_FF,
#                  computed from land/s8-f. Any other tip: exit 79.
#   classify HEAD  read-only frontier classification (always exits 79; parent dispositions).
#   compose        canonical lock. Remote tip MUST equal M. Fresh standalone clone, merge --no-ff --no-commit be88909f,
#                  tree == PRED_TREE, the L2-2 must-run suites ONCE via jest (--runInBand, explicit files), one genuine
#                  hooked Bradley commit (parents M, be88909f). No install/generate/regen/PG. Nothing is pushed.
#   stage          push land/s9-a-accepted = be88909f and land/s9-a = M2 (ordinary, absent-or-equal), open ONE PR.
#   ff             ACCEPT_RECORD (names be88909f) + LAND_RECORD (names M2) + PR CI green once: ordinary FF push.
# Invariants: Bradley author+committer; no trailers/banned tokens; no --no-verify/amend/force/'+' remote refspec/ref
# deletion/merge button; never refs/heads/main; first failure stops with state preserved; no loops or retries.
set -uo pipefail
export GIT_OPTIONAL_LOCKS=0

# ---------- fixed identities (observed 2026-09-25 ~21:55Z; see analysis/L2-2-DISPOSITION-S9A.md) ----------
GH_REPO=BradleyGleavePortfolio/growth-project-backend
ORIGIN_URL=https://github.com/$GH_REPO.git
TARGET_REF=refs/heads/integration/importer
FORBIDDEN_REF=refs/heads/main
TIP=62471b116267fdec6746073c4b4c80a154d09834            # M: S8-F landing merge; integration/importer after parent ff
TIP_TREE=23614f0b7dc33dc37b90cf4f27fcb8331912e60f
PRE_FF_TIP=1c5fbb0441178e0cfe6e9f8d72e955c645c265e9     # tip before S8-F ff; also the S9-A parent == merge base
MB=1c5fbb0441178e0cfe6e9f8d72e955c645c265e9
MAIN_EXPECT=1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47
H=be88909f4bf6a727a3bd376385aba91f209f989a              # exact accepted S9-A bytes (reused, never rebuilt)
H_TREE=54349476c9f92296f4595bda45d64a48534c4553
S9A_REPO=/home/user/workspace/worktrees/1910a060-s9a    # object source for H (branch exec1910/s9a); READ ONLY
S9A_REF=refs/heads/exec1910/s9a
S9A_GATE=/home/user/workspace/tgp-private-evidence/execution/1910a060/s9a/gate   # postformat-*.ts byte receipts
PRED_TREE=737c34a3b50cb823c9317d13e1b23797127338b9      # git merge-tree --write-tree M be88909f (both orders)
S9A_PATHS="src/scout/reconciliation/coverage.ts src/scout/reconciliation/reconcile.ts src/scout/reconciliation/types.ts test/scout/reconciliation/reconcile.spec.ts"
BLOB_COVERAGE=f50d9401adbf6dc79bcc6a30cee0c9ada60ddb06
BLOB_RECONCILE=bcc85e491c9d48fa9c63ed3489e13eaa2993b116
BLOB_TYPES=b75994271f22cef235ff945edded0c27a4c4e796
BLOB_SPEC=11f2a524e790815396c7b1bb97564f8dc1ba5394
CONTRACT=docs/contracts/importer-openapi.json; CONTRACT_BLOB=8ebf936a9f12087a807cb37b069592d0c1e96cb2
SCHEMA_SHA=0eb41f9a88ef3b77266e908a5ea814206c188d1bdb031bd96d746491fee84015
PKG_LOCK_SHA=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55
# L2-2 must-run set on the REAL M tree x REAL S9-A bytes (analysis/L2-2-DISPOSITION-S9A.md): 5 real-repo src/ walkers
# that read both sides' bytes + 2 conservative adds (S9-A's own spec; controller walker). Runs ONCE before the commit.
SUITES="test/deploy-readiness.spec.ts test/prod-readiness/env-discovery.spec.ts test/prod-readiness/operator-keys-artifact.spec.ts test/route-doc-drift.spec.ts test/scout/reconstruct/mapping-spec.third-source.spec.ts test/scout/reconciliation/reconcile.spec.ts test/dunning-v2-lockout-allowlist-route-table.spec.ts"
# CORRECTION-1 hook method (path-normalized against the reference clone's lefthook 2.1.9 hooks).
HOOK_REF_ROOT=/home/user/workspace/worktrees/1910a060-s8f
LEFTHOOK_EXPECT=2.1.9
LOCK=/home/user/workspace/execution/test-validation.lock; LOCK_INODE=667698
DONOR_REPO=/home/user/workspace/worktrees/1910a060-s8f       # RT-NEW-1 clone (HEAD e1ec2fec, same schema/lockfile): READ ONLY
DONOR_HEAD=e1ec2fecb71f315b6721d426ba0dacb84f304498
PFX=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9
PFX_MANIFEST=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256
W=/home/user/workspace/worktrees/1910a060-land-s9a-3          # (S9A-2: -3; clones -1/-2 preserved) fresh standalone composition clone (created by compose)
BR=land1910/s9a
LANDING=/home/user/workspace/tgp-private-evidence/execution/1910a060/landing
SELECT=$LANDING/analysis/select_suites.py
NAME="Bradley Gleave"; EMAIL=bradley@bradleytgpcoaching.com; WHO="$NAME <$EMAIL>"
BANNED_RE='claude|anthropic|openai|gpt[- ]|computer[- ]agent|perplexity|co-authored[- ]by|generated with|🤖|ai assist|\b(ai|agent)\b'

# ---------- helpers (as land-s8f-1910.sh) ----------
ts(){ date -u +%FT%TZ; }
sha(){ sha256sum "$1" | cut -c1-64; }
RUN_DIR=""
log(){ echo "$(ts) $*" | tee -a "$RUN_DIR/run.log"; }
refuse(){ local rc=$1; shift; log "REFUSED rc=$rc: $*"; exit "$rc"; }
new_run(){ RUN_DIR=$LANDING/run/s9a-$1-$(date -u +%Y%m%dT%H%M%SZ); mkdir -p "$RUN_DIR" || exit 70; log "RUN s9a-$1 pid=$$ user=$(id -un) node=$(node -v 2>/dev/null || echo n/a) git=$(git --version)"; }
is_sha(){ [[ "$1" =~ ^[0-9a-f]{40}$ ]]; }
remote_sha(){ git ls-remote "$ORIGIN_URL" "$1" 2>>"$RUN_DIR/run.log" | awk -v r="$1" '$2==r{print $1}'; }
refuse_bypass_env(){
  [ "${LEFTHOOK:-}" = 0 ] && refuse 71 "LEFTHOOK=0 would skip genuine hooks"
  [ -n "${LEFTHOOK_BIN:-}${LEFTHOOK_EXCLUDE:-}" ] && refuse 71 "LEFTHOOK_BIN/LEFTHOOK_EXCLUDE set"
  [ -n "${GIT_DIR:-}${GIT_WORK_TREE:-}${GIT_INDEX_FILE:-}" ] && refuse 71 "GIT_DIR/GIT_WORK_TREE/GIT_INDEX_FILE set"
  [ -n "$(git config --global --get core.hooksPath 2>/dev/null || true)" ] && refuse 71 "global core.hooksPath set"
  return 0
}
remote_state(){ # $1 = expected integration tip
  RT=$(remote_sha "$TARGET_REF"); RM=$(remote_sha "$FORBIDDEN_REF")
  git ls-remote "$ORIGIN_URL" 'refs/heads/land/*' >"$RUN_DIR/ls-remote-land.txt" 2>>"$RUN_DIR/run.log"
  log "REMOTE integration/importer=$RT main=$RM land_refs=$(wc -l <"$RUN_DIR/ls-remote-land.txt")"
  [ -n "$RT" ] || refuse 72 "ls-remote returned no integration/importer (credentials?)"
  [ "$RM" = "$MAIN_EXPECT" ] || refuse 72 "main is $RM, not $MAIN_EXPECT; parent must disposition (never written here)"
  [ "$RT" = "$1" ] || refuse 79 "FRONTIER integration/importer=$RT != expected $1 (S8-F ff not done, or moved); run 'classify' and stop"
}
land_ref_absent_or(){ local cur; cur=$(awk -v r="refs/heads/$1" '$2==r{print $1}' "$RUN_DIR/ls-remote-land.txt")
  [ -z "$cur" ] || [ "$cur" = "$2" ] || refuse 76 "remote $1 exists at $cur, not $2 (no force; parent must disposition)"; }
push_land_ref(){ # $1 repo, $2 sha, $3 land/<name>
  case "$3" in land/*) ;; *) refuse 64 "push_land_ref writes land/* only";; esac
  local cur; cur=$(remote_sha "refs/heads/$3")
  if [ -n "$cur" ]; then [ "$cur" = "$2" ] || refuse 76 "remote $3 at $cur != $2"; log "PUSH skip $3 already $2"; return 0; fi
  git -C "$1" push "$ORIGIN_URL" "$2:refs/heads/$3" >>"$RUN_DIR/push.log" 2>&1 || refuse 76 "push $3 failed (no retry)"
  [ "$(remote_sha "refs/heads/$3")" = "$2" ] || refuse 76 "ls-remote $3 != $2 after push"
  log "PUSH $3 = $2 (ordinary, ls-remote verified)"
}
check_commit_hygiene(){ # $1 repo, $2 base, $3 head
  local c bad
  bad=$(git -C "$1" log --format='%H%x09%an <%ae>%x09%cn <%ce>' "$2..$3" | awk -F'\t' -v w="$WHO" '$2!=w || $3!=w')
  [ -z "$bad" ] || refuse 73 "identity mismatch: $bad"
  for c in $(git -C "$1" rev-list "$2..$3"); do
    [ -z "$(git -C "$1" log -1 --format='%(trailers:only,unfold)' "$c" | tr -d '[:space:]')" ] || refuse 73 "$c has trailers"
    git -C "$1" log -1 --format=%B "$c" | grep -iqE "$BANNED_RE" && refuse 73 "$c message has a banned token"
  done
  log "HYGIENE ok $(git -C "$1" rev-list --count "$2..$3") commit(s) ${2:0:8}..${3:0:8}"
}
check_acceptance(){ local f=$1; shift
  [ -n "$f" ] && [ -f "$f" ] || refuse 75 "acceptance record missing (${f:-unset})"
  local s; for s in "$@"; do grep -q "$s" "$f" || refuse 75 "record $f does not name $s"; done
  grep -Eq '\bACCEPT(ED)?\b' "$f" || refuse 75 "record $f has no ACCEPT verdict"
  grep -Eiq '\bNOT ACCEPT|\bREJECT|\bNO-GO\b' "$f" && refuse 75 "record $f contains a negative verdict"
  log "ACCEPTANCE record=$f sha256=$(sha "$f") names=[$*]"; }
check_pr_ci(){ # $1 PR, $2 head. Observed ONCE.
  local j="$RUN_DIR/pr$1-checks.json" head
  head=$(gh pr view "$1" -R "$GH_REPO" --json headRefOid --jq .headRefOid) || refuse 77 "gh pr view failed"
  [ "$head" = "$2" ] || refuse 77 "PR #$1 head $head != $2"
  gh pr checks "$1" -R "$GH_REPO" --json name,state,bucket,workflow,link >"$j" 2>>"$RUN_DIR/run.log"
  python3 - "$j" <<'PY' >>"$RUN_DIR/run.log" 2>&1 || refuse 77 "PR CI not green or still pending (see $j); parent dispositions, no re-run loop"
import json, sys
checks = json.load(open(sys.argv[1]))
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
  log "CI PR#$1 green at $2"; }
ff_push(){ # $1 repo, $2 expected tip, $3 new sha
  [ "$(remote_sha "$TARGET_REF")" = "$2" ] || refuse 78 "integration/importer moved before FF push; no push"
  git -C "$1" merge-base --is-ancestor "$2" "$3" || refuse 78 "$3 is not a fast-forward of $2"
  git -C "$1" push "$ORIGIN_URL" "$3:$TARGET_REF" >>"$RUN_DIR/push.log" 2>&1 || refuse 78 "FF push rejected (no retry, no force)"
  local now; now=$(remote_sha "$TARGET_REF"); [ "$now" = "$3" ] || refuse 78 "ls-remote integration/importer=$now, expected $3"
  log "LANDED integration/importer $2 -> $3 (ordinary FF, ls-remote verified)"
  gh api "repos/$GH_REPO/commits/$3" --jq '"remote author=\(.commit.author.name) <\(.commit.author.email)> committer=\(.commit.committer.name) <\(.commit.committer.email)> tree=\(.commit.tree.sha)"' | tee -a "$RUN_DIR/run.log"
  local m; m=$(remote_sha "$FORBIDDEN_REF"); [ "$m" = "$MAIN_EXPECT" ] && log "MAIN unchanged $m" || log "ALERT main=$m != $MAIN_EXPECT (not written by this run)"; }
take_lock(){
  [ -e "$LOCK" ] || refuse 75 "canonical lock file absent (never created here)"
  [ "$(stat -c %i "$LOCK")" = "$LOCK_INODE" ] || refuse 75 "lock inode $(stat -c %i "$LOCK") != $LOCK_INODE"
  exec 9>>"$LOCK"; flock -n 9 || refuse 75 "canonical lock busy; not waiting, not stealing"
  log "LOCK acquired fd9 inode=$LOCK_INODE (released at exit; file preserved)"; }
fetch_s9a(){ # $1 repo: fetch exact S9-A from the accepted clone branch, verify sha/tree/parent/blobs/gate receipts
  git -C "$1" fetch -q --no-tags "$S9A_REPO" "$S9A_REF:refs/heads/s9a-accepted" >>"$RUN_DIR/run.log" 2>&1 || refuse 70 "fetch S9-A from $S9A_REPO"
  [ "$(git -C "$1" rev-parse refs/heads/s9a-accepted)" = "$H" ] && [ "$(git -C "$1" rev-parse "$H^{tree}")" = "$H_TREE" ] \
    && [ "$(git -C "$1" rev-parse "$H^@")" = "$MB" ] || refuse 70 "S9-A head/tree/parent mismatch"
  [ "$(git -C "$1" diff --name-only "$MB" "$H" | sort | tr '\n' ' ')" = "$S9A_PATHS " ] || refuse 70 "S9-A paths != the 4"
  local f b n
  for f in $S9A_PATHS; do
    case "$f" in *coverage.ts) b=$BLOB_COVERAGE;; *reconcile.spec.ts) b=$BLOB_SPEC;; *reconcile.ts) b=$BLOB_RECONCILE;; *types.ts) b=$BLOB_TYPES;; esac
    n=$(basename "$f")
    [ "$(git -C "$1" rev-parse "$H:$f")" = "$b" ] || refuse 70 "blob $f != $b"
    [ "$(git hash-object "$S9A_GATE/postformat-$n")" = "$b" ] || refuse 70 "gate receipt postformat-$n != $b"
  done
  log "S9A exact $H tree=$H_TREE parent=$MB blobs==gate postformat receipts"; }
scratch(){ # objects only: live tip + land/s8-f from origin, S9-A from the accepted clone
  SX=$(mktemp -d /tmp/land1910-s9a-scratch-XXXXXX)/r.git; git init -q --bare "$SX" || refuse 70 "scratch init"
  git -C "$SX" fetch -q --no-tags "$ORIGIN_URL" "$TARGET_REF:refs/remotes/origin/integration/importer" "refs/heads/land/s8-f:refs/remotes/origin/land/s8-f" >>"$RUN_DIR/run.log" 2>&1 || refuse 72 "fetch tip/land/s8-f"
  fetch_s9a "$SX"
  log "SCRATCH $SX tip=$(git -C "$SX" rev-parse refs/remotes/origin/integration/importer) land/s8-f=$(git -C "$SX" rev-parse refs/remotes/origin/land/s8-f)"; }

MODE=${1:-}; shift || true
case "$MODE" in
# =====================================================================================================================
predict)
  new_run predict
  scratch
  RT=$(git -C "$SX" rev-parse refs/remotes/origin/integration/importer); LS=$(git -C "$SX" rev-parse refs/remotes/origin/land/s8-f)
  log "REMOTE integration/importer=$RT land/s8-f=$LS main=$(remote_sha "$FORBIDDEN_REF")"
  if [ "$RT" = "$TIP" ]; then STATUS=PREDICT_OK
  elif [ "$RT" = "$PRE_FF_TIP" ] && [ "$LS" = "$TIP" ]; then STATUS=PREDICT_OK_PENDING_FF
  else log "FRONTIER_MOVED tip=$RT (neither M nor pre-ff 1c5fbb04 with land/s8-f==M); use: classify $H"; exit 79; fi
  [ "$(git -C "$SX" rev-parse "$TIP^{tree}")" = "$TIP_TREE" ] || refuse 74 "M tree != $TIP_TREE"
  [ "$(git -C "$SX" merge-base "$TIP" "$H")" = "$MB" ] || refuse 74 "merge-base != $MB"
  A=$(git -C "$SX" merge-tree --write-tree "$TIP" "$H"); ra=$?; B=$(git -C "$SX" merge-tree --write-tree "$H" "$TIP"); rb=$?
  log "MERGE_TREE M,s9a rc=$ra out=[$(echo $A)] s9a,M rc=$rb out=[$(echo $B)]"
  [ $ra = 0 ] && [ $rb = 0 ] && [ "$A" = "$PRED_TREE" ] && [ "$B" = "$PRED_TREE" ] || refuse 74 "prediction differs from $PRED_TREE"
  [ "$(git -C "$SX" diff --raw "$TIP" "$PRED_TREE")" = "$(git -C "$SX" diff --raw "$MB" "$H")" ] || refuse 74 "tree-M != the 4 S9-A paths byte-identical"
  [ "$(git -C "$SX" diff --raw "$H" "$PRED_TREE")" = "$(git -C "$SX" diff --raw "$MB" "$TIP")" ] || refuse 74 "tree-S9A != the S8-F 17 paths byte-identical"
  OV=$(comm -12 <(git -C "$SX" diff --name-only "$MB" "$TIP" | sort) <(git -C "$SX" diff --name-only "$MB" "$H" | sort) | wc -l)
  [ "$OV" = 0 ] || refuse 74 "overlap paths: $OV"
  [ "$(git -C "$SX" rev-parse "$PRED_TREE:$CONTRACT")" = "$CONTRACT_BLOB" ] || refuse 74 "contract blob"
  log "$STATUS tree=$PRED_TREE = exact union (M + 4 S9-A paths; overlap 0); read-only; nothing written remotely"; exit 0 ;;
# =====================================================================================================================
classify)
  CAND=${1:-}; is_sha "$CAND" || { echo "usage: classify <full candidate head sha>" >&2; exit 64; }
  new_run classify
  scratch
  NT=$(git -C "$SX" rev-parse refs/remotes/origin/integration/importer)
  git -C "$SX" cat-file -e "$CAND^{commit}" 2>/dev/null || refuse 70 "candidate $CAND not available"
  MBX=$(git -C "$SX" merge-base "$NT" "$CAND"); log "CLASSIFY tip=$NT candidate=$CAND merge_base=$MBX"
  git -C "$SX" log --format='%H %P | %an <%ae> | %s' "$MBX..$NT" >"$RUN_DIR/tip-commits.txt"
  git -C "$SX" diff --name-only "$MBX" "$CAND" >"$RUN_DIR/side-candidate-paths.txt"
  git -C "$SX" diff --name-only "$MBX" "$NT" >"$RUN_DIR/side-tip-paths.txt"
  git -C "$SX" diff --name-status "$MBX" "$NT" >"$RUN_DIR/tip-delta-name-status.txt"
  comm -12 <(sort "$RUN_DIR/side-candidate-paths.txt") <(sort "$RUN_DIR/side-tip-paths.txt") >"$RUN_DIR/overlap-paths.txt"
  NTREE=$(git -C "$SX" merge-tree --write-tree --name-only "$NT" "$CAND" 2>&1); rc=$?
  echo "$NTREE" >"$RUN_DIR/merge-tree.txt"; log "MERGE_TREE rc=$rc first_line=$(echo "$NTREE" | head -1) overlap_paths=$(wc -l <"$RUN_DIR/overlap-paths.txt")"
  if [ $rc = 0 ]; then
    X=$(mktemp -d /tmp/land1910-s9a-tree-XXXXXX); git -C "$SX" archive "$(echo "$NTREE" | head -1)" | tar -x -C "$X"
    python3 "$SELECT" "$X" "$RUN_DIR/side-tip-paths.txt" "$RUN_DIR/side-candidate-paths.txt" >"$RUN_DIR/selection-conservative.txt" 2>&1
    python3 "$SELECT" "$X" "$RUN_DIR/side-candidate-paths.txt" "$RUN_DIR/side-tip-paths.txt" >"$RUN_DIR/selection-conservative-reversed.txt" 2>&1
    log "SELECTION conservative superset: $(grep -c '^SELECT ' "$RUN_DIR/selection-conservative.txt") / reversed $(grep -c '^SELECT ' "$RUN_DIR/selection-conservative-reversed.txt") suites (manual disposition required)"
  fi
  log "FRONTIER_CLASSIFIED: parent must disposition. Nothing composed."; exit 79 ;;
# =====================================================================================================================
compose)
  new_run compose
  [ "${COMPOSE_GRANT:-}" = 1 ] || refuse 78 "COMPOSE_GRANT=1 (parent grant) not set"
  for v in DONOR_NM_LOCK_SHA DONOR_CLIENT_DTS_SHA DONOR_CLIENT_SCHEMA_SHA; do [ -n "${!v:-}" ] || refuse 70 "$v not relayed"; done
  refuse_bypass_env
  [ ! -e "$W" ] || refuse 76 "$W exists: compose is one-shot; parent must disposition (never deleted here)"
  [ ! -e "$LANDING/state/compose-s9a.env" ] || refuse 76 "state/compose-s9a.env exists; one-shot"
  take_lock
  remote_state "$TIP"; land_ref_absent_or land/s9-a-accepted "$H"; land_ref_absent_or land/s9-a "__none__"
  mkdir -p "$(dirname "$W")"; git init -q -b "$BR" "$W" || refuse 70 "git init"
  cd "$W" || refuse 70 "cd $W"
  git config user.name "$NAME"; git config user.email "$EMAIL"; git config remote.origin.url "$ORIGIN_URL"
  git config remote.origin.fetch '+refs/heads/integration/importer:refs/remotes/origin/integration/importer'
  [ -z "$(git config --get core.hooksPath || true)" ] || refuse 71 "core.hooksPath set"
  timeout --foreground 900 git fetch -q --no-tags origin >>"$RUN_DIR/run.log" 2>&1 || refuse 72 "fetch integration/importer"
  [ "$(git rev-parse refs/remotes/origin/integration/importer)" = "$TIP" ] && [ "$(git rev-parse "$TIP^{tree}")" = "$TIP_TREE" ] || refuse 72 "fetched tip/tree mismatch"
  fetch_s9a "$W"
  check_commit_hygiene "$W" "$MB" "$H"
  [ "$(ls .git/hooks | grep -vc '\.sample$')" = 0 ] || refuse 71 "fresh clone already has non-sample hooks"
  git update-ref "refs/heads/$BR" "$TIP" && git reset -q --hard HEAD || refuse 70 "checkout tip"
  [ "$(git rev-parse HEAD)" = "$TIP" ] && [ "$(git rev-parse --abbrev-ref HEAD)" = "$BR" ] || refuse 70 "branch not at tip"
  [ "$(sha prisma/schema.prisma)" = "$SCHEMA_SHA" ] && [ "$(sha package-lock.json)" = "$PKG_LOCK_SHA" ] || refuse 70 "schema/lockfile pins at tip"
  git diff --quiet "$MB" "$H" -- prisma docs package.json package-lock.json || refuse 70 "S9-A touches pinned files (unexpected)"
  # --- runtime: copy (never install) node_modules from the donor; donor is read-only
  D=$DONOR_REPO/node_modules
  [ "$(git -C "$DONOR_REPO" rev-parse HEAD)" = "$DONOR_HEAD" ] || refuse 71 "donor clone HEAD != $DONOR_HEAD"
  # CORRECTION-S9A-1: compare in the composition clone; the read-only donor clone does not hold object M
  git -C "$W" diff --quiet "$DONOR_HEAD" "$TIP" -- prisma package.json package-lock.json || refuse 71 "donor schema/package inputs differ from tip"
  [ -d "$D" ] && [ ! -L "$D" ] || refuse 71 "donor node_modules absent or symlink"
  [ "$(sha "$D/.package-lock.json")" = "$DONOR_NM_LOCK_SHA" ] && [ "$(sha "$D/.prisma/client/index.d.ts")" = "$DONOR_CLIENT_DTS_SHA" ] \
    && [ "$(sha "$D/.prisma/client/schema.prisma")" = "$DONOR_CLIENT_SCHEMA_SHA" ] || refuse 71 "donor pins != relayed values"
  cp -a "$D" node_modules || refuse 71 "cp -a node_modules"
  [ "$(sha node_modules/.package-lock.json)" = "$DONOR_NM_LOCK_SHA" ] && [ "$(sha node_modules/.prisma/client/index.d.ts)" = "$DONOR_CLIENT_DTS_SHA" ] || refuse 71 "copied pins"
  [ ! -e node_modules/.bin/prettier ] || refuse 71 "prettier inside product tree"
  for b in tsc eslint lefthook jest; do [ -x node_modules/.bin/$b ] || refuse 71 "node_modules/.bin/$b missing"; done
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
  git merge --no-ff --no-commit refs/heads/s9a-accepted >"$RUN_DIR/merge.log" 2>&1 || refuse 74 "git merge --no-commit failed (state preserved, no abort)"
  [ "$(git rev-parse MERGE_HEAD)" = "$H" ] || refuse 74 "MERGE_HEAD != $H"
  [ -z "$(git diff --name-only --diff-filter=U)" ] || refuse 74 "unmerged paths"
  ST=$(git write-tree); [ "$ST" = "$PRED_TREE" ] || refuse 74 "staged tree $ST != predicted $PRED_TREE"
  [ "$(git diff --cached --name-only "$TIP" | sort | tr '\n' ' ')" = "$S9A_PATHS " ] || refuse 74 "staged set != the 4 S9-A paths"
  [ "$(git rev-parse ":$CONTRACT")" = "$CONTRACT_BLOB" ] || refuse 74 "contract blob"
  git diff --quiet || refuse 74 "worktree != index"
  log "MERGED (uncommitted) tree=$ST"
  # --- L2-2 must-run suites, ONCE (default config, no PG), explicit file list
  for s in $SUITES; do [ -f "$s" ] || refuse 79 "suite missing: $s"; done
  timeout -k 30 2400 ./node_modules/.bin/jest --ci --runInBand --runTestsByPath $SUITES >"$RUN_DIR/jest-affected.raw.log" 2>&1; rc=$?
  log "JEST rc=$rc $(grep -E '^(Test Suites|Tests):' "$RUN_DIR/jest-affected.raw.log" | tr '\n' ' ')"
  [ $rc = 0 ] || refuse 79 "must-run Jest failed (raw log preserved; no retry)"
  git diff --quiet || refuse 79 "a suite modified tracked files"
  [ "$(git write-tree)" = "$PRED_TREE" ] || refuse 79 "index drifted from the predicted tree"
  # CORRECTION-S9A-2: only '??' entries are untracked; the 4 staged 'A ' merge adds are expected here
  UT=$(git status --porcelain --untracked-files=all | grep '^??' | grep -v '^?? node_modules/' || true)
  [ -z "$UT" ] || refuse 79 "suites left untracked files: $(echo "$UT" | head -5 | tr '\n' ' ')"
  # --- one genuine hooked commit (pre-commit: R75 staged, tsc, eslint, prettier, prod-readiness-quick; commit-msg: R3)
  MSG=$RUN_DIR/commit-message.txt
  printf 'Merge S9-A reconciler (%s) into integration/importer\n\nComposes the accepted S9-A candidate %s (tree %s, parent %s) onto the landed S8-F merge\n%s. The merged tree %s is the exact union: the 4 S9-A paths byte for byte on top of\n%s, with no overlapping path. No composition edit and no regeneration.\nNon-production branch. Production promotion stays the separate owner stage.\n' \
    "${H:0:8}" "${H:0:8}" "${H_TREE:0:8}" "${MB:0:8}" "${TIP:0:8}" "${PRED_TREE:0:8}" "${TIP:0:8}" >"$MSG"
  grep -iqE "$BANNED_RE" "$MSG" && refuse 80 "commit message has a banned token"
  timeout -k 30 2400 git commit -F "$MSG" >"$RUN_DIR/commit.raw.log" 2>&1; rc=$?
  tail -40 "$RUN_DIR/commit.raw.log" >>"$RUN_DIR/run.log"; [ $rc = 0 ] || refuse 80 "hooked commit rc=$rc (genuine hooks; no bypass; state preserved)"
  M2=$(git rev-parse HEAD); MT=$(git rev-parse 'HEAD^{tree}')
  [ "$(git rev-list --parents -n1 HEAD)" = "$M2 $TIP $H" ] || refuse 80 "parents != ($TIP, $H)"
  [ "$MT" = "$PRED_TREE" ] || refuse 80 "committed tree $MT != $PRED_TREE (hook rewrote bytes?)"
  check_commit_hygiene "$W" "$TIP" "$M2"
  [ -z "$(git status --porcelain --untracked-files=no)" ] || refuse 80 "worktree not clean after commit"
  X=$RUN_DIR/export; mkdir -p "$X" "$LANDING/state"
  git bundle create "$X/land-s9a-${M2:0:12}.bundle" "$TIP..refs/heads/$BR" >>"$RUN_DIR/run.log" 2>&1 && git bundle verify "$X/land-s9a-${M2:0:12}.bundle" >>"$RUN_DIR/run.log" 2>&1 || refuse 80 "bundle export"
  git diff --name-status "$TIP" "$M2" >"$X/name-status-vs-tip.txt"; git diff --name-status "$H" "$M2" >"$X/name-status-vs-s9a.txt"
  { echo "tip=$TIP tree=$TIP_TREE"; echo "s9a=$H tree=$H_TREE"; echo "merge=$M2"; echo "tree=$MT"; echo "contract_blob=$CONTRACT_BLOB"
    echo "s9a_blobs coverage=$BLOB_COVERAGE reconcile=$BLOB_RECONCILE types=$BLOB_TYPES spec=$BLOB_SPEC"
    echo "suites=$SUITES"; echo "jest=$(grep -E '^(Test Suites|Tests):' "$RUN_DIR/jest-affected.raw.log" | tr '\n' ' ')"
    git log -1 --format='author=%an <%ae>%ncommitter=%cn <%ce>%ndate=%cI' "$M2"
    echo "hooks raw pre-commit=$HP commit-msg=$HC normalized pre-commit=$NP commit-msg=$NC (== ref $HOOK_REF_ROOT normalized) lefthook=$LHV prettier=$V"; } >"$X/COMPOSE_RECEIPT.txt"
  ( cd "$X" && sha256sum ./* >SHA256SUMS )
  printf 'TIP=%s\nS9A=%s\nMERGE=%s\nTREE=%s\nWT=%s\nRECEIPT=%s\n' "$TIP" "$H" "$M2" "$MT" "$W" "$X/COMPOSE_RECEIPT.txt" >"$LANDING/state/compose-s9a.env"
  log "DONE compose merge=$M2 tree=$MT (not pushed)"; exit 0 ;;
# =====================================================================================================================
stage)
  new_run stage
  [ "${STAGE_GRANT:-}" = 1 ] || refuse 78 "STAGE_GRANT=1 (parent grant) not set"
  S=$LANDING/state/compose-s9a.env; [ -f "$S" ] || refuse 70 "no compose state"
  M2=$(sed -n 's/^MERGE=//p' "$S"); is_sha "$M2" || refuse 70 "bad MERGE in state"
  [ ! -e "$LANDING/state/stage-s9a.env" ] || refuse 76 "already staged (one PR, CI once)"
  [ "$(git -C "$W" rev-parse "refs/heads/$BR")" = "$M2" ] && [ "$(git -C "$W" rev-parse "$M2^{tree}")" = "$PRED_TREE" ] || refuse 70 "clone branch/tree != state"
  remote_state "$TIP"; land_ref_absent_or land/s9-a-accepted "$H"; land_ref_absent_or land/s9-a "$M2"
  push_land_ref "$W" "$H" land/s9-a-accepted
  push_land_ref "$W" "$M2" land/s9-a
  BODY=$RUN_DIR/pr-body.md
  printf '%s\n' "Exact composition of the accepted S9-A candidate \`$H\` (tree \`$H_TREE\`) onto integration/importer \`$TIP\` (S8-F landed)." "" \
    "- Merge \`$M2\`, parents (\`$TIP\`, \`$H\`), tree \`$PRED_TREE\` = \`$TIP\` plus the 4 S9-A paths byte for byte; no overlapping path." \
    "- \`land/s9-a-accepted\` preserves the exact candidate bytes. No migration, contract, schema or module wiring change." \
    "- Landing: one ordinary fast-forward push of this exact head after green CI. The merge button is not used. Non-production. \`main\` is untouched." >"$BODY"
  grep -iqE "$BANNED_RE" "$BODY" && refuse 80 "PR body has a banned token"
  URL=$(gh pr create -R "$GH_REPO" --base integration/importer --head land/s9-a --title "Land S9-A reconciler onto integration/importer" --body-file "$BODY" 2>>"$RUN_DIR/run.log") || refuse 77 "gh pr create failed"
  PR=${URL##*/}; log "PR $URL"
  printf 'MERGE=%s\nPR=%s\nURL=%s\n' "$M2" "$PR" "$URL" >"$LANDING/state/stage-s9a.env"
  log "DONE stage PR #$PR (CI observed once by 'ff' after it completes)"; exit 0 ;;
# =====================================================================================================================
ff)
  new_run ff
  [ "${FF_GRANT:-}" = 1 ] || refuse 78 "FF_GRANT=1 (parent grant) not set"
  M2=$(sed -n 's/^MERGE=//p' "$LANDING/state/stage-s9a.env" 2>/dev/null); PR=$(sed -n 's/^PR=//p' "$LANDING/state/stage-s9a.env" 2>/dev/null)
  is_sha "$M2" && [ -n "$PR" ] || refuse 70 "no stage state"
  check_acceptance "${ACCEPT_RECORD:-}" "$H"          # S9-A accepted (s9a/S9A_ACCEPTANCE.md names be88909f)
  check_acceptance "${LAND_RECORD:-}" "$M2"           # parent landing GO for this exact composition
  remote_state "$TIP"
  [ "$(remote_sha refs/heads/land/s9-a)" = "$M2" ] || refuse 77 "land/s9-a != $M2"
  check_pr_ci "$PR" "$M2"
  ff_push "$W" "$TIP" "$M2"
  log "PR #$PR state=$(gh pr view "$PR" -R "$GH_REPO" --json state --jq .state) (expected MERGED by FF)"; exit 0 ;;
*) echo "usage: $0 predict | classify <sha> | compose | stage | ff" >&2; exit 64 ;;
esac
