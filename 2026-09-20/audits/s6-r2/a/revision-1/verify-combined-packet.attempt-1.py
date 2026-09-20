#!/usr/bin/env python3
"""Read-only independent verification of frozen S6 R2 evidence and source."""
import hashlib
import json
import re
import subprocess
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path("/home/user/workspace")
SOURCE = ROOT / "worktrees/s6-final"
AUDIT = ROOT / "execution/audits/s6-r2/a"
EXECUTION = ROOT / "execution/s6-final-r2"
PUBLISHED = ROOT / "repos/evidence/2026-09-20/remediation/s6-r2/combined/revision-1"
HEAD = "55db31a0696ebd07d0cb9abb18ffd31dce29457d"
TREE = "130ef9bfdcdbc038b87466529f5980e759f3451a"
REPORT_SHA = "36dbd19ff358d76b2dcfae79f7abde1c20d0393a52e2402ba451c86d3470bc25"
PARENTS = [
    "eaccaba98bc4400a0341bcd80409ab317bc85856",
    "d7079265ea1263a1af6cd9cd132fc18dcb1793d9",
]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def git(*args):
    return subprocess.check_output(
        ["git", "-C", str(SOURCE), *args], text=True
    ).strip()


def verify_manifest(base, manifest):
    rows = []
    for line in (base / manifest).read_text().splitlines():
        expected, name = line.split(maxsplit=1)
        name = name.removeprefix("*")
        path = base / name
        actual = digest(path)
        assert expected == actual, str(path)
        rows.append({"file": name, "sha256": actual, "match": True})
    return {"manifest": str((base / manifest).relative_to(ROOT)),
            "matched": len(rows), "entries": rows}


result = {
    "observed_utc": datetime.now(timezone.utc).isoformat(),
    "mode": "read-only local evidence/source checks; no remote claim; no runtime bundle execution",
    "source": {
        "head": git("rev-parse", "HEAD"),
        "tree": git("rev-parse", "HEAD^{tree}"),
        "parents": git("show", "-s", "--format=%P", "HEAD").split(),
        "status_porcelain": git("status", "--porcelain=v1", "--untracked-files=all"),
    },
}
assert result["source"]["head"] == HEAD
assert result["source"]["tree"] == TREE
assert result["source"]["parents"] == PARENTS
assert result["source"]["status_porcelain"] == ""
result["manifests"] = [
    verify_manifest(AUDIT, "PRELIMINARY_SHA256SUMS"),
    verify_manifest(EXECUTION, "SHA256SUMS"),
    verify_manifest(PUBLISHED, "SHA256SUMS"),
    verify_manifest(PUBLISHED, "BUILDER_SHA256SUMS"),
]
assert (EXECUTION / "SHA256SUMS").read_bytes() == (PUBLISHED / "BUILDER_SHA256SUMS").read_bytes()
assert digest(EXECUTION / "REPORT.md") == REPORT_SHA
assert digest(PUBLISHED / "REPORT.md") == REPORT_SHA
result["frozen_combined_report_sha256"] = REPORT_SHA

expected_inputs = {
    "package.json": "63e2e2e2327b5a305fd184c0737ff4eea91f2283e8aa5d313041bffbdf130d5f",
    "package-lock.json": "840be0b8d5f4ed8272afd20290c8ebf6f6dacc394e6edae4ae5403e9fabe6b69",
}
result["dependency_input_hashes"] = {}
for name, expected in expected_inputs.items():
    assert digest(SOURCE / name) == expected
    assert digest(ROOT / "worktrees/s6" / name) == expected
    result["dependency_input_hashes"][name] = expected
result["node_modules_target"] = str((SOURCE / "node_modules").resolve())
assert result["node_modules_target"] == str(ROOT / "worktrees/s6/node_modules")
assert not (SOURCE / "node_modules/react-native-mmkv").exists()
result["mmkv_present"] = False

result["stage_bindings"] = []
for path in sorted((EXECUTION / "logs").glob("*.STAMP")):
    text = path.read_text()
    for required in (
        f"HEAD={HEAD}\n", f"TREE={TREE}\n", "STATUS_SHORT_LINES=0 (0 = clean)\n",
        "NODE=v22.13.1 NPM=10.9.2 ", "NODE_OPTIONS=<unset>",
        "MMKV_STUB_PRESENT=no\n", "CHILD_EXIT=0\n",
        expected_inputs["package.json"], expected_inputs["package-lock.json"],
    ):
        assert required in text, (path.name, required)
    values = dict(line.split("=", 1) for line in text.splitlines() if "=" in line)
    result["stage_bindings"].append({
        "stage": path.stem, "command": values["CMD"], "start": values["START"],
        "end": values["END"], "exit": int(values["CHILD_EXIT"]),
        "environment": values.get("ENV: CI"),
    })
assert len(result["stage_bindings"]) == 8
jest = next(s for s in result["stage_bindings"] if s["stage"] == "04-jest-full")
assert jest["command"] == "timeout 660 npx jest --ci"
jest["wall_seconds"] = (
    datetime.fromisoformat(jest["end"]) - datetime.fromisoformat(jest["start"])
).total_seconds()
assert jest["wall_seconds"] < 660
jest_log = (EXECUTION / "logs/04-jest-full.log").read_text()
for expected in ("Test Suites: 308 passed, 308 total",
                 "Tests:       3839 passed, 3839 total",
                 "Snapshots:   5 passed, 5 total"):
    assert expected in jest_log
result["jest"] = {
    "suites_passed": 308, "tests_passed": 3839, "snapshots_passed": 5,
    "reported_test_seconds": 119.144, "wall_seconds": jest["wall_seconds"],
    "delayed_exit_warning_present": "Jest did not exit one second" in jest_log,
    "natural_exit_evidence": "child exit 0 from timeout 660; no --forceExit in command",
}
result["bundles"] = []
texts = {}
for mode, expected_flag, expected_sha, export_log in (
    ("flag-on", '"true"', "43c981f2b9f611113359806775b8f278b57833f700ca45eb9837c9067ddb59d8", "05-export-flag-on.log"),
    ("flags-unset", "void 0", "0aa77c1f245b11bd52143e1e4a13b9ca53c6254df7f4746e0caf0a24e48f2dbe", "07-export-flags-unset.log"),
):
    export_root = EXECUTION / f"export-{mode}"
    paths = list((export_root / "_expo/static/js/android").glob("index-*.js"))
    assert len(paths) == 1
    path = paths[0]
    text = path.read_text()
    texts[mode] = text
    assert digest(path) == expected_sha
    assert "Bundler cache is empty" in (EXECUTION / "logs" / export_log).read_text()
    flags = {
        key: re.findall(key + r":([^,}]*)", text)
        for key in ("EXPO_PUBLIC_FF_EXTENSION_IMPORT", "EXPO_PUBLIC_FF_IMPORT_REVIEW")
    }
    assert flags["EXPO_PUBLIC_FF_EXTENSION_IMPORT"] == [expected_flag]
    assert flags["EXPO_PUBLIC_FF_IMPORT_REVIEW"] == ["void 0"]
    assert text.count("process.env[") == 0
    assert text.count("process.env.EXPO_PUBLIC_FF_") == 0
    assert text.count("react-native-mmkv") == 1
    pos = text.index("react-native-mmkv")
    public_residue = sorted(set(re.findall(r"process\.env\.EXPO_PUBLIC[A-Z_]*", text)))
    assert public_residue == ["process.env.EXPO_PUBLIC_USE_RN_FETCH"]
    metadata = json.loads((export_root / "metadata.json").read_text())
    result["bundles"].append({
        "mode": mode, "file": str(path.relative_to(ROOT)), "sha256": digest(path),
        "bytes": path.stat().st_size, "flags": flags,
        "computed_env_reads": 0, "runtime_app_flag_reads": 0,
        "public_residue": public_residue, "mmkv_mentions": 1,
        "mmkv_context": text[pos-200:pos+300], "metadata": metadata,
        "cold_cache_log_marker": True,
    })
result["bundles_equal_after_normalizing_extension_flag"] = (
    texts["flag-on"].replace('EXPO_PUBLIC_FF_EXTENSION_IMPORT:"true"',
                            "EXPO_PUBLIC_FF_EXTENSION_IMPORT:void 0")
    == texts["flags-unset"]
)
assert result["bundles_equal_after_normalizing_extension_flag"]
result["all_assertions_passed"] = True
print(json.dumps(result, indent=2))
