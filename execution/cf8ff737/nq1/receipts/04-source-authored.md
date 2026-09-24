# 04 — N/Q1 source authored (frozen at write-tree 7adad696; HEAD still 7d2895e1 = R head)

Builder: `nq1_final_writer_reader_t4_build` (sole T4 builder). Requested route Claude Fable 5 / High — **no telemetry
available to me; I claim none.** Worktree `/home/user/workspace/worktrees/s7-nq1`, branch `s7-nq1`, own physical
node_modules (receipt 02), N-only `prisma generate` (receipt 03; `index.d.ts` sha `92d42c56…`).

## Scope delivered (grant NQ1_BUILD_GRANT.md; spec nq1-prep/NQ1_SLICE_BRIEF.md)
- **NQ1-a reader**: `src/scout/scout-cursor.ts` (v2 envelope `{v:2,c,i,f,o:'source_id:asc,source_platform:asc',s,p}`,
  `SCOUT_CURSOR_MAX_LENGTH=8192`, `encode/decode/resolveScoutCursor/scoutCursorWhere/scoutCursorOrder`); roster and
  entities services/DTOs/controllers page the ledger by the composite identity `(source_id, source_platform)`.
  Legacy (v1) token: one resolve query in scope (`findMany` scope+source_id, `select source_platform`, `take 2`);
  exactly one canonical row → same page as v2; zero or ≥2 rows → **existing 400 `'malformed cursor'`** (P1, no new
  message; restart from page 1 documented in the contract). Cursor from a **Q0/R response is always 400** (P2, no
  fallback, no runtime switch).
- **NQ1-b final writer**: `prisma/schema.prisma` ledger `source_platform String` (required; NO migration — the column,
  NOT NULL and both identity keys already exist from E/B/R). `scout-reconstruct.service.ts` `writeLedger` upserts on
  the five-field selector `coach_id_intent_id_entity_type_source_platform_source_id` with `update:{}`; precedence via
  `updateMany`; a second `P2002` under contention → `ProvenanceConflict` 409 `'reconstruction provenance conflict'`;
  staging page `orderBy [source_id, source_platform]`.
- **Contract**: `scripts/importer-contract.ts` version label bumped once → `2.0.0-c1-s1.2` (P3; pair-surface section
  unchanged); `docs/contracts/importer-openapi.json` regenerated (pre-copy `/tmp/nq1-contract-before.json`).
- **Unit specs updated**: contract pin, `scout-cursor.spec.ts`, roster/entities service specs, reconstruct
  service/families/conformance-alpha.
- **NQ1-c PG proof (test-only)**: `test/utils/g2-nq1-{db,pg-harness,harness}.ts`, `test/utils/g2-nq1-bootstrap.sh`,
  `test/utils/g2-nq1-old-root.sh`, `test/scout/g2-nq1-db-guard.spec.ts` (DB-free, default Jest),
  `test/rls-g2-nq1.spec.ts` (cases N01–N06, Q01–Q07; `jest.rls.config.js` only, never default Jest).
- **Binding** (`execution/cf8ff737/nq1/binding/`): `nq1-pg-proof.sh`, `nq1-fixture.sh`, `derive-nq1-pg-proof.py`
  (reproduces both byte-identically), `README.md`, `PINS.txt` (UNFILLED), `BINDING.sha256`, diff-vs-R.

## Substitution map (R → N/Q1), applied to harness/guard/bootstrap/fixture/runner
| R | N/Q1 |
|---|---|
| `g2-r-ready-*` | `g2-nq1-*` |
| `G2_R_*` env | `G2_NQ1_*` env |
| `R_RUNNER_PID` / `R_STOP_TIMEOUT` / `R_FIXTURE_*` | `NQ1_*` |
| port 55471, `r_super`/`r_local_synthetic` | port 55481, `nq1_super`/`nq1_local_synthetic` |
| `g2_r_ready_disposable` | `g2_nq1_disposable` (sixth disposable identity) |
| `r-disposable-pg17` / `r-g2-ready-synthetic-disposable-fixture-safe-to-drop` | `nq1-disposable-pg17` / `nq1-g2-synthetic-disposable-fixture-safe-to-drop` |
| `clusters/r-ready`, `run/r-ready` | `clusters/nq1`, `run/nq1` (R cluster retained + hashed, never started) |
| worker prefix `g2r_` | `g2n_` |
| REFUSED_PORTS + `'55461'` | + `'55471'`; guard refuses B and R db names/roles too |
| `OLD_HEAD=925780e0` (O) | `OLD_HEAD=7d2895e1` (T = accepted R head) |
| `EXPECTED_MIGRATIONS=168` via O(164)+by-file | `169` (164 + S1, C1, E, B, R) via T-root `migrate deploy` |
| `EXPECT_NM_CLIENT_SHA=7c367454…` | `92d42c56…` |

## T-root design (deviation from "by file"; C qualification)
R's old side was O (pre-E writer), created by the unchanged S5 helper hard-pinned to 925780e0 (164 migrations, ledger
without `source_platform`). N/Q1's old side is **T = the R head 7d2895e1**: its writer, its Q0 readers, its
`String?` client. The S5 helper cannot express that, so `test/utils/g2-nq1-old-root.sh` is derived from it by
substitution with an inverted identity gate (MUST contain E and R, count 169, candidate `prisma/migrations` byte-identical
to 7d2895e1, T ledger model carries `source_platform String?`). Offline dry-run against a temporary `--shared` clone at
`/tmp/nq1-oldroot-check`: `G2_NQ1_OLD_ROOT_OK head=7d2895e1 detached=yes migrations=169`. Bootstrap step 5 applies the
whole accepted history through the T root's own `prisma migrate deploy` (169) instead of file-by-file; N01 then asserts
the candidate's deploy reports "No pending migrations" and catalog/wide/narrow/fence are unchanged. Consequence: no
"by-file" migration replay exists in this proof (it would be a no-op — N/Q1 ships no migration). Class **C**: recorded,
qualified, continue.

## Other C qualifications
- `tsc --noEmit` OOMs (rc 134) with the default Node heap at baseline HEAD too; all tsc runs use
  `NODE_OPTIONS=--max-old-space-size=4096`. Not a slice regression.
- N05 (R down): the N writer under a nulled provenance row may surface 409 or 500 depending on whether the unique
  violation or the NOT-NULL violation wins; the spec accepts `[409, 500]` and logs `PG17_N05_WRITER`. T reclaims after
  the row is deleted and R is re-applied; shape restored; deploy nothing pending.
- Old-root clone alternates point at the shared object store (`worktrees/s7-b-drain/.git/objects`, the repository's
  common dir); read-only.

## Light gates (frozen source; receipts 07–10)
tsc rc=0 (44 s) · eslint `--max-warnings 0` rc=0 (22 ts files) · prettier `--check` rc=0 · check-r75 `--mode=staged`
rc=0 ("no positive token change") · `bash -n` rc=0 (bootstrap, old-root). Fixes made during gating: removed a wrong
`ledgerCount as ledgerRows` import from the pg-harness (the counter lives in `g2-nq1-harness.ts`) and an unused
`allLedger` import; both in `test/rls-g2-nq1.spec.ts` only.

## Heavy gates
Not yet run — require the relayed slot `/home/user/workspace/execution/test-validation.lock` (receipt 06/11 when done).
No PostgreSQL started; `pgrep -cx postgres` = 0 throughout.
