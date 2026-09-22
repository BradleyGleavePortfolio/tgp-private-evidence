"""Read-only source/packet checks; all outputs and local object import stay in auditor A's directory."""
import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import time

START = time.monotonic()
ROOT = Path("/home/user/workspace")
OUT = ROOT / "execution/audits/s1s2-final/a"
SRC = ROOT / "worktrees/s2-composition"
HEAD = "9742037b153221de565e651ad8ba3b721bc0fb31"
S1 = "b7d7fe5964680050ab441c195055ea946282a9c3"
R4 = "41f4d6a985e5037bf53831a38ed00a9a4314cf7d"
S2 = "e15e25c28824b43558f7c231eec26a5ac64bafa9"
S3 = "5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06"
MIG = "prisma/migrations/20261224000000_rls_close_public_exposure/"
records = {}

def run(args, cwd=SRC, env=None):
    p = subprocess.run(args, cwd=cwd, env=env, capture_output=True, timeout=20)
    return {"exit": p.returncode, "stdout": p.stdout.decode(errors="replace"),
            "stderr": p.stderr.decode(errors="replace")}

def git(*args):
    return run(["git", *args])

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

records["utc"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
records["identity"] = {k: git(*args) for k, args in {
    "head": ["rev-parse", "HEAD"],
    "tree": ["rev-parse", "HEAD^{tree}"],
    "status": ["status", "--porcelain", "--untracked-files=all"],
    "parents": ["show", "-s", "--format=%P", HEAD],
}.items()}
records["ancestor_checks"] = {h: git("merge-base", "--is-ancestor", h, HEAD) for h in [S1, S2, R4]}
paths = [MIG+"migration.sql", MIG+"down.sql", MIG+"verify.sql",
         "test/db/_support/s1-target-guard.sh",
         "test/db/_support/supabase-like-bootstrap.sql",
         "prisma/migrations/rls_fitness_backend.sql", "package.json", "package-lock.json",
         "scripts/release.sh", "scripts/release-required-verifiers.txt"]
records["blobs"] = {}
for p in paths:
    records["blobs"][p] = {"sha256": sha(SRC/p), **{
        h: git("rev-parse", f"{h}:{p}") for h in [HEAD, S1, R4, S2]}}
records["s2_preservation"] = git("diff", "--name-status", S2, HEAD, "--",
                                ".github", "scripts", "docs", "Dockerfile", "package.json", "package-lock.json", "test/ci")
records["s1_delta"] = git("diff", S1, HEAD, "--", "prisma", "test/db")

manifests = [
    ROOT/"execution/s2-composition/composition/20260922T000811Z/SHA256SUMS.b1-frozen",
    ROOT/"execution/s2-composition/composition/20260922T000811Z/SHA256SUMS.runner-written",
    ROOT/"repos/tgp-private-evidence/2026-09-20/remediation/s2-r3/revision-1/ARCHIVE_SHA256SUMS",
]
records["manifests"] = {}
for manifest in manifests:
    checked = []
    for line in manifest.read_text().splitlines():
        m = re.match(r"^([0-9a-f]{64})\s+[ *]?(.+)$", line)
        if not m:
            checked.append({"unparsed": line})
            continue
        expected, name = m.groups()
        f = manifest.parent/name
        actual = sha(f) if f.is_file() else None
        checked.append({"name": name, "expected": expected, "actual": actual, "match": actual == expected})
    records["manifests"][str(manifest.relative_to(ROOT))] = checked

packet = ROOT/"execution/s2-composition/composition/20260922T000811Z/harness"
records["real_parent_replay"] = {}
for label in ["P1", "P2"]:
    text = (packet/f"{label}.parent-deploy.log").read_text()
    names = re.findall(r"^Applying migration `([^`]+)`", text, flags=re.M)
    records["real_parent_replay"][label] = {"applications": len(names), "unique": len(set(names)),
        "first": names[:1], "last": names[-1:], "candidate_absent": MIG.split("/")[-2] not in names}
log = (packet/"harness.log").read_text()
records["b1_assertion_counts"] = {"pass": len(re.findall(r"^PASS  ", log, flags=re.M)),
    "fail": len(re.findall(r"^FAIL  ", log, flags=re.M))}
records["quoted_truncate_actual"] = re.findall(r'[^;]*MuxProcessedEvent[^;]*TRUNCATE[^;]*', log)
records["telemetry_lines"] = {}
for label in ["C1","C2","C8"]:
    text = (packet/f"{label}.release.log").read_text().splitlines()
    records["telemetry_lines"][label] = [
        {"line": i+1, "text": s} for i,s in enumerate(text)
        if "pending_before" in s or "ALL_APPLIED" in s or s == "0" or "Either --url" in s]

# Isolated local, bare object database solely to read the retained S3 bundle.
# No source worktree, original repository, network, hooks, commits or pushes.
bare = OUT/"s3-readonly-objects.git"
env = dict(os.environ)
common = git("rev-parse", "--git-common-dir")["stdout"].strip()
env["GIT_ALTERNATE_OBJECT_DIRECTORIES"] = str((SRC/common/"objects").resolve())
env["GIT_TERMINAL_PROMPT"] = "0"
bundle = ROOT/"repos/tgp-private-evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/s3-backend-5c7b42b3.bundle"
records["s3_local_import"] = {"bundle_sha256": sha(bundle)}
records["s3_local_import"]["init"] = run(["git", "init", "--bare", str(bare)], cwd=OUT)
records["s3_local_import"]["fetch"] = run(["git", "--git-dir", str(bare), "-c", "gc.auto=0",
    "fetch", "--no-tags", str(bundle), S3], cwd=OUT, env=env)
if records["s3_local_import"]["fetch"]["exit"] == 0:
    for path in [".github/workflows/dependency-audit.yml", "fly.toml", "package.json"]:
        result = run(["git", "--git-dir", str(bare), "show", f"{S3}:{path}"], cwd=OUT, env=env)
        records["s3_local_import"][path] = result
    records["s3_local_import"]["changed_files"] = run(["git", "--git-dir", str(bare),
        "diff", "--name-status", "c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7", S3], cwd=OUT, env=env)
records["elapsed_seconds"] = round(time.monotonic()-START, 3)
(OUT/"STATIC_EVIDENCE.json").write_text(json.dumps(records, indent=2)+"\n")
print(json.dumps({
    "elapsed": records["elapsed_seconds"],
    "identity": records["identity"],
    "manifest_counts": {k: {"total": len(v), "matched": sum(x.get("match",False) for x in v),
                           "nonmatching": [x for x in v if not x.get("match",False)]} for k,v in records["manifests"].items()},
    "parent_replay": records["real_parent_replay"],
    "assertions": records["b1_assertion_counts"],
    "s2_preservation": records["s2_preservation"],
    "s3_import": records["s3_local_import"]["fetch"]
}, indent=2))
