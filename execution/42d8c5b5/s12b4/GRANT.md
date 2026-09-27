# S12-B4 build grant (EXEC-42D8C5B5) — T2, builder claude_sonnet_5_0
Tier: T2. Why: docs + read-only SQL whose output is the pilot's truth report; no product code (T1 would need a fully fixed spec; it is not).
Base: backend 419a756da4e6eebc28e22b19d0c08d72549f6d4e (= origin/cand/x42/s12b1-on-s8d1: S11-DE → S8-D1 → S12-B2 → S12-B1, the composed
stack now in landing proof; integration/importer will FF to it). Fresh clone: `git clone --no-hardlinks /home/user/workspace/repos/backend <clone>`,
fetch origin cand refs with api_credentials github; node_modules `cp -al` from the donor per WORKER_RULES. Commit as Bradley Gleave through the
hooks; push every commit to the preserve ref named below. Rules: execution/42d8c5b5/WORKER_RULES.md (lock for every tsc/jest/prettier run).
Clone /home/user/workspace/worktrees/x42-s12b4, branch x42/s12b4, preserve ref cand/x42/s12b4.
Scope: execution/fa72efb2/s12/S12_PILOT_READINESS.md §2b row S12-B4 and §3 (esp. §3.4 pilot report): a pilot runbook (docs/pilot/) plus a
read-only observation pack (SQL/psql, SELECT only, parameterised by coach_id/intent_id, never run against production by builders) producing the
§3.4 report from ScoutImport, the ledger, provenance (incl. S8-D1 person provenance), declaration/observation rows and the settled basis;
unknown-safe (NULL/absent reported as unknown, never 0); documented flag on/off and pilot-allowlist procedure (S12-B1 variable, S12-B6 workflow)
incl. S12-B1 review C4 (removing a coach leaves an open run open until re-listed). Validate every query against the schema at base by running
it on a throwaway local PG from the runtime (migrate deploy at base; synthetic rows allowed) under the lock; record outputs.
Report execution/42d8c5b5/s12b4/BUILD.md.
