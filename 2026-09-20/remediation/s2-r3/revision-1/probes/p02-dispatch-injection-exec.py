#!/usr/bin/env python3
"""Execution-level adversarial probe (offline). For each operator workflow, extract every real
`run:` step text, execute it with bash under hostile dispatch-input values supplied the way the
runner does (as environment variables from the step's env: map), with a fake `flyctl` on PATH that
records its argv verbatim and never contacts the network. Asserts:
  (1) no marker file is created by any hostile payload (no command substitution / separator execution);
  (2) the 'Validate Fly app target' step exits non-zero for every hostile value and 0 for the allowed app;
  (3) when the allowed app is supplied, flyctl receives `--app`/`-a` followed by exactly the app string.
Steps that use `${{ secrets.* }}` get harmless fake values; `${{ inputs.* }}` get the probe value."""
import sys, os, re, glob, subprocess, tempfile, json, yaml
root = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else '.')
os.chdir(root)
HOSTILE = [
    'x$(printf hostile > "$MARKER")y',
    'x`printf hostile > "$MARKER"`y',
    'x"; printf hostile > "$MARKER"; echo "',
    "x'; printf hostile > \"$MARKER\"; echo '",
    'x\nprintf hostile > "$MARKER"\n',
    'x; printf hostile > "$MARKER" #',
    'x && printf hostile > "$MARKER"',
    'x | printf hostile > "$MARKER"',
    '$MARKER',
    '',
]
ALLOWED = 'backend-spring-lake-3890'
expr = re.compile(r'\$\{\{\s*([^}]+?)\s*\}\}')
def resolve(v, inputs):
    def sub(m):
        e = m.group(1)
        if e.startswith('inputs.'): return inputs.get(e[7:], '')
        if e.startswith('github.event.inputs.'): return inputs.get(e[20:], '')
        if e.startswith('secrets.'): return 'fake-' + e[8:]
        return 'unresolved'
    return expr.sub(sub, str(v))
fails = 0; runs = 0
with tempfile.TemporaryDirectory() as td:
    bindir = os.path.join(td, 'bin'); os.mkdir(bindir)
    argvlog = os.path.join(td, 'flyctl-argv.jsonl')
    with open(os.path.join(bindir, 'flyctl'), 'w') as fh:
        fh.write('#!/usr/bin/env python3\nimport sys,json\nopen(%r,"a").write(json.dumps(sys.argv[1:])+"\\n")\n' % argvlog)
        fh.write('if sys.argv[1:3]==["secrets","list"]: print("NAME DIGEST CREATED\\nRECENT_AUTH_SECRET abc 1m\\nRECENT_AUTH_TTL_MS def 1m\\nFEATURE_SCOUT_INGEST x 1m\\nFEATURE_EXTENSION_PAIRING y 1m\\nDATABASE_URL z 1m\\nDIRECT_URL z 1m\\nAPPLE_NONCE_REQUIRED z 1m\\nPUBLIC_INVITE_BASE_URL z 1m\\nPUBLIC_WEB_SIGNUP_URL z 1m\\nAPP_STORE_URL z 1m\\nPLAY_STORE_URL z 1m\\nCORS_ORIGINS z 1m\\nSTRIPE_PRICE_ID_FITNESS z 1m\\nBILLING_ENFORCEMENT z 1m\\nSTRIPE_SECRET_KEY z 1m\\nSTRIPE_WEBHOOK_SECRET z 1m\\nSENTRY_DSN z 1m")\n')
    os.chmod(os.path.join(bindir, 'flyctl'), 0o755)
    for f in sorted(glob.glob('.github/workflows/fly-*.yml')):
        doc = yaml.safe_load(open(f))
        if 'operator' not in (doc.get('name') or '').lower(): continue
        on = doc.get('on') or doc.get(True)
        inputs_def = ((on or {}).get('workflow_dispatch') or {}).get('inputs') or {}
        if 'app' not in inputs_def: continue
        for jname, job in (doc.get('jobs') or {}).items():
            for i, step in enumerate(job.get('steps') or []):
                run = step.get('run')
                if not run: continue
                name = step.get('name') or f'step{i}'
                for payload in HOSTILE + [ALLOWED]:
                    inputs = {k: (payload if k == 'app' else ('SET' if k == 'confirm' else 'true' if k.startswith('feature_') else '5' if k == 'lines' else '')) for k in inputs_def}
                    env = {'PATH': bindir + ':' + os.environ['PATH'], 'HOME': td, 'MARKER': os.path.join(td, 'marker')}
                    for k, v in (step.get('env') or {}).items(): env[k] = resolve(v, inputs)
                    if os.path.exists(env['MARKER']): os.remove(env['MARKER'])
                    if os.path.exists(argvlog): os.remove(argvlog)
                    r = subprocess.run(['bash', '-e', '-c', resolve(run, inputs)], env=env, capture_output=True, text=True, timeout=60)
                    runs += 1
                    marker = os.path.exists(env['MARKER'])
                    tag = f'{f} [{jname}/{name}] payload={payload!r:.40}'
                    if marker:
                        print(f'FAIL {tag}: hostile payload EXECUTED (marker written) exit={r.returncode}'); fails += 1
                    if name == 'Validate Fly app target':
                        if payload == ALLOWED and r.returncode != 0:
                            print(f'FAIL {tag}: allowed app refused'); fails += 1
                        if payload != ALLOWED and r.returncode == 0:
                            print(f'FAIL {tag}: hostile app ACCEPTED'); fails += 1
                    if payload == ALLOWED and os.path.exists(argvlog):
                        for line in open(argvlog):
                            argv = json.loads(line)
                            for flag in ('--app', '-a'):
                                if flag in argv and argv[argv.index(flag) + 1] != ALLOWED:
                                    print(f'FAIL {tag}: flyctl got app {argv[argv.index(flag)+1]!r}'); fails += 1
                    if payload != ALLOWED and os.path.exists(argvlog) and 'flyctl' in run:
                        # data-not-code: if flyctl was called at all, the hostile string must arrive as ONE argv element
                        for line in open(argvlog):
                            argv = json.loads(line)
                            for flag in ('--app', '-a'):
                                if flag in argv and argv[argv.index(flag) + 1] != payload:
                                    print(f'FAIL {tag}: hostile app string was split/altered: {argv!r}'); fails += 1
        print(f'ok   {f}: all run: steps executed under {len(HOSTILE)} hostile payloads + allowed app')
print(f'step executions={runs} failures={fails}')
sys.exit(1 if fails else 0)
