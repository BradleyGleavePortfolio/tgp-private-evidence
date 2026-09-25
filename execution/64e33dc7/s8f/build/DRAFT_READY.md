# S8-F native reader — DRAFT_READY (source preparation only)

Status: **DRAFT_READY**. Source prepared, checkpointed and hashed. **Nothing compiled, linted,
formatted, tested or executed against PostgreSQL.** No install, `prisma generate`, tsc, Jest,
prettier, hooks, PG connection, canonical-lock operation, commit, push or external publication
was performed by this lane. Gates and commit await parent composition onto the accepted S8-C.

- Worktree: `/home/user/workspace/worktrees/64e33dc7-s8f`, branch `exec64/s8f-readers`
- Base: `93389265a846095b846fa8f1fb0dad782fb6ee9f` (`BASE_HEAD.txt`), unchanged HEAD; all edits
  uncommitted (`GIT_STATUS_PORCELAIN.txt`: 10 modified, 5 untracked)
- Grant: `execution/64e33dc7/S8F_SOURCE_PREPARATION_GRANT.md`; readiness `s8f/READINESS.md` (read
  only, not altered)
- Other worktrees (`64e33dc7-env`, `-s7l`, `-s8c`) neither read nor written.

## Checkpoint (immutable exact export)

`s8f/build/checkpoint/<repo path>` = byte copy of every changed/new file; `TRACKED_EDITS.patch` =
`git diff 93389265` of the tracked files; `UNTRACKED_WORKTREE_SHA256.txt` = the untracked files'
hashes as they sit in the worktree (match `CHECKPOINT_MANIFEST.sha256`). Verify with
`cd s8f/build && sha256sum -c CHECKPOINT_MANIFEST.sha256`.

## Changed paths (15; all inside the granted surface)

Source (6):
- `src/scout/scout-entities.dto.ts` — `ENTITY_TARGET_KIND` {scout_entity, workout_program,
  workout_plan}, `EntityTargetKind`, `ENTITY_TARGET_KINDS`; `ReconstructedEntityDto` gains
  `target_kind` (enum) and nullable `native_id` (uuid). Additive only.
- `src/scout/scout-entities.service.ts` — ledger select adds `target_kind`; `materialize`
  dispatches on the effective kind: NULL/`scout_entity` → unchanged evidence join;
  `workout_plan`/`workout_program` → same-coach, `archived_at IS NULL` native row AND same-coach
  `ImportNativeProvenance` (native_kind, native_id) with outcome `created`/`already_present`;
  unknown kind, typed row with NULL target, missing/foreign/archived row, missing/mismatched
  provenance → dropped (fail closed). One RepeatableRead snapshot, uniform settled-intent 404,
  ledger-anchored cursor, `page_count = entities.length`, erased-row drop all preserved. Native rows:
  `id = native_id = native row id`, `label = name`, `client_source_id = null`, source
  platform/id from the ledger row, no payload.
- `src/scout/scout-roster.dto.ts` — `ROSTER_TARGET_KIND = 'person'`, `ROSTER_BRIDGE_PENDING = true`;
  `ScoutRosterResult.roster_bridge_pending: boolean`.
- `src/scout/scout-roster.service.ts` — ledger select adds `target_kind`; only NULL/`person` rows
  reach the Person join (existing semantics); response carries `roster_bridge_pending: true`
  including empty results. Row shape unchanged.
- `src/scout/scout-entities.controller.ts`, `src/scout/scout-roster.controller.ts` —
  `@ApiOperation` description text only.

Focused default tests (4 edited):
- `test/scout/entities/scout-entities.service.spec.ts` — FakePrisma gains `plans`, `programs`,
  `provenance`, `nativeReads`; legacy key-set updated; new block "S8-F native targets": F01, F02
  (exact where shapes incl. `archived_at: null` and outcome `in`), F03 (`it.skip` until a
  `programs`-family is in `ENTITY_REVIEW_FAMILIES` — see dependencies), F04, F05, F06, F07, F08,
  F09, F11, analytics unchanged.
- `test/scout/entities/scout-entities.contract.spec.ts` — published props now include
  `native_id`/`target_kind`; enum/nullable/required assertions; PR-M4 fixture typed.
- `test/scout/roster/scout-roster.service.spec.ts` — qualifier on populated and empty pages,
  response-level only, F10 (explicit `person` kind materializes; non-person kinds never joined even
  when the id matches a Person; typed-only page empty with cursor advancing, zero Person reads).
- `test/scout/roster/scout-roster.controller.spec.ts` — `emptyResult` gains
  `roster_bridge_pending: true` (TypeScript requires it).

Minimum real-RLS proof source (5 new; **prepared, not executed**):
- `test/utils/g2-s8f-db.ts` — target guard (DB `g2_s8f_disposable`, role `s8f_super`, env
  `G2_S8F_PASSWORD`, markers `s8f-disposable-pg17` /
  `s8f-g2-native-reader-synthetic-disposable-fixture-safe-to-drop`; refuses all earlier lane
  ports incl. 55511/55641/55642). Derived from `g2-s8b-db.ts`, which is untouched.
- `test/scout/g2-s8f-db-guard.spec.ts` — default-run guard unit test (example port 55643).
- `test/utils/g2-s8f-bootstrap.sh` — reduced bootstrap (no OLD side, no migration under test;
  `prisma migrate deploy` of the composed candidate; refuses uncommitted schema/migration changes).
- `test/utils/g2-s8f-pg-harness.ts` — psql/worker helpers + synthetic seeders (User, ScoutImport,
  ledger with kind, evidence, WorkoutPlan, WorkoutProgram, provenance). Uses the unchanged
  `test/utils/g2-tq0-worker.cjs` `entities`/`roster` actions.
- `test/rls-g2-s8f.spec.ts` — stages: lane identity; F01/F02/F04 native joins on RLS-enabled
  tables + cross-tenant drop + API-role denial; F05 provenance denial (no/unresolved/kind-mismatch/
  table-mismatch provenance) + S8-B CHECK forgeries refused; F07 archived-row paging (limit 2 over
  5 rows) + un-archive reappearance; F10 roster on a real ledger + uniform 404. Auto-excluded from
  default Jest by `jest.config.js`; run only via `jest.rls.config.js` with the `G2_S8F_*` env.

## Dependency assumptions (must hold at composition)

1. **S8-C N1–N4 kinds** as frozen: ledger `target_kind` ∈ {person, scout_entity, workout_program,
   workout_plan} (S8-B CHECK), provenance `native_kind` ∈ {workout_plan, workout_program, ...},
   outcomes `created | already_present | unresolved`. Reader treats exactly `created` and
   `already_present` as qualifying.
2. **Schema/client** at the composed head = S8-B (`ImportNativeProvenance`, ledger `target_kind`)
   + accepted `WorkoutPlan`/`WorkoutProgram` (`coach_id`, `name`, `archived_at`). Client must be
   generated by the owner's process; this lane ran no `prisma generate`.
3. **F03 (`workout_program` end-to-end)** is `it.skip` because no `programs` family exists in
   `ENTITY_REVIEW_FAMILIES` at base 93389265; the service path is exercised through the mixed-kind
   tests. Un-skip only when S8-C (or its accepted successor) adds the family; the family list is
   not S8-F-owned.
4. **Frozen importer contract (not S8-F-owned):** the additive DTO fields change
   `docs/contracts/importer-openapi.json`, and `test/contracts/importer-contract.spec.ts` pins
   `ReconstructedEntityDto` props exactly (line ~252) — that spec WILL FAIL until the contract
   owner regenerates the artifact and updates the pinned list (both readers are in the frozen slice,
   `scripts/importer-contract.ts` lines 32–33). This is F12 (generator territory); only the
   in-surface `scout-entities.contract.spec.ts` was prepared. Same for `ScoutRosterResult`
   (`roster_bridge_pending`) if the frozen spec pins it.
5. **Principal/visibility policy owner-reserved:** the program join filters on `coach_id` +
   `archived_at` only; `owner_user_id`/`visibility` are NOT applied. Provenance match is
   (coach_id, native_kind, native_id, outcome) only — no `import_intent_id`, `source_namespace` or
   `source_id` join (grant: no intent inference through the nullable UUID field).
6. Legacy rows: NULL kind is reported as effective `scout_entity` with `native_id: null`; no
   backfill, no accepted-proof rerun.

## Actual unexecuted status / known risks

- No tsc/ts-node/Jest/prettier/eslint run: type errors or line-length nits are possible and
  unverified. Likely-clean but unchecked spots: Prisma `OR` typing in the provenance where; `const`
  select object typing for `NativeRecord`; unused-import lint in new test files.
- The live proof's seeders assume `User (id,supabase_id,email,name,role)` insert shape (copied from
  the S8-B harness), `WorkoutPlan.type='strength'`, `WorkoutProgram (weeks, days_per_week)`
  required ints, `PersonState` default — unverified against a real database.
- `test/utils/g2-s8f-bootstrap.sh` marker literals match `g2-s8f-db.ts` (guard spec asserts this
  by reading the file); executable bit set on the worktree copy.
- Commits remain `Bradley Gleave <bradley@bradleytgpcoaching.com>` (G05); this lane committed
  nothing.
