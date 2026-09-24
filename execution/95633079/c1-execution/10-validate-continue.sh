#!/usr/bin/env bash
# S7-2 C1 remaining-stage continuation after the frozen launcher's benign hook-path detector stop
# (09-validate.sentinel RC=71 STAGE=hooks-missing, Lefthook install child raw rc=0, hooks genuinely installed).
# Scope: ONLY the unexecuted remainder — original lines 46-47 (skipped post-install guards), stage 2 (ordinary
# hooked commit) and stage 3 (existing targeted Jest), unchanged commands/bounds/status handling/first-failure stop.
# NOT done here: lefthook install (already completed, raw rc 0), hook rewrite, source/env recovery, new tests, retry.
# The frozen launcher a57c224c… is unchanged and is NOT called. Its receipts (logs/09-*, sentinel) are preserved.
# Line 45's third predicate is replaced by an assertion on the ACTUAL installed native Lefthook route; the
# genuine-hook boundary is retained, not removed (executable pre-commit + commit-msg, real callable Lefthook
# 2.1.9 native binary referenced by both hooks, no bypass env, hooksPath unset).
# Launch: setsid nohup bash /home/user/workspace/execution/95633079/c1-execution/10-validate-continue.sh \
#   > /home/user/workspace/execution/e7d2385c/s7-c1-formatted/logs/10-launcher.out 2>&1 &
#   poll /home/user/workspace/execution/e7d2385c/s7-c1-formatted/logs/10-validate-continue.sentinel
set -u
P=/home/user/workspace/execution/e7d2385c/s7-c1-formatted; L=$P/logs; W=/home/user/workspace/worktrees/s7-c1
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 NODE_OPTIONS=--max-old-space-size=4096 PRISMA_HIDE_UPDATE_MESSAGE=1 npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false npm_config_offline=true CHECKPOINT_DISABLE=1 LEFTHOOK_VERBOSE=1 CI=1
mkdir -p "$L"; log=$L/10-validate-continue.log; sent=$L/10-validate-continue.sentinel
cd "$W" || { echo "RC=74 STAGE=cd END=$(date -u +%FT%TZ)" > "$sent"; exit 74; }
echo "START $(date -u +%FT%TZ) pid=$$ NODE_OPTIONS=$NODE_OPTIONS bound=600s/kill30 node=$(node -v) continuation-of=09-validate.sentinel(RC=71,STAGE=hooks-missing)" > "$log"
stop(){ echo "STOP $1 rc=$2 $(date -u +%FT%TZ)" >> "$log"; echo "RC=$2 STAGE=$1 END=$(date -u +%FT%TZ) HEAD=$(git rev-parse HEAD)" > "$sent"; exit "$2"; }

# --- preconditions: unchanged rc70 guard set from the frozen launcher (lines 19-37) ---
[ "$(git rev-parse HEAD)" = 5c760b774598532e90d5d217e15adc9285c3c3f4 ] || stop precondition-HEAD 70
[ "$(cat .git/MERGE_HEAD 2>/dev/null)" = 881c4c791727adef8d423931e1cca83a0ffbb9c9 ] || stop precondition-MERGE_HEAD 70
[ "$(git write-tree)" = 87798e742c7b48f56b05e9b5c30efa877180a9b3 ] || stop precondition-index-tree 70
[ -z "$(git diff --name-only)$(git ls-files --others --exclude-standard)" ] || stop precondition-dirty 70
[ "$(git diff --cached --name-only HEAD | wc -l)" = 18 ] || stop precondition-staged-count 70
[ "$(sha256sum "$P/07-merge-message.r2.txt" | cut -c1-64)" = 288048d7b7e908f8803d3d70e57465f52cfc9f102bb4bc4b1dba30143ce7cb83 ] || stop precondition-message-hash 70
[ "$(sha256sum "$P/MANIFEST.sha256" | cut -c1-64)" = 8ef86a1b24b43c2aafc2bc9279393d54734d0f06ac42da34b0088d338ae7802a ] || stop precondition-manifest-hash 70
( cd "$P" && sha256sum -c --quiet MANIFEST.sha256 ) >> "$log" 2>&1 || stop precondition-manifest-contents 70
[ "$(sha256sum /home/user/workspace/execution/e7d2385c/s7-c1/MANIFEST.sha256 | cut -c1-64)" = 128496e2cf9d2090ddf69df077c58a09473db7db61cafe348728d5af47b94b43 ] || stop precondition-original-packet 70
[ "$(git var GIT_AUTHOR_IDENT | sed 's/ [0-9]* [+-][0-9]*$//')" = "Bradley Gleave <bradley@bradleytgpcoaching.com>" ] || stop precondition-author-identity 70
[ "$(git var GIT_COMMITTER_IDENT | sed 's/ [0-9]* [+-][0-9]*$//')" = "Bradley Gleave <bradley@bradleytgpcoaching.com>" ] || stop precondition-committer-identity 70
[ -z "$(git config core.hooksPath)" ] || stop precondition-hooksPath 70
[ "$(git hash-object lefthook.yml)" = 54d037490460fcddf2523ce05801bae9860489ff ] || stop precondition-lefthook-yml 70
[ "$(git hash-object package.json)" = 656d11a20c6abee819a0b04e9f04c0b66c0a05ef ] || stop precondition-package-json 70
[ "$(git hash-object package-lock.json)" = 354de3dae19449970497da6e4d87f0a1225a8f43 ] || stop precondition-lock 70
[ "$(sha256sum node_modules/.package-lock.json | cut -c1-16)" = 05bc530aa44bfa6d ] || stop precondition-installed-record 70
[ "$(sha256sum node_modules/.prisma/client/index.d.ts | cut -c1-16)" = bf679a16e50a6f0c ] || stop precondition-prisma-client 70
[ "$(sha256sum docs/contracts/importer-openapi.json | cut -c1-64)" = bdb022dd6c4fb64cdf291fdde3796b99e4b23004f676b7cb46a58460526ba4e5 ] || stop precondition-artifact 70
[ -x node_modules/.bin/lefthook ] && [ -x node_modules/.bin/jest ] || stop precondition-bins 70
# frozen launcher and its failed first receipt must still be present and unmodified
[ "$(sha256sum "$P/09-validate-launch.sh" | cut -c1-64)" = a57c224c6e8e9364393318efaa99c33f4a90877287d7e1a7e370b1c75b220448 ] || stop precondition-frozen-launcher 70
grep -q '^RC=71 STAGE=hooks-missing ' "$L/09-validate.sentinel" || stop precondition-prior-receipt 70
echo "PRECONDITIONS_OK $(date -u +%FT%TZ)" >> "$log"

# --- stage 1R: genuine-hook boundary bound to the ACTUAL installed route (no install, no hook rewrite) ---
# replaces frozen line 45's `.bin/lefthook` string predicate only; all other hook requirements retained.
echo "HOOKS_VERIFY_START $(date -u +%FT%TZ)" >> "$log"
[ -x .git/hooks/pre-commit ] && [ -x .git/hooks/commit-msg ] || stop hooks-missing 71
[ "$(sha256sum .git/hooks/pre-commit | cut -c1-64)" = a868b3a9ee25a048ca80c26b875e2b41b829f7d7fe325b2c3b585e3a368aef46 ] || stop hooks-pre-commit-bytes 71
[ "$(sha256sum .git/hooks/commit-msg | cut -c1-64)" = a46fa3984a49a61212e9ed239cde4e0e6642cc89a708c92e766cbd0fc64686f8 ] || stop hooks-commit-msg-bytes 71
grep -q "$W/node_modules/lefthook-linux-x64/bin/lefthook" .git/hooks/pre-commit || stop hooks-native-path-pre-commit 71
grep -q "$W/node_modules/lefthook-linux-x64/bin/lefthook" .git/hooks/commit-msg || stop hooks-native-path-commit-msg 71
grep -q 'call_lefthook run "pre-commit"' .git/hooks/pre-commit || stop hooks-run-pre-commit 71
grep -q 'call_lefthook run "commit-msg"' .git/hooks/commit-msg || stop hooks-run-commit-msg 71
[ -x node_modules/lefthook-linux-x64/bin/lefthook ] || stop hooks-native-binary 71
[ "$(sha256sum node_modules/lefthook-linux-x64/bin/lefthook | cut -c1-64)" = 974486e94169a44b38d60e4d26491ed205416ca16c93621f8f69b52d401c3a79 ] || stop hooks-native-binary-bytes 71
[ "$(timeout -k 30 60 node_modules/lefthook-linux-x64/bin/lefthook version)" = 2.1.9 ] || stop hooks-native-version 71
# no-bypass context: the generated hooks honour LEFTHOOK / LEFTHOOK_BIN and PATH discovery before their native fallback
[ -z "${LEFTHOOK:-}" ] || stop hooks-bypass-LEFTHOOK 71
[ -z "${LEFTHOOK_BIN:-}" ] || stop hooks-bypass-LEFTHOOK_BIN 71
command -v lefthook >/dev/null 2>&1 && stop hooks-path-shadow 71
[ ! -e lefthook-local.yml ] && [ ! -e .lefthook-local.yml ] || stop hooks-local-override 71
# frozen lines 46-47, skipped by the first launch, now executed unchanged
[ -z "$(git config core.hooksPath)" ] || stop hooks-hooksPath 71
[ "$(git write-tree)" = 87798e742c7b48f56b05e9b5c30efa877180a9b3 ] && [ -z "$(git diff --name-only)$(git ls-files --others --exclude-standard)" ] || stop hooks-changed-tree 71
echo "HOOKS_VERIFY_OK $(date -u +%FT%TZ) pre-commit=a868b3a9 commit-msg=a46fa398 native=lefthook-linux-x64 2.1.9" >> "$log"

# --- stage 2: ordinary hooked commit (real pre-commit + commit-msg; no --no-verify) — unchanged from frozen lines 50-61 ---
echo "COMMIT_START $(date -u +%FT%TZ)" >> "$log"
timeout -k 30 600 git commit -F "$P/07-merge-message.r2.txt" >> "$log" 2>&1; rc=$?
echo "COMMIT_END $(date -u +%FT%TZ) rc=$rc HEAD=$(git rev-parse HEAD)" >> "$log"
[ $rc = 0 ] || stop commit "$rc"
H=$(git rev-parse HEAD)
[ "$(git rev-parse 'HEAD^{tree}')" = 87798e742c7b48f56b05e9b5c30efa877180a9b3 ] || stop commit-tree 71
[ "$(git rev-parse HEAD^1)" = 5c760b774598532e90d5d217e15adc9285c3c3f4 ] && [ "$(git rev-parse HEAD^2)" = 881c4c791727adef8d423931e1cca83a0ffbb9c9 ] && [ -z "$(git rev-parse -q --verify HEAD^3 2>/dev/null)" ] || stop commit-parents 71
[ "$(git log -1 --format='%an <%ae>|%cn <%ce>')" = "Bradley Gleave <bradley@bradleytgpcoaching.com>|Bradley Gleave <bradley@bradleytgpcoaching.com>" ] || stop commit-identity 71
[ "$(git log -1 --format=%B | sha256sum | cut -c1-64)" = "$(sha256sum "$P/07-merge-message.r2.txt" | cut -c1-64)" ] || echo "NOTE message-bytes-differ-from-file (git may strip trailing newline); recorded" >> "$log"
git log -1 --format=%B | grep -qiE 'co-authored-by|generated with|signed-off-by' && stop commit-trailer 71
[ ! -e .git/MERGE_HEAD ] && [ -z "$(git status --porcelain --untracked-files=all)" ] || stop commit-state 71
{ echo "COMMIT=$H"; echo "TREE=$(git rev-parse 'HEAD^{tree}')"; echo "PARENTS=$(git rev-parse HEAD^1) $(git rev-parse HEAD^2)"; echo "IDENT=$(git log -1 --format='%an <%ae> | %cn <%ce> | %aI | %cI')"; } > "$P/COMMIT_RESULT.txt"

# --- stage 3: existing targeted Jest only (default config; test/rls-*.spec.ts is ignored by that config) — unchanged from frozen lines 64-70 ---
echo "JEST_START $(date -u +%FT%TZ)" >> "$log"
timeout -k 30 600 ./node_modules/.bin/jest --ci --runInBand test/contracts/importer-contract.spec.ts src/extension-pair/__tests__ > "$L/10-jest.log" 2>&1; rc=$?
echo "JEST_END $(date -u +%FT%TZ) rc=$rc" >> "$log"
grep -E '^(Test Suites|Tests|Snapshots|Time):' "$L/10-jest.log" >> "$log" 2>/dev/null
grep -E '^(PASS|FAIL) ' "$L/10-jest.log" >> "$log" 2>/dev/null
[ "$(git rev-parse HEAD)" = "$H" ] && [ -z "$(git status --porcelain --untracked-files=all)" ] || stop jest-changed-tree 71
[ $rc = 0 ] || stop jest "$rc"
echo "DONE $(date -u +%FT%TZ)" >> "$log"
echo "RC=0 STAGE=done END=$(date -u +%FT%TZ) HEAD=$H" > "$sent"
