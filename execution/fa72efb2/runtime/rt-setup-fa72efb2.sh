#!/usr/bin/env bash
# EXEC-FA72EFB2 runtime setup (new environment; no identity claim with any predecessor runtime).
# Same pinned PG 17.6 artifact as execution/d3a9f701/runtime/pg17-fetch-d3a9f701.sh (Maven zonky 17.6.0; sha1 + sha256 pins),
# apt psql client (major 17-19), genuine `npm ci` (lifecycle scripts on: prepare=lefthook install, postinstall=prisma generate)
# plus the CI step `npx prisma generate` in the standalone source clone worktrees/fa72-s11a1 (HEAD 3db615c0 = S11-A1 v3),
# and pinned prettier@3.9.9 in an isolated prefix (lefthook pre-commit runs `npx prettier --check`; the lock has no prettier).
# Holds the canonical lock (inode 686480) nonblocking on fd 9 for the whole run; never creates/deletes it.
# NOT performed: initdb, server start, migration, jest, tsc, eslint, any proof.
set -uo pipefail
EVD=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/runtime; R=$EVD/raw
LOG=$R/rt-setup.log; SENT=$R/rt-setup.sentinel
ROOT=/home/user/workspace/execution/fa72efb2/runtime
LOCK=/home/user/workspace/execution/test-validation.lock; LOCK_INODE=686480
W=/home/user/workspace/worktrees/fa72-s11a1; EXPECT_HEAD=3db615c0a5e64a63b910d34ce7c732ee6e63f24d
EXPECT_PKG_LOCK=b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55
PG17_HOME=$ROOT/pg17; ART=embedded-postgres-binaries-linux-amd64-17.6.0.jar
BASE=https://repo1.maven.org/maven2/io/zonky/test/postgres/embedded-postgres-binaries-linux-amd64/17.6.0
PINNED_SHA1=8163322358dbe4e6c2abccc90f2e543f8cfc65db
S1_JAR_SHA256=23da5a044b4fb7a5a081a45008c95749c873305328d73f86aefd56922ce1d29d
S1_TXZ_SHA256=26fa633461a3340913015503d0783d73a28384110257e2f17d9936bdf8b067c0
S1_POSTGRES_SHA256=23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a
S1_INITDB_SHA256=b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a
REC_PGCTL_SHA256=af53d826845af4679a0aaba2bda319f5e527f3b94f3794c67fa174049c9b9401
PVER=3.9.9; PFX=$ROOT/tools/prettier-$PVER; P_TARBALL=https://registry.npmjs.org/prettier/-/prettier-3.9.9.tgz
P_INTEGRITY='sha512-Z/CJHIkdujO/OtN7nXUii0Rf3VT5SRuhjBA82Xvu2XhBUgX3nhP67T0LHceBdQLex7OOFGTox+Q5Yg8Jk2Qivg=='
P_TGZ_SHA256=c3b162d30c45126873cc6338a539383e92120a390d10de78f373f42c2045b338
export GIT_NO_LAZY_FETCH=1 GIT_OPTIONAL_LOCKS=0
mkdir -p "$R" "$ROOT"
[ -e "$SENT" ] && { echo "REFUSED: $SENT exists" >&2; exit 76; }
ts(){ date -u +%FT%TZ; }; log(){ echo "$*" | tee -a "$LOG"; }; sha(){ sha256sum "$1" | cut -c1-64; }
[ -e "$LOCK" ] && [ "$(stat -c %i "$LOCK")" = "$LOCK_INODE" ] || { log "REFUSED: lock absent or inode != $LOCK_INODE"; exit 75; }
exec 9>>"$LOCK"; flock -n 9 || { log "REFUSED: canonical lock busy"; exit 75; }
finish(){ echo "RC=$1 STAGE=$STAGE END=$(ts) LOCK_INODE=$(stat -c %i "$LOCK")" >"$SENT"; log "END rc=$1 stage=$STAGE $(ts) (fd9 released on exit)"; exit "$1"; }
STAGE=preflight
log "START $(ts) pid=$$ host=$(hostname) lock inode=$(stat -c %i "$LOCK") held fd9; node=$(node --version) node_sha256=$(sha "$(readlink -f "$(command -v node)")") npm=$(npm --version) os=$(. /etc/os-release; echo "$PRETTY_NAME") cpus=$(nproc) mem_gb=$(free -g | awk '/Mem/{print $2}')"
node --version | grep -q '^v20\.' || { log "node major != 20"; finish 70; }
df -h / | tail -1 | tee -a "$LOG"
# ---- PG 17.6 server distribution
STAGE=pg17
[ -e "$PG17_HOME/dist" ] && { log "REFUSED: $PG17_HOME/dist exists"; finish 70; }
mkdir -p "$PG17_HOME/download" && cd "$PG17_HOME/download" || finish 70
timeout --foreground 300 curl -fsSLo "$ART" "$BASE/$ART" || { log "curl jar failed"; finish 70; }
timeout --foreground 60 curl -fsSLo "$ART.sha1" "$BASE/$ART.sha1" || { log "curl sha1 failed"; finish 70; }
[ "$(tr -d ' \n' <"$ART.sha1")" = "$PINNED_SHA1" ] && echo "$PINNED_SHA1  $ART" | sha1sum -c - >>"$LOG" 2>&1 || { log "sha1 mismatch"; finish 70; }
[ "$(sha "$ART")" = "$S1_JAR_SHA256" ] || { log "jar sha256 != pin"; finish 70; }
unzip -o -q "$ART" postgres-linux-x86_64.txz && [ "$(sha postgres-linux-x86_64.txz)" = "$S1_TXZ_SHA256" ] || { log "txz sha256 != pin"; finish 70; }
mkdir -p "$PG17_HOME/dist" && tar -xJf postgres-linux-x86_64.txz -C "$PG17_HOME/dist" || finish 70
V=$(LD_LIBRARY_PATH="$PG17_HOME/dist/lib" "$PG17_HOME/dist/bin/postgres" --version); [ "${V##* }" = 17.6 ] || { log "not 17.6: $V"; finish 70; }
[ "$(sha "$PG17_HOME/dist/bin/postgres")" = "$S1_POSTGRES_SHA256" ] && [ "$(sha "$PG17_HOME/dist/bin/initdb")" = "$S1_INITDB_SHA256" ] && [ "$(sha "$PG17_HOME/dist/bin/pg_ctl")" = "$REC_PGCTL_SHA256" ] || { log "server binaries sha256 != pin"; finish 70; }
rm -f "$ART" postgres-linux-x86_64.txz
{ echo "artifact=$BASE/$ART"; echo "maven_sha1=$PINNED_SHA1"; echo "jar_sha256=$S1_JAR_SHA256"; echo "txz_sha256=$S1_TXZ_SHA256"; echo "postgres_sha256=$S1_POSTGRES_SHA256"; echo "initdb_sha256=$S1_INITDB_SHA256"; echo "pg_ctl_sha256=$REC_PGCTL_SHA256"; echo "server_binary=$V"; echo "installed_by=tgp-private-evidence/execution/fa72efb2/runtime/rt-setup-fa72efb2.sh"; echo "utc=$(ts)"; echo "result=success"; } > "$PG17_HOME/PROVENANCE.txt"
log "PG17_OK $V (jar/txz/postgres/initdb/pg_ctl pins match; no initdb, no start)"
# ---- psql client
STAGE=psql
if ! ls /usr/lib/postgresql/*/bin/psql >/dev/null 2>&1; then
  timeout --foreground 600 sudo -n apt-get update -qq >>"$LOG" 2>&1 || { log "apt update failed"; finish 70; }
  if apt-cache show postgresql-client-18 >/dev/null 2>&1; then PKG=postgresql-client-18; elif apt-cache show postgresql-client-17 >/dev/null 2>&1; then PKG=postgresql-client-17; else PKG=postgresql-client; fi
  DEBIAN_FRONTEND=noninteractive timeout --foreground 900 sudo -n apt-get install -y -qq --no-install-recommends "$PKG" >>"$LOG" 2>&1 || { log "apt install $PKG failed"; finish 70; }
fi
PSQL_REAL=$(ls /usr/lib/postgresql/*/bin/psql 2>/dev/null | sort -V | tail -1)
PV=$("$PSQL_REAL" --version); grep -qE '\(PostgreSQL\) 1[7-9]\.' <<<"$PV" || { log "psql major < 17: $PV"; finish 70; }
log "PSQL_OK real=$PSQL_REAL version='$PV' sha256=$(sha "$PSQL_REAL") dpkg='$(dpkg -S "$PSQL_REAL" 2>/dev/null | cut -d: -f1) $(dpkg-query -W -f='${Version}' "$(dpkg -S "$PSQL_REAL" 2>/dev/null | cut -d: -f1)" 2>/dev/null)'"
# ---- npm ci + prisma generate in the source clone
STAGE=npm_ci
cd "$W" || finish 70
[ "$(git rev-parse HEAD)" = "$EXPECT_HEAD" ] && [ -z "$(git status --porcelain --untracked-files=all)" ] || { log "source clone head/clean mismatch"; finish 70; }
[ "$(sha package-lock.json)" = "$EXPECT_PKG_LOCK" ] || { log "package-lock sha != pin"; finish 70; }
[ ! -e node_modules ] || { log "node_modules already present"; finish 70; }
export npm_config_cache=$ROOT/npm-cache XDG_CACHE_HOME=$ROOT/xdg-cache npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false PRISMA_HIDE_UPDATE_MESSAGE=1 CHECKPOINT_DISABLE=1
timeout --foreground 1800 npm ci --no-audit --no-fund --foreground-scripts >"$R/npm-ci.out" 2>&1; rc=$?
log "npm_ci_exit=$rc $(ts)"; tail -15 "$R/npm-ci.out" >>"$LOG"; [ $rc = 0 ] || finish $rc
C1=$(sha node_modules/.prisma/client/index.d.ts 2>/dev/null || echo absent)
STAGE=prisma_generate
timeout --foreground 600 npx --no-install prisma generate >"$R/prisma-generate.out" 2>&1; rc=$?; cat "$R/prisma-generate.out" >>"$LOG"; [ $rc = 0 ] || finish $rc
C2=$(sha node_modules/.prisma/client/index.d.ts)
log "NM_OK hidden_lock=$(sha node_modules/.package-lock.json) client_index_dts=$C2 postinstall_equal=$([ "$C1" = "$C2" ] && echo yes || echo NO) client_schema=$(sha node_modules/.prisma/client/schema.prisma) prisma=$(npx --no-install prisma --version 2>/dev/null | awk '/^prisma /{print $3}') jest=$(./node_modules/.bin/jest --version) tsc=$(node node_modules/typescript/bin/tsc --version) nm_du=$(du -sh node_modules | cut -f1)"
H=$(git rev-parse --path-format=absolute --git-path hooks); for h in pre-commit commit-msg; do [ -f "$H/$h" ] && log "hook_$h sha256=$(sha "$H/$h") lefthook=$(grep -c lefthook "$H/$h")" || log "hook_$h ABSENT"; done
[ -z "$(git status --porcelain --untracked-files=all)" ] || { log "clone dirty after install: $(git status --porcelain | head)"; finish 70; }
# ---- prettier 3.9.9 isolated prefix
STAGE=prettier
mkdir -p "$ROOT/tools/download" && cd "$ROOT/tools/download" || finish 70
timeout --foreground 120 curl -fsSLo prettier-$PVER.tgz "$P_TARBALL" || { log "curl prettier failed"; finish 70; }
[ "sha512-$(openssl dgst -sha512 -binary prettier-$PVER.tgz | base64 -w0)" = "$P_INTEGRITY" ] && [ "$(sha prettier-$PVER.tgz)" = "$P_TGZ_SHA256" ] || { log "prettier tarball hash mismatch"; finish 70; }
npm install --global --prefix "$PFX" --offline --no-audit --no-fund "$ROOT/tools/download/prettier-$PVER.tgz" >"$R/npm-install-prettier.out" 2>&1 || { log "prettier install failed"; finish 70; }
[ "$("$PFX/bin/prettier" --version)" = "$PVER" ] || { log "prettier version mismatch"; finish 70; }
log "PRETTIER_OK prefix=$PFX (use: export npm_config_prefix=$PFX PATH=$PFX/bin:\$PATH)"
df -h / | tail -1 | tee -a "$LOG"
STAGE=done; finish 0
