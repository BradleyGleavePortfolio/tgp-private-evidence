#!/usr/bin/env bash
# EXEC-1910A060 RT-NEW-1 current runtime setup (SCOPE.md "Fresh runtime inspection and ownership" + heavy sequence step 1).
# Tooling + S8-F standalone clone + dependency install ONLY. Derived from the accepted recipe
# execution/64e33dc7/runtime/rt-setup.sh (f6801d30...; same PG 17.6 pins / refusal codes) and
# execution/64e33dc7/runtime/formatter/fmt-tool.sh (4f92c381...; same prettier@3.9.9 registry pins), with these deltas:
#   - fresh namespace: writable root $ROOT=execution/1910a060/runtime (pg17/dist, tools/, npm-cache/, xdg-cache/);
#     nothing under execution/64e33dc7/** (absent in this host) is adopted or recreated
#   - canonical lock: the EXISTING file execution/test-validation.lock established by the parent (LOCK_ESTABLISHED.txt,
#     inode 667698) is opened, its inode verified, and `flock -n` taken on fd 9 for the whole run; it is never created,
#     deleted, or replaced by this script (absent/wrong inode => refuse)
#   - S8-F source: STANDALONE clone worktrees/1910a060-s8f (own .git, own hooks/index/config; NOT `git worktree add` on the
#     shared --no-checkout blob:none clone). Base commit 1c10e2a1 objects are fetched read-only from origin (the shared
#     clone holds no blobs); the exact S8-F candidate e1ec2fec comes ONLY from the verified checkpoint bundle
#     s8f-e1ec2fec.bundle (sha256 a69b4fc8...). No rebuild, no cherry-pick, no commit, no push. Push URL disabled.
#   - genuine `npm ci` in the S8-F clone (prepare=lefthook install into the clone's own .git/hooks; postinstall=prisma
#     generate; NO --ignore-scripts), then the CI step `npx prisma generate`, against the UNCHANGED lock b7fed5ed and the
#     landed S7-L schema 0eb41f9a (expected generated client 9042e713, the S8-F v1 binding pin)
#   - pinned prettier@3.9.9 isolated npm-global-layout prefix under $ROOT/tools (backend lefthook pre-commit runs
#     `npx prettier --check`; the lock contains no prettier)
# NOT performed: initdb, PG server start, cluster, database, migration, bootstrap, jest, tsc, eslint, lint, any proof.
# Usage: timeout -k 30 3600 bash rt-setup-1910a060.sh   (PG 17.6 server distribution: separate lock-free pg17-fetch-1910a060.sh)
set -uo pipefail
EVD=/home/user/workspace/tgp-private-evidence/execution/1910a060/runtime; R=$EVD/raw
LOG=$R/rt-setup.log; SENT=$R/rt-setup.sentinel
ROOT=/home/user/workspace/execution/1910a060/runtime
LOCK=/home/user/workspace/execution/test-validation.lock; LOCK_INODE=667698
SHARED=/home/user/workspace/growth-project-backend
ORIGIN_URL=https://github.com/BradleyGleavePortfolio/growth-project-backend.git
BUNDLE=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8f/checkpoints/v1/s8f-e1ec2fec.bundle
BUNDLE_SHA=a69b4fc837506cf868135894d2b6f497455de8d787ae8f2e78ea9eab4364c467
BUNDLE_REF=refs/heads/exec-dace/s8f
W=/home/user/workspace/worktrees/1910a060-s8f; BRANCH=exec1910/s8f
GIT_NAME='Bradley Gleave'; GIT_EMAIL=bradley@bradleytgpcoaching.com
BASE_HEAD=1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47; BASE_TREE=aa160557577f821b6f284435d22037e046991202
EXPECT_HEAD=e1ec2fecb71f315b6721d426ba0dacb84f304498; EXPECT_TREE=2fe0201ff132dfdc53ea82b3f26ed0fc8d1c65d6
EXPECT_PKG_LOCK=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55   # package-lock.json (unchanged since 93389265)
EXPECT_SCHEMA=0eb41f9a88ef3b77266e908a5ea814206c188d1bdb031bd96d746491fee84015     # prisma/schema.prisma @1c10e2a1 (S7-L landed)
REC_NM_LOCK=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44        # node_modules/.package-lock.json (prior record; compare only)
REC_CLIENT=9042e713ba5678c99959a345b7b18a60dfc186b2c7d890b8d9c3ed5c8f4edcc6         # .prisma/client/index.d.ts (S7-L schema; v1 binding pin; compare only)
REC_CLIENT_SCHEMA=b84392033ab86776533007505c31f57930307a210844067a7407ed20d25abf3e  # .prisma/client/schema.prisma (v1 binding pin; compare only)
EXPECT_MIGRATIONS=172
PG17_HOME=$ROOT/pg17
ART=embedded-postgres-binaries-linux-amd64-17.6.0.jar
BASE=https://repo1.maven.org/maven2/io/zonky/test/postgres/embedded-postgres-binaries-linux-amd64/17.6.0
PINNED_SHA1=8163322358dbe4e6c2abccc90f2e543f8cfc65db
S1_JAR_SHA256=23da5a044b4fb7a5a081a45008c95749c873305328d73f86aefd56922ce1d29d
S1_TXZ_SHA256=26fa633461a3340913015503d0783d73a28384110257e2f17d9936bdf8b067c0
S1_POSTGRES_SHA256=23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a
S1_INITDB_SHA256=b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a
REC_PGCTL_SHA256=af53d826845af4679a0aaba2bda319f5e527f3b94f3794c67fa174049c9b9401
REC_PSQL_SHA256=a200e38c89b111d3abdf26927b186fdd423bef3d84f157af0f4b65db6f8e6c94
PVER=3.9.9; PFX=$ROOT/tools/prettier-$PVER; PDL=$ROOT/tools/download/prettier-$PVER; PCACHE=$ROOT/tools/npm-cache-prettier-$PVER
P_TARBALL=https://registry.npmjs.org/prettier/-/prettier-3.9.9.tgz
P_INTEGRITY='sha512-Z/CJHIkdujO/OtN7nXUii0Rf3VT5SRuhjBA82Xvu2XhBUgX3nhP67T0LHceBdQLex7OOFGTox+Q5Yg8Jk2Qivg=='
P_SHASUM=09b826918c91cd4cbc80e0cbd1d2a922ff04f233
P_TGZ_SHA256=c3b162d30c45126873cc6338a539383e92120a390d10de78f373f42c2045b338
REC_LAUNCHER=6e922134a3c76fd4de202959bb6aef50bde0c994148075003a15569b7197906e
export GIT_NO_LAZY_FETCH=1 GIT_OPTIONAL_LOCKS=0
mkdir -p "$R"
[ -e "$SENT" ] && { echo "REFUSED: $SENT exists; setup ran already (inspect receipts, do not loop)" >&2; exit 76; }
ts(){ date -u +%FT%TZ; }; log(){ echo "$*" | tee -a "$LOG"; }; sha(){ sha256sum "$1" | cut -c1-64; }
# live-process filter: process NAME (comm) of the heavy binaries, or an actual script execution of a proof/gate driver as
# first argument. Deliberately not a substring match over full argv: other lanes' read-only shell commands mention
# "postgres"/"pg_ctl"/"s9a-gate" in their argv (attempt 1 at 21:17:05Z refused on exactly that false positive).
procs(){ ps -eo pid,comm,args --no-headers | awk '{a=$3; for(i=4;i<=NF;i++) a=a" "$i} $2 ~ /^(postgres|postmaster|pg_ctl|initdb|jest|tsc|npm|npx|prisma|lefthook|prettier)$/ || a ~ /^(\/usr\/bin\/|\/bin\/)?(timeout( --foreground)?( -k [0-9]+)? [0-9]+ )?(bash|sh) [^ ]*\/(s8f-pg-proof|s9a-gate[^ \/]*|rt-setup[^ \/]*)\.sh/' | grep -v -e awk -e rt-setup-1910a060 -e 'ps -eo' || true; }
nmsig(){ find /home/user/node_modules -maxdepth 2 -printf '%p %s %T@\n' 2>/dev/null | sort | sha256sum | cut -c1-64; }
STAGE=preflight
log "PRE $(ts) host=$(hostname) lock_file=$([ -e "$LOCK" ] && echo present || echo absent) ports=$(ss -ltn | awk 'NR>1{print $4}' | tr '\n' ' ')"
P=$(procs); log "PRE relevant_processes=[${P:-none}] lslocks=[$(lslocks -n -o PID,TYPE,MODE,PATH 2>/dev/null | grep test-validation | tr -s ' ' | tr '\n' ';' || true)]"
[ -z "$P" ] || { log "REFUSED: relevant live process present"; echo "RC=74 STAGE=preflight END=$(ts)" >"$SENT"; exit 74; }
ss -ltn | awk 'NR>1{print $4}' | grep -qE ':(55641|55642|55643)$' && { log "REFUSED: proof port listening"; echo "RC=74 STAGE=preflight END=$(ts)" >"$SENT"; exit 74; }
[ -e "$LOCK" ] || { log "REFUSED: canonical lock $LOCK absent; the parent creates it exclusively once; never created here"; exit 75; }
[ "$(stat -c %i "$LOCK")" = "$LOCK_INODE" ] || { log "REFUSED: lock inode $(stat -c %i "$LOCK") != recorded $LOCK_INODE (LOCK_ESTABLISHED.txt); not adopting"; exit 75; }
[ ! -e "$PFX" ] && [ ! -e "$ROOT/npm-cache" ] && [ ! -e "$W/node_modules" ] || { log "REFUSED: install outputs already present ($PFX / npm-cache / node_modules); not deleting"; exit 70; }
exec 9>>"$LOCK"; flock -n 9 || { log "REFUSED: canonical lock busy ($LOCK)"; exit 75; }
finish(){ echo "RC=$1 STAGE=$STAGE END=$(ts) LOCK_INODE=$(stat -c %i "$LOCK")" >"$SENT"; log "END rc=$1 stage=$STAGE $(ts) (fd9 released on exit; lock file left in place, inode $(stat -c %i "$LOCK"))"; exit "$1"; }
log "START $(ts) pid=$$ user=$(id -un) lock=$LOCK held nonblocking fd9 inode=$(stat -c %i "$LOCK") (recorded $LOCK_INODE) holder=[$(lslocks -n -o PID,MODE,PATH 2>/dev/null | grep test-validation | tr -s ' ' | tr '\n' ';' || true)]"
mkdir -p "$ROOT" || finish 70
# ---- toolchain identity (CI ci.yml: actions/setup-node node-version '20'; Dockerfile node:20-slim; no engines/.nvmrc)
STAGE=toolchain
NODE=$(command -v node); NPM=$(command -v npm)
log "node=$NODE real=$(readlink -f "$NODE") version=$(node --version) sha256=$(sha "$(readlink -f "$NODE")")"
log "npm=$NPM real=$(readlink -f "$NPM") version=$(npm --version) npm_cli_js_sha256=$(sha "$(dirname "$(readlink -f "$NPM")")/npm-cli.js" 2>/dev/null || echo n/a)"
node --version | grep -q '^v20\.' || { log "node major != 20 (CI requires '20'); refusing"; finish 70; }
log "git=$(git --version) openssl=$(openssl version 2>/dev/null) os=$(. /etc/os-release; echo "$PRETTY_NAME") kernel=$(uname -r) cpus=$(nproc) mem_gb=$(free -g | awk '/Mem/{print $2}')"
df -h / | tail -1 | tee -a "$LOG"
NM_BEFORE=$(nmsig); log "platform_nm_before entries=$(ls -1 /home/user/node_modules 2>/dev/null | wc -l) sig=$NM_BEFORE"
# ---- S8-F standalone clone at the exact candidate (bundle is the sole source of e1ec2fec)
STAGE=clone
log "bundle=$BUNDLE sha256=$(sha "$BUNDLE") expected=$BUNDLE_SHA"
[ "$(sha "$BUNDLE")" = "$BUNDLE_SHA" ] || { log "bundle sha256 != checkpoint manifest; refusing"; finish 70; }
log "shared_clone: head=$(git -C "$SHARED" rev-parse HEAD) promisor=$(git -C "$SHARED" config --get remote.origin.promisor) filter=$(git -C "$SHARED" config --get remote.origin.partialclonefilter) missing_objects_for_base=$(git -C "$SHARED" rev-list --objects --missing=print "$BASE_HEAD" --max-count=1 | grep -c '^?') (blobs absent => base fetched read-only from origin)"
if [ -e "$W" ]; then
  # attempt 2 (raw/attempt2-partial/rt-setup.log, CLONE_OK 21:18:28Z) created this standalone clone before dying on a
  # variable-name bug in the client stage; it is REUSED only if every candidate check below passes again.
  [ "$(git -C "$W" rev-parse --absolute-git-dir)" = "$W/.git" ] && [ -z "$(git -C "$W" config --get core.worktree || true)" ] || { log "REFUSED: $W is not a standalone clone"; finish 70; }
  log "clone_reused: $W (created by attempt 2) user=$(git -C "$W" config user.name) <$(git -C "$W" config user.email)> core.hooksPath=$(git -C "$W" config --get core.hooksPath || echo unset) pushurl=$(git -C "$W" config --get remote.origin.pushurl) fetch_url=$(git -C "$W" config --get remote.origin.url)"
  [ "$(git -C "$W" config user.name)|$(git -C "$W" config user.email)" = "$GIT_NAME|$GIT_EMAIL" ] || { log "clone identity config wrong"; finish 70; }
  [ ! -e "$W/node_modules" ] || { log "REFUSED: node_modules already present in clone"; finish 70; }
  [ "$(git -C "$W" rev-parse "$BASE_HEAD^{tree}")" = "$BASE_TREE" ] || { log "base tree != $BASE_TREE"; finish 70; }
  git -C "$W" bundle verify "$BUNDLE" >>"$LOG" 2>&1 || { log "bundle verify failed in clone"; finish 70; }
  [ "$(git -C "$W" rev-parse "refs/heads/$BRANCH")" = "$EXPECT_HEAD" ] || { log "branch $BRANCH != $EXPECT_HEAD"; finish 70; }
  [ "$(git -C "$W" rev-parse --abbrev-ref HEAD)" = "$BRANCH" ] || { log "clone not on $BRANCH"; finish 70; }
else
mkdir -p "$(dirname "$W")" && git init -q -b main "$W" >>"$LOG" 2>&1 || finish 70
git -C "$W" config user.name "$GIT_NAME"; git -C "$W" config user.email "$GIT_EMAIL"
git -C "$W" config remote.origin.url "$ORIGIN_URL"; git -C "$W" config remote.origin.fetch '+refs/heads/main:refs/remotes/origin/main'
git -C "$W" config remote.origin.tagopt --no-tags; git -C "$W" config remote.origin.pushurl 'no_push://disabled-by-RT-NEW-1'
log "clone_init: $W own_git_dir=$(git -C "$W" rev-parse --absolute-git-dir) user=$(git -C "$W" config user.name) <$(git -C "$W" config user.email)> core.hooksPath=$(git -C "$W" config --get core.hooksPath || echo unset) pushurl=$(git -C "$W" config --get remote.origin.pushurl)"
timeout --foreground 900 git -C "$W" fetch --no-tags origin "$BASE_HEAD" >"$R/git-fetch-base.out" 2>&1; rc=$?; log "fetch_base_exit=$rc utc=$(ts) (raw/git-fetch-base.out)"; [ $rc = 0 ] || finish $rc
[ "$(git -C "$W" rev-parse "$BASE_HEAD^{commit}" 2>/dev/null)" = "$BASE_HEAD" ] || { log "base commit absent after fetch"; finish 70; }
[ "$(git -C "$W" rev-parse "$BASE_HEAD^{tree}")" = "$BASE_TREE" ] || { log "base tree != $BASE_TREE"; finish 70; }
git -C "$W" update-ref refs/heads/main "$BASE_HEAD" || finish 70
git -C "$W" bundle verify "$BUNDLE" >>"$LOG" 2>&1 || { log "bundle verify failed in clone"; finish 70; }
timeout --foreground 120 git -C "$W" fetch --no-tags "$BUNDLE" "+$BUNDLE_REF:refs/heads/$BRANCH" >>"$LOG" 2>&1; rc=$?; log "fetch_bundle_exit=$rc"; [ $rc = 0 ] || finish $rc
[ "$(git -C "$W" rev-parse "refs/heads/$BRANCH")" = "$EXPECT_HEAD" ] || { log "branch $BRANCH != $EXPECT_HEAD"; finish 70; }
git -C "$W" checkout -q "$BRANCH" >>"$LOG" 2>&1 || finish 70
fi
H=$(git -C "$W" rev-parse HEAD); T=$(git -C "$W" rev-parse 'HEAD^{tree}'); log "head=$H tree=$T branch=$(git -C "$W" rev-parse --abbrev-ref HEAD)"
[ "$H" = "$EXPECT_HEAD" ] && [ "$T" = "$EXPECT_TREE" ] || { log "head/tree mismatch; refusing"; finish 70; }
[ "$(git -C "$W" rev-parse HEAD^)" = "$BASE_HEAD" ] || { log "head is not exactly one commit on base"; finish 70; }
log "head_identity: $(git -C "$W" log -1 --format='author=%an <%ae> %aI committer=%cn <%ce> %cI subject=%s' HEAD)"
[ "$(git -C "$W" log -1 --format='%an <%ae>|%cn <%ce>' HEAD)" = "$GIT_NAME <$GIT_EMAIL>|$GIT_NAME <$GIT_EMAIL>" ] || { log "head identity != operator identity"; finish 70; }
N=$(git -C "$W" diff --name-only "$BASE_HEAD" HEAD | wc -l); log "base..head_changed_paths=$N (expected 17)"; [ "$N" = 17 ] || finish 70
git -C "$W" diff --name-only "$BASE_HEAD" HEAD | tee -a "$LOG" >"$R/changed-paths.txt"
[ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] || { log "clone dirty after checkout; refusing"; finish 70; }
for pin in "test/rls-g2-s8f.spec.ts 77785ec5fa3d0bb15731ba7787c4ede4968eb51d" "test/utils/g2-s8f-bootstrap.sh 5ac2753bdc0498899d1a9eef297ef4acc467ccb8" \
           "test/utils/g2-s8f-db.ts aeff4cb0f06d0d65b969bf7742c1d8cf377f4c79" "test/utils/g2-s8f-pg-harness.ts a8acd231d10194d4552546339a7a4309c86fb8d4" \
           "test/utils/g2-tq0-worker.cjs aa35e7e2c38f8d1a990a4eac466824963ae866f4" "prisma/schema.prisma 2e328bbcab0c902c6adb55dfb5ee172defc5f698" \
           "jest.rls.config.js 44c9691533be2ea27f9a416271d9ff400f7faa3f" "scripts/ci/supabase-shim.sql 0f99f9249959acd6d3b3990808c85228b1a8a87b" \
           "src/scout/reconstruct/native dfd8ef66fd0ebe1fab0380de9e6b378bb16b39c2"; do set -- $pin
  [ "$(git -C "$W" rev-parse "HEAD:$1")" = "$2" ] || { log "blob pin mismatch $1"; finish 70; }; done
[ "$(git -C "$W" ls-files -s test/utils/g2-s8f-bootstrap.sh | cut -c1-6)" = 100755 ] && [ -x "$W/test/utils/g2-s8f-bootstrap.sh" ] || { log "bootstrap mode != 100755"; finish 70; }
log "blob_pins_ok (v1 PINS.txt: spec/bootstrap/db/harness/worker + accepted schema/jest.rls/shim/native)"
log "package_lock_sha256=$(sha "$W/package-lock.json") expected=$EXPECT_PKG_LOCK package_json_sha256=$(sha "$W/package.json") schema_sha256=$(sha "$W/prisma/schema.prisma") expected=$EXPECT_SCHEMA migrations=$(find "$W/prisma/migrations" -mindepth 1 -maxdepth 1 -type d | wc -l)"
[ "$(sha "$W/package-lock.json")" = "$EXPECT_PKG_LOCK" ] || { log "package-lock sha mismatch; refusing"; finish 70; }
[ "$(sha "$W/prisma/schema.prisma")" = "$EXPECT_SCHEMA" ] || { log "schema sha mismatch; refusing"; finish 70; }
[ "$(find "$W/prisma/migrations" -mindepth 1 -maxdepth 1 -type d | wc -l)" = "$EXPECT_MIGRATIONS" ] || { log "migrations != $EXPECT_MIGRATIONS"; finish 70; }
HOOKS=$(git -C "$W" rev-parse --path-format=absolute --git-path hooks); log "hooks_dir=$HOOKS before=[$(ls "$HOOKS" 2>/dev/null | tr '\n' ' ')]"
case "$HOOKS" in "$W"/.git/*) ;; *) log "hooks dir not inside the standalone clone; refusing"; finish 70;; esac
log "CLONE_OK $(ts) git_dir_du=$(du -sh "$W/.git" | cut -f1)"
# ---- psql client (recorded apt route; major 17-19; recorded 18.6-0ubuntu0.26.04.1)
STAGE=client
if command -v psql >/dev/null && psql --version | grep -qE ' (1[7-9])\.'; then log "CLIENT already present: $(psql --version)"
else
  timeout --foreground 600 sudo -n apt-get update -qq >>"$LOG" 2>&1; rc=$?; log "apt_update_exit=$rc"; [ $rc = 0 ] || finish $rc
  if apt-cache show postgresql-client-18 >/dev/null 2>&1; then PKG=postgresql-client-18
  elif apt-cache show postgresql-client-17 >/dev/null 2>&1; then PKG=postgresql-client-17; else PKG=postgresql-client; fi
  log "package=$PKG candidate=$(apt-cache policy "$PKG" | awk '/Candidate/{print $2}')"
  DEBIAN_FRONTEND=noninteractive timeout --foreground 900 sudo -n apt-get install -y -qq --no-install-recommends "$PKG" >>"$LOG" 2>&1; rc=$?; log "apt_install_exit=$rc"; [ $rc = 0 ] || finish $rc
  psql --version | grep -qE ' (1[7-9])\.' || { log "client major < 17; refusing"; finish 70; }
  log "dpkg=$(dpkg-query -W -f='${Package} ${Version} ${Status}\n' "$PKG")"
fi
[ -x /usr/bin/psql ] || { log "CLIENT_FAIL /usr/bin/psql absent"; finish 70; }
PSQL_SHA=$(sha "$(readlink -f /usr/bin/psql)")
log "CLIENT_OK psql=/usr/bin/psql real=$(readlink -f /usr/bin/psql) version='$(/usr/bin/psql --version)' wrapper_sha256=$PSQL_SHA recorded_wrapper=$REC_PSQL_SHA256 match=$([ "$PSQL_SHA" = "$REC_PSQL_SHA256" ] && echo yes || echo NO) pg_dump='$(pg_dump --version 2>/dev/null)'"
# CB1 (REVIEW_B 2.3): pin the REAL version-specific psql binary, not the pg_wrapper dispatcher; assert major
PSQL_REAL=$(ls /usr/lib/postgresql/*/bin/psql 2>/dev/null | sort -V | tail -1); [ -x "$PSQL_REAL" ] || { log "CLIENT_FAIL real psql binary absent under /usr/lib/postgresql"; finish 70; }
PSQL_REAL_VER=$("$PSQL_REAL" --version); echo "$PSQL_REAL_VER" | grep -qE '\(PostgreSQL\) 1[7-9]\.' || { log "CLIENT_FAIL real psql major < 17: $PSQL_REAL_VER"; finish 70; }
log "CLIENT_REAL psql_real=$PSQL_REAL version='$PSQL_REAL_VER' sha256=$(sha "$PSQL_REAL") (v2 binding pins this binary; wrapper hash kept for comparison only)"
# ---- PG 17.6 server distribution: moved to pg17-fetch-1910a060.sh (needs no heavy slot; runs after lock release per parent 14:19 PT)
# ---- genuine npm ci in the S8-F clone (lifecycle scripts run: postinstall prisma generate, prepare lefthook install)
STAGE=npm_ci
export npm_config_cache=$ROOT/npm-cache XDG_CACHE_HOME=$ROOT/xdg-cache npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false PRISMA_HIDE_UPDATE_MESSAGE=1 CHECKPOINT_DISABLE=1
mkdir -p "$npm_config_cache" "$XDG_CACHE_HOME"
cd "$W" || finish 70
[ ! -e node_modules ] || { log "node_modules already present; refusing"; finish 70; }
timeout --foreground 1500 npm ci --no-audit --no-fund --foreground-scripts >"$R/npm-ci.out" 2>&1; rc=$?
log "npm_ci_exit=$rc utc=$(ts) (full output raw/npm-ci.out, sha256 $(sha "$R/npm-ci.out"))"; tail -25 "$R/npm-ci.out" >>"$LOG"; [ $rc = 0 ] || finish $rc
NM_LOCK=$(sha node_modules/.package-lock.json); log "nm_hidden_lock_sha256=$NM_LOCK prior_record=$REC_NM_LOCK match=$([ "$NM_LOCK" = "$REC_NM_LOCK" ] && echo yes || echo NO)"
C1=$( [ -f node_modules/.prisma/client/index.d.ts ] && sha node_modules/.prisma/client/index.d.ts || echo absent); log "client_index_d_ts_after_postinstall=$C1"
log "hooks_after_npm_ci=[$(ls "$HOOKS" | tr '\n' ' ')]"
[ -L node_modules ] && { log "node_modules is a symlink; refusing"; finish 70; }
# ---- CI step: npx prisma generate (ci.yml: npm ci -> npx prisma generate)
STAGE=prisma_generate
log "prisma_version=$(npx --no-install prisma --version 2>&1 | tr '\n' ' ' | tr -s ' ')"
timeout --foreground 600 npx --no-install prisma generate >"$R/prisma-generate.out" 2>&1; rc=$?
cat "$R/prisma-generate.out" >>"$LOG"; log "prisma_generate_exit=$rc utc=$(ts)"; [ $rc = 0 ] || finish $rc
C2=$(sha node_modules/.prisma/client/index.d.ts); log "client_index_d_ts=$C2 equal_to_postinstall=$([ "$C1" = "$C2" ] && echo yes || echo NO) v1_binding_pin=$REC_CLIENT match=$([ "$C2" = "$REC_CLIENT" ] && echo yes || echo NO)"
[ "$C1" = "$C2" ] || { log "generated client not deterministic across postinstall/CI generate; refusing"; finish 70; }
for f in index.js schema.prisma package.json; do [ -f node_modules/.prisma/client/$f ] && log "client_$f sha256=$(sha node_modules/.prisma/client/$f)"; done
log "client_schema_vs_v1_pin=$([ "$(sha node_modules/.prisma/client/schema.prisma)" = "$REC_CLIENT_SCHEMA" ] && echo match || echo DIFFERS) ($REC_CLIENT_SCHEMA)"
ENG=$(ls node_modules/.prisma/client/libquery_engine-*.so.node 2>/dev/null | head -1); [ -n "$ENG" ] && log "client_engine=$(basename "$ENG") sha256=$(sha "$ENG")"
log "hidden_lock_after_generate=$(sha node_modules/.package-lock.json)"
# ---- prettier@3.9.9 isolated tool prefix (fmt-tool.sh recipe; needed by lefthook pre-commit `npx prettier --check`)
STAGE=prettier_tool
[ -e "$PFX" ] && { log "REFUSED: $PFX exists"; finish 70; }
mkdir -p "$PDL" "$PCACHE" || finish 70
( export npm_config_cache=$PCACHE
  timeout --foreground 60 curl -fsS -H 'Accept: application/json' -o "$R/registry-prettier-3.9.9.json" "https://registry.npmjs.org/prettier/$PVER"; rc=$?
  log "curl_metadata_exit=$rc sha256=$([ -f "$R/registry-prettier-3.9.9.json" ] && sha "$R/registry-prettier-3.9.9.json")"; [ $rc = 0 ] || exit $rc
  M=$(node -e 'const d=require(process.argv[1]);console.log([d.name,d.version,d.dist.tarball,d.dist.integrity,d.dist.shasum,Object.keys(d.dependencies||{}).length,JSON.stringify((d.scripts||{}))].join("\t"))' "$R/registry-prettier-3.9.9.json") || exit 70
  IFS=$'\t' read -r M_NAME M_VER M_TAR M_INT M_SHA1 M_DEPS M_SCRIPTS <<<"$M"
  log "meta name=$M_NAME version=$M_VER tarball=$M_TAR integrity=$M_INT shasum=$M_SHA1 dependencies=$M_DEPS scripts=$M_SCRIPTS"
  [ "$M_NAME" = prettier ] && [ "$M_VER" = "$PVER" ] && [ "$M_TAR" = "$P_TARBALL" ] && [ "$M_INT" = "$P_INTEGRITY" ] && [ "$M_SHA1" = "$P_SHASUM" ] || { log "BLOCKER: registry metadata disagrees with recorded prettier pins"; exit 70; }
  TGZ=$PDL/prettier-$PVER.tgz
  timeout --foreground 120 curl -fsSL -o "$TGZ" "$M_TAR"; rc=$?; log "curl_tarball_exit=$rc bytes=$(stat -c %s "$TGZ" 2>/dev/null)"; [ $rc = 0 ] || exit $rc
  GOT_INT="sha512-$(openssl dgst -sha512 -binary "$TGZ" | base64 -w0)"; GOT_SHA1=$(sha1sum "$TGZ" | cut -c1-40); GOT_256=$(sha "$TGZ")
  log "tarball_integrity_match=$([ "$GOT_INT" = "$P_INTEGRITY" ] && echo yes || echo NO) sha1_match=$([ "$GOT_SHA1" = "$P_SHASUM" ] && echo yes || echo NO) sha256=$GOT_256 recorded_match=$([ "$GOT_256" = "$P_TGZ_SHA256" ] && echo yes || echo NO)"
  [ "$GOT_INT" = "$P_INTEGRITY" ] && [ "$GOT_SHA1" = "$P_SHASUM" ] && [ "$GOT_256" = "$P_TGZ_SHA256" ] || { log "BLOCKER: tarball hashes disagree"; exit 70; }
  mkdir -p "$PDL/extract" && tar -xzf "$TGZ" -C "$PDL/extract" || exit 70
  cd "$ROOT/tools" || exit 70
  timeout --foreground 300 npm install --global --prefix "$PFX" --offline --no-audit --no-fund --foreground-scripts "$TGZ" >"$R/npm-install-prettier.out" 2>&1; rc=$?
  cat "$R/npm-install-prettier.out" >>"$LOG"; log "npm_install_prettier_exit=$rc"; [ $rc = 0 ] || exit $rc
  PK=$PFX/lib/node_modules/prettier
  [ "$(node -p "require('$PK/package.json').version")" = "$PVER" ] || { log "BLOCKER: installed version != $PVER"; exit 70; }
  diff -r "$PDL/extract/package" "$PK" >"$R/diff-tarball-vs-installed.txt" 2>&1; rc=$?; log "installed_tree_vs_verified_tarball diff_exit=$rc"; [ $rc = 0 ] || exit 70
  L=$(sha "$PK/bin/prettier.cjs"); log "bin/prettier.cjs sha256=$L recorded=$REC_LAUNCHER match=$([ "$L" = "$REC_LAUNCHER" ] && echo yes || echo NO) bin_link=$(readlink "$PFX/bin/prettier")"
  ( cd "$PFX" && find . -type f -print0 | sort -z | xargs -0 sha256sum ) >"$R/prettier-prefix-files.sha256"
  log "prefix_files=$(wc -l <"$R/prettier-prefix-files.sha256") prefix_manifest_sha256=$(sha "$R/prettier-prefix-files.sha256")"
  V1=$("$PFX/bin/prettier" --version 2>&1); rc=$?; log "direct: $PFX/bin/prettier --version -> '$V1' exit=$rc"; [ $rc = 0 ] && [ "$V1" = "$PVER" ] || exit 70
  cd "$W" || exit 70
  [ ! -e node_modules/.bin/prettier ] || { log "BLOCKER: clone node_modules/.bin/prettier exists (lock should contain no prettier)"; exit 70; }
  V2=$(env npm_config_prefix="$PFX" npm_config_offline=true npx --no-install prettier --version 2>&1); rc=$?
  log "npx-from-clone: (cwd=$W npm_config_prefix=$PFX npm_config_offline=true) npx --no-install prettier --version -> '$V2' exit=$rc"; [ $rc = 0 ] && [ "$V2" = "$PVER" ] || exit 70
); rc=$?; [ $rc = 0 ] || finish $rc
log "PRETTIER_OK prefix=$PFX (usage: export npm_config_prefix=$PFX npm_config_offline=true in the hooked-commit shell; nothing added to package.json/lock/node_modules)"
# ---- hooks + identities + unchanged checks
STAGE=verify
cd "$W" || finish 70
for h in pre-commit commit-msg; do [ -f "$HOOKS/$h" ] && log "hook_$h sha256=$(sha "$HOOKS/$h") mode=$(stat -c %a "$HOOKS/$h") lefthook=$(grep -c lefthook "$HOOKS/$h")" || log "hook_$h ABSENT"; done
log "lefthook_version=$(npx --no-install lefthook version 2>&1 | head -1) lefthook_checksum_file=$( [ -f "$(git rev-parse --git-path info/lefthook.checksum)" ] && cat "$(git rev-parse --git-path info/lefthook.checksum)" || echo absent) core.hooksPath=$(git config --get core.hooksPath || echo unset)"
log "tsc_version=$(node node_modules/typescript/bin/tsc --version) jest_pkg=$(node -p "require('./node_modules/jest/package.json').version") ts_node=$(./node_modules/.bin/ts-node --version 2>/dev/null | head -1) eslint=$(node -p "require('./node_modules/eslint/package.json').version" 2>/dev/null) (versions only; no compile/test/lint)"
log "nm_top_level_entries=$(ls -1 node_modules | wc -l) nm_du=$(du -sh node_modules | cut -f1) nm_realpath_inside_clone=$(case "$(readlink -f node_modules)" in "$W"/*) echo yes;; *) echo NO;; esac)"
NM_AFTER=$(nmsig); log "platform_nm_after entries=$(ls -1 /home/user/node_modules 2>/dev/null | wc -l) sig=$NM_AFTER unchanged=$([ "$NM_BEFORE" = "$NM_AFTER" ] && echo yes || echo NO)"
G=$(git status --porcelain --untracked-files=all); log "clean_after=$([ -z "$G" ] && echo yes || echo "NO [$G]") head_after=$(git rev-parse HEAD) tree_after=$(git rev-parse 'HEAD^{tree}')"
[ "$(git rev-parse HEAD)" = "$EXPECT_HEAD" ] && [ -z "$G" ] || { log "clone changed during setup; refusing"; finish 70; }
log "shared_clone_after: head=$(git -C "$SHARED" rev-parse HEAD) worktrees=[$(git -C "$SHARED" worktree list | tr '\n' ';')] (untouched)"
P=$(procs); log "post_relevant_processes=[${P:-none}] postgres_procs=$(pgrep -cx postgres || true) ports=$(ss -ltn | awk 'NR>1{print $4}' | tr '\n' ' ') pg17_dist=$([ -e "$PG17_HOME/dist" ] && echo present || echo absent-see-pg17-fetch)"
df -h / | tail -1 | tee -a "$LOG"
STAGE=done; finish 0
