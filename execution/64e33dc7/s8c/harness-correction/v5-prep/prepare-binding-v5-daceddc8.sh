#!/usr/bin/env bash
# S8C-BC-5: derive binding/v5 from the frozen v4 bytes and the CLEAN COMMITTED final head (harness + spec corrections).
# Source-side derivations/checks only; never runs the driver, fixture, bootstrap, generator or any test.
# Mechanical v4->v5: binding dir, head/tree pins, changed-blob pins (SPEC, HARNESS; BOOTSTRAP unchanged since e0cee7e0),
# fixture pin, fresh proof-v5 lane/socket paths, other-lane loops also enumerate proof-v5/clusters/*/, PINS.txt L57 lane line
# fixed in this fill step (documentary line previously left at the v3 paths; class C in v4).
# Usage: prepare-binding-v5-daceddc8.sh <committed-head-sha>   (refuses dirty trees, wrong lineage and an existing v5)
set -euo pipefail
S=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c; V4=$S/binding/v4; V5=$S/binding/v5
W=/home/user/workspace/worktrees/64e33dc7-s8c
P0=87018a421f5be1064767d2cdd32e75ca935f7cdb; P1=e0cee7e04bef88811310f6dde1fd921f45d103ad; H=${1:?committed head}
[ -e "$V5" ] && { echo "REFUSED: $V5 exists (never overwrite a binding version)" >&2; exit 1; }
cd "$W"; [ "$(git rev-parse HEAD)" = "$H" ] || { echo "REFUSED: HEAD != $H" >&2; exit 1; }
[ "$(git rev-parse HEAD~3)" = "$P1" ] && [ "$(git rev-parse HEAD~4)" = "$P0" ] || { echo "REFUSED: lineage" >&2; exit 1; }
[ -z "$(git status --porcelain --untracked-files=all)" ] || { echo "REFUSED: dirty tree" >&2; exit 1; }
[ "$(git diff-tree --no-commit-id -r --name-only "$P1" "$H" | sort | tr '\n' ' ')" = "test/rls-g2-s8c.spec.ts test/utils/g2-s8c-harness.ts " ] || { echo "REFUSED: delta from e0cee7e0 is not exactly spec+harness" >&2; exit 1; }
(cd "$V4" && sha256sum -c --quiet BINDING.sha256) || { echo "REFUSED: v4 manifest broken" >&2; exit 1; }
T=$(git rev-parse 'HEAD^{tree}'); SPEC=$(git rev-parse HEAD:test/rls-g2-s8c.spec.ts); HARN=$(git rev-parse HEAD:test/utils/g2-s8c-harness.ts); BOOT=$(git rev-parse HEAD:test/utils/g2-s8c-bootstrap.sh)
OLD_SPEC=$(grep -oE '^EXPECT_SPEC_BLOB=[0-9a-f]{40}' "$V4/s8c-pg-proof.sh" | cut -d= -f2); OLD_HARN=$(grep -oE '^EXPECT_HARNESS_BLOB=[0-9a-f]{40}' "$V4/s8c-pg-proof.sh" | cut -d= -f2)
OLD_FIX=$(grep -oE '^EXPECT_FIXTURE_SHA=[0-9a-f]{64}' "$V4/s8c-pg-proof.sh" | cut -d= -f2)
[ "$(grep -oE '^EXPECT_BOOTSTRAP_BLOB=[0-9a-f]{40}' "$V4/s8c-pg-proof.sh" | cut -d= -f2)" = "$BOOT" ] || { echo "REFUSED: bootstrap blob changed since v4" >&2; exit 1; }
mkdir -p "$V5"; for f in s8c-pg-proof.sh s8c-fixture.sh PINS.txt; do cp -p "$V4/$f" "$V5/$f.v4"; cp -p "$V4/$f" "$V5/$f"; done; cp -p "$V4/README.md" "$V5/README.md"
# ---- fixture: lane/socket path constants + directly associated comments only
sed -i -e 's|^LANE=\$RUNTIME_ROOT/proof-v4/clusters/s8-c$|LANE=$RUNTIME_ROOT/proof-v5/clusters/s8-c|' \
       -e 's|^DATA=\$LANE/pg-data; LOG=\$LANE/pg.log; SOCK=\$RUNTIME_ROOT/proof-v4/run/s8-c$|DATA=$LANE/pg-data; LOG=$LANE/pg.log; SOCK=$RUNTIME_ROOT/proof-v5/run/s8-c|' \
       -e 's|data and socket directories under recovery-reset/proof-v4/clusters/s8-c and|data and socket directories under recovery-reset/proof-v5/clusters/s8-c and|' \
       -e 's|#     recovery-reset/proof-v4/run/s8-c (fresh v4 lane; the failed v3 lane clusters/s8-c is retained, never adopted)|#     recovery-reset/proof-v5/run/s8-c (fresh v5 lane; the failed v3 lane clusters/s8-c and the failed v4 lane proof-v4/clusters/s8-c are retained, never adopted)|' "$V5/s8c-fixture.sh"
FIX=$(sha256sum "$V5/s8c-fixture.sh" | cut -c1-64)
# ---- driver: exact-string replacements with asserted counts (python used only as a literal text editor)
V5="$V5" S="$S" H="$H" T="$T" P1="$P1" SPEC="$SPEC" HARN="$HARN" OLD_SPEC="$OLD_SPEC" OLD_HARN="$OLD_HARN" FIX="$FIX" OLD_FIX="$OLD_FIX" python3 - <<'PY'
import os
e=os.environ; p=e['V5']+'/s8c-pg-proof.sh'; s=open(p).read()
def rep(a,b,n=1):
    global s; assert s.count(a)==n, (a[:70], s.count(a)); s=s.replace(a,b)
rep("D=%s/binding/v4\n"%e['S'], "D=%s/binding/v5\n"%e['S'])
rep("EXPECT_HEAD=%s\n"%e['P1'], "EXPECT_HEAD=%s\n"%e['H'])
rep("EXPECT_TREE=b249efb66e22f4c13529f255f3510d4a81314a99\n", "EXPECT_TREE=%s\n"%e['T'])
rep("EXPECT_SPEC_BLOB=%s "%e['OLD_SPEC'], "EXPECT_SPEC_BLOB=%s "%e['SPEC'])
rep("EXPECT_HARNESS_BLOB=%s "%e['OLD_HARN'], "EXPECT_HARNESS_BLOB=%s "%e['HARN'])
rep("EXPECT_FIXTURE_SHA=%s"%e['OLD_FIX'], "EXPECT_FIXTURE_SHA=%s"%e['FIX'])
rep('LANE=$RUNTIME_ROOT/proof-v4/clusters/s8-c; SOCK=$RUNTIME_ROOT/proof-v4/run/s8-c\n', 'LANE=$RUNTIME_ROOT/proof-v5/clusters/s8-c; SOCK=$RUNTIME_ROOT/proof-v5/run/s8-c\n')
rep('# fresh v4 lane; retained clusters/s8-c (failed v3 run) proof-v3/clusters/* and proof-v4/clusters/* other than this lane (S7-L) are other lanes: never adopted, hashed pre/post\n',
    '# fresh v5 lane; retained clusters/s8-c (failed v3 run), proof-v3/clusters/*, proof-v4/clusters/* (failed S8-C v4 run, S7-L) and proof-v5/clusters/* other than this lane are other lanes: never adopted, hashed pre/post\n')
rep('for d in "$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-v3/clusters/*/ "$RUNTIME_ROOT"/proof-v4/clusters/*/; do',
    'for d in "$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-v3/clusters/*/ "$RUNTIME_ROOT"/proof-v4/clusters/*/ "$RUNTIME_ROOT"/proof-v5/clusters/*/; do', 2)
open(p,'w').write(s)
PY
# ---- PINS.txt: binding dir, head/tree/changed-blob/fixture pins, receipts path, and the documentary lane line (L57) fixed here
sed -i -e "s|binding/v4)|binding/v5)|" -e "s|^EXPECT_HEAD=$P1|EXPECT_HEAD=$H|" -e "s|^EXPECT_TREE=b249efb66e22f4c13529f255f3510d4a81314a99|EXPECT_TREE=$T|" \
       -e "s|^EXPECT_SPEC_BLOB=$OLD_SPEC|EXPECT_SPEC_BLOB=$SPEC|" -e "s|^EXPECT_HARNESS_BLOB=$OLD_HARN|EXPECT_HARNESS_BLOB=$HARN|" \
       -e "s|^\(EXPECT_FIXTURE_SHA=\)[0-9a-f]\{64\}|\1$FIX|" -e "s|s8c/binding/v4/run/|s8c/binding/v5/run/|" \
       -e 's|^DIST=\$RUNTIME_ROOT/pg17/dist  DATA=\$RUNTIME_ROOT/clusters/s8-c/pg-data  SOCK=\$RUNTIME_ROOT/run/s8-c$|DIST=$RUNTIME_ROOT/pg17/dist  DATA=$RUNTIME_ROOT/proof-v5/clusters/s8-c/pg-data  SOCK=$RUNTIME_ROOT/proof-v5/run/s8-c|' "$V5/PINS.txt"
{ echo; echo "## v5 (harness + spec assertion corrections, S8C-BC-3/4/5)"; echo "Fresh lane \`recovery-reset/proof-v5/clusters/s8-c\` and socket \`proof-v5/run/s8-c\`; head $H (lineage e0cee7e0 -> 9cc76401 harness updated_at -> 4d7d4b4e spec jsonAdmin/toBeCloseTo -> $H spec User baseline; bootstrap blob unchanged). The failed v3 and v4 runs, their sentinels and lanes \`clusters/s8-c\` / \`proof-v4/clusters/s8-c\` are retained, never adopted; both other-lane loops also enumerate \`proof-v5/clusters/*/\`. PINS.txt lane line now states the v5 paths (v4 left it at the v3 paths; class C)."; } >> "$V5/README.md"
bash -n "$V5/s8c-pg-proof.sh"; bash -n "$V5/s8c-fixture.sh"
for f in s8c-pg-proof.sh s8c-fixture.sh PINS.txt; do diff -u "$V5/$f.v4" "$V5/$f" > "$V5/$f.diff-v4-to-v5" || true; done
# ---- checks
for pair in SPEC:test/rls-g2-s8c.spec.ts BOOTSTRAP:test/utils/g2-s8c-bootstrap.sh DB:test/utils/g2-s8c-db.ts PGH:test/utils/g2-s8c-pg-harness.ts HARNESS:test/utils/g2-s8c-harness.ts WORKER:test/utils/g2-s8c-worker.cjs; do
  v=${pair%%:*}; f=${pair#*:}; for t in "$V5/s8c-pg-proof.sh" "$V5/PINS.txt"; do [ "$(grep -oE "^EXPECT_${v}_BLOB=[0-9a-f]{40}" "$t" | cut -d= -f2)" = "$(git rev-parse HEAD:$f)" ] || { echo "PIN_MISMATCH $v in $t" >&2; exit 1; }; done; done
for t in "$V5/s8c-pg-proof.sh" "$V5/PINS.txt"; do [ "$(grep -oE '^EXPECT_HEAD=[0-9a-f]{40}' "$t" | cut -d= -f2)" = "$H" ] && [ "$(grep -oE '^EXPECT_TREE=[0-9a-f]{40}' "$t" | cut -d= -f2)" = "$T" ] && [ "$(grep -oE '^EXPECT_FIXTURE_SHA=[0-9a-f]{64}' "$t" | cut -d= -f2)" = "$FIX" ] || { echo "HEAD/TREE/FIXTURE pin not derived in $t" >&2; exit 1; }; done
grep -E '^EXPECT_(POSTGRES|INITDB|PGCTL|PSQL|NODE|NM_LOCK|NM_CLIENT|SCHEMA|PKG_LOCK)_SHA=|^BASE_(HEAD|TREE)=|^EXPECT_(BOOTSTRAP|DB|PGH|WORKER)_BLOB=' "$V5/s8c-pg-proof.sh" \
  | diff - <(grep -E '^EXPECT_(POSTGRES|INITDB|PGCTL|PSQL|NODE|NM_LOCK|NM_CLIENT|SCHEMA|PKG_LOCK)_SHA=|^BASE_(HEAD|TREE)=|^EXPECT_(BOOTSTRAP|DB|PGH|WORKER)_BLOB=' "$V4/s8c-pg-proof.sh") || { echo "UNCHANGED_PINS_DRIFTED" >&2; exit 1; }
[ "$(grep -c 'proof-v5/clusters/\*/; do' "$V5/s8c-pg-proof.sh" || true)" = 2 ] || { echo "LOOP_REWRITE_COUNT != 2" >&2; exit 1; }
[ "$(grep -hv '^#' "$V5/s8c-pg-proof.sh" "$V5/s8c-fixture.sh" | grep -c 'proof-v4/clusters/s8-c\|proof-v4/run/s8-c' || true)" = 0 ] || { echo "v4 lane path remains as own lane (non-comment line)" >&2; exit 1; }
[ "$(grep -c 'proof-v5' "$V5/s8c-fixture.sh" || true)" -ge 3 ] && [ "$(grep -c '^DIST=.*proof-v5/clusters/s8-c/pg-data.*proof-v5/run/s8-c$' "$V5/PINS.txt" || true)" = 1 ] || { echo "fresh paths missing" >&2; exit 1; }
[ "$(grep -c __FILL "$V5/s8c-pg-proof.sh" || true)" = 0 ] || { echo "placeholders remain" >&2; exit 1; }
(cd "$V5" && sha256sum s8c-pg-proof.sh s8c-fixture.sh PINS.txt README.md s8c-pg-proof.sh.v4 s8c-fixture.sh.v4 PINS.txt.v4 s8c-pg-proof.sh.diff-v4-to-v5 s8c-fixture.sh.diff-v4-to-v5 PINS.txt.diff-v4-to-v5 > BINDING.sha256)
echo "V5_FILLED head=$H tree=$T spec_blob=$SPEC harness_blob=$HARN bootstrap_blob=$BOOT fixture=$FIX driver=$(sha256sum "$V5/s8c-pg-proof.sh" | cut -c1-64) manifest=$(sha256sum "$V5/BINDING.sha256" | cut -c1-64)" | tee "$V5/prepare-binding-v5.log"
cat "$V5/BINDING.sha256" | tee -a "$V5/prepare-binding-v5.log"
