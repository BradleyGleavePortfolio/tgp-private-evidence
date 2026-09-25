# S8-G work grading (T0-T4 per slice, with the rule that triggers each grade)

Tiers as used in `daceddc8/SCOPE.md`: T0 = parent-executed, fully prepared mechanical step (hash-pinned script, no judgement); T1 = mechanical with a fixed checklist and a single expected output; T2 = bounded source edit under an exact diff spec, no design freedom; T3 = design-bearing but read-only or single-writer with a frozen interface (e.g. LAND-PREP-1, RT-2); T4 = new product bytes touching concurrency/state authority, tenancy or native customer data, requiring an independent review pair and a real-PG proof (e.g. S7L-WC-1, S8C-BC-2).

Triggering rule (applied top-down; the first match sets the grade): (1) writes `terminal_status`/`execution_epoch`/fence columns or changes the CAS → T4 + owner note; (2) new bytes in a per-row transaction that commits native/provenance/ledger rows, or changes lock order → T4; (3) new pure code with no I/O whose outputs feed a T4 path → T3; (4) test-only bytes that run real PG → T3 (prepared by the builder, executed by the parent on the slot as T0); (5) test-only doubles/unit → T2; (6) renames/copies of accepted harness files with constant substitution → T1; (7) hash-pinned script replay → T0.

| Slice | Content | Grade | Trigger | Notes |
|---|---|---|---|---|
| G-0 | This draft (design/tests, evidence only) | T4 drafter, read-only | READINESS drafting permission | done; no product bytes |
| G-1 | `orchestration/run-context.ts`, `orchestration/family-plan.ts` | T3 | rule 3: pure, but `RUN_FAMILY_ORDER`/`planRun` decide which rows the T4 engine writes | same builder as G-2 (single writer of the worktree) |
| G-2 | `scout-reconstruct.service.ts`: `reconstructRun`, gate-first insertion, ctx threading | T4 | rule 2: gate UPDATE becomes the first statement of every native/evidence/ledger transaction; legacy byte-identity at stake | independent Review A/B on changed bytes; G02/G08 proof |
| G-3 | `lifecycle.service.ts` hook body + optional constructor parameter | T4 | rule 1 adjacency: touches the file that owns the CAS, even though the tail is kept verbatim | reviewers must diff-verify the tail L314-334 is byte-identical; G14 proof |
| G-4 | Unit specs (`family-plan`, `reconstruct-run`, `settle-hook`) | T2 | rule 5 | drafts attached; may be tightened by the builder |
| G-5 | `g2-s8g-*` harness/db/bootstrap/old-root | T1 | rule 6 | renamed S7-L files; any semantic change lifts to T3 |
| G-6 | `g2-s8g-worker.cjs`, `rls-g2-s8g.spec.ts`, `g2-s8g-db-guard.spec.ts` | T3 | rule 4 | barriers pause only; any query-result substitution is a refusal |
| G-7 | Scoped prettier/eslint + one genuine hooked commit | T0 on the slot | rule 7 | parent relay, first failure stops |
| G-8 | Binding `s8g/binding/v1/` and the single real-PG proof (`timeout -k 30 3900`) | T0 execution / T3 preparation | rules 4, 7 | one attempt; failure preserved, never looped |
| G-9 | Reviews A/B of G-2/G-3 changed bytes | T4 read-only, non-builder, no peer reads | SCOPE REV pattern | dual GO before G-8 |
| G-10 | Landing onto `integration/importer` | owner/parent per LAND-PREP-1 | SCOPE owner-reserved list | not S8-G's |

Escalations that change a grade mid-build: touching any "not owned" path in PATHS.md (stop, disposition); needing a schema/migration (stop: S8-G has none by design); needing a new reason code or event key (stop: READINESS forbids; DESIGN uses none); Nest DI failing to resolve the optional parameter (allows the `scout.module.ts` provider-only hunk, still T4, recorded).
