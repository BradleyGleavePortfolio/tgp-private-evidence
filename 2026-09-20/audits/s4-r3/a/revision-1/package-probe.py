"""Independent offline ZIP/source/inventory verification; no builds or installs."""
from pathlib import Path
import subprocess, hashlib, json, struct, zlib, zipfile
root = Path("/home/user/workspace/worktrees/s4-r3")
packet = Path("/home/user/workspace/execution/s4-r3")
out = Path(__file__).parent
head = "84471e99b278e964f7cb3f6bf9c78491064c41b7"
base = "c5a5ae12c5b3c3e32a4601c99319ad7c0d980057"
artifact = packet / "artifacts/tgp-importer-extension-0.3.0-rc.1.84471e9.zip"
inv = json.loads((packet / "artifacts/tgp-importer-extension-0.3.0-rc.1.84471e9.inventory.json").read_text())
sha = lambda b: hashlib.sha256(b).hexdigest()
git = lambda *args: subprocess.check_output(["git","-C",str(root),*args])
assert git("rev-parse","HEAD").decode().strip() == head
raw = artifact.read_bytes()
assert inv["source"] == {"head":head,"clean":True}
assert inv["zip"]["sha256"] == sha(raw)
assert inv["zip"]["bytes"] == len(raw)
with zipfile.ZipFile(artifact) as zip:
    names = zip.namelist()
    assert len(names) == len(set(names)) == 36
    assert names == sorted(names)
    assert zip.testzip() is None
    assert {x["path"] for x in inv["files"]} == set(names)
    # Batch object reads instead of spawning a process for every member.
    queries = [f"{ref}:{name}" for ref in [head,base] for name in names]
    batch = subprocess.check_output(["git","-C",str(root),"cat-file","--batch"],
                                    input=("\n".join(queries)+"\n").encode())
    blobs = {}
    pos = 0
    for query in queries:
        end = batch.index(b"\n",pos)
        fields = batch[pos:end].split()
        assert fields[1] == b"blob"
        size = int(fields[2])
        pos = end+1
        blobs[query] = batch[pos:pos+size]
        pos += size+1
    files = []
    changes = []
    for name in names:
        b = blobs[f"{head}:{name}"]
        assert zip.read(name) == b == (root/name).read_bytes(),name
        record = next(x for x in inv["files"] if x["path"]==name)
        assert record["sha256"] == sha(b) and record["bytes"] == len(b)
        assert name.split("/")[0] not in {".git",".github","docs","node_modules","scripts","test","types","dist"}
        files.append((name,b))
        if blobs[f"{base}:{name}"] != b:
            changes.append(name)
    # Reconstruct known shipping format directly from exact Git blobs.
    # This verifies the byte-level writer, not an independent AST-closure walk.
    local = bytearray()
    central = bytearray()
    for name,b in files:
        n = name.encode()
        crc = zlib.crc32(b)
        offset = len(local)
        local += struct.pack("<IHHHHHIIIHH",0x04034b50,10,0,0,0,0x21,crc,len(b),len(b),len(n),0) + n + b
        central += struct.pack("<IHHHHHHIIIHHHHHII",0x02014b50,10,10,0,0,0,0x21,crc,len(b),len(b),len(n),0,0,0,0,0,offset) + n
    rebuilt = local + central + struct.pack("<IHHHHIIH",0x06054b50,0,0,len(files),len(files),len(central),len(local),0)
    assert rebuilt == raw
    (out / "reconstructed-from-git.zip").write_bytes(rebuilt)
assert set(changes) == {"shared/log.js","shared/net.js","shared/pairing.js","shared/session.js"}
meta = {}
for number,label in [(9,"npm-test-full"),(10,"npm-gates"),(11,"npm-package"),(12,"browser-proof")]:
    m = json.loads((packet/f"logs/{number:02}-{label}.meta.json").read_text())
    assert m["head"] == head and m["dirty_paths"] == 0
    assert m["package_json_sha256"] == sha(git("show",f"{head}:package.json"))
    assert m["package_lock_sha256"] == sha(git("show",f"{head}:package-lock.json"))
    meta[label] = {"exit_code":m["exit_code"],"tree":m["tree"],"node":m["node"],"npm":m["npm"]}
positive = json.loads((packet/"logs/browser-load-proof.84471e9.positive.json").read_text())
negative = json.loads((packet/"logs/browser-load-proof.84471e9.negative-control.json").read_text())
for receipt in [positive,negative]:
    assert receipt["package"]["sha256"] == sha(raw)
    assert receipt["package"]["inventory"]["source"]["head"] == head
assert len(positive["checks"]) == 11 and all(c["pass"] for c in positive["checks"])
assert negative["negativeControl"] == {"detected":True,"noReceiver":True,"syntaxExceptionSeen":True,"unrelatedFailures":[]}
assert "positive_exit=0" in (packet/"logs/12-browser-proof.log").read_text()
assert "negative_control_exit=0" in (packet/"logs/12-browser-proof.log").read_text()
print(json.dumps({
    "head":head,"base":base,"package_sha256":sha(raw),"package_bytes":len(raw),
    "members":len(names),"every_member_matches_git_worktree_inventory":True,
    "independent_store_zip_reconstruction_identical":True,
    "changed_shipping_members":changes,
    "metas":meta,
    "positive_checks":len(positive["checks"]),
    "negative_control":negative["negativeControl"],
    "browser_wrapper_exit_alone_not_sufficient":True,
    "real_browser_launched_by_auditor":False
},indent=2))
