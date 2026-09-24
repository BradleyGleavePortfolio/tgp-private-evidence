# S7-L0 / S7-L1 DRAFT_READY — lifecycle decision committed; expand migration + PG harness drafted (uncommitted)

Worktree `/home/user/workspace/worktrees/s7-l`, branch `s7-l`, base 61b93cff (N/Q1 v1). One commit:
**f12661af2a4df64e449a16d5660ae6256772bf4c** (tree f0c6d2d3) — `docs(importer): decide the server-owned import run lifecycle contract`,
author + committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no trailers, genuine lefthook v2.1.9 hooks (receipt 04:
pre-commit prod-readiness-quick ✔ banned-cast-tokens ✔ prettier ✔ tsc ✔ 101 s; commit-msg no-ai-tokens ✔). Doc blob
`4fd35390`. Nothing pushed. No PG process, cluster, lock or schema.prisma/service edit touched.

## Files

| path (worktree) | lines | sha256 | state |
|---|---|---|---|
| `docs/decisions/2026-09-24-s7l-run-lifecycle.md` | 244 | `922cff8027043735d0e1566e80db9ede5d8042e9d30c1b785e9d9212fa3b2fff` | COMMITTED f12661af |
| `prisma/migrations/20270123000000_scout_run_lifecycle_expand/migration.sql` | 160 | `bd78dd06ac4b43e9dc1340308e492ede441f6af66a6fdace2c17ffc0d65023dd` | uncommitted draft |
| `prisma/migrations/20270123000000_scout_run_lifecycle_expand/down.sql` | 87 | `a14780f2bd81e461c80082db4624055bd5e727097c46845001eae6a52f671379` | uncommitted draft |
| `test/rls-g2-s7l.spec.ts` | 500 | `17d0cd4cadd86400f4238478af0dc6b448e9e121086dac555f6fc5cf24613623` | uncommitted draft |
| `test/scout/g2-s7l-db-guard.spec.ts` | 119 | `6a7ecb63f8f1ef95d2f5ff7b90a7822b89da81e0f07b92acac34e00c02a71388` | uncommitted draft (default jest: 41/41 pass, receipt 03) |
| `test/utils/g2-s7l-db.ts` | 114 | `afd6250de8c3a9541bf7341ef952120cc9ad093fb7c41d3f5895ec86a62cdd55` | uncommitted draft |
| `test/utils/g2-s7l-harness.ts` | 172 | `238e8805b748bc79031ef062ee5b1e943dd3d3a8ac704a647a3867d3f7ca9cc5` | uncommitted draft |
| `test/utils/g2-s7l-pg-harness.ts` | 254 | `bfd9bfc1227b672b9c6a8a565a0f29a085dba6e21c8d570b48eba6e5d0401204` | uncommitted draft |
| `test/utils/g2-s7l-worker.cjs` | 62 | `34548fd4baf61ea6c880a3adc5662a42639c035d0015cdab751259a28e2f2271` | uncommitted draft |
| `test/utils/g2-s7l-bootstrap.sh` (+x) | 259 | `a86bdd2da41ae44f0e8189e2a09b5cc0203d465b2ecadfec05f91cd2d0468ada` | uncommitted draft, `bash -n` ok |
| `test/utils/g2-s7l-old-root.sh` (+x) | 99 | `7eb1edeac3e7506d23bd626bc72f8cd5769ee1f0292720a03f46c55631ac1097` | uncommitted draft, `bash -n` ok |

| path (execution/ce3748cb/s7l/) | lines | sha256 |
|---|---|---|
| `binding/derive-s7l-pg-proof.py` | 221 | `185cddcce215c31d4ec4a908fd0c3e46a4d3695630e3417c444a49dfd1e97c7a` |
| `binding/s7l-fixture.sh` (+x, `bash -n` ok) | 95 | `6b3a76f499038b61fe6ee650a157f3798f1e441824a873630d1d9e929e379566` |
| `binding/s7l-pg-proof.sh` (+x, `bash -n` ok) | 233 | `d351870c34c99e2e7c4e2608bda177aa1a79f3488e9d0901f65d5a85c95d3a1c` |
| `binding/README.md` | 43 | `8b13d0034b642b00e083cfb7603dd32cabb91bbba7619ba9358074024ceff53a` |
| `binding/PINS.txt` (UNFILLED) | 7 | `00ec26a737b1ecf057e685c5c6a016477f2ce788babfdcabf6f9f12fac9d23c3` |
| `binding/BINDING.sha256` | 3 | `64614ff4e8b768f4b456db1f0dc27892b14c5d89392da13941c5b3ffa01a187a` |
| `binding/s7l-pg-proof.sh.diff-vs-c` | 229 | `85c7fa6e4e60ce9915a84472aef71eb3a1f330d9ab104dacc4dadbea453c3299` |
| `01-deps-copy.txt` (isolated node_modules copy receipt) | 14 | `9ecbba2e3bad70cd453fe3fc3ae9caac4424a9b8fc143dd82577762ab45b26aa` |
| `02-gate-tsc-draft.log` (tsc --noEmit rc=0, whole tree incl. drafts) | 4 | `c0e0f503ce34f59c07582bfc1cf06d350c4243488bde4d6db8a3e3eae4a531e6` |
| `03-gate-jest-guard.log` (default jest, guard spec 41/41) | 53 | `14d93375dfd39787c8d5f7281da35b106fdfac9149274f33f1b35b4f22c8ce89` |
| `04-commit-l0.txt` (hooked commit transcript) | 43 | `2e540550f2ef6669c323c7e24ea188262e34a8c3376004a1270930bfc907722d` |

## What was actually run (nothing else)
- `git worktree add` (s7-l at 61b93cff); `cp -a` of `worktrees/s7-nq1/node_modules` → `worktrees/s7-l/node_modules`
  (isolated copy, not symlink; hidden lock 05bc530a…, N client index.d.ts 92d42c56… — both equal to the E3 verified install
  record; receipt 01). No `npm ci`, no `prisma generate`.
- Light gates on the drafts: prettier `--check` rc=0 after `--write` (formatting only; prettier 3.9.9 from the npx cache the
  hook itself uses); eslint `--max-warnings 0` rc=0 on the 6 ts/cjs files; `tsc --noEmit` rc=0 whole tree (needs
  `NODE_OPTIONS=--max-old-space-size=4096`; the first attempt with the default heap OOM-aborted — same env exported for the
  hooked commit, hooks not bypassed); default jest on `test/scout/g2-s7l-db-guard.spec.ts` 41/41; `bash -n` on 4 shell files.
- Binding derivation: `derive-s7l-pg-proof.py` run once (asserted match counts), `bash -n` on its outputs.
- NOT run: any PostgreSQL, `test/rls-g2-s7l.spec.ts`, bootstrap/old-root helpers, migration SQL, CI dry-run.

## Frozen §6 honoured
Deadline default 300 000 ms (`SCOUT_RUN_DEADLINE_MS`), lazy evaluation, no timer; arbiter default
`partial` / `reconciliation_not_performed` until an S9 verdict; contract lineage `2.0.0-c1-s2.0`; no new flag.

## Deviations / findings (all class C — record, qualify, continue)
1. Unique index `ScoutImport_import_intent_id_key` is NON-partial (brief sketched `WHERE import_intent_id IS NOT NULL`).
   PG unique indexes ignore NULLs, so semantics are identical for legacy rows; non-partial matches Prisma `@unique` (so the
   schema hunk is `import_intent_id String? @unique @db.Uuid` with no drift) and the C1 `ExtensionPairCode_import_intent_id_key`
   precedent.
2. Sixth CHECK `ScoutImport_fence_pair_check` ((fenced_at IS NULL)=(fence_reason IS NULL)) and `deadline_at >
   accepted_start_at` inside `ScoutImport_mode_shape_check` added (invariant 4 in the doc). Shape CHECK is `NOT VALID` then
   `VALIDATE` so the table scan happens without the long exclusive hold.
3. `down.sql` refuses on ANY non-default lifecycle value (mode<>'legacy' or any non-null new column or epoch<>1), not only on
   server rows; fixed text `Import run lifecycle state exists; retain schema and use compatible forward repair`. History is
   never rewritten by the file.
4. Added entry gate `G2-S7L unrecognised legacy terminal status` (terminal_status outside success/partial/failed): the shape
   CHECK would otherwise fail on such a row with a generic 23514; the gate names the row class and applies nothing.
5. FK `(import_intent_id, coach_id) → ImportIntent(id, coach_id) ON DELETE RESTRICT ON UPDATE CASCADE`: owner erasure via the
   User→ImportIntent cascade fails closed while a server run exists. Recorded as the L8 seam in the doc (§8); the spec asserts
   RESTRICT on the intent only (User-cascade path not exercised: other FKs on User could surface first).
6. Added `test/utils/g2-s7l-worker.cjs` (inside the owned `test/utils/g2-s7l-*` glob): the tq0 worker has no ScoutService;
   needed for the mixed-version OLD/candidate `/complete` + status read (L05).
7. UNVERIFIED renderings in `g2-s7l-harness.ts` (`EXPECTED_CHECK_DEFS`, `EXPECTED_FK_DEF`, `EXPECTED_UNIQUE_INDEX_DEF`,
   column type strings): written from `pg_get_constraintdef`/`pg_get_indexdef` conventions, never compared to a live catalog.
   First PG run may need exact-string corrections (class C: proof-string, not schema).
8. Bootstrap step 7 (candidate client must carry `mode`/`import_intent_id`/`execution_epoch`) and the spec's candidate-client
   assertion pass only after the schema hunk + S7-L1-only `prisma generate` (not in scope now). The copied node_modules carries
   the N client — correct for today's tree, and the runner's `EXPECT_NM_CLIENT_SHA` is `__FILL_AFTER_GENERATE__`.
9. OLD_HEAD pinned to 61b93cff (N/Q1 v1) in runner, `g2-s7l-old-root.sh`, `g2-s7l-bootstrap.sh`, `g2-s7l-pg-harness.ts`, and
   `EXPECTED_MIGRATIONS`/`EXPECTED_HISTORY` = 169: the mechanical rebase onto the accepted C head re-pins to that head and 170,
   and adds the C file blob pins at the marked slot in the runner. Migration timestamp `20270123000000` sorts after C's
   `20270121000000`.
10. `intent()` fixture helper supersedes the coach's current ImportIntent before inserting (C1 `ImportIntent_one_current_key`
    allows one current setup per coach) — fixture shaping only.
11. `tsc --noEmit` on this tree OOMs at the default node heap (rc=134, 1m55s); with 4 GB heap rc=0 (1m08s). The hook's
    `npx tsc` ran under the same exported `NODE_OPTIONS` (101 s). Not a code issue; noting for whoever runs gates here.
12. Hooks live in the shared `repos/growth-project-backend/.git/hooks` (already genuine lefthook from N/Q1 receipt 20; worktree
    has no `core.hooksPath`); no `lefthook install` was needed or run.

## Not done (by grant)
schema.prisma hunk; S7-L2 service/routes/DTOs; contract regen; any PG run; commit of SQL/harness/binding; push.

## Next activation conditions (for the parent)
1. Accepted C head known → mechanical rebase of `s7-l` (doc commit + drafts) onto it; re-pin per finding 9.
2. schema.prisma ScoutImport hunk (10 fields + `@unique` + relation to ImportIntent with `onDelete: Restrict`,
   `onUpdate: Cascade`) → S7-L1-only `prisma generate` (receipt 03, pin `EXPECT_NM_CLIENT_SHA`) → light gates → heavy gates under
   the relayed slot → chain-harness CI dry-run PG 15.18 (deploy → down → re-apply → byte-identical `pg_dump -s`).
3. Hooked Bradley commit of SQL + harness → fill `binding/PINS.txt` and runner `EXPECT_*` → separate single-run PG grant for
   `s7l-pg-proof.sh` (port 55501, lane `clusters/s7-l`).
