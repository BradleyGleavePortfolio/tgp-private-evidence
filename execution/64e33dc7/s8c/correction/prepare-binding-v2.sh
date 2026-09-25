#!/usr/bin/env bash
# S8C_MAPPING_EXPECTATION_CORRECTION_GRANT — v2 filled binding. Lock-free, source-only; executes nothing.
# Copies the original filled binding (unchanged) to s8c/binding/v2/ and changes ONLY: EXPECT_HEAD, EXPECT_TREE, and the
# mechanical binding directory path (D=.../binding -> .../binding/v2, so run/ receipts land under v2/run). Six proof blobs,
# BASE_HEAD/BASE_TREE, tool pins, fixture and execution behaviour must be byte-identical; verified against the new head.
set -euo pipefail
S=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c; D=$S/binding; V=$D/v2; W=/home/user/workspace/worktrees/64e33dc7-s8c
PARENT=527fe2bc24f954b26c0485c90345f237ce39a09d
[ ! -e "$V" ] || { echo "REFUSED: $V exists (no overwrite)"; exit 70; }
cd "$W"; HEAD=$(git rev-parse HEAD); TREE=$(git rev-parse 'HEAD^{tree}')
[ "$HEAD" != "$PARENT" ] || { echo "REFUSED: correction commit not yet made (HEAD is $PARENT)"; exit 70; }
[ "$(git rev-parse HEAD^)" = "$PARENT" ] || { echo "REFUSED: HEAD parent is not $PARENT"; exit 70; }
[ -z "$(git status --porcelain --untracked-files=all)" ] || { echo "REFUSED: dirty worktree"; exit 70; }
[ "$(git log -1 --format='%an <%ae>|%cn <%ce>')" = 'Bradley Gleave <bradley@bradleytgpcoaching.com>|Bradley Gleave <bradley@bradleytgpcoaching.com>' ] || { echo "REFUSED: identity"; exit 70; }
[ "$(git diff-tree --no-commit-id -r --name-only "$PARENT" "$HEAD")" = "test/scout/reconstruct/mapping-spec.spec.ts" ] || { echo "REFUSED: follow-up touches more than the one test"; exit 70; }
# six proof blobs must be unchanged between 527fe2bc and the new head
for f in test/rls-g2-s8c.spec.ts test/utils/g2-s8c-bootstrap.sh test/utils/g2-s8c-db.ts test/utils/g2-s8c-pg-harness.ts test/utils/g2-s8c-harness.ts test/utils/g2-s8c-worker.cjs; do
  [ "$(git rev-parse "$PARENT:$f")" = "$(git rev-parse "$HEAD:$f")" ] || { echo "REFUSED: proof blob changed: $f"; exit 70; }
done
mkdir -p "$V"; cp -p "$D/s8c-pg-proof.sh" "$D/s8c-fixture.sh" "$D/PINS.txt" "$D/README.md" "$V/"
cp -p "$D/s8c-pg-proof.sh" "$V/s8c-pg-proof.sh.v1"
sed -i -e "s|^EXPECT_HEAD=$PARENT|EXPECT_HEAD=$HEAD|" -e "s|^EXPECT_TREE=d87a96267c2ec4f4d79d83d26e6b2928a56c8a85|EXPECT_TREE=$TREE|" \
       -e "s|^D=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c/binding$|D=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c/binding/v2|" "$V/s8c-pg-proof.sh"
sed -i -e "s|^EXPECT_HEAD=$PARENT|EXPECT_HEAD=$HEAD|" -e "s|^EXPECT_TREE=d87a96267c2ec4f4d79d83d26e6b2928a56c8a85|EXPECT_TREE=$TREE|" \
       -e "s|execution/64e33dc7/s8c/binding)|execution/64e33dc7/s8c/binding/v2)|" -e "s|execution/64e33dc7/s8c/binding/run/|execution/64e33dc7/s8c/binding/v2/run/|" "$V/PINS.txt"
diff -u "$V/s8c-pg-proof.sh.v1" "$V/s8c-pg-proof.sh" > "$V/s8c-pg-proof.sh.diff-v1-to-v2" || true
diff -u "$D/PINS.txt" "$V/PINS.txt" > "$V/PINS.txt.diff-v1-to-v2" || true
# exactly three changed lines in the runner (EXPECT_HEAD, EXPECT_TREE, D=); the fixture is byte-identical (fixture pin unchanged)
n=$(grep -c '^-[^-]' "$V/s8c-pg-proof.sh.diff-v1-to-v2"); [ "$n" -eq 3 ] || { echo "REFUSED: runner delta has $n removed lines, expected 3"; exit 70; }
grep -q "^+EXPECT_HEAD=$HEAD" "$V/s8c-pg-proof.sh.diff-v1-to-v2"; grep -q "^+EXPECT_TREE=$TREE" "$V/s8c-pg-proof.sh.diff-v1-to-v2"; grep -q '^+D=.*/binding/v2$' "$V/s8c-pg-proof.sh.diff-v1-to-v2"
cmp "$D/s8c-fixture.sh" "$V/s8c-fixture.sh"; [ "$(sha256sum "$V/s8c-fixture.sh" | cut -c1-64)" = "$(grep -oE '^EXPECT_FIXTURE_SHA=[0-9a-f]{64}' "$V/s8c-pg-proof.sh" | cut -d= -f2)" ]
[ "$(grep -c "__FILL_AFTER_ATTESTATION__" "$V/s8c-pg-proof.sh" || true)" = 0 ]  # grep -c exits 1 on zero count; first run tripped set -e here (recorded)
( cd "$V" && sha256sum s8c-pg-proof.sh s8c-pg-proof.sh.v1 s8c-pg-proof.sh.diff-v1-to-v2 s8c-fixture.sh PINS.txt PINS.txt.diff-v1-to-v2 README.md > BINDING.sha256 )
{ echo "V2_FILLED head=$HEAD tree=$TREE parent=$PARENT fixture=$(sha256sum "$V/s8c-fixture.sh" | cut -c1-64) original_binding_untouched=$(cd "$D" && sha256sum -c --quiet BINDING.sha256 && echo yes)"; cat "$V/BINDING.sha256"; } | tee "$V/prepare-binding-v2.log"
