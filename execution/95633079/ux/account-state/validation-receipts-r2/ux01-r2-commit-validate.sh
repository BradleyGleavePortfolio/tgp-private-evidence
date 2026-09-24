#!/bin/bash
# UX-01 r2: ordinary additive commit of the reviewed r2 tree on 327731d4, then the
# frozen 4-stage bounded remainder. Nonblocking canonical lock; first nonzero stops.
set -o pipefail
WT=/home/user/workspace/worktrees/ux01-state
OUT=/home/user/workspace/execution/95633079/ux/account-state/validation-receipts-r2
LOCKFILE=/home/user/workspace/execution/test-validation.lock
EXPECT_PARENT=327731d4c6daf9c319fd0a79fc9cf4be9dc2f580
EXPECT_TREE=17a6ce1acea7e4d6e926113faeb6a57eafa684f3
EXPECT_LOCK_SHA=840be0b8d5f4ed8272afd20290c8ebf6f6dacc394e6edae4ae5403e9fabe6b69
EXPECT_INSTALLED_SHA=c4d7824b8b519c4a1720f13deb37b3d65e3f9987aca7734e352cee0ed0ac450b
export CI=1
ts() { date -u +%FT%TZ; }
stage() { echo "=== [$(ts)] $*"; }

exec 200>"$LOCKFILE"
if ! flock -n 200; then echo "LOCK_BUSY: refusing (rc=75)" | tee "$OUT/00-lock-status.txt"; exit 75; fi
echo "LOCK_ACQUIRED pid=$$ at $(ts)" | tee "$OUT/00-lock-status.txt"
trap 'echo "LOCK_RELEASED pid=$$ at $(ts)" | tee -a "$OUT/00-lock-status.txt"' EXIT

cd "$WT" || exit 1
stage "pre-flight" | tee "$OUT/01-preflight.txt"
HEAD0=$(git rev-parse HEAD); TREE0=$(git write-tree)
{ echo "HEAD=$HEAD0 (expect $EXPECT_PARENT)"; echo "staged_tree=$TREE0 (expect $EXPECT_TREE)"; git status --porcelain;
  echo "core.hooksPath=$(git config --get core.hooksPath || echo '(unset)')"; echo "non-sample hooks: $(ls .git/hooks | grep -v '\.sample$' | tr '\n' ' ')(none if empty)";
  git var GIT_AUTHOR_IDENT; git var GIT_COMMITTER_IDENT; node --version; npm --version;
  echo "package-lock: $(sha256sum package-lock.json | cut -d' ' -f1)"; echo "installed record: $(sha256sum node_modules/.package-lock.json | cut -d' ' -f1)"; } | tee -a "$OUT/01-preflight.txt"
[ "$HEAD0" = "$EXPECT_PARENT" ] || { echo "STOP: HEAD drift" | tee -a "$OUT/01-preflight.txt"; exit 2; }
[ "$TREE0" = "$EXPECT_TREE" ] || { echo "STOP: staged tree drift" | tee -a "$OUT/01-preflight.txt"; exit 2; }
[ "$(git status --porcelain)" = "M  src/hooks/__tests__/useImportOfferDecision.test.tsx" ] || { echo "STOP: unexpected status" | tee -a "$OUT/01-preflight.txt"; exit 2; }
[ "$(sha256sum package-lock.json | cut -d' ' -f1)" = "$EXPECT_LOCK_SHA" ] || { echo "STOP: lock sha drift"; exit 2; }
[ "$(sha256sum node_modules/.package-lock.json | cut -d' ' -f1)" = "$EXPECT_INSTALLED_SHA" ] || { echo "STOP: installed record drift"; exit 2; }

stage "ordinary additive commit (no amend; no hooks configured; no bypass flag)" | tee "$OUT/02-commit.txt"
git commit -q -F "$OUT/COMMIT_MESSAGE_R2.txt" 2>&1 | tee -a "$OUT/02-commit.txt"; RC=${PIPESTATUS[0]}
echo "commit rc=$RC" | tee -a "$OUT/02-commit.txt"; [ "$RC" -eq 0 ] || exit 3
HEAD1=$(git rev-parse HEAD); TREE1=$(git rev-parse HEAD^{tree})
{ echo "new_head=$HEAD1"; echo "tree=$TREE1"; echo "parent=$(git rev-parse HEAD^)"; git log -1 --format='author=%an <%ae> %ad%ncommitter=%cn <%ce> %cd' HEAD;
  echo "--- status (expect empty)"; git status --porcelain; } | tee -a "$OUT/02-commit.txt"
[ "$TREE1" = "$EXPECT_TREE" ] || { echo "STOP: committed tree != r2 tree" | tee -a "$OUT/02-commit.txt"; exit 3; }
git cat-file commit HEAD > "$OUT/02-commit-object.txt"; git log -1 --format=%B HEAD > "$OUT/02-commit-message-actual.txt"
sha256sum "$OUT/COMMIT_MESSAGE_R2.txt" "$OUT/02-commit-message-actual.txt" | tee -a "$OUT/02-commit.txt"

run_bounded() { local name=$1 secs=$2; shift 2
  stage "$name (bounded ${secs}s, TERM+30s): $*" | tee "$OUT/$name-status.txt"
  local s=$(date +%s); timeout -k 30 "$secs" "$@" > "$OUT/$name.log" 2>&1; local rc=$?; local e=$(date +%s)
  echo "$name exit_status=$rc duration_s=$((e-s))" | tee -a "$OUT/$name-status.txt"; return $rc; }
JEST=./node_modules/.bin/jest; TSC=./node_modules/.bin/tsc; ESLINT=./node_modules/.bin/eslint
for b in $JEST $TSC $ESLINT; do [ -x "$b" ] || { echo "STOP: missing $b"; exit 5; }; done

run_bounded 03-jest-hook-named-loading-case 300 $JEST --ci --runInBand \
  src/hooks/__tests__/useImportOfferDecision.test.tsx \
  -t 'is loading \(render nothing\) until the read settles, then ready with null when unanswered' || { echo "STOP at 03"; exit 10; }
run_bounded 04-jest-authActions-filtered 300 $JEST --ci --runInBand \
  src/services/__tests__/authActions.test.ts -t 'import_offer_decision' || { echo "STOP at 04"; exit 11; }
run_bounded 05-tsc 180 $TSC --noEmit || { echo "STOP at 05"; exit 12; }
run_bounded 06-eslint-six-files 180 $ESLINT \
  src/storage/importOfferDecision.ts src/hooks/useImportOfferDecision.ts src/services/authActions.ts \
  src/storage/__tests__/importOfferDecision.test.ts src/hooks/__tests__/useImportOfferDecision.test.tsx \
  src/services/__tests__/authActions.test.ts || { echo "STOP at 06"; exit 13; }

stage "post-run integrity" | tee "$OUT/07-postrun.txt"
{ echo "HEAD=$(git rev-parse HEAD)"; echo "tree=$(git rev-parse HEAD^{tree})"; git status --porcelain; echo "(expect empty above)"; } | tee -a "$OUT/07-postrun.txt"
echo "ALL_STAGES_PASSED commit=$HEAD1 tree=$TREE1" | tee "$OUT/08-summary.txt"
