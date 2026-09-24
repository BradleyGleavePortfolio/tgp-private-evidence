#!/usr/bin/env bash
# B/drain MINIMUM environment recovery PROPOSAL — NOT RUN. Requires parent disposition first.
# Reproduces exactly the C1-recorded environment route (c1-execution/07-environment-recovery-receipt.txt) for the
# recovered standalone worktree, then refuses unless every recorded pin matches. Under the canonical heavy slot.
# Steps: (1) product `npm ci --ignore-scripts` from the accepted lock 354de3da (integrity-pinned graph);
#        (2) pinned prisma 6.19.3 CLI fetches engines c2990dca (as in C1); (3) `prisma generate` (no generated
#        client is durable anywhere; C1 seal: "node_modules is not archived"); (4) tooling-only Prettier 3.9.6 from
#        the preserved manifests (6c39ea3d…/3e2189ff…) into a uniquely named recovery dir, then the same absolute
#        .bin/prettier link C1 had. Nothing touches tracked files; write-tree must stay 87798e74 before/after.
# NOT here: PG jar/binary/cluster, lefthook install, staging, gates, commit, product lock edits.
set -u
W=/home/user/workspace/worktrees/s7-b-drain
A=/home/user/workspace/execution/cf8ff737/b-drain/env-recovery; L=$A/logs; mkdir -p "$L"
TOOL=/home/user/workspace/execution/cf8ff737/b-drain/tooling/prettier-3.9.6
MAN=/tmp/tgp-private-evidence/2026-09-22/remediation/s3-composition-prep/request-02/tooling/prettier-3.9.6
export GIT_OPTIONAL_LOCKS=0 PRISMA_HIDE_UPDATE_MESSAGE=1 npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false CHECKPOINT_DISABLE=1 CI=1
log=$L/env-recovery.log; sent=$L/env-recovery.sentinel; ts(){ date -u +%FT%TZ; }
say(){ echo "$(ts) $*" >> "$log"; }
stop(){ say "STOP stage=$1 rc=$2"; echo "RC=$2 STAGE=$1 END=$(ts) LOCK=released-on-exit" > "$sent"; exit "$2"; }
exec 9>/home/user/workspace/execution/test-validation.lock
flock -n 9 || { echo "RC=75 STAGE=lock-busy END=$(ts)" > "$sent"; exit 75; }
echo "START $(ts) pid=$$ lock=held(fd9) node=$(node -v) npm=$(npm -v)" > "$log"
cd "$W" || stop cd 74
BASE=a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992; T0=87798e742c7b48f56b05e9b5c30efa877180a9b3

# ---- stage 0: preflight (rc 70) ----
[ "$(git rev-parse HEAD)" = $BASE ] && [ "$(git rev-parse HEAD^{tree})" = $T0 ] || stop pre-head 70
git diff --cached --quiet && git diff --quiet HEAD || stop pre-dirty 70
[ "$(git rev-parse HEAD:package.json)" = 656d11a20c6abee819a0b04e9f04c0b66c0a05ef ] && [ "$(git hash-object package.json)" = 656d11a20c6abee819a0b04e9f04c0b66c0a05ef ] || stop pre-package-json 70
[ "$(git rev-parse HEAD:package-lock.json)" = 354de3dae19449970497da6e4d87f0a1225a8f43 ] && [ "$(git hash-object package-lock.json)" = 354de3dae19449970497da6e4d87f0a1225a8f43 ] || stop pre-package-lock 70
[ "$(node -v)" = v20.20.1 ] && [ "$(npm -v)" = 10.8.2 ] || stop pre-node-npm 70
[ ! -e node_modules ] || stop pre-node_modules-present 70
[ ! -e "$TOOL/node_modules" ] || stop pre-tool-present 70
[ "$(sha256sum "$MAN/package.json" | cut -c1-64)" = 6c39ea3db029c5dda4d663f256419496b494129619a034e60e0f609711a4a774 ] || stop pre-tool-manifest 70
[ "$(sha256sum "$MAN/package-lock.json" | cut -c1-64)" = 3e2189ffec7b867997fd37f28ae77ac0bed5aef745a42e8d5687cc711c5a53b7 ] || stop pre-tool-lock 70
say "PREFLIGHT_OK df_avail_kb=$(df --output=avail "$W" | tail -1 | tr -d ' ')"

# ---- stage 1: product npm ci (identical C1 command) ----
say "NPM_CI start"; timeout -k 30 1500 npm ci --no-audit --no-fund --ignore-scripts --loglevel=error > "$L/01-npm-ci.log" 2>&1; rc=$?; echo "rc=$rc" >> "$L/01-npm-ci.log"; [ $rc = 0 ] || stop npm-ci $rc
[ "$(git write-tree)" = $T0 ] && git diff --quiet HEAD || stop npm-ci-changed-tracked 71
[ "$(sha256sum node_modules/.package-lock.json | cut -c1-64)" = 05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44 ] || stop nm-record-sha 71
for p in "lefthook 2.1.9" "prisma 6.19.3" "@prisma/client 6.19.3" "jest 30.4.2" "typescript 5.9.3" "eslint 10.5.0" "ts-jest 29.4.9"; do set -- $p
  [ "$(node -p "require('./node_modules/$1/package.json').version")" = "$2" ] || stop "nm-pin-$1" 71; done
say "NPM_CI_OK record=05bc530a"

# ---- stage 2: prisma engines via pinned CLI (as C1 did), then generate ----
timeout -k 10 300 ./node_modules/.bin/prisma version > "$L/02-prisma-version.txt" 2>&1; rc=$?; echo "rc=$rc" >> "$L/02-prisma-version.txt"; [ $rc = 0 ] || stop prisma-version $rc
grep -q 'c2990dca591cba766e3b7ef5d9e8a84796e47ab7' "$L/02-prisma-version.txt" || stop engines-hash 72
[ "$(sha256sum node_modules/@prisma/engines/libquery_engine-debian-openssl-3.0.x.so.node | cut -c1-64)" = a2924eab1c78a0a7bb67edac5738939fa10589ef073af5542f53812a22e4a7d8 ] || stop libquery-sha 72
[ "$(sha256sum node_modules/@prisma/engines/schema-engine-debian-openssl-3.0.x | cut -c1-64)" = 5d42b181631fd20bb0ecc5abcdba72575e7f467a0d52f4d5ef1ff28f0c74e6e9 ] || stop schema-engine-sha 72
timeout -k 10 300 ./node_modules/.bin/prisma generate > "$L/02-prisma-generate.log" 2>&1; rc=$?; echo "rc=$rc" >> "$L/02-prisma-generate.log"; [ $rc = 0 ] || stop prisma-generate $rc
[ "$(sha256sum node_modules/.prisma/client/index.d.ts | cut -c1-64)" = bf679a16e50a6f0c39528887b80c2a03c5d0825b816cec3417fcbc94300b72d5 ] || stop client-sha 72
[ "$(git write-tree)" = $T0 ] && git diff --quiet HEAD || stop generate-changed-tracked 72
say "PRISMA_OK client=bf679a16"

# ---- stage 3: tooling Prettier 3.9.6 (manifests only from evidence; one integrity-verified registry read) ----
mkdir -p "$TOOL"; cp "$MAN/package.json" "$MAN/package-lock.json" "$TOOL/"
( cd "$TOOL" && timeout -k 10 300 npm ci --ignore-scripts --no-audit --no-fund --loglevel=error ) > "$L/03-tooling-npm-ci.log" 2>&1; rc=$?; echo "rc=$rc" >> "$L/03-tooling-npm-ci.log"; [ $rc = 0 ] || stop tooling-npm-ci $rc
CLI=$TOOL/node_modules/prettier/bin/prettier.cjs
[ "$(sha256sum "$CLI" | cut -c1-64)" = 6e922134a3c76fd4de202959bb6aef50bde0c994148075003a15569b7197906e ] || stop prettier-cli-sha 73
[ "$(node -p "require('$TOOL/node_modules/prettier/package.json').version")" = 3.9.6 ] || stop prettier-pkg-version 73
[ "$(node "$CLI" --version)" = 3.9.6 ] || stop prettier-version 73
[ ! -e node_modules/.bin/prettier ] || stop product-prettier-bin-exists 73   # product lock has no prettier bin; same as C1
ln -s "$CLI" node_modules/.bin/prettier || stop prettier-link 73
[ "$(readlink -f node_modules/.bin/prettier)" = "$CLI" ] || stop prettier-link-target 73
say "PRETTIER_OK 3.9.6 cli=6e922134 link=$CLI"

# ---- receipt ----
{ echo "utc=$(ts) node=$(node -v) npm=$(npm -v)"; echo "HEAD=$(git rev-parse HEAD) write_tree=$(git write-tree)"; echo "porcelain_tracked='$(git status --porcelain)'"
  echo "nm_entries=$(ls node_modules | wc -l) du=$(du -sh node_modules | cut -f1)"; echo "nm_record_sha=$(sha256sum node_modules/.package-lock.json | cut -c1-64)"; echo "nm_client_sha=$(sha256sum node_modules/.prisma/client/index.d.ts | cut -c1-64)"
  echo "prettier_target=$(readlink -f node_modules/.bin/prettier) sha=$(sha256sum "$CLI" | cut -c1-64) version=$(node "$CLI" --version)"; echo "lefthook=$(./node_modules/.bin/lefthook version 2>&1)"; echo "hooks_non_sample='$(ls .git/hooks | grep -v '\.sample$')'"; } > "$L/04-environment-receipt.txt" 2>&1
say "DONE"; stop done 0
