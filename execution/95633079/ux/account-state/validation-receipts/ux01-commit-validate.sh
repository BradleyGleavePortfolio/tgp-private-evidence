#!/bin/bash
# UX-01 account-state: ordinary local commit of the reviewed tree, then minimum
# targeted validation on that committed, unchanged tree. Holds the canonical
# heavy lock nonblocking for the whole bounded run. First nonzero stops.
set -o pipefail
WT=/home/user/workspace/worktrees/ux01-state
SIB=/home/user/workspace/worktrees/ux07-mobile
OUT=/home/user/workspace/execution/95633079/ux/account-state/validation-receipts
LOCKFILE=/home/user/workspace/execution/test-validation.lock
EXPECT_TREE=a33cb8919495ed24e30623188dbb9f59c67df8bd
EXPECT_BASE=bc7b4e96fc1db54568bc209dbe1f7a4121501ac9
EXPECT_LOCK_SHA=840be0b8d5f4ed8272afd20290c8ebf6f6dacc394e6edae4ae5403e9fabe6b69
export CI=1

ts() { date -u +%FT%TZ; }
stage() { echo "=== [$(ts)] $*"; }

exec 200>"$LOCKFILE"
if ! flock -n 200; then
  echo "LOCK_BUSY: $LOCKFILE held by another owner; refusing (rc=75)" | tee "$OUT/00-lock-status.txt"
  exit 75
fi
echo "LOCK_ACQUIRED pid=$$ at $(ts)" | tee "$OUT/00-lock-status.txt"
trap 'echo "LOCK_RELEASED pid=$$ at $(ts)" | tee -a "$OUT/00-lock-status.txt"' EXIT

cd "$WT" || { echo "WORKTREE_MISSING"; exit 1; }

stage "pre-flight" | tee "$OUT/01-preflight.txt"
HEAD0=$(git rev-parse HEAD); TREE0=$(git write-tree)
{ echo "HEAD=$HEAD0"; echo "staged_tree=$TREE0"; git status --porcelain; git config --get core.hooksPath || echo "core.hooksPath=(unset)";
  echo "non-sample hooks: $(ls .git/hooks | grep -v '\.sample$' | tr '\n' ' ')(none if empty)";
  git var GIT_AUTHOR_IDENT; git var GIT_COMMITTER_IDENT; } | tee -a "$OUT/01-preflight.txt"
[ "$HEAD0" = "$EXPECT_BASE" ] || { echo "STOP: HEAD drift" | tee -a "$OUT/01-preflight.txt"; exit 2; }
[ "$TREE0" = "$EXPECT_TREE" ] || { echo "STOP: staged tree drift" | tee -a "$OUT/01-preflight.txt"; exit 2; }
[ -z "$(git status --porcelain | grep -v '^[AM]  ')" ] || { echo "STOP: unexpected dirty paths" | tee -a "$OUT/01-preflight.txt"; exit 2; }

stage "ordinary commit (no hooks configured, no bypass flag used)" | tee "$OUT/02-commit.txt"
git commit -q -F "$OUT/COMMIT_MESSAGE.txt" 2>&1 | tee -a "$OUT/02-commit.txt"
COMMIT_RC=${PIPESTATUS[0]}
echo "commit rc=$COMMIT_RC" | tee -a "$OUT/02-commit.txt"
[ "$COMMIT_RC" -eq 0 ] || exit 3
HEAD1=$(git rev-parse HEAD); TREE1=$(git rev-parse HEAD^{tree})
{ echo "new_head=$HEAD1"; echo "tree=$TREE1"; echo "parent=$(git rev-parse HEAD^)";
  git log -1 --format='author=%an <%ae> %ad%ncommitter=%cn <%ce> %cd' HEAD; echo "--- git status --porcelain (expect empty)"; git status --porcelain; } | tee -a "$OUT/02-commit.txt"
[ "$TREE1" = "$EXPECT_TREE" ] || { echo "STOP: committed tree != reviewed tree" | tee -a "$OUT/02-commit.txt"; exit 3; }
git cat-file commit HEAD > "$OUT/02-commit-object.txt"
git log -1 --format=%B HEAD > "$OUT/02-commit-message-actual.txt"
sha256sum "$OUT/COMMIT_MESSAGE.txt" "$OUT/02-commit-message-actual.txt" | tee -a "$OUT/02-commit.txt"

stage "environment reuse: verify parity, copy accepted node_modules (isolated copy)" | tee "$OUT/03-env-reuse.txt"
{ node --version; npm --version; which node npm;
  echo "package-lock sha256: $(sha256sum package-lock.json | cut -d' ' -f1) (expect $EXPECT_LOCK_SHA)";
  cmp package.json "$SIB/package.json" && echo "package.json identical to accepted sibling";
  cmp package-lock.json "$SIB/package-lock.json" && echo "package-lock.json identical to accepted sibling";
  echo "sibling installed record: $(sha256sum "$SIB/node_modules/.package-lock.json")";
  echo "sibling accepted install receipt: $(cat /home/user/workspace/execution/95633079/ux/mobile-presentation/validation-receipts/03-npm-ci-status.txt | head -1)"; } | tee -a "$OUT/03-env-reuse.txt"
[ "$(sha256sum package-lock.json | cut -d' ' -f1)" = "$EXPECT_LOCK_SHA" ] || { echo "STOP: lock sha mismatch" | tee -a "$OUT/03-env-reuse.txt"; exit 4; }
[ ! -e node_modules ] || { echo "STOP: node_modules already present" | tee -a "$OUT/03-env-reuse.txt"; exit 4; }
START=$(date +%s)
cp -a --reflink=auto "$SIB/node_modules" ./node_modules
CP_RC=$?
END=$(date +%s)
{ echo "cp -a --reflink=auto rc=$CP_RC duration_s=$((END-START))";
  echo "copied installed record: $(sha256sum node_modules/.package-lock.json)";
  echo "symlinks at node_modules top level: $(find node_modules -maxdepth 1 -type l | wc -l)";
  echo "node_modules is symlink? $([ -L node_modules ] && echo yes || echo no)";
  du -sh node_modules | cut -f1; git status --porcelain | head -3; echo "(git status after copy above; expect empty — node_modules ignored)"; } | tee -a "$OUT/03-env-reuse.txt"
[ "$CP_RC" -eq 0 ] || exit 4
[ -z "$(git status --porcelain)" ] || { echo "STOP: worktree dirty after copy" | tee -a "$OUT/03-env-reuse.txt"; exit 4; }

run_bounded() { # name seconds cmd...
  local name=$1 secs=$2; shift 2
  stage "$name (bounded ${secs}s, TERM+30s grace): $*" | tee "$OUT/$name-status.txt"
  local s=$(date +%s)
  timeout -k 30 "$secs" "$@" > "$OUT/$name.log" 2>&1
  local rc=$?
  local e=$(date +%s)
  echo "$name exit_status=$rc duration_s=$((e-s))" | tee -a "$OUT/$name-status.txt"
  return $rc
}

JEST=./node_modules/.bin/jest; TSC=./node_modules/.bin/tsc; ESLINT=./node_modules/.bin/eslint
for b in $JEST $TSC $ESLINT; do [ -x "$b" ] || { echo "STOP: missing local executable $b" | tee "$OUT/04-missing-bin.txt"; exit 5; }; done

run_bounded 04-jest-new-files 300 $JEST --ci --runInBand \
  src/storage/__tests__/importOfferDecision.test.ts \
  src/hooks/__tests__/useImportOfferDecision.test.tsx || { echo "STOP at 04"; exit 10; }

run_bounded 05-jest-authActions-filtered 300 $JEST --ci --runInBand \
  src/services/__tests__/authActions.test.ts -t 'import_offer_decision' || { echo "STOP at 05"; exit 11; }

run_bounded 06-tsc 180 $TSC --noEmit || { echo "STOP at 06"; exit 12; }

run_bounded 07-eslint-six-files 180 $ESLINT \
  src/storage/importOfferDecision.ts \
  src/hooks/useImportOfferDecision.ts \
  src/services/authActions.ts \
  src/storage/__tests__/importOfferDecision.test.ts \
  src/hooks/__tests__/useImportOfferDecision.test.tsx \
  src/services/__tests__/authActions.test.ts || { echo "STOP at 07"; exit 13; }

stage "post-run integrity" | tee "$OUT/08-postrun.txt"
{ echo "HEAD=$(git rev-parse HEAD)"; echo "tree=$(git rev-parse HEAD^{tree})"; git status --porcelain; echo "(status above; expect empty)"; } | tee -a "$OUT/08-postrun.txt"
echo "ALL_STAGES_PASSED commit=$HEAD1 tree=$TREE1" | tee "$OUT/09-summary.txt"
exit 0
