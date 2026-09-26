# S9-C builder summary — TGP importer backend (draft source, nothing run)

Worktree: `/home/user/workspace/worktrees/d3a9-s9c`, branch `exec-d3a9/s9c`, base `771db62aa10dd0065f30d7d8a155d89fd1cfcfc8` (S8-G landed).
All edits are UNCOMMITTED. No commits, pushes, tsc/jest/eslint/prettier/npm/npx/prisma/postgres runs. Only `bash -n`, `node --check`, `rg`, `git` (read-only), `sha256sum` used. The 11 frozen S9-B candidate files were not modified. `execution/test-validation.lock` untouched.

## 1. Files (path · sha256 · mode · new/modified)

| # | Path | sha256 | mode | state |
|---|------|--------|------|-------|
| 1 | src/scout/lifecycle/reason-codes.ts | 74f1962ae412dbf80e938b40ec8954f14954c8980cf6f8b389aca0f8b1b92d14 | 644 | modified |
| 2 | src/scout/lifecycle/lifecycle.service.ts | b744624071fe406134f11fab3d62015ed12e49bc125eb9637ada5caab096e307 | 644 | modified |
| 3 | src/scout/scout.service.ts | adff9ab7852d73a305f8f34292593443d2af4168c87920a2d8c49012cec06ac3 | 644 | modified |
| 4 | src/scout/scout.module.ts | 854e50cf68190031891a7a8139df5592dafb4d7fb4f23810c8356f10780c740c | 644 | modified |
| 5 | src/scout/scout.dto.ts | 02a52db72bf46ddd36420b08c6d5ad73c6d6c61f7d8dc4873ab027623dab756a | 644 | modified |
| 6 | src/scout/scout.service.spec.ts | 5f941f712f38bc6b2103c54f17cdbe84843781cfa4d6caebfcbbaaa8fdf9f08c | 644 | modified |
| 7 | test/contracts/importer-contract.spec.ts | 594113ec16095be9fee9829054588e04541831edef010704146dea2207fce5fe | 644 | modified |
| 8 | test/scout/lifecycle/arbiter.spec.ts | 4957155f8f7ef911437d50718e835c93d7869596fbe46f888c31f3f996ae6c02 | 644 | modified |
| 9 | test/scout/lifecycle/lifecycle.service.spec.ts | 6b21fc16cdc6f58242cd5535e757ec2a570462c61fa05903e6eeb26235eb04d7 | 644 | modified |
| 10 | test/scout/orchestration/settle-hook.spec.ts | 9c559aae6881196bb5d20aa2a49de35239def025e6c7d06fe6758a99627d6592 | 644 | modified (landed S8-G spec; see §5) |
| 11 | test/scout/reconciliation/catalogue-parity.spec.ts | 3352a3222ba9dd03dc6fad03e32498bee38e5f67277e68a93baf9e29fc959fd2 | 644 | new |
| 12 | test/rls-g2-s9c.spec.ts | 2b851e7ed0bdc4988ebd639ebbdf7aec7ab19a09d18dd990aeee833f21dc7069 | 644 | new |
| 13 | test/scout/g2-s9c-db-guard.spec.ts | 09ededf30c0b6bdef2a9138363b1dbf5640379552003ac376d8b140b69eadd75 | 644 | new |
| 14 | test/utils/g2-s9c-db.ts | a21c1e53e61e0792d54bb0f76b5885c69545929fe83f4ef5e7b9e7733522fa0e | 644 | new |
| 15 | test/utils/g2-s9c-pg-harness.ts | 702ff54de2ec5905e47cca19b4f105e52cc1a3e26b03927f117c3ca2b2cf6ff8 | 644 | new |
| 16 | test/utils/g2-s9c-harness.ts | 4c720422b37de1d4352f720fe24745fea4204f221d7dd33b08d06c22bfce07ca | 644 | new |
| 17 | test/utils/g2-s9c-worker.cjs | 4ef2e3b0b015207e9de00828cb410799ef7f87c3a96a707caf2c5ce37b58e9d6 | 644 | new |
| 18 | test/utils/g2-s9c-bootstrap.sh | 8797645f6aef1986379d7bb3ddbaf4dfec10c2ff8e00726c800928f7bdd56b90 | 755 | new |

Hashes are pre-prettier. `docs/contracts/importer-openapi.json` and the generated client are NOT hand-edited (see §3 Gen row).

### What each source edit does
- **reason-codes.ts** — `RUN_REASON_CODES` += `unresolved_identities`, `relationship_unverified`, `coverage_basis_unknown` appended after `revoked` (original six + order preserved; `unresolved_family` was already the fifth S7-L code). New closed enums `FAMILY_QUALIFIERS = ['roster_bridge_pending']`, `RELATIONSHIP_CLOSURES = ['verified','unverified','not_applicable']` + types.
- **lifecycle.service.ts** — 4th `@Optional()` ctor param `facts?: ReconciliationFactsService` (defaults to `new ReconciliationFactsService()`); `onTransferSettled` tail: lock → CAS → `collectFacts` → `reconcileRun` (facts.collect on the same tx + frozen `reconcile().verdict`) → `arbitrate({fence, reconciliation, ...facts})` → one `writeTerminal`. `static reportApplies(row)` (server + terminal + not `reconciliation_not_performed`); `readReport(coach, intent, row)` = one `RepeatableRead` `$transaction` running `reconcile(facts).report`, no write; `static projectFamilies(staged, ledger, report?)` fills the six additive keys per staged token via `projectToken` (C-10 multi-family merge) and `projectReasons`/`admitReasonCode` (C-6 qualifier-domain check → fold into `unresolved:reason_unrecognised`). Exports `S9_RUN_REASON_CODES: readonly RunReasonCode[] = S9_REASON_CODES` (compile-time subset proof), `PROJECTED_FAMILY_QUALIFIERS`, `PROJECTED_RELATIONSHIP_CLOSURES`, `ReportScopeRow`.
- **scout.service.ts** (`getImportStatus`) — `report = serverRun ? await lifecycle.readReport(coach, intent, importRow) : null`; `families: projectFamilies(grouped, ledger, report)`. Legacy rows never call `readReport`.
- **scout.module.ts** — imports `ReconciliationModule` (registers the provider).
- **scout.dto.ts** — additive `@ApiPropertyOptional` on `ScoutImportFamilyDto`: `canonical_family` (string|null), `native_present_verified` (int ≥0), `completeness_basis` (string), `relationship_closure` (enum RELATIONSHIP_CLOSURES), `reasons: ScoutImportReasonCountDto[]` (new DTO `{code, count}`), `qualifiers` (array enum FAMILY_QUALIFIERS). Required set unchanged.

## 2. Contract mapping — C-tier acceptance cases → tests

| Case (doc §3 / Addendum) | Where proven |
|---|---|
| **R09** settle hook passes the S9 verdict; fence precedence; claim failed + zero staged → failed/transfer_failed; exactly one terminal write; CAS miss no-op; S9 writes nothing | `arbiter.spec.ts` "S9-C" describe (4 it: order; fence beats every verdict incl. complete; claim-failed+zero beats complete; codes verbatim) · `lifecycle.service.spec.ts` "S9-C settle wiring (D-S9-1, R09)" (8 it: facts.collect once on the tx after lock; verdict written; fence wins; claim failed+zero → transfer_failed; only one `SET terminal_status` executeRaw; CAS miss → no collect/no write; `complete` never written without S10 basis; S9 issues no executeRaw) · `settle-hook.spec.ts` (updated: order `pass,lock,facts,terminal`; CAS miss never reaches facts; G06) · **live** `rls-g2-s9c.spec.ts` R09 describe (4 it) |
| **R10(C)** replayed report identical | `lifecycle.service.spec.ts` "recompute-on-read (D-S9-5, RC-2, C-9)" (3 it: `RepeatableRead` option, no write, report equality across reads; reportApplies matrix; null for legacy/open/`reconciliation_not_performed`) · **live** R10(C)/R15 it: second `status` and second `report` `toEqual` the first; provenance/ledger unchanged |
| **R11** no cross-tenant reads/writes | **live** R11 describe: A's verdict/report count only A's rows, B open run untouched, B's report after settle counts only B's; anon/authenticated refused; rolled-back service_role write persists nothing |
| **R13** legacy row status shape unchanged | `scout.service.spec.ts` "R13" it (readReport never called; families byte-identical to S7-L) · **live** R13 it (exactly the 8 S7-L keys; no S9 read; no read tx) |
| **R15** additive projection; 32-family/128-char-token body ≤ 64 KiB | `scout.service.spec.ts` R15 its (report composition, null-report S7-L shape, 32×full-histogram fixture `Buffer.byteLength ≤ 65536`) · `lifecycle.service.spec.ts` "additive projection (D-S9-5, C-6, C-7, C-10, R13, R15)" (7 it) · **live** R10(C)/R15 it (six additive keys, per-token equality with report, truthful counts, ≤ 64 KiB) |
| **C-6** qualifier domains | `lifecycle.service.spec.ts` additive-projection describe (`unresolved_family:<non-staged>` / bad platform / bad native name fold to `unresolved:reason_unrecognised`, counts merged, sorted) |
| **C-7** DTO enums closed & typed against S9-A literals | `importer-contract.spec.ts` new it (required set = original 8; enum for `relationship_closure` / `qualifiers.items`; `reasons.items.$ref`), enum pins (9 reason codes, 14 family props) · `catalogue-parity.spec.ts` last it (D-S9-7 order) |
| **C-9** catalogue equality (DEVIATION) | `catalogue-parity.spec.ts`: runtime `UNRESOLVED_CODE` (12) ⊂ S9-A `UNRESOLVED_CATALOGUE` (15) with identical qualifier shapes; surplus pinned to exactly `date_zone_unknown`, `no_native_destination`, `unit_unknown`. Literal "equals" cannot pass at 771db62a without editing the frozen S9-A catalogue or widening S8-C's writer contract — both outside the S9-C row. |
| **C-10** multi-family token merge | `lifecycle.service.spec.ts` additive-projection describe (canonical_family null when two holders, counts summed, `completeness_basis` common-or-`none`, closure `unverified` dominates, qualifiers union) |
| Lane identity / no migration | `g2-s9c-db-guard.spec.ts` (7 it) · live "lane identity" describe (3 it) |

### Expected it() counts per spec (verify with `rg -c '^\s*it\(' <file>`)
| Spec | before → after |
|---|---|
| test/scout/lifecycle/arbiter.spec.ts | 9 → 13 |
| test/scout/lifecycle/lifecycle.service.spec.ts | 29 → 47 |
| src/scout/scout.service.spec.ts | 67 → 71 |
| test/contracts/importer-contract.spec.ts | 56 → 57 |
| test/scout/orchestration/settle-hook.spec.ts | 10 → 10 (assertions changed) |
| test/scout/reconciliation/catalogue-parity.spec.ts | new, 5 |
| test/scout/g2-s9c-db-guard.spec.ts | new, 7 |
| test/rls-g2-s9c.spec.ts (live, jest.rls.config.js only) | new, 10 |

## 3. Gen row decision — MUST ship in this slice
`test/contracts/importer-contract.spec.ts` byte-compares `docs/contracts/importer-openapi.json` against fresh regeneration and pins enums/props; the DTO additions make the committed JSON stale, so the committed contract test fails until regenerated. Do NOT hand-edit generated bytes. Under the lock run:

```
npm run contract:importer          # = ts-node scripts/export-importer-contract.ts (regenerates docs/contracts/importer-openapi.json + client)
npx jest test/contracts/importer-contract.spec.ts
```
No `CONTRACT_VERSION` bump (S8-F precedent e1ec2fec; stays `2.0.0-c1-s2.0`); additive-only change.

## 4. Heavy commands for the parent (under the canonical lock)
```
cd /home/user/workspace/worktrees/d3a9-s9c
npx prettier --write src/scout/lifecycle/reason-codes.ts src/scout/lifecycle/lifecycle.service.ts \
  src/scout/scout.service.ts src/scout/scout.module.ts src/scout/scout.dto.ts src/scout/scout.service.spec.ts \
  test/contracts/importer-contract.spec.ts test/scout/lifecycle/arbiter.spec.ts \
  test/scout/lifecycle/lifecycle.service.spec.ts test/scout/orchestration/settle-hook.spec.ts \
  test/scout/reconciliation/catalogue-parity.spec.ts test/rls-g2-s9c.spec.ts test/scout/g2-s9c-db-guard.spec.ts \
  test/utils/g2-s9c-db.ts test/utils/g2-s9c-pg-harness.ts test/utils/g2-s9c-harness.ts
NODE_OPTIONS=--max-old-space-size=4096 npx tsc --noEmit
npx eslint --max-warnings 0 <the .ts files above>
npm run contract:importer && npx jest test/contracts/importer-contract.spec.ts
npx jest test/scout/lifecycle/arbiter.spec.ts test/scout/lifecycle/lifecycle.service.spec.ts \
  test/scout/orchestration/settle-hook.spec.ts src/scout/scout.service.spec.ts \
  test/scout/reconciliation/catalogue-parity.spec.ts test/scout/g2-s9c-db-guard.spec.ts
# S9-B frozen specs must still pass unchanged:
npx jest test/scout/reconciliation/facts.service.spec.ts test/scout/reconciliation/reconcile.spec.ts
# PG proof (lane g2_s9c, port 55646, cluster_name s9c-disposable-pg17), after commit of the attested head:
export G2_S9C_DATABASE_URL=postgresql://s9c_super@127.0.0.1:55646/g2_s9c_disposable G2_S9C_CONFIRM=g2_s9c_disposable:55646 \
  G2_S9C_PASSWORD=<fixture> G2_S9C_PSQL=<psql> G2_S9C_DATA_DIRECTORY=<dir> G2_S9C_CANDIDATE_HEAD=<40-hex committed head>
bash test/utils/g2-s9c-bootstrap.sh bootstrap
npx jest --config jest.rls.config.js test/rls-g2-s9c.spec.ts --runInBand --ci
```

## 5. Residual risks / deviations (honest list)
1. **Nothing has been type-checked or executed.** Expected verdicts in specs (e.g. MIXED fixture → `partial/unresolved_identities`, empty facts → `partial/coverage_basis_unknown`, full P01 fixture → `unresolved_identities`) were derived by reading `reconcile.ts`/`coverage.ts`, not by running them.
2. **Landed spec changed:** `test/scout/orchestration/settle-hook.spec.ts` (S8-G) asserted `reconciliation_not_performed` from the tail; that code is unreachable from the hook once S9-C wires the verdict (D-S9-1). Updated minimally: facts double injected (empty staged partition → `coverage_basis_unknown`), order pin `pass,lock,facts,terminal`, CAS-miss asserts no facts read. Similarly the landed live proofs `test/rls-g2-s7l.spec.ts` / `test/rls-g2-s8g.spec.ts` assert `reconciliation_not_performed`; they are head-bound to their own attested candidates and are not re-runnable at this head — left untouched, but they would fail if re-pointed here.
3. **C-9 literal "equals" cannot hold** (12 runtime vs 15 catalogue codes); pinned as subset + exact delta instead (see §2).
4. **Prettier reflow required**: ~90 added lines exceed printWidth 100 in the spec/harness files (code lines, not just `it()` titles). Hashes above will change after `prettier --write`. Source files (`src/**`) have no new over-width lines.
5. **Settle-tail isolation** left at S8-G's default (row lock excludes writers); only the status-path report tx is `RepeatableRead`, per C-9 wording. If the reviewer wants the tail at `RepeatableRead`, it is a one-line option on the existing `$transaction` in `onTransferSettled`.
6. **Swagger rendering assumption**: `@ApiPropertyOptional({ isArray: true, enum: FAMILY_QUALIFIERS })` assumed to render `{type:'array', items:{type:'string', enum:[…]}}`; `reasons` assumed `items.$ref → ScoutImportReasonCountDto`. The contract spec pins these; if nestjs/swagger renders differently the pin (not the DTO) needs adjusting.
7. **Live-proof heuristics**: `isS9Read` = a `SELECT … "ImportNativeProvenance"` statement (facts service reads provenance only when ≥1 mapped family is staged — true in every case that asserts it). Status read asserted to open exactly one interactive tx (`-- tx:begin` marker) — verified by reading that no other `$transaction(fn)` sits on the server status path.
8. **Worker delta**: `g2-s9c-worker.cjs` adds a `report` action (`lifecycle.readReport(coach, intent, await lifecycle.readRun(...))`) and constructs `new ReconciliationFactsService({sourceMappers, nativeRules})` from the fixture spec as the 4th lifecycle arg; otherwise a literal S8-G substitution (S8-G ports 55644 and S9-B 55645 added to the refused list; `EXPECTED_MIGRATIONS` stays 172 — verified `ls -d prisma/migrations/*/ | wc -l` = 172 and `git diff --stat 62471b11 HEAD -- prisma/` empty).
9. **Unused-import risk** for eslint `--max-warnings 0`: new spec imports were checked by eye only (`isRunReasonCode`, `S9_REASON_CODES`, etc. are all referenced); tsc/eslint will confirm.
10. Invariant "NEW SOURCE → CORE DIFF = 0" holds by construction: no platform literal in `src/**` changes; the only platform-specific value (`s9c-proof`) lives in test harness code.

---

## 6. Dev-loop fix round 1 (2026-09-25 18:58 PDT) — response to parent mail

Parent state: prettier 3.9.9 reflowed the .ts/.cjs in place (bytes kept); `docs/contracts/importer-openapi.json` regenerated by `npm run contract:importer` (+65/-1, importer-contract.spec PASSES); eslint rc0; targeted jest 544/546. Three fixes, minimal edits, no heavy tools run:

| File | new sha256 | Reason |
|---|---|---|
| test/scout/reconciliation/catalogue-parity.spec.ts | 4bc4d12d742796e0d17e91e80d8ab81b17b39c7e9c030fd6ce0066ca8a2d26d4 | TS2345 at L53: `runtimeCodes` is the narrow `UnresolvedCode[]`; widened the lookup to `(runtimeCodes as readonly string[]).includes(c)`. (Parent's `as const` on the L60 loop retained.) |
| src/scout/scout.service.spec.ts | 32a393cd5952382fe6c903c3bca300a8f8f904c9c3032489e38250a371b8b66e | R15 bound test 33≠32: **class B (fixture miscount), product correct.** The `lifecycleDouble` default `readLedger` returned `{ routines: … }`; the landed S7-L `projectFamilies` unions staged tokens with ledger keys, so a ledger-only token (`ledger_without_staged`) is its own S7-L-shaped entry — the 33rd row was `routines`, not a duplicate or an unknown→entry. Fix: `lifecycleDouble` takes an optional `ledger` arg and the 32-family case passes a ledger keyed by the same 32 tokens (`{reconstructed:3, skipped:15, failed:1}` each, matching the 19 identities). No product code changed. |
| test/scout/g2-s9c-db-guard.spec.ts | 2aaca1d1775058fbb7bf3bf0b69fd4122585bb8878406f991a28d4b2a3c24382 | The `refuses unsafe or ambiguous target` row that "did not throw" was `base.replace('55646', '55646')` — my earlier `55644→55646` regex pass had also rewritten the intended S8-G-port refusal into a no-op that fed `base` itself (a VALID target) to the guard. Restored `base.replace('55646', '55644')` (the guard in `g2-s9c-db.ts` already refuses 55644 and 55645 — unchanged, not weakened) and added the sibling's confirmation-mismatch cases `g2_s8g_disposable:55646` / `g2_s9_disposable:55646`. |

Expected it() counts unchanged (scout.service.spec 71, catalogue-parity 5, g2-s9c-db-guard 7). Parent re-run: `npx tsc --noEmit` (NODE_OPTIONS=--max-old-space-size=4096), `npx prettier --check` on the three files, `npx jest src/scout/scout.service.spec.ts test/scout/reconciliation/catalogue-parity.spec.ts test/scout/g2-s9c-db-guard.spec.ts`.

---

## 7. Review A + B fix round (2026-09-25 19:5x PDT) — clone `worktrees/d3a9-s9c-r2`, branch `exec-d3a9/s9c-r2`, base `5407efae` (S9-B landed)

Frozen draft in `worktrees/d3a9-s9c` untouched. No heavy tools, no commits; self-check by reading + `bash -n` only. Product/doc changes:

| File | state | sha256 | Reason |
|---|---|---|---|
| src/scout/lifecycle/lifecycle.service.ts | modified | 15a5c326a3eadf840330330101699d3f984508519309fc5e278bd267e95a2745 | **A-1/B-2/A-1(B):** settle tail now runs via `settleWithSnapshot` with `S9_SNAPSHOT_TX_OPTIONS = {isolationLevel: RepeatableRead, timeout: 20_000, maxWait: 5_000}` (same object on `readReport`); bounded retry (`SETTLE_ATTEMPTS = 3`) of the whole tx on Prisma `P2034` only (`isSerializationFailure`), rethrow otherwise/after exhaustion. **A-2/B-4:** `admitReasonCode(code, stagedTokens, stagedPlatforms?)` is now closed-domain membership (`CONSTANT_REASON_CODES`, catalogue shape via `isAdmissibleUnresolved`, staged-token / staged-platform membership); `NATIVE_NAME_QUALIFIER` regex removed. |
| src/scout/lifecycle/reason-domains.ts | **new** | 1a5e5e1875b14023be43a060ec36497b0362bf22fce7b672b792d0414864140a | Derived (not hand-listed) qualifier domains: families (`RECONSTRUCT_FAMILY`, `NATIVE_FAMILY`, `CHILD_ENTITY_TYPE`), models (`Prisma.ModelName.{WorkoutProgram,WorkoutPlan,WorkoutPlanExercise,Person}`), columns (`Prisma.<Model>ScalarFieldEnum`) + `NATIVE_RULE_FIELDS`; constant code set (`S9_REPORT_CODE`, bare `WRITER_CODE`s, `REJECTION_MISSING_SOURCE_ID`); `unresolvedCodeShape` / `isAdmissibleUnresolved` over `UNRESOLVED_CATALOGUE`. |
| src/scout/reconstruct/native/native-rules.ts | modified (landed S8-C file, **+17/-0**) | 1a2bc47cabbb0901975f3e911cf224820154b791dc803fc8b6516c4e3ceecbd5 | Additive `export const NATIVE_RULE_FIELDS` derived from the private `PROGRAM_FIELDS`/`WORKOUT_FIELDS`/`EXERCISE_FIELDS` tables (+ `exercises` key). Needed so the qualifier domain is derived from the grammar constant rather than copied. Flag for grant: outside the S9-C row. |
| docs/decisions/2026-09-25-s9-reconciliation.md | modified (**+87/-0**) | 59652e14254c854065b71d6be4def43a74aee8e3c7917d89c77802df1d0e4a44 | **B-3:** "Addendum B — S9-C closures (session d3a9f701)": B.1 C-9 catalogue clause amended to subset + identical shapes + pinned surplus with rationale; B.2 RR + timeout on settle path, retry rule, live-isolation note; B.3 C-6 as closed-domain membership; B.4 scope-deviation list (Gen row adopted by parent, settle-hook.spec, parity spec, g2-s9c proof files, helper additions, native-rules export, settle-tail grant, C-9 subset). |

Test/harness changes:

| File | sha256 | Reason |
|---|---|---|
| test/scout/lifecycle/lifecycle.service.spec.ts | 34b69efb4708d26ee9db2f68f1b83b072420fd8f65c0ee2d61f3437733ada93d | +5 C-9 cases (options object identity on settle; P2034 then success → 2 attempts, one landed terminal, one event; retry re-locks terminal row → no-op; bounded exhaustion rethrows P2034 after 3; P2002/plain Error not retried), readReport asserts the same options object; +1 C-6 closed-domain case (`:Jane`, `title`, unknown bare word, wrong shapes fold; native columns/rule fields/families/models admitted; `unsupported_platform` staged-platform membership); existing C-6 histogram case gains `:Jane` + `frobnicate` (fold count 5→7); +1 **R10(C)** unit case (MIXED with `created`→`already_present` flipped: identical `reconcile()` output, identical `projectFamilies`, `created_native`/`already_present_verified` null, identical terminal write). Fixture qualifier `title`→`name`. it(): 47 → **54**. |
| src/scout/scout.service.spec.ts | 07e947c8eae76b70bd638569213744c0eddbe447856e47870480108cf395a42a | Fixture qualifiers made domain-valid (`title`→`name`, `minutes`→`duration_estimate_minutes`, `kind`→`type`); it() unchanged (71). |
| test/rls-g2-s9c.spec.ts | c56b9cdabececc587a7c1d7b77c130c4c04bd4ba7e9c724a8720a81432837617 | **B-1:** `isS9Read` narrowed to `SELECT … "ImportNativeProvenance" … "source_namespace" IN (` — the facts collector's `readProvenance` shape. Verified by reading: S8-C `findProvenance` (findUnique, equality), `countUnresolvedChildren` (equality), create/update/upsert, and `scout-entities` `findMany` (`native_id IN`/`outcome IN`) never emit `"source_namespace" IN (`. it() 10. |
| test/scout/g2-s9c-db-guard.spec.ts | 6154b2d0a669ec4723fec0144e6edc652ef8fdc06b158db41e3337b25ef84276 | Refused roles add `s8g_super@`, `s9_super@` (kept `s8c_super@`…); refused DBs add `g2_s8g_disposable`, `g2_s9_disposable`; BASE_HEAD pins → `5407efae319fd913e973c87f3be0d49786c4a3e0`. it() 7. |
| test/utils/g2-s9c-db.ts | d265c9e346b9294def9415f949c41511050cf333ef8eb8f8fa0567091c1aa360 | `G2_S9C_BASE_HEAD` → 5407efae…. Guard semantics unchanged (username must be `s9c_super`; 55644/55645 refused). |
| test/utils/g2-s9c-bootstrap.sh | 7981e8e3a20151da25f768dc2b388e2e0dec0964110ccd13bbd885ce0d6b757a | `BASE_HEAD=5407efae…`; prose "base 5407efae (S9-B merge…)". `bash -n` OK. EXPECTED_MIGRATIONS stays 172 (`git log 771db62a..5407efae -- prisma` empty). |
| test/utils/g2-s9c-pg-harness.ts | ea3e77c6937ff8672041bf5ef226cd0908070bcabd4454200ea12aa503bc3b41 | Prose only: base 5407efae. |

Notes for the parent:
- **B-3 R10(C)** covered at unit tier (cheap, non-vacuous: the fixture provably flips an outcome; reconcile/projection/terminal all compared). Live spec already replays the status read/report byte-identically (R10(C)/R15 block); no live replay-of-settle case added (the live fixture drives one settle per intent).
- **Live RR assertion:** not added — PG does not echo isolation per statement and a `SHOW transaction_isolation` probe would be a new heuristic; isolation is pinned at unit tier by options-object identity on both paths (recorded in Addendum B.2). Prisma's `SET TRANSACTION ISOLATION LEVEL …` statement is already filtered by the live spec's `isNoise` (`^SET `), so the tail-segment assertions are unaffected.
- **P2034 also covers 40P01 (deadlock)** — retried with the same idempotent re-lock; documented.
- Heavy commands to re-run under the lock: `npx prettier --write` on the changed .ts (comment lines were kept ≤100 by hand; prettier may still reflow code), `NODE_OPTIONS=--max-old-space-size=4096 npx tsc --noEmit`, eslint `--max-warnings 0`, targeted jest (lifecycle.service.spec, scout.service.spec, settle-hook, arbiter, catalogue-parity, g2-s9c-db-guard, importer-contract), then the PG proof per §4 with `G2_S9C_CANDIDATE_HEAD` = the committed candidate head (harness refuses base 5407efae and a dirty tree).
- Residual risks: `Prisma.PersonScalarFieldEnum`/`Prisma.ModelName` are relied on as runtime values (confirmed present in the frozen clone's generated client `index.js`); if the generated client is regenerated with a different generator these names must still exist. `NATIVE_RULE_FIELDS` export in a landed S8-C file needs the parent's explicit grant.
