"""Evidence inspection only: hash files and read Git objects; no candidate execution."""
from pathlib import Path
import hashlib, json, os, subprocess, datetime
ROOT=Path("/home/user/workspace")
OUT=Path(__file__).parent
P=ROOT/"execution/s2-setup-prep"
V=ROOT/"execution/s2-runner53"
W=ROOT/"worktrees/s2-runner53"
commands=[]
def sha(b): return hashlib.sha256(b).hexdigest()
def git(*args):
    r=subprocess.run(["git","-C",str(W),*args],capture_output=True,env={**os.environ,"GIT_OPTIONAL_LOCKS":"0"})
    commands.append({"args":list(args),"exit":r.returncode,"stdout":r.stdout.decode(),"stderr":r.stderr.decode()})
    return r.stdout
def manifest(base,name):
    results=[]
    for line in (base/name).read_text().splitlines():
        h,n=line.split(None,1); n=n.lstrip("*")
        f=base/n
        results.append({"file":n,"expected":h,"actual":sha(f.read_bytes()) if f.is_file() else None})
    return {"path":str((base/name).relative_to(ROOT)),"sha256":sha((base/name).read_bytes()),"entries":results}
e={"utc":datetime.datetime.now(datetime.timezone.utc).isoformat(),
   "scope":"S2-R53-INDEPENDENT-PLAN-A; read-only; no execution",
   "head":git("rev-parse","HEAD").decode().strip(),"tree":git("rev-parse","HEAD^{tree}").decode().strip(),
   "porcelain_before":git("status","--porcelain=v1","--untracked-files=all").decode(),
   "manifests":[manifest(P,"SHA256SUMS.outer"),manifest(V,"SHA256SUMS.outer")],
   "model_actual":None,"reasoning_actual":None,"peer_S2_report_read":False}
git("merge-base","--is-ancestor","56fb0d227558c86fe824f9fb1bc15e222411504f","HEAD")
git("diff","--name-status","56fb0d227558c86fe824f9fb1bc15e222411504f","HEAD","--","test/db","prisma/migrations/20261224000000_rls_close_public_exposure")
git("diff","--name-status","9742037b153221de565e651ad8ba3b721bc0fb31","HEAD","--","package.json","package-lock.json","prisma/schema.prisma")
e["predecessor_verifier_sha256"]=sha(git("show","b7d7fe5964680050ab441c195055ea946282a9c3:prisma/migrations/20261224000000_rls_close_public_exposure/verify.sql"))
e["source_hashes"]={}
for n in ["test/release/s1s2-composition.sh","scripts/release.sh","scripts/release-required-verifiers.txt",
          "prisma/schema.prisma","package.json","package-lock.json",
          "test/db/s1-r4-truncate-discriminator.sh","test/db/_support/s1-truncate-controls.sh",
          "test/db/_support/s1-target-guard.sh","test/db/_support/supabase-like-bootstrap.sql"]:
    e["source_hashes"][n]=sha((W/n).read_bytes())
e["migration_directory_count"]=sum(f.is_dir() and len(f.name.split("_")[0])==14 and f.name.split("_")[0].isdigit() for f in (W/"prisma/migrations").iterdir())
e["packet_texts"]={}
for n in ["REPORT.md","SLOT_REQUEST_05_SETUP_ONLY.md","SLOT_REQUEST_06_CONTROLS_AND_PROOF.md",
          "run-composition-r53-v5.3.1-when-granted.sh","infra/s2-fixture-r53.sh","infra/setup-20-pg17.sh",
          "infra/setup-30-npm-ci.sh","infra/launch-detached.sh","controls-proposed/run-runner-controls-v531.sh",
          "controls-proposed/run-fixture-lockcheck-controls.sh"]:
    e["packet_texts"][n]={"sha256":sha((P/n).read_bytes()),"text":(P/n).read_text()}
e["v53_observations"]={"control_summary":(V/"controls/20260922T043943Z/CONTROLS_RESULT.txt").read_text(),"runs":{}}
for d in ["20260922T043945Z","20260922T043947Z","20260922T043951Z","20260922T044011Z","20260922T044013Z"]:
    b=V/"runner-selftest-r53"/d
    e["v53_observations"]["runs"][d]={"exit_codes":(b/"exit-codes.txt").read_text(),"stamp":(b/"stamp.txt").read_text()}
e["mandate"]=(ROOT/"execution/S2_R53_ALLOCATION_AND_REVIEW.md").read_text()
e["porcelain_after"]=git("status","--porcelain=v1","--untracked-files=all").decode()
e["git_observations"]=commands
(OUT/"STATIC_EVIDENCE.json").write_text(json.dumps(e,indent=2)+"\n")
print(json.dumps({"head":e["head"],"tree":e["tree"],"clean":not(e["porcelain_before"] or e["porcelain_after"]),
  "manifests":[{"path":m["path"],"matched":sum(x["actual"]==x["expected"] for x in m["entries"]),"total":len(m["entries"])} for m in e["manifests"]],
  "migrations":e["migration_directory_count"],"s1_predecessor_sha256":e["predecessor_verifier_sha256"]},indent=2))
