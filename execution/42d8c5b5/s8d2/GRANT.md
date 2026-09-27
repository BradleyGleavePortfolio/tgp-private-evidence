# S8-D2 build grant (EXEC-42D8C5B5) — T4, builder claude_fable_5
Tier: T4. Why: publishes coach-owned PII (imported people) on the coach roster, alters a public contract, retires an honesty qualifier.
Base: backend 419a756da4e6eebc28e22b19d0c08d72549f6d4e (= origin/cand/x42/s12b1-on-s8d1: S11-DE → S8-D1 → S12-B2 → S12-B1, the composed
stack now in landing proof; integration/importer will FF to it). Fresh clone: `git clone --no-hardlinks /home/user/workspace/repos/backend <clone>`,
fetch origin cand refs with api_credentials github; node_modules `cp -al` from the donor per WORKER_RULES. Commit as Bradley Gleave through the
hooks; push every commit to the preserve ref named below. Rules: execution/42d8c5b5/WORKER_RULES.md (lock for every tsc/jest/prettier run).
Clone /home/user/workspace/worktrees/x42-s8d2, branch x42/s8d2, preserve ref cand/x42/s8d2.
Scope = decision record docs/decisions/2026-09-26-s8d-person-link.md (on origin/land/s8d-doc, PR #566) §5.2 + §6 row S8-D2 and anything they
cite: coach roster gains sibling `imported_people[]` (Persons of the coach, state ∉ {Claimed, Deleted}; Suspended shown; fixed label copy),
`person_link`/`proposal`/`invite` markers emitted truthfully as null where the backing tables (S8-D3+) do not exist yet — never fabricated;
suggestions read-only and never applied (if the record's suggestion source needs D3+ tables, emit [] and say so); importer-G roster keeps its shape
with `roster_bridge_pending` → false (field retirement waits for mobile); contract regen through scripts/importer-contract.ts (stable x2);
privacy review of every emitted field in BUILD.md (tenant scope, no email/contact fields, no cross-coach leak).
Update J19 leg B's qualifier assertion only if the retirement changes it (J20 S11_RANGE_END stays ce37c6ee).
Gates (lock): prettier, eslint, tsc, contract regen x2, jest of touched + coach/roster/scout suites + g2-s11 guard. No PostgreSQL; list PG lanes
the parent must run. >1,000 prod LOC → stop and report. Open questions that need an owner product decision → stop and report, do not assume.
Report execution/42d8c5b5/s8d2/BUILD.md.
