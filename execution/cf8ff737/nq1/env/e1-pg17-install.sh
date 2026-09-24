#!/usr/bin/env bash
# N/Q1 v2r Phase E step 1 — PG17 tooling install. Logic of
# tgp-private-evidence/2026-09-22/remediation/s2-setup-prep/proposal-1/infra/setup-20-pg17.sh (pins unchanged),
# retargeted: log under execution/cf8ff737/nq1/env, no validation lock (download/extract only; the lock is for npm ci/generate).
set -euo pipefail
PG17_HOME=/home/user/pg17
sha(){ sha256sum "$1" | cut -c1-64; }
S1_JAR_SHA256=23da5a044b4fb7a5a081a45008c95749c873305328d73f86aefd56922ce1d29d
S1_TXZ_SHA256=26fa633461a3340913015503d0783d73a28384110257e2f17d9936bdf8b067c0
S1_POSTGRES_SHA256=23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a
S1_INITDB_SHA256=b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a
ART=embedded-postgres-binaries-linux-amd64-17.6.0.jar
BASE=https://repo1.maven.org/maven2/io/zonky/test/postgres/embedded-postgres-binaries-linux-amd64/17.6.0
PINNED_SHA1=8163322358dbe4e6c2abccc90f2e543f8cfc65db
echo "== e1-pg17-install start_utc=$(date -u +%FT%TZ) pg17_home_before=$([ -e $PG17_HOME ] && echo PRESENT || echo absent)"
[ -d "$PG17_HOME/dist" ] && { echo "REFUSED: $PG17_HOME/dist present; not deleting"; exit 70; }
mkdir -p "$PG17_HOME/download" && cd "$PG17_HOME/download"
PROV=$PG17_HOME/PROVENANCE.txt
set +e; timeout --foreground 300 curl -fsSLo "$ART" "$BASE/$ART"; rc=$?; set -e; echo "curl_jar_exit=$rc"; [ $rc -eq 0 ] || exit $rc
set +e; timeout --foreground 60 curl -fsSLo "$ART.sha1" "$BASE/$ART.sha1"; rc=$?; set -e; echo "curl_sha1_exit=$rc"; [ $rc -eq 0 ] || exit $rc
echo "maven_sha1=$(cat "$ART.sha1") pinned_sha1=$PINNED_SHA1"
[ "$(tr -d ' \n' <"$ART.sha1")" = "$PINNED_SHA1" ] || { echo "Maven sha1 file does not match pinned sha1; refusing"; exit 70; }
echo "$PINNED_SHA1  $ART" | sha1sum -c - || { echo "download sha1 mismatch; refusing"; exit 70; }
echo "jar_sha256=$(sha "$ART") jar_bytes=$(stat -c %s "$ART")"
[ "$(sha "$ART")" = "$S1_JAR_SHA256" ] || { echo "jar sha256 != S1-recorded $S1_JAR_SHA256; refusing"; exit 70; }
unzip -o -q "$ART" postgres-linux-x86_64.txz
echo "txz_sha256=$(sha postgres-linux-x86_64.txz) txz_bytes=$(stat -c %s postgres-linux-x86_64.txz)"
[ "$(sha postgres-linux-x86_64.txz)" = "$S1_TXZ_SHA256" ] || { echo "txz sha256 != S1-recorded $S1_TXZ_SHA256; refusing"; exit 70; }
mkdir -p "$PG17_HOME/dist" && tar -xJf postgres-linux-x86_64.txz -C "$PG17_HOME/dist"
V=$(LD_LIBRARY_PATH="$PG17_HOME/dist/lib" "$PG17_HOME/dist/bin/postgres" --version)
echo "server_binary=$V"
[ "${V##* }" = "17.6" ] || { echo "not 17.6; refusing"; exit 70; }
echo "initdb_sha256=$(sha "$PG17_HOME/dist/bin/initdb") postgres_sha256=$(sha "$PG17_HOME/dist/bin/postgres")"
[ "$(sha "$PG17_HOME/dist/bin/postgres")" = "$S1_POSTGRES_SHA256" ] && [ "$(sha "$PG17_HOME/dist/bin/initdb")" = "$S1_INITDB_SHA256" ] || { echo "server binaries sha256 != S1-recorded; refusing"; exit 70; }
{ echo "artifact=$BASE/$ART"; echo "maven_sha1=$PINNED_SHA1 (Maven publishes SHA1/MD5 only)"; echo "jar_sha256=$(sha "$ART")"; echo "txz_sha256=$(sha postgres-linux-x86_64.txz)"
  echo "postgres_sha256=$(sha "$PG17_HOME/dist/bin/postgres")"; echo "initdb_sha256=$(sha "$PG17_HOME/dist/bin/initdb")"; echo "server_binary=$V"
  echo "installed_by=execution/cf8ff737/nq1/env/e1-pg17-install.sh"; echo "utc=$(date -u +%FT%TZ)"; echo "result=success"; } > "$PROV"
echo "provenance_written=$PROV"; ls "$PG17_HOME"; echo "clusters_dir=$([ -e $PG17_HOME/clusters ] && echo PRESENT || echo absent)"
echo "== e1-pg17-install end_utc=$(date -u +%FT%TZ) exit=0"
