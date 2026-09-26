# S11-E roster/entities readers resolve source tokens to families — build grant (EXEC-FA72EFB2)
Grade T4 (native read of coach-owned people/PII; tenant scope; north star NEW SOURCE → CORE DIFF = 0 — a reader that only works when
the source's token is literally `clients` violates it). Route: Claude Fable 5 builds (the S11-D r4 fixer, who diagnosed it);
independent review GPT-6 Sol; parent runs the S11-lane proof (all stages — src change).
Finding: s11d/S11D_R4_LEG_B_ROSTER_FINDING.md (class B). Minimum fix: the IMPORTER-G roster reader (src/scout/scout-roster.service.ts
L72-128) and the IMPORTER-I entities reader (src/scout/scout-entities.service.ts L113/180/236/330) select staged and ledger rows by
the set of (source_platform, entity_type token) pairs that map to the requested family through the SAME registry/mapping the
reconstruct engine uses (family-plan.ts L88-92; the mapping spec per platform) — no source slug or token literal in src; the legacy
convention token == family (`clients`, facts.service.ts L80-83) keeps working (rls-g2-ledger-expand precedent L244-256). Do NOT change
the engine's ledger identity (S9 joins on it). Unknown platform / token not in the registry → excluded and counted honestly (say how
the DTO exposes it — never silently zero if staged rows exist that the reader cannot classify; propose the minimal truthful field or
reuse an existing one; no invented server behaviour). Tenant scope unchanged (coach_id, intent_id). Bounded queries (no N+1).
Commits on /home/user/workspace/worktrees/fa72-s11d2 branch fa72/s11d-r2 on top of 913811fd: (1) ONE src commit (readers + unit
specs), (2) ONE spec commit adding that src commit's SHA to journey-full SLICE_COMMITS (J20 full-range walk) — leg B's roster
assertions stay byte-identical unless the DTO change requires an added field assertion (justify). Check the slug rule on the src
commit. Gates under `flock -w 3600 /home/user/workspace/execution/test-validation.lock` while
/home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE exists: prettier, eslint, tsc, jest of touched + src/scout suites. Hooks,
Bradley, no trailers, no push, no PostgreSQL. Report s11e/s11e_build.md (design, file:line, LOC prod/test, which live specs now
exercise it + expected S11-lane counts, commands+RC, heads/trees, risks). Rules: execution/fa72efb2/WORKER_RULES.md.
