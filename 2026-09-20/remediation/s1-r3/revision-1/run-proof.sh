#!/usr/bin/env bash
# S1 R3 heavy-run wrapper (builder evidence, not self-audit) — revision 2.
#
# Order of operations (parent review 16:00): nothing that could open a
# connection or execute a tool runs before (1) the worktree is proven clean and
# (2) the harness's OWN disposable-target guard has accepted the inputs offline
# and (3) its read-only preflight has accepted the server. Only then are tool
# versions/hashes stamped, and only then does the harness run — under the
# canonical nonblocking validation lock, inside an outer bounded `timeout`
# (no -k SIGKILL masking; 124 is reported as TIMEOUT, every other code is the
# harness's real exit code). Every stamped field is REQUIRED: a missing tool,
# hash or fixture field fails closed before the harness starts.
#
# Usage (parent-authorized slot only):
#   S1_PG_SUPER_URL=postgresql://s1_super:<pw>@127.0.0.1:54321/postgres \
#   S1_PG_PORT=54321 \
#   S1_PG_DISPOSABLE_CONFIRM='DESTROY-127.0.0.1:54321/s1_rls_proof,s1_rls_proof_lock' \
#   S1_PRISMA_CLI=/abs/path/to/node_modules/prisma/build/index.js \
#   execution/s1-r3/run-proof.sh [attempt-number]
set -euo pipefail
ROOT=/home/user/workspace
WT=$ROOT/worktrees/s1-r3
OUT=$ROOT/execution/s1-r3
LOCK=$ROOT/execution/test-validation.lock
DBNAME=s1_rls_proof
HARNESS_CEILING=${S1_HARNESS_CEILING:-1800}   # seconds; R2 run-05 took ~4 min, generous ceiling
die(){ echo "run-proof: $*" >&2; exit 70; }

cd "$WT" || die "worktree missing: $WT"
ATTEMPT=${1:-$(( $(ls "$OUT"/proof-run-*.log 2>/dev/null | wc -l) + 1 ))}
HEAD=$(git rev-parse HEAD); SHORT=$(git rev-parse --short HEAD); TREE=$(git rev-parse 'HEAD^{tree}')
STATUS=$(git status --porcelain --untracked-files=all)
[ -z "$STATUS" ] || { printf '%s\n' "$STATUS" | sed 's/^/  dirty: /' >&2; die "worktree not clean; refusing to produce evidence"; }
LOGF=$(printf '%s/proof-run-%02d-head-%s.log' "$OUT" "$ATTEMPT" "$SHORT")
DETAIL=$(printf '%s/proof-run-%02d-head-%s-harness-detail.log' "$OUT" "$ATTEMPT" "$SHORT")
[ ! -e "$LOGF" ] && [ ! -e "$DETAIL" ] || die "refusing to overwrite $LOGF / $DETAIL"

# ---- 1. the harness's own guard, offline layer, BEFORE any tool call --------
: "${S1_PG_SUPER_URL:?S1_PG_SUPER_URL required}"; : "${S1_PG_PORT:?S1_PG_PORT required}"; : "${S1_PG_DISPOSABLE_CONFIRM:?S1_PG_DISPOSABLE_CONFIRM required}"
. test/db/_support/s1-target-guard.sh          # defines s1_guard_offline / s1_guard_preflight; refusals exit 64
# The frozen guard (7cbbb03) is written for the harness's `set -u` shell: it captures
# `out=$(psql …); rc=$?` and refuses on rc. Under this wrapper's `set -e` that capture
# would abort before the refusal message, so the guard runs with -e suspended; its
# refusals still `exit 64` from this shell, and any non-refusal failure is caught below.
set +e; s1_guard_offline "$S1_PG_SUPER_URL" "$DBNAME"; grc=$?; set -e
[ "$grc" -eq 0 ] || die "guard offline layer returned $grc without refusing"
# ---- 2. lock (nonblocking, held only for the remainder of this run) ---------
exec 9>"$LOCK"
flock -n 9 || { echo "validation lock busy ($LOCK); not waiting"; exit 75; }
# ---- 3. the harness's read-only preflight ONCE (its only connection); harness repeats it
set +e; s1_guard_preflight "$S1_PG_SUPER_URL" "$DBNAME"; grc=$?; set -e
[ "$grc" -eq 0 ] || die "guard preflight returned $grc without refusing"
# ---- 4. required stamps; every field must resolve or we fail closed ----------
PRISMA_CLI=${S1_PRISMA_CLI:-$WT/node_modules/prisma/build/index.js}
req(){ # req <name> <value>
  [ -n "$2" ] && [ "$2" != MISSING ] || die "required stamp '$1' unavailable"; printf '%s=%s\n' "$1" "$2"; }
redact(){ sed -E 's#://[^@[:space:]]*@#://<redacted>@#g'; }
[ -f "$PRISMA_CLI" ] || die "prisma CLI not found at $PRISMA_CLI"
command -v psql >/dev/null || die "psql not on PATH"
command -v pg_dump >/dev/null || die "pg_dump not on PATH"
command -v node >/dev/null || die "node not on PATH"
{
  echo "== S1 R3 proof run attempt $ATTEMPT"
  req start_utc "$(date -u +%FT%TZ)"
  req worktree "$WT"
  req head "$HEAD"; req tree "$TREE"; req branch "$(git rev-parse --abbrev-ref HEAD)"
  req worktree_clean yes
  req harness_sha256 "$(sha256sum test/db/s1-rls-close-public-exposure.sh | cut -c1-64)"
  req guard_sha256 "$(sha256sum test/db/_support/s1-target-guard.sh | cut -c1-64)"
  req bootstrap_sha256 "$(sha256sum test/db/_support/supabase-like-bootstrap.sql | cut -c1-64)"
  req verify_sql_sha256 "$(sha256sum prisma/migrations/20261224000000_rls_close_public_exposure/verify.sql | cut -c1-64)"
  req migration_sql_sha256 "$(sha256sum prisma/migrations/20261224000000_rls_close_public_exposure/migration.sql | cut -c1-64)"
  req down_sql_sha256 "$(sha256sum prisma/migrations/20261224000000_rls_close_public_exposure/down.sql | cut -c1-64)"
  req package_lock_sha256 "$(sha256sum package-lock.json | cut -c1-64)"
  req prisma_cli "$PRISMA_CLI"
  req prisma_cli_sha256 "$(sha256sum "$PRISMA_CLI" | cut -c1-64)"
  req prisma_version "$(node "$PRISMA_CLI" --version 2>&1 | tr '\n' ' ')"
  req node_version "$(node --version)"
  req psql_version "$(psql --version)"
  req pg_dump_version "$(pg_dump --version)"
  req S1_PG_PORT "$S1_PG_PORT"
  req S1_PG_SUPER_URL "$(printf '%s' "$S1_PG_SUPER_URL" | redact)"
  req S1_PG_DISPOSABLE_CONFIRM "$S1_PG_DISPOSABLE_CONFIRM"
  req guard_preflight "accepted (offline+preflight passed in wrapper before any tool call; harness re-runs both)"
  req lock "$LOCK held nonblocking by pid $$"
  req harness_ceiling_s "$HARNESS_CEILING"
  req cpu "$(nproc)"; req mem_total_kb "$(awk '/MemTotal/{print $2}' /proc/meminfo)"; req disk_free "$(df -h "$ROOT" | awk 'NR==2{print $4}')"
  req command "timeout --foreground $HARNESS_CEILING bash test/db/s1-rls-close-public-exposure.sh $DBNAME"
  req detail_log "$DETAIL"
  echo "== harness output"
} > "$LOGF"

# ---- 5. run: outer bounded timeout, real exit preserved, no -k kill masking ---
set +e
S1_PROOF_LOG="$DETAIL" timeout --foreground "$HARNESS_CEILING" bash test/db/s1-rls-close-public-exposure.sh "$DBNAME" 2>&1 | tee -a "$LOGF"
RC=${PIPESTATUS[0]}
set -e
{
  echo "== end"
  echo "harness_exit_code=$RC"
  [ "$RC" -eq 124 ] && echo "harness_result=TIMEOUT (outer ceiling ${HARNESS_CEILING}s reached; NOT a pass, NOT a harness verdict)"
  echo "end_utc=$(date -u +%FT%TZ)"
  echo "head_after=$(git rev-parse HEAD) clean_after=$([ -z "$(git status --porcelain --untracked-files=all)" ] && echo yes || echo NO)"
  echo "log_sha256=$(sha256sum "$DETAIL" 2>/dev/null | cut -c1-64 || echo none)"
} | tee -a "$LOGF"
exit "$RC"
