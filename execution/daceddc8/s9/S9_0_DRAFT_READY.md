# S9-0 draft ready (decision doc; uncommitted)

Lane `s9_0_decision_doc`, grant S9-0-1 (`execution/daceddc8/SCOPE.md` "S7-L landed" → "Grants"), T3
sole writer. Status: **DRAFT_READY**. The draft is not committed. The commit waits for the parent to
relay the heavy slot and for one independent T3 review to return GO. This evidence repo is not
committed.

## Worktree state

- Worktree: `worktrees/64e33dc7-s7l`.
- Branch: `exec-dace/s9-0`, created with `git switch -c` at `df713fd9217df524915348ef8a42c797f288dde1`
  (`integration/importer`). HEAD has not moved, and no other ref changed.
- Working tree: exactly one untracked file and no other change (`git status --porcelain
  --untracked-files=all` shows only `?? docs/decisions/2026-09-25-s9-reconciliation.md`).
- File: `docs/decisions/2026-09-25-s9-reconciliation.md`, 463 lines, 37,555 bytes.
- **sha256:** `53c15c686dd330d33595ed2048cb2fd20710d2f0a383d6e54fceca4a397ec521`
- Formatting: `npx prettier --check` passes. The repo `.prettierrc` has printWidth 100. The lefthook
  pre-commit prettier glob includes `*.md`. Prettier is not a devDependency, so npx fetched it,
  exactly as the hook will. R75 does not scan `docs/`.
- No code, no schema change and no other file.

## What the doc records

**D-S9-1: S9 computes and never writes.**
- `reconcile(facts)` is pure, plus a facts service.
- S9 never writes a terminal, ledger, provenance or native row, never fences and adds no route.
- It runs inside S8-G's settle transaction.
- Arbiter precedence is unchanged (S7L-DOC L67-74).
- Its outcome set is only `complete | partial`.

**D-S9-2: verdict predicate.**
- Grouping goes through `resolveStagedFamily`. A failed resolution forms an unmapped entry.
- Staging and ledger are joined on the wide identity (schema L6996), and provenance on the D-S8-3
  key (S8-DOC L93-98). These are identity joins, not count comparisons.
- A first-match classification table (buckets a-j) puts every staged identity in exactly one of
  `native_present_verified`, `rejected`, `unresolved` or `failed`, with a histogram key. It covers:
  - D-C1 not-reconstructed rows and the ceiling;
  - evidence and no-principal rows;
  - missing provenance and identity conflicts;
  - C4 removed targets.
- Also recorded:
  - `ledger_without_staged`;
  - `unresolved_children` (S8-DOC L150-151, L194-197, L435-438);
  - the partition invariant;
  - closure edges E-R1 (plan→program and week/day), E-R2 (child→plan and `#ord:` order) and E-R3
    (`client_source_id`).
- Run conditions, in order: C-FAM → `unresolved_family`; C-ID → `unresolved_identities` (the S8-DOC
  L152-157 family-complete rule); C-REL → `relationship_unverified`; C-COV →
  `coverage_basis_unknown`. `reason_code` is the first condition that holds. `conditions` lists them
  all. `complete` requires an empty list, and an empty run is never vacuously complete.

**D-S9-3 (F1): `complete` needs a recorded basis.**
- `complete` requires a recorded per-family basis (`CoverageFact` with `known` and
  `covers_staged_identities`) and a stored claim of `success`.
- S9-B passes `coverage: null` in v1. Every native-clean run is therefore `partial/coverage_basis_unknown`.
- `COMPLETENESS_BASIS_KINDS = ['none']`. S10 adds its evaluator and kinds additively, with no core
  change.

**D-S9-4 (F2): verified union only.** The report carries only `native_present_verified`.
`created_native` and `already_present_verified` are `null` ("not yet known", never 0) until N3-FILL.

**D-S9-5: report and manifest v1, recomputed on read, no table.**
- The TS shape is given. It carries CQ-13 fields (`completeness_basis`, closure, reasons,
  qualifiers `roster_bridge_pending`). Fields not yet known are `null`.
- The projection keeps `families[]` one entry per token (S7L-DOC L207-210) and adds additive fields
  (`canonical_family`, `native_present_verified`, `completeness_basis`, `relationship_closure`,
  `reasons`, `qualifiers`) through the generator owner.
- The no-table justification has four points:
  1. `complete` is unreachable in v1, so a recomputed report cannot contradict it.
  2. Drift can only show the current native state under a terminal that stays `partial`.
  3. R10 and R15 hold for a recomputed report.
  4. A table would pull in L8 retention, which is owner-reserved.
- Re-decision trigger: persistence is re-decided when S10 makes `complete` reachable.

**D-S9-6: ceiling and `blocked`.** The ceiling case ends `partial/unresolved_identities` with key
`unresolved:pass_ceiling_exceeded`. `blocked` stays fence-`revoked` only.

**D-S9-7: reason codes.**
- Three run codes are appended to `RUN_REASON_CODES` (L46-53). The TEXT column needs no schema
  change (migration L126-128).
- The additions must land with the wiring, because the projection narrows unknown codes to null
  (L574-575).
- S9-A carries its own `S9_REASON_CODES`. S9-C proves `S9ReasonCode ⊆ RunReasonCode` at compile
  time.
- Report histogram keys are the S8-DOC §3.7 list plus six S9 keys. An unrecognised ledger reason
  becomes `unresolved:reason_unrecognised`. `failed` never echoes its text. No PII anywhere.

**D-S9-8: seam and paths per slice.** S9-A matches grant S9-A-1 exactly. S9-B has no migration or
schema paths. S9-C and Gen are listed.

**Other sections.** Acceptance R01-R19 (R01-R16 from READINESS, adapted to F1/F2/no-table, plus
R17 precedence, R18 empty run and R19 children); owner-reserved and deferred items; release
boundary.

## Points for the reviewer (deliberate deviations and choices)

1. **S9-C gains two narrow hunks the READINESS §3 table marked "not owned".** The status read and
   its DTO live in `src/scout/scout.service.ts` (`families` composition at L455/L497 only) and
   `src/scout/scout.dto.ts` (`ScoutImportFamilyDto` additive properties only, L219-262). Without
   them the report cannot reach `families[]`. The migration, schema and new-table RLS paths were
   dropped (no table).
2. **Rejected rows block `complete`.** They count under C-ID, a strict reading of S8-DOC L152-155:
   "every staged identity is `created` or `already_present`".
3. **Unmapped entries include `unsupported_platform` resolutions** under C-FAM →
   `unresolved_family`. Row-level detail stays in the histogram.
4. **A non-`success` claim keeps coverage unknown.** It adds a conjunct to `complete` and no new
   code.
5. **E2 consumer-freeze safety.** `families[]` keeps its per-token key and existing fields. Every
   S9 field is additive.

## Not done (by grant)

No commit, no push, no hooks run, no tests, no PG work and no change to the evidence repo other than
this file.
