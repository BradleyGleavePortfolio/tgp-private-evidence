"""Reviewer A: read/hash specified evidence only; never import/execute candidate code."""
from pathlib import Path
import hashlib
import json
import subprocess
from datetime import datetime, timezone

ROOT = Path("/home/user/workspace")
OUT = Path(__file__).parent

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def manifest(rel):
    p = ROOT / rel
    entries = []
    for line in p.read_text().splitlines():
        if not line.strip():
            continue
        expected, name = line.split(maxsplit=1)
        target = p.parent / name.lstrip("*")
        actual = sha(target)
        entries.append({"path": str(target.relative_to(ROOT)), "expected": expected,
                        "actual": actual, "matches": actual == expected})
    return {"path": rel, "sha256": sha(p), "count": len(entries),
            "all_match": all(e["matches"] for e in entries), "entries": entries}

def git(*args):
    c = subprocess.run(["git", "--no-optional-locks", "-C",
                        str(ROOT / "worktrees/s2-runner53"), *args],
                       capture_output=True, text=True)
    return {"args": list(args), "exit": c.returncode, "stdout": c.stdout,
            "stderr": c.stderr}

files = [
    "execution/EXECUTION_REPAIR_WAVE_2.md",
    "execution/DISPATCHES.md",
    "execution/s2-setup-prep/REPORT.md",
    "execution/s2-setup-prep/SLOT_REQUEST_05_SETUP_ONLY.md",
    "execution/s2-setup-prep/SLOT_REQUEST_06_CONTROLS_AND_PROOF.md",
    "execution/s2-setup-prep/infra/s2-fixture-r53.sh",
    "execution/s2-setup-prep/run-composition-r53-v5.3.1-when-granted.sh",
    "execution/s2-setup-prep/runs/setup-30-grant05.exit",
    "execution/s2-setup-prep/runs/setup-30-grant05.log",
    "execution/s2-setup-prep/grant05/install-stamp.actual.txt",
    "execution/s2-runner53/controls/20260922T043943Z/CONTROLS_RESULT.txt",
    "execution/audits/s2-r53/a/revision-1/REPORT.md",
    "execution/audits/s2-r53/a/revision-1/FINDINGS.json",
    "execution/audits/s2-r53/b/revision-1/REPORT.md",
    "worktrees/s2-runner53/package.json",
    "worktrees/s2-runner53/package-lock.json",
    "worktrees/s2-runner53/prisma/schema.prisma",
    "worktrees/s2-runner53/scripts/release.sh",
    "worktrees/s2-runner53/test/release/s1s2-composition.sh",
    "worktrees/s2-runner53/test/db/s1-r4-truncate-discriminator.sh",
    "worktrees/s2-runner53/test/db/s1-harness-guard.spec.sh",
    "worktrees/s2-runner53/node_modules/.s2-composition-install-stamp",
    "worktrees/s2-runner53/node_modules/.prisma/client/index.js",
    "worktrees/s2-runner53/node_modules/prisma/package.json",
    "worktrees/s2-runner53/node_modules/prisma/build/index.js",
    "worktrees/s2-runner53/node_modules/prisma/build/child.js",
]
external = [
    "/usr/local/lib/node_modules/npm/package.json",
    "/usr/local/lib/node_modules/npm/node_modules/libnpmexec/lib/run-script.js",
    "/usr/local/lib/node_modules/npm/node_modules/@npmcli/run-script/lib/make-spawn-args.js",
    "/usr/local/lib/node_modules/npm/node_modules/@npmcli/run-script/lib/run-script-pkg.js",
]
manifests = [
    "execution/s2-runner54/SHA256SUMS.outer",
    "execution/s2-setup-prep/SHA256SUMS.outer",
    "execution/audits/s2-r53/a/revision-1/SHA256SUMS",
    "execution/audits/s2-r53/b/revision-1/SHA256SUMS",
]
data = {
    "collected_utc": datetime.now(timezone.utc).isoformat(),
    "class": "STATIC_READ_HASH_GIT_ONLY",
    "executed_candidate_code": False,
    "current_peer_B_access": False,
    "git": [git("rev-parse", "HEAD", "HEAD^{tree}"),
            git("status", "--porcelain", "--untracked-files=all")],
    "manifests": [manifest(m) for m in manifests],
    "input_files": [{"path": f, "sha256": sha(ROOT / f),
                     "bytes": (ROOT / f).stat().st_size} for f in files],
    "installed_npm_consumers": [{"path": f, "sha256": sha(Path(f))}
                              for f in external],
    "limitations": [
        "No current process census, environment read, runtime launch, tool version invocation, lock probe, or network request.",
        "Installed dependency excerpts are code inspection, not observed child behavior.",
        "Shared governance documents may later receive additive changes; hashes bind this review's read time.",
    ],
}
OUT.mkdir(parents=True, exist_ok=True)
(OUT / "STATIC_EVIDENCE.json").write_text(json.dumps(data, indent=2) + "\n")

# Preserve small, exact excerpts with line and character offsets from minified code.
path = ROOT / "worktrees/s2-runner53/node_modules/prisma/build/index.js"
text = path.read_text()
sections = [
    ("Checkpoint default and detach", "async function check(e){", 2700),
    ("Checkpoint fork options", "function getForkOpts(e)", 470),
    ("Reached CLI checkpoint call", "async function V1e(", 1400),
    ("Command dispatch calls checkpoint", "let p=this.cmds[l];if(p){let f=V1e", 900),
    ("Schema engine spawn", "this.child=(0,WEe.spawn)", 410),
]
extracts = []
for label, needle, size in sections:
    pos = text.find(needle)
    assert pos >= 0, label
    extracts.append({"label": label, "path": str(path.relative_to(ROOT)),
                     "sha256": sha(path), "line": text.count("\n", 0, pos) + 1,
                     "character_offset": pos, "excerpt": text[pos:pos+size]})
for label, name, start, stop in [
    ("npm inherits client environment",
     "/usr/local/lib/node_modules/npm/node_modules/@npmcli/run-script/lib/make-spawn-args.js", 19, 37),
    ("Generated Prisma client library engine",
     str(ROOT / "worktrees/s2-runner53/node_modules/.prisma/client/index.js"), 3333, 3350),
    ("Checkpoint worker lifecycle and optional request",
     str(ROOT / "worktrees/s2-runner53/node_modules/prisma/build/child.js"), 82814, 82909),
]:
    p = Path(name)
    extracts.append({"label": label, "path": name, "sha256": sha(p),
                     "line_start": start, "line_end": stop,
                     "excerpt": "\n".join(p.read_text().splitlines()[start-1:stop])})
(OUT / "CLIENT_GRAPH_EXCERPTS.json").write_text(json.dumps(extracts, indent=2) + "\n")
print(json.dumps({"manifests": [{"path": m["path"], "sha256": m["sha256"],
                                "count": m["count"], "all_match": m["all_match"]}
                               for m in data["manifests"]], "git": data["git"]}, indent=2))
