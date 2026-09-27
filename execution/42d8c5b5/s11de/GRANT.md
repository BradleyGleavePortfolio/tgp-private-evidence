# S11-DE rebuild grant (EXEC-42D8C5B5) — T4, builder claude_fable_5
Tier: T4. Why: native read of coach-owned people (PII) + tenant scope, and it is the NEW SOURCE → CORE DIFF = 0 defect.
Situation: the predecessor's S11-D r4 (913811fd) and S11-E (da095ee5, 66fca8ed, commit 3 unfinished) existed only in a dead
sandbox. They are LOST. You build a NEW candidate from the durable designs; do not claim the old bytes.
Base: origin/land/s11d = aed23289024898cceca7385d3778cd7373b7424d (S11-D r3, PR #565, on integration/importer 54be96f1).
Clone: /home/user/workspace/worktrees/x42-s11de, branch x42/s11de; preserve ref cand/x42/s11de.
Read first (evidence repo /home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/):
  s11d/PROOF_V2_FINDING.md, s11d/S11D_R4_LEG_B_ROSTER_FINDING.md, s11e/S11E_BUILD_GRANT.md, s11e/s11e_build.md (the full design,
  file:line, tests, risks — follow it; improve only where it was wrong).
Deliver exactly two commits on aed23289:
 (1) src commit — S11-E: roster (src/scout/scout-roster.service.ts) and entities (src/scout/scout-entities.service.ts) readers
     select staged/ledger rows by the (source_platform, token) pairs that classify to the requested family through the SAME registry
     the engine uses (buildSourceMapperRegistry + resolveFamily); legacy token==family keeps working; unclassifiable staged rows are
     counted in an additive DTO field (roster `accounting.unclassified`, entities `unclassified_staged`), never a silent zero; engine
     ledger identity unchanged; tenant scope (coach_id, intent_id) unchanged; bounded queries (no N+1); contract regenerated
     byte-stable; unit specs as in s11e_build.md. No slug/token literal in src.
 (2) test commit — (a) leg A J17 fix from PROOF_V2_FINDING (spec passed intentId as pairCurrent's setup-nonce argument; leg A empty
     roster discriminated by a direct h.persons(COACH_A) read); (b) harness: test/utils/g2-s11-worker.cjs assigns
     `.sourceMappers = reconstruct.sourceMappers` to the roster/entities readers it constructs (s11e_build.md risk 1) and leg B asserts
     `accounting.unclassified === 0`; (c) J20: SLICE_COMMITS gains commit (1) and `S11_RANGE_END` = commit (1) SHA, full-range walk
     ends there. Trace every assertion you touch to the executing code path and a live-passing precedent (two live failures already).
Also produce a short table: every live (pg/rls) spec that exercises the roster or entities readers → lane → expected count change.
Gates (lock): prettier, eslint, tsc, contract regen x2 stable, jest test/scout + test/contracts/importer-contract.spec.ts +
test/utils/g2-s11-db-guard.spec.ts. No PostgreSQL. Stop and report if prod LOC > 1,000 or a new product decision is needed.
Report: execution/42d8c5b5/s11de/BUILD.md. Rules: execution/42d8c5b5/WORKER_RULES.md.
