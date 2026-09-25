#!/usr/bin/env bash
# S8-C binding pin fill (authorized preparation, NOT a PG run; parent mail 2026-09-24 21:24 PDT). Read-only against the
# worktree: derives the nine head pins from the COMMITTED head, refuses a dirty tree or the base, re-verifies the tool pins
# by sha256 (reports mismatches; never edits them), writes the filled runner, keeps the unfilled template, records the
# template->filled diff and hashes. Runs nothing else. Usage: bash fill-pins.sh
set -euo pipefail
D=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c/binding
W=/home/user/workspace/worktrees/64e33dc7-s8c
RUNTIME_ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset
BASE=93389265a846095b846fa8f1fb0dad782fb6ee9f
T=$D/s8c-pg-proof.sh
[ -e "$D/s8c-pg-proof.sh.unfilled" ] && { echo "REFUSED: already filled ($D/s8c-pg-proof.sh.unfilled exists); a re-fill is a new binding version, not an overwrite" >&2; exit 76; }
grep -q '__FILL_AFTER_ATTESTATION__' "$T" || { echo "REFUSED: runner has no placeholders" >&2; exit 76; }
HEAD=$(git -C "$W" rev-parse HEAD)
[ "$HEAD" != "$BASE" ] || { echo "REFUSED: HEAD is the base; no candidate commit exists" >&2; exit 70; }
[ -z "$(git -C "$W" status --porcelain --untracked-files=all)" ] || { echo "REFUSED: worktree dirty; pins are filled only from a committed, clean head" >&2; exit 70; }
git -C "$W" merge-base --is-ancestor "$BASE" "$HEAD" || { echo "REFUSED: HEAD does not descend from base" >&2; exit 70; }
# the commit must be Bradley-authored and -committed, with no trailers, and made through the lefthook hooks
git -C "$W" log -1 --format='%an <%ae> / %cn <%ce>' | grep -qx 'Bradley Gleave <bradley@bradleytgpcoaching.com> / Bradley Gleave <bradley@bradleytgpcoaching.com>' || { echo "REFUSED: author/committer identity" >&2; exit 70; }
[ -z "$(git -C "$W" log -1 --format=%B | grep -E '^[A-Za-z-]+: ')" ] || { echo "REFUSED: trailer-like line in commit message" >&2; exit 70; }
TREE=$(git -C "$W" rev-parse 'HEAD^{tree}')
b(){ git -C "$W" rev-parse "HEAD:$1"; }
SPEC=$(b test/rls-g2-s8c.spec.ts); BOOT=$(b test/utils/g2-s8c-bootstrap.sh); DB=$(b test/utils/g2-s8c-db.ts)
PGH=$(b test/utils/g2-s8c-pg-harness.ts); HAR=$(b test/utils/g2-s8c-harness.ts); WRK=$(b test/utils/g2-s8c-worker.cjs)
FIXSHA=$(sha256sum "$D/s8c-fixture.sh" | cut -c1-64)
# tool pins: read-only re-verification against the live binaries (report only)
sha(){ sha256sum "$1" | cut -c1-64; }
chk(){ local name=$1 file=$2 exp; exp=$(sed -n "s/^$name=\([0-9a-f]\{64\}\).*/\1/p" "$T"); local act; act=$(sha "$file" 2>/dev/null || echo ABSENT)
  if [ "$act" = "$exp" ]; then echo "TOOL_PIN_OK $name"; else echo "TOOL_PIN_MISMATCH $name expected=$exp actual=$act file=$file"; MISMATCH=1; fi; }
MISMATCH=0
chk EXPECT_POSTGRES_SHA "$RUNTIME_ROOT/pg17/dist/bin/postgres"; chk EXPECT_INITDB_SHA "$RUNTIME_ROOT/pg17/dist/bin/initdb"; chk EXPECT_PGCTL_SHA "$RUNTIME_ROOT/pg17/dist/bin/pg_ctl"
chk EXPECT_PSQL_SHA "$(readlink -f /usr/bin/psql)"; chk EXPECT_NODE_SHA "$(readlink -f "$(command -v node)")"
chk EXPECT_SCHEMA_SHA "$W/prisma/schema.prisma"; chk EXPECT_PKG_LOCK_SHA "$W/package-lock.json"
[ -d "$W/node_modules" ] && { chk EXPECT_NM_LOCK_SHA "$W/node_modules/.package-lock.json"; chk EXPECT_NM_CLIENT_SHA "$W/node_modules/.prisma/client/index.d.ts"; } || echo "TOOL_PIN_DEFERRED node_modules not yet copied into $W (donor copy happens at the source slot); runner re-checks at run time"
cp -p "$T" "$T.unfilled"
sed -i -e "s|^EXPECT_HEAD=__FILL_AFTER_ATTESTATION__|EXPECT_HEAD=$HEAD|" -e "s|^EXPECT_TREE=__FILL_AFTER_ATTESTATION__|EXPECT_TREE=$TREE|" \
  -e "s|^EXPECT_SPEC_BLOB=__FILL_AFTER_ATTESTATION__|EXPECT_SPEC_BLOB=$SPEC|" -e "s|^EXPECT_BOOTSTRAP_BLOB=__FILL_AFTER_ATTESTATION__|EXPECT_BOOTSTRAP_BLOB=$BOOT|" \
  -e "s|^EXPECT_DB_BLOB=__FILL_AFTER_ATTESTATION__|EXPECT_DB_BLOB=$DB|" -e "s|^EXPECT_PGH_BLOB=__FILL_AFTER_ATTESTATION__|EXPECT_PGH_BLOB=$PGH|" \
  -e "s|^EXPECT_HARNESS_BLOB=__FILL_AFTER_ATTESTATION__|EXPECT_HARNESS_BLOB=$HAR|" -e "s|^EXPECT_WORKER_BLOB=__FILL_AFTER_ATTESTATION__|EXPECT_WORKER_BLOB=$WRK|" \
  -e "s|^EXPECT_FIXTURE_SHA=__FILL_AFTER_ATTESTATION__|EXPECT_FIXTURE_SHA=$FIXSHA|" "$T"
grep -q '__FILL_AFTER_ATTESTATION__' "$T" && { echo "FILL_INCOMPLETE: placeholders remain" >&2; exit 72; }
sed -i -e "s|^EXPECT_HEAD=__FILL_AFTER_ATTESTATION__|EXPECT_HEAD=$HEAD|" -e "s|^EXPECT_TREE=__FILL_AFTER_ATTESTATION__|EXPECT_TREE=$TREE|" \
  -e "s|^EXPECT_SPEC_BLOB=__FILL_AFTER_ATTESTATION__|EXPECT_SPEC_BLOB=$SPEC|" -e "s|^EXPECT_BOOTSTRAP_BLOB=__FILL_AFTER_ATTESTATION__|EXPECT_BOOTSTRAP_BLOB=$BOOT|" \
  -e "s|^EXPECT_DB_BLOB=__FILL_AFTER_ATTESTATION__|EXPECT_DB_BLOB=$DB|" -e "s|^EXPECT_PGH_BLOB=__FILL_AFTER_ATTESTATION__|EXPECT_PGH_BLOB=$PGH|" \
  -e "s|^EXPECT_HARNESS_BLOB=__FILL_AFTER_ATTESTATION__|EXPECT_HARNESS_BLOB=$HAR|" -e "s|^EXPECT_WORKER_BLOB=__FILL_AFTER_ATTESTATION__|EXPECT_WORKER_BLOB=$WRK|" \
  -e "s|^EXPECT_FIXTURE_SHA=__FILL_AFTER_ATTESTATION__|EXPECT_FIXTURE_SHA=$FIXSHA|" "$D/PINS.txt"
bash -n "$T"
diff -u "$T.unfilled" "$T" > "$D/s8c-pg-proof.sh.diff-unfilled-to-filled" || true
( cd "$D" && sha256sum s8c-pg-proof.sh s8c-pg-proof.sh.unfilled s8c-pg-proof.sh.diff-unfilled-to-filled s8c-fixture.sh PINS.txt README.md fill-pins.sh > BINDING.sha256 )
echo "FILLED head=$HEAD tree=$TREE fixture=$FIXSHA tool_pin_mismatch=$MISMATCH"; cat "$D/BINDING.sha256"
echo "NEXT: dual independent review of head $HEAD + BINDING.sha256; execution only under a separate grant."
