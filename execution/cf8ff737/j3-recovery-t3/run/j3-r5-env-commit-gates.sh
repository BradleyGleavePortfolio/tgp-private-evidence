#!/usr/bin/env bash
# J3 r5 — exact environment, commit and gates driver.
# Grant: execution/cf8ff737/J3_R5_ENV_COMMIT_AND_GATES_GRANT.md. Sole writer: worktrees/ux03-j3/**, execution/cf8ff737/j3-recovery-t3/**.
# NOT TO BE RUN until parent relays B PG proof release of execution/test-validation.lock.
# Stages: 0 preflight -> 1 one plain `npm ci` (1500s) + pins -> 2 hook posture restore + identity -> 3 stage 2 paths, tree check,
#         ordinary `git commit -F` -> 4 post-commit verify -> 5 gates tsc(180) -> eslint 2 files(120) -> jest 2 files full(180)
#         -> 6 portable bundle/patch. First nonzero stops (no retry/fix/amend). Single canonical lock holder (flock -n, fd 9).
# RC map: 70 preflight, 71 npm ci nonzero/timeout, 72 env pin mismatch, 73 hook/identity, 74 stage/commit, 75 lock busy,
#         76 post-commit verify, 81/82/83 gate1/2/3 nonzero (raw rc also recorded), 0 all pass.
set -u
O=/home/user/workspace/execution/cf8ff737/j3-recovery-t3/run/receipts
W=/home/user/workspace/worktrees/ux03-j3
EV=/tmp/tgp-private-evidence/execution/95633079/ux/j3-source-selection/validation-receipts
MSG=$EV/23-r5-commit-message.txt
LOCK=/home/user/workspace/execution/test-validation.lock
BASE=820dbd04500b06648ce4c0820c1badced55d6d7c; R5TREE=823b97006f7df9617bad5516d7ef578189095e82
PATCHSHA=48d1c58355cd8d1d0129d802a3832b686ad9f18a6b877f5806df097e425a5fb6
PROD=src/screens/coach/ImportDataScreen.tsx; PRODBLOB=92ed52f5cc108f3a098062364d6af793cbb8e2b7
T1=src/screens/coach/__tests__/ImportDataScreen.test.tsx; T1BLOB=a1f65a6b61c3d3cda5d38ac53dac39575c21978c
T2=src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx; T2BLOB=34263aee6c60cebe4fedd192b5fd7ec9ec23401f
LOCKSHA=840be0b8d5f4ed8272afd20290c8ebf6f6dacc394e6edae4ae5403e9fabe6b69
PKGSHA=63e2e2e2327b5a305fd184c0737ff4eea91f2283e8aa5d313041bffbdf130d5f
INSTSHA=c4d7824b8b519c4a1720f13deb37b3d65e3f9987aca7734e352cee0ed0ac450b
MSGSHA_EXPECT_SUBJECT='test(importer): complete J3 screen mock isolation'
ID='Bradley Gleave <bradley@bradleytgpcoaching.com>'
KILLGRACE=10
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1
mkdir -p "$O"; log=$O/driver.log; sent=$O/driver.sentinel
ts(){ date -u +%FT%TZ; }
say(){ echo "$(ts) $*" | tee -a "$log"; }
stop(){ say "STOP stage=$1 rc=$2"; survivors; echo "RC=$2 STAGE=$1 END=$(ts) HEAD=$(git -C "$W" rev-parse HEAD 2>/dev/null) LOCK=released-on-exit" > "$sent"; exit "$2"; }
survivors(){ { echo "=== owned-survivor check $(ts) (descendants of driver pid $$) ==="; pgrep -a -P $$ | grep -v -e pgrep -e ' ps ' || echo "none"; } >> "$O/99-survivors.txt" 2>&1; }
sha(){ sha256sum "$1" | cut -d' ' -f1; }

[ -e "$sent" ] && { echo "sentinel exists from a prior run; refusing to rerun (no automatic retry)"; exit 75; }
exec 9>"$LOCK"
flock -n 9 || { echo "RC=75 STAGE=lock-busy END=$(ts)" > "$sent"; exit 75; }
echo "START $(ts) pid=$$ lock=held(fd9) script_sha256=$(sha "$0")" > "$log"
cd "$W" || stop cd 70

# ---- stage 0: preflight (all rc 70) ----
{ echo "=== 00 preflight $(ts) ==="
  echo "node=$(node -v) npm=$(npm -v) node_path=$(command -v node) npm_path=$(command -v npm)"
  echo "HEAD=$(git rev-parse HEAD) branch=$(git symbolic-ref -q HEAD)"
  git status --porcelain --untracked-files=all
  echo "diff sha256=$(git diff | sha256sum | cut -d' ' -f1)"
  git hash-object "$PROD" "$T1" "$T2"
  echo "package.json=$(sha package.json) package-lock=$(sha package-lock.json)"
  echo "hooksPath(local)=$(git config --local --get core.hooksPath)"; ls -a .git/hooks; ls -d .husky 2>&1
  echo "remotes=$(git remote | wc -l)"; ls -d node_modules 2>&1; } > "$O/00-preflight.txt" 2>&1
[ "$(node -v)" = v20.20.1 ] && [ "$(npm -v)" = 10.8.2 ] || stop pre-node-npm 70
[ "$(git rev-parse HEAD)" = $BASE ] || stop pre-HEAD 70
[ "$(git symbolic-ref -q HEAD)" = refs/heads/ux03-j3-source-selection ] || stop pre-branch 70
git diff --cached --quiet || stop pre-index-dirty 70
[ "$(git status --porcelain --untracked-files=all | sort)" = "$(printf ' M %s\n M %s\n' "$T2" "$T1" | sort)" ] || stop pre-status-set 70
[ "$(git diff | sha256sum | cut -d' ' -f1)" = $PATCHSHA ] || stop pre-patch-sha 70
[ "$(git hash-object "$PROD")" = $PRODBLOB ] && [ "$(git hash-object "$T1")" = $T1BLOB ] && [ "$(git hash-object "$T2")" = $T2BLOB ] || stop pre-blobs 70
[ "$(sha package.json)" = $PKGSHA ] && [ "$(sha package-lock.json)" = $LOCKSHA ] || stop pre-package-inputs 70
[ "$(git config --local --get core.hooksPath)" = /dev/null ] || stop pre-expected-recovery-hooksPath 70
[ -z "$(ls .git/hooks | grep -v '\.sample$')" ] && [ ! -e .husky ] || stop pre-hooks-present 70
[ "$(git remote | wc -l)" = 0 ] || stop pre-remotes 70
[ ! -e node_modules ] || stop pre-node_modules-exists 70
[ "$(head -c 200 "$MSG")" = "$MSGSHA_EXPECT_SUBJECT" ] && [ "$(wc -c < "$MSG")" = 49 ] || stop pre-message 70
say "stage0 preflight OK"

# ---- stage 1: one plain npm ci (recorded mobile recipe) ----
say "stage1 npm ci start (bound 1500s, kill grace ${KILLGRACE}s)"
t0=$(date +%s); timeout -k $KILLGRACE 1500 npm ci > "$O/01-npm-ci.log" 2>&1; rc=$?; t1=$(date +%s)
echo "npm ci exit_status=$rc duration_s=$((t1-t0))" > "$O/01-npm-ci-status.txt"; survivors
[ $rc = 0 ] || stop "npm-ci(raw_rc=$rc)" 71
{ echo "=== 02 env pins $(ts) ==="
  echo "node=$(node -v) npm=$(npm -v)"
  echo "package.json=$(sha package.json) package-lock=$(sha package-lock.json) installed-record=$(sha node_modules/.package-lock.json)"
  echo "node_modules symlink? $([ -L node_modules ] && echo yes || echo no); top-level symlinks=$(find node_modules -maxdepth 1 -type l | wc -l)"
  git status --porcelain --untracked-files=normal
  for p in typescript eslint jest react-native-safe-area-context @testing-library/react-native jest-expo; do
    printf '%s=%s\n' "$p" "$(node -p "require('./node_modules/$p/package.json').version" 2>/dev/null || echo absent)"; done
  ./node_modules/.bin/tsc --version; ./node_modules/.bin/eslint --version; ./node_modules/.bin/jest --version; } > "$O/02-env-pins.txt" 2>&1
[ "$(sha package.json)" = $PKGSHA ] && [ "$(sha package-lock.json)" = $LOCKSHA ] || stop env-package-inputs-changed 72
[ "$(sha node_modules/.package-lock.json)" = $INSTSHA ] || stop env-installed-record-mismatch 72
[ ! -L node_modules ] || stop env-node_modules-symlink 72
[ "$(git status --porcelain --untracked-files=all | sort)" = "$(printf ' M %s\n M %s\n' "$T2" "$T1" | sort)" ] || stop env-tracked-bytes-changed 72
[ "$(git diff | sha256sum | cut -d' ' -f1)" = $PATCHSHA ] || stop env-patch-sha-changed 72
say "stage1 env pins OK"

# ---- stage 2: restore recorded mobile no-configured-hooks posture + repo-local identity ----
{ echo "=== 03 hook posture / identity $(ts) ==="
  echo "before: local core.hooksPath=$(git config --local --get core.hooksPath)"
  git config --local --unset core.hooksPath; echo "unset rc=$?"
  echo "after: effective core.hooksPath=[$(git config --get core.hooksPath)] (empty = unset/default)"
  echo "global/system hooksPath=[$(git config --global --get core.hooksPath 2>/dev/null)][$(git config --system --get core.hooksPath 2>/dev/null)]"
  echo ".git/hooks:"; ls -a .git/hooks; echo "non-sample hooks: [$(ls .git/hooks | grep -v '\.sample$')]"; ls -d .husky 2>&1
  git config --local user.name "Bradley Gleave"; git config --local user.email bradley@bradleytgpcoaching.com
  echo "author=$(git var GIT_AUTHOR_IDENT)"; echo "committer=$(git var GIT_COMMITTER_IDENT)"
  echo "NOTE: no hooks are configured; this is the recorded mobile posture, not a bypass and not genuine hook execution."; } > "$O/03-hooks-identity.txt" 2>&1
[ -z "$(git config --get core.hooksPath)" ] || stop hooksPath-still-set 73
[ -z "$(ls .git/hooks | grep -v '\.sample$')" ] && [ ! -e .husky ] || stop hooks-present 73
[ "$(git var GIT_AUTHOR_IDENT | sed 's/ [0-9]* [+-][0-9]*$//')" = "$ID" ] && [ "$(git var GIT_COMMITTER_IDENT | sed 's/ [0-9]* [+-][0-9]*$//')" = "$ID" ] || stop identity 73
say "stage2 hooks/identity OK"

# ---- stage 3: stage exactly two paths, tree check, ordinary commit ----
{ echo "=== 04 stage + tree check $(ts) ==="
  git add -- "$T1" "$T2"; echo "add rc=$?"
  git status --porcelain --untracked-files=no; git diff --cached --stat
  echo "write-tree=$(git write-tree) expected=$R5TREE"; } > "$O/04-stage-treecheck.txt" 2>&1
[ "$(git write-tree)" = $R5TREE ] || stop staged-tree-mismatch 74
[ "$(git diff --cached --name-only | sort)" = "$(printf '%s\n%s\n' "$T2" "$T1" | sort)" ] || stop staged-path-set 74
cp "$MSG" "$O/05-approved-message.txt"
git commit -F "$MSG" > "$O/05-commit.txt" 2>&1; rc=$?; echo "commit exit=$rc" >> "$O/05-commit.txt"
[ $rc = 0 ] || stop commit 74
say "stage3 commit rc 0 head=$(git rev-parse HEAD)"

# ---- stage 4: post-commit verification ----
H=$(git rev-parse HEAD)
{ echo "=== 06 post-commit $(ts) ==="
  echo "head=$H"; echo "tree=$(git rev-parse HEAD^{tree})"; echo "parent=$(git rev-parse HEAD^)"; echo "parents=$(git rev-list --parents -n1 HEAD)"
  echo "--- raw commit object ---"; git cat-file commit HEAD
  echo "--- actual message bytes ---"; git log -1 --format=%B HEAD | od -c | tail -3
  echo "trailers=[$(git log -1 --format='%(trailers)' HEAD)]"
  echo "product blob=$(git rev-parse HEAD:$PROD)"; echo "--- status (tracked) ---"; git status --porcelain --untracked-files=no
  git diff-tree -r --stat $BASE HEAD; } > "$O/06-post-commit.txt" 2>&1
[ "$(git rev-parse HEAD^{tree})" = $R5TREE ] || stop post-tree 76
[ "$(git rev-list --parents -n1 HEAD)" = "$H $BASE" ] || stop post-parent 76
[ "$(git log -1 --format=%B HEAD)" = "$MSGSHA_EXPECT_SUBJECT" ] && [ -z "$(git log -1 --format=%b HEAD)" ] || stop post-message 76
[ "$(git log -1 --format='%an <%ae>|%cn <%ce>' HEAD)" = "$ID|$ID" ] || stop post-identity 76
[ "$(git rev-parse HEAD:$PROD)" = $PRODBLOB ] || stop post-product-blob 76
[ -z "$(git status --porcelain --untracked-files=no)" ] || stop post-tracked-dirty 76
say "stage4 post-commit verification OK"

# ---- stage 5: gates, original order, first nonzero stop ----
gate(){ n=$1; bound=$2; shift 2; f="$O/07-gate$n.txt"
  { echo "=== GATE $n (bound ${bound}s, kill grace ${KILLGRACE}s) $(ts) ==="; echo "HEAD: $(git rev-parse HEAD)"; echo "cmd: $*"; } > "$f"
  t0=$(date +%s); timeout -k $KILLGRACE "$bound" "$@" >> "$f" 2>&1; grc=$?; t1=$(date +%s)
  echo "--- exit code: $grc duration_s=$((t1-t0)) ---" >> "$f"; survivors; say "gate$n rc=$grc"; return $grc; }
# portable exports of the actual committed head (produced on pass or gate failure; commit stays unamended)
bundle_out(){ { echo "=== 08 portable exports $(ts) ==="
  git bundle create "$O/j3-r5-committed-$(git rev-parse --short=7 HEAD).bundle" refs/heads/ux03-j3-source-selection; echo "bundle rc=$?"
  git bundle verify "$O"/j3-r5-committed-*.bundle
  git format-patch -1 --stdout HEAD > "$O/j3-r5-committed.patch"; echo "format-patch rc=$?"
  git diff $BASE HEAD > "$O/j3-r4-to-r5-committed.diff"
  echo "committed diff sha256=$(sha "$O/j3-r4-to-r5-committed.diff") expected=$PATCHSHA"
  sha256sum "$O"/j3-r5-committed-*.bundle "$O/j3-r5-committed.patch"; } > "$O/08-exports.txt" 2>&1; }

gate 1 180 ./node_modules/.bin/tsc --noEmit || { r=$grc; bundle_out; stop "gate1-tsc(raw_rc=$r)" 81; }
gate 2 120 ./node_modules/.bin/eslint "$T1" "$T2" || { r=$grc; bundle_out; stop "gate2-eslint(raw_rc=$r)" 82; }
gate 3 180 ./node_modules/.bin/jest "$T1" "$T2" --silent --runInBand || { r=$grc; bundle_out; stop "gate3-jest(raw_rc=$r)" 83; }

# ---- stage 6: exports + final ----
bundle_out
{ echo "=== 09 final $(ts) ==="; echo "HEAD=$(git rev-parse HEAD) tree=$(git rev-parse HEAD^{tree})"; git status --porcelain --untracked-files=no; } > "$O/09-final.txt" 2>&1
survivors
say "ALL STAGES rc 0"
echo "RC=0 STAGE=complete END=$(ts) HEAD=$(git rev-parse HEAD) LOCK=released-on-exit" > "$sent"
exit 0
