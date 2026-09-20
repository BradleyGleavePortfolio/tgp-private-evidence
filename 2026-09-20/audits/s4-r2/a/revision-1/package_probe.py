"""Read-only exact-blob check and independent deterministic ZIP reconstruction."""
from pathlib import Path
import hashlib, json, subprocess, struct, zlib, zipfile

out = Path(__file__).resolve().parent
root = Path("/home/user/workspace/worktrees/s4")
packet = Path("/home/user/workspace/repos/evidence/2026-09-20/remediation/s4-r2/revision-1")
head = "c5a5ae12c5b3c3e32a4601c99319ad7c0d980057"
archive = packet / "artifacts/tgp-importer-extension-0.3.0-rc.1.c5a5ae1.zip"
inventory = json.loads(archive.with_suffix(".inventory.json").read_text())
sha = lambda b: hashlib.sha256(b).hexdigest()
checksums = []
for line in (packet / "SHA256SUMS").read_text().splitlines():
    expected, name = line.split(None, 1)
    actual = sha((packet / name.strip()).read_bytes())
    checksums.append({"file": name.strip(), "ok": expected == actual})
assert all(c["ok"] for c in checksums)
files = []
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    assert z.namelist() == [f["path"] for f in inventory["files"]]
    for f in inventory["files"]:
        b = subprocess.check_output(["git", "-C", str(root), "show", f"{head}:{f['path']}"])
        assert b == z.read(f["path"]) == (root / f["path"]).read_bytes()
        assert sha(b) == f["sha256"]
        files.append((f["path"], b))
locals_, central, offset = [], [], 0
for path, b in sorted(files):
    name = path.encode()
    crc, n = zlib.crc32(b), len(b)
    local = struct.pack("<IHHHHHIIIHH", 0x04034b50, 10, 0, 0, 0, 33, crc, n, n, len(name), 0)
    cen = struct.pack("<IHHHHHHIIIHHHHHII", 0x02014b50, 10, 10, 0, 0, 0, 33, crc, n, n, len(name), 0, 0, 0, 0, 0, offset)
    locals_.extend([local, name, b])
    central.extend([cen, name])
    offset += len(local) + len(name) + n
c = b"".join(central)
end = struct.pack("<IHHHHIIH", 0x06054b50, 0, 0, len(files), len(files), len(c), offset, 0)
rebuilt = b"".join(locals_) + c + end
assert rebuilt == archive.read_bytes()
(out / "independent-reconstructed.zip").write_bytes(rebuilt)
result = {
    "head": head,
    "files": len(files),
    "bytes": len(rebuilt),
    "sha256": sha(rebuilt),
    "archive_bytes_equal_git_blobs_and_worktree": True,
    "independent_zip_reconstruction_byte_identical": True,
    "scope_limit": "Reconstructed ZIP writer with Python from inventory-selected exact Git blobs; did not execute npm packager or independently regenerate TS-AST closure.",
    "inventory_source": inventory["source"],
    "packet_checksum_count": len(checksums),
    "packet_checksum_failures": [c for c in checksums if not c["ok"]],
}
(out / "package-probe.json").write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
