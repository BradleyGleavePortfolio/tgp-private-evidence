#!/usr/bin/env bash
# C1 PG environment recovery — DIRECT EQUIVALENTS of the frozen recipes setup-10-clients.sh (622f1997…) and
# setup-20-pg17.sh (96a2a443…) with ONE canonical flock holder (this script) and receipts under the current packet,
# because the recorded _common.sh hard-codes legacy log paths and takes its own lock (A: PG_FIXTURE_BINDING_REVIEW
# "installer-path correction"). Same pins, same refusals (rc 70), same destinations (/home/user/pg17/dist, /usr/bin/psql).
# Frozen recipes are NOT edited or nested. Recovers ONLY the absent server dist + client; never touches worktrees,
# node_modules, or any cluster; does not rebuild S5. RUN ONLY UNDER THE DELEGATED RECOVERY OWNER'S GRANT.
# Usage: timeout -k 30 1500 bash /home/user/workspace/execution/95633079/c1-pg/c1-env-recovery.sh
set -uo pipefail
D=/home/user/workspace/execution/cf8ff737/b-drain/pg-tooling; R=$D/env; LOG=$R/b-pg-env-recovery.log; SENT=$R/b-pg-env-recovery.sentinel
LOCK=/home/user/workspace/execution/test-validation.lock
PG17_HOME=/home/user/pg17
ART=embedded-postgres-binaries-linux-amd64-17.6.0.jar
BASE=https://repo1.maven.org/maven2/io/zonky/test/postgres/embedded-postgres-binaries-linux-amd64/17.6.0
PINNED_SHA1=8163322358dbe4e6c2abccc90f2e543f8cfc65db
S1_JAR_SHA256=23da5a044b4fb7a5a081a45008c95749c873305328d73f86aefd56922ce1d29d
S1_TXZ_SHA256=26fa633461a3340913015503d0783d73a28384110257e2f17d9936bdf8b067c0
S1_POSTGRES_SHA256=23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a
S1_INITDB_SHA256=b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a
PGCTL_PREFIX=af53d826845af467
mkdir -p "$R"
[ -e "$SENT" ] && { echo "REFUSED: $SENT exists; recovery ran already (inspect receipts, do not loop)" >&2; exit 76; }
exec 9>"$LOCK"; flock -n 9 || { echo "REFUSED: canonical lock busy ($LOCK)" >&2; exit 75; }
ts(){ date -u +%FT%TZ; }; log(){ echo "$*" | tee -a "$LOG"; }; sha(){ sha256sum "$1" | cut -c1-64; }
STAGE=start
finish(){ echo "RC=$1 STAGE=$STAGE END=$(ts)" >"$SENT"; log "END rc=$1 stage=$STAGE $(ts)"; exit "$1"; }
log "START $(ts) pid=$$ user=$(id -un) lock=$LOCK(held nonblocking)"
# ---- step 10 client (direct equivalent; recorded acceptance: psql major 17–19; recorded actual 18.6)
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
[ -x /usr/bin/psql ] || { log "CLIENT_FAIL /usr/bin/psql absent after install"; finish 70; }
log "CLIENT_OK psql=/usr/bin/psql version='$(/usr/bin/psql --version)' sha256=$(sha /usr/bin/psql)"
# ---- step 20 server (direct equivalent; verified download/extract; any mismatch refuses 70 and writes no provenance)
STAGE=server
PROV=$PG17_HOME/PROVENANCE.txt
if [ -x "$PG17_HOME/dist/bin/postgres" ] && [ -f "$PROV" ] && grep -qx result=success "$PROV" \
   && [ "$(grep '^postgres_sha256=' "$PROV" | cut -d= -f2)" = "$(sha "$PG17_HOME/dist/bin/postgres")" ] \
   && [ "$(grep '^initdb_sha256=' "$PROV" | cut -d= -f2)" = "$(sha "$PG17_HOME/dist/bin/initdb")" ]; then
  log "SERVER already present via recorded provenance:"; sed 's/^/  prov: /' "$PROV" | tee -a "$LOG"
else
  [ -d "$PG17_HOME/dist" ] && log "dist present WITHOUT matching provenance -> verified re-download/extract"
  mkdir -p "$PG17_HOME/download" && cd "$PG17_HOME/download" || finish 70
  rm -f "$PROV" "$ART" "$ART.sha1"
  timeout --foreground 300 curl -fsSLo "$ART" "$BASE/$ART"; rc=$?; log "curl_jar_exit=$rc"; [ $rc = 0 ] || finish $rc
  timeout --foreground 60 curl -fsSLo "$ART.sha1" "$BASE/$ART.sha1"; rc=$?; log "curl_sha1_exit=$rc"; [ $rc = 0 ] || finish $rc
  log "maven_sha1=$(cat "$ART.sha1") pinned_sha1=$PINNED_SHA1"
  [ "$(tr -d ' \n' <"$ART.sha1")" = "$PINNED_SHA1" ] || { log "Maven sha1 file != pinned; refusing"; finish 70; }
  echo "$PINNED_SHA1  $ART" | sha1sum -c - >>"$LOG" 2>&1 || { log "download sha1 mismatch; refusing"; finish 70; }
  log "jar_sha256=$(sha "$ART") jar_bytes=$(stat -c %s "$ART")"
  [ "$(sha "$ART")" = "$S1_JAR_SHA256" ] || { log "jar sha256 != S1-recorded; refusing"; finish 70; }
  unzip -o -q "$ART" postgres-linux-x86_64.txz || finish 70
  log "txz_sha256=$(sha postgres-linux-x86_64.txz) txz_bytes=$(stat -c %s postgres-linux-x86_64.txz)"
  [ "$(sha postgres-linux-x86_64.txz)" = "$S1_TXZ_SHA256" ] || { log "txz sha256 != S1-recorded; refusing"; finish 70; }
  rm -rf "$PG17_HOME/dist" && mkdir -p "$PG17_HOME/dist" && tar -xJf postgres-linux-x86_64.txz -C "$PG17_HOME/dist" || finish 70
  V=$(LD_LIBRARY_PATH="$PG17_HOME/dist/lib" "$PG17_HOME/dist/bin/postgres" --version); log "server_binary=$V"
  [ "${V##* }" = 17.6 ] || { log "not 17.6; refusing"; finish 70; }
  [ "$(sha "$PG17_HOME/dist/bin/postgres")" = "$S1_POSTGRES_SHA256" ] && [ "$(sha "$PG17_HOME/dist/bin/initdb")" = "$S1_INITDB_SHA256" ] || { log "server binaries sha256 != S1-recorded; refusing"; finish 70; }
  { echo "artifact=$BASE/$ART"; echo "maven_sha1=$PINNED_SHA1 (Maven publishes SHA1/MD5 only)"; echo "jar_sha256=$(sha "$ART")"; echo "txz_sha256=$(sha postgres-linux-x86_64.txz)"
    echo "postgres_sha256=$(sha "$PG17_HOME/dist/bin/postgres")"; echo "initdb_sha256=$(sha "$PG17_HOME/dist/bin/initdb")"; echo "server_binary=$V"
    echo "installed_by=execution/95633079/c1-pg/c1-env-recovery.sh (direct equivalent of s2-composition/infra/setup-20-pg17.sh 96a2a443)"; echo "utc=$(ts)"; echo "log=$LOG"; echo "result=success"; } > "$PROV"
  log "provenance_written=$PROV"
fi
# ---- verify (read-only) — what c1-pg-proof.sh preconditions will re-check
STAGE=verify
[ "$(readlink -f "$PG17_HOME")" = "$PG17_HOME" ] || { log "VERIFY_FAIL $PG17_HOME not a real path"; finish 70; }
for b in postgres initdb pg_ctl; do [ -x "$PG17_HOME/dist/bin/$b" ] || { log "VERIFY_FAIL $b missing"; finish 70; }; log "bin_$b sha256=$(sha "$PG17_HOME/dist/bin/$b")"; done
[ "$(sha "$PG17_HOME/dist/bin/postgres")" = "$S1_POSTGRES_SHA256" ] && [ "$(sha "$PG17_HOME/dist/bin/initdb")" = "$S1_INITDB_SHA256" ] || { log "VERIFY_FAIL server hashes"; finish 70; }
case "$(sha "$PG17_HOME/dist/bin/pg_ctl")" in "$PGCTL_PREFIX"*) log "pg_ctl matches recorded prefix $PGCTL_PREFIX";; *) log "NOTE pg_ctl sha256 differs from recorded 16-char prefix $PGCTL_PREFIX (recorded as observed; postgres/initdb full pins govern)";; esac
log "VERIFY_OK $(ts) server='$(LD_LIBRARY_PATH=$PG17_HOME/dist/lib "$PG17_HOME/dist/bin/postgres" --version)' psql='$(/usr/bin/psql --version)' clusters_dir=$([ -e "$PG17_HOME/clusters" ] && echo present || echo absent) postgres_procs=$(pgrep -cx postgres || true)"
( cd "$R" && sha256sum c1-env-recovery.log > RECEIPTS.sha256 )   # pre-final snapshot; END line is appended after (same C07 qualification)
STAGE=done; finish 0
