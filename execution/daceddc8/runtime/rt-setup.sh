#!/usr/bin/env bash
# EXEC-64E33DC7 replacement runtime setup (RUNTIME_SETUP_GRANT.md). Tooling + dependency donor ONLY.
# Derived from execution/cf8ff737/b-drain/pg-tooling/b-pg-env-recovery.sh (bce3ce15...; same PG pins/refusals, rc 70)
# and execution/cf8ff737/nq1/env/e3-npm-ci-generate.sh, with these grant-directed deltas:
#   - fresh namespace: server into $ROOT/pg17/dist (not /home/user/pg17); npm/xdg caches under $ROOT
#   - detached env worktree at accepted 93389265 (not a builder worktree)
#   - genuine `npm ci` (prepare=lefthook install, postinstall=prisma generate run for real; NO --ignore-scripts),
#     then the CI step `npx prisma generate` (ci.yml: setup-node '20' -> npm ci -> npx prisma generate)
#   - single canonical nonblocking flock held for the whole run, released on exit. Lock file is never deleted.
# NOT performed: initdb, server start, cluster, database, migration, bootstrap, jest, tsc, lint, any proof.
# Usage: timeout -k 30 2400 bash rt-setup.sh
set -uo pipefail
EVD=/home/user/workspace/tgp-private-evidence/execution/daceddc8/runtime; R=$EVD/raw
LOG=$R/rt-setup.log; SENT=$R/rt-setup.sentinel
ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset
LOCK=/home/user/workspace/execution/test-validation.lock
REPO=/home/user/workspace/growth-project-backend
WT=/home/user/workspace/worktrees/64e33dc7-env
ACCEPTED=93389265a846095b846fa8f1fb0dad782fb6ee9f
EXPECT_TREE=a315dd651b8c54c2e82f2260fcc6058f0d13b64a
EXPECT_PKG_LOCK=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55   # package-lock.json @93389265 (== N/Q1 E3 record)
REC_NM_LOCK=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44      # prior record (compare only)
REC_CLIENT=b6716a865a705ffc0efab30ed88cd163b461e5344ad64e5926a0dff078b49f44       # S8-B PINS NM_CLIENT, schema 77f33bcd (compare only)
REC_SCHEMA=77f33bcdc36802f8e1d52553d011f546f56f757cacb391f23436ab266a148589
PG17_HOME=$ROOT/pg17
ART=embedded-postgres-binaries-linux-amd64-17.6.0.jar
BASE=https://repo1.maven.org/maven2/io/zonky/test/postgres/embedded-postgres-binaries-linux-amd64/17.6.0
PINNED_SHA1=8163322358dbe4e6c2abccc90f2e543f8cfc65db
S1_JAR_SHA256=23da5a044b4fb7a5a081a45008c95749c873305328d73f86aefd56922ce1d29d
S1_TXZ_SHA256=26fa633461a3340913015503d0783d73a28384110257e2f17d9936bdf8b067c0
S1_POSTGRES_SHA256=23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a
S1_INITDB_SHA256=b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a
PGCTL_PREFIX=af53d826845af467
mkdir -p "$R" "$ROOT" "$(dirname "$LOCK")"
[ -e "$SENT" ] && { echo "REFUSED: $SENT exists; setup ran already (inspect receipts, do not loop)" >&2; exit 76; }
ts(){ date -u +%FT%TZ; }; log(){ echo "$*" | tee -a "$LOG"; }; sha(){ sha256sum "$1" | cut -c1-64; }
procs(){ ps -eo pid,comm,args --no-headers | awk '$2 ~ /^(postgres|postmaster|pg_ctl|initdb|jest|tsc|npm|npx|prisma)$/ || $0 ~ /(jest|tsc|prisma|pg_ctl|postgres)/' | grep -v -e awk -e rt-setup -e 'ps -eo' || true; }
STAGE=preflight
log "PRE $(ts) lock_file=$([ -e "$LOCK" ] && echo present || echo absent) ports=$(ss -ltn | awk 'NR>1{print $4}' | tr '\n' ' ')"
P=$(procs); log "PRE relevant_processes=[${P:-none}]"
[ -z "$P" ] || { log "REFUSED: relevant live process present"; echo "RC=74 STAGE=preflight END=$(ts)" >"$SENT"; exit 74; }
ss -ltn | awk 'NR>1{print $4}' | grep -qE ':(55641|55642)$' && { log "REFUSED: proof port listening"; echo "RC=74 STAGE=preflight END=$(ts)" >"$SENT"; exit 74; }
exec 9>>"$LOCK"; flock -n 9 || { log "REFUSED: canonical lock busy ($LOCK)"; exit 75; }
finish(){ echo "RC=$1 STAGE=$STAGE END=$(ts)" >"$SENT"; log "END rc=$1 stage=$STAGE $(ts) (fd9 released on exit)"; exit "$1"; }
log "START $(ts) pid=$$ user=$(id -un) lock=$LOCK(held nonblocking fd9, inode $(stat -c %i "$LOCK"))"
# ---- toolchain identity (CI: actions/setup-node node-version '20'; Dockerfile node:20-slim; no engines/.nvmrc)
STAGE=toolchain
NODE=$(command -v node); NPM=$(command -v npm)
log "node=$NODE real=$(readlink -f "$NODE") version=$(node --version) sha256=$(sha "$(readlink -f "$NODE")")"
log "npm=$NPM real=$(readlink -f "$NPM") version=$(npm --version) npm_cli_js_sha256=$(sha "$(dirname "$(readlink -f "$NPM")")/npm-cli.js" 2>/dev/null || echo n/a)"
node --version | grep -q '^v20\.' || { log "node major != 20 (CI requires '20'); refusing"; finish 70; }
log "git=$(git --version) openssl=$(openssl version 2>/dev/null) os=$(. /etc/os-release; echo "$PRETTY_NAME") kernel=$(uname -r)"
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
log "CLIENT_OK psql=/usr/bin/psql real=$(readlink -f /usr/bin/psql) version='$(/usr/bin/psql --version)' sha256=$(sha "$(readlink -f /usr/bin/psql)") link_sha256=$(sha /usr/bin/psql) pg_dump='$(pg_dump --version 2>/dev/null)'"
# ---- PG 17.6 server distribution into the fresh namespace (verified download/extract; mismatch refuses 70)
STAGE=server
PROV=$PG17_HOME/PROVENANCE.txt
[ -e "$PG17_HOME/dist" ] && { log "REFUSED: $PG17_HOME/dist already present; not deleting"; finish 70; }
mkdir -p "$PG17_HOME/download" && cd "$PG17_HOME/download" || finish 70
timeout --foreground 300 curl -fsSLo "$ART" "$BASE/$ART"; rc=$?; log "curl_jar_exit=$rc"; [ $rc = 0 ] || finish $rc
timeout --foreground 60 curl -fsSLo "$ART.sha1" "$BASE/$ART.sha1"; rc=$?; log "curl_sha1_exit=$rc"; [ $rc = 0 ] || finish $rc
log "maven_sha1=$(cat "$ART.sha1") pinned_sha1=$PINNED_SHA1"
[ "$(tr -d ' \n' <"$ART.sha1")" = "$PINNED_SHA1" ] || { log "Maven sha1 file != pinned; refusing"; finish 70; }
echo "$PINNED_SHA1  $ART" | sha1sum -c - >>"$LOG" 2>&1 || { log "download sha1 mismatch; refusing"; finish 70; }
log "jar_sha256=$(sha "$ART") jar_bytes=$(stat -c %s "$ART")"
[ "$(sha "$ART")" = "$S1_JAR_SHA256" ] || { log "jar sha256 != pin; refusing"; finish 70; }
unzip -o -q "$ART" postgres-linux-x86_64.txz || finish 70
log "txz_sha256=$(sha postgres-linux-x86_64.txz) txz_bytes=$(stat -c %s postgres-linux-x86_64.txz)"
[ "$(sha postgres-linux-x86_64.txz)" = "$S1_TXZ_SHA256" ] || { log "txz sha256 != pin; refusing"; finish 70; }
mkdir -p "$PG17_HOME/dist" && tar -xJf postgres-linux-x86_64.txz -C "$PG17_HOME/dist" || finish 70
V=$(LD_LIBRARY_PATH="$PG17_HOME/dist/lib" "$PG17_HOME/dist/bin/postgres" --version); log "server_binary=$V"
[ "${V##* }" = 17.6 ] || { log "not 17.6; refusing"; finish 70; }
[ "$(sha "$PG17_HOME/dist/bin/postgres")" = "$S1_POSTGRES_SHA256" ] && [ "$(sha "$PG17_HOME/dist/bin/initdb")" = "$S1_INITDB_SHA256" ] || { log "server binaries sha256 != pin; refusing"; finish 70; }
for b in postgres initdb pg_ctl; do [ -x "$PG17_HOME/dist/bin/$b" ] || { log "VERIFY_FAIL $b missing"; finish 70; }; log "bin_$b sha256=$(sha "$PG17_HOME/dist/bin/$b")"; done
case "$(sha "$PG17_HOME/dist/bin/pg_ctl")" in "$PGCTL_PREFIX"*) log "pg_ctl matches recorded prefix $PGCTL_PREFIX";; *) log "NOTE pg_ctl differs from recorded prefix $PGCTL_PREFIX";; esac
( cd "$PG17_HOME/dist" && find . -type f -print0 | sort -z | xargs -0 sha256sum ) > "$R/pg17-dist-files.sha256"
log "dist_file_count=$(wc -l <"$R/pg17-dist-files.sha256") dist_manifest_sha256=$(sha "$R/pg17-dist-files.sha256")"
{ echo "artifact=$BASE/$ART"; echo "maven_sha1=$PINNED_SHA1 (Maven publishes SHA1/MD5 only)"; echo "jar_sha256=$(sha "$ART")"; echo "txz_sha256=$(sha postgres-linux-x86_64.txz)"
  echo "postgres_sha256=$(sha "$PG17_HOME/dist/bin/postgres")"; echo "initdb_sha256=$(sha "$PG17_HOME/dist/bin/initdb")"; echo "pg_ctl_sha256=$(sha "$PG17_HOME/dist/bin/pg_ctl")"; echo "server_binary=$V"
  echo "installed_by=tgp-private-evidence/execution/64e33dc7/runtime/rt-setup.sh"; echo "utc=$(ts)"; echo "log=$LOG"; echo "result=success"; } > "$PROV"
log "provenance_written=$PROV clusters_dir=$([ -e "$PG17_HOME/clusters" ] && echo present || echo absent)"
# ---- detached environment worktree at accepted backend (not a builder worktree)
STAGE=worktree
[ -e "$WT" ] && { log "REFUSED: $WT exists"; finish 70; }
[ "$(git -C "$REPO" rev-parse "$ACCEPTED^{commit}")" = "$ACCEPTED" ] || { log "accepted commit absent"; finish 70; }
HOOKS=$(git -C "$REPO" rev-parse --path-format=absolute --git-common-dir)/hooks
log "hooks_dir=$HOOKS before=[$(ls "$HOOKS" | tr '\n' ' ')] core.hooksPath=$(git -C "$REPO" config --get core.hooksPath || echo unset)"
mkdir -p "$(dirname "$WT")"
git -C "$REPO" worktree add --detach "$WT" "$ACCEPTED" >>"$LOG" 2>&1; rc=$?; log "worktree_add_exit=$rc"; [ $rc = 0 ] || finish $rc
cd "$WT" || finish 70
H=$(git rev-parse HEAD); T=$(git rev-parse HEAD^{tree}); log "head=$H tree=$T"
[ "$H" = "$ACCEPTED" ] && [ "$T" = "$EXPECT_TREE" ] || { log "head/tree mismatch; refusing"; finish 70; }
[ -z "$(git status --porcelain --untracked-files=all)" ] || { log "worktree dirty; refusing"; finish 70; }
log "package_lock_sha256=$(sha package-lock.json) expected=$EXPECT_PKG_LOCK package_json_sha256=$(sha package.json) schema_sha256=$(sha prisma/schema.prisma) (S8-B record $REC_SCHEMA)"
[ "$(sha package-lock.json)" = "$EXPECT_PKG_LOCK" ] || { log "package-lock sha mismatch; refusing"; finish 70; }
# ---- genuine npm ci (lifecycle scripts run: postinstall prisma generate, prepare lefthook install)
STAGE=npm_ci
export npm_config_cache=$ROOT/npm-cache XDG_CACHE_HOME=$ROOT/xdg-cache npm_config_update_notifier=false
mkdir -p "$npm_config_cache" "$XDG_CACHE_HOME"
OUT_BEFORE=$(find /home/user/node_modules -maxdepth 2 -printf '%p %s %T@\n' 2>/dev/null | sort | sha256sum | cut -c1-64)
log "outside_root_before: /home/user/node_modules entries=$(ls -1 /home/user/node_modules | wc -l) listing_sha256=$OUT_BEFORE"
df -h / | tail -1 | tee -a "$LOG"
timeout --foreground 1500 npm ci --no-audit --no-fund --foreground-scripts >"$R/npm-ci.out" 2>&1; rc=$?
log "npm_ci_exit=$rc utc=$(ts) (full output raw/npm-ci.out, sha256 $(sha "$R/npm-ci.out"))"; tail -25 "$R/npm-ci.out" >>"$LOG"; [ $rc = 0 ] || finish $rc
NM_LOCK=$(sha node_modules/.package-lock.json); log "nm_hidden_lock_sha256=$NM_LOCK prior_record=$REC_NM_LOCK match=$([ "$NM_LOCK" = "$REC_NM_LOCK" ] && echo yes || echo NO)"
C1=$( [ -f node_modules/.prisma/client/index.d.ts ] && sha node_modules/.prisma/client/index.d.ts || echo absent); log "client_index_d_ts_after_postinstall=$C1"
log "hooks_after_npm_ci=[$(ls "$HOOKS" | tr '\n' ' ')]"
# ---- CI step: npx prisma generate
STAGE=prisma_generate
log "prisma_version=$(npx --no-install prisma --version 2>&1 | tr '\n' ' ' | tr -s ' ')"
timeout --foreground 600 npx --no-install prisma generate >"$R/prisma-generate.out" 2>&1; rc=$?
cat "$R/prisma-generate.out" >>"$LOG"; log "prisma_generate_exit=$rc utc=$(ts)"; [ $rc = 0 ] || finish $rc
C2=$(sha node_modules/.prisma/client/index.d.ts); log "client_index_d_ts=$C2 equal_to_postinstall=$([ "$C1" = "$C2" ] && echo yes || echo NO) s8b_record=$REC_CLIENT match=$([ "$C2" = "$REC_CLIENT" ] && echo yes || echo NO)"
for f in index.js schema.prisma package.json; do [ -f node_modules/.prisma/client/$f ] && log "client_$f sha256=$(sha node_modules/.prisma/client/$f)"; done
ENG=$(ls node_modules/.prisma/client/libquery_engine-*.so.node 2>/dev/null | head -1); [ -n "$ENG" ] && log "client_engine=$(basename "$ENG") sha256=$(sha "$ENG")"
log "hidden_lock_after_generate=$(sha node_modules/.package-lock.json)"
# ---- hooks + identities
STAGE=verify
for h in pre-commit commit-msg; do [ -f "$HOOKS/$h" ] && log "hook_$h sha256=$(sha "$HOOKS/$h") mode=$(stat -c %a "$HOOKS/$h")" || log "hook_$h ABSENT"; done
log "lefthook_version=$(npx --no-install lefthook version 2>&1 | head -1) lefthook_checksum_file=$( [ -f "$(git rev-parse --git-path info/lefthook.checksum)" ] && cat "$(git rev-parse --git-path info/lefthook.checksum)" || echo absent)"
log "tsc_version=$(node node_modules/typescript/bin/tsc --version) jest_pkg=$(node -p "require('./node_modules/jest/package.json').version") (versions only; no compile/test)"
log "nm_top_level_entries=$(ls -1 node_modules | wc -l) nm_du=$(du -sh node_modules | cut -f1)"
OUT_AFTER=$(find /home/user/node_modules -maxdepth 2 -printf '%p %s %T@\n' 2>/dev/null | sort | sha256sum | cut -c1-64)
log "outside_root_after: entries=$(ls -1 /home/user/node_modules | wc -l) listing_sha256=$OUT_AFTER unchanged=$([ "$OUT_BEFORE" = "$OUT_AFTER" ] && echo yes || echo NO)"
G=$(git status --porcelain --untracked-files=all); log "clean_after=$([ -z "$G" ] && echo yes || echo "NO [$G]") head_after=$(git rev-parse HEAD)"
P=$(procs); log "post_relevant_processes=[${P:-none}] postgres_procs=$(pgrep -cx postgres || true) clusters_dir=$([ -e "$PG17_HOME/clusters" ] && echo present || echo absent)"
df -h / | tail -1 | tee -a "$LOG"
STAGE=done; finish 0
