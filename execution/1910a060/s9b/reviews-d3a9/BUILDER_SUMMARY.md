# S9-B T4 rebuild — six lost files (session d3a9f701)

W = /home/user/workspace/worktrees/1910a060-s9b (branch exec1910/s9b, HEAD 9497ca52). No commits, no pushes,
no heavy tools run (only `bash -n`, `node --check`, read-only greps of the donor node_modules). Frozen files untouched.

`git status --porcelain --untracked-files=all` = ` M docs/decisions/2026-09-25-s9-reconciliation.md` + `??` for exactly
the 10 NEW_FILES of gate/PINS (4 frozen + these 6). Nothing else.

## Files (pre-prettier bytes; the gate's prettier stage will reflow the .ts files, so take the final pins from its
POSTFORMAT lines / after `prettier --write`. The .sh and .cjs? — .cjs IS in PRETTIER_FILES too; only .sh is excluded.)

| path | sha256 (as written) | mode |
|---|---|---|
| src/scout/reconciliation/reconciliation.module.ts | 48040a5af6e3598475eb7423cb42a25dee711bbc6bd6c87903e6cec292406e8a | 644 |
| test/utils/g2-s9-pg-harness.ts | 3a6bd56a555715184d52bc9872c6ceec8ec0a68f8690a203fe24ebaebe871469 | 644 |
| test/utils/g2-s9-harness.ts | 0378563b3681bb296a6f528c3492dfccef610d50014f1227d38679ada5a51732 | 644 |
| test/utils/g2-s9-worker.cjs | d2fba3a8b8be63c468014d38cf0d76bff4860b84f742c5426e02e631b6d1d195 | 644 |
| test/utils/g2-s9-bootstrap.sh | 8799525798ce64c4133167770d15cb301b8318d096c01c004124f1bb85974386 | 755 |
| test/rls-g2-s9.spec.ts | ff84db29680390eb611ae7cc6eb32cab1469b5035ceb863fa7e030612dbfb576 | 644 |

## Contract mapping

- **reconciliation.module.ts** — `@Module({ providers: [ReconciliationFactsService], exports: [ReconciliationFactsService] })
  export class ReconciliationModule`. Imported by nothing (S9-C wires it); scout.module.ts untouched.
- **g2-s9-pg-harness.ts** — S8-C pg-harness by substitution: G2_S9_* env, imports from frozen g2-s9-db.ts
  (G2_S9_ADMIN_ROLE/MIGRATION_ROLE/RUNTIME_ROLE/BASE_HEAD/CANDIDATE_HEAD_ENV, g2S9CandidateHead, g2S9TestTarget,
  withFixturePassword). Exports root, BASE_HEAD (`: string = G2_S9_BASE_HEAD`), S8B_MIGRATION, S7L_MIGRATION,
  EXPECTED_MIGRATIONS = 172, psql, directory, expectedVersion (170006), target, candidateHead, migrationUrl, sql, sqlAdmin,
  sqlAs, quote, json, jsonAdmin, refused, appliedMigrations, WorkerMode, Result, worker (with `mode` option, default
  'facts'; fork env `G2_S9_WORKER`, file test/utils/g2-s9-worker.cjs, app name `g2s9_N`), run, blocked, holdTransaction,
  gitShow, prisma, prismaMigrateDeploy. Pause/barrier instrumentation kept. Guard-spec literals verified by grep.
- **g2-s9-harness.ts** — S8-C harness + S9 additions: PLATFORM 's9-proof' (SPEC/RULES identical shape to S8-C),
  PLATFORM_B 's9-proof-b' (SPEC_B workouts-only, same as unit spec's other-proof), REGISTRY / REGISTRY_AB, childSourceId,
  ensureUser, settle, claim() (ScoutImportCompletion upsert on coach_id,intent_id), stage (any token), ledgerRow (R05
  orphan fixture), catalog, provenanceRows/ledgerRows/plans/programs/exercises/count/evidenceRows, WATCHED_TABLES +
  snapshot() (count + md5 content digest per table), resetData() incl. ScoutImportCompletion.
- **g2-s9-worker.cjs** — S8-C worker + `mode`: 'facts' (default) builds registries from parsed spec(s)/rules
  (array or single), `new ReconciliationFactsService({sourceMappers, nativeRules})`, one `db.$transaction(fn,
  {isolationLevel:'RepeatableRead'})` that first reads `current_setting('transaction_isolation')` from PG then runs
  `collect(tx, coach, intent)`, then frozen `reconcile(facts)`; returns `{done, result:{isolation, facts, verdict, report},
  queries, events, pid, families}`. 'reconstruct' = S8-C writer path verbatim. Head check before any client; @prisma/client
  pinned to input.client; query shapes only logged.
- **g2-s9-bootstrap.sh** — S8-C bootstrap by substitution: G2_S9_* env, g2_s9_disposable / s9_super / postgres /
  service_role, BASE_HEAD=1c5fbb04…, EXPECTED_MIGRATIONS=172, S8B_MIGRATION, S7L_MIGRATION, CLUSTER_MARKER / DB_MARKER
  literals; modes bootstrap|verify-only; asserts S7-L (ScoutImportCompletion; ScoutImport mode/execution_epoch/reason_code),
  S8-B (provenance, ledger target_kind, CHECKs), S8-C/S9 targets (WorkoutProgram/Plan/PlanExercise/Revision,
  ExerciseCatalogItem, ScoutReconstructedEntity, ScoutIngestEntity, Person). Candidate client verified STRUCTURALLY
  (engine sha = @prisma/engines copy, runtime realpath = pinned, models/columns grep in client schema.prisma incl.
  ScoutImportCompletion.terminal_status, ScoutImport.mode, WorkoutPlan.program_id); NO invented ACCEPTED_CLIENT_SCHEMA_SHA
  (the copy's sha is printed, not pinned). Prints CANDIDATE_HEAD=…, CANDIDATE_CLIENT_VERIFIED …, G2_S9_BOOTSTRAP_OK.
  Structural checks validated against the donor client schema (all pass). `bash -n` OK.
- **test/rls-g2-s9.spec.ts** — exactly 10 `it(` in 4 describes (no it.each / skip / only):
  1. lane identity: version 170006, cluster 's9-disposable-pg17', directory, port, db 'g2_s9_disposable', 172 migrations,
     S7-L/S8-B/S8-C objects, no hosted roles.
  2. bound to attested candidate head (40-hex, ≠ base, HEAD clean, descends from base).
  3. empty run (R19/R12/RC-1): facts exactly {claim null, families [], relationships [], spec_families null,
     ledger_without_staged 0, coverage null}; verdict partial/coverage_basis_unknown, required_families null;
     claim filter: 'complete' → null; success|partial|failed pass through and never yield Complete.
  4. real writer rows (program + program-day + standalone): present_owned facts, E-R1 consistent true, E-R2 one edge per
     created child all true, spec_families = 4, verified report [ch 0, clients 0, programs 1, workouts 2 'verified'],
     conditions exactly ['coverage_basis_unknown'] (no false Complete), created_native/already_present_verified/
     observed_unique null, completeness_basis 'none'; writer replay + second collect → facts and report deep-equal,
     identities unique (idempotent / no duplicate identity).
  5. R04 drift: archived program + deleted plan → 'removed', native_target_removed, E-R1/E-R2 inconsistent,
     conditions [unresolved_identities, relationship_unverified, coverage_basis_unknown]; ledger/provenance rows unchanged.
  6. R11 tenancy: coach-b same source ids → both present_owned, factsA == factsB (coach-scoped identity); provenance
     repoint → provenance_mismatch; provenance+ledger repoint to B's plan → foreign_owner → identity_conflict, B's facts
     unchanged; symmetric case B→A; native rows of the other tenant untouched.
  7. R05/R08: 3 orphan ledger rows (workouts, blocks→programs ledger-only entry, notes→none) counted run-wide 3 and
     attributed; unresolved children histogram {exercise_reference: 2} with 2 consistent E-R2 edges; client-linked
     evidence row → no_native_client_principal + E-R3 client_link consistent null; workouts report tally.
  8. RC-3: unmapped tokens (unresolved_family:notes, unresolved_family:programs on s9-proof-b), union spec_families across two
     registered platforms, not_reconstructed for never-written row; unregistered platform → spec_families null,
     required_families null, unsupported_platform:<p> rejected; verdict partial/unresolved_family.
  9. read-only + isolation (C-9): server-reported isolation 'repeatable read', one BEGIN..COMMIT, SELECT-only log
     (no INSERT/UPDATE/DELETE/DDL), every watched table's count + content digest unchanged.
  10. bounded (R08): empty run 3 SELECTs; verified fixture 7 SELECTs over exactly the 7 tables (no Person); 503 staged rows
      → +1 (second staged page); 500 unwritten rows → unresolved 500, never zero, never Complete.

## Gate / binding non-hash expectations
None need to change: EXPECT_TESTS=10; port 55645; db/role names; env vars G2_S9_*; bootstrap markers
`G2_S9_BOOTSTRAP_OK` / `CANDIDATE_HEAD=`; grep pins `EXPECTED_MIGRATIONS = 172;` and `S7L_MIGRATION = '…'` in pg-harness;
guard-spec literals in bootstrap/harness; status set. Only the 6 sha256 pins (SHA_MODULE, SHA_G2_PGH, SHA_G2_HARNESS,
SHA_G2_WORKER, SHA_G2_BOOTSTRAP, SHA_RLS_SPEC) need new values — take them AFTER the gate's prettier stage (.ts/.cjs reflow;
.sh unchanged).

## Residual risks for the bounded typecheck/test window
- Not type-checked or linted here (forbidden). Written to mirror the S8-C siblings; static unused-import scan clean.
- Exact SELECT counts (3 / 7 / +1) derive from facts.service.ts's query structure; Prisma 6.19 emits one SELECT per
  findUnique/findMany. The isolation assertion uses PG's own `current_setting('transaction_isolation')` instead of log wording.
- Provenance `reason` tags for the program-day row are intentionally not pinned (defaulted:type may apply).
