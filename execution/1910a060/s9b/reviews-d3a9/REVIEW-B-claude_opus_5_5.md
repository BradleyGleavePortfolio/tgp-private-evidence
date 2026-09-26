# S9-B rebuilt-files review — reviewer B (T4, read-only)

Worktree: /home/user/workspace/worktrees/1910a060-s9b @ 9497ca52 (uncommitted, 11 status lines = the 10 NEW_FILES + the modified doc).
No edits, tests, tsc, jest, npm, npx, prettier or postgres were run, and the lock was not touched. I used only sha256sum, rg, diff, `bash -n` and git read commands.

## Verdict: GO. No A or B findings against the six rebuilt files.

## (1) The five recovered files match their pins
facts.service.ts e2f40a79… = SHA_FACTS_SERVICE; facts.service.spec.ts 9dcfbd96… = SHA_FACTS_SPEC; g2-s9-db.ts 39ba033b… = SHA_G2_DB;
g2-s9-db-guard.spec.ts a99cf9c9… = SHA_G2_GUARD_SPEC; doc be591e97… = SHA_DOC_ADDENDUM. All five MATCH.

## (2) reconciliation.module.ts (48040a5a…)
It is a single `@Module({ providers: [ReconciliationFactsService], exports: [ReconciliationFactsService] })`. It has no controller, no imports and no side effects. Nothing in src/ or test/ imports it, so it has no customer-facing effect. The service's `@Optional() @Inject(RECONCILIATION_FACTS_OPTIONS)` constructor resolves without a provider. It is correct and minimal.

## (3) rls-g2-s9.spec.ts (ff84db29…)
- The spec has 10 `it(` calls in 4 describes (2 lane identity + 4 evidence + 2 unaccounted/unmapped + 2 bounded/read-only). This is the same structure reviewer A recorded for the lost original. There is no skip, only, todo, it.each or test(. This matches EXPECT_TESTS=10 and the `^Tests: +10 passed` check.
- Identity checks: the spec asserts the cluster 's9-disposable-pg17', the db 'g2_s9_disposable', `target.port` (from the double-entered G2_S9_CONFIRM; runner port 55645), data_directory = G2_S9_DATA_DIRECTORY, version 170006, 172 migrations and no hosted roles. The candidate head must be clean, must not be the base, and must descend from 1c5fbb04 (verified to be an ancestor of M2).
- Invariants, all asserted with exact toEqual or exact arrays and none vacuous:
  - **Unknown never becomes zero:** empty facts are `{claim:null, families:[], spec_families:null, coverage:null, ...}`. `created_native`, `already_present_verified` and `observed_unique` are null and `completeness_basis` is 'none'. The 500 unwritten rows give `unresolved: 500`.
  - **No false Complete:** a fully verified run gives `partial/coverage_basis_unknown`, and a 'complete' claim is filtered to null.
  - **Tenant isolation:** R11 is tested both ways (A→B and B→A), with B's facts unchanged and the other tenant's native rows unchanged.
  - **Read-only:** the isolation level is read back from the server; there is exactly one BEGIN/COMMIT pair; the query log contains SELECT/SET/DEALLOCATE only; and the count plus md5 content digest of 11 watched tables are unchanged.
  - **Bounded queries:** exactly 3 and 7 SELECTs over the named tables, and +1 SELECT for 503 staged rows.
  - **Idempotent, no duplicate identity:** after the writer is replayed, the facts and report deep-equal the first run, the identity set is unique, and the table counts are fixed.
- I cross-checked the fixtures against the schema and constraints:
  - The ScoutImportCompletion table has no CHECK constraint, so storing 'complete' works.
  - The ledger target_kind shape CHECK is satisfied, and the platform names pass the canonical regex.
  - WorkoutPlan deletes cascade to their revisions and exercises.
  - The child ordinal is 0-based, as in S8-C.
  - The field names in the report and facts types match the assertions (types.ts).

## (4) Harness, worker and bootstrap
- **g2-s9-pg-harness.ts:** it differs from g2-s8c-pg-harness.ts only by substitution plus S7L_MIGRATION, 172 and `mode`. It contains the literals the guard spec asserts (`export const BASE_HEAD: string = G2_S9_BASE_HEAD;`, `EXPECTED_MIGRATIONS = 172;`, `S8B_MIGRATION`/`S7L_MIGRATION`). The env it reads is exactly what the runner exports.
- **g2-s9-worker.cjs:** it keeps the S8-C worker's head check before any client is created. The facts mode runs one RepeatableRead `$transaction` and then the frozen `reconcile`. The reconstruct mode is the S8-C path unchanged.
- **g2-s9-bootstrap.sh:**
  - Mode is 755, `bash -n` passes, and it has no secrets (the password comes from env/PGPASSWORD only).
  - It carries `CLUSTER_MARKER=`, `DB_MARKER=`, `BASE_HEAD=`, `EXPECTED_MIGRATIONS=172`, `S8B_`/`S7L_MIGRATION` and `G2_S9_CANDIDATE_HEAD` literally.
  - It refuses a non-loopback or refused-port target (g2S9TestTarget), a foreign cluster_name before any write, a database without the marker comment, and hosted roles.
  - It prints the `CANDIDATE_HEAD=` and `G2_S9_BOOTSTRAP_OK` lines the runner greps for.
  - Its preconditions hold at M2: the prisma tree and package manifests are identical to 1c5fbb04, and there are 172 migration dirs.

## (5) Typecheck and lint
- I found no unused imports or locals in any of the 6 files.
- `no-explicit-any` is off in eslint.config.js.
- None of the R75 banned tokens appear in the six files.
- The TS target is ES2021, so `entries()` iteration is fine, and the casts are only `as Facts`, `as WorkerMode` and `as Array<…>` on `any`.
- Lines over 100 characters are comments or template text only; prettier reflow is left to the gate.

## Non-blocking (C)
- **C-1 (required step before the gate; not a defect in the files).** gate/PINS.env still pins the lost originals: SHA_MODULE f2c1e447, SHA_G2_PGH 8274a85b, SHA_G2_HARNESS 16a5aeac, SHA_G2_WORKER 5e52b918, SHA_G2_BOOTSTRAP 8452feba and SHA_RLS_SPEC b854fd59. The gate's `chk` at s9b-gate-1910.sh L90-98 will refuse until the parent re-pins them to 48040a5a… / 3a6bd56a… / 0378563b… / d2fba3a8… / 87995257… / ff84db29… (and records this in SOURCE_READY §2).
- **C-2.** Bootstrap L203-208 says "no pre-computed digest" of the client schema copy exists. The accepted value b84392033… does exist (PINS.env CLIENT_SCHEMA; the gate enforces it at L144). The structural check matches the original disposition ("no invented SHA"). Optionally, add an exact-sha check at L217 and fix the comment.
- **C-3.** The exact SELECT counts (3 and 7) are stricter than the original 6-7 range, and the spec relies on Prisma 6 logging BEGIN/COMMIT (tq0 precedent). If the live run fails, it fails closed, so this is a risk to note, not a weakening.
