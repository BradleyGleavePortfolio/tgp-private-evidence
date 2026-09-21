#!/usr/bin/env bash
# Offline stand-in for psql used ONLY by execution/s5-r3 runner negative controls. Never connects.
# Scenario via STUB_SCENARIO; every invocation is appended to STUB_LOG (args, no stdin echo).
set -u
echo "CALL: $*" >> "${STUB_LOG:?}"
if [ "${1:-}" = "--version" ]; then echo "psql (PostgreSQL) 18.0 (stub)"; exit 0; fi
sql=""; prev=""; for a in "$@"; do [ "$prev" = "-c" ] && sql="$a"; prev="$a"; done
if [ -n "$sql" ]; then
  case "$sql" in
    "DROP DATABASE g2_s5_etq0_disposable") echo "DROP-EXECUTED" >> "$STUB_LOG"; echo "DROP DATABASE"; exit 0;;
    *"count(*) FROM pg_database WHERE datname='g2_s5_etq0_disposable'"*) echo 0; exit 0;;
    *) echo "stub: unexpected -c $sql" >&2; exit 1;;
  esac
fi
cat >/dev/null   # consume the identity query batch
S="${STUB_SCENARIO:?}"
ver=170006; cluster=s5-disposable-pg17; datadir=/home/user/pg17/clusters/s5; listen=127.0.0.1; addr=127.0.0.1; port=54325; user=s5_super; super=t; hosted=0
dbs="postgres s5_tgp template0 template1"; exists=0; marker='<absent>'; sessions=0
case "$S" in
  ok-absent) ;;
  blank-cluster) cluster="";;
  foreign-cluster) cluster="s1-disposable-pg17";;
  hosted-roles) hosted=2;;
  foreign-db) dbs="postgres s5_tgp template0 template1 tgp_production";;
  wrong-version) ver=160004;;
  wrong-datadir) datadir=/var/lib/postgresql/17/main;;
  not-loopback) listen='*'; addr=10.0.0.5;;
  wrong-port) port=5432;;
  not-super) super=f;;
  exists-unmarked) exists=1; marker=""; dbs="g2_s5_etq0_disposable postgres s5_tgp template0 template1";;
  exists-wrong-marker) exists=1; marker="s1-something-else"; dbs="g2_s5_etq0_disposable postgres s5_tgp template0 template1";;
  exists-marked-busy) exists=1; marker=s5-g2-etq0-synthetic-disposable-fixture-safe-to-drop; sessions=1; dbs="g2_s5_etq0_disposable postgres s5_tgp template0 template1";;
  exists-marked-idle) exists=1; marker=s5-g2-etq0-synthetic-disposable-fixture-safe-to-drop; dbs="g2_s5_etq0_disposable postgres s5_tgp template0 template1";;
  connect-fail) echo "psql: error: connection refused (stub)" >&2; exit 2;;
  *) echo "stub: unknown scenario $S" >&2; exit 1;;
esac
printf '%s\n' "$ver" "$cluster" "$datadir" "$listen" "$addr" "$port" "$user" "$super" "$hosted" "$dbs" "$exists" "$marker" "$sessions"
