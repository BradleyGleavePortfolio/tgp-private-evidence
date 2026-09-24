#!/usr/bin/env bash
# S7-3' B/drain Phase A (dual-granted v4 f4922ca0…): isolated C1 dependency copy → real lefthook install →
# stage exact 11 paths → ordered bounded gates → ordinary hooked commit → verify → filled PG binding COPY (not run).
# Single canonical lock holder for the whole heavy slot (flock -n, fd 9). First nonzero stops; no retry; no fix.
# NOT here: npm ci/install, prisma generate, PG/cluster/O-root/bootstrap/probe, hook edits, bypass env, amend/rebase.
set -u
A=/home/user/workspace/execution/95633079/s7-b-drain/phase-a; L=$A/logs; W=/home/user/workspace/worktrees/s7-b-drain
C1=/home/user/workspace/worktrees/s7-c1; E=/home/user/workspace/execution/95633079/s7-b-drain
export GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1 NODE_OPTIONS=--max-old-space-size=4096 PRISMA_HIDE_UPDATE_MESSAGE=1 npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false npm_config_offline=true CHECKPOINT_DISABLE=1 LEFTHOOK_VERBOSE=1 CI=1
log=$L/phase-a.log; sent=$L/phase-a.sentinel; ts(){ date -u +%FT%TZ; }
say(){ echo "$(ts) $*" >> "$log"; }
stop(){ say "STOP stage=$1 rc=$2"; echo "RC=$2 STAGE=$1 END=$(ts) HEAD=$(git -C "$W" rev-parse HEAD 2>/dev/null) LOCK=released-on-exit" > "$sent"; exit "$2"; }
exec 9>/home/user/workspace/execution/test-validation.lock
flock -n 9 || { echo "RC=75 STAGE=lock-busy END=$(ts)" > "$sent"; exit 75; }
echo "START $(ts) pid=$$ lock=held(fd9) node=$(node -v) npm=$(npm -v)" > "$log"
cd "$W" || stop cd 74
V4=f4922ca070e887fb7f613ce955b12621b5c33156; BASE=a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992
P=(prisma/migrations/20270119000000_scout_ledger_obsolete_writer_fence/migration.sql prisma/migrations/20270119000000_scout_ledger_obsolete_writer_fence/down.sql src/scout/scout-ledger-backfill.ts src/scout/scout-ledger-backfill.cli.ts src/scout/scout-ledger-backfill.spec.ts test/rls-g2-b-drain.spec.ts test/utils/g2-b-drain-harness.ts test/utils/g2-b-drain-db.ts test/utils/g2-b-drain-pg-harness.ts test/utils/g2-b-drain-bootstrap.sh test/scout/g2-b-drain-db-guard.spec.ts)
TS8=(src/scout/scout-ledger-backfill.ts src/scout/scout-ledger-backfill.cli.ts src/scout/scout-ledger-backfill.spec.ts test/rls-g2-b-drain.spec.ts test/utils/g2-b-drain-harness.ts test/utils/g2-b-drain-db.ts test/utils/g2-b-drain-pg-harness.ts test/scout/g2-b-drain-db-guard.spec.ts)

# ---- stage 0: preflight (all rc 70) ----
[ "$(git rev-parse HEAD)" = $BASE ] || stop pre-HEAD 70
[ "$(git rev-parse HEAD^{tree})" = 87798e742c7b48f56b05e9b5c30efa877180a9b3 ] || stop pre-base-tree 70
git diff --cached --quiet || stop pre-index-dirty 70
git diff --quiet HEAD || stop pre-tracked-modified 70
[ ! -e .git/MERGE_HEAD ] || stop pre-MERGE_HEAD 70
[ "$(git ls-files --others --exclude-standard | sort | tr '\n' ' ')" = "$(printf '%s\n' "${P[@]}" | sort | tr '\n' ' ')" ] || stop pre-untracked-set 70
{ for f in "${P[@]}"; do m=$(stat -c %a "$f"); case $m in 755) m=100755;; 644) m=100644;; esac; printf '%s blob %s\t%s\n' "$m" "$(git hash-object "$f")" "$f"; done; } | sort -k4 > "$L/00-live-blobs.txt"
sort -k4 "$E/frozen-v4/BLOBS.git-sha1" | diff - "$L/00-live-blobs.txt" >> "$log" 2>&1 || stop pre-blob-mode-binding 70
( sha256sum -c --quiet "$E/frozen-v4/SOURCE.sha256" ) >> "$log" 2>&1 || stop pre-source-sha 70
for pin in "test/utils/g2-pg17-db.ts 0e73d76d8f06328872d09c6a76db20715547ebe0" "test/utils/g2-pg17-harness.ts ab9aaab4ba3e2c55671f66d5f2ee7a23674337be" "test/utils/g2-pg17-bootstrap.sh 85a636ba75607604032cef7af1d285cb198ca263" "test/scout/g2-pg17-db-guard.spec.ts 4fed8bcd57218b6f1bb174948f1adc6e0e3252ba" "test/utils/g2-pg17-old-root.sh b9080538b4ba4838db89d03d90e2cc206b3860b7" "lefthook.yml 54d037490460fcddf2523ce05801bae9860489ff" "package.json 656d11a20c6abee819a0b04e9f04c0b66c0a05ef" "package-lock.json 354de3dae19449970497da6e4d87f0a1225a8f43"; do set -- $pin
  [ "$(git rev-parse "HEAD:$1")" = "$2" ] && [ "$(git hash-object "$1")" = "$2" ] || stop "pre-accepted-file-$1" 70; done
[ "$(node -v)" = v20.20.1 ] && [ "$(npm -v)" = 10.8.2 ] || stop pre-node-npm 70
for f in package.json package-lock.json prisma/schema.prisma; do cmp -s "$f" "$C1/$f" || stop "pre-parity-$f" 70; done
[ "$(git -C "$C1" rev-parse HEAD)" = $BASE ] || stop pre-c1-head 70
[ ! -e node_modules ] || stop pre-node_modules-present 70
[ -z "$(ls .git/hooks 2>/dev/null | grep -v '\.sample$')" ] || stop pre-hooks-present 70
[ -z "$(git config core.hooksPath)" ] || stop pre-hooksPath 70
[ "$(git var GIT_AUTHOR_IDENT | sed 's/ [0-9]* [+-][0-9]*$//')" = "Bradley Gleave <bradley@bradleytgpcoaching.com>" ] || stop pre-author 70
[ "$(git var GIT_COMMITTER_IDENT | sed 's/ [0-9]* [+-][0-9]*$//')" = "Bradley Gleave <bradley@bradleytgpcoaching.com>" ] || stop pre-committer 70
[ "$(sha256sum "$A/commit-message.txt" | cut -c1-64)" = fca0b6aab065ac2f325126d7cd0f35933d41eba4156cf1172577519393c4d9f6 ] || stop pre-message-hash 70
[ -z "${LEFTHOOK:-}${LEFTHOOK_EXCLUDE:-}" ] || stop pre-bypass-env 70
[ "$(sha256sum "$C1/node_modules/.package-lock.json" | cut -c1-64)" = 05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44 ] || stop pre-c1-nm-record 70
[ "$(sha256sum "$C1/node_modules/.prisma/client/index.d.ts" | cut -c1-64)" = bf679a16e50a6f0c39528887b80c2a03c5d0825b816cec3417fcbc94300b72d5 ] || stop pre-c1-nm-client 70
[ ! -L "$C1/node_modules" ] || stop pre-c1-nm-symlink 70
say "PREFLIGHT_OK df_avail_kb=$(df --output=avail "$W" | tail -1 | tr -d ' ')"

# ---- stage 1: isolated dependency copy (no install) ----
timeout -k 10 900 cp -a --reflink=auto "$C1/node_modules" ./node_modules > "$L/01-cp.log" 2>&1; rc=$?; echo "rc=$rc" >> "$L/01-cp.log"; [ $rc = 0 ] || stop copy-node_modules $rc
[ -d node_modules ] && [ ! -L node_modules ] || stop copy-not-real-dir 71
{ echo "entries=$(ls node_modules | wc -l) c1_entries=$(ls "$C1/node_modules" | wc -l)"
  echo "symlinks_total=$(find node_modules -type l | wc -l) symlinks_outside_tree=$(find node_modules -type l -exec sh -c 'r=$(readlink -f "$1"); case "$r" in "$PWD/node_modules/"*) ;; *) echo "$1 -> $r";; esac' _ {} \; | wc -l)"
  echo "files_with_multiple_links=$(find node_modules -type f -links +1 | wc -l)"
  echo "same_inode_as_source=$(find node_modules -type f -samefile "$C1/node_modules/.package-lock.json" | wc -l)"
  echo "nm_lock_sha=$(sha256sum node_modules/.package-lock.json | cut -c1-64)"; echo "nm_client_sha=$(sha256sum node_modules/.prisma/client/index.d.ts | cut -c1-64)"
  echo "du=$(du -sh node_modules | cut -f1)"; } > "$L/01-copy-verify.txt" 2>&1
grep -q '^symlinks_outside_tree=0$' "$L/01-copy-verify.txt" || stop copy-symlink-outside 71
grep -q '^same_inode_as_source=0$' "$L/01-copy-verify.txt" || stop copy-shared-inode 71
grep -q '^nm_lock_sha=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44$' "$L/01-copy-verify.txt" || stop copy-nm-record 71
grep -q '^nm_client_sha=bf679a16e50a6f0c39528887b80c2a03c5d0825b816cec3417fcbc94300b72d5$' "$L/01-copy-verify.txt" || stop copy-nm-client 71
say "COPY_OK $(tr '\n' ' ' < "$L/01-copy-verify.txt")"

# ---- stage 2: genuine lefthook install (standalone worktree) ----
./node_modules/.bin/lefthook version > "$L/02-lefthook-version.txt" 2>&1
timeout -k 10 120 ./node_modules/.bin/lefthook install > "$L/02-lefthook-install.log" 2>&1; rc=$?; echo "rc=$rc" >> "$L/02-lefthook-install.log"; [ $rc = 0 ] || stop lefthook-install $rc
for h in pre-commit commit-msg; do [ -x .git/hooks/$h ] || stop "hook-missing-$h" 72; grep -qi lefthook .git/hooks/$h || stop "hook-not-lefthook-$h" 72; cp .git/hooks/$h "$L/02-actual-$h.hook"; done
{ sha256sum .git/hooks/pre-commit .git/hooks/commit-msg; ls -la .git/hooks | grep -v '\.sample$'; echo "hooksPath='$(git config core.hooksPath)'"; } > "$L/02-hook-identity.txt" 2>&1
git status --porcelain --untracked-files=all > "$L/02-status-after-install.txt"
[ "$(wc -l < "$L/02-status-after-install.txt")" = 11 ] || stop install-changed-tree 72
say "HOOKS_OK"

# ---- stage 3: stage exact 11 paths, tree must equal v4 ----
git add -- "${P[@]}" >> "$log" 2>&1 || stop stage-add 73
T=$(git write-tree); echo "$T" > "$L/03-staged-tree.txt"; [ "$T" = $V4 ] || stop stage-tree-mismatch 73
[ "$(git diff --cached --name-only | wc -l)" = 11 ] || stop stage-count 73
git diff --cached --name-status > "$L/03-staged-name-status.txt"
say "STAGED_OK tree=$T"

# ---- stage 4: ordered bounded gates ----
gate(){ n=$1; b=$2; shift 2; say "GATE $n start bound=${b}s: $*"; timeout -k 10 "$b" "$@" > "$L/04-$n.log" 2>&1; rc=$?; echo "rc=$rc" >> "$L/04-$n.log"; say "GATE $n rc=$rc"; [ $rc = 0 ] || stop "gate-$n" $rc; }
gate tsc 300 ./node_modules/.bin/tsc --noEmit -p tsconfig.json
gate eslint 180 ./node_modules/.bin/eslint --no-warn-ignored --max-warnings 0 "${TS8[@]}"
gate prettier 120 ./node_modules/.bin/prettier --check "${TS8[@]}"
gate check-r75 60 node scripts/check-r75.js --mode=staged
gate jest 300 ./node_modules/.bin/jest src/scout/scout-ledger-backfill.spec.ts test/scout/g2-b-drain-db-guard.spec.ts --runInBand
say "GATES_OK"

# ---- stage 5: ordinary hooked commit ----
[ "$(git write-tree)" = $V4 ] || stop precommit-tree-drift 73
timeout -k 30 300 git commit -F "$A/commit-message.txt" > "$L/05-commit.stdout" 2> "$L/05-commit.stderr"; rc=$?; echo "rc=$rc" > "$L/05-commit.rc"; [ $rc = 0 ] || stop commit $rc
H=$(git rev-parse HEAD)
[ "$(git rev-parse HEAD^{tree})" = $V4 ] || stop verify-tree 76
[ "$(git rev-parse HEAD^)" = $BASE ] || stop verify-parent 76
[ -z "$(git status --porcelain --untracked-files=all)" ] || stop verify-dirty 76
git cat-file -p HEAD > "$L/06-commit-object.txt"; git log -1 --format=%B > "$L/06-commit-message.raw"
diff <(sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$A/commit-message.txt") <(sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$L/06-commit-message.raw") >> "$log" 2>&1 || stop verify-message 76
git ls-tree -r HEAD -- "${P[@]}" > "$L/06-committed-blobs.txt"
say "COMMIT_OK head=$H"

# ---- stage 6: filled PG binding COPY (substitution only; NOT run) ----
mkdir -p "$E/runtime/binding"; SRC=$E/fixture-proposal-v3/binding/b-pg-proof.sh; DST=$E/runtime/binding/b-pg-proof.sh
sed -e "s/__V3_COMMIT__/$H/" -e "s/__V3_TREE__/$V4/" -e "s/__V3_SPEC_BLOB__/9b31fd1813d25a1624ab04666e0b1be4743277ab/" -e "s/__V3_BOOTSTRAP_BLOB__/b4503eef525baa531eedb148f47828db3a4ade6f/" -e "s/__B_FIXTURE_SHA256__/4525f01d06333918bdb1fca3fd70f4d4e3936ee1cefc01eb5ac6d0ba9d501eb9/" "$SRC" > "$DST"
diff -u "$SRC" "$DST" > "$E/runtime/binding/b-pg-proof.sh.substitution-only.diff"; [ "$(grep -c '^[-+][^-+]' "$E/runtime/binding/b-pg-proof.sh.substitution-only.diff")" = 10 ] || stop binding-diff-shape 77
grep -qE '__V3_|__B_FIXTURE' "$DST" && stop binding-placeholder-left 77
[ "$(git rev-parse HEAD:test/rls-g2-b-drain.spec.ts)" = 9b31fd1813d25a1624ab04666e0b1be4743277ab ] || stop binding-spec-pin 77
[ "$(git rev-parse HEAD:test/utils/g2-b-drain-bootstrap.sh)" = b4503eef525baa531eedb148f47828db3a4ade6f ] || stop binding-bootstrap-pin 77
[ "$(sha256sum "$E/fixture-proposal-v3/binding/b-fixture.sh" | cut -c1-64)" = 4525f01d06333918bdb1fca3fd70f4d4e3936ee1cefc01eb5ac6d0ba9d501eb9 ] || stop binding-fixture-pin 77
bash -n "$DST" || stop binding-syntax 77
{ echo "source_sha=$(sha256sum "$SRC" | cut -c1-64)"; echo "filled_sha=$(sha256sum "$DST" | cut -c1-64)"; echo "HEAD=$H TREE=$V4 SPEC=9b31fd1813d25a1624ab04666e0b1be4743277ab BOOTSTRAP=b4503eef525baa531eedb148f47828db3a4ade6f FIXTURE=4525f01d06333918bdb1fca3fd70f4d4e3936ee1cefc01eb5ac6d0ba9d501eb9"; grep -n '^EXPECT_\|^D=' "$DST"; } > "$E/runtime/binding/PINS.txt"
say "BINDING_FILLED (not run)"

# ---- stage 7: bundle + patch ----
mkdir -p "$A/bundle"; git bundle create "$A/bundle/s7-b-drain-$H.bundle" $BASE..HEAD >> "$log" 2>&1 || stop bundle 78
git bundle verify "$A/bundle/s7-b-drain-$H.bundle" > "$A/bundle/verify.txt" 2>&1 || stop bundle-verify 78
git format-patch -1 --stdout HEAD > "$A/bundle/s7-b-drain-$H.patch" || stop patch 78
( cd "$A/bundle" && sha256sum * > BUNDLE.sha256 )
say "DONE head=$H tree=$V4 parent=$BASE"
stop done 0
