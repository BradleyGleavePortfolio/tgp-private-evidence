# EXEC-42D8C5B5 worker rules (binding on every builder/reviewer this parent dispatches)

HOLD LIFTED 2026-09-27 19:36Z: the owner confirmed in session that the commit/merge identity does not matter. G05 identity (Bradley Gleave
<bradley@bradleytgpcoaching.com>, no AI co-author) stays the default; scratch-identity commits must be re-created before any push.

Parent: session 42d8c5b5 (sole owner of grants, acceptance, landing, integration refs, evidence commits).
Doctrine: tgp-agent-context AGENT_RULES.md G01-G22, T0-T4 routing, EXECUTE, Safety ROI (A/B/C). Optimize correct customer value per elapsed time.

1. Identity: every commit author AND committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, through the installed lefthook
   hooks (never --no-verify), no AI/co-author trailers, never amend someone else's commit.
2. Clone: standalone `git clone --no-hardlinks /home/user/workspace/repos/backend <your clone>` (NEVER `git worktree add`).
   `git remote set-url --push origin no_push://disabled`; add remote `preserve` = https://github.com/BradleyGleavePortfolio/growth-project-backend.git.
3. PRESERVATION (new, deterministic control — bytes were lost 3x when a sandbox died): immediately after EVERY local commit run
   `git push preserve HEAD:refs/heads/cand/x42/<your-slice>` (bash with api_credentials ["github"]). That ref namespace is the ONLY
   remote write you may make: never land/*, integration/*, main, tags, PRs, or force-push anyone else's ref. Report the pushed SHA.
4. Paths: edit only what your grant owns. Never touch another worker's clone, worktrees/x42-donor, execution/42d8c5b5/runtime/**,
   or any clusters/run directory.
5. Heavy slot: canonical lock /home/user/workspace/execution/test-validation.lock (inode 657581). Every heavy command (tsc, jest,
   eslint over more than a few files, contract generator, anything >1 CPU-minute) runs ONLY as
   `flock -w 3600 /home/user/workspace/execution/test-validation.lock bash -c '<cmd>'`. Never delete/recreate/steal it.
   `NODE_OPTIONS=--max-old-space-size=3072`, `jest --runInBand` (2 CPUs / 7 GB). Real-PG lanes, initdb, pg_ctl, `*.pg.spec.ts`
   and `rls-g2-*` live runs are PARENT-ONLY. Long commands: launch with `nohup setsid ... &` and poll (tool calls time out ~10 min).
6. node_modules: wait until execution/42d8c5b5/runtime/raw/rt-setup.sentinel (in the evidence repo) says RC=0, then
   `cp -al /home/user/workspace/worktrees/x42-donor/node_modules <clone>/node_modules` and `./node_modules/.bin/lefthook install`.
   NEVER npm install/ci or prisma generate in a clone. Prettier 3.9.9: export npm_config_prefix=/home/user/workspace/execution/42d8c5b5/runtime/tools/prettier-3.9.9 PATH=$npm_config_prefix/bin:$PATH.
   Write code while you wait; do not idle.
7. Cheap before expensive: prettier/eslint/tsc before jest; focused jest before broad; never burn a PG proof on a static defect.
8. Findings: A (product/customer/security/data), B (proof/test/harness), C (hygiene). Each A/B names HARM, EXACT THING BLOCKED,
   MINIMUM CLOSURE, STATE UNLOCKED. C = record and continue. No invented races, no recursive test-of-tests, no re-audit of landed bytes.
9. Invariants: NEW SOURCE → CORE DIFF = 0 (no platform slug/token literal in src); no model-generated executable JS; unknown never
   silently becomes zero; no fabricated server behaviour in UI; owner-reserved boundaries untouched (production, flags, live source
   accounts, CWS, branch protection, spending, external commitments).
10. Output: report file where the grant says (do not commit the evidence repo — parent commits). Exact heads/trees, pushed cand ref,
    LOC prod/test, commands with RC, risks. Never claim you ran or read something you did not. Keep reports short.
