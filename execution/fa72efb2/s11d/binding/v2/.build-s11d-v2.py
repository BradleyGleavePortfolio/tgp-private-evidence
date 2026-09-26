#!/usr/bin/env python3
# Build S11-D binding v2 from s11d/binding/v1 by count-asserted minimum substitution (source only; runs nothing).
import hashlib, os, subprocess
EV = '/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2'
V1 = EV + '/s11d/binding/v1'
D = EV + '/s11d/binding/v2'
SRC = '/home/user/workspace/worktrees/fa72-s11d2'
SPEC = 'test/scout/s11/journey-full.pg.spec.ts'
HEAD = 'aed23289024898cceca7385d3778cd7373b7424d'
env = dict(os.environ, GIT_OPTIONAL_LOCKS='0', GIT_NO_LAZY_FETCH='1')
def sha(b): return hashlib.sha256(b).hexdigest()
def git(*a): return subprocess.run(['git', '-C', SRC, *a], env=env, check=True, capture_output=True).stdout
TREE = git('rev-parse', HEAD + '^{tree}').decode().strip()
BLOB = git('rev-parse', HEAD + ':' + SPEC).decode().strip()
freeze = f'{sha(git("show", HEAD + ":" + SPEC))}  {SPEC}\n'.encode()
open(D + '/FREEZE-s11d.sha256', 'wb').write(freeze); FZ = sha(freeze)

t = open(V1 + '/s11-pg-proof.sh').read()
assert sha(t.encode()) == '8dda61d6fb0122dbfde910aea4acd5f6fb0649b3d6747b7b7933a693dbd46225'
n_sub = 0
def sub(old, new, count=1):
    global t, n_sub
    c = t.count(old); assert c == count, (c, old[:120])
    t = t.replace(old, new); n_sub += 1

sub('#!/usr/bin/env bash\n# EXEC-FA72EFB2 S11-D binding v1 —',
    '#!/usr/bin/env bash\n'
    '# EXEC-FA72EFB2 S11-D binding v2 — minimum substitution of s11d/binding/v1 (sha256 8dda61d6…6225; its run was consumed and\n'
    '# FAILED at jest-full: J20 4/4 passed, J19 legs A/B spec defects, s11d/PROOF_V1_FINDING.md) to the r3 candidate: chain\n'
    f'# 54be96f1 -> a52d20d6 (r1) -> 38d0d366 (r2) -> aed23289 (r3: J19 leg A push count, leg B report field), tree {TREE[:8]}.\n'
    '# Changes: three-commit chain check (HEAD^ = R2_HEAD, HEAD^^ = R1_HEAD, HEAD~3 = BASE, count 3; same in the clone check),\n'
    '# r1->r2 check kept (R1_HEAD..R2_HEAD) + new r2->r3 check (exactly test/scout/s11/journey-full.pg.spec.ts), EXPECT_FULL_BLOB\n'
    f'# {BLOB[:8]}, FREEZE-s11d regenerated at HEAD r3, fresh clone worktrees/fa72-s11d2-pg2, own dir/run. Delta (1 path), other\n'
    '# freezes/pins, stages (bootstrap + full 6 + guard 95), counts and bounds (full 4200, outer 7800) unchanged.\n'
    '# Full delta: DELTA-from-v1.diff. Text below is s11d v1.\n'
    '# EXEC-FA72EFB2 S11-D binding v1 —')
sub('timeout -k 30 7800 bash .../fa72efb2/s11d/binding/v1/s11-pg-proof.sh', 'timeout -k 30 7800 bash .../fa72efb2/s11d/binding/v2/s11-pg-proof.sh')
sub('D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11d/binding/v1\n', 'D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s11d/binding/v2\n')
sub('# clone source (read-only here): HEAD 38d0d366 (= origin/land/s11d,', '# clone source (read-only here): HEAD aed23289 (= origin/land/s11d,')
sub('W=/home/user/workspace/worktrees/fa72-s11d2-pg1 ', 'W=/home/user/workspace/worktrees/fa72-s11d2-pg2 ')
sub('EXPECT_HEAD=38d0d366730331e4edf19a14cda8247435b89431                             # S11-D r2 candidate (J20 live-gated, roster-bridge qualifier, full range), two commits on BASE_HEAD',
    f'EXPECT_HEAD={HEAD}                             # S11-D r3 candidate (J19 leg A push count, leg B report field), three commits on BASE_HEAD')
sub('EXPECT_TREE=075c1513d54367abb796c35faac0bf2872acbace', f'EXPECT_TREE={TREE}')
sub('R1_HEAD=a52d20d6827ae51da58505050ab0d29327659796                                 # S11-D r1 (J19 + J20) = HEAD^, parent BASE_HEAD\n',
    'R1_HEAD=a52d20d6827ae51da58505050ab0d29327659796                                 # S11-D r1 (J19 + J20) = HEAD^^, parent BASE_HEAD\n'
    'R2_HEAD=38d0d366730331e4edf19a14cda8247435b89431                                 # S11-D r2 (binding v1 candidate) = HEAD^, parent R1_HEAD\n')
sub('R1R2_DELTA="test/scout/s11/journey-full.pg.spec.ts"   # R1_HEAD..HEAD (the r2 review fixes), exactly\n',
    'R1R2_DELTA="test/scout/s11/journey-full.pg.spec.ts"   # R1_HEAD..R2_HEAD (the r2 review fixes), exactly\n'
    'R2R3_DELTA="test/scout/s11/journey-full.pg.spec.ts"   # R2_HEAD..HEAD (the r3 J19 fixes), exactly\n')
sub('EXPECT_FULL_BLOB=ecfe8cef35eb99f955d7b0acdaddeb84d3cef8e2                         # test/scout/s11/journey-full.pg.spec.ts (S11-D r2, new; the delta)',
    f'EXPECT_FULL_BLOB={BLOB}                         # test/scout/s11/journey-full.pg.spec.ts (S11-D r3, new; the delta)')
sub('S11D_FREEZE_SHA=6819f7854806e862faa9bb12da5dd4f991a1d1150d517fe7caad8abf05cd1f9f      # FREEZE-s11d v1: the 1 S11-D path at HEAD r2 (paths == delta)',
    f'S11D_FREEZE_SHA={FZ}      # FREEZE-s11d v2: the 1 S11-D path at HEAD r3 (paths == delta)')
sub('$EXPECT_TREE$R1_HEAD$EXPECT_MIGRATIONS_TREE', '$EXPECT_TREE$R1_HEAD$R2_HEAD$EXPECT_MIGRATIONS_TREE')
sub('# clone source: committed candidate, two commits on BASE (r1, r2),', '# clone source: committed candidate, three commits on BASE (r1, r2, r3),')
sub('[ "$(g rev-parse HEAD^)" = "$R1_HEAD" ] && [ "$(g rev-parse HEAD^^)" = "$BASE_HEAD" ] && [ "$(g rev-list --count "$BASE_HEAD..HEAD")" = 2 ] || { log "PRECONDITION_FAIL chain != $BASE_HEAD -> $R1_HEAD -> HEAD (two commits)"; fail 70; }',
    '[ "$(g rev-parse HEAD^)" = "$R2_HEAD" ] && [ "$(g rev-parse HEAD^^)" = "$R1_HEAD" ] && [ "$(g rev-parse HEAD~3)" = "$BASE_HEAD" ] && [ "$(g rev-list --count "$BASE_HEAD..HEAD")" = 3 ] || { log "PRECONDITION_FAIL chain != $BASE_HEAD -> $R1_HEAD -> $R2_HEAD -> HEAD (three commits)"; fail 70; }')
sub('[ "$(g diff --name-only "$R1_HEAD" HEAD | sort | tr \'\\n\' \' \' | sed \'s/ $//\')" = "$R1R2_DELTA" ] || { log "PRECONDITION_FAIL r1..r2 delta != [$R1R2_DELTA]"; fail 70; }',
    '[ "$(g diff --name-only "$R1_HEAD" "$R2_HEAD" | sort | tr \'\\n\' \' \' | sed \'s/ $//\')" = "$R1R2_DELTA" ] || { log "PRECONDITION_FAIL r1..r2 delta != [$R1R2_DELTA]"; fail 70; }\n'
    '[ "$(g diff --name-only "$R2_HEAD" HEAD | sort | tr \'\\n\' \' \' | sed \'s/ $//\')" = "$R2R3_DELTA" ] || { log "PRECONDITION_FAIL r2..r3 delta != [$R2R3_DELTA]"; fail 70; }')
sub('[ "$(git -C "$W" rev-parse HEAD^)" = "$R1_HEAD" ] && [ "$(git -C "$W" rev-parse HEAD^^)" = "$BASE_HEAD" ] \\',
    '[ "$(git -C "$W" rev-parse HEAD^)" = "$R2_HEAD" ] && [ "$(git -C "$W" rev-parse HEAD^^)" = "$R1_HEAD" ] && [ "$(git -C "$W" rev-parse HEAD~3)" = "$BASE_HEAD" ] \\')
assert 'fa72-s11d2-pg1' not in t.split('# EXEC-FA72EFB2 S11-D binding v1 —')[1].split('set -uo pipefail', 1)[1]
open(D + '/s11-pg-proof.sh', 'w').write(t); os.chmod(D + '/s11-pg-proof.sh', 0o755)

l = open(V1 + '/launch-when-free.sh').read()
assert sha(l.encode()) == 'd055014c1866152605b5abeec49f22d1207bce30b417927c3101f81d28bdc6dc' and l.count('S11-D binding v1') == 1
l = l.replace('S11-D binding v1', 'S11-D binding v2')
open(D + '/launch-when-free.sh', 'w').write(l); os.chmod(D + '/launch-when-free.sh', 0o755)
fx = open(V1 + '/s11-fixture.sh', 'rb').read()
assert sha(fx) == '777e6ac3db359bc6ecb891c19da37943b8296ac9574ba48220ea9a94cfc31636'
open(D + '/s11-fixture.sh', 'wb').write(fx); os.chmod(D + '/s11-fixture.sh', 0o644)
print('substitutions', n_sub, 'tree', TREE, 'blob', BLOB, 'runner_sha', sha(t.encode()), 'freeze_sha', FZ, 'launcher_sha', sha(l.encode()))
