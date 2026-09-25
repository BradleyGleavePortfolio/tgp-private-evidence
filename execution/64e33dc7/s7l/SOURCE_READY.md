# S7-L replacement builder — SOURCE_READY (with one tooling blocker)

Lane: `exec64/s7l-replacement`, worktree `/home/user/workspace/worktrees/64e33dc7-s7l`
Base: `93389265a846095b846fa8f1fb0dad782fb6ee9f` (accepted S8-B head). New lineage; nothing inherited from a585bf76.
Written 2026-09-25 ~04:20Z. Slot RELEASED 04:17:21Z (S8-C may proceed).

## Binding (exact source)
- **Staged tree id**: `7086b68220d952ca1fae05949b5b2d1d67189ef5` (`git write-tree` of the fully staged index, stable across two probes).
- **HEAD**: still `93389265` — **no commit exists**. The genuine hooked commit was attempted twice and refused; the sole remaining refusal is the absent `prettier` executable (below).
- Checkpoints (private, `s7l/checkpoints/`): `draft-01-source` (sealed, 21 entries), `draft-02-full` (29 entries, MANIFEST sha256 `4c6bf84f…3aaa`, taken BEFORE the slot), `draft-03-gated` (30 entries incl. regenerated contract, MANIFEST sha256 `9758ba14…7b78`, taken after all gate fixes; byte-identical to the staged tree).
- Export (`s7l/bundle/`): `s7l-candidate-93389265-to-tree-7086b68220d9.patch` (git diff --cached --binary base→tree), `s7l-candidate-tree-7086b68220d9.tar.gz` (git archive of the exact tree), `MANIFEST-name-status.txt` (29 paths), `SHA256SUMS`, `README.md`. Verify: apply patch on 93389265, `git add -A`, `git write-tree` == tree above. A `git bundle` needs a commit and therefore does not exist yet.
- Changed paths (29): migration up/down; `prisma/schema.prisma`; `src/scout/lifecycle/{arbiter,lifecycle.dto,lifecycle.service,reason-codes,run.controller}.ts`; `src/scout/{scout.module,scout.dto,scout.service,scout.controller,scout-ingest.service}.ts`; `src/analytics/events.ts` (additive keys); `scripts/importer-contract.ts`; `docs/contracts/importer-openapi.json` (regenerated); `test/contracts/importer-contract.spec.ts`; `src/scout/scout.service.spec.ts`; `test/scout/lifecycle/*.spec.ts` (3); `test/scout/g2-s7l-db-guard.spec.ts`; `test/rls-g2-s7l.spec.ts`; `test/utils/g2-s7l-{db,harness,pg-harness}.ts`, `g2-s7l-worker.cjs`, `g2-s7l-{bootstrap,old-root}.sh`. Nothing outside the granted surface; S8-C paths untouched (`scout-reconstruct.service.ts` unchanged, byte-identity listed in old-root.sh).

## Slot record (`s7l/gates/slot-acquisition.txt`, `slot.log`, `slot-2.log`)
- Lock file `/home/user/workspace/execution/test-validation.lock` preserved (0 bytes, unchanged mtime 03:23).
- **Correction recorded honestly**: first holder pid 17284 (ACQUIRED 04:02:28Z) was started with nohup and was killed when its tool call ended; the probe right after returned exit 0 (lock NOT held). The donor `cp -a` (04:02:30–04:05:00Z) therefore ran without the slot held. Second holder `setsid -f` pid 17436 ACQUIRED 04:05:40Z, probe exit 1 (held) re-verified before prisma generate, contract regeneration, tsc, Jest and both commit attempts; RELEASED 04:17:21Z; post-release probe exit 0.

## Donor / generate (`gates/donor-copy.log`, `gates/prisma-generate.log`)
- `<wt>/node_modules` was absent; real `cp -a` of `/home/user/workspace/worktrees/64e33dc7-env/node_modules` (717M, 2m29s; only `.bin` symlinks, as in the donor).
- `node_modules/.package-lock.json` = `05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44` ✔; `package-lock.json` = `b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55` ✔ (unchanged).
- `prisma/schema.prisma` sha256 `0eb41f9a88ef3b77266e908a5ea814206c188d1bdb031bd96d746491fee84015` (differs from donor 77f33bcd) → `npx prisma generate` inside the worktree only (5.9s): `node_modules/.prisma/client/index.d.ts` = `9042e713ba5678c99959a345b7b18a60dfc186b2c7d890b8d9c3ed5c8f4edcc6`, client `schema.prisma` = `b84392033ab86776533007505c31f57930307a210844067a7407ed20d25abf3e`. Donor never touched. Node v20.20.1.

## Generator state (for the S8-C relay; `gates/generator-state.txt`, `gates/contract-regenerate.log`)
- `npm run contract:importer` (ts-node `scripts/export-importer-contract.ts`, unchanged from base) regenerated `docs/contracts/importer-openapi.json` from the real DTOs: 15 paths, 36 schemas, version **`2.0.0-c1-s2.0`**; new paths `/api/scout/runs/start`, `/api/scout/runs/cancel`; new schemas `ScoutRunStartDto/Result`, `ScoutRunCancelDto/Result`. No hand edits (`.prettierignore` already excludes the artifact).
- Hashes: `scripts/importer-contract.ts` `7e89abfeab3d8c162293d475c74d8e595105cf4f6a100fba87cf2fd8d4486cde`; `scripts/export-importer-contract.ts` `891e74b5697bd7cd5bc8514cb6ea031e84cc0bab4cbcf2e63907de632a5a56e0` (unchanged); `docs/contracts/importer-openapi.json` `36aa847771bd5a31967f5749f5ea04e8378dd68be724c7e1aff419edb7eccde6` (was `68dfd959…3eb1` at `2.0.0-c1-s1.2`); `test/contracts/importer-contract.spec.ts` `fa825328…ee4d2` before the dig fix (see below; final bytes in draft-03).
- Contract spec "cross-process determinism" test confirms a fresh subprocess regeneration is byte-identical to the artifact.

## Gate outcomes (raw logs in `s7l/gates/`)
| gate | result | notes |
|---|---|---|
| R75 `node scripts/check-r75.js --mode=staged` | first run **FAIL** (`as never` +2 in arbiter.spec/run.controller.spec), second **FAIL** (`as unknown as` +1 in lifecycle.service.spec), final **OK exit 0** | all three casts removed in-scope test files (typed superset body; `string` comparison; `instanceof` guard) — `r75.log` |
| tsc `NODE_OPTIONS=--max-old-space-size=4096 npx tsc --noEmit` | **exit 0** (46s) | `tsc.raw.log`; tsconfig covers test/ |
| eslint scoped (23 staged ts/cjs, `--max-warnings 0`) | first **exit 1** (4 unused-var warnings, `test/rls-g2-s7l.spec.ts:887`), final **exit 0** | `eslint.raw.log` |
| Jest affected (`src/scout test/scout test/contracts/importer-contract*.spec.ts test/utils`, default config) | **49 suites: 48 pass / 1 fail; 1067 pass, 1 fail, 5 skipped** (81s) | `jest-affected.raw.log` preserved. First background attempt was killed with its tool call (no output) — recorded |
| Jest targeted rerun `test/contracts/importer-contract.spec.ts` | **56/56 pass, exit 0** (39s) | `jest-contract-rerun.raw.log`. Fix: the pre-existing `dig()` path helper threw on the `$ref` member of the 409 `allOf`; made null-safe (owned spec file). Not all 49 rerun, per parent |
| genuine hooks, attempt 1 (`npm_config_offline=true`) | **refused**: prettier ENOTCACHED (no download happened) **and** hook `tsc` OOM at default heap (exit 134) | `commit-attempt-1.raw.log` |
| genuine hooks, attempt 2 (`+ NODE_OPTIONS=--max-old-space-size=4096`) | **refused by prettier only**: ✔ prod-readiness-quick ✔ banned-cast-tokens ✔ eslint ✔ tsc (42.9s) 🥊 prettier | `commit-attempt-2.raw.log`; commit-msg hook not reached |
| PG proof `test/rls-g2-s7l.spec.ts` | **not run** (no PG granted) | driver below |

Commit identity used: author+committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, message preserved verbatim in `gates/commit-message.txt`; no trailers. Hooks never bypassed (`--no-verify`/`LEFTHOOK=0` not used).

## BLOCKER — exact minimum tooling requirement
`lefthook.yml` pre-commit runs `npx prettier --check {staged_files}`, but **prettier is not in the pinned dependency tree**: `package.json` has no prettier entry; `package-lock.json` mentions it only as an optional peer (`^3.0.0`) of `@nestjs/schematics`; `node_modules/prettier` absent in donor and copy; npx cache empty. `npx` would resolve it by an **unpinned registry download**, which the grant forbids, so both attempts ran with `npm_config_offline=true` (genuine failure, nothing fetched).
- Minimum closure (parent decision; dependencies are outside my surface): make a **pinned prettier 3.x** resolvable to `npx prettier` from the pinned tree — e.g. add `prettier@3.x.y` (exact version, with lockfile entry) to the donor, or seed the npm cache with that exact tarball. Config in repo: `.prettierrc.json` (printWidth 100, singleQuote, trailingComma all), `.prettierignore` excludes the generated contract.
- Also worth noting for the hook lane: the hook's own `npx tsc --noEmit` OOMs at Node's default heap on this tree; it passes with `NODE_OPTIONS=--max-old-space-size=4096` in the environment (no hook edit).
- Until then: no head, no `git bundle`. The staged tree id + patch + archive above are the exact source binding for dual review; I will run the hooked commit the moment prettier is available (≈45s).

## A/B residuals (recorded, not fixed)
1. `src/scout/scout-ingest.controller.ts` is outside my surface: its 409 `run_not_started` / `run_fenced` (raised by `ScoutIngestService` via the gate) is undocumented in OpenAPI for `/api/scout/ingest`. Harm: contract under-documents a real response. Minimum closure: one `@ApiResponse({ status: 409 })` on that controller (owner: parent/S8 lane). `/api/scout/ingest/complete` 409 `run_not_started` IS documented (in my `scout.controller.ts`).
2. Prisma `@@unique([import_intent_id])` vs DB partial unique `WHERE import_intent_id IS NOT NULL` — semantically equal (NULLs distinct), noted for `prisma migrate diff` reviewers.
3. Legacy spec doubles amended minimally (`src/scout/scout.service.spec.ts`, contract spec `dig`).
4. Pinned `pg_get_constraintdef`/`pg_get_indexdef` renderings in `test/utils/g2-s7l-harness.ts` (`EXPECTED_CHECK_DEFS`, `EXPECTED_FK_DEF`, `EXPECTED_INDEX_DEFS`) are unverified until the first PG run; if PG17 renders differently the fix is in the harness constants, not the migration.
5. S9: every settle arbitrates to `partial/reconciliation_not_performed`; no completion path exists (by decision). No G3 route/principal; `revoked` reserved.

## Candidate-bound PG proof driver (for the parent to run when PG is granted; NOT run)
- Binding: run only from tree `7086b68220d9…` (or the head that commits it). Bootstrap: `bash test/utils/g2-s7l-bootstrap.sh` (creates fresh data/socket dirs under `/home/user/workspace/execution/64e33dc7/recovery-reset/.../s7l/pg-data`, PG dist `/home/user/workspace/execution/64e33dc7/recovery-reset/pg17/dist` 17.6, psql `/usr/bin/psql`), then `bash test/utils/g2-s7l-old-root.sh` (detached OLD checkout of 93389265, OLD deploy → 171 migrations, OLD client generated).
- Identity the spec asserts: port **55641**, database `g2_s7l_disposable`, roles `s7l_super`(login) / `postgres`(migration, non-super, bypassrls) / `service_role`,`anon`,`authenticated`; cluster_name `s7l-disposable-pg17`; database comment `s7l-g2-run-lifecycle-synthetic-disposable-fixture-safe-to-drop`; server_version_num 17xxxx (`G2_S7L_SERVER_VERSION`, default 170006 — set to the real 17.6 = 170006); data_directory matches `/execution/64e33dc7/recovery-reset/.*/s7l/pg-data$`; refuses 55501/55511/55642 and every other lane's role (guard spec).
- Env: `G2_S7L_DATABASE_URL`, `G2_S7L_CONFIRM=g2_s7l_disposable:55641`, `G2_S7L_PSQL`, `G2_S7L_OLD_ROOT`, `G2_S7L_OLD_CLIENT`, `G2_S7L_DATA_DIRECTORY`, `G2_S7L_SERVER_VERSION`, `G2_S7L_PASSWORD` (disposable fixture password only), plus role names via `g2-s7l-db.ts` constants.
- Command: `NODE_OPTIONS=--max-old-space-size=4096 npx jest --config jest.rls.config.js test/rls-g2-s7l.spec.ts --runInBand` (jest.setTimeout 240000). Expect PG17_DATABASE / PG17_BLOCKED warnings in output; EXPECTED_HISTORY 171 → 172 after L01.
- Stages: 1 OLD-shape baseline + refusing gates (decoy relation, decoy constraint, 55P03 lock, down ABSENT); 2 L01 deploy exactness/RLS byte-equal/legacy defaults, L02 rerun refusal + "No pending migrations", SQL gate serialization + FOR NO KEY UPDATE wait; 3 CHECK/FK/partial-unique matrix, L06 roles; 4 L07 Start guards + duplicate race, L08 cancel-vs-ingest and ingest-vs-progress barriers, L09 complete/late complete/not-started, L10 lazy deadline with tx-order markers (`-- tx:begin|commit|rollback` fixture markers from the worker), CAS terminal-once, L11 projections, L05/L12 OLD image writers + legacy-marker protection; 5 L03 down refusal, L04 down/up identity, second down ABSENT.
- Do not invoke S8-B or other accepted suites; harness patterns were reused as code only.

## Not done / not claimed
No push, no production, no historical evidence edits, no dependency/workflow/policy edits, no PG run, no S9 verdict, no self-acceptance. The two lefthook refusals and the unprotected donor-copy window are preserved as facts above.
