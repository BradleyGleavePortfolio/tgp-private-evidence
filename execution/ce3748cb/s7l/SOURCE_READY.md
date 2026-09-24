# S7-L1 + S7-L2 — SOURCE_READY (2026-09-24, T4 builder)

Grant: Mail 3 (S7-L1 + S7-L2 build per accepted L0 doc + POST_C_SEQUENCING). Worktree `/home/user/workspace/worktrees/s7-l`,
branch `s7-l`, clean (`git status --porcelain` empty). No PG process started. No push. No edits to
`scripts/importer-contract.ts`, `docs/contracts/importer-openapi.json`, `test/contracts/**`, or any S8-A/S8-B path.

## Commits on `s7-l` (all lefthook-hooked: banned-cast-tokens, eslint, prettier, tsc, prod-readiness-quick, no-ai-tokens; author+committer Bradley Gleave <bradley@bradleytgpcoaching.com>; no trailers)

| commit | tree | parent | content | receipt |
|---|---|---|---|---|
| `e65f5c03` | `32ab866a` | `1b6cc661` (accepted C head) | L0 doc (carried through rebase, receipt 06) | 04 |
| `cb9d9805` | `18fe38c4` | e65f5c03 | L0 review closure (B1/B2/C) | 05 |
| **`0ef55965688ee0221d59ac200a393b22c1386b47`** | `ef14cf77` | cb9d9805 | **S7-L1**: migration `20270123000000_scout_run_lifecycle_expand` (migration.sql 163 / down.sql 87), `prisma/schema.prisma` hunk (ScoutImport lifecycle columns + `ScoutImportIntent` relation on ImportIntent only), PG harness/spec/guard/bootstrap/old-root/worker | 08 |
| **`7ab9cc379e6d06187bb912cfd3442f28570ae46f`** | `44384a90` | 0ef55965 | **S7-L2**: `src/scout/lifecycle/{reason-codes,arbiter,lifecycle.dto,lifecycle.service,lifecycle.controller}.ts` + specs; gate edits in `scout.service.ts`, `scout-ingest.service.ts`; `scout.dto.ts` status widening; `scout.module.ts` wiring; `analytics/events.ts` (+`SCOUT_RUN_STARTED`, `SCOUT_RUN_TERMINAL`) | 09 |
| **`12de0bbd7514f21cd6abe2a0480976592d3ab2e1`** | `28a7400b` | 7ab9cc37 | **S7-L2 follow-up** (new commit, no amend): late/duplicate `/complete` on a closed run = 200 ack no-op (doc §3 table row "any terminal + /complete"); seam spec `scout.service.lifecycle.spec.ts` | 13 |

Head for review/binding: **`12de0bbd`** (tree `28a7400b`). `1b6cc661..HEAD`: 27 files, +4243/−20.

## Files changed vs `1b6cc661` (lines, sha256[0:16])

| file | lines | sha256 |
|---|---|---|
| `docs/decisions/2026-09-24-s7l-run-lifecycle.md` | 286 | `b581a30be2882ee7` |
| `prisma/migrations/20270123000000_scout_run_lifecycle_expand/down.sql` | 87 | `a14780f2bd81e461` |
| `prisma/migrations/20270123000000_scout_run_lifecycle_expand/migration.sql` | 163 | `7cd74eab3e06b169` |
| `prisma/schema.prisma` | 7014 | `a2005c413f34e64b` |
| `src/analytics/events.ts` | 158 | `8881a50edd1c6174` |
| `src/scout/lifecycle/arbiter.spec.ts` | 92 | `39aab6af294c2b65` |
| `src/scout/lifecycle/arbiter.ts` | 48 | `81f998fb772b2874` |
| `src/scout/lifecycle/lifecycle.controller.spec.ts` | 38 | `a9f48625e0c35ceb` |
| `src/scout/lifecycle/lifecycle.controller.ts` | 92 | `494bd705c73940c5` |
| `src/scout/lifecycle/lifecycle.dto.ts` | 74 | `da7d8854cef5f465` |
| `src/scout/lifecycle/lifecycle.service.spec.ts` | 472 | `26f025a41ae327ae` |
| `src/scout/lifecycle/lifecycle.service.ts` | 466 | `a9fbfbeb8c8e5243` |
| `src/scout/lifecycle/reason-codes.ts` | 80 | `c4e219d2dd2ae431` |
| `src/scout/scout-ingest.service.ts` | 169 | `4d05b68846f82805` |
| `src/scout/scout.dto.ts` | 368 | `595a99e0717fc930` |
| `src/scout/scout.module.ts` | 59 | `3f0784b2e42561e7` |
| `src/scout/scout.service.lifecycle.spec.ts` | 268 | `3482c0dea2e94e1e` |
| `src/scout/scout.service.spec.ts` | 855 | `cc67c2182a8884eb` |
| `src/scout/scout.service.ts` | 640 | `50f2778ae3aac6b7` |
| `test/rls-g2-s7l.spec.ts` | 562 | `0119d9b99ddb322f` |
| `test/scout/g2-s7l-db-guard.spec.ts` | 119 | `6a7ecb63f8f1ef95` |
| `test/utils/g2-s7l-bootstrap.sh` | 259 | `fadabfc919fb0abc` |
| `test/utils/g2-s7l-db.ts` | 114 | `afd6250de8c3a954` |
| `test/utils/g2-s7l-harness.ts` | 172 | `8bad01ad572dbd1c` |
| `test/utils/g2-s7l-old-root.sh` | 98 | `b8707f4d4cedbe87` |
| `test/utils/g2-s7l-pg-harness.ts` | 254 | `c7222ba895e51de4` |
| `test/utils/g2-s7l-worker.cjs` | 62 | `34548fd4baf61ea6` |

## What L2 implements (doc `docs/decisions/2026-09-24-s7l-run-lifecycle.md`, blob 2a159920)

- `LifecycleService` (`lifecycle.service.ts`): `start` (guard order owned→paired→not superseded→no terminal→open=same body; P2002 race → winning row; deadline = start + `SCOUT_RUN_DEADLINE_MS` default 300 000, lazy, no timer), `cancel` (FOR NO KEY UPDATE fence + epoch bump + arbiter terminal `cancelled`; idempotent; `legacy_run`/`run_terminal`/404), `resolve` → `legacy|open|none|closed`, `withOpenRun` (one interactive tx; first statement = row-locking gate UPDATE `RETURNING execution_epoch`; miss → rollback → 409 `run_not_started`/`run_fenced`), `touch` (progress; never throws), `fenceIfExpired`/`fence` (CAS), `onTransferSettled` (arbiter → CAS terminal write), `project` (families from `count(DISTINCT (source_platform, source_id))` + ledger groupBy; native buckets null until S8-B/S9), `observeForRead`, static `serverTerminal`.
- `arbiter.ts`: pure; fence > claim-failed-with-zero-staged > verdict > default `partial/reconciliation_not_performed`; never `complete` without a verdict (full table in `arbiter.spec.ts`).
- Routes: `POST /api/scout/runs/start`, `POST /api/scout/runs/cancel` — 200, `@Roles('coach','owner')`, 30/min throttle, same dark gate/guards as `/api/scout/*`; DTOs lowercase UUIDs via `@Transform` + `@IsUUID('all')` (L0 review C note).
- Gate integration: `ScoutIngestService.ingest` and `ScoutService.complete` write inside `withOpenRun` for server runs; `recordProgress` stays sync/void and caches only after `touch` returns `open`; `getImportStatus` applies the lazy deadline then projects (`status` = server terminal when present, else legacy projection) and spreads `mode/phase/accepted_start_at/deadline_at/last_observed_at/execution_epoch/claimed_status/reason_code/families`.
- Legacy preserved: `LifecycleService` is `@Optional()` in both services (ScoutModule always wires it — asserted in `lifecycle.service.spec.ts`); a non-UUID key or an unowned UUID resolves `legacy` and every legacy path is byte-identical.
- Frozen §6 honoured: no new flag; lineage untouched; deadline default 300 000 ms lazy.

## Gates (all on the committed heads; receipts in this directory)

| gate | result | receipt |
|---|---|---|
| lefthook pre-commit ×3 (banned-cast-tokens, eslint, prettier --check, tsc heap 4096, prod-readiness-quick) + commit-msg no-ai-tokens | ✔ ×3 | 08, 09, 13 |
| `check-r75 --mode=staged` (hook: `R75 --cached`) | ✔ ×3 | 08, 09, 13 |
| `tsc --noEmit` whole tree, NODE_OPTIONS 4096 | 0 errors (hook, ~47 s each) | 08, 09, 13 |
| affected default Jest (`--findRelatedTests` on the 26 changed src/schema files) under `execution/test-validation.lock` | 10 suites / 226 tests pass at `12de0bbd` | 14 (10 = pre-follow-up) |
| `jest src/scout test/scout test/utils` under the lock | 44 suites / 880 pass, 5 skipped (pre-existing skips) | 14 (11) |
| `prisma validate` + `migrate diff --from-schema-datamodel` == migration.sql | ✔ (L1 draft phase) | 07 |
| `prisma generate` (S7-L1 schema) → `node_modules/.prisma/client/index.d.ts` `f9797c30…bfe9` | ✔ | 03 |

## Deviations / self-reported findings for the reviewer

1. **B (declared-shape assertion changed)** — `src/scout/scout.service.spec.ts` case "returns only the declared safe shape" asserted the exact 5-key set of `ScoutImportStatusResult`. The additive lifecycle fields make that assertion necessarily change; it now asserts the 14-key set and `mode:'legacy', execution_epoch:1, families:[]` for the legacy row. Every other case in that file is unchanged and passes. The acceptance line "existing scout.service.spec.ts cases pass unchanged" is therefore met for all but this one key-list assertion. Reviewer decides whether this needs a doc note.
2. **Expected, L3-owned: importer contract drift** — `test/contracts/importer-contract.spec.ts` fails 4 cases at this head (artifact byte-diff; "exactly its five fields"; "four provable states only"; subprocess regeneration) because the read DTO widened and two routes were added (receipt 12). Regenerating `docs/contracts/importer-openapi.json` and updating those frozen assertions is the separate L3 generator-owner step; not touched here.
3. `SCOUT_RUN_CANCELLED` was not added as a separate event; cancel emits through the single `SCOUT_RUN_TERMINAL` (`{intent_id, terminal_status, reason_code}`) alongside `SCOUT_RUN_STARTED`. C-class naming choice; trivially split if the analytics owner prefers.
4. Late/duplicate `/complete` initially returned 409 `run_fenced` in `7ab9cc37`; corrected to the doc's 200 ack no-op in `12de0bbd` (new commit, history preserved).
5. `EXPECTED_CHECK_DEFS` renderings in `test/utils/g2-s7l-harness.ts` remain UNVERIFIED against real PG (`pg_get_constraintdef` normalises text); may need a one-line adjustment on the first PG run — B-class for the PG proof only, not for L2 code.
6. PG-specific behaviours (gate serialization under concurrent cancel, CAS races, CHECK enforcement, lazy timeout) are unit-proven only at the decision layer; the SQL is proven only by the pending PG run.

## Binding (`binding/`)

`s7l-pg-proof.sh` pins filled to `12de0bbd`: `OLD_HEAD=1b6cc661` (accepted C head), `EXPECT_HEAD/TREE`, `EXPECT_SPEC_BLOB=af199dbf`, `EXPECT_BOOTSTRAP_BLOB=60ec9fc3`, `EXPECT_FIXTURE_SHA=6b3a76f4…`, `EXPECT_NM_CLIENT_SHA=f9797c30…`, `EXPECT_NM_LOCK_SHA=05bc530a…` (verified identical now); N/Q1 pins re-pinned to their `1b6cc661` blobs (`g2-nq1-pg-harness.ts d51267f2`, `rls-g2-nq1.spec.ts a9338260`; other five unchanged); accepted C blob block added at the marked slot (7 files + migration dir `35a0cdab`) plus C-ancestor check. `bash -n` OK; zero `__FILL` placeholders. Filled sha256 `ed85a5a4700cf3c3359ad51a806ae060ae9e54953c2930bba05b48083197fd35` (substitution-only form `d351870c…` remains what `derive-s7l-pg-proof.py` describes, as C recorded). `PINS.txt`, `README.md` status header, `BINDING.sha256` updated. Committed harness already carries `OLD_HEAD=1b6cc661` and `EXPECTED_MIGRATIONS/HISTORY=170`. If S8-B lands on `integration/importer` before the PG run, re-pin OLD_HEAD in runner + `g2-s7l-{bootstrap,old-root}.sh` + `g2-s7l-pg-harness.ts` first (POST_C_SEQUENCING).

## Not done (by grant)

- No PG run (separate single-run grant; runner ready).
- No L3 contract regeneration / frozen-spec update (generator owner).
- No push; `s7-l` is local only (`worktrees/s7-l`, shared `.git` at `repos/growth-project-backend`).
- No PG spec cases L07–L12 (S7-L2 PG cases per doc §9) — the L1 spec ships L01–L06 + the gate-serialization SQL check; L07–L12 belong to the PG-run grant scope and are not written.

## Next

1. Independent T4 review of `0ef55965..12de0bbd` (L1 SQL + L2 module), with finding 1 decided.
2. L3: regenerate the importer contract artifact + frozen spec on top of `12de0bbd`.
3. PG run grant → execute `binding/s7l-pg-proof.sh` (after OLD_HEAD check vs S8-B status).
