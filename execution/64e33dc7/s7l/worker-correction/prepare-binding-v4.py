#!/usr/bin/env python3
"""S7-L binding v4: mechanical derivation from the frozen v3 binding (grant S7L-WC-1). Source-only: copies the three
v3 scripts into binding/v4 and applies exact, enumerated text replacements. Refuses if any replacement does not
match exactly once. Runs nothing (the freeze/bash -n/diffs are run by the caller)."""
import os, shutil, sys

L = '/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding'
V3, V4 = f'{L}/v3', f'{L}/v4'
BASE = '93389265a846095b846fa8f1fb0dad782fb6ee9f'
V1H, V1T = '839b54c53ccb252f95b4ec63df0b08595bbe7698', 'f02205c60ad0bfeb24ce82d74b0025ee9a185df6'
V2H, V2T = '54970cd937afc8dea689b33243961abfef8b9dd6', '513c71d7c1390787e1521ccbfa46b30bb52b5462'
V3H, V3T = 'a68cdac70d81aea384fdc99c01c9c983a08e80eb', '6c00e2483d0407e1ba8b8e97d03ff0e1ea2b88eb'
V4H, V4T = 'df713fd9217df524915348ef8a42c797f288dde1', '796f437fea80550a379b5f54dc485bc5dbba67e1'
WORKER_OLD, WORKER_NEW = 'a8fed545d68d1536171de0892f33ef8a9abf2f3e', '155ffdccd3d4e472cede84e7b11523d18201b450'
FIX_V3 = '721468ac49eae624697feafa78ddfbddab9fee41303be03c36c66c923e6f7945'
V3_JEST_LOG = '2d41a121cc89294f8a84bdcdea288d88629147c7f0f394a24560273c58985929'

os.makedirs(V4, exist_ok=True)
for f in ('s7l-pg-proof.sh', 's7l-fixture.sh'):
    shutil.copyfile(f'{V3}/{f}', f'{V4}/{f}')
shutil.copyfile(f'{V3}/freeze-v3.sh', f'{V4}/freeze-v4.sh')


def edit(path, reps):
    s = open(path).read()
    for old, new in reps:
        n = s.count(old)
        if n != 1:
            sys.exit(f'REFUSED {path}: expected exactly 1 match, found {n} for: {old[:90]!r}')
        s = s.replace(old, new)
    open(path, 'w').write(s)


LOOP_OLD = ('for d in "$CLUSTERS"/*/; do [ -d "$d" ] || continue; n=$(basename "$d"); [ "${d%/}" != "$LANE" ] || continue'
            '  # own lane by actual path; retained v2 clusters/s7l is another stopped lane')
LOOP_NEW = ('for d in "$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-v3/clusters/*/ "$RUNTIME_ROOT"/proof-v4/clusters/*/; do [ -d "$d" ] || continue; '
            '[ "${d%/}" != "$LANE" ] || continue; n=${d#$RUNTIME_ROOT/}; n=${n%/}'
            '  # own lane by actual path; every other lane (retained v2 clusters/s7l, failed v3 proof-v3/clusters/s7l, sibling proof-v4/clusters/*) is another stopped lane')

# ---- driver
edit(f'{V4}/s7l-pg-proof.sh', [
    # header (lines 2-9)
    ('# S7-L real-PG proof — binding v3 (S7L_RUNTIME_MINIMUM_CORRECTION_GRANT: P1 observed lock-timeout message, P2 try/finally\n'
     '# release in the stage-1 held-transaction test of test/rls-g2-s7l.spec.ts). Bound to the ORDINARY FOLLOW-UP commit whose\n'
     '# exact parent is the failed-but-preserved v2 candidate 54970cd937afc8dea689b33243961abfef8b9dd6 (HEAD^^ = preserved v1\n'
     '# 839b54c5, HEAD^^^ = accepted base 93389265). Identical to binding/v2/s7l-pg-proof.sh except: versioned paths (binding/v3,\n'
     '# run receipts under binding/v3/run), FRESH runtime lane/socket/old-root under recovery-reset/proof-v3 (the failed v2 lane\n'
     '# clusters/s7l and its old-root are retained evidence, never reused, and are now included in the other-lane checks),\n'
     '# EXPECT_PARENT pin + lineage/one-path delta checks, and the candidate head/tree/spec-blob/fixture pins filled by\n'
     '# freeze-v3.sh. NOT RUN; NOT GRANTED. Derived as a code pattern from the\n',
     '# S7-L real-PG proof — binding v4 (grant S7L-WC-1, daceddc8/SCOPE.md: worker runtime-identity correction — the OLD-image\n'
     '# worker resolves @prisma/client/runtime/library to the custom-output client\'s own runtime copy so P2002 instanceof holds;\n'
     '# one file test/utils/g2-s7l-worker.cjs). Bound to the ORDINARY FOLLOW-UP commit whose exact parent is the\n'
     '# failed-but-preserved v3 candidate a68cdac70d81aea384fdc99c01c9c983a08e80eb (HEAD^^ = preserved v2 54970cd9, HEAD^^^ =\n'
     '# preserved v1 839b54c5, HEAD^^^^ = accepted base 93389265). Identical to binding/v3/s7l-pg-proof.sh except: versioned\n'
     '# paths (binding/v4, run receipts under binding/v4/run), FRESH runtime lane/socket/old-root under recovery-reset/proof-v4\n'
     '# (the failed v2 lane clusters/s7l and the failed v3 lane proof-v3/clusters/s7l are retained evidence, never reused; the\n'
     '# other-lane loops enumerate clusters/, proof-v3/clusters/ and proof-v4/clusters/ excluding only this lane by path so a\n'
     '# sibling S8-C v4 lane is protected), EXPECT_PARENT pin + lineage/one-path delta checks shifted one level, and the\n'
     '# candidate head/tree/worker-blob/fixture pins (fixture filled by freeze-v4.sh). NOT RUN; NOT GRANTED. Derived as a code pattern from the\n'),
    ('#   timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v3/s7l-pg-proof.sh\n',
     '#   timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v4/s7l-pg-proof.sh\n'),
    ('D=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v3\n',
     'D=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v4\n'),
    (f'EXPECT_PARENT={V2H}                       # v2 candidate (failed proof, preserved): the exact parent of the ordinary follow-up commit\n',
     f'EXPECT_PARENT={V3H}                       # v3 candidate (failed proof 23/1 L05/L12, preserved): the exact parent of the ordinary follow-up commit\n'),
    (f'EXPECT_HEAD={V3H}                                  # v3 candidate head (P1/P2 runtime minimum correction), filled by freeze-v3.sh\n',
     f'EXPECT_HEAD={V4H}                                  # v4 candidate head (worker runtime-identity correction), committed df713fd9; verified by freeze-v4.sh\n'),
    (f'EXPECT_TREE={V3T}\n', f'EXPECT_TREE={V4T}\n'),
    (f'EXPECT_WORKER_BLOB={WORKER_OLD}                 # test/utils/g2-s7l-worker.cjs\n',
     f'EXPECT_WORKER_BLOB={WORKER_NEW}                 # test/utils/g2-s7l-worker.cjs (v4: runtime/library redirect)\n'),
    (f'EXPECT_FIXTURE_SHA={FIX_V3}                                     # sha256 of binding/v3/s7l-fixture.sh (frozen with this file by freeze-v3.sh)\n',
     'EXPECT_FIXTURE_SHA=__FILLED_BY_FREEZE__                                     # sha256 of binding/v4/s7l-fixture.sh (frozen with this file by freeze-v4.sh)\n'),
    ('LANE=$RUNTIME_ROOT/proof-v3/clusters/s7l; SOCK=$RUNTIME_ROOT/proof-v3/run/s7l  # fresh v3 lane; CLUSTERS kept for other-lane checks\n',
     'LANE=$RUNTIME_ROOT/proof-v4/clusters/s7l; SOCK=$RUNTIME_ROOT/proof-v4/run/s7l  # fresh v4 lane; CLUSTERS kept for other-lane checks\n'),
    ('OLDROOT=$RUNTIME_ROOT/proof-v3/s7l/old-root; OLDCLIENT=$OLDROOT/.g2-s7l-old-client\n',
     'OLDROOT=$RUNTIME_ROOT/proof-v4/s7l/old-root; OLDCLIENT=$OLDROOT/.g2-s7l-old-client\n'),
    ('case "$EXPECT_FIXTURE_SHA$EXPECT_HEAD$EXPECT_TREE$EXPECT_SPEC_BLOB" in *__*) log "PRECONDITION_FAIL v3 pins not frozen (run freeze-v3.sh after the follow-up commit)"; fail 70;; esac\n',
     'case "$EXPECT_FIXTURE_SHA$EXPECT_HEAD$EXPECT_TREE$EXPECT_WORKER_BLOB" in *__*) log "PRECONDITION_FAIL v4 pins not frozen (run freeze-v4.sh after the follow-up commit)"; fail 70;; esac\n'),
    ('{ log "PRECONDITION_FAIL EXPECT_HEAD is the base or the v2 parent, not the v3 candidate"; fail 70; }\n',
     '{ log "PRECONDITION_FAIL EXPECT_HEAD is the base or the v3 parent, not the v4 candidate"; fail 70; }\n'),
    ('# ordinary follow-up lineage: HEAD^ is exactly the preserved v2 candidate (never amended/replaced), HEAD^^ the preserved v1\n'
     '# candidate 839b54c5, HEAD^^^ the accepted base; both preserved trees are checked byte-for-byte\n'
     '[ "$(git -C "$W" rev-parse HEAD^)" = "$EXPECT_PARENT" ] || { log "PRECONDITION_FAIL HEAD parent != $EXPECT_PARENT (ordinary follow-up on the preserved v2 candidate expected)"; fail 70; }\n'
     f'[ "$(git -C "$W" rev-parse "$EXPECT_PARENT^{{tree}}")" = {V2T} ] || {{ log "PRECONDITION_FAIL v2 parent tree changed (54970cd9 must be preserved byte-for-byte)"; fail 70; }}\n'
     f'[ "$(git -C "$W" rev-parse "$EXPECT_PARENT^")" = {V1H} ] || {{ log "PRECONDITION_FAIL v2 parent $EXPECT_PARENT does not sit directly on the preserved v1 candidate 839b54c5"; fail 70; }}\n'
     '[ "$(git -C "$W" rev-parse "$EXPECT_PARENT^^")" = "$BASE_HEAD" ] || { log "PRECONDITION_FAIL v1 candidate 839b54c5 does not sit directly on the accepted base"; fail 70; }\n'
     f'[ "$(git -C "$W" rev-parse "$EXPECT_PARENT^^{{tree}}")" = {V1T} ] || {{ log "PRECONDITION_FAIL v1 tree changed (839b54c5 must be preserved byte-for-byte)"; fail 70; }}\n',
     '# ordinary follow-up lineage: HEAD^ is exactly the preserved v3 candidate (never amended/replaced), HEAD^^ the preserved v2\n'
     '# candidate 54970cd9, HEAD^^^ the preserved v1 candidate 839b54c5, HEAD^^^^ the accepted base; all three preserved trees are checked byte-for-byte\n'
     '[ "$(git -C "$W" rev-parse HEAD^)" = "$EXPECT_PARENT" ] || { log "PRECONDITION_FAIL HEAD parent != $EXPECT_PARENT (ordinary follow-up on the preserved v3 candidate expected)"; fail 70; }\n'
     f'[ "$(git -C "$W" rev-parse "$EXPECT_PARENT^{{tree}}")" = {V3T} ] || {{ log "PRECONDITION_FAIL v3 parent tree changed (a68cdac7 must be preserved byte-for-byte)"; fail 70; }}\n'
     f'[ "$(git -C "$W" rev-parse "$EXPECT_PARENT^")" = {V2H} ] || {{ log "PRECONDITION_FAIL v3 parent $EXPECT_PARENT does not sit directly on the preserved v2 candidate 54970cd9"; fail 70; }}\n'
     f'[ "$(git -C "$W" rev-parse "$EXPECT_PARENT^^{{tree}}")" = {V2T} ] || {{ log "PRECONDITION_FAIL v2 tree changed (54970cd9 must be preserved byte-for-byte)"; fail 70; }}\n'
     f'[ "$(git -C "$W" rev-parse "$EXPECT_PARENT^^")" = {V1H} ] || {{ log "PRECONDITION_FAIL v2 candidate 54970cd9 does not sit directly on the preserved v1 candidate 839b54c5"; fail 70; }}\n'
     f'[ "$(git -C "$W" rev-parse "$EXPECT_PARENT^^^{{tree}}")" = {V1T} ] || {{ log "PRECONDITION_FAIL v1 tree changed (839b54c5 must be preserved byte-for-byte)"; fail 70; }}\n'
     '[ "$(git -C "$W" rev-parse "$EXPECT_PARENT^^^")" = "$BASE_HEAD" ] || { log "PRECONDITION_FAIL v1 candidate 839b54c5 does not sit directly on the accepted base"; fail 70; }\n'),
    ('# the follow-up delta from v2 is exactly the one granted proof-spec path\n'
     '[ "$(git -C "$W" diff --name-only "$EXPECT_PARENT" HEAD | sort | tr \'\\n\' \' \')" = "test/rls-g2-s7l.spec.ts " ] \\\n'
     '  || { log "PRECONDITION_FAIL follow-up delta from v2 is not exactly the one granted P1/P2 path test/rls-g2-s7l.spec.ts"; fail 70; }\n',
     '# the follow-up delta from v3 is exactly the one granted proof-worker path\n'
     '[ "$(git -C "$W" diff --name-only "$EXPECT_PARENT" HEAD | sort | tr \'\\n\' \' \')" = "test/utils/g2-s7l-worker.cjs " ] \\\n'
     '  || { log "PRECONDITION_FAIL follow-up delta from v3 is not exactly the one granted path test/utils/g2-s7l-worker.cjs"; fail 70; }\n'),
])
# the two other-lane loops (preflight + post): identical text, replaced one at a time
s = open(f'{V4}/s7l-pg-proof.sh').read()
if s.count(LOOP_OLD) != 2:
    sys.exit(f'REFUSED driver: expected exactly 2 other-lane loops, found {s.count(LOOP_OLD)}')
open(f'{V4}/s7l-pg-proof.sh', 'w').write(s.replace(LOOP_OLD, LOOP_NEW))

# ---- fixture: exactly 3 lines (comment, LANE, DATA/SOCK)
edit(f'{V4}/s7l-fixture.sh', [
    ('#     socket directories under recovery-reset/proof-v3/clusters/s7l and recovery-reset/proof-v3/run/s7l (fresh v3 lane; the retained failed v2 lane clusters/s7l is never reused) — never pg17/dist as a data root,\n',
     '#     socket directories under recovery-reset/proof-v4/clusters/s7l and recovery-reset/proof-v4/run/s7l (fresh v4 lane; the retained failed v2 lane clusters/s7l and failed v3 lane proof-v3/clusters/s7l are never reused) — never pg17/dist as a data root,\n'),
    ('LANE=$RUNTIME_ROOT/proof-v3/clusters/s7l\n', 'LANE=$RUNTIME_ROOT/proof-v4/clusters/s7l\n'),
    ('DATA=$LANE/pg-data; LOG=$LANE/pg.log; SOCK=$RUNTIME_ROOT/proof-v3/run/s7l\n',
     'DATA=$LANE/pg-data; LOG=$LANE/pg.log; SOCK=$RUNTIME_ROOT/proof-v4/run/s7l\n'),
])

# ---- freeze
edit(f'{V4}/freeze-v4.sh', [
    ('# S7-L binding v3 freeze (S7L_RUNTIME_MINIMUM_CORRECTION_GRANT; source-only preparation, NOT a PG run, needs no slot). Read-only against the worktree: re-derives\n',
     '# S7-L binding v4 freeze (grant S7L-WC-1; source-only preparation, NOT a PG run, needs no slot). Read-only against the worktree: re-derives\n'),
    ('# mismatch; never edits a pin to pass), re-verifies the tool pins by sha256 (report only), fills the single fixture-sha\n'
     '# placeholder, and records BINDING.sha256 (filled runner + fixture + this file). Runs nothing else. Usage: bash freeze-v3.sh\n',
     '# mismatch; never edits a pin to pass), re-verifies the tool pins by sha256 (report only), fills the single fixture-sha\n'
     '# placeholder, and records BINDING.sha256 (filled runner + fixture + this file). Runs nothing else. Usage: bash freeze-v4.sh\n'),
    ('D=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v3\n'
     'V1=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding\n'
     'V2=$V1/v2\n'
     f'PARENT={V2H}   # preserved failed v2 candidate\n'
     f'V1HEAD={V1H}\n',
     'D=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v4\n'
     'V1=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding\n'
     'V2=$V1/v2\n'
     'V3=$V1/v3\n'
     f'PARENT={V3H}   # preserved failed v3 candidate\n'
     f'V2HEAD={V2H}\n'
     f'V1HEAD={V1H}\n'),
    ('[ "$HEAD" != "$PARENT" ] && [ "$HEAD" != "$V1HEAD" ] || { echo "REFUSED: HEAD is still the v2 (or v1) candidate; the follow-up commit does not exist yet" >&2; exit 70; }\n'
     '[ "$(git -C "$W" rev-parse HEAD^)" = "$PARENT" ] || { echo "REFUSED: HEAD^ != $PARENT (ordinary follow-up on the preserved v2 candidate required; no amend/replace)" >&2; exit 70; }\n'
     f'[ "$(git -C "$W" rev-parse "$PARENT^{{tree}}")" = {V2T} ] || {{ echo "REFUSED: v2 candidate tree changed" >&2; exit 70; }}\n'
     '[ "$(git -C "$W" rev-parse "$PARENT^")" = "$V1HEAD" ] && [ "$(git -C "$W" rev-parse "$V1HEAD^")" = "$BASE" ] || { echo "REFUSED: lineage is not base -> 839b54c5 -> 54970cd9 -> HEAD" >&2; exit 70; }\n'
     f'[ "$(git -C "$W" rev-parse "$V1HEAD^{{tree}}")" = {V1T} ] || {{ echo "REFUSED: v1 candidate tree changed" >&2; exit 70; }}\n'
     '[ "$(git -C "$W" diff --name-only "$PARENT" HEAD | sort | tr \'\\n\' \' \')" = "test/rls-g2-s7l.spec.ts " ] \\\n'
     '  || { echo "REFUSED: follow-up delta is not exactly the one granted path test/rls-g2-s7l.spec.ts" >&2; exit 70; }\n'
     '# v3 fixture delta from v2 is exactly the recorded fresh-lane/socket diff (paths + one directly corresponding comment); nothing else\n'
     '[ "$(diff "$V2/s7l-fixture.sh" "$D/s7l-fixture.sh" || true)" = "$(cat "$D/fixture-v2-to-v3.diff")" ] || { echo "REFUSED: v3 fixture delta from v2 differs from the recorded fixture-v2-to-v3.diff" >&2; exit 70; }\n'
     '[ "$(diff "$V2/s7l-fixture.sh" "$D/s7l-fixture.sh" | grep -cE \'^> \' || true)" = 3 ] || { echo "REFUSED: fixture delta is not exactly the 3 granted lines (LANE, DATA/SOCK, comment)" >&2; exit 70; }\n'
     '[ -e "$V1/BINDING.sha256" ] && ( cd "$V1" && sha256sum -c --quiet BINDING.sha256 ) || { echo "REFUSED: v1 binding missing or altered" >&2; exit 70; }\n'
     '[ -e "$V2/BINDING.sha256" ] && ( cd "$V2" && sha256sum -c --quiet BINDING.sha256 ) || { echo "REFUSED: v2 binding missing or altered" >&2; exit 70; }\n'
     '[ "$(sha256sum "$V2/run/jest.log" | cut -c1-64)" = d6253d28d1a3e432959857dd17d8c9b258609a5855adc35058a909adae1892a5 ] || { echo "REFUSED: v2 run receipt jest.log altered" >&2; exit 70; }\n',
     '[ "$HEAD" != "$PARENT" ] && [ "$HEAD" != "$V2HEAD" ] && [ "$HEAD" != "$V1HEAD" ] || { echo "REFUSED: HEAD is still the v3 (or v2/v1) candidate; the follow-up commit does not exist yet" >&2; exit 70; }\n'
     '[ "$(git -C "$W" rev-parse HEAD^)" = "$PARENT" ] || { echo "REFUSED: HEAD^ != $PARENT (ordinary follow-up on the preserved v3 candidate required; no amend/replace)" >&2; exit 70; }\n'
     f'[ "$(git -C "$W" rev-parse "$PARENT^{{tree}}")" = {V3T} ] || {{ echo "REFUSED: v3 candidate tree changed" >&2; exit 70; }}\n'
     '[ "$(git -C "$W" rev-parse "$PARENT^")" = "$V2HEAD" ] && [ "$(git -C "$W" rev-parse "$V2HEAD^")" = "$V1HEAD" ] && [ "$(git -C "$W" rev-parse "$V1HEAD^")" = "$BASE" ] || { echo "REFUSED: lineage is not base -> 839b54c5 -> 54970cd9 -> a68cdac7 -> HEAD" >&2; exit 70; }\n'
     f'[ "$(git -C "$W" rev-parse "$V2HEAD^{{tree}}")" = {V2T} ] || {{ echo "REFUSED: v2 candidate tree changed" >&2; exit 70; }}\n'
     f'[ "$(git -C "$W" rev-parse "$V1HEAD^{{tree}}")" = {V1T} ] || {{ echo "REFUSED: v1 candidate tree changed" >&2; exit 70; }}\n'
     '[ "$(git -C "$W" diff --name-only "$PARENT" HEAD | sort | tr \'\\n\' \' \')" = "test/utils/g2-s7l-worker.cjs " ] \\\n'
     '  || { echo "REFUSED: follow-up delta is not exactly the one granted path test/utils/g2-s7l-worker.cjs" >&2; exit 70; }\n'
     '# v4 fixture delta from v3 is exactly the recorded fresh-lane/socket diff (paths + one directly corresponding comment); nothing else\n'
     '[ "$(diff "$V3/s7l-fixture.sh" "$D/s7l-fixture.sh" || true)" = "$(cat "$D/fixture-v3-to-v4.diff")" ] || { echo "REFUSED: v4 fixture delta from v3 differs from the recorded fixture-v3-to-v4.diff" >&2; exit 70; }\n'
     '[ "$(diff "$V3/s7l-fixture.sh" "$D/s7l-fixture.sh" | grep -cE \'^> \' || true)" = 3 ] || { echo "REFUSED: fixture delta is not exactly the 3 granted lines (LANE, DATA/SOCK, comment)" >&2; exit 70; }\n'
     '[ -e "$V1/BINDING.sha256" ] && ( cd "$V1" && sha256sum -c --quiet BINDING.sha256 ) || { echo "REFUSED: v1 binding missing or altered" >&2; exit 70; }\n'
     '[ -e "$V2/BINDING.sha256" ] && ( cd "$V2" && sha256sum -c --quiet BINDING.sha256 ) || { echo "REFUSED: v2 binding missing or altered" >&2; exit 70; }\n'
     '[ -e "$V3/BINDING.sha256" ] && ( cd "$V3" && sha256sum -c --quiet BINDING.sha256 ) || { echo "REFUSED: v3 binding missing or altered" >&2; exit 70; }\n'
     '[ "$(sha256sum "$V2/run/jest.log" | cut -c1-64)" = d6253d28d1a3e432959857dd17d8c9b258609a5855adc35058a909adae1892a5 ] || { echo "REFUSED: v2 run receipt jest.log altered" >&2; exit 70; }\n'
     f'[ "$(sha256sum "$V3/run/jest.log" | cut -c1-64)" = {V3_JEST_LOG} ] || {{ echo "REFUSED: v3 run receipt jest.log altered" >&2; exit 70; }}\n'
     '( cd "$V3/run" && sha256sum -c --quiet RUN_FREEZE.sha256 ) || { echo "REFUSED: v3 run directory freeze altered" >&2; exit 70; }\n'),
    # v4 pins are written from the committed head; the fill lines become no-ops on already-filled pins and cmp_pin verifies them
    ('fill EXPECT_HEAD "$HEAD"; fill EXPECT_TREE "$(git -C "$W" rev-parse \'HEAD^{tree}\')"; fill EXPECT_SPEC_BLOB "$(b test/rls-g2-s7l.spec.ts)"\n',
     'fill EXPECT_HEAD "$HEAD"; fill EXPECT_TREE "$(git -C "$W" rev-parse \'HEAD^{tree}\')"; fill EXPECT_WORKER_BLOB "$(b test/utils/g2-s7l-worker.cjs)"\n'),
    ('{ echo "# S7-L PG proof binding v3, frozen $(date -u +%FT%TZ) against head $HEAD (source-only; NOT RUN; no PG granted)"\n'
     '  ( cd "$D" && sha256sum s7l-pg-proof.sh s7l-fixture.sh freeze-v3.sh PINS.txt README.md DELTA-v2-to-v3.md driver-v2-to-v3.diff fixture-v2-to-v3.diff ); } > "$D/BINDING.sha256"\n'
     'cat "$D/BINDING.sha256"; echo "FROZEN_V3 head=$HEAD parent=$PARENT fixture_sha=$FIXSHA"\n',
     '{ echo "# S7-L PG proof binding v4, frozen $(date -u +%FT%TZ) against head $HEAD (source-only; NOT RUN; no PG granted)"\n'
     '  ( cd "$D" && sha256sum s7l-pg-proof.sh s7l-fixture.sh freeze-v4.sh PINS.txt README.md DELTA-v3-to-v4.md driver-v3-to-v4.diff fixture-v3-to-v4.diff freeze-v3-to-v4.diff ); } > "$D/BINDING.sha256"\n'
     'cat "$D/BINDING.sha256"; echo "FROZEN_V4 head=$HEAD parent=$PARENT fixture_sha=$FIXSHA"\n'),
])
print('PREPARED binding/v4: s7l-pg-proof.sh s7l-fixture.sh freeze-v4.sh (pre-freeze; EXPECT_FIXTURE_SHA placeholder pending)')
