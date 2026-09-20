"""Read-only R2-A evidence checks. Run from any directory; no candidate writes."""
from pathlib import Path
import datetime
import hashlib
import json
import re
import subprocess

ROOT = Path("/home/user/workspace")
WORK = ROOT / "worktrees/s3"
PACKET = ROOT / "repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2"
BASE = "c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7"


def git(*args):
    return subprocess.check_output(["git", "-C", str(WORK), *args], text=True).strip()


def git_blob(ref, path):
    return subprocess.check_output(["git", "-C", str(WORK), "show", ref + ":" + path])


checks = {}
for line in (PACKET / "SHA256SUMS.txt").read_text().splitlines():
    expected, name = line.split("  ", 1)
    actual = hashlib.sha256((PACKET / name).read_bytes()).hexdigest()
    checks[name] = {"match": expected == actual, "actual_sha256": actual}

log = (PACKET / "logs/10-full-jest-sharded.log").read_text()
passes = re.findall(r"^PASS (\S+)", log, re.M)
config = (WORK / "jest.config.js").read_text()
roots = re.findall(r"'<rootDir>/([^']+)'", config.split("roots: [")[1].split("],")[0])
selected = sorted({
    str(p.relative_to(WORK))
    for root in roots
    for p in (WORK / root).rglob("*.spec.ts")
    if not str(p.relative_to(WORK)).startswith("test/rls/")
    and not re.match(r"test/rls-.*\.spec\.ts$", str(p.relative_to(WORK)))
})
omitted = sorted(set(selected) - set(passes))
changed = git("diff", "--name-only", BASE, "HEAD").splitlines()
changed_specs = [p for p in changed if p.endswith(".spec.ts")]
lock = json.loads((WORK / "package-lock.json").read_text())
package = json.loads((WORK / "package.json").read_text())
lint = (PACKET / "logs/06-lint.log").read_text()
lint_paths = re.findall(r"^/home/user/workspace/worktrees/s3-backend/(.+)$", lint, re.M)
result = {
    "observed_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "method": "Static read-only checks, not a new test-suite execution",
    "head": git("rev-parse", "HEAD"),
    "tree": git("rev-parse", "HEAD^{tree}"),
    "base_merge_base": git("merge-base", BASE, "HEAD"),
    "status_porcelain": git("status", "--porcelain=v1"),
    "commit_count": int(git("rev-list", "--count", BASE + "..HEAD")),
    "commit_identities": sorted(set(git("log", "--format=%an <%ae>|%cn <%ce>", BASE + "..HEAD").splitlines())),
    "checksum_results": checks,
    "suite_selection": {
        "static_discovery_count": len(selected),
        "pass_lines": len(passes),
        "unique_pass_paths": len(set(passes)),
        "duplicates": sorted({p for p in passes if passes.count(p) > 1}),
        "changed_specs": changed_specs,
        "changed_specs_missing_pass": sorted(set(changed_specs) - set(passes)),
        "omitted_suite_base_identity": {
            p: git_blob(BASE, p) == (WORK / p).read_bytes()
            for p in omitted
        },
        "totals": {
            name: sum(map(int, re.findall(pattern, log)))
            for name, pattern in {
                "passed_suites": r"Test Suites:.*?(\d+) passed",
                "passed_tests": r"Tests:.*?(\d+) passed",
                "skipped_tests": r"Tests:.*?(\d+) skipped",
                "todo_tests": r"Tests:.*?(\d+) todo",
            }.items()
        },
        "summary_lines": [
            line for line in log.splitlines()
            if re.search(r"^Test Suites:|^Tests:|^=== shard|^overall_exit|^exit=", line)
        ],
    },
    "lint_warning_paths_intersect_changed_paths": sorted(set(lint_paths) & set(changed)),
    "lock": {
        "version": lock["lockfileVersion"],
        "entries": len(lock["packages"]),
        "manifest_dependency_sections_match": all(
            lock["packages"][""].get(k) == package.get(k)
            for k in ["dependencies", "devDependencies"]
        ),
        "same_as_prefixed_head_925780e0": git_blob("925780e0", "package-lock.json")
        == (WORK / "package-lock.json").read_bytes(),
        "missing_integrity_or_nonregistry": [
            name for name, entry in lock["packages"].items()
            if name and (
                not entry.get("integrity")
                or not entry.get("resolved", "").startswith("https://registry.npmjs.org/")
            )
        ],
        "overrides": package["overrides"],
    },
}
print(json.dumps(result, indent=2))
