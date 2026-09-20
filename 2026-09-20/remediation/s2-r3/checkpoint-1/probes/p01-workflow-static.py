#!/usr/bin/env python3
"""Static structural probe over .github/workflows/*.yml (offline).
Checks: YAML parses; no `${{ inputs.* }}` / `${{ github.event.inputs.* }}` inside any run: text;
every operator workflow with an `app` input has the allowlist guard step; no operator workflow
other than fly-deploy.yml invokes a mutating flyctl machine/deploy verb; fly-logs-dump.yml absent."""
import sys, re, glob, os, yaml
root = sys.argv[1] if len(sys.argv) > 1 else '.'
os.chdir(root)
bad = 0
files = sorted(glob.glob('.github/workflows/*.yml'))
inline = re.compile(r'\$\{\{\s*(github\.event\.)?inputs\.')
mut = re.compile(r'flyctl\s+(machine[s]?\s+(start|stop|restart|destroy|kill|update)|deploy|scale)\b')
for f in files:
    with open(f) as fh:
        text = fh.read()
    try:
        doc = yaml.safe_load(text)
    except Exception as e:
        print(f'FAIL {f}: yaml parse error {e}'); bad += 1; continue
    on = doc.get('on') or doc.get(True)
    is_operator = f.endswith('(operator)') or 'operator' in (doc.get('name') or '').lower()
    inputs = {}
    if isinstance(on, dict) and isinstance(on.get('workflow_dispatch'), dict):
        inputs = (on['workflow_dispatch'] or {}).get('inputs') or {}
    for jname, job in (doc.get('jobs') or {}).items():
        for i, step in enumerate(job.get('steps') or []):
            run = step.get('run')
            if run and inline.search(run):
                print(f'FAIL {f} job {jname} step {i} ({step.get("name")}): input interpolated inside run:'); bad += 1
            if run and is_operator and mut.search(run):
                print(f'FAIL {f} job {jname} step {i}: mutating flyctl verb in operator workflow'); bad += 1
    if is_operator and 'app' in inputs:
        has_guard = any(s.get('name') == 'Validate Fly app target' and 'backend-spring-lake-3890)' in (s.get('run') or '')
                        for j in (doc.get('jobs') or {}).values() for s in (j.get('steps') or []))
        if not has_guard:
            print(f'FAIL {f}: operator workflow with app input lacks allowlist guard'); bad += 1
        else:
            print(f'ok   {f}: allowlist guard present')
if os.path.exists('.github/workflows/fly-logs-dump.yml'):
    print('FAIL fly-logs-dump.yml still present'); bad += 1
else:
    print('ok   fly-logs-dump.yml absent')
print(f'{len(files)} workflows parsed; failures={bad}')
sys.exit(1 if bad else 0)
