#!/usr/bin/env bash
# EXEC-1910A060 RT-NEW-1: pinned PostgreSQL 17.6 server distribution into the fresh namespace (owner 14:14 PT clarification:
# prefer the exact predecessor artifact via the recorded no-cost Maven route). Verified download + extract ONLY. This stage
# needs no heavy slot (no install into a worktree, no server), so per the parent's 14:19 PT relay it runs AFTER the
# rt-setup-1910a060.sh lock release and takes no flock. Refuses (rc 70) on any pin mismatch. No initdb, no server start.
# Same pins as execution/64e33dc7/runtime/rt-setup.sh / cf8ff737 b-pg-env-recovery.sh.
# Usage: timeout -k 30 900 bash pg17-fetch-1910a060.sh
set -uo pipefail
EVD=/home/user/workspace/tgp-private-evidence/execution/d3a9f701/runtime; R=$EVD/raw
LOG=$R/pg17-fetch.log; SENT=$R/pg17-fetch.sentinel
ROOT=/home/user/workspace/execution/1910a060/runtime
PG17_HOME=$ROOT/pg17
ART=embedded-postgres-binaries-linux-amd64-17.6.0.jar
BASE=https://repo1.maven.org/maven2/io/zonky/test/postgres/embedded-postgres-binaries-linux-amd64/17.6.0
PINNED_SHA1=8163322358dbe4e6c2abccc90f2e543f8cfc65db
S1_JAR_SHA256=23da5a044b4fb7a5a081a45008c95749c873305328d73f86aefd56922ce1d29d
S1_TXZ_SHA256=26fa633461a3340913015503d0783d73a28384110257e2f17d9936bdf8b067c0
S1_POSTGRES_SHA256=23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a
S1_INITDB_SHA256=b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a
REC_PGCTL_SHA256=af53d826845af4679a0aaba2bda319f5e527f3b94f3794c67fa174049c9b9401
mkdir -p "$R" "$ROOT"
[ -e "$SENT" ] && { echo "REFUSED: $SENT exists (do not loop)" >&2; exit 76; }
ts(){ date -u +%FT%TZ; }; log(){ echo "$*" | tee -a "$LOG"; }; sha(){ sha256sum "$1" | cut -c1-64; }
finish(){ echo "RC=$1 STAGE=$STAGE END=$(ts)" >"$SENT"; log "END rc=$1 stage=$STAGE $(ts) (no lock was taken by this script)"; exit "$1"; }
STAGE=server
log "START $(ts) pid=$$ lock_holder=[$(lslocks -n -o PID,MODE,PATH 2>/dev/null | grep test-validation | tr -s ' ' | tr '\n' ';' || true)] postgres_procs=$(pgrep -cx postgres || true)"
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
[ "$(sha "$PG17_HOME/dist/bin/pg_ctl")" = "$REC_PGCTL_SHA256" ] && log "pg_ctl matches recorded $REC_PGCTL_SHA256" || log "NOTE pg_ctl differs from recorded $REC_PGCTL_SHA256"
( cd "$PG17_HOME/dist" && find . -type f -print0 | sort -z | xargs -0 sha256sum ) > "$R/pg17-dist-files.sha256"
log "dist_file_count=$(wc -l <"$R/pg17-dist-files.sha256") dist_manifest_sha256=$(sha "$R/pg17-dist-files.sha256")"
{ echo "artifact=$BASE/$ART"; echo "maven_sha1=$PINNED_SHA1 (Maven publishes SHA1/MD5 only)"; echo "jar_sha256=$(sha "$ART")"; echo "txz_sha256=$(sha postgres-linux-x86_64.txz)"
  echo "postgres_sha256=$(sha "$PG17_HOME/dist/bin/postgres")"; echo "initdb_sha256=$(sha "$PG17_HOME/dist/bin/initdb")"; echo "pg_ctl_sha256=$(sha "$PG17_HOME/dist/bin/pg_ctl")"; echo "server_binary=$V"
  echo "installed_by=tgp-private-evidence/execution/1910a060/runtime/pg17-fetch-1910a060.sh"; echo "utc=$(ts)"; echo "log=$LOG"; echo "result=success"; } > "$PROV"
log "SERVER_OK provenance_written=$PROV clusters_dir=$([ -e "$PG17_HOME/clusters" ] && echo present || echo absent) (no initdb, no start)"
log "libs: $(ls "$PG17_HOME/dist/lib" | grep -E '^libpq|^libssl|^libcrypto|^libxml' | tr '\n' ' ')"
[ -x "$PG17_HOME/dist/bin/psql" ] && log "dist_psql=$PG17_HOME/dist/bin/psql version='$(LD_LIBRARY_PATH=$PG17_HOME/dist/lib "$PG17_HOME/dist/bin/psql" --version)' sha256=$(sha "$PG17_HOME/dist/bin/psql")" || log "dist_psql=absent"
log "postgres_procs_after=$(pgrep -cx postgres || true) clusters_dir=$([ -e "$PG17_HOME/clusters" ] && echo present || echo absent)"
STAGE=done; finish 0
