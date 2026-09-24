#!/usr/bin/env bash
# S7-3' B/drain v5 Phase A (B_V5_MINIMUM_CORRECTION_AND_PHASE_A_GRANT.md). NOT RUN until parent relays J3's released slot.
# Derived from remainder.sh (accepted mechanics) for a TWO-FILE MODIFICATION on top of head 75a2863b: preflight re-asserts
# base head/tree, the exact two new blobs (and nothing else modified/untracked), accepted pins, the already-verified
# environment (no install/copy/generate), existing genuine hooks (verified by hash, NOT reinstalled); stage 2 paths;
# affected gates (tsc whole project, eslint/prettier on the one changed TS file, check-r75 staged, the two DB-free suites);
# ordinary hooked commit with the approved one-line message; verify tree/parent; bundles; FILL v5 binding (not run).
# Single canonical lock holder (flock -n, fd 9). First nonzero stops; no retry; no fix; no amend/rebase/bypass.
set -u
A=/home/user/workspace/execution/cf8ff737/b-drain/v5; L=$A/gates; mkdir -p "$L"; W=/home/user/workspace/worktrees/s7-b-drain
CAN=/home/user/workspace/execution/95633079/s7-b-drain
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 NODE_OPTIONS=--max-old-space-size=4096 PRISMA_HIDE_UPDATE_MESSAGE=1 npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false npm_config_offline=true CHECKPOINT_DISABLE=1 LEFTHOOK_VERBOSE=1 CI=1
log=$L/phase-a-v5.log; sent=$L/phase-a-v5.sentinel; ts(){ date -u +%FT%TZ; }
say(){ echo "$(ts) $*" >> "$log"; }
stop(){ say "STOP stage=$1 rc=$2"; echo "RC=$2 STAGE=$1 END=$(ts) HEAD=$(git -C "$W" rev-parse HEAD 2>/dev/null) LOCK=released-on-exit" > "$sent"; exit "$2"; }
[ -e "$sent" ] && { echo "REFUSED: $sent exists; phase A v5 runs once" >&2; exit 76; }
exec 9>/home/user/workspace/execution/test-validation.lock
flock -n 9 || { echo "RC=75 STAGE=lock-busy END=$(ts)" > "$sent"; exit 75; }
echo "START $(ts) pid=$$ lock=held(fd9) node=$(node -v) npm=$(npm -v)" > "$log"
cd "$W" || stop cd 74
BASE=75a2863bf79a44f84050406d6878ec9a87f4053e; BASE_TREE=f4922ca070e887fb7f613ce955b12621b5c33156; V5=d02f9b124bee52107f8ad2f286f8af611b859fe6
F1=src/scout/scout-ledger-backfill.ts; F2=prisma/migrations/20270119000000_scout_ledger_obsolete_writer_fence/down.sql
P=("$F1" "$F2"); TS1=("$F1")
[ "$(node -v)" = v20.20.1 ] && [ "$(npm -v)" = 10.8.2 ] || stop pre-node 70
[ "$(git rev-parse HEAD)" = $BASE ] || stop pre-HEAD 70
[ "$(git rev-parse HEAD^{tree})" = $BASE_TREE ] || stop pre-base-tree 70
[ "$(git rev-parse HEAD^)" = a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992 ] || stop pre-base-parent 70
git diff --cached --quiet || stop pre-index-dirty 70
[ ! -e .git/MERGE_HEAD ] || stop pre-MERGE_HEAD 70
[ -z "$(git ls-files --others --exclude-standard)" ] || stop pre-untracked-present 70
[ "$(git diff --name-only | sort | tr '\n' ' ')" = "$(printf '%s\n' "${P[@]}" | sort | tr '\n' ' ')" ] || stop pre-modified-set 70
[ "$(git hash-object $F1)" = 11d0a3fed8c1937b579ace267d7d90e71a2b5623 ] || stop pre-blob-F1 70
[ "$(git hash-object $F2)" = 7deaf7009ced136df6c7f06e1989060b15568dfa ] || stop pre-blob-F2 70
[ "$(git rev-parse HEAD:$F1)" = 957fb8c6d830cb6821b6087cda210523166d903d ] && [ "$(git rev-parse HEAD:$F2)" = 91e646dde82a8458d66ff6092b88b6674332ecf8 ] || stop pre-old-blobs 70
[ "$(git diff | grep -c '^[-+][^-+]')" = 4 ] || stop pre-delta-shape 70
git diff | grep -q "^-      AND t.tgattr::int2\[\] = '{}'::int2\[\] AND t.tgnargs = 0 AND t.tgconstraint = 0\`;\$" || stop pre-delta-F1-old 70
git diff | grep -q '^+      AND cardinality(t.tgattr::int2\[\]) = 0 AND t.tgnargs = 0 AND t.tgconstraint = 0`;$' || stop pre-delta-F1-new 70
git diff | grep -q "^-      AND t.tgattr::int2\[\] = '{}'::int2\[\]\$" || stop pre-delta-F2-old 70
git diff | grep -q '^+      AND cardinality(t.tgattr::int2\[\]) = 0$' || stop pre-delta-F2-new 70
git diff > "$L/00-live-delta.patch"; cmp -s "$L/00-live-delta.patch" "$A/prep/v5.delta.patch" || stop pre-delta-frozen 70
for pin in "test/utils/g2-pg17-db.ts 0e73d76d8f06328872d09c6a76db20715547ebe0" "test/utils/g2-pg17-harness.ts ab9aaab4ba3e2c55671f66d5f2ee7a23674337be" "test/utils/g2-pg17-bootstrap.sh 85a636ba75607604032cef7af1d285cb198ca263" "test/scout/g2-pg17-db-guard.spec.ts 4fed8bcd57218b6f1bb174948f1adc6e0e3252ba" "test/utils/g2-pg17-old-root.sh b9080538b4ba4838db89d03d90e2cc206b3860b7" "lefthook.yml 54d037490460fcddf2523ce05801bae9860489ff" "package.json 656d11a20c6abee819a0b04e9f04c0b66c0a05ef" "package-lock.json 354de3dae19449970497da6e4d87f0a1225a8f43" "test/rls-g2-b-drain.spec.ts 9b31fd1813d25a1624ab04666e0b1be4743277ab" "test/utils/g2-b-drain-bootstrap.sh b4503eef525baa531eedb148f47828db3a4ade6f"; do set -- $pin
  [ "$(git rev-parse "HEAD:$1")" = "$2" ] && [ "$(git hash-object "$1")" = "$2" ] || stop "pre-accepted-file-$1" 70; done
[ "$(git config user.name)" = "Bradley Gleave" ] && [ "$(git config user.email)" = bradley@bradleytgpcoaching.com ] || stop pre-identity 70
[ -z "${GIT_AUTHOR_NAME:-}${GIT_COMMITTER_NAME:-}${GIT_AUTHOR_EMAIL:-}${GIT_COMMITTER_EMAIL:-}${LEFTHOOK:-}${SKIP:-}" ] || stop pre-bypass-env 70
[ "$(git config core.hooksPath)" = "" ] || stop pre-hooksPath 70
[ "$(sha256sum "$A/commit-message.txt" | cut -c1-64)" = "$(printf 'fix(importer): recognize empty trigger column vectors\n' | sha256sum | cut -c1-64)" ] || stop pre-message 70
# environment reassert (reuse only; no install/copy/generate)
[ "$(sha256sum node_modules/.package-lock.json | cut -c1-64)" = 05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44 ] || stop env-nm-record 71
[ "$(sha256sum node_modules/.prisma/client/index.d.ts | cut -c1-64)" = bf679a16e50a6f0c39528887b80c2a03c5d0825b816cec3417fcbc94300b72d5 ] || stop env-nm-client 71
PT=$(readlink -f node_modules/.bin/prettier); [ -n "$PT" ] && [ -f "$PT" ] || stop env-prettier-link 71
[ "$(sha256sum "$PT" | cut -c1-64)" = 6e922134a3c76fd4de202959bb6aef50bde0c994148075003a15569b7197906e ] || stop env-prettier-target-sha 71
[ "$(node "$PT" --version)" = 3.9.6 ] || stop env-prettier-version 71
[ "$(./node_modules/.bin/lefthook version 2>/dev/null)" = 2.1.9 ] || stop env-lefthook-version 71
# genuine hooks already installed by the accepted remainder: verify identity, do not reinstall
[ "$(sha256sum .git/hooks/pre-commit | cut -c1-64)" = e5723334a2cfa4b640be875ffa011904c672666ff6ec3765bd40cf1d12080ec0 ] || stop hook-pre-commit-sha 72
[ "$(sha256sum .git/hooks/commit-msg | cut -c1-64)" = 29f83d8eb0681c78fb31e1af8dacf1c079f2926fec8f5981da2221ab4c6d1ba1 ] || stop hook-commit-msg-sha 72
for h in pre-commit commit-msg; do [ -x .git/hooks/$h ] && grep -qi lefthook .git/hooks/$h || stop "hook-$h" 72; done
{ echo "nm_lock_sha=$(sha256sum node_modules/.package-lock.json | cut -c1-64)"; echo "nm_client_sha=$(sha256sum node_modules/.prisma/client/index.d.ts | cut -c1-64)"; echo "prettier_target=$PT sha=$(sha256sum "$PT" | cut -c1-64) version=$(node "$PT" --version)"; echo "lefthook=$(./node_modules/.bin/lefthook version)"; sha256sum .git/hooks/pre-commit .git/hooks/commit-msg; echo "entries=$(ls node_modules | wc -l)"; } > "$L/01-env-reassert.txt"
say "PREFLIGHT_OK env_reasserted hooks_verified df_avail_kb=$(df --output=avail "$W" | tail -1 | tr -d ' ')"
# ---- stage 2: stage exactly the two paths ----
git add -- "${P[@]}" >> "$log" 2>&1 || stop stage-add 73
T=$(git write-tree); echo "$T" > "$L/03-staged-tree.txt"; [ "$T" = $V5 ] || stop stage-tree-mismatch 73
[ "$(git diff --cached --name-only | wc -l)" = 2 ] || stop stage-count 73
git diff --quiet || stop stage-unstaged-left 73
git diff --cached --name-status > "$L/03-staged-name-status.txt"
say "STAGED_OK tree=$T"
# ---- stage 4: ordered bounded gates ----
gate(){ n=$1; b=$2; shift 2; say "GATE $n start bound=${b}s: $*"; timeout -k 10 "$b" "$@" > "$L/04-$n.log" 2>&1; rc=$?; echo "rc=$rc" >> "$L/04-$n.log"; say "GATE $n rc=$rc"; [ $rc = 0 ] || stop "gate-$n" $rc; }
gate tsc 300 ./node_modules/.bin/tsc --noEmit -p tsconfig.json
gate eslint 180 ./node_modules/.bin/eslint --no-warn-ignored --max-warnings 0 "${TS1[@]}"
gate prettier 120 ./node_modules/.bin/prettier --check "${TS1[@]}"
gate check-r75 60 node scripts/check-r75.js --mode=staged
gate jest 300 ./node_modules/.bin/jest src/scout/scout-ledger-backfill.spec.ts test/scout/g2-b-drain-db-guard.spec.ts --runInBand
say "GATES_OK"
# ---- stage 5: ordinary hooked commit ----
[ "$(git write-tree)" = $V5 ] || stop precommit-tree-drift 73
timeout -k 30 300 git commit -F "$A/commit-message.txt" > "$L/05-commit.stdout" 2> "$L/05-commit.stderr"; rc=$?; echo "rc=$rc" > "$L/05-commit.rc"; [ $rc = 0 ] || stop commit $rc
H=$(git rev-parse HEAD)
[ "$(git rev-parse HEAD^{tree})" = $V5 ] || stop verify-tree 76
[ "$(git rev-parse HEAD^)" = $BASE ] || stop verify-parent 76
git cat-file -p HEAD > "$L/06-commit-object.txt"; git log -1 --format=%B > "$L/06-commit-message.raw"
[ "$(git log -1 --format=%B | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')" = "fix(importer): recognize empty trigger column vectors" ] || stop verify-message 76
[ "$(git log -1 --format='%an <%ae>|%cn <%ce>')" = "Bradley Gleave <bradley@bradleytgpcoaching.com>|Bradley Gleave <bradley@bradleytgpcoaching.com>" ] || stop verify-identity 76
git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ] || stop verify-clean 76
git ls-tree -r HEAD -- "${P[@]}" > "$L/06-committed-blobs.txt"
[ "$(git rev-parse HEAD:$F1)" = 11d0a3fed8c1937b579ace267d7d90e71a2b5623 ] && [ "$(git rev-parse HEAD:$F2)" = 7deaf7009ced136df6c7f06e1989060b15568dfa ] || stop verify-blobs 76
git update-ref refs/s7/b-drain-v5 HEAD; git update-ref refs/s7/b-drain-v4-failed $BASE
say "COMMIT_OK head=$H"
# ---- stage 6: v5 binding (substitution-only fill + ONE disclosed mechanical RT line; not run) ----
bash "$A/binding/fill-v5-binding.sh" "$H" "$V5" >> "$log" 2>&1 || stop binding $?
say "BINDING_FILLED (not run)"
# ---- stage 7: bundles + patch ----
mkdir -p "$A/bundle"; git bundle create "$A/bundle/s7-b-drain-v5-$H.bundle" $BASE..HEAD >> "$log" 2>&1 || stop bundle 78
git bundle verify "$A/bundle/s7-b-drain-v5-$H.bundle" > "$A/bundle/verify.txt" 2>&1 || stop bundle-verify 78
git bundle create "$A/bundle/s7-b-drain-v4v5-from-a0ea1bea-$H.bundle" a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992..HEAD refs/s7/b-drain-v4-failed >> "$log" 2>&1 || stop bundle-v4v5 78
git bundle verify "$A/bundle/s7-b-drain-v4v5-from-a0ea1bea-$H.bundle" >> "$A/bundle/verify.txt" 2>&1 || stop bundle-v4v5-verify 78
if git bundle create "$A/bundle/s7-b-drain-full-history-$H.bundle" --all HEAD >> "$log" 2>&1 && git bundle verify "$A/bundle/s7-b-drain-full-history-$H.bundle" >> "$A/bundle/verify.txt" 2>&1; then say "FULL_HISTORY_BUNDLE ok (to shallow graft c23b9d9f)"; else say "FULL_HISTORY_BUNDLE not feasible from shallow graph (C, recorded; range bundles preserve both commits)"; rm -f "$A/bundle/s7-b-drain-full-history-$H.bundle"; fi
git format-patch -1 --stdout HEAD > "$A/bundle/s7-b-drain-v5-$H.patch" || stop patch 78
( cd "$A/bundle" && sha256sum * > BUNDLE.sha256 )
say "DONE head=$H tree=$V5 parent=$BASE"
stop done 0
