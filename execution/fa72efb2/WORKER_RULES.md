# EXEC-FA72EFB2 worker rules (binding on every builder/reviewer this parent dispatches)

Parent: session fa72efb2 (sole owner of grants, acceptance, landing, remote writes, evidence commits).
Doctrine in force: tgp-agent-context AGENT_RULES.md G01-G22 (EFFECTIVE), T0-T4 routing, EXECUTE, owner Safety ROI
(execution/6c2a68ac/OWNER_SAFETY_ROI_AND_EXECUTION_DOCTRINE.md), mission roadmap/M-IMPORTER-PRODUCT-MISSION_v1.md.

1. Remote: NEVER push, open/edit PRs, move GitHub refs, or land anything. Local commits only in your own clone, only when
   your grant says so, through the installed lefthook hooks (never --no-verify), author AND committer
   `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no AI/co-author trailers, no amend of anyone else's commit.
2. Paths: edit only the paths your grant owns. Never touch another worker's clone, the proof source clone
   worktrees/fa72-s11a1, /home/user/workspace/execution/fa72efb2/runtime/**, or any clusters/run directory.
3. Heavy slot: canonical lock /home/user/workspace/execution/test-validation.lock (inode 686480). Every heavy command
   (tsc, jest, eslint over more than a few files, the contract generator, anything >1 CPU-minute) runs ONLY as
   `flock -w 3600 /home/user/workspace/execution/test-validation.lock bash -c '<cmd>'` so workers queue. Never delete,
   recreate, or `flock -n`-probe-and-steal it; never run two at once. Use `NODE_OPTIONS=--max-old-space-size=3072` and
   `jest --runInBand` (2 CPUs / 7 GB host). Real-PG lanes, bootstraps, initdb, pg_ctl, and any `*.pg.spec.ts` /
   `rls-g2-*` live run are PARENT-ONLY proof bindings: do not run them.
4. node_modules in builder clones is a hard-linked copy of the proof donor: NEVER run npm install/ci, prisma generate,
   or anything that writes inside node_modules. Prettier 3.9.9 lives at
   /home/user/workspace/execution/fa72efb2/runtime/tools/prettier-3.9.9 (export npm_config_prefix=<that> PATH=<that>/bin:$PATH).
5. Safety ROI: classify every finding A/B/C. Each A/B must name CLASS, CONCRETE HARM, EXACT DECISION BLOCKED,
   MINIMUM CLOSURE, EXECUTION UNLOCKED. C = record, qualify, continue. Do not invent races, do not test tests
   recursively, do not re-audit accepted landed bytes, do not widen scope.
6. Mission invariants: new source -> core diff 0; no arbitrary model-generated JavaScript; unknown never silently
   becomes zero; no fabricated server behaviour in UI; owner-reserved boundaries untouched (production, flags,
   live source accounts, G3-AUTH, S8-D/E principal, CWS, branch protection, spending).
7. Output: write your report where the grant says (a file under this evidence namespace; do not git-commit the
   evidence repo — the parent commits). Report exact paths + sha256, LOC, every command run with RC, open risks.
   Never claim you ran or read something you did not.
