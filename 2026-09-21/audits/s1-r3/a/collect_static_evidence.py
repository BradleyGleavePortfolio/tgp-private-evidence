"""Read-only source/archive inspection. Writes only this auditor's output directory."""
import datetime
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path("/home/user/workspace")
SOURCE = ROOT / "initialization/recovered/s1-r3-b7d7fe5"
PACKET = ROOT / "repos/tgp-private-evidence/2026-09-20/remediation/s1-r3/revision-1"
OUT = ROOT / "execution/audits/s1-r3/a"

def run(*args):
    p = subprocess.run(args, cwd=SOURCE, text=True, capture_output=True)
    return {"command": list(args), "exit": p.returncode, "stdout": p.stdout, "stderr": p.stderr}

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

summary = (PACKET / "proof-run-04-head-b7d7fe5.log").read_text()
detail = (PACKET / "proof-run-04-head-b7d7fe5-harness-detail.log").read_text()
stamps = dict(line.split("=", 1) for line in summary.splitlines() if "=" in line and not line.startswith("PASS"))
files = {
    "harness_sha256": "test/db/s1-rls-close-public-exposure.sh",
    "guard_sha256": "test/db/_support/s1-target-guard.sh",
    "bootstrap_sha256": "test/db/_support/supabase-like-bootstrap.sql",
    "verify_sql_sha256": "prisma/migrations/20261224000000_rls_close_public_exposure/verify.sql",
    "migration_sql_sha256": "prisma/migrations/20261224000000_rls_close_public_exposure/migration.sql",
    "down_sql_sha256": "prisma/migrations/20261224000000_rls_close_public_exposure/down.sql",
    "package_lock_sha256": "package-lock.json",
}
checks = {}
for key, file in files.items():
    actual = sha(SOURCE / file)
    checks[file] = {"sha256": actual, "archived_stamp": stamps[key], "matches": actual == stamps[key]}
manifest = []
for line in (PACKET / "ARCHIVE_SHA256SUMS").read_text().splitlines():
    expected, name = line.split(maxsplit=1)
    actual = sha(PACKET / name)
    manifest.append({"file": name, "sha256": actual, "matches": actual == expected})
shell = [run("bash", "-n", f) for f in [
    "test/db/_support/s1-target-guard.sh",
    "test/db/s1-harness-guard.spec.sh",
    "test/db/s1-rls-close-public-exposure.sh",
]]
data = {
    "observed_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "reviewer": {
        "assignment": "Independent T4 S1 R3 auditor A",
        "observable_identity": "API assistant; concrete model/version/reasoning setting not exposed",
        "requested_model": "No auditor-specific model selector exposed in task",
        "not_claimed": "Builder routing labels are not this reviewer's identity",
        "db_tests_executed": False,
        "peer_r3_b_report_read": False,
    },
    "source": str(SOURCE),
    "archive": str(PACKET),
    "git_identity": run("git", "rev-parse", "HEAD", "HEAD^{tree}"),
    "git_status": run("git", "status", "--porcelain=v1", "--untracked-files=all"),
    "git_delta_check": run("git", "diff", "--check", "c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7", "HEAD"),
    "git_commits": run("git", "log", "c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7..HEAD", "--format=%H|%an <%ae>|%cn <%ce>|%(trailers)"),
    "sql_unchanged_from_7cbbb03": run("git", "diff", "--exit-code", "7cbbb03977455fcfb5da543bdaffaf5de3c45696", "HEAD", "--", "prisma/migrations/20261224000000_rls_close_public_exposure"),
    "source_stamp_matches": checks,
    "archive_manifest": manifest,
    "bash_syntax_only": shell,
    "historical_proof": {
        "summary_sha256": sha(PACKET / "proof-run-04-head-b7d7fe5.log"),
        "detail_sha256": sha(PACKET / "proof-run-04-head-b7d7fe5-harness-detail.log"),
        "pass_lines": sum(l.startswith("PASS  ") for l in summary.splitlines()),
        "fail_lines": sum(l.startswith("FAIL  ") for l in summary.splitlines()),
        "harness_exit_code": stamps["harness_exit_code"],
        "parent_apply_lines_first_two_replays": sum(l.startswith("Applying migration") for l in detail.splitlines()[:1008]),
        "parent_164_declarations": sum("164 migrations found" in l for l in detail.splitlines()),
        "forward_dump_1_sha256": sha(PACKET / "proof-run-04-head-b7d7fe5-harness-detail.schema-forward1.sql"),
        "forward_dump_2_sha256": sha(PACKET / "proof-run-04-head-b7d7fe5-harness-detail.schema-forward2.sql"),
        "down_dump_sha256": sha(PACKET / "proof-run-04-head-b7d7fe5-harness-detail.schema-after-down.sql"),
        "current_execution": False,
    },
    "limits": [
        "No database, install, broad tests, browser execution, hosted inspection, or current composition execution.",
        "Archive hash agreement establishes local consistency, not a cryptographic signature or live clearance.",
        "Current peer auditor reports/messages not read.",
        "Only prior A report read; historical B finding names appear only in A report/builder packet.",
    ],
}
(OUT / "static-evidence.json").write_text(json.dumps(data, indent=2) + "\n")
print(json.dumps({
    "source_stamp_matches": all(c["matches"] for c in checks.values()),
    "archive_manifest_entries": len(manifest),
    "archive_manifest_all_match": all(c["matches"] for c in manifest),
    "syntax_exits": [c["exit"] for c in shell],
    "diff_check_exit": data["git_delta_check"]["exit"],
    "historical_proof": data["historical_proof"],
}, indent=2))
