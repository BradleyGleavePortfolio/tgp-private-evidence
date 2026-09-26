# S11-A2 independent T4 review — J09–J11

Parent `fa72efb2`; candidate `/home/user/workspace/worktrees/fa72-s11a2` at `03e7a2344ef95b019c751983527bbc9f78200921`, tree `738b711610a570357136ad8e8eb1be176d406c51`, parent `dda794d7e8bee0482a7ad373795fcc51dcf54bb5`. Read-only static review under `WORKER_RULES.md` and `S11A2_REVIEW_GRANT.md`. No PostgreSQL, Jest, lock, or runtime execution.

## Verdict: GO to parent-owned real-PG binding; not a claim that the live proof passed

No A/B finding in the reviewed diff. The four live cases are sufficiently discriminating to attempt the first PG run. Parent should bind the **exact** candidate head and run the four cases in band; a live failure is not waived by this review.

## Findings and reasoning

### A/B findings

None. Thus there are no A/B five-field closure records (CLASS, CONCRETE HARM, EXACT DECISION BLOCKED, MINIMUM CLOSURE, EXECUTION UNLOCKED).

### Evidence for GO

1. **J09 reaches an honest `complete` shape, if the live writes conform.** `test/fixtures/scout/s11/s11-sources.ts:154-177` removes every first-source `clients` row; `s11_second/staged-rows.json` has only coach-owned program/workout rows, with no owner field; `journey-induction.pg.spec.ts:97-105` pins the family partition and empty clients set before any case. The first manifest explicitly expects `clients,programs,workouts`; the second expects `programs,workouts`. Evidence signs even the empty family (`s11-sources.ts:180-192,220-269`), independently computes the staged identity digest (`:79-86`), and binds the parsed spec digest (`:136-150`). J09 asserts two declaration rows and order-insensitive cross-host replay (`spec:160-181`), exact staged token partition (`:183-200`), five observation units plus replay without inserts (`:202-235`), one terminal write and settled basis (`:237-261`), source-signed counts including `clients=0` and native verified identities (`:262-293`), and byte-identical cross-host status (`:295-306`). If evidence verification, native provenance, coverage, or terminal truth breaks, these assertions fail; a staged client cannot be silently misreported as complete. In core code `native-writers.ts:118-122,350-353` returns typed program/plan kinds, `reconcile.ts:135-160` classifies present-owned provenance into native bucket (j), and `lifecycle.service.ts:560-583` persists the settled basis. The known legacy-client bucket-(f) limitation remains explicitly stated in the spec header (`:17-25`), not concealed.
2. **J10 isolates C-COV from C-ID and unknown from zero.** It stages both sources but declares only the first (`spec:316-331`); an attempted second-source observation must fail `observation_not_declared` and store no second-source unit (`:333-344`; `observation.service.ts:265-303`). It requires the **only** report condition `coverage_basis_unknown` (`spec:346-362`), programs/workouts `none/null`, and first-source clients `source_signed_enumeration/0` (`:363-370`). Its identity cells are fully native and verified, with zero unresolved/rejected/failed and zero orphan ledger (`:371-395`); this prevents an unresolved-identities reason from masking the coverage failure. It asserts both hosts' partial status and the undeclared platform's token-projection counts as null (`:397-408`). Core `verify.ts:337-360` marks an undeclared staged platform's emitted families unknown, `coverage.ts:23-49` retains null for unknown, and `reconcile.ts:338-355` independently computes C-ID and C-COV. A source that incorrectly reports absence as 0, or falsely declares completeness, fails the exact cells.
3. **J11 drives both orderings at actual run-row locks.** Worker interception pauses only after the real `$queryRaw` returns (`g2-s11-worker.cjs:222-265`), not by substituting database results. `observation.service.ts:324-339` uses `FOR NO KEY UPDATE`; ingest's first gate is `lifecycle.service.ts:644-660`'s UPDATE of the same row. In J11(a), declaration is held at `locked`, then `pg.blocked` must observe ingest's PostgreSQL Lock wait before releasing (`spec:437-463`). In J11(b), ingest is held at `gated`, then the wait of declaration is observed before release (`:477-503`). `g2-s11-pg-harness.ts:208-220` polls `pg_stat_activity` by the exact worker `application_name`; the 25 ms sleep only spaces *observation polls*, not transaction ordering. `observation.service.ts:148-175` checks committed staging under the serialized run lock, making replay-versus-first-declaration behavior distinct. Both cases assert the winning ordering, declaration-row count, and a successful first batch (`spec:418-431,463-474,503-523`). The `declaredOk !== refused` line alone is tautological because `refused` is its negation, but the subsequent exact branch checks plus each case's expected outcome still enforce the substantive XOR.
4. **The harness edit is sequential and limited.** Diff from `dda794d7` contains only the 12 owned test paths (+1161/−12); no `src/` or `prisma/` path and no dirty worktree. The worker's new branch combines repository specs/rules/manifests with parsed injected packages, cross-checks the induction registry, and sends the same mapper/native/induction registries to reconstruction, facts and observation (`g2-s11-worker.cjs:294-345`); `declare` and `observe` call the real S10-B controller/service (`:426-438`). Its previous A1 `spec/rules` branch remains an `else if` (`:318-332`), and its other action cases are unchanged. Harness additions are the induction wrappers, data inputs/readers, and reset of the S10-B tables (`g2-s11-harness.ts:284-291,406-507`); the PG harness's one-line change only excludes the injected package from process logs (`g2-s11-pg-harness.ts:182-193`). The updated guard pins the exact action set and wiring (`g2-s11-db-guard.spec.ts:304-360`), checks both journey specs are inert without lane (`:381-388`), and validates the six second-source files, spec/rules/manifest/key congruence and absence of that slug from `src` (`:390-429`). Builder records the no-DB guard at **95 passed**; this reviewer did not run Jest.
5. **Data-only source boundary holds in the actual tree.** The new key, manifests, rules, spec, rows and statement template live only under `test/fixtures/scout/s11/s11_second/`; a read-only `rg` found no `s11_second` or `private_key_pkcs8_b64` in `src/` (RC 1, no matches). The spec and harness reference `SOURCES.first/second`, never hard-code the second slug; the worker receives raw fixture packages only through the explicit test input. The first source's repository-resident S10-D manifest is pre-existing, not a new production source. This is a local synthetic proof, **not** permission to expose customer-visible complete (journey decision Q-S11-4).

### C findings / live-run qualifications

- **C1 — first PG execution outstanding.** No conclusion about live settle success or the four test results follows from static review. In particular, the combined program + workout native persistence across two platforms and exact settled report cells need the parent run.
- **C2 — cold-start/observation window.** The case set invokes roughly 38 short-lived ts-node worker processes (builder estimate), and each `blocked()` poll allows 400 checks with a 25 ms delay *plus* psql-call overhead (`g2-s11-pg-harness.ts:208-220`). A slow worker may miss this observation window and fail loudly; it cannot manufacture a successful lock proof. The holder has a 60 s interactive transaction timeout (`spec:440-457,481-498`) and 90 s child kill timer (`g2-s11-pg-harness.ts:156`).
- **C3 — barrier cleanup on failure.** The J11 tests have no `finally` to release/stop held workers if an assertion or `blocked()` fails before `resume()` (`spec:437-500`). The child kill timer limits a hung process to 90 s, but the failed case may temporarily hold the shared test row. Run the spec alone as instructed; if the observation fails, inspect the worker process/log rather than inferring a core race.
- **C4 — clock assumption.** `issuedAfterStart` constructs timestamps using the Jest host clock and the run's UTC PG start, then waits past its issued time (`g2-s11-harness.ts:469-482`). This is valid for the specified same-machine disposable lane, not a general multi-machine clock proof.
- **C5 — test-only signer.** The fixture commits a private test key (`signer-test-key.json`) on purpose; it is absent from `src` and cannot verify a production source from the production loaders. Keep Q-S11-4's synthetic-only limitation attached to any use of J09.
- **C6 — descriptor remains at A1's base and 173 migrations.** The decision text says A2 moves the descriptor, but the A1 base already included the S10-B migration; `g2-s11-db-guard.spec.ts:193-239` and PG harness `:30-39` still pin `711c1f8f`/173, while the guard permits well-formed later migrations. No `prisma/` diff appears in this A2 commit. Parent owns confirming the disposable-lane bootstrap/candidate-head binding, not weakening this static gate.

## Exact changed-path inventory

All paths below are relative to `/home/user/workspace/worktrees/fa72-s11a2`; LOC is `wc -l` of HEAD and SHA-256 is of that file's bytes.

| Path | LOC | SHA-256 |
|---|---:|---|
| `test/fixtures/scout/s11/s11-sources.ts` | 269 | `c56df889ffba4221bd4b55569e39e24fe98b3c79b464fffa1df959ea5d5b12ae` |
| `test/fixtures/scout/s11/s11_second/induction-manifest.json` | 17 | `e58de930ee19d83c743213b4a311768a01777ed57f65123ca93f12fe2ece76f4` |
| `test/fixtures/scout/s11/s11_second/mapping-spec.json` | 18 | `58abf8beebde20a900aeec0b1e32a1a36cafe2c0d06f9e1f04c39872e8d20718` |
| `test/fixtures/scout/s11/s11_second/native-rules.json` | 18 | `b9077e2189cd92fcebd295701572738c622db9f320ac486f7ed51d70325b001c` |
| `test/fixtures/scout/s11/s11_second/signer-test-key.json` | 9 | `070a8b48f43dd9c91264929cc956e0449076474761fbf648f513e8a111f515eb` |
| `test/fixtures/scout/s11/s11_second/staged-rows.json` | 19 | `99f07a55887b70d70fa025a90e6624835980909d87260afd4839e78441d87f81` |
| `test/fixtures/scout/s11/s11_second/statements.json` | 13 | `a63082cd8a1f45480d85f8ad2106459e2967eb8eb7a15e2bc6c83242879edbee` |
| `test/scout/s11/journey-induction.pg.spec.ts` | 525 | `8223f00875d459a226b1120e57ba54197e37b1fc658575e264ae0522bce00922` |
| `test/utils/g2-s11-db-guard.spec.ts` | 430 | `120cbe806ce024fbec147fefbe3a20d84f54db63c0790c0960f3945b8aada134` |
| `test/utils/g2-s11-harness.ts` | 507 | `494a683a5876c8f168d680a2f627728ff943cb89e6c1630a1c8a3461d4b6b4b5` |
| `test/utils/g2-s11-pg-harness.ts` | 269 | `e7dac8abb6f5a56046ea96974b94c6ba7f6016e331e11f0f2c621acca4c69dd6` |
| `test/utils/g2-s11-worker.cjs` | 477 | `8966789265c0c209a8a23d9e6b0ec6d14bda7852d136ee53593c1f8b2336d488` |

## Commands run and RC

All reads below are read-only. `W=/home/user/workspace/worktrees/fa72-s11a2`; `E=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2`. Several independent commands were grouped in one Bash invocation; RC is the invocation RC, except where a subsidiary command is explicitly noted.

| # | Command(s), abbreviated only by W/E above | RC |
|---|---|---:|
| 1 | `sed -n '1,240p' E/WORKER_RULES.md` | 0 |
| 2 | `sed -n '1,260p' E/s11a2/S11A2_REVIEW_GRANT.md` | 0 |
| 3 | `git -C W status --short; git -C W log -1 --format='%H %T %P %s'; git -C W diff --stat dda794d7..HEAD; git -C W diff --name-status dda794d7..HEAD` | 0 |
| 4 | `sed -n '1,260p' E/s11a2/s11a2_build.md; sed -n '1,260p' E/s11a2/S11A2_BUILD_GRANT.md` | 0 |
| 5 | `rg -n 'D-S11-6|J09|J10|J11|Q-S11-4|declare|observe' W/docs/decisions/2026-09-26-s11-journey.md; sed -n '1,220p' E/s10d2/d2_diagnose_fix.md` | 0 |
| 6 | Initial relative-path `nl -ba test/scout/s11/journey-induction.pg.spec.ts ...` from workspace, not W | 0 (inner `nl` failed: path not found) |
| 7 | Initial relative-path `nl -ba test/fixtures/scout/s11/s11-sources.ts; for f in test/fixtures/scout/s11/s11_second/*.json; ...` from workspace | 2 (paths not found) |
| 8 | Initial `git diff dda794d7..HEAD -- test/utils/...` without `-C W` | 129 (not inside clone) |
| 9 | `nl -ba W/test/scout/s11/journey-induction.pg.spec.ts \| sed -n '1,280p'` | 0 |
| 10 | Same, `sed -n '281,550p'` | 0 |
| 11 | `nl -ba W/test/fixtures/scout/s11/s11-sources.ts \| sed -n '1,300p'; for f in W/test/fixtures/scout/s11/s11_second/*.json; do sed -n '1,80p' "$f"; done` | 0 |
| 12 | `git -C W diff dda794d7..HEAD -- test/utils/g2-s11-worker.cjs test/utils/g2-s11-harness.ts test/utils/g2-s11-pg-harness.ts` | 0 |
| 13 | `nl -ba W/test/utils/g2-s11-db-guard.spec.ts \| sed -n '1,460p'` | 0 |
| 14 | `nl -ba W/test/utils/g2-s11-pg-harness.ts \| sed -n '1,280p'; nl -ba W/test/utils/g2-s11-harness.ts \| sed -n '380,520p'` | 0 |
| 15 | `nl -ba W/test/utils/g2-s11-worker.cjs \| sed -n '190,480p'; nl -ba W/test/utils/g2-s11-harness.ts \| sed -n '35,185p'` | 0 |
| 16 | `rg -n 'declaration_after_ingest|observation_not_declared|declaration_missing|FOR NO KEY UPDATE|postDeclaration|postObservation|issued_at|observedUniqueFor|coverage_basis_unknown|unknown|source_signed_enumeration' W/src/scout/induction/{observation.service.ts,observation.controller.ts,verify.ts} W/src/scout/reconciliation/{reconcile.ts,coverage.ts} W/src/scout/lifecycle/lifecycle.service.ts` | 0 |
| 17 | `sed -n '275,310p' W/docs/decisions/2026-09-26-s11-journey.md; sed -n '400,418p' ...; git -C W diff --check dda794d7..HEAD; git -C W diff --name-only dda794d7..HEAD -- src prisma; rg -n 's11_second|private_key_pkcs8_b64' W/src \|\| true` | 0 (inner `rg` had no matches) |
| 18 | `nl -ba W/src/scout/induction/observation.service.ts \| sed -n '120,360p'; nl -ba W/src/scout/induction/observation.controller.ts \| sed -n '92,162p'` | 0 |
| 19 | `nl -ba W/src/scout/induction/verify.ts \| sed -n '270,390p'; nl -ba W/src/scout/reconciliation/coverage.ts \| sed -n '1,125p'; nl -ba W/src/scout/reconciliation/reconcile.ts \| sed -n '325,405p'; nl -ba W/src/scout/lifecycle/lifecycle.service.ts \| sed -n '960,1000p'` | 0 |
| 20 | `rg -n 'model ScoutRunDeclaration|model ScoutRunObservation|model ScoutRunSettledBasis|onDelete|function loadSourceMappingSpecs|function loadNativeRuleSets|function loadInductionManifests|function buildInductionRegistry' W/prisma/schema.prisma W/src/scout/{reconstruct/source-mapper-registry.ts,reconstruct/native/native-rule-registry.ts,induction/manifest-registry.ts}; sha256sum W/test/scout/s11/journey-induction.pg.spec.ts W/test/fixtures/scout/s11/s11-sources.ts W/test/utils/g2-s11-{harness.ts,pg-harness.ts,worker.cjs,db-guard.spec.ts}; wc -l [same six files]` | 0 |
| 21 | `for f in W/test/fixtures/scout/s11/s11_second/*.json W/test/fixtures/scout/s11/s11-sources.ts W/test/scout/s11/journey-induction.pg.spec.ts W/test/utils/g2-s11-{db-guard.spec.ts,harness.ts,pg-harness.ts,worker.cjs}; do sha256sum "$f"; wc -l "$f"; done; sed -n '1,110p' W/src/scout/induction/sources/s10_unseen.json; sed -n '1,80p' W/test/fixtures/scout/s10_unseen/staged-rows.json` | 0 |
| 22 | `nl -ba W/src/scout/reconstruct/native/native-writers.ts \| sed -n '105,145p;240,265p;338,360p'; nl -ba W/src/scout/reconciliation/reconcile.ts \| sed -n '112,175p'; nl -ba W/src/scout/lifecycle/lifecycle.service.ts \| sed -n '635,685p;555,585p'` | 0 |
| 23 | `git -C W diff --numstat dda794d7..HEAD; git -C W status --porcelain --untracked-files=all; git -C W diff --check dda794d7..HEAD; rg -n 's11_second|private_key_pkcs8_b64' W/src; printf 'rg_rc=%s\n' "$?"` | 0 (inner `rg_rc=1`, no matches) |

Report-only write: this file. No worktree files changed; no PG/Jest/lock action.

## Round 2 — delta review of `54be96f18c314cae35d1e5d3000af9f06d693d81`

**Verdict: GO to parent-owned binding v2, not live acceptance.** Head tree `435fec782672214c7e8e81b2eb91f8f9266331b4`; the only r2 path is `test/utils/g2-s11-harness.ts`, +5/−3 against `03e7a234`, now **509 LOC**, SHA-256 `502c97c9f54e9ed6da7d16404559bddf87c6c45faf857046d14b20b5b1ce7be3`. The other eleven r1 paths are unchanged. Round 1's statement that the added direct deletes were harmless is **withdrawn**; its GO for other unchanged bytes remains a static assessment.

1. **Exact reset equivalence.** A byte comparison of the entire `resetData()` function extracted from A1 base `dda794d7:test/utils/g2-s11-harness.ts` and r2 HEAD returned RC 0 (`cmp -s`). The r2 function at `g2-s11-harness.ts:287-294` deletes child staging/provenance/ledger/progress/completion, then `DELETE FROM "${RUN}"` (`RUN = 'ScoutImport'` at `:37`), and subsequently the native fixtures/intent; it no longer directly deletes any S10-B table. The other r2 changes are explanatory comments, not executable logic.
2. **All three child tables cascade from the run.** Migration `prisma/migrations/20270124000000_scout_run_observation_expand/migration.sql:104-107,140-146,169-171` declares composite `(coach_id,intent_id)` FKs to `ScoutImport` with `ON DELETE CASCADE` for declaration, observation and settled basis; observation also cascades from declaration. Its insert-only trigger rejects top-level DELETE/any UPDATE/TRUNCATE but permits nested FK cascades (`:174-188,219-239`). Thus the existing parent-run DELETE removes all three table rows, including those from the first failing case, without the forbidden top-level child DELETE.
3. **No alternate child mutation.** A read-only search for direct `DELETE FROM`, `UPDATE`, or `TRUNCATE` against literal table names or `DECLARATION`/`OBSERVATION`/`SETTLED_BASIS` interpolation returned no match (RC 1) across the r2 harness, worker, induction spec and fixtures, and *all* `test/scout/s11` specs plus `test/rls-g2-s11.spec.ts`. A second search for those names on lines with SQL mutations or Prisma `delete/update` methods also returned no match (RC 1). This includes the reset users `rls-g2-s11.spec.ts`, `journey-core.pg.spec.ts`, `readiness.pg.spec.ts`, `settle-redrive.pg.spec.ts`, and `journey-induction.pg.spec.ts`; no separate reset implementation appears in those files.
4. **The v1 first-case rows cannot leak between cases via this reset.** `test/rls-g2-s11.spec.ts:156-190` seeds a run (`legacyRun`), one declaration, one observation and one settled basis for that run; its global `beforeEach` and `afterAll` both invoke `resetData()` (`:61-62`). On the next reset, the parent-run DELETE cascades exactly those three child rows, and the earlier progress snapshot plus later intent delete clear the other seeded fixture rows. `readiness.pg.spec.ts:50-51,63-69` likewise resets around cases that insert declaration rows. This is a schema/static conclusion, pending the parent's live v2 run.

**A/B findings in the r2 delta:** none. **C:** the prior live v1 failed at the RLS stage (`s11a2/PROOF_V1_FINDING.md`), so J09–J11 have still not passed live under this head; the parent must rerun. **Why r1 missed it (learning):** I treated the three added direct child DELETEs as safe cleanup based on their cascade FKs, without checking the migration's insert-only row trigger; empty-table/no-DB checks could not expose that row-dependent refusal.

### Round 2 commands and RC

All run read-only; `W` and `E` retain the definitions above. No PG/Jest/lock.

| # | Command(s) | RC |
|---|---|---:|
| R2-1 | `git -C W status --short; git -C W log -2 --format='%H %T %P %s'; git -C W diff --stat 03e7a234..HEAD; git -C W diff 03e7a234..HEAD -- test/utils/g2-s11-harness.ts; git -C W diff dda794d7..HEAD -- test/utils/g2-s11-harness.ts` | 0 |
| R2-2 | `sed -n '1,260p' E/s11a2/PROOF_V1_FINDING.md; rg -n 'Round 2|resetData|54be96' E/s11a2/s11a2_build.md` | 0 |
| R2-3 | `rg -n 'ScoutRunDeclaration|ScoutRunObservation|ScoutRunSettledBasis|REFERENCES "ScoutImport"|ON DELETE CASCADE|CREATE POLICY' W/prisma/migrations/20270124000000_scout_run_observation_expand/migration.sql; rg -n 'resetData|ScoutRunDeclaration|ScoutRunObservation|ScoutRunSettledBasis' W/test/{rls-g2-s11.spec.ts,scout/s11,fixtures/scout/s11,utils/g2-s11-harness.ts,utils/g2-s11-worker.cjs}` | 0 |
| R2-4 | `cmp -s <(git -C W show dda794d7:test/utils/g2-s11-harness.ts \| sed -n '/^export function resetData() {/,/^}/p') <(sed -n '/^export function resetData() {/,/^}/p' W/test/utils/g2-s11-harness.ts)` | 0 |
| R2-5 | `sed -n '275,308p' W/test/utils/g2-s11-harness.ts; git -C W diff dda794d7..HEAD -- test/utils/g2-s11-harness.ts \| rg '^[-+] .*DELETE|^[-+]export function resetData|^[-+]  sql\('; git -C W diff --check 03e7a234..HEAD; sha256sum W/test/utils/g2-s11-harness.ts; wc -l W/test/utils/g2-s11-harness.ts` | 0 (`rg` matched explanatory comment text only) |
| R2-6 | `nl -ba W/prisma/migrations/20270124000000_scout_run_observation_expand/migration.sql \| sed -n '1,19p;88,112p;137,150p;154,189p;219,239p'; nl -ba W/test/rls-g2-s11.spec.ts \| sed -n '50,73p;135,220p'; nl -ba W/test/scout/s11/readiness.pg.spec.ts \| sed -n '43,80p;111,132p'` | 0 |
| R2-7 | `rg -n -i '(delete\s+from|update\s+|truncate\s+(table\s+)?)\s*(["\`]|\$\{)?(ScoutRunDeclaration|ScoutRunObservation|ScoutRunSettledBasis|DECLARATION|OBSERVATION|SETTLED_BASIS)' W/test/utils/g2-s11-harness.ts W/test/utils/g2-s11-worker.cjs W/test/scout/s11 W/test/rls-g2-s11.spec.ts W/test/fixtures/scout/s11` | 1 (no match) |
| R2-8 | `rg -n 'DELETE|UPDATE|TRUNCATE|deleteMany|updateMany|\.delete\(|\.update\(|\$executeRaw|\$queryRaw' [same files] \| rg 'Declaration|Observation|SettledBasis|\$\{(DECLARATION|OBSERVATION|SETTLED_BASIS)\}|scoutRun(Declaration|Observation|SettledBasis)'` | 1 (no match) |
| R2-9 | `git -C W diff --name-only 03e7a234..HEAD; git -C W status --porcelain --untracked-files=all` | 0 (only harness changed in commit, worktree clean) |
