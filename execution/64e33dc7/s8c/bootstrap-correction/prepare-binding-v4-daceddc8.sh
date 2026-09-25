#!/usr/bin/env bash
# S8C_BOOTSTRAP_MINIMUM_CORRECTION_GRANT: derive binding/v4 from the frozen v3 bytes and the CLEAN COMMITTED head.
# Source-side derivations/checks only; never runs the driver, fixture, bootstrap, generator or any test.
# EXEC-DACEDDC8 derivation (daceddc8/SCOPE.md S8C-BC-2): identical to the frozen prepare-binding-v4.sh (2c6f01c3…) except the
# recorded enumeration reconsideration: other-lane loops also enumerate proof-v4/clusters/*/ (sibling S7-L v4 lane).
# Usage: prepare-binding-v4-daceddc8.sh <committed-head-sha>   (refuses uncommitted/dirty trees and an existing v4)
set -euo pipefail
S=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c; V3=$S/binding/v3; V4=$S/binding/v4
W=/home/user/workspace/worktrees/64e33dc7-s8c; RR=/home/user/workspace/execution/64e33dc7/recovery-reset
PARENT=87018a421f5be1064767d2cdd32e75ca935f7cdb; H=${1:?committed head}
[ -e "$V4" ] && { echo "REFUSED: $V4 exists (never overwrite a binding version)" >&2; exit 1; }
cd "$W"; [ "$(git rev-parse HEAD)" = "$H" ] || { echo "REFUSED: HEAD != $H" >&2; exit 1; }
[ "$(git rev-parse HEAD^)" = "$PARENT" ] || { echo "REFUSED: parent != $PARENT" >&2; exit 1; }
[ -z "$(git status --porcelain --untracked-files=all)" ] || { echo "REFUSED: dirty tree" >&2; exit 1; }
[ "$(git diff-tree --no-commit-id -r --name-only "$PARENT" "$H")" = "test/utils/g2-s8c-bootstrap.sh" ] || { echo "REFUSED: delta is not exactly the one file" >&2; exit 1; }
(cd "$V3" && sha256sum -c --quiet BINDING.sha256) || { echo "REFUSED: v3 manifest broken" >&2; exit 1; }
T=$(git rev-parse 'HEAD^{tree}'); BOOT=$(git rev-parse HEAD:test/utils/g2-s8c-bootstrap.sh)
OLD_BOOT=$(grep -oE '^EXPECT_BOOTSTRAP_BLOB=[0-9a-f]{40}' "$V3/s8c-pg-proof.sh" | cut -d= -f2)
mkdir -p "$V4"; cp -p "$V3/s8c-pg-proof.sh" "$V4/s8c-pg-proof.sh.v3"; cp -p "$V3/s8c-fixture.sh" "$V4/s8c-fixture.sh.v3"; cp -p "$V3/PINS.txt" "$V4/PINS.txt.v3"
cp -p "$V3/s8c-pg-proof.sh" "$V4/s8c-pg-proof.sh"; cp -p "$V3/s8c-fixture.sh" "$V4/s8c-fixture.sh"; cp -p "$V3/PINS.txt" "$V4/PINS.txt"; cp -p "$V3/README.md" "$V4/README.md"
# ---- fixture: lane/socket path constants + directly associated comments only
sed -i -e 's|^LANE=\$RUNTIME_ROOT/clusters/s8-c$|LANE=$RUNTIME_ROOT/proof-v4/clusters/s8-c|' \
       -e 's|^DATA=\$LANE/pg-data; LOG=\$LANE/pg.log; SOCK=\$RUNTIME_ROOT/run/s8-c$|DATA=$LANE/pg-data; LOG=$LANE/pg.log; SOCK=$RUNTIME_ROOT/proof-v4/run/s8-c|' \
       -e 's|recovery-reset/pg17/dist; data and socket directories under recovery-reset/clusters/s8-c and|recovery-reset/pg17/dist; data and socket directories under recovery-reset/proof-v4/clusters/s8-c and|' \
       -e 's|#     recovery-reset/run/s8-c — never pg17/dist as a data root, never the historical /home/user/pg17 paths.|#     recovery-reset/proof-v4/run/s8-c (fresh v4 lane; the failed v3 lane clusters/s8-c is retained, never adopted)\n#     — never pg17/dist as a data root, never the historical /home/user/pg17 paths.|' "$V4/s8c-fixture.sh"
FIX=$(sha256sum "$V4/s8c-fixture.sh" | cut -c1-64)
# ---- driver: v4 paths, head/tree/bootstrap-blob/fixture pins, fresh lane/socket, actual-path lane exclusion + proof-v3 glob
#      (exact-string replacements with asserted counts; python used only as a literal text editor)
V4="$V4" S="$S" H="$H" T="$T" BOOT="$BOOT" OLD_BOOT="$OLD_BOOT" FIX="$FIX" PARENT="$PARENT" python3 - <<'PY'
import os
e=os.environ; p=e['V4']+'/s8c-pg-proof.sh'; s=open(p).read()
def rep(a,b,n=1):
    global s; assert s.count(a)==n, (a[:70], s.count(a)); s=s.replace(a,b)
rep("D=%s/binding/v3\n"%e['S'], "D=%s/binding/v4\n"%e['S'])
rep("EXPECT_HEAD=%s\n"%e['PARENT'], "EXPECT_HEAD=%s\n"%e['H'])
rep("EXPECT_TREE=cec7d05a91876ec3f6badb1020bb97aacdb9331d\n", "EXPECT_TREE=%s\n"%e['T'])
rep("EXPECT_BOOTSTRAP_BLOB=%s "%e['OLD_BOOT'], "EXPECT_BOOTSTRAP_BLOB=%s "%e['BOOT'])
rep("EXPECT_FIXTURE_SHA=1a7faa5ff4a4937216c329fa8ce810f559085c7ca8f9295c15f9e7a57c0a07b3", "EXPECT_FIXTURE_SHA=%s"%e['FIX'])
rep('DIST=$RUNTIME_ROOT/pg17/dist; CLUSTERS=$RUNTIME_ROOT/clusters; LANE=$CLUSTERS/s8-c; SOCK=$RUNTIME_ROOT/run/s8-c\n',
    'DIST=$RUNTIME_ROOT/pg17/dist; CLUSTERS=$RUNTIME_ROOT/clusters; LANE=$RUNTIME_ROOT/proof-v4/clusters/s8-c; SOCK=$RUNTIME_ROOT/proof-v4/run/s8-c\n'
    '# fresh v4 lane; retained clusters/s8-c (failed v3 run) proof-v3/clusters/* and proof-v4/clusters/* other than this lane (S7-L) are other lanes: never adopted, hashed pre/post\n')
rep('for d in "$CLUSTERS"/*/; do [ -d "$d" ] || continue; n=$(basename "$d"); [ "$n" != s8-c ] || continue\n',
    'for d in "$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-v3/clusters/*/ "$RUNTIME_ROOT"/proof-v4/clusters/*/; do [ -d "$d" ] || continue; [ "${d%/}" != "$LANE" ] || continue; n=${d#$RUNTIME_ROOT/}; n=${n%/}\n', 2)
open(p,'w').write(s)
PY
sed -i -e "s|binding/v3)|binding/v4)|" -e "s|^EXPECT_HEAD=$PARENT|EXPECT_HEAD=$H|" -e "s|^EXPECT_TREE=cec7d05a91876ec3f6badb1020bb97aacdb9331d|EXPECT_TREE=$T|" \
       -e "s|^EXPECT_BOOTSTRAP_BLOB=$OLD_BOOT|EXPECT_BOOTSTRAP_BLOB=$BOOT|" -e "s|^\(EXPECT_FIXTURE_SHA=\)[0-9a-f]\{64\}|\1$FIX|" -e "s|s8c/binding/v3/run/|s8c/binding/v4/run/|" "$V4/PINS.txt"
{ echo; echo "## v4 (bootstrap correction, S8C_BOOTSTRAP_MINIMUM_CORRECTION_GRANT)"; echo "Fresh lane \`recovery-reset/proof-v4/clusters/s8-c\` and socket \`proof-v4/run/s8-c\`; head $H (parent $PARENT, one-file bootstrap delta). The failed v3 run, its sentinel and lane \`clusters/s8-c\` are retained, never adopted; both other-lane loops now exclude the own lane by actual path and also enumerate \`proof-v3/clusters/*/\` and \`proof-v4/clusters/*/\` (EXEC-DACEDDC8 enumeration reconsideration)."; } >> "$V4/README.md"
bash -n "$V4/s8c-pg-proof.sh"; bash -n "$V4/s8c-fixture.sh"
diff -u "$V4/s8c-pg-proof.sh.v3" "$V4/s8c-pg-proof.sh" > "$V4/s8c-pg-proof.sh.diff-v3-to-v4" || true
diff -u "$V4/s8c-fixture.sh.v3" "$V4/s8c-fixture.sh" > "$V4/s8c-fixture.sh.diff-v3-to-v4" || true
diff -u "$V4/PINS.txt.v3" "$V4/PINS.txt" > "$V4/PINS.txt.diff-v3-to-v4" || true
# ---- checks: pins derived from the head; other pins unchanged; loops rewritten in both places; no placeholders
for pair in SPEC:test/rls-g2-s8c.spec.ts BOOTSTRAP:test/utils/g2-s8c-bootstrap.sh DB:test/utils/g2-s8c-db.ts PGH:test/utils/g2-s8c-pg-harness.ts HARNESS:test/utils/g2-s8c-harness.ts WORKER:test/utils/g2-s8c-worker.cjs; do
  v=${pair%%:*}; f=${pair#*:}; [ "$(grep -oE "^EXPECT_${v}_BLOB=[0-9a-f]{40}" "$V4/s8c-pg-proof.sh" | cut -d= -f2)" = "$(git rev-parse HEAD:$f)" ] || { echo "PIN_MISMATCH $v" >&2; exit 1; }; done
grep -E '^EXPECT_(POSTGRES|INITDB|PGCTL|PSQL|NODE|NM_LOCK|NM_CLIENT|SCHEMA|PKG_LOCK)_SHA=|^BASE_(HEAD|TREE)=|^EXPECT_(SPEC|DB|PGH|HARNESS|WORKER)_BLOB=' "$V4/s8c-pg-proof.sh" \
  | diff - <(grep -E '^EXPECT_(POSTGRES|INITDB|PGCTL|PSQL|NODE|NM_LOCK|NM_CLIENT|SCHEMA|PKG_LOCK)_SHA=|^BASE_(HEAD|TREE)=|^EXPECT_(SPEC|DB|PGH|HARNESS|WORKER)_BLOB=' "$V3/s8c-pg-proof.sh") || { echo "UNCHANGED_PINS_DRIFTED" >&2; exit 1; }
[ "$(grep -cF 'for d in "$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-v3/clusters/*/ "$RUNTIME_ROOT"/proof-v4/clusters/*/; do [ -d "$d" ] || continue; [ "${d%/}" != "$LANE" ] || continue; n=${d#$RUNTIME_ROOT/}; n=${n%/}' "$V4/s8c-pg-proof.sh" || true)" = 2 ] || { echo "LOOP_REWRITE_COUNT != 2" >&2; exit 1; }
[ "$(grep -c 'basename' "$V4/s8c-pg-proof.sh" || true)" = 0 ] || { echo "basename exclusion remains" >&2; exit 1; }
[ "$(grep -c 'CLUSTERS=\$RUNTIME_ROOT/clusters;' "$V4/s8c-pg-proof.sh" || true)" = 1 ] || { echo "CLUSTERS constant changed" >&2; exit 1; }
[ "$(grep -c __FILL "$V4/s8c-pg-proof.sh" || true)" = 0 ] || { echo "placeholders remain" >&2; exit 1; }
[ "$(grep -c 'proof-v4' "$V4/s8c-pg-proof.sh" || true)" -ge 1 ] && [ "$(grep -c 'proof-v4' "$V4/s8c-fixture.sh" || true)" -ge 2 ] || { echo "fresh paths missing" >&2; exit 1; }
[ "$(grep -oE '^EXPECT_FIXTURE_SHA=[0-9a-f]{64}' "$V4/s8c-pg-proof.sh" | cut -d= -f2)" = "$FIX" ] || { echo "fixture pin not derived" >&2; exit 1; }
(cd "$V4" && sha256sum s8c-pg-proof.sh s8c-fixture.sh PINS.txt README.md s8c-pg-proof.sh.v3 s8c-fixture.sh.v3 PINS.txt.v3 s8c-pg-proof.sh.diff-v3-to-v4 s8c-fixture.sh.diff-v3-to-v4 PINS.txt.diff-v3-to-v4 > BINDING.sha256)
echo "V4_FILLED head=$H tree=$T bootstrap_blob=$BOOT fixture=$FIX driver=$(sha256sum "$V4/s8c-pg-proof.sh" | cut -c1-64) manifest=$(sha256sum "$V4/BINDING.sha256" | cut -c1-64)" | tee "$V4/prepare-binding-v4.log"
cat "$V4/BINDING.sha256" | tee -a "$V4/prepare-binding-v4.log"
