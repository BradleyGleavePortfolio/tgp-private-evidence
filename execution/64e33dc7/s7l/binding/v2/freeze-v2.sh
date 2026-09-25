#!/usr/bin/env bash
# S7-L binding v2 freeze (S7L_MINIMUM_CORRECTION_GRANT; source-only preparation, NOT a PG run, needs no slot). Read-only against the worktree: re-derives
# every head pin from the COMMITTED clean head and compares it with the values written in s7l-pg-proof.sh (reports any
# mismatch; never edits a pin to pass), re-verifies the tool pins by sha256 (report only), fills the single fixture-sha
# placeholder, and records BINDING.sha256 (filled runner + fixture + this file). Runs nothing else. Usage: bash freeze.sh
set -euo pipefail
D=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v2
V1=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding
PARENT=839b54c53ccb252f95b4ec63df0b08595bbe7698
W=/home/user/workspace/worktrees/64e33dc7-s7l
RUNTIME_ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset
BASE=93389265a846095b846fa8f1fb0dad782fb6ee9f
T=$D/s7l-pg-proof.sh
[ -e "$D/BINDING.sha256" ] && { echo "REFUSED: already frozen ($D/BINDING.sha256 exists); a re-freeze is a new binding version, not an overwrite" >&2; exit 76; }
HEAD=$(git -C "$W" rev-parse HEAD)
[ "$HEAD" != "$BASE" ] || { echo "REFUSED: HEAD is the base; no candidate commit exists" >&2; exit 70; }
[ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] || { echo "REFUSED: worktree dirty; pins are frozen only from a committed, clean head" >&2; exit 70; }
git -C "$W" merge-base --is-ancestor "$BASE" "$HEAD" || { echo "REFUSED: HEAD does not descend from base" >&2; exit 70; }
[ "$HEAD" != "$PARENT" ] || { echo "REFUSED: HEAD is still the v1 candidate; the follow-up commit does not exist yet" >&2; exit 70; }
[ "$(git -C "$W" rev-parse HEAD^)" = "$PARENT" ] || { echo "REFUSED: HEAD^ != $PARENT (ordinary follow-up on the preserved v1 candidate required; no amend/replace)" >&2; exit 70; }
[ "$(git -C "$W" rev-parse "$PARENT^{tree}")" = f02205c60ad0bfeb24ce82d74b0025ee9a185df6 ] || { echo "REFUSED: v1 candidate tree changed" >&2; exit 70; }
[ "$(git -C "$W" diff --name-only "$PARENT" HEAD | sort | tr '\n' ' ')" = "src/scout/lifecycle/lifecycle.service.ts test/rls-g2-s7l.spec.ts test/scout/lifecycle/lifecycle.service.spec.ts " ] \
  || { echo "REFUSED: follow-up delta is not exactly the three granted paths" >&2; exit 70; }
cmp -s "$V1/s7l-fixture.sh" "$D/s7l-fixture.sh" || { echo "REFUSED: v2 fixture is not byte-identical to v1" >&2; exit 70; }
[ -e "$V1/BINDING.sha256" ] && ( cd "$V1" && sha256sum -c --quiet BINDING.sha256 ) || { echo "REFUSED: v1 binding missing or altered" >&2; exit 70; }
git -C "$W" log -1 --format='%an <%ae> / %cn <%ce>' | grep -qx 'Bradley Gleave <bradley@bradleytgpcoaching.com> / Bradley Gleave <bradley@bradleytgpcoaching.com>' || { echo "REFUSED: author/committer identity" >&2; exit 70; }
# trailers = git's own trailer block parse (the conventional 'scout: ...' subject is not a trailer)
[ -z "$(git -C "$W" log -1 --format=%B | git interpret-trailers --parse --only-trailers)" ] || { echo "REFUSED: trailer block present in commit message" >&2; exit 70; }
b(){ git -C "$W" rev-parse "HEAD:$1"; }
pin(){ sed -n "s/^$1=\([0-9a-f]\{40,64\}\).*/\1/p" "$T"; }
MISMATCH=0
cmp_pin(){ local name=$1 exp=$2 act; act=$(pin "$name"); if [ "$act" = "$exp" ]; then echo "HEAD_PIN_OK $name=$exp"; else echo "HEAD_PIN_MISMATCH $name written=$act derived=$exp"; MISMATCH=1; fi; }
cmp_pin EXPECT_PARENT "$PARENT"
fill(){ sed -i "s|^$1=__FILL_AFTER_FOLLOWUP_COMMIT__|$1=$2|" "$T"; }
fill EXPECT_HEAD "$HEAD"; fill EXPECT_TREE "$(git -C "$W" rev-parse 'HEAD^{tree}')"; fill EXPECT_SPEC_BLOB "$(b test/rls-g2-s7l.spec.ts)"
cmp_pin EXPECT_HEAD "$HEAD"
cmp_pin EXPECT_TREE "$(git -C "$W" rev-parse 'HEAD^{tree}')"
cmp_pin BASE_TREE "$(git -C "$W" rev-parse "$BASE^{tree}")"
cmp_pin EXPECT_SPEC_BLOB "$(b test/rls-g2-s7l.spec.ts)"
cmp_pin EXPECT_BOOTSTRAP_BLOB "$(b test/utils/g2-s7l-bootstrap.sh)"
cmp_pin EXPECT_OLDROOT_BLOB "$(b test/utils/g2-s7l-old-root.sh)"
cmp_pin EXPECT_DB_BLOB "$(b test/utils/g2-s7l-db.ts)"
cmp_pin EXPECT_PGH_BLOB "$(b test/utils/g2-s7l-pg-harness.ts)"
cmp_pin EXPECT_HARNESS_BLOB "$(b test/utils/g2-s7l-harness.ts)"
cmp_pin EXPECT_WORKER_BLOB "$(b test/utils/g2-s7l-worker.cjs)"
cmp_pin EXPECT_GUARD_BLOB "$(b test/scout/g2-s7l-db-guard.spec.ts)"
cmp_pin EXPECT_MIGRATION_TREE "$(b prisma/migrations/20270123000000_scout_run_lifecycle_expand)"
cmp_pin EXPECT_SCHEMA_BLOB "$(b prisma/schema.prisma)"
sha(){ sha256sum "$1" | cut -c1-64; }
chk(){ local name=$1 file=$2 exp act; exp=$(pin "$name"); act=$(sha "$file" 2>/dev/null || echo ABSENT)
  if [ "$act" = "$exp" ]; then echo "TOOL_PIN_OK $name"; else echo "TOOL_PIN_MISMATCH $name expected=$exp actual=$act file=$file"; MISMATCH=1; fi; }
chk EXPECT_POSTGRES_SHA "$RUNTIME_ROOT/pg17/dist/bin/postgres"; chk EXPECT_INITDB_SHA "$RUNTIME_ROOT/pg17/dist/bin/initdb"; chk EXPECT_PGCTL_SHA "$RUNTIME_ROOT/pg17/dist/bin/pg_ctl"
chk EXPECT_PSQL_SHA "$(readlink -f /usr/bin/psql)"; chk EXPECT_NODE_SHA "$(readlink -f "$(command -v node)")"
chk EXPECT_SCHEMA_SHA "$W/prisma/schema.prisma"; chk EXPECT_PKG_LOCK_SHA "$W/package-lock.json"; chk EXPECT_JEST_RLS_CFG_SHA "$W/jest.rls.config.js"
chk EXPECT_NM_LOCK_SHA "$W/node_modules/.package-lock.json"; chk EXPECT_NM_CLIENT_SHA "$W/node_modules/.prisma/client/index.d.ts"
[ "$MISMATCH" = 0 ] || { echo "REFUSED: pin mismatch above; nothing written (fix the pin source or report, never edit to pass)" >&2; exit 71; }
FIXSHA=$(sha "$D/s7l-fixture.sh")
if grep -q '^EXPECT_FIXTURE_SHA=__FILLED_BY_FREEZE__' "$T"; then
  sed -i "s|^EXPECT_FIXTURE_SHA=__FILLED_BY_FREEZE__|EXPECT_FIXTURE_SHA=$FIXSHA|" "$T"
else
  # placeholder already consumed (an earlier freeze pass filled it before being refused later): accept only if it equals the live fixture
  [ "$(pin EXPECT_FIXTURE_SHA)" = "$FIXSHA" ] || { echo "REFUSED: EXPECT_FIXTURE_SHA=$(pin EXPECT_FIXTURE_SHA) != live fixture $FIXSHA" >&2; exit 76; }
fi
! grep -q '__FILL' "$T" || { echo "REFUSED: placeholders remain" >&2; exit 76; }
bash -n "$T" && bash -n "$D/s7l-fixture.sh"
{ echo "# S7-L PG proof binding v2, frozen $(date -u +%FT%TZ) against head $HEAD (source-only; NOT RUN; no PG granted)"
  ( cd "$D" && sha256sum s7l-pg-proof.sh s7l-fixture.sh freeze-v2.sh PINS.txt README.md DELTA-v1-to-v2.md ); } > "$D/BINDING.sha256"
cat "$D/BINDING.sha256"; echo "FROZEN_V2 head=$HEAD parent=$PARENT fixture_sha=$FIXSHA"
