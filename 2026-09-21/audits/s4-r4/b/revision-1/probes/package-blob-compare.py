# Offline check: every file in the exact-head package zip is byte-identical to the
# git blob at HEAD 2bcf1563 in the read-only worktree (no source mutation).
import zipfile, hashlib, subprocess, json, sys
ZIP="/home/user/workspace/execution/s4-r4/artifacts/tgp-importer-extension-0.3.0-rc.1.zip"
WT="/home/user/workspace/worktrees/s4-r4"
HEAD="2bcf1563d85bc2109e99805e4ce1b06fce4dcdb3"
z=zipfile.ZipFile(ZIP)
zsha=hashlib.sha256(open(ZIP,'rb').read()).hexdigest()
mismatch=[];missing=[];ok=0;names=[]
for info in z.infolist():
    if info.is_dir(): continue
    names.append(info.filename)
    data=z.read(info.filename)
    try:
        blob=subprocess.run(["git","-C",WT,"show",f"{HEAD}:{info.filename}"],capture_output=True,check=True).stdout
    except subprocess.CalledProcessError:
        missing.append(info.filename); continue
    if blob==data: ok+=1
    else: mismatch.append(info.filename)
changed=["background.js","shared/session.js","shared/log.js","shared/replay/engine.js"]
print(json.dumps({"zip":ZIP,"zipSha256":zsha,"files":len(names),"identicalToHeadBlob":ok,
  "mismatch":mismatch,"notInHead":missing,
  "changedShippingFilesPresent":{c:(c in names) for c in changed},
  "testFilesInZip":[n for n in names if n.startswith("test/")],
  "manifestInZip":"manifest.json" in names}, indent=1))
sys.exit(0 if not mismatch and not missing else 1)
