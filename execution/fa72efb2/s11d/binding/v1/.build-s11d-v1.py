#!/usr/bin/env python3
# Build S11-D binding v1 from s11a2/binding/v2 by count-asserted minimum substitution (source only; runs nothing).
import hashlib, os, re, subprocess, sys
EV = '/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2'
V2 = EV + '/s11a2/binding/v2'
D = EV + '/s11d/binding/v1'
SRC = '/home/user/workspace/worktrees/fa72-s11d2'
SPEC = 'test/scout/s11/journey-full.pg.spec.ts'
env = dict(os.environ, GIT_OPTIONAL_LOCKS='0', GIT_NO_LAZY_FETCH='1')

def sha(b): return hashlib.sha256(b).hexdigest()

# FREEZE-s11d: the delta (1 path) at HEAD 38d0d366, sha256 of the blob bytes (same format as FREEZE-s11a2)
blob = subprocess.run(['git', '-C', SRC, 'show', '38d0d366730331e4edf19a14cda8247435b89431:' + SPEC],
                      env=env, check=True, capture_output=True).stdout
freeze = f'{sha(blob)}  {SPEC}\n'.encode()
open(D + '/FREEZE-s11d.sha256', 'wb').write(freeze)
FZ = sha(freeze)

t = open(V2 + '/s11-pg-proof.sh').read()
assert sha(t.encode()) == 'c785752b88e287238c676e27a83e772addb39da2fdb42e93147e574009d0c708'
n_sub = 0
def sub(old, new, count=1):
    global t, n_sub
    c = t.count(old)
    assert c == count, (c, old[:120])
    t = t.replace(old, new); n_sub += 1

A2_FILES = ('test/fixtures/scout/s11/s11-sources.ts test/fixtures/scout/s11/s11_second/induction-manifest.json '
            'test/fixtures/scout/s11/s11_second/mapping-spec.json test/fixtures/scout/s11/s11_second/native-rules.json '
            'test/fixtures/scout/s11/s11_second/signer-test-key.json test/fixtures/scout/s11/s11_second/staged-rows.json '
            'test/fixtures/scout/s11/s11_second/statements.json test/scout/s11/journey-induction.pg.spec.ts '
            'test/utils/g2-s11-db-guard.spec.ts test/utils/g2-s11-harness.ts test/utils/g2-s11-pg-harness.ts test/utils/g2-s11-worker.cjs')

# 1 header
sub('#!/usr/bin/env bash\n# EXEC-FA72EFB2 S11-A2 binding v2 —',
    '#!/usr/bin/env bash\n'
    '# EXEC-FA72EFB2 S11-D binding v1 — minimum substitution of s11a2/binding/v2 (sha256 c785752b…c708; ran END rc=0 127/127,\n'
    '# S11-A2 landed as integration/importer = 54be96f1, PR #564) to the S11-D candidate: chain 54be96f1 (tree 435fec78) -> a52d20d6\n'
    '# (r1) -> 38d0d366 (r2), tree 075c1513, branch fa72/s11d-r2, land ref land/s11d, clone source worktrees/fa72-s11d2, fresh clone\n'
    '# worktrees/fa72-s11d2-pg1. Delta = exactly test/scout/s11/journey-full.pg.spec.ts (blob ecfe8cef, 6 it: J19 legs A/B + 4 J20\n'
    '# checks), pinned by the new FREEZE-s11d; FREEZE-s11a2 (12 paths, no longer the delta), FREEZE-v3 kept lines, FREEZE-s11c,\n'
    '# FREEZE-s11b and all 18 v2 blob pins must hold unchanged at HEAD; BASE..HEAD touches nothing in src/prisma/package*/test/utils.\n'
    '# Stages: bootstrap + NEW full (jest-full.log) + guard 95 only; rls/journey/readiness/settle-redrive/induction were accepted at\n'
    '# BASE in the s11a2 v2 run on unchanged bytes and are NOT rerun (their byte pins/it() counts are still checked). New pre-lock\n'
    '# tool check: rg on PATH (J20 runs scripts/s10-core-diff-gate.sh at 275e458c, which needs rg). J20 needs history: the clone\n'
    '# is --shared (objects via alternates to the source); all 10 commits of 3db615c0^..HEAD and every object of their trees are\n'
    '# present in the source (checked read-only at build). J20\'s scratch `git worktree add` goes to os.tmpdir() (outside $W) and is\n'
    '# removed in its finally; .git/worktrees is not in `git status`, so the PORC0 post check is unaffected; the post step logs the\n'
    '# clone\'s worktree count (record only). Bounds: full = 6 cases x jest.setTimeout 600 s = 3600 s hard jest ceiling + 600 s\n'
    '# boot/hooks = 4200 s (J19 legs fork many ts-node harness workers incl. the J12 kill-and-replay, each with its own 90 s kill\n'
    '# cap; cf. v2 run: journey-core 188 s, redrive 233 s, induction 84 s). Inner sum clone 120 + checkout 120 + cp 600 + generate\n'
    '# 600 + init 60 + start 60 + bootstrap 900 + identity 8x15 + full 4200 + guard 300 + stop 75 + destroy 75 = 7230 s; outer 7800\n'
    '# (570 s margin). A timeout is a failure (rc 124), never a retry. Full delta: DELTA-from-s11a2-v2.diff. Text below is s11a2 v2.\n'
    '# EXEC-FA72EFB2 S11-A2 binding v2 —')
# 2 usage
sub('# Usage (under the separate single-run PG grant): timeout -k 30 13500 bash .../fa72efb2/s11a2/binding/v2/s11-pg-proof.sh',
    '# Usage (under the separate single-run PG grant): timeout -k 30 7800 bash .../fa72efb2/s11d/binding/v1/s11-pg-proof.sh')
# 3 D
sub('D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11a2/binding/v2\n',
    'D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11d/binding/v1\n')
# 4 SRC
sub('SRC=/home/user/workspace/worktrees/fa72-s11a2                                    # clone source (read-only here): HEAD 54be96f1 (= origin/land/s11a2, branch fa72/s11a2), clean, lefthook hooks',
    'SRC=/home/user/workspace/worktrees/fa72-s11d2                                    # clone source (read-only here): HEAD 38d0d366 (= origin/land/s11d, branch fa72/s11d-r2), clean, lefthook hooks')
# 5 W
sub('W=/home/user/workspace/worktrees/fa72-s11a2-pg2 ', 'W=/home/user/workspace/worktrees/fa72-s11d2-pg1 ')
# 6 JLOG7
sub('JLOG6=$R/jest-induction.log;', 'JLOG6=$R/jest-induction.log; JLOG7=$R/jest-full.log;')
# 7 BASE
sub('BASE_HEAD=dda794d7e8bee0482a7ad373795fcc51dcf54bb5                               # S11-B r2 (proof RC=0 122/122; = 275e458c + 2 S11-B commits) (= HEAD^^)',
    'BASE_HEAD=54be96f18c314cae35d1e5d3000af9f06d693d81                               # S11-A2 r2 (proof RC=0 127/127; landed = integration/importer, PR #564) (= HEAD^^)')
sub('BASE_TREE=802e1c196c7a0bd27f091218407f5f0b031dd760', 'BASE_TREE=435fec782672214c7e8e81b2eb91f8f9266331b4')
# 8 HEAD
sub('EXPECT_HEAD=54be96f18c314cae35d1e5d3000af9f06d693d81                             # S11-A2 r2 candidate (resetData cascade-only fix), two commits on BASE_HEAD',
    'EXPECT_HEAD=38d0d366730331e4edf19a14cda8247435b89431                             # S11-D r2 candidate (J20 live-gated, roster-bridge qualifier, full range), two commits on BASE_HEAD')
sub('EXPECT_TREE=435fec782672214c7e8e81b2eb91f8f9266331b4', 'EXPECT_TREE=075c1513d54367abb796c35faac0bf2872acbace')
# 9 R1 / delta / land
sub('R1_HEAD=03e7a2344ef95b019c751983527bbc9f78200921                                 # S11-A2 r1 (binding v1 candidate) = HEAD^, parent BASE_HEAD',
    'R1_HEAD=a52d20d6827ae51da58505050ab0d29327659796                                 # S11-D r1 (J19 + J20) = HEAD^, parent BASE_HEAD')
sub('R1R2_DELTA="test/utils/g2-s11-harness.ts"   # R1_HEAD..HEAD (the r2 fix), exactly',
    'R1R2_DELTA="test/scout/s11/journey-full.pg.spec.ts"   # R1_HEAD..HEAD (the r2 review fixes), exactly')
sub('LAND_REF=refs/remotes/origin/land/s11a2', 'LAND_REF=refs/remotes/origin/land/s11d')
# 10 full blob pin
sub('EXPECT_INDUCTION_BLOB=1b9832bcbce7a51da6a58df60c312a5b0416f144                    # test/scout/s11/journey-induction.pg.spec.ts (S11-A2, new)\n',
    'EXPECT_INDUCTION_BLOB=1b9832bcbce7a51da6a58df60c312a5b0416f144                    # test/scout/s11/journey-induction.pg.spec.ts (S11-A2, new)\n'
    'EXPECT_FULL_BLOB=ecfe8cef35eb99f955d7b0acdaddeb84d3cef8e2                         # test/scout/s11/journey-full.pg.spec.ts (S11-D r2, new; the delta)\n')
# 11 freezes
sub('S11A2_FREEZE_SHA=51d901ef8689b396ed23074911dbea1daaf5058ebc54864135484b3d80047290      # FREEZE-s11a2 v2: the 12 S11-A2 paths at HEAD r2 (paths == delta)\n',
    'S11A2_FREEZE_SHA=51d901ef8689b396ed23074911dbea1daaf5058ebc54864135484b3d80047290      # FREEZE-s11a2 v2: the 12 S11-A2 files, byte-identical at HEAD (S11-D: no longer the delta)\n'
    f'S11A2_FILES="{A2_FILES}"\n'
    'S11D_FREEZE=$D/FREEZE-s11d.sha256\n'
    f'S11D_FREEZE_SHA={FZ}      # FREEZE-s11d v1: the 1 S11-D path at HEAD r2 (paths == delta)\n')
# 12 delta
m = re.search(r'^EXPECT_DELTA="[^"\n]*"\n', t, re.M); assert m and t.count(m.group(0)) == 1
sub(m.group(0), f'EXPECT_DELTA="{SPEC}"\n')
# 13 count
m = re.search(r'^EXPECT_TESTS_GUARD=95 [^\n]*\n', t, re.M); assert m
sub(m.group(0), m.group(0) + 'EXPECT_TESTS_FULL=6         # it( in test/scout/s11/journey-full.pg.spec.ts: J19 leg A, J19 leg B, J20 x4 (no each/skip/only/todo; describe.skip only when G2_S11_DATABASE_URL is unset)\n')
# 14 pins-not-filled
sub('$S11A2_FREEZE_SHA" in *__*)', '$S11A2_FREEZE_SHA$EXPECT_FULL_BLOB$S11D_FREEZE_SHA" in *__*)')
# 16 delta msg
sub('delta [$DELTA] != the 12 S11-A2 paths"', 'delta [$DELTA] != [$EXPECT_DELTA]"')
# 17 FREEZE-s11a2 paths + FREEZE-s11d
sub('[ "$AFILES" = "$EXPECT_DELTA" ] || { log "PRECONDITION_FAIL FREEZE-s11a2 paths != delta"; fail 70; }',
    '[ "$AFILES" = "$S11A2_FILES" ] || { log "PRECONDITION_FAIL FREEZE-s11a2 paths != the 12 S11-A2 files"; fail 70; }')
old = 'while read -r s p; do GOT=$(g show "HEAD:$p" | sha256sum | cut -c1-64); [ "$GOT" = "$s" ] || { log "PRECONDITION_FAIL $p at HEAD != FREEZE-s11a2"; fail 70; }; done < "$S11A2_FREEZE"\n'
sub(old, old.replace('$p at HEAD != FREEZE-s11a2', 'S11-A2 file $p at HEAD != FREEZE-s11a2') +
    '[ -f "$S11D_FREEZE" ] && [ "$(sha "$S11D_FREEZE")" = "$S11D_FREEZE_SHA" ] || { log "PRECONDITION_FAIL S11-D FREEZE absent or sha mismatch"; fail 70; }\n'
    'DFILES=$(awk \'{print $2}\' "$S11D_FREEZE" | sort | tr \'\\n\' \' \' | sed \'s/ $//\'); [ "$DFILES" = "$EXPECT_DELTA" ] || { log "PRECONDITION_FAIL FREEZE-s11d paths != delta"; fail 70; }\n'
    'while read -r s p; do GOT=$(g show "HEAD:$p" | sha256sum | cut -c1-64); [ "$GOT" = "$s" ] || { log "PRECONDITION_FAIL $p at HEAD != FREEZE-s11d"; fail 70; }; done < "$S11D_FREEZE"\n')
# 18 test/utils untouched
sub('[ "$(g diff --name-only "$BASE_HEAD" HEAD -- test/utils | sort | tr \'\\n\' \' \' | sed \'s/ $//\')" = "$A2_A1_EDITS" ] || { log "PRECONDITION_FAIL BASE..HEAD test/utils != the 4 A2 harness edits"; fail 70; }',
    '[ -z "$(g diff --name-only "$BASE_HEAD" HEAD -- test/utils)" ] || { log "PRECONDITION_FAIL BASE..HEAD touches test/utils (S11-D changes no harness file)"; fail 70; }')
# 19 read full spec
sub('&& IND=$(g show HEAD:test/scout/s11/journey-induction.pg.spec.ts) ||',
    '&& IND=$(g show HEAD:test/scout/s11/journey-induction.pg.spec.ts) && FULL=$(g show HEAD:test/scout/s11/journey-full.pg.spec.ts) ||')
# 20 live switch
old = 'grep -qF "const live = process.env.G2_S11_DATABASE_URL ? describe : describe.skip;" <<<"$IND" || { log "PRECONDITION_FAIL induction spec live switch not the pinned form"; fail 70; }\n'
sub(old, old + old.replace('"$IND"', '"$FULL"').replace('induction spec', 'full spec'))
# 21 badpat
old = '! grep -qE "$BADPAT" <<<"$IND" || { log "PRECONDITION_FAIL induction spec carries skip/only/todo/each"; fail 70; }\n'
sub(old, old + old.replace('"$IND"', '"$FULL"').replace('induction spec', 'full spec'))
# 22 it() count
m = re.search(r'^\[ "\$N1" = "\$EXPECT_TESTS_RLS" \][^\n]*\n', t, re.M); assert m
sub(m.group(0), m.group(0) + 'N6=$(grep -cE \'^\\s*it\\(\' <<<"$FULL" || true); [ "$N6" = "$EXPECT_TESTS_FULL" ] || { log "PRECONDITION_FAIL it() count full=$N6 != $EXPECT_TESTS_FULL"; fail 70; }\n')
# 23 blob loop
sub('"test/scout/s11/journey-induction.pg.spec.ts $EXPECT_INDUCTION_BLOB"; do set -- $pin',
    '"test/scout/s11/journey-induction.pg.spec.ts $EXPECT_INDUCTION_BLOB" "test/scout/s11/journey-full.pg.spec.ts $EXPECT_FULL_BLOB"; do set -- $pin')
# 24 rg tool
m = re.search(r'^NODEV=\$\(node --version\);[^\n]*\n', t, re.M); assert m
sub(m.group(0), m.group(0) + 'RGV=$(rg --version 2>/dev/null | head -1); grep -q \'^ripgrep \' <<<"$RGV" || { log "PRECONDITION_FAIL rg not on PATH (J20 runs scripts/s10-core-diff-gate.sh, which requires rg)"; fail 70; }; log "PRELOCK rg=$(command -v rg) $RGV"\n')
# 25 under-lock recheck
sub('[ "$(sha "$S11A2_FREEZE")" = "$S11A2_FREEZE_SHA" ] \\\n',
    '[ "$(sha "$S11A2_FREEZE")" = "$S11A2_FREEZE_SHA" ] && [ "$(sha "$S11D_FREEZE")" = "$S11D_FREEZE_SHA" ] \\\n')
# 26 stages
sub('# ---- step 8 the six specs, each exactly once;', '# ---- step 8 the two specs (full, guard), each exactly once;')
m = re.search(r'^STAGE=jest-rls;.*?^jcheck induction "\$JLOG6" "\$JRC" "\$EXPECT_TESTS_INDUCTION"\n', t, re.M | re.S); assert m
blk = m.group(0); assert blk.count('jcheck ') == 5 and t.count(blk) == 1
sub(blk,
    'STAGE=jest-full; log "JEST_START full $(ts) cmd=\'./node_modules/.bin/jest --runInBand --ci test/scout/s11/journey-full.pg.spec.ts\'"\n'
    '( cd "$W" && timeout -k 30 4200 ./node_modules/.bin/jest --runInBand --ci test/scout/s11/journey-full.pg.spec.ts ) >"$JLOG7" 2>&1; JRC=$?\n'
    'jcheck full "$JLOG7" "$JRC" "$EXPECT_TESTS_FULL"\n')
# 27 receipts
sub('jest-induction.log jest-guard.log', 'jest-induction.log jest-full.log jest-guard.log')
# 28 post record of worktrees
old = '|| { log "POST_FAIL clone changed"; fail 74; }\n'
sub(old, old + 'log "POST clone_worktrees=$(git -C "$W" worktree list --porcelain | grep -c \'^worktree \') (1 = J20 scratch worktree removed; record only)"\n')

assert 's11a2/binding/v2/s11-pg-proof.sh' not in t
open(D + '/s11-pg-proof.sh', 'w').write(t)
os.chmod(D + '/s11-pg-proof.sh', 0o755)

l = open(V2 + '/launch-when-free.sh').read()
assert sha(l.encode()).startswith('9bd00b1d')
c1 = l.count('S11-A2 binding v2'); c2 = l.count('exec timeout -k 30 13500 ')
assert c1 == 1 and c2 == 1
l = l.replace('S11-A2 binding v2', 'S11-D binding v1').replace('exec timeout -k 30 13500 ', 'exec timeout -k 30 7800 ')
open(D + '/launch-when-free.sh', 'w').write(l); os.chmod(D + '/launch-when-free.sh', 0o755)

fx = open(V2 + '/s11-fixture.sh', 'rb').read()
assert sha(fx) == '777e6ac3db359bc6ecb891c19da37943b8296ac9574ba48220ea9a94cfc31636'
open(D + '/s11-fixture.sh', 'wb').write(fx); os.chmod(D + '/s11-fixture.sh', os.stat(V2 + '/s11-fixture.sh').st_mode & 0o777)
print('substitutions', n_sub, 'runner_sha', sha(t.encode()), 'freeze_sha', FZ, 'launcher_sha', sha(l.encode()))
