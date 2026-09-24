# S8-B DRAFT_READY — native provenance ledger expand migration + PG harness drafted (source-only, uncommitted)

Worktree `/home/user/workspace/worktrees/s8-b`, branch `s8-b`, base **29e60705d8c4e1228fd1d2f248c7e53b6b8e56dd** (accepted
N/Q1 head). Zero commits on the branch; HEAD == base. Nothing pushed, nothing staged, `prisma/schema.prisma` untouched
(`git diff --quiet HEAD -- prisma/schema.prisma` → clean). No PostgreSQL process, cluster directory (`/home/user/pg17/clusters/`
still holds only `nq1`), migration SQL or `prisma generate` touched by this draft. Contract source: S8-0 `e322602d`
`docs/decisions/2026-09-24-s8-native-contract.md` incl. A2 closure (nullable `native_id` iff `unresolved`; wide `source_id`).

## Files

| path (worktree, all `??` untracked) | lines | sha256 | state |
|---|---|---|---|
| `prisma/migrations/20270122000000_scout_native_provenance_expand/migration.sql` | 196 | `6b55af3bf9a7260aeb671b92286c98d6b8452a85b31464550fc94942f675288c` | uncommitted draft |
| `prisma/migrations/20270122000000_scout_native_provenance_expand/down.sql` | 87 | `b3779be80a685c715aa6f3150a96aee863081c786c53a1fdd7d2b8c26768b246` | uncommitted draft |
| `test/rls-g2-s8b.spec.ts` | 641 | `476514a8268369979630110811c835292a3f5df798e13b54a71ddf54eb67f481` | uncommitted draft (rls jest only; NOT run) |
| `test/scout/g2-s8b-db-guard.spec.ts` | 124 | `ec1cab8597300f90a6cd74ada3e166e6e37f6bd774ddb3bae460c3ee06060e46` | uncommitted draft (default jest: 44/44 pass, receipt 04) |
| `test/utils/g2-s8b-db.ts` | 117 | `cd199b3f6ce1fab1a72b1e69044f26f47f7a6007dcdc757a7b5199c79ec31cd8` | uncommitted draft |
| `test/utils/g2-s8b-harness.ts` | 284 | `bf7d867b4caeced8bfc9c4ce7d8c6c281fe3396a1538cb71db3f6ac0da4d4974` | uncommitted draft |
| `test/utils/g2-s8b-pg-harness.ts` | 255 | `d75fa476b8cb28a032392ef29a883209aad5c15219d1f4c9bd9b8b656a4f74b7` | uncommitted draft |
| `test/utils/g2-s8b-bootstrap.sh` (+x) | 269 | `cf9f791d7c9aea1e01bed5010c27bc6fd18bc83ae72f11d7b484edde68578749` | uncommitted draft, `bash -n` ok |
| `test/utils/g2-s8b-old-root.sh` (+x) | 102 | `3a956678fbce0a21be92db3cc656b9244d2d2c4267564935eb1d1f137e00f2fb` | uncommitted draft, `bash -n` ok |

| path (execution/ce3748cb/s8b/) | lines | sha256 |
|---|---|---|
| `binding/derive-s8b-pg-proof.py` (run once; asserted match counts) | 225 | `9d0713192569cdb2a721b21f1d55ab11ad092bd71a7727607a3df54106f9a937` |
| `binding/s8b-fixture.sh` (+x, `bash -n` ok) | 95 | `360b093b0f06360a45ad00cf6ed98d764f16d861227e827a466ba844d65b4b0b` |
| `binding/s8b-pg-proof.sh` (+x, `bash -n` ok, pins UNFILLED) | 246 | `e208f3213f59949cbf770a8b9e8bad0834e9122feb5723d66010edd14acffa37` |
| `binding/s8b-pg-proof.sh.diff-vs-s7l` (`diff -u` S7-L runner → S8-B runner) | 253 | `d13aec05c1829aad6ef8cc9c0dfeadaa5be86dfae802927985409a5be8b2f826` |
| `binding/README.md` | 46 | `0f5eabec75a35d6d787a7e57d8d3b96d7d5868cb5987f05adb915526beaab10d` |
| `binding/PINS.txt` (UNFILLED) | 7 | `dbac52cdb3b5733047605e20346ab30b0bfda2da8b97811bcf8beed3a789c448` |
| `binding/BINDING.sha256` | 6 | `9d08a2fd31821567cbc3fd897c4fb73ed7f1108f5245c23b78fadfb349e9587a` |
| `01-deps-copy.txt` (isolated node_modules copy receipt) | 12 | `6bc274f11796f59b85e663afcf43d57a28759de00697fdc7987fc16802785642` |
| `02-gate-prettier.txt` / `02-gate-eslint.log` (rc=0 both) | 2 / 1 | — / `e38193e0e1a760971c8c88916678f28e19426274bd37b741d1577cc13a17c2d9` |
| `03-gate-tsc.log` (`tsc --noEmit` whole tree incl. drafts, rc=0, 45 s, 4 GB heap) | 6 | `578f5ae979e4448024aaf7086a24ebb4182acfc503e7cfad24cbd5f80a679848` |
| `04-gate-jest-guard.log` (default jest, guard spec 44/44, rc=0) | 53 | `397cd6cd7543c583180821661b0ca31099a5009fa8a7893ab4d79dbfe361c7c1` |
| `05-gate-check-r75.log` (R75 policy tokens applied to the 5 ts files: 0 hits) | 2 | `a7bd2643eb037b437f2da497cfec7369952d94ac0c91aadab942600c8b1fe246` |

## What the migration does (contract §3.3 / A2 → SQL)
`migration.sql`: single transaction, `lock_timeout 5s` / `statement_timeout 30s`; `LOCK "ScoutReconstructionLedger" ACCESS
EXCLUSIVE`, `"ImportIntent" SHARE ROW EXCLUSIVE`; DO-block entry gates (`G2-S8B unexpected ledger identity prerequisite` /
`… ledger column prerequisite` / `… intent prerequisite` / `G2-S8B provenance already present`) so a partial or foreign state
applies nothing. Creates `ImportNativeProvenance` (`id TEXT PK`, `coach_id TEXT NN`, `import_intent_id UUID NULL`,
`source_namespace TEXT NN`, `entity_type TEXT NN`, `source_id TEXT NN`, `native_kind TEXT NN`, `native_id TEXT NULL`,
`outcome TEXT NN`, `reason TEXT NULL`, `created_at TIMESTAMP(3) NN DEFAULT now`) with closed CHECKs
`ImportNativeProvenance_native_kind_check` (person | scout_entity | workout_program | workout_plan | workout_plan_exercise),
`_outcome_check` (created | already_present | unresolved), `_native_id_shape_check` (`(native_id IS NULL) = (outcome =
'unresolved')`), `_unresolved_reason_check` (unresolved ⇒ reason NOT NULL); composite FK
`(import_intent_id, coach_id) → ImportIntent(id, coach_id) ON DELETE RESTRICT ON UPDATE CASCADE`; unique
`ImportNativeProvenance_identity_key (coach_id, source_namespace, entity_type, source_id)`; indexes
`…_coach_id_native_kind_native_id_idx`, `…_coach_id_import_intent_id_idx`; RLS ENABLE + FORCE; `REVOKE ALL … FROM anon,
authenticated`; policies `p_import_native_provenance_service_role_all` (PERMISSIVE) + `deny_all_anon_…` /
`deny_all_authenticated_…` (RESTRICTIVE). Ledger: `ADD COLUMN target_kind TEXT` (nullable) + closed CHECK
`ScoutReconstructionLedger_target_kind_check` (NULL | person | scout_entity | workout_program | workout_plan) +
`…_target_kind_shape_check` (target_kind ⇒ target_id NOT NULL).
`down.sql`: tests table presence BEFORE locking (pre-S8-B DB → fixed `G2-S8B provenance absent`), exact-shape check (4 CHECKs,
FK, identity index def, 2 idx, 3 policies, ledger column + 2 CHECKs), refuses once ANY provenance row or ANY ledger
`target_kind IS NOT NULL` exists with fixed text `Native provenance state exists; retain schema and use compatible forward
repair`; otherwise drops the two ledger CHECKs, the column and the table (no CASCADE). Never rewrites history.

## Spec coverage (`test/rls-g2-s8b.spec.ts`, 4 stages / 13 cases; designed, NOT executed)
- Stage 1: OLD N writer baseline on the pre-S8-B schema; decoy relation / decoy ledger constraint refuse up untouched;
  held ledger transaction → up hits `lock_timeout` (55P03), nothing applied.
- Stage 2: P01 `prisma migrate deploy` applies exactly S8-B (history 169 → 170; both catalogs exact; ledger RLS/rows
  untouched); P02 raw rerun refused atomically (OIDs, rows, history unchanged; deploy has nothing pending).
- Stage 3: P05 mixed-version — OLD image N writer (pre-S8-B client, byte-identical `src/scout` writer/reader) reconstructs on
  the S8-B schema, ledger rows carry `target_kind NULL`, replay converges; candidate image writer + both images' roster read
  identical, cross-tenant 404 on both; CHECK/FK refusals for every malformed provenance / typed-ledger row as owner and as
  `service_role`; D-S8-3 identity accepted once, child encodings `<len>:<parent>#id:<child>` / `#ord:<n>` (contract §3.3
  A2), typed ledger target, `ON DELETE RESTRICT` on the bound intent; P06 anon/authenticated refused by privilege AND by
  policy (after fixture GRANT), service_role rollback persists nothing.
- Stage 4: P03 down refuses with provenance rows, then with typed ledger rows (fixed text; nothing deleted; OIDs/history
  unchanged); P04 down on an empty fact set removes exactly S8-B, OLD writer continues, second down refuses ABSENT;
  re-apply restores the identical shape, raw rerun refused again.

## What was actually run (nothing else)
- `git worktree add -b s8-b … 29e60705`; `cp -a worktrees/s7-nq1/node_modules → worktrees/s8-b/node_modules` (isolated copy,
  not symlink; hidden lock `05bc530a…` and N client index.d.ts `92d42c56…` equal to the verified record; receipt 01). No
  `npm ci`, no `prisma generate`.
- Under `flock -n execution/test-validation.lock` (never busy, never deleted): prettier 3.9.9 `--write` then `--check` rc=0;
  eslint `--no-warn-ignored --max-warnings 0` rc=0 (5 ts files); `tsc --noEmit` whole tree rc=0 (45 s, 4 GB heap); default
  jest `test/scout/g2-s8b-db-guard.spec.ts` 44/44 rc=0.
- `bash -n` on 4 shell files; `derive-s8b-pg-proof.py` run once (asserted counts; re-derivable byte-identically); R75 policy
  tokens applied to the 5 ts files via node (0 hits — `scripts/check-r75.js` itself only scans the index or a commit range, and
  the index was deliberately not touched).
- NOT run: any PostgreSQL, `test/rls-g2-s8b.spec.ts`, bootstrap/old-root helpers, migration/down SQL, CI dry-run.

## Deviations / findings (all class C — record, qualify, continue)
1. Composite FK `(import_intent_id, coach_id) → ImportIntent(id, coach_id) ON DELETE RESTRICT ON UPDATE CASCADE` (S7-L1/C1
   precedent; the L8 erasure seam recurs: owner erasure via User→ImportIntent fails closed while provenance is bound).
   Spec asserts RESTRICT on the intent only.
2. `REVOKE ALL … FROM anon, authenticated` on the new table beyond the RESTRICTIVE deny policies (S1 belt-and-braces
   convention); the spec proves permission-denied first, then RLS after a fixture GRANT, then re-REVOKEs.
3. Two CHECKs beyond the contract minimum: `_unresolved_reason_check` (unresolved rows must say why) and the ledger
   `_target_kind_shape_check` (a typed target must name its target_id). Both are NULL-safe for every existing row.
4. Two indexes added for S8-F/S9 reverse lookup and per-intent counts (`coach_id, native_kind, native_id` and
   `coach_id, import_intent_id`). No format CHECK on `source_namespace` (opaque per D-S8-3).
5. `down.sql` refuses on typed ledger rows too (not only provenance rows): `target_kind` is provenance state by the contract.
   Table presence is tested before the provenance LOCK so a pre-S8-B DB gets the fixed ABSENT text, not a relation error.
6. The entry gate does not depend on C's narrow-index drop (order-independent of C's 20270121 apart from the rebase; S7-L1
   20270123 may land before or after — the spec/bootstrap only require the exact two-file diff vs OLD_HEAD).
7. No `g2-s8b-worker.cjs`: the unchanged `test/utils/g2-tq0-worker.cjs` (reconstruct / roster / entities actions) is forked
   via `G2_TQ0_WORKER`; the mixed-version basis is that the N writer never names `target_kind` (verified by reading
   `scout-reconstruct.service.ts` `writeLedger`; `g2-s8b-old-root.sh` and the runner pin the four writer/reader files
   byte-identical to OLD_HEAD).
8. UNVERIFIED renderings in `g2-s8b-harness.ts` (`EXPECTED_*_CHECK_DEFS`, `EXPECTED_FK_DEF`, `EXPECTED_PK_DEF`,
   `EXPECTED_INDEX_DEFS`, column type strings, policy `roles` as JSON arrays): written from `pg_get_constraintdef` /
   `pg_get_indexdef` conventions, never compared to a live catalog. First PG run may need exact-string corrections
   (proof-string, not schema).
9. Bootstrap step 7 (candidate client must carry `model ImportNativeProvenance` with the contract fields and ledger
   `target_kind String?`) and the spec's candidate-client assertion pass only after the schema.prisma hunk + S8-B-only
   `prisma generate` (not in scope now). The copied node_modules carries the N client; runner `EXPECT_NM_CLIENT_SHA` is
   `__FILL_AFTER_GENERATE__`.
10. OLD_HEAD = 29e60705 pinned in runner, `g2-s8b-old-root.sh`, `g2-s8b-bootstrap.sh`, `g2-s8b-pg-harness.ts`;
    `EXPECTED_MIGRATIONS`/`EXPECTED_HISTORY` = 169. The mechanical rebase onto the accepted C head re-pins to that head and
    170 and adds the C file blob pins at the marked slot in the runner. Migration timestamp `20270122000000` sorts after C's
    `20270121000000` and before S7-L1's `20270123000000`.
11. `intent()` fixture helper supersedes the coach's current ImportIntent before inserting (C1 `ImportIntent_one_current_key`)
    — fixture shaping only. `provenanceInsert` ids are sequence-generated `prov-N` (the writer-side id policy is S8-C's).
12. Guard spec refuses the S7-L identity too (port 55501, `g2_s7l_disposable`, `s7l_super`); runner hashes a retained
    stopped `clusters/s7-l` like the other lanes (ABSENT recorded as-is today).
13. First `tsc` attempt launched as a plain background job was killed with the tool shell before finishing (log held only
    `start=`); relaunched detached (`setsid nohup`) → rc=0 in 45 s. No code issue.

## Not done (by grant)
schema.prisma hunk; S8-C..E writers (`src/scout/native`); any PG run; commit of SQL/harness/binding; push; CI dry-run.

## Next activation conditions (for the parent)
1. Accepted C head known → mechanical rebase of `s8-b` (drafts only; no commits to carry) onto it; re-pin per finding 10.
2. schema.prisma hunk: `model ImportNativeProvenance` (11 fields, `@@unique([coach_id, source_namespace, entity_type,
   source_id], map: "ImportNativeProvenance_identity_key")`, the two `@@index`es, relation to ImportIntent
   `fields: [import_intent_id, coach_id], references: [id, coach_id], onDelete: Restrict, onUpdate: Cascade`, `@db.Uuid`,
   `@db.Timestamp(3)`), ledger `target_kind String?`, ImportIntent back-relation → S8-B-only `prisma generate` (receipt 04;
   pin `EXPECT_NM_CLIENT_SHA`) → light gates → heavy gates under the relayed slot → chain-harness CI dry-run PG 15.18 (deploy →
   down → re-apply → byte-identical `pg_dump -s`).
3. Hooked Bradley commit of SQL + harness → fill `binding/PINS.txt` and runner `EXPECT_*` → separate single-run PG grant for
   `s8b-pg-proof.sh` (port 55511, lane `clusters/s8-b`), own promotion stage after C per D-C2.
