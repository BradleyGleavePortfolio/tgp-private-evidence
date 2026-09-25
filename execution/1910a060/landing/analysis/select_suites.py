#!/usr/bin/env python3
"""LAND-PREP-1910 composition suite selection (L2-2 method), read-only.

Usage: select_suites.py <tree_dir> <side_x_paths_file> <side_y_paths_file>

<tree_dir> is an extracted (git archive) predicted merged tree. The two path files list the
paths each side changed relative to the merge base. Nothing is written except stdout.

A default-config spec is selected when EITHER
  (1) its static relative-import closure contains changed bytes from BOTH sides, OR
  (2) it (or a file in its closure) is a repository reader (fs / git API present) whose string
      literals name a changed path of side Y, or a directory prefix of one ('docs', 'docs/decisions',
      'src', 'src/scout', ...), including consecutive literal arguments of one join/resolve call.
      This is the L2-2 lesson: specs that read repository files must be selected even when the
      changed bytes are not in their import closure. Rule (2) is applied for side Y against specs
      that already depend on side X by closure or by reading a side-X path, and it is reported
      separately for every spec so the parent can see the conservative superset.
Selection is conservative (over-inclusive); every rule-(2) hit is listed for manual disposition.
"""
import os, re, sys

root, xf, yf = sys.argv[1:4]
X = [l.strip() for l in open(xf) if l.strip()]
Y = [l.strip() for l in open(yf) if l.strip()]

ROOTS = ['test', 'src/roman/voice', 'src/community/ack', 'src/community/challenges',
         'src/notifications/__tests__', 'src/community/voice', 'src/community/search',
         'src/community/wearable-prompts', 'src/regimes', 'src/feature-flags',
         'src/talent-marketplace', 'src/extension-pair', 'src/scout']        # jest.config.js roots
IGNORE = [re.compile(p) for p in [r'/node_modules/', r'/dist/', r'^test/rls/', r'^test/rls-.*\.spec\.ts$']]

code = []
for d, _, fs in os.walk(root):
    if '/.git' in d or '/node_modules' in d:
        continue
    for f in fs:
        rel = os.path.relpath(os.path.join(d, f), root)
        if re.search(r'\.(ts|js|cjs|mjs)$', rel):
            code.append(rel)
codeset = set(code)
specs = sorted(f for f in code if f.endswith('.spec.ts') and any(f.startswith(r + '/') for r in ROOTS)
               and not any(p.search(f) for p in IGNORE))

IMP = re.compile(r"""(?:from\s+|require\(\s*|import\(\s*|import\s+|jest\.mock\(\s*)['"](\.{1,2}/[^'"]+)['"]""")
text, deps = {}, {}
for f in code:
    try:
        body = open(os.path.join(root, f), encoding='utf8', errors='replace').read()
    except OSError:
        body = ''
    text[f] = body
    ds = set()
    for m in IMP.finditer(body):
        p = os.path.normpath(os.path.join(os.path.dirname(f), m.group(1)))
        for c in (p, p + '.ts', p + '.js', p + '.cjs', p + '/index.ts', p + '/index.js'):
            if c in codeset:
                ds.add(c)
                break
    deps[f] = ds

memo = {}
def closure(f):
    if f in memo:
        return memo[f]
    seen, stack = set(), [f]
    while stack:
        g = stack.pop()
        if g in seen:
            continue
        seen.add(g)
        stack.extend(deps.get(g, ()))
    memo[f] = seen
    return seen

READER = re.compile(r'\b(readFileSync|readdirSync|readdir|readFile|existsSync|statSync|lstatSync|opendirSync|globSync|fast-glob|spawnSync|execSync|execFileSync)\b')
LIT = re.compile(r"""['"`]([^'"`\n]{1,200})['"`]""")
CALL = re.compile(r"""(?:join|resolve)\(([^()]*)\)""")

def prefixes(p):
    segs = p.split('/')
    return {'/'.join(segs[:k]) for k in range(1, len(segs) + 1)}

def reads(files, paths):
    """Return {path: [evidence]} for changed paths named by reader files."""
    hits = {}
    for f in files:
        body = text.get(f, '')
        if not READER.search(body):
            continue
        lits = {m.group(1).strip('/') for m in LIT.finditer(body)}
        for m in CALL.finditer(body):
            args = re.findall(r"""['"]([^'"]+)['"]""", m.group(1))
            args = [a for a in args if a not in ('..', '.')]
            for i in range(len(args)):
                lits.add('/'.join(a.strip('/') for a in args[i:]))
        for p in paths:
            pre = prefixes(p)
            named = sorted(l for l in lits if l in pre)
            if named:
                hits.setdefault(p, []).append(f"{f}: {named}")
    return hits

sel = []
print(f"# default-config specs: {len(specs)}; side X paths: {len(X)}; side Y paths: {len(Y)}")
for s in specs:
    cl = closure(s)
    cx, cy = sorted(cl & set(X)), sorted(cl & set(Y))
    rx, ry = reads(cl, X), reads(cl, Y)
    dep_x = bool(cx or rx)
    dep_y = bool(cy or ry)
    if dep_x and dep_y:
        sel.append(s)
        why = []
        if cx: why.append(f"closure-X={cx[:3]}")
        if rx: why.append(f"reads-X={sorted(rx)[:3]}")
        if cy: why.append(f"closure-Y={cy[:3]}")
        if ry: why.append(f"reads-Y={ {k: v[:2] for k, v in list(ry.items())[:3]} }")
        print(f"SELECT {s} | " + ' | '.join(why))
    elif ry:
        print(f"READS-Y-ONLY {s} | {ry}")
print(f"# selected (depends on both sides): {len(sel)}")
for s in sel:
    print(s)
