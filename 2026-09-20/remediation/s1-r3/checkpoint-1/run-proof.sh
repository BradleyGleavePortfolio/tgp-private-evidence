#!/usr/bin/env bash
# S1 R3 heavy-run wrapper (builder evidence, not self-audit).
# Runs the S1-DB-01 harness ONCE against the disposable synthetic PG17 fixture,
# under the shared nonblocking validation lock, stamping every input that
# determines the result. Preserves the harness's real exit code; fails closed
# on every wrapper-side error. Never reuses artifacts; every run writes a new
# log named by attempt number and head.
#
# Usage (parent-authorized slot only):
#   S1_PG_SUPER_URL=postgresql://s1_super:<pw>@127.0.0.1:54321/postgres \
#   S1_PG_PORT=54321 \
#   S1_PG_DISPOSABLE_CONFIRM='DESTROY-127.0.0.1:54321/s1_rls_proof,s1_rls_proof_lock' \
#   S1_PRISMA_CLI=/abs/path/to/node_modules/prisma/build/index.js \
#   execution/s1-r3/run-proof.sh [attempt-number]
set -uo pipefail
ROOT=/home/user/workspace
WT=$ROOT/worktrees/s1-r3
OUT=$ROOT/execution/s1-r3
LOCK=$ROOT/execution/test-validation.lock
ATTEMPT=${1:-$(( $(ls "$OUT"/proof-run-*.log 2>/dev/null | wc -l) + 1 ))}
cd "$WT" || exit 70
HEAD=$(git rev-parse HEAD); SHORT=$(git rev-parse --short HEAD); TREE=$(git rev-parse HEAD^{tree})
STATUS=$(git status --porcelain --untracked-files=all)
LOGF=$(printf '%s/proof-run-%02d-head-%s.log' "$OUT" "$ATTEMPT" "$SHORT")
[ -e "$LOGF" ] && { echo "refusing to overwrite $LOGF"; exit 70; }

exec 9>"$LOCK"
if ! flock -n 9; then echo "validation lock busy ($LOCK); not waiting" | tee "$LOGF"; exit 75; fi

redact(){ sed -E 's#://[^@[:space:]]*@#://<redacted>@#g'; }
PRISMA_CLI=${S1_PRISMA_CLI:-$WT/node_modules/prisma/build/index.js}
{
  echo "== S1 R3 proof run attempt $ATTEMPT"
  echo "start_utc=$(date -u +%FT%TZ)"
  echo "worktree=$WT"
  echo "head=$HEAD"; echo "tree=$TREE"; echo "branch=$(git rev-parse --abbrev-ref HEAD)"
  if [ -z "$STATUS" ]; then echo "worktree_clean=yes"; else echo "worktree_clean=NO"; printf '%s\n' "$STATUS" | sed 's/^/  dirty: /'; fi
  echo "harness_sha256=$(sha256sum test/db/s1-rls-close-public-exposure.sh | cut -c1-64)"
  echo "guard_sha256=$(sha256sum test/db/_support/s1-target-guard.sh | cut -c1-64)"
  echo "verify_sql_sha256=$(sha256sum prisma/migrations/20261224000000_rls_close_public_exposure/verify.sql | cut -c1-64)"
  echo "migration_sql_sha256=$(sha256sum prisma/migrations/20261224000000_rls_close_public_exposure/migration.sql | cut -c1-64)"
  echo "package_lock_sha256=$(sha256sum package-lock.json | cut -c1-64)"
  echo "prisma_cli=$PRISMA_CLI"
  echo "prisma_cli_sha256=$( [ -f "$PRISMA_CLI" ] && sha256sum "$PRISMA_CLI" | cut -c1-64 || echo MISSING)"
  echo "prisma_version=$( [ -f "$PRISMA_CLI" ] && node "$PRISMA_CLI" --version 2>&1 | tr '\n' ' ' || echo MISSING)"
  echo "node_version=$(node --version 2>&1)"
  echo "psql_version=$(psql --version 2>&1)"
  echo "pg_dump_version=$(pg_dump --version 2>&1)"
  echo "S1_PG_PORT=${S1_PG_PORT-unset}"
  echo "S1_PG_SUPER_URL=$(printf '%s' "${S1_PG_SUPER_URL-unset}" | redact)"
  echo "S1_PG_DISPOSABLE_CONFIRM=${S1_PG_DISPOSABLE_CONFIRM-unset}"
  echo "server_identity=$( [ -n "${S1_PG_SUPER_URL-}" ] && PGCONNECT_TIMEOUT=5 timeout 20 psql "$S1_PG_SUPER_URL" -X -qAt -c "select version()||' cluster='||current_setting('cluster_name')||' datadir='||current_setting('data_directory')||' addr='||host(inet_server_addr())||':'||inet_server_port()" 2>&1 | redact | head -1 || echo unset)"
  echo "lock=$LOCK (held nonblocking by pid $$)"
  echo "cpu=$(nproc) mem_total_kb=$(awk '/MemTotal/{print $2}' /proc/meminfo) disk_free=$(df -h "$ROOT" | awk 'NR==2{print $4}')"
  echo "command=test/db/s1-rls-close-public-exposure.sh s1_rls_proof"
  echo "== harness output"
} > "$LOGF" 2>&1
[ -z "$STATUS" ] || { echo "worktree not clean; refusing to produce evidence" | tee -a "$LOGF"; exit 70; }

S1_PROOF_LOG="$OUT/proof-run-$(printf '%02d' "$ATTEMPT")-harness-detail.log" \
  bash test/db/s1-rls-close-public-exposure.sh s1_rls_proof 2>&1 | tee -a "$LOGF"
RC=${PIPESTATUS[0]}
{
  echo "== end"
  echo "harness_exit_code=$RC"
  echo "end_utc=$(date -u +%FT%TZ)"
  echo "head_after=$(git rev-parse HEAD) clean_after=$([ -z "$(git status --porcelain --untracked-files=all)" ] && echo yes || echo NO)"
} | tee -a "$LOGF"
exit "$RC"
