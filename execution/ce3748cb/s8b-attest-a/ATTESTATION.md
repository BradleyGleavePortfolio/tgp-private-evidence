# S8-B attestation A (independent T4, read-only, no PG)

Candidate: `worktrees/s8-b` HEAD `edd6dc6b2c3ce82f64d567930edad27fbfc77255` (tree `5a4db6c9…`), parent accepted C `1b6cc661`. Authority: `S8_B_DRAFT_GRANT.md`, `POST_C_SEQUENCING.md`, `s8-prep/S8_BRIEF.md` row S8-B, S8-0 contract `e322602d:docs/decisions/2026-09-24-s8-native-contract.md` (§3.2, §3.3 incl. A2, §3.4, D-S8-3). Builder records `s8b/DRAFT_READY.md`, `s8b/SOURCE_READY.md`, `s8b/binding/*`. `s8b-attest-b` not read. Nothing executed against PostgreSQL; every rendering claim below is derived from PostgreSQL ruleutils/catalog rules plus the accepted C/R/B precedents that used the same forms.

## Verdict

**NO-GO as-is for the single PG run. One B (proof-invalidating, deterministic) finding in the spec, closure is a two-line spec edit + re-pin. GO once B-1 is closed; no SQL, schema, harness or binding-logic change is needed.**

## B-1 — spec `tally()` omits `intent_id`; strict `toEqual` fails deterministically and cascades

- `test/rls-g2-s8b.spec.ts` L101-106: `tally = (staged, reconstructed) => ({ staged, reconstructed, skipped: 0, failed: 0 })`, used with `expect(pass.result).toEqual(tally(…))` in stage 1 case 1, stage 3 P05 (three times) and stage 4 P04.
- The real writer returns `{ intent_id, staged, reconstructed, skipped, failed }` (`src/scout/scout-reconstruct.service.ts` L322-328, byte-identical to OLD_HEAD; the worker `test/utils/g2-tq0-worker.cjs` L95 forwards it unchanged). The accepted C proof asserts exactly that shape including `intent_id` (`test/rls-g2-c-contract.spec.ts` L692-698), and N/Q1 likewise (`test/rls-g2-nq1.spec.ts` L277-283).
- Jest `toEqual` does not ignore a defined extra key, so stage 1 case 1 fails at its second `expect`, **before** `before = shape()` is assigned. Every later `expect(shape()).toEqual(before)` fails and P01 throws on `before.ledger.columns`. The run cannot produce the P01–P06 evidence.
- Harm: none to product (spec only). Decision blocked: the S8-B PG proof. Minimum closure: `tally` returns `{ intent_id: 'intent', staged, reconstructed, skipped: 0, failed: 0 }` (every `run()` in this spec uses the default intent `'intent'`), or switch the five call sites to `toMatchObject`. Ordinary hooked Bradley commit on top of `edd6dc6b` (history not rewritten); re-pin `EXPECT_HEAD`/`EXPECT_TREE`/`EXPECT_SPEC_BLOB` in `s8b-pg-proof.sh`, reseal `BINDING.sha256`/`PINS.txt`, re-export; delta re-check limited to that hunk and the pin lines. Execution unlocked: the single PG run.

## Catalog rendering strings (builder finding 8, UNVERIFIED) — checked, none expected to fail on PG 17

Rules applied: `pg_get_constraintdef(oid)`/`pg_get_expr` deparse with `PRETTYFLAG_INDENT` only (no `PRETTYFLAG_PAREN`), so every OpExpr/BoolExpr/NullTest/ScalarArrayOpExpr is wrapped in its own parentheses; text constants carry `::text`; `IN (…)` on a text column is stored as `col = ANY (ARRAY['a'::text, …])` (CHECK expressions are not constant-folded at cook time); implicit casts (`COERCE_IMPLICIT_CAST`) are hidden; `pg_get_indexdef(oid)` always schema-qualifies the table (`generate_qualified_relation_name`) and never quotes lowercase identifiers; `generate_relation_name` in FK defs qualifies only when the table is not visible on `search_path`; FK renders `ON UPDATE` before `ON DELETE` and omits `NO ACTION`; NOT NULL constraints are not in `pg_constraint` on PG 17 (the spec pins `< 180000`).

| expectation (`test/utils/g2-s8b-harness.ts`) | verdict |
|---|---|
| `CHECK (((native_id IS NULL) = (outcome = 'unresolved'::text)))` | matches |
| `CHECK ((native_kind = ANY (ARRAY['person'::text, …, 'workout_plan_exercise'::text])))` | matches |
| `CHECK ((outcome = ANY (ARRAY['created'::text, 'already_present'::text, 'unresolved'::text])))` | matches |
| `CHECK (((outcome <> 'unresolved'::text) OR (reason IS NOT NULL)))` | matches |
| `CHECK (((target_kind IS NULL) OR (target_kind = ANY (ARRAY[…4…]))))` | matches (paren count verified: `]))))`) |
| `CHECK (((target_kind IS NULL) OR (target_id IS NOT NULL)))` | matches |
| `FOREIGN KEY (import_intent_id, coach_id) REFERENCES "ImportIntent"(id, coach_id) ON UPDATE CASCADE ON DELETE RESTRICT` | matches (owner session `postgres`, default `search_path` → unqualified, mixed-case quoted) |
| `PRIMARY KEY (id)` | matches |
| four `CREATE [UNIQUE] INDEX "…" ON public."ImportNativeProvenance" USING btree (…)` | match; same form as the accepted B/R/C entry gates and the C harness literal `CHECK (((source_platform COLLATE "C") ~ '…'::text))` |
| columns `text` / `uuid` / `timestamp(3) without time zone`, default `CURRENT_TIMESTAMP` | match (`format_type`; PG 16+ `COERCE_SQL_SYNTAX` renders `CURRENT_TIMESTAMP`, the implicit timestamptz→timestamp(3) casts are hidden, as in pg_dump of every Prisma table) |
| `pg_policies` `permissive` `'RESTRICTIVE'/'PERMISSIVE'`, `roles` JSON arrays, `cmd` `'ALL'`, ordered by policyname under `C.UTF-8` | match |
| grants: `service_role` present, `anon`/`authenticated` absent | match: bootstrap L135 `ALTER DEFAULT PRIVILEGES FOR ROLE postgres … GRANT ALL ON TABLES TO anon, authenticated, service_role`; deploy and the psql re-apply both run as `postgres`; the migration revokes the two API roles |
| migration.sql / down.sql `pg_get_indexdef` literals (ledger identity key, `ImportIntent_id_coach_id_key`, provenance identity key) | match; ImportIntent index created 20270117 L17 as `CREATE UNIQUE INDEX` on `(id, coach_id)`, table RLS enabled+forced (L22-23), `id uuid NOT NULL`, `coach_id text NOT NULL` |

CHECK evaluation order (by constraint name) was checked against every refusal case in stage 3: no case violates two S8-B constraints at once, so the asserted constraint name is the only possible one. NOT NULL fires before CHECKs (`coach_id`/`source_namespace`/`source_id` cases). The G2-B ledger fence trigger is BEFORE INSERT on NULL `source_platform` only; the typed-without-target ledger INSERT supplies `'truecoach'` and reaches the shape CHECK.

## Delta review (DDL, semantics, compatibility)

- **Atomicity/locks.** One `BEGIN…COMMIT`, `lock_timeout 5s`, `statement_timeout 30s`, ledger ACCESS EXCLUSIVE, `ImportIntent` SHARE ROW EXCLUSIVE (the mode the composite FK needs). DO-block gates refuse (never adopt/drop) on: ledger identity key/canonical CHECK/RLS flags, ledger `status`/`target_id`/`source_platform` column shape, `ImportIntent(id uuid, coach_id text)` + unique `(id, coach_id)` on an RLS-forced table, and any pre-existing object under the eight S8-B names or a `target_kind` column. Raw rerun → `G2-S8B provenance already present`, nothing applied. Held ledger lock → 55P03, nothing applied.
- **CHECKs.** `native_kind` closed on the §3.3 minimum set (5); `outcome` closed on §3.2 (3); A2 `("native_id" IS NULL) = ("outcome" = 'unresolved')` is exact given `outcome NOT NULL`; `unresolved ⇒ reason NOT NULL`. Ledger `target_kind` closed on the four ledger targets (child-only `workout_plan_exercise` excluded, per §3.3) and `target_kind ⇒ target_id`. Both ledger CHECKs are trivially true for every existing row (`target_kind` NULL), no rewrite; ADD COLUMN nullable without default is metadata-only.
- **Composite FK + RESTRICT.** `(import_intent_id, coach_id) → ImportIntent(id, coach_id) ON DELETE RESTRICT ON UPDATE CASCADE` = the C1 `ExtensionPairCode` pattern with RESTRICT; MATCH SIMPLE so a NULL intent (all rows until S7-L L4) is never checked. Owner-scoped: a foreign coach's intent is refused (spec case). See C-1 for the erasure seam.
- **RLS.** ENABLE + FORCE, `REVOKE ALL … FROM anon, authenticated` (S1 convention), PERMISSIVE `service_role` policy, RESTRICTIVE deny-all for `anon` and `authenticated` — byte-for-byte the ledger posture of 20261223000200. Spec proves privilege denial, then policy denial after a fixture GRANT, then re-revokes and re-compares the full posture.
- **down.sql.** Table presence tested by `to_regclass` before the provenance LOCK (fixed `G2-S8B provenance absent` on a pre-S8-B DB); exact-shape gate (4 CHECKs, FK, identity indexdef, 2 indexes, 3 policies, ledger column + 2 CHECKs); refuses with fixed identifier-free text once any provenance row **or** any typed ledger row exists; `SET LOCAL row_security = off` makes a filtered emptiness check impossible rather than silently permissive; drops exactly what up created, no CASCADE; `_prisma_migrations` untouched (spec asserts 171 stays after down). Forward-repair doctrine matches C1/S7-L1.
- **schema.prisma ↔ DDL.** `String @id @default(uuid())` → `TEXT` PK no DB default ✓; `String? @db.Uuid` ✓; `DateTime @default(now())` → `TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP` ✓; `@@unique(…, map: "ImportNativeProvenance_identity_key")` (default name would exceed 63 chars) ✓; both `@@index` default names equal the DDL names ✓; relation default FK name `ImportNativeProvenance_import_intent_id_coach_id_fkey`, `onDelete: Restrict, onUpdate: Cascade` ✓; ledger `target_kind String?` ✓. Committed schema sha `77f33bcd…` = the sha the S8-B-only generate ran against; `node_modules/.prisma/client/index.d.ts` = `b6716a86…` and contains `ImportNativeProvenance` (527 hits) and `target_kind` (30). CHECKs/RLS are outside Prisma's diff, as for R/C (CI `migration-dry-run` precedent).
- **Mixed-version.** The N/Q1+C writer and readers (`scout-reconstruct.service.ts`, `scout-roster.service.ts`, `scout-entities.service.ts`, `reconstruct/families.ts`) are byte-identical to `1b6cc661` (verified `rev-parse` equality); they use only Prisma client calls (upsert/updateMany/groupBy/findMany), no raw SQL, so the OLD client never names or selects `target_kind`; `src` diff vs OLD_HEAD = 0 files. Spec runs both images on the S8-B schema (write, replay, roster, uniform 404) and the OLD image again after down.
- **Spec genuinely proves the claims** (once B-1 is closed): expand exactness with and without OIDs, rerun refusal through both the raw file and `migrate deploy`, lock-timeout refusal, every closed-vocabulary/shape/FK/NOT NULL refusal for owner and `service_role`, D-S8-3 identity accepted once (namespace/coach/family split identities), child encodings `<len>:<parent>#id:<child>` / `#ord:<n>` with `#`/`:` inside ids, RESTRICT on the bound intent, API-role denial by privilege and by policy, rollback persistence, down refusal on both fact kinds, down/up shape identity with ledger rows retained.

## Binding, pins, identity

- `s8b-pg-proof.sh` sha256 `3fbdcdb17a3885174b450ea8e668787b6ebb1c0ca3f0c83065f5eb072f11c59a`; `BINDING.sha256` verifies 8/8. Pins re-derived read-only: `OLD_HEAD=1b6cc661` (ancestor ✓), `EXPECT_HEAD=edd6dc6b` ✓, `EXPECT_TREE=5a4db6c9` ✓, spec blob `bd94ef73` ✓, bootstrap blob `55ab8972` ✓, fixture sha `360b093b` ✓, NM client `b6716a86` ✓, NM lock `05bc530a` ✓, all listed C/N-Q1/R/S5 blob pins ✓ (0 mismatches), migrations diff vs OLD_HEAD = exactly the two S8-B files ✓, worktree porcelain 0 ✓, migration dirs 170 → 171 ✓ (`EXPECTED_MIGRATIONS/HISTORY 170`). The runner refuses on any drift (rc 70), one-shot sentinel rc 76, lane `clusters/s8-b`, port 55511, identity `s8b_super` / `g2_s8b_disposable` / markers pinned; sibling clusters hashed before/after.
- Commit: author = committer = `Bradley Gleave <bradley@bradleytgpcoaching.com>`, equal dates, no trailers, no AI/model tokens in body; hooks path `repos/growth-project-backend/.git/hooks` with lefthook `pre-commit` and `commit-msg` present. Subject/body accurately describe the delta.
- After B-1 the pins `EXPECT_HEAD`, `EXPECT_TREE`, `EXPECT_SPEC_BLOB` must move to the new head; everything else is unchanged.

## C findings (record / qualify / continue — no new work)

- **C-1 RESTRICT vs owner erasure.** `ImportIntent.coach_id → User ON DELETE CASCADE`; a bound provenance row would block that cascade. No live path hard-deletes `User` (account deletion tombstones with `deleted_at`, `account-deletion.service.ts`) and `import_intent_id` stays NULL until S7-L L4 binds intents. Record for S7-L L4 / L8 (erasure seam): decide SET NULL vs explicit erasure before intents are bound.
- **C-2 `already_present` as a persisted outcome.** §3.3 persists only `created`/`unresolved`; §3.2 and the brief row list `already_present` as an outcome, and the CHECK admits it. Harmless under the identity key; S8-C's writer contract (verify, do not insert) governs.
- **C-3 identity-key width.** `source_id` is unbounded TEXT (A2), but a btree tuple caps at ~2.7 KB of incompressible key; ingest bounds `sourceId` at 256 (`scout-ingest.dto.ts` L70), so the worst child encoding (~520 chars) is far below it. The 4000-char spec case passes only because `'p'.repeat(4000)` pglz-compresses in the index tuple — it proves TEXT width, not btree headroom. No product path reaches the limit.
- **C-4** Both ledger CHECK additions validate by scanning the ledger under the 30 s statement timeout while ACCESS EXCLUSIVE is already held; failure is atomic (R precedent did the same).
- **C-5** `ImportIntent.native_provenance` back-relation is a client-only field Prisma requires (builder-recorded grant deviation). `ON UPDATE CASCADE` on `coach_id` via the composite FK is theoretical (coach ids are never rewritten).
- **C-6** Down refuses on typed ledger rows as well as provenance rows — stricter than the grant sentence, consistent with forward repair; recorded by the builder.
- **C-7** PG15 chain dry-run deferred to the PR CI (no PG in the environment) — recorded by the builder; SQL uses nothing beyond PG15.

## GO condition

Close B-1 (spec-only `tally` fix, hooked commit, three pin lines, reseal, export) → GO for a single run of `timeout -k 30 3600 bash execution/ce3748cb/s8b/binding/s8b-pg-proof.sh` on the re-pinned head. Nothing else in the delta requires change before the run.

---

## Addendum — B-1 closure delta check (attester A, 2026-09-24 ~22:35Z, read-only, no PG)

Candidate now `8a0075de1ac6ec6cef439af77105896ad0862859` (tree `b8aab8e6…`), parent `edd6dc6b` retained (no amend, no rewrite), grandparent accepted C `1b6cc661` (ancestor ✓). Record `s8b/SOURCE_READY_B1.md` read.

- **Delta:** `git diff edd6dc6b HEAD` = exactly one added line, `intent_id: 'intent',` in `tally()` (`test/rls-g2-s8b.spec.ts` L98). No change under `prisma/`, `src/`, harness or helpers. All five `tally()` call sites (L207, L363, L375, L383, L625) run the writer with the default fixture intent `'intent'`, so the expected object now equals the real `reconstruct()` result `{intent_id, staged, reconstructed, skipped, failed}`. **B-1 closed.** Everything else in the main attestation stands unchanged (the migration, down, schema and client are byte-identical: schema `77f33bcd…`, client `b6716a86…`).
- **No new A/B.** Nothing else changed; no new surface to review.
- **Identity:** author = committer = Bradley Gleave, equal dates, no trailers, body clean; lefthook `pre-commit` and `commit-msg` present at the shared hooks path; worktree porcelain 0.
- **Pins:** runner `s8b-pg-proof.sh` sha256 `be7981ebea205195e0aeecf4438a32f390be8167a29b8462bf21c5054f8ab3b9`; `BINDING.sha256` verifies 10/10; diff vs the retained `edd6dc6b` filled form (`3fbdcdb1…`) is the header word plus exactly `EXPECT_HEAD=8a0075de…`, `EXPECT_TREE=b8aab8e6…`, `EXPECT_SPEC_BLOB=0af1709f…` — each re-derived from HEAD and matching. `EXPECT_BOOTSTRAP_BLOB=55ab8972…`, `EXPECT_FIXTURE_SHA=360b093b…` (fixture unchanged), `EXPECT_NM_CLIENT_SHA`, `EXPECT_NM_LOCK_SHA`, `OLD_HEAD=1b6cc661` unchanged and still correct. Drift refusal logic untouched.

**GO** for a single run of `timeout -k 30 3600 bash execution/ce3748cb/s8b/binding/s8b-pg-proof.sh` against head `8a0075de`. C findings C-1…C-7 remain recorded, none blocking.

---

## FINAL — single PG run reviewed (attester A, 2026-09-24 ~22:40Z, read-only)

- **Executed the attested head/runner:** log `START … head_expect=8a0075de… fixture_expect=360b093b…` (only the `be7981eb…` filled runner carries that pin; the retained `edd6dc6b` form pins `head_expect=edd6dc6b`); runner precondition and post checks require `rev-parse HEAD == EXPECT_HEAD`; sentinel `RC=0 STAGE=done END=2026-09-24T22:33:37Z HEAD=8a0075de…`; worktree HEAD still `8a0075de`, porcelain 0; `binding/s8b-pg-proof.sh` is `be7981eb…` now and `BINDING.sha256` verifies. Fixture identity in `jest.log` matches the pinned lane (port 55511, `g2_s8b_disposable`, `clusters/s8-b`, 170006, `postgres` non-super BYPASSRLS).
- **Evidence:** `jest.log` shows 14/14 passed in the attested spec (`0af1709f…`), incl. P01 exact-catalog assertions (the UNVERIFIED rendering strings held), P02, P03, P04, P05 ×2, P06, lock-timeout 5038 ms, CHECK/FK/identity/RESTRICT cases. `PRECONDITIONS_OK → PREFLIGHT_OK → IDENTITY_OK → JEST_END rc=0 → STOP_STATE_OK (postgres 0, port free) → POST_OK → END rc=0`; sibling `nq1`/`c-contract` clusters unchanged. Every acceptance item of `S8_B_DRAFT_GRANT.md` (expand, refusing down/forward repair, rerun idempotence, RLS anon+authenticated deny / service_role only, closed CHECKs on `target_kind` and `outcome`, mixed-version N/Q1+C writer unchanged) is covered by a passing case; nothing here claims deployment or customer acceptance.
- **C (recorded, non-blocking):** `RECEIPTS.sha256` for `s8b-pg-proof.log` mismatches the final file only because the runner seals before appending its own `POST_OK`/`END` lines — the hash of the first 560 lines equals the sealed `bc6d1299…`; `jest.log` seal OK. PG15 CI dry-run remains deferred to the PR. C-1…C-7 from the main attestation stand.

**FINAL ACCEPT — S8-B at `8a0075de1ac6ec6cef439af77105896ad0862859` (runner `be7981eb…`, one run, 14/14).**
