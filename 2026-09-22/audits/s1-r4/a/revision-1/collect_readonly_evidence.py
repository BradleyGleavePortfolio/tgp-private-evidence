"""Read/hash/Git inspection only. Never invokes candidate scripts or a database."""
from pathlib import Path
import datetime, hashlib, json, os, re, subprocess

OUT = Path(__file__).parent
ROOT = Path("/home/user/workspace")
SRC = ROOT / "initialization/recovered/s1-r4-56fb"
PACK = ROOT / "tgp-private-evidence/2026-09-21/remediation/s1-r4/checkpoint2-56fb0d22"
B1 = ROOT / "tgp-private-evidence/2026-09-21/remediation/s2-composition/b1-failed/20260922T000811Z"
OLD = "b7d7fe5964680050ab441c195055ea946282a9c3"
FIRST = "41f4d6a985e5037bf53831a38ed00a9a4314cf7d"
MIG = "prisma/migrations/20261224000000_rls_close_public_exposure/"
commands = []
def git(*args):
    p = subprocess.run(["git", "-C", str(SRC), *args], capture_output=True,
                       env={**os.environ, "GIT_OPTIONAL_LOCKS": "0"})
    commands.append({"argv": ["git", "-C", str(SRC), *args], "exit": p.returncode,
                     "stdout": p.stdout.decode(), "stderr": p.stderr.decode()})
    return p.stdout
def sha(data):
    return hashlib.sha256(data).hexdigest()
def file_info(p):
    return {"path": str(p.relative_to(ROOT)), "sha256": sha(p.read_bytes()),
            "bytes": p.stat().st_size}
files = [MIG+x for x in ["migration.sql","down.sql","verify.sql"]]
files += ["test/db/_support/s1-target-guard.sh",
          "test/db/_support/supabase-like-bootstrap.sql",
          "test/db/s1-harness-guard.spec.sh",
          "test/db/s1-rls-close-public-exposure.sh",
          "test/db/_support/s1-truncate-controls.sh",
          "test/db/s1-r4-truncate-discriminator.sh",
          "test/db/s1-r4-truncate-message-spec.sh",
          "package.json", "package-lock.json", "prisma/schema.prisma",
          "prisma/migrations/rls_fitness_backend.sql"]
record = {
    "scope": "S1-R4-SOURCE-FOLLOWUP; independent A; static evidence inspection only",
    "observed_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "source_head": git("rev-parse", "HEAD").decode().strip(),
    "source_tree": git("rev-parse", "HEAD^{tree}").decode().strip(),
    "porcelain_before": git("status", "--porcelain=v1", "--untracked-files=all").decode(),
    "current_peer_read": False, "candidate_execution": False, "network_or_database": False,
    "runtime_model": None, "runtime_reasoning_setting": None,
    "requested_model": "Inherited parent model (request only; not observable runtime telemetry)",
}
git("cat-file", "-p", "HEAD")
git("cat-file", "-p", FIRST)
git("merge-base", "c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7", "HEAD")
git("diff", "--name-status", OLD, "HEAD")
git("diff", FIRST, "HEAD")
git("diff", OLD, "HEAD", "--", MIG, "test/db/s1-rls-close-public-exposure.sh")
record["source_files"] = []
for f in files:
    item = file_info(SRC/f)
    item["source_relative"] = f
    item["head_blob"] = git("rev-parse", "HEAD:"+f).decode().strip()
    for ref, key in [(FIRST,"first_r4"),(OLD,"prior_r3")]:
        b = git("show", ref+":"+f)
        if commands[-1]["exit"] == 0:
            item[key+"_sha256"] = sha(b)
            item[key+"_equal"] = b == (SRC/f).read_bytes()
    record["source_files"].append(item)
record["archive_manifests"] = []
for name in ["SHA256SUMS","ARCHIVE_SHA256SUMS"]:
    results=[]
    for line in (PACK/name).read_text().splitlines():
        expected, rel = line.split(None,1)
        rel=rel.lstrip("*")
        actual=sha((PACK/rel).read_bytes())
        results.append({"file":rel, "expected":expected, "actual":actual, "match":expected==actual})
    record["archive_manifests"].append({"manifest":name, "self_included":any(x["file"]==name for x in results),
                                       "entries":results})
record["offline_logs"]=[]
for name in ["message-spec.log","message-spec-at-56fb0d22.log","message-spec-NEGATIVE-unquoted-needles.log"]:
    p=PACK/"runs/offline-20260922T002622Z"/name
    s=p.read_text()
    record["offline_logs"].append({**file_info(p), "text":s,
                                  "pass_lines":sum(l.startswith("PASS ") for l in s.splitlines()),
                                  "fail_lines":sum(l.startswith("FAIL ") for l in s.splitlines())})
spec=(SRC/"test/db/s1-r4-truncate-message-spec.sh").read_text()
diagnostic=(B1/"harness/C3.release.log").read_text()
record["b1_diagnostic"]={**file_info(B1/"harness/C3.release.log"),
                        "exit_record":(B1/"exit-codes.txt").read_text(),
                        "spec_fragment_comparisons":[]}
for label in ["B1_FRAG_ANON","B1_FRAG_AUTHN"]:
    fragment=re.search("^"+label+r"='(.*)'$", spec, re.M).group(1)
    record["b1_diagnostic"]["spec_fragment_comparisons"].append(
        {"label":label,"fragment":fragment,"occurs_verbatim":fragment in diagnostic,
         "matching_lines":[n for n,l in enumerate(diagnostic.splitlines(),1) if fragment in l]})
record["archived_copies"]=[]
for copy, f in [("verify.sql.41f4d6a9.copy",MIG+"verify.sql"),
                ("s1-truncate-controls.sh.56fb0d22.copy","test/db/_support/s1-truncate-controls.sh"),
                ("s1-r4-truncate-discriminator.sh.56fb0d22.copy","test/db/s1-r4-truncate-discriminator.sh"),
                ("s1-r4-truncate-message-spec.sh.56fb0d22.copy","test/db/s1-r4-truncate-message-spec.sh")]:
    record["archived_copies"].append({"copy":copy,"source":f,"equal":(PACK/copy).read_bytes()==(SRC/f).read_bytes()})
historical=ROOT/"tgp-private-evidence/2026-09-20/remediation/s1-r3/revision-1/proof-run-04-head-b7d7fe5.log"
record["historical_r3"]={**file_info(historical),"text":historical.read_text()}
record["mandatory_and_prior_inputs"]=[file_info(ROOT/p) for p in [
    "execution/S1_S3_CONTINUATION_BRIEF.md",
    "execution/DISPATCHES.md",
    "tgp-agent-context/AGENT_RULES.md",
    "tgp-private-evidence/LAST_OPERATOR_STATE.md",
    "tgp-private-evidence/LAST_OEPRATOR_HANDOFF.MD",
    "tgp-private-evidence/2026-09-21/audits/s1-r3/a/REPORT.md",
    "tgp-private-evidence/2026-09-21/audits/s1s2-final/a/revision-1/REPORT.md",
    "uploaded_attachments/c1d040eeb6aa44df8b1b2a7a711ed921/TGP_EXECUTE_Autonomous_Executive_Operator_Doctrine.docx",
    "uploaded_attachments/c1d040eeb6aa44df8b1b2a7a711ed921/TGP_T0-T4_PR_Slice_Grading_and_Model_Routing_Doctrine.docx",
]]
record["porcelain_after"]=git("status","--porcelain=v1","--untracked-files=all").decode()
record["commands"]=commands
(OUT/"STATIC_EVIDENCE.json").write_text(json.dumps(record,indent=2)+"\n")
print(json.dumps({
    "head":record["source_head"],"tree":record["source_tree"],
    "clean_before_after":record["porcelain_before"]==record["porcelain_after"]=="",
    "archive_matches":[[m["manifest"],sum(x["match"] for x in m["entries"]),len(m["entries"])] for m in record["archive_manifests"]],
    "offline_counts":[[x["path"].split("/")[-1],x["pass_lines"],x["fail_lines"]] for x in record["offline_logs"]],
    "b1_fragments_verbatim":[x["occurs_verbatim"] for x in record["b1_diagnostic"]["spec_fragment_comparisons"]],
    "copy_matches":[x["equal"] for x in record["archived_copies"]],
},indent=2))
