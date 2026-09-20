"""Independent bounded R2 probes. No network, install, credentials, or candidate writes."""
import hashlib
import io
import json
import os
from pathlib import Path
import subprocess
import zipfile
import yaml

OUT = Path(__file__).resolve().parent
ROOT = Path("/home/user/workspace/worktrees/s2")
SHA = "0b05fcf5352287109ac88ed2ba3682e441e3a076"
REPO = "BradleyGleavePortfolio/growth-project-backend"
os.environ["TMPDIR"] = str(OUT)

def write(p, text):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(text)
    return p

def execute(label, args, *, cwd=ROOT, env=None):
    e = {"PATH": os.environ["PATH"], "HOME": str(OUT), "TMPDIR": str(OUT)}
    if env:
        e.update(env)
    r = subprocess.run(args, cwd=cwd, env=e, text=True, capture_output=True, timeout=20)
    write(OUT / (label + ".log"), f"exit={r.returncode}\n{r.stdout}\n{r.stderr}")
    print(f"{label}: exit={r.returncode}")
    return r

binpath = OUT / "bin"
binpath.mkdir(exist_ok=True)
write(binpath / "gh", """#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
p=Path(os.environ['FIXTURES'])
mapping=json.loads((p/'map.json').read_text())
if len(sys.argv)!=3 or sys.argv[1]!='api' or sys.argv[2] not in mapping:
    print('fixture endpoint absent', file=sys.stderr); sys.exit(1)
sys.stdout.buffer.write((p/mapping[sys.argv[2]]).read_bytes())
""").chmod(0o755)
write(binpath / "flyctl", """#!/usr/bin/env bash
if [[ "$1" == machine && "$2" == list ]]; then
  printf '[{"id":"synthetic-machine","config":{"metadata":{"fly_process_group":"app"}}}]'
else
  printf 'fake flyctl invoked\\n'
fi
""").chmod(0o755)
safeenv = {"PATH": str(binpath) + ":" + os.environ["PATH"]}

# Full gate, using the real release lockfile and independently authored API data.
fx = OUT / "fixtures"
fx.mkdir(exist_ok=True)
mapping = {}
def api(path, data):
    key = hashlib.sha256(path.encode()).hexdigest()
    mapping[path] = key
    (fx/key).write_bytes(data if isinstance(data, bytes) else json.dumps(data).encode())
    write(fx/"map.json", json.dumps(mapping, indent=2))

required = [
    ("ci.yml", ["build-and-test", "rls-floor-guard", "rls-live-tests", "mwb-3-live-tests"]),
    ("codeql.yml", ["CodeQL JS/TS (javascript-typescript)"]),
    ("sbom.yml", ["build-sbom"]),
    ("dependency-audit.yml", ["npm audit (high+critical, whole graph)"]),
]
runs = []
for n, (wf, jobs) in enumerate(required, 1):
    runs.append(dict(id=n, path=".github/workflows/"+wf, run_number=n,
                     head_sha=SHA, head_branch="main", event="push", status="completed",
                     conclusion="success", repository={"full_name": REPO},
                     head_repository={"full_name": REPO}))
    api(f"repos/{REPO}/actions/runs/{n}/jobs?per_page=100",
        {"jobs": [{"name": j, "status": "completed", "conclusion": "success"} for j in jobs]})
runpath = f"repos/{REPO}/actions/runs?head_sha={SHA}&per_page=100"
api(runpath, {"workflow_runs": runs})
analysispath = f"repos/{REPO}/code-scanning/analyses?ref=refs/heads/main&per_page=100"
analysis = dict(id=5, commit_sha=SHA, created_at="2026-09-20T00:00:00Z",
                tool={"name": "CodeQL"}, error="", rules_count=42, results_count=0)
api(analysispath, [analysis])
api(f"repos/{REPO}/actions/runs/3/artifacts?per_page=100",
    {"artifacts": [{"id": 6, "name": "sbom-cyclonedx-"+SHA, "expired": False}]})
envpath = f"repos/{REPO}/environments/production"
protected = {"can_admins_bypass": False,
             "protection_rules": [{"type": "required_reviewers", "reviewers": [{"type": "User"}]}]}
api(envpath, protected)
def sbom_zip(doc):
    body = json.dumps(doc).encode()
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w") as z:
        z.writestr("sbom.cdx.json", body)
        z.writestr("sbom.cdx.json.sha256", hashlib.sha256(body).hexdigest()+"  sbom.cdx.json\n")
    api(f"repos/{REPO}/actions/artifacts/6/zip", buf.getvalue())

sbom = json.loads(Path("/home/user/workspace/repos/evidence/2026-09-20/remediation/s2-r2/revision-3/local-omit-dev-sbom.cdx.json").read_text())
sbom_zip(sbom)
def gate(label):
    return execute(label, ["bash", str(ROOT/"scripts/ci/release-evidence-gate.sh")],
                   env={**safeenv, "FIXTURES": str(fx), "GH_REPO": REPO, "RELEASE_SHA": SHA,
                        "DISPATCH_SHA": SHA, "OUT_DIR": str(OUT/label)})
assert gate("p01-gate-control").returncode == 0
api(analysispath, [{**analysis, "rules_count": 0}])
assert gate("p02-empty-codeql").returncode != 0
api(analysispath, [analysis])
api(envpath, {"can_admins_bypass": True, "protection_rules": []})
assert gate("p03-unprotected-environment").returncode != 0
api(envpath, protected)
api(runpath, {"workflow_runs": runs + [{**runs[0], "id": 100, "run_number": 100, "conclusion": "failure"}]})
assert gate("p04-newest-failed").returncode != 0
api(runpath, {"workflow_runs": runs})
sbom_zip({"bomFormat": "CycloneDX", "components": [
    {"name": n, "version": "999.999.999"}
    for n in ["@nestjs/core", "@prisma/client", "prisma"]]})
assert gate("p05-incomplete-wrong-version-sbom").returncode == 0

# Substitute workflow expression values as Actions would; harmless command
# substitution creates a marker, and flyctl is a local no-network stand-in.
logs = yaml.safe_load((ROOT/".github/workflows/fly-logs-dump.yml").read_text())
cmd = logs["jobs"]["dump"]["steps"][1]["run"]
line = next(x for x in cmd.splitlines() if x.startswith("MID="))
marker = OUT/"logs-app-expression-executed.txt"
app = f"synthetic-app$(printf injected > {marker})"
expanded = line.replace("${{ inputs.app }}", app)
write(OUT/"p06-expanded-logs-line.sh", expanded+"\n")
assert execute("p06-logs-input-shell-execution", ["bash", "-e", "-c", expanded], env=safeenv).returncode == 0
assert marker.read_text() == "injected"

recent = yaml.safe_load((ROOT/".github/workflows/fly-recent-auth-set.yml").read_text())
cmd = next(s["run"] for s in recent["jobs"]["set-secrets"]["steps"] if s.get("name") == "Set recent-auth secrets on Fly")
marker = OUT/"recent-auth-app-expression-executed.txt"
app = f"synthetic-app$(printf injected > {marker})"
expanded = cmd.replace("${{ inputs.app }}", app)
write(OUT/"p07-expanded-recent-auth-step.sh", expanded)
assert execute("p07-recent-auth-input-shell-execution", ["bash", "-e", "-c", expanded],
               env={**safeenv, "RECENT_AUTH_SECRET": "synthetic-not-secret", "RECENT_AUTH_TTL_MS": "100"}).returncode == 0
assert marker.read_text() == "injected"

# Only step 4 of release.sh, byte-identical except hard-coded output log path.
# No Prisma/DB run: synthetic npx supplies exit status; no source is edited.
release = (ROOT/"scripts/release.sh").read_text()
start = release.index('echo "[release] step 4:')
end = release.index("# Count successfully applied", start)
block = release[start:end].replace("/tmp/prisma_verifier.log", str(OUT/"prisma_verifier.log"))
write(OUT/"release-step4-isolated.sh", "set -Eeuo pipefail\n"+block)
write(binpath/"npx", '#!/usr/bin/env bash\nprintf "synthetic verifier invocation\\n"\nexit "${PROBE_NPX_EXIT:-0}"\n').chmod(0o755)
fixture = OUT/"verifier-fixture"
write(fixture/"prisma/migrations/a/verify.sql", "DO $$ BEGIN NULL; END $$;\n")
assert execute("p08-verifier-success", ["bash", str(OUT/"release-step4-isolated.sh")], cwd=fixture,
               env={**safeenv, "DIRECT_URL": "synthetic"}).returncode == 0
assert execute("p09-verifier-failure", ["bash", str(OUT/"release-step4-isolated.sh")], cwd=fixture,
               env={**safeenv, "DIRECT_URL": "synthetic", "PROBE_NPX_EXIT": "1"}).returncode != 0
write(binpath/"find", '#!/usr/bin/env bash\necho "synthetic discovery failure" >&2\nexit 2\n').chmod(0o755)
assert execute("p10-verifier-discovery-failure", ["bash", str(OUT/"release-step4-isolated.sh")], cwd=fixture,
               env={**safeenv, "DIRECT_URL": "synthetic"}).returncode == 0

# Labels are descriptive, not build attestation or health-check verification.
machines = [{"id": "synthetic", "state": "started", "config": {"metadata": {"fly_process_group": "app"}},
             "image_ref": {"tag": "sha-"+SHA, "labels": {"GH_SHA": SHA, "GH_REPO": "other/repository"},
                           "registry": "other.registry", "repository": "other-image",
                           "digest": "sha256:"+"a"*64},
             "checks": [{"name": "ready", "status": "critical"}]}]
write(OUT/"p11-machines.json", json.dumps(machines))
assert execute("p11-image-label-only", ["bash", str(ROOT/"scripts/ci/verify-fly-release.sh")],
               env={"MACHINES_JSON": str(OUT/"p11-machines.json"), "RELEASE_SHA": SHA,
                    "IMAGE_LABEL": "sha-"+SHA}).returncode == 0
print("All bounded probes completed. Unexpected acceptances are findings/limits, not passing safety claims.")
