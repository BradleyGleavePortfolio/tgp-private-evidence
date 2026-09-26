#!/usr/bin/env bash
# land-s9c-d3a9.sh (derived from land-s9b-d3a9.sh, session d3a9f701): LAND-PREP-S9C (EXEC-1910A060, Tier T3). Exact nonproduction
# composition of the S9-C candidate H (gate-2 commit on exec-d3a9/s9c-r2, sole parent MB = 5407efae, the S9-B landing merge)
# onto integration/importer TIP = a4af8e33 (S10-0 doc-only landing, PR #546: 5407efae -> ba6c740a -> a4af8e33). Keeps every
# land-s9b-d3a9.sh invariant and refusal (CORRECTION-1 path-normalized hooks, CORRECTION-S9A-1 donor inputs compared in the
# composition clone, CORRECTION-S9A-2 untracked-only leftover check). Deltas: S9-C DOES change docs/contracts/importer-openapi.json
# and the S9 decision doc (append-only Addendum B) -> docs delta must be exactly those two paths, prisma/package files unchanged;
# the only candidate path under src/scout/reconstruct is native-rules.ts (parent-granted additive export); tip-side commit
# hygiene is checked too (2 doc-only Bradley commits). Candidate objects come ONLY from the sha-pinned evidence bundle.
# PREPARED; NOT RUN. Candidate pins are __FILL_*__ until the gate-2 receipt exists (`fill-help` prints the exact commands);
# every mode except fill-help refuses 70 while any pin is unfilled. predict/classify (read-only): parent. compose/stage/ff: grants.
#
# Modes (each writes only a new run dir under landing/run/ and, for compose/stage, landing/state/):
#   fill-help      prints the commands that compute each __FILL__ value (read-only; writes nothing).
#   predict        read-only. Scratch bare repo in /tmp. Tip must == TIP; merge-tree both orders == PRED_TREE; exact union.
#   classify HEAD  read-only frontier classification (always exits 79; parent dispositions).
#   compose        canonical lock. Remote tip MUST equal TIP. Fresh standalone clone, merge --no-ff --no-commit H,
#                  tree == PRED_TREE, the must-run suites ONCE via jest (--runInBand, explicit files), one genuine
#                  hooked Bradley commit M (parents TIP, H). No install/generate/regen/PG. Nothing is pushed.
#   stage          push land/s9-c-accepted = H and land/s9-c = M (ordinary, absent-or-equal), open ONE PR.
#   ff             ACCEPT_RECORD (names H) + LAND_RECORD (names M) + PR CI green once: ordinary FF push.
# Invariants: Bradley author+committer; no trailers/banned tokens; no --no-verify/amend/force/'+' remote refspec/ref
# deletion/merge button; never refs/heads/main; first failure stops with state preserved; no loops or retries.
set -uo pipefail
export GIT_OPTIONAL_LOCKS=0

# ---------- fixed identities (observed 2026-09-26 ~03:20Z: ls-remote integration/importer=a4af8e33, main=1c10e2a1) ----------
GH_REPO=BradleyGleavePortfolio/growth-project-backend
ORIGIN_URL=https://github.com/$GH_REPO.git
TARGET_REF=refs/heads/integration/importer
FORBIDDEN_REF=refs/heads/main
TIP=a4af8e330bd4d6f882f0aebd411200b76d651aba   # S10-0 doc-only landing = integration/importer (PR #546)
TIP_TREE=82111726a41fb114aecc4095aaa3b6c08b6f6a64   # git rev-parse a4af8e33^{tree}
MB=5407efae319fd913e973c87f3be0d49786c4a3e0   # S9-B landing merge: S9-C sole parent == merge-base(TIP, S9-C)
MAIN_EXPECT=1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47
TIP_NCOMMITS=2                                # ba6c740a, a4af8e33 (both Bradley, doc-only)
H=__FILL_H__   # exact S9-C gate-2 commit (reused, never rebuilt)
H_TREE=__FILL_H_TREE__
CAND_BUNDLE=__FILL_CAND_BUNDLE__   # e.g. $LANDING/bundles/s9c-<H12>.bundle (5407efae..refs/heads/exec-d3a9/s9c-r2)
CAND_BUNDLE_SHA=__FILL_CAND_BUNDLE_SHA__
CAND_REF=refs/heads/exec-d3a9/s9c-r2
CAND_RECEIPT=__FILL_CAND_RECEIPT__   # /home/user/workspace/tgp-private-evidence/execution/d3a9f701/s9c/gate/HEAD-<H12>.txt
CAND_RECEIPT_SHA=__FILL_CAND_RECEIPT_SHA__   # 22 'blob <path> <blob> sha256=<sha>' lines (21 OWNED_PINS + the S9 doc)
CAND_RAW_SHA=__FILL_CAND_RAW_SHA__   # sha256 of diff --raw --no-abbrev MB H
CAND_NPATHS=22
TIPSIDE_PATHS="docs/decisions/2026-09-26-s10-induction.md"
PRED_TREE=__FILL_PRED_TREE__   # git merge-tree --write-tree TIP H (both orders)
CONTRACT=docs/contracts/importer-openapi.json; CONTRACT_BLOB=__FILL_CONTRACT_BLOB__   # S9-C contract blob (gate receipt blob line)
S9_DOC=docs/decisions/2026-09-25-s9-reconciliation.md
CAND_DOCS_EXPECT="$CONTRACT $S9_DOC"          # git diff --name-only MB H -- docs (sorted), exactly these two
RECONSTRUCT_DELTA_EXPECT="src/scout/reconstruct/native/native-rules.ts"   # parent-granted additive NATIVE_RULE_FIELDS export only
SCHEMA_SHA=0eb41f9a88ef3b77266e908a5ea814206c188d1bdb031bd96d746491fee84015
PKG_LOCK_SHA=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55
# Must-run set (d3a9, S9-C): the 16 S9-C gate SUITES (gate/PINS.env) U the 53 S9-B landing SUITES, deduplicated (59), gate order
# first. The tip side is doc-only (no selector input); the parent appends any extra classify selector output. Every path exists
# at 5407efae except catalogue-parity.spec.ts and g2-s9c-db-guard.spec.ts, which are S9-C owned (present in PRED_TREE).
SUITES="test/contracts/importer-contract.spec.ts test/scout/lifecycle/arbiter.spec.ts test/scout/lifecycle/lifecycle.service.spec.ts test/scout/orchestration/settle-hook.spec.ts src/scout/scout.service.spec.ts test/scout/reconciliation/catalogue-parity.spec.ts test/scout/g2-s9c-db-guard.spec.ts test/scout/reconciliation/facts.service.spec.ts test/scout/reconciliation/reconcile.spec.ts test/scout/g2-s9-db-guard.spec.ts test/scout/g2-s8g-db-guard.spec.ts test/scout/orchestration/reconstruct-run.spec.ts test/scout/orchestration/family-plan.spec.ts test/route-doc-drift.spec.ts test/scout/reconstruct/native/native-families.spec.ts test/scout/reconstruct/mapping-spec.spec.ts test/deploy-readiness.spec.ts test/prod-readiness/env-discovery.spec.ts test/prod-readiness/operator-keys-artifact.spec.ts test/scout/reconstruct/mapping-spec.third-source.spec.ts test/dunning-v2-lockout-allowlist-route-table.spec.ts test/scout/g2-s8c-db-guard.spec.ts test/scout/g2-s7l-db-guard.spec.ts test/scout/g2-s8b-db-guard.spec.ts test/invariants/locked_defaults.spec.ts test/doctrine-cleanup.spec.ts src/roman/voice/__tests__/voice-policy-lint-contract.spec.ts test/ai-credits-stream1.spec.ts test/ci/delivery-artifact.spec.ts test/ci/r100-pathspec.spec.ts test/ci/r75-boundaries.spec.ts test/ci/r75-gate.spec.ts test/ci/r75-wiring.spec.ts test/common/feature-flag-not-found.bootstrap.spec.ts test/community/challenges/community-challenges-progress.live.spec.ts test/community/community-dms.e2e.spec.ts test/community/community-foundation.e2e.spec.ts test/community/community-messages.e2e.spec.ts test/community/community-moderation.e2e.spec.ts test/community/community-plan-context.e2e.spec.ts test/community/community-posts.e2e.spec.ts test/community/community-reactions.e2e.spec.ts test/community/events/community-events.e2e.spec.ts test/community/rls/community-rls.spec.ts test/community/rls/community-v1-emoji-roundtrip.spec.ts test/community/schema/community-schema.spec.ts test/cors-config.spec.ts test/diagnostic-prompt-doctrine.spec.ts test/drop-coach-direct-enabled.spec.ts test/federation-inbound-constant-time.spec.ts test/first-win.controller.spec.ts test/lost-webhook-reconcile.service.spec.ts test/prod-readiness/auto-flipper.spec.ts test/prod-readiness/operator-keys-generator.spec.ts test/prod-readiness/provider-wiring-stripe-mux-sendgrid.spec.ts test/prod-readiness/provider-wiring-twilio-aws-fly-sentry-supabase-openai-cf.spec.ts test/prod-readiness/redactor.spec.ts test/prod-readiness/stub-scanner.spec.ts test/scout/entities/scout-entities.rls.live.spec.ts"
# CORRECTION-1 hook method (path-normalized against the reference clone's lefthook 2.1.9 hooks).
HOOK_REF_ROOT=/home/user/workspace/worktrees/1910a060-s8f
LEFTHOOK_EXPECT=2.1.9
LOCK=/home/user/workspace/execution/test-validation.lock; LOCK_INODE=692282
DONOR_REPO=/home/user/workspace/worktrees/1910a060-s8f       # RT-NEW-1 clone (HEAD e1ec2fec, same schema/lockfile): READ ONLY
DONOR_HEAD=e1ec2fecb71f315b6721d426ba0dacb84f304498
PFX=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9
PFX_MANIFEST=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256
W=/home/user/workspace/worktrees/d3a9-land-s9c               # fresh standalone composition clone (created by compose)
BR=land-d3a9/s9c
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
new_run(){ RUN_DIR=$LANDING/run/s9c-$1-$(date -u +%Y%m%dT%H%M%SZ); mkdir -p "$RUN_DIR" || exit 70; log "RUN s9c-$1 pid=$$ user=$(id -un) node=$(node -v 2>/dev/null || echo n/a) git=$(git --version)"; }
is_sha(){ [[ "$1" =~ ^[0-9a-f]{40}$ ]]; }
is_sha256(){ [[ "$1" =~ ^[0-9a-f]{64}$ ]]; }
pins_filled(){ # refuse (70) while any candidate pin is a placeholder or malformed
  local v; for v in H H_TREE PRED_TREE CONTRACT_BLOB; do is_sha "${!v}" || refuse 70 "pin $v unfilled/malformed (${!v}); see: $0 fill-help"; done
  for v in CAND_BUNDLE_SHA CAND_RECEIPT_SHA CAND_RAW_SHA; do is_sha256 "${!v}" || refuse 70 "pin $v unfilled/malformed (${!v}); see: $0 fill-help"; done
  case "$CAND_BUNDLE$CAND_RECEIPT" in *__FILL*) refuse 70 "CAND_BUNDLE/CAND_RECEIPT path unfilled";; esac
  case "$SUITES" in *__FILL*) refuse 70 "SUITES has a placeholder";; esac; }
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
  [ "$RT" = "$1" ] || refuse 79 "FRONTIER integration/importer=$RT != expected $1 (frontier moved); run 'classify' and stop"
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
fetch_cand(){ # $1 repo (must already hold MB): fetch exact S9-C from the sha-pinned bundle; verify sha/tree/parent/paths/blobs
  [ -f "$CAND_BUNDLE" ] && [ "$(sha "$CAND_BUNDLE")" = "$CAND_BUNDLE_SHA" ] || refuse 70 "candidate bundle missing or sha != $CAND_BUNDLE_SHA"
  [ -f "$CAND_RECEIPT" ] && [ "$(sha "$CAND_RECEIPT")" = "$CAND_RECEIPT_SHA" ] || refuse 70 "candidate gate receipt missing or sha != $CAND_RECEIPT_SHA"
  git -C "$1" bundle verify "$CAND_BUNDLE" >>"$RUN_DIR/run.log" 2>&1 || refuse 70 "bundle verify (prerequisite $MB absent?)"
  git -C "$1" fetch -q --no-tags "$CAND_BUNDLE" "$CAND_REF:refs/heads/cand-accepted" >>"$RUN_DIR/run.log" 2>&1 || refuse 70 "fetch candidate from bundle"
  [ "$(git -C "$1" rev-parse refs/heads/cand-accepted)" = "$H" ] && [ "$(git -C "$1" rev-parse "$H^{tree}")" = "$H_TREE" ] \
    && [ "$(git -C "$1" rev-parse "$H^@")" = "$MB" ] || refuse 70 "S9-C head/tree/parent mismatch (expect sole parent MB)"
  [ "$(git -C "$1" diff --raw --no-abbrev "$MB" "$H" | sha256sum | cut -c1-64)" = "$CAND_RAW_SHA" ] || refuse 70 "S9-C raw diff != pinned"
  [ "$(git -C "$1" diff --name-only "$MB" "$H" | wc -l)" = "$CAND_NPATHS" ] || refuse 70 "S9-C path count != $CAND_NPATHS"
  local n=0 p b
  while read -r _ p b _; do n=$((n+1)); [ "$(git -C "$1" rev-parse "$H:$p")" = "$b" ] || refuse 70 "blob $p != gate receipt $b"; done < <(grep '^blob ' "$CAND_RECEIPT")
  [ "$n" = "$CAND_NPATHS" ] || refuse 70 "gate receipt blob lines $n != $CAND_NPATHS"
  log "S9C exact $H tree=$H_TREE parent=$MB raw=$CAND_RAW_SHA blobs==gate receipt ($n) bundle=$CAND_BUNDLE_SHA"; }
cand_scope(){ # $1 repo, $2 rc: S9-C scope — prisma/package files untouched, docs delta exactly contract + S9 doc,
  # src/scout/reconstruct delta exactly native-rules.ts, S9 doc BASE bytes preserved as an exact prefix (append-only Addendum B)
  git -C "$1" diff --quiet "$MB" "$H" -- prisma package.json package-lock.json || refuse "$2" "S9-C touches prisma/package files (unexpected)"
  [ "$(git -C "$1" diff --name-only "$MB" "$H" -- docs | sort | tr '\n' ' ')" = "$(printf '%s\n' $CAND_DOCS_EXPECT | sort | tr '\n' ' ')" ] || refuse "$2" "S9-C docs delta != [$CAND_DOCS_EXPECT]"
  [ "$(git -C "$1" diff --name-only "$MB" "$H" -- src/scout/reconstruct | sort | tr '\n' ' ')" = "$RECONSTRUCT_DELTA_EXPECT " ] || refuse "$2" "S9-C src/scout/reconstruct delta != [$RECONSTRUCT_DELTA_EXPECT]"
  [ "$(git -C "$1" diff --numstat "$MB" "$H" -- "$S9_DOC" | cut -f2)" = 0 ] || refuse "$2" "S9 doc has deleted lines (Addendum B must be append-only)"
  local n; n=$(git -C "$1" cat-file -s "$MB:$S9_DOC")
  cmp -s <(git -C "$1" cat-file blob "$MB:$S9_DOC") <(git -C "$1" cat-file blob "$H:$S9_DOC" | head -c "$n") || refuse "$2" "S9 doc BASE bytes are not a prefix at H"
  log "SCOPE ok docs=[$CAND_DOCS_EXPECT] reconstruct=[$RECONSTRUCT_DELTA_EXPECT] prisma/package unchanged; S9 doc append-only"; }
scratch(){ # objects only: live tip from origin, S9-C from the pinned bundle
  SX=$(mktemp -d /tmp/land-d3a9-s9c-scratch-XXXXXX)/r.git; git init -q --bare "$SX" || refuse 70 "scratch init"
  git -C "$SX" fetch -q --no-tags "$ORIGIN_URL" "$TARGET_REF:refs/remotes/origin/integration/importer" >>"$RUN_DIR/run.log" 2>&1 || refuse 72 "fetch tip"
  git -C "$SX" cat-file -e "$MB^{commit}" 2>/dev/null || refuse 72 "tip history does not contain $MB (frontier rewritten?)"
  fetch_cand "$SX"
  log "SCRATCH $SX tip=$(git -C "$SX" rev-parse refs/remotes/origin/integration/importer)"; }

MODE=${1:-}; shift || true
case "$MODE" in
# =====================================================================================================================
fill-help)
  cat <<'HELP'
# Compute every __FILL__ pin (read-only except the bundle, which is written into landing/bundles/). Run in the S9-C clone
# only AFTER gate-2 has released the lock (git reads; no checkout/fetch). R=/home/user/workspace/worktrees/d3a9-s9c-r2
R=/home/user/workspace/worktrees/d3a9-s9c-r2; L=/home/user/workspace/tgp-private-evidence/execution/1910a060/landing
H=$(git -C $R rev-parse refs/heads/exec-d3a9/s9c-r2); echo H=$H              # == gate receipt HEAD-<12> name, HEAD^ == 5407efae
git -C $R rev-parse "$H^@"                                                     # must print only 5407efae319fd913e973c87f3be0d49786c4a3e0
echo H_TREE=$(git -C $R rev-parse "$H^{tree}")
echo CAND_RECEIPT=/home/user/workspace/tgp-private-evidence/execution/d3a9f701/s9c/gate/HEAD-${H:0:12}.txt
echo CAND_RECEIPT_SHA=$(sha256sum /home/user/workspace/tgp-private-evidence/execution/d3a9f701/s9c/gate/HEAD-${H:0:12}.txt | cut -c1-64)
grep -c '^blob ' /home/user/workspace/tgp-private-evidence/execution/d3a9f701/s9c/gate/HEAD-${H:0:12}.txt   # must be 22
echo CAND_RAW_SHA=$(git -C $R diff --raw --no-abbrev 5407efae319fd913e973c87f3be0d49786c4a3e0 "$H" | sha256sum | cut -c1-64)
git -C $R diff --name-only 5407efae319fd913e973c87f3be0d49786c4a3e0 "$H" | wc -l                # must be 22 (CAND_NPATHS)
echo CONTRACT_BLOB=$(git -C $R rev-parse "$H:docs/contracts/importer-openapi.json")     # == the receipt's blob line
git -C $R bundle create $L/bundles/s9c-${H:0:12}.bundle 5407efae319fd913e973c87f3be0d49786c4a3e0..refs/heads/exec-d3a9/s9c-r2
git -C $R bundle verify $L/bundles/s9c-${H:0:12}.bundle
echo CAND_BUNDLE=$L/bundles/s9c-${H:0:12}.bundle; echo CAND_BUNDLE_SHA=$(sha256sum $L/bundles/s9c-${H:0:12}.bundle | cut -c1-64)
# PRED_TREE: scratch bare repo holding the tip objects (from origin, or the read-only d3a9-land-s10-0 clone) + the bundle
SX=$(mktemp -d /tmp/land-d3a9-s9c-fill-XXXXXX)/r.git; git init -q --bare $SX
git -C $SX fetch -q --no-tags https://github.com/BradleyGleavePortfolio/growth-project-backend.git refs/heads/integration/importer:refs/remotes/origin/integration/importer
git -C $SX fetch -q --no-tags $L/bundles/s9c-${H:0:12}.bundle refs/heads/exec-d3a9/s9c-r2:refs/heads/cand
git -C $SX rev-parse a4af8e330bd4d6f882f0aebd411200b76d651aba^{tree}          # must be 82111726a41fb114aecc4095aaa3b6c08b6f6a64
echo PRED_TREE=$(git -C $SX merge-tree --write-tree a4af8e330bd4d6f882f0aebd411200b76d651aba "$H")
git -C $SX merge-tree --write-tree "$H" a4af8e330bd4d6f882f0aebd411200b76d651aba                # must print the same tree
HELP
  exit 0 ;;
predict)
  new_run predict
  pins_filled
  scratch
  RT=$(git -C "$SX" rev-parse refs/remotes/origin/integration/importer)
  log "REMOTE integration/importer=$RT main=$(remote_sha "$FORBIDDEN_REF")"
  [ "$RT" = "$TIP" ] || { log "FRONTIER_MOVED tip=$RT != TIP $TIP; run: classify $H (nothing composed)"; exit 79; }
  [ "$(git -C "$SX" rev-parse "$TIP^{tree}")" = "$TIP_TREE" ] || refuse 74 "TIP tree != $TIP_TREE"
  [ "$(git -C "$SX" rev-list --count "$MB..$TIP")" = "$TIP_NCOMMITS" ] || refuse 74 "tip side commit count != $TIP_NCOMMITS"
  check_commit_hygiene "$SX" "$MB" "$TIP"
  check_commit_hygiene "$SX" "$MB" "$H"
  [ "$(git -C "$SX" merge-base "$TIP" "$H")" = "$MB" ] || refuse 74 "merge-base != $MB"
  A=$(git -C "$SX" merge-tree --write-tree "$TIP" "$H"); ra=$?; B=$(git -C "$SX" merge-tree --write-tree "$H" "$TIP"); rb=$?
  log "MERGE_TREE tip,s9c rc=$ra out=[$(echo $A)] s9c,tip rc=$rb out=[$(echo $B)]"
  [ $ra = 0 ] && [ $rb = 0 ] && [ "$A" = "$PRED_TREE" ] && [ "$B" = "$PRED_TREE" ] || refuse 74 "prediction differs from $PRED_TREE"
  [ "$(git -C "$SX" diff --raw "$TIP" "$PRED_TREE")" = "$(git -C "$SX" diff --raw "$MB" "$H")" ] || refuse 74 "tree-TIP != the 22 S9-C paths byte-identical"
  [ "$(git -C "$SX" diff --raw "$H" "$PRED_TREE")" = "$(git -C "$SX" diff --raw "$MB" "$TIP")" ] || refuse 74 "tree-S9C != the tip-side S10-0 doc byte-identical"
  [ "$(git -C "$SX" diff --name-only "$MB" "$TIP" | sort | tr '\n' ' ')" = "$TIPSIDE_PATHS " ] || refuse 74 "tip side != the S10-0 doc only"
  OV=$(comm -12 <(git -C "$SX" diff --name-only "$MB" "$TIP" | sort) <(git -C "$SX" diff --name-only "$MB" "$H" | sort) | wc -l)
  [ "$OV" = 0 ] || refuse 74 "overlap paths: $OV"
  [ "$(git -C "$SX" rev-parse "$PRED_TREE:$CONTRACT")" = "$CONTRACT_BLOB" ] || refuse 74 "contract blob"
  cand_scope "$SX" 74
  log "PREDICT_OK tree=$PRED_TREE = exact union (TIP + 22 S9-C paths; overlap 0); read-only; nothing written remotely"; exit 0 ;;
# =====================================================================================================================

classify)
  CAND=${1:-}; is_sha "$CAND" || { echo "usage: classify <full candidate head sha>" >&2; exit 64; }
  new_run classify
  pins_filled
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
    X=$(mktemp -d /tmp/land-d3a9-s9c-tree-XXXXXX); git -C "$SX" archive "$(echo "$NTREE" | head -1)" | tar -x -C "$X"
    python3 "$SELECT" "$X" "$RUN_DIR/side-tip-paths.txt" "$RUN_DIR/side-candidate-paths.txt" >"$RUN_DIR/selection-conservative.txt" 2>&1
    python3 "$SELECT" "$X" "$RUN_DIR/side-candidate-paths.txt" "$RUN_DIR/side-tip-paths.txt" >"$RUN_DIR/selection-conservative-reversed.txt" 2>&1
    log "SELECTION conservative superset: $(grep -c '^SELECT ' "$RUN_DIR/selection-conservative.txt") / reversed $(grep -c '^SELECT ' "$RUN_DIR/selection-conservative-reversed.txt") suites (manual disposition required)"
  fi
  log "FRONTIER_CLASSIFIED: parent must disposition. Nothing composed."; exit 79 ;;
# =====================================================================================================================
compose)
  new_run compose
  pins_filled
  [ "${COMPOSE_GRANT:-}" = 1 ] || refuse 78 "COMPOSE_GRANT=1 (parent grant) not set"
  for v in DONOR_NM_LOCK_SHA DONOR_CLIENT_DTS_SHA DONOR_CLIENT_SCHEMA_SHA; do [ -n "${!v:-}" ] || refuse 70 "$v not relayed"; done
  refuse_bypass_env
  [ ! -e "$W" ] || refuse 76 "$W exists: compose is one-shot; parent must disposition (never deleted here)"
  [ ! -e "$LANDING/state/compose-s9c.env" ] || refuse 76 "state/compose-s9c.env exists; one-shot"
  take_lock
  remote_state "$TIP"; land_ref_absent_or land/s9-c-accepted "$H"; land_ref_absent_or land/s9-c "__none__"
  mkdir -p "$(dirname "$W")"; git init -q -b "$BR" "$W" || refuse 70 "git init"
  cd "$W" || refuse 70 "cd $W"
  git config user.name "$NAME"; git config user.email "$EMAIL"; git config remote.origin.url "$ORIGIN_URL"
  git config remote.origin.fetch '+refs/heads/integration/importer:refs/remotes/origin/integration/importer'
  [ -z "$(git config --get core.hooksPath || true)" ] || refuse 71 "core.hooksPath set"
  timeout --foreground 900 git fetch -q --no-tags origin >>"$RUN_DIR/run.log" 2>&1 || refuse 72 "fetch integration/importer"
  [ "$(git rev-parse refs/remotes/origin/integration/importer)" = "$TIP" ] && [ "$(git rev-parse "$TIP^{tree}")" = "$TIP_TREE" ] || refuse 72 "fetched tip/tree mismatch"
  fetch_cand "$W"
  [ "$(git rev-list --count "$MB..$TIP")" = "$TIP_NCOMMITS" ] || refuse 70 "tip side commit count != $TIP_NCOMMITS"
  check_commit_hygiene "$W" "$MB" "$TIP"
  check_commit_hygiene "$W" "$MB" "$H"
  [ "$(ls .git/hooks | grep -vc '\.sample$')" = 0 ] || refuse 71 "fresh clone already has non-sample hooks"
  git update-ref "refs/heads/$BR" "$TIP" && git reset -q --hard HEAD || refuse 70 "checkout tip"
  [ "$(git rev-parse HEAD)" = "$TIP" ] && [ "$(git rev-parse --abbrev-ref HEAD)" = "$BR" ] || refuse 70 "branch not at tip"
  [ "$(sha prisma/schema.prisma)" = "$SCHEMA_SHA" ] && [ "$(sha package-lock.json)" = "$PKG_LOCK_SHA" ] || refuse 70 "schema/lockfile pins at tip"
  cand_scope "$W" 70
  # --- runtime: copy (never install) node_modules from the donor; donor is read-only
  D=$DONOR_REPO/node_modules
  [ "$(git -C "$DONOR_REPO" rev-parse HEAD)" = "$DONOR_HEAD" ] || refuse 71 "donor clone HEAD != $DONOR_HEAD"
  # CORRECTION-S9A-1: compare in the composition clone; the read-only donor clone does not hold the tip objects
  git -C "$W" diff --quiet "$DONOR_HEAD" "$TIP" -- prisma package.json package-lock.json || refuse 71 "donor schema/package inputs differ from tip"
  [ -d "$D" ] && [ ! -L "$D" ] || refuse 71 "donor node_modules absent or symlink"
  [ "$(sha "$D/.package-lock.json")" = "$DONOR_NM_LOCK_SHA" ] && [ "$(sha "$D/.prisma/client/index.d.ts")" = "$DONOR_CLIENT_DTS_SHA" ] \
    && [ "$(sha "$D/.prisma/client/schema.prisma")" = "$DONOR_CLIENT_SCHEMA_SHA" ] || refuse 71 "donor pins != relayed values"
  # disk is tight (~4 GB free at prep): the single node_modules copy (~800 MB) is the only large write; require headroom first
  NMK=$(du -sk "$D" | cut -f1); AVK=$(df -Pk "$W" | awk 'NR==2{print $4}'); log "DISK node_modules=${NMK}K avail=${AVK}K"
  [ "$AVK" -gt $(( NMK + 1048576 )) ] || refuse 71 "insufficient disk: need node_modules + 1 GiB headroom (${NMK}K + 1048576K), have ${AVK}K"
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
  git merge --no-ff --no-commit refs/heads/cand-accepted >"$RUN_DIR/merge.log" 2>&1 || refuse 74 "git merge --no-commit failed (state preserved, no abort)"
  [ "$(git rev-parse MERGE_HEAD)" = "$H" ] || refuse 74 "MERGE_HEAD != $H"
  [ -z "$(git diff --name-only --diff-filter=U)" ] || refuse 74 "unmerged paths"
  ST=$(git write-tree); [ "$ST" = "$PRED_TREE" ] || refuse 74 "staged tree $ST != predicted $PRED_TREE"
  [ "$(git diff --cached --raw "$TIP")" = "$(git diff --raw "$MB" "$H")" ] || refuse 74 "staged set != the 22 S9-C paths byte-identical"
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
  # CORRECTION-S9A-2: only '??' entries are untracked; the staged 'A '/'M ' merge paths are expected here
  UT=$(git status --porcelain --untracked-files=all | grep '^??' | grep -v '^?? node_modules/' || true)
  [ -z "$UT" ] || refuse 79 "suites left untracked files: $(echo "$UT" | head -5 | tr '\n' ' ')"
  # --- one genuine hooked commit (pre-commit: R75 staged, tsc, eslint, prettier, prod-readiness-quick; commit-msg: R3)
  MSG=$RUN_DIR/commit-message.txt
  printf 'Merge S9-C reconciliation wiring (%s) into integration/importer\n\nComposes the accepted S9-C candidate %s (tree %s, parent %s) onto the landed S10-0\ndecision record %s. The merged tree %s is the exact union: the 22 S9-C paths byte for\nbyte on top of %s, with no overlapping path. No composition edit and no regeneration.\nNon-production branch. Production promotion stays the separate owner stage.\n' \
    "${H:0:8}" "${H:0:8}" "${H_TREE:0:8}" "${MB:0:8}" "${TIP:0:8}" "${PRED_TREE:0:8}" "${TIP:0:8}" >"$MSG"
  grep -iqE "$BANNED_RE" "$MSG" && refuse 80 "commit message has a banned token"
  timeout -k 30 2400 git commit -F "$MSG" >"$RUN_DIR/commit.raw.log" 2>&1; rc=$?
  tail -40 "$RUN_DIR/commit.raw.log" >>"$RUN_DIR/run.log"; [ $rc = 0 ] || refuse 80 "hooked commit rc=$rc (genuine hooks; no bypass; state preserved)"
  M3=$(git rev-parse HEAD); MT=$(git rev-parse 'HEAD^{tree}')
  [ "$(git rev-list --parents -n1 HEAD)" = "$M3 $TIP $H" ] || refuse 80 "parents != ($TIP, $H)"
  [ "$MT" = "$PRED_TREE" ] || refuse 80 "committed tree $MT != $PRED_TREE (hook rewrote bytes?)"
  check_commit_hygiene "$W" "$TIP" "$M3"
  [ -z "$(git status --porcelain --untracked-files=no)" ] || refuse 80 "worktree not clean after commit"
  X=$RUN_DIR/export; mkdir -p "$X" "$LANDING/state"
  git bundle create "$X/land-s9c-${M3:0:12}.bundle" "$TIP..refs/heads/$BR" >>"$RUN_DIR/run.log" 2>&1 && git bundle verify "$X/land-s9c-${M3:0:12}.bundle" >>"$RUN_DIR/run.log" 2>&1 || refuse 80 "bundle export"
  git diff --name-status "$TIP" "$M3" >"$X/name-status-vs-tip.txt"; git diff --name-status "$H" "$M3" >"$X/name-status-vs-s9c.txt"
  { echo "tip=$TIP tree=$TIP_TREE"; echo "s9c=$H tree=$H_TREE"; echo "merge=$M3"; echo "tree=$MT"; echo "contract_blob=$CONTRACT_BLOB"
    echo "s9c_bundle=$CAND_BUNDLE_SHA s9c_raw=$CAND_RAW_SHA s9c_receipt=$CAND_RECEIPT_SHA"
    echo "suites=$SUITES"; echo "jest=$(grep -E '^(Test Suites|Tests):' "$RUN_DIR/jest-affected.raw.log" | tr '\n' ' ')"
    git log -1 --format='author=%an <%ae>%ncommitter=%cn <%ce>%ndate=%cI' "$M3"
    echo "hooks raw pre-commit=$HP commit-msg=$HC normalized pre-commit=$NP commit-msg=$NC (== ref $HOOK_REF_ROOT normalized) lefthook=$LHV prettier=$V"; } >"$X/COMPOSE_RECEIPT.txt"
  ( cd "$X" && sha256sum ./* >SHA256SUMS )
  printf 'TIP=%s\nS9C=%s\nMERGE=%s\nTREE=%s\nWT=%s\nRECEIPT=%s\n' "$TIP" "$H" "$M3" "$MT" "$W" "$X/COMPOSE_RECEIPT.txt" >"$LANDING/state/compose-s9c.env"
  log "DONE compose merge=$M3 tree=$MT (not pushed)"; exit 0 ;;
# =====================================================================================================================
stage)
  new_run stage
  pins_filled
  [ "${STAGE_GRANT:-}" = 1 ] || refuse 78 "STAGE_GRANT=1 (parent grant) not set"
  S=$LANDING/state/compose-s9c.env; [ -f "$S" ] || refuse 70 "no compose state"
  M3=$(sed -n 's/^MERGE=//p' "$S"); is_sha "$M3" || refuse 70 "bad MERGE in state"
  [ ! -e "$LANDING/state/stage-s9c.env" ] || refuse 76 "already staged (one PR, CI once)"
  [ "$(git -C "$W" rev-parse "refs/heads/$BR")" = "$M3" ] && [ "$(git -C "$W" rev-parse "$M3^{tree}")" = "$PRED_TREE" ] || refuse 70 "clone branch/tree != state"
  remote_state "$TIP"; land_ref_absent_or land/s9-c-accepted "$H"; land_ref_absent_or land/s9-c "$M3"
  push_land_ref "$W" "$H" land/s9-c-accepted
  push_land_ref "$W" "$M3" land/s9-c
  BODY=$RUN_DIR/pr-body.md
  printf '%s\n' "Exact composition of the accepted S9-C candidate \`$H\` (tree \`$H_TREE\`) onto integration/importer \`$TIP\` (S10-0 decision record landed)." "" \
    "- Merge \`$M3\`, parents (\`$TIP\`, \`$H\`), tree \`$PRED_TREE\` = \`$TIP\` plus the 22 S9-C paths byte for byte; no overlapping path." \
    "- \`land/s9-c-accepted\` preserves the exact candidate bytes. No migration or schema change. The importer contract changes by regeneration only (blob \`$CONTRACT_BLOB\`); the S9 decision record gains the append-only Addendum B." \
    "- Landing: one ordinary fast-forward push of this exact head after green CI. The merge button is not used. Non-production. \`main\` is untouched." >"$BODY"
  grep -iqE "$BANNED_RE" "$BODY" && refuse 80 "PR body has a banned token"
  URL=$(gh pr create -R "$GH_REPO" --base integration/importer --head land/s9-c --title "Land S9-C reconciliation wiring onto integration/importer" --body-file "$BODY" 2>>"$RUN_DIR/run.log") || refuse 77 "gh pr create failed"
  PR=${URL##*/}; log "PR $URL"
  printf 'MERGE=%s\nPR=%s\nURL=%s\n' "$M3" "$PR" "$URL" >"$LANDING/state/stage-s9c.env"
  log "DONE stage PR #$PR (CI observed once by 'ff' after it completes)"; exit 0 ;;
# =====================================================================================================================
ff)
  new_run ff
  pins_filled
  [ "${FF_GRANT:-}" = 1 ] || refuse 78 "FF_GRANT=1 (parent grant) not set"
  M3=$(sed -n 's/^MERGE=//p' "$LANDING/state/stage-s9c.env" 2>/dev/null); PR=$(sed -n 's/^PR=//p' "$LANDING/state/stage-s9c.env" 2>/dev/null)
  is_sha "$M3" && [ -n "$PR" ] || refuse 70 "no stage state"
  check_acceptance "${ACCEPT_RECORD:-}" "$H"          # S9-C acceptance record must name H (gate + PG proof)
  check_acceptance "${LAND_RECORD:-}" "$M3"           # parent landing GO for this exact composition
  remote_state "$TIP"
  [ "$(remote_sha refs/heads/land/s9-c)" = "$M3" ] || refuse 77 "land/s9-c != $M3"
  check_pr_ci "$PR" "$M3"
  ff_push "$W" "$TIP" "$M3"
  log "PR #$PR state=$(gh pr view "$PR" -R "$GH_REPO" --json state --jq .state) (expected MERGED by FF)"; exit 0 ;;
*) echo "usage: $0 fill-help | predict | classify <sha> | compose | stage | ff" >&2; exit 64 ;;
esac
