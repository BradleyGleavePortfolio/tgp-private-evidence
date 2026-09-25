# S7-L independent review B — V2 changed-question re-attestation (T4, nonbuilder)

Reviewer: independent reviewer B. Written 2026-09-25 ~05:10Z. Scope strictly per `execution/64e33dc7/S7L_MINIMUM_CORRECTION_GRANT.md`: F1/F2 closure, new head/parent/tree lineage, applicable gates, and the changed filled binding v2. The unchanged source audit is NOT repeated; `REVIEW_B.md` (original, 839b54c5) is immutable and remains the record for everything else. REVIEW_A / REVIEW_A_V2 were not read. Read-only inspection only; no product/Git/runtime writes, tests, installs or lock actions; only this file was created.

## 1. Lineage and identity (independently re-derived, read-only git)

| item | value |
|---|---|
| HEAD (v2 candidate) | `54970cd937afc8dea689b33243961abfef8b9dd6` |
| tree | `513c71d7c1390787e1521ccbfa46b30bb52b5462` |
| exact parent (`HEAD^`) | `839b54c53ccb252f95b4ec63df0b08595bbe7698` — preserved v1 candidate, tree still `f02205c6…` |
| grandparent (`HEAD^^`) / accepted base | `93389265a846095b846fa8f1fb0dad782fb6ee9f`; `merge-base --is-ancestor` true |
| commit | ordinary (not amend/replace), author+committer Bradley Gleave <bradley@bradleytgpcoaching.com>, `interpret-trailers --only-trailers` empty, subject `scout: S7-L close Review B F1/F2 (fresh-run classification, L06 role entry)` |
| worktree | `/home/user/workspace/worktrees/64e33dc7-s7l`, `status --porcelain --untracked-files=all` empty |
| delta vs 839b54c5 | exactly 3 files, +30/−5: `src/scout/lifecycle/lifecycle.service.ts` (blob `5949a293…`), `test/rls-g2-s7l.spec.ts` (`052fa35d…`), `test/scout/lifecycle/lifecycle.service.spec.ts` (`52d4f144…`) — the exact granted surface, nothing else |
| unchanged proof-object blobs (re-derived) | bootstrap `ebef51fc…`, old-root `cb1137fe…`, db `384e1b74…`, pg-harness `d8b71d68…`, harness `f0860a8d…`, worker `a8fed545…`, guard spec `27fcba5f…`, migration tree `4ce57646…`, schema `2e328bbc…` — identical to v1 |

Original v1 binding directory verified untouched (driver `3e97da2e…`, fixture `dc77a7c9…`, PINS `c41a53a7…`, README `22fe2dfa…`, freeze `c891972b…`).

## 2. F1 closure (class A) — `classifyClosed` future-deadline guard

Evidence: `src/scout/lifecycle/lifecycle.service.ts` diff 839b54c5→HEAD. Inside the `terminal_status === null && fenced_at === null` branch, before `fence(..., 'timed_out')`, the new lines read:
`if (row.deadline_at !== null && row.deadline_at.getTime() > Date.now()) { return { kind: 'not_started' }; }`
Comment extended to state the rationale (row committed by a Start after the gate; answer `run_not_started` as the failed gate did; no write on that path). The expired-row lazy `timed_out` path, the fence CAS, and every other branch are byte-unchanged (diff is +7 lines, −1 comment line).

Assessment: this is exactly the minimum closure I specified in REVIEW_B.md F1 and the grant's wording ("distinguish an open, not-yet-expired row before calling the timeout fence; return `not_started` for that race without mutation"). `readRun` selects `deadline_at` (Date | null); a null deadline (impossible for `mode='server'` by the shape CHECK) falls through to the previous behaviour — no widening. The caller maps `not_started` → 409 `run_not_started` (unchanged `closedConflict`), consistent with the gate's own zero-row answer. No write is issued before the return. Concrete harm (fresh run permanently `timed_out`, unique intent burned) is removed.

Regression case: `test/scout/lifecycle/lifecycle.service.spec.ts` adds exactly one `it(...)` after the existing expired-row case: mocks `openRun({ deadline_at: now+60 s })`, asserts `classifyClosed` → `{kind:'not_started'}`, `closedConflict(...)` body code `run_not_started`, and that `$transaction`, `$queryRaw`, `$executeRaw` and analytics `capture` were never called. The existing "past its deadline → fenced timed_out lazily" case (`deadline_at: now−5 ms`, `executeRaw → 1`) is preserved verbatim; no case was deleted or weakened (diff is purely +16 lines). Receipt `correction/jest-lifecycle-unit.raw.log`: 29/29 passed, including the new case (`slot-4.log` 04:56:59Z).

Verdict F1: CLOSED. A-block on the lifecycle bytes lifted.

## 3. F2 closure (class B) — L06 owner-session `SET ROLE`

Evidence: `test/rls-g2-s7l.spec.ts` diff, L06 (L524-545 at HEAD). For `role ∈ {'anon','authenticated'}` the four statements now run from the owner session via `sql(...)`/`refused(...)` with `SET ROLE ${role};` prefixed inside the statement text:
- `expect(sql(\`SET ROLE ${role}; SELECT count(*) FROM "${RUN}"\`)).toBe('0')`
- `refused(\`SET ROLE ${role}; ${serverRunInsert(COACH, intentId)}\`, 'row-level security')`
- `sql(\`SET ROLE ${role}; UPDATE "${RUN}" SET phase='reconciling' WHERE mode='server'\`)`
- `sql(\`SET ROLE ${role}; DELETE FROM "${RUN}"\`)`
followed by the unchanged `runCount()`/`phase='reconciling'` assertions and the unchanged `sqlAs('service_role', BEGIN … ROLLBACK)` case with its two assertions. A three-line comment was added. No other stanza changed.

Assessment: matches the accepted S8-B P06 pattern (`test/rls-g2-s8b.spec.ts` L549-556). `sql()` connects as `postgres` (LOGIN, bootstrap L105), which holds `GRANT anon, authenticated, service_role TO postgres WITH ADMIN OPTION` (L107), so `SET ROLE` succeeds; after `SET ROLE`, row security is evaluated for the current role (`anon`/`authenticated`, not BYPASSRLS), so the RLS decision — not a connection refusal — is exercised. Table privileges for these roles come from `ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role` (bootstrap L137), which is the same assumption the original L06 relied on and is unchanged. psql `-qAt` prints only the SELECT result, so `toBe('0')` is well-formed. `sqlAs` remains used elsewhere (6 call sites), so no dead import; eslint passed. The deterministic `FATAL: role "anon" is not permitted to log in` failure is gone; all original RLS/rollback assertions are retained.

Verdict F2: CLOSED for the proof as now bound.

## 4. Applicable gates (receipts read; not rerun)

`correction/slot-4.log` (slot pid 10350, in-process flock fd 9, 04:56:44–04:57:54Z, lock file preserved): prettier 3.9.9 `--check` on the 3 files rc 0 (no rewrite), eslint 3 files rc 0, R75 staged rc 0, changed unit spec 29/29, `STAGED_TREE=513c71d7…` equals the committed tree. `correction/commit-attempt-1.raw.log`: genuine lefthook pre-commit prod-readiness-quick / banned-cast-tokens / prettier / eslint / tsc (46.8 s, heap 4096) and commit-msg no-ai-tokens all pass; commit `54970cd9`, 3 files +30/−5. Bundles `bundle/v2/` thin + full-history verified ("records a complete history"); `HEAD-54970cd937af.txt` matches my derivation. Per grant, not run and not claimed: the 48 unaffected suites, contract regeneration, any PG. The source change in `lifecycle.service.ts` touches no OpenAPI/contract surface, so no contract regeneration was required.

## 5. Changed filled binding v2 (`s7l/binding/v2/`, every file read completely; hashes recomputed by me)

| file | sha256 |
|---|---|
| `s7l-pg-proof.sh` (215 lines) | `0287a941655b0ff9ec19a306af943fd93c357c00b6187f6ad31dfc90c1de2705` |
| `s7l-fixture.sh` | `dc77a7c9b52a439914fe0fdb0903bd6a55b1f47a692a5cda0a22c3a6522b3dd2` — byte-identical to v1 (`cmp`) |
| `freeze-v2.sh` | `9662dfcceba1dbcdaab855c482b610e9ead4806f3a87a7f918955905961d35bb` |
| `PINS.txt` | `7adcc31f026d2e463c62f530c9b62890c029e4d798134328dd1163fb94730837` |
| `README.md` | `518d6defea8a980270b09cfbde5c6113be39c7e0f0ff0ea65f65a6a8fd10f894` |
| `DELTA-v1-to-v2.md` | `bc96f3795da6d320a894af64149f61e994f19d225e0af08a6837593aa85177ae` |
| `BINDING.sha256` | `01985b8561fda734e8f4d9821dd9e2e231fd819d2ba63bae5f28735575531be2`; header "binding v2, frozen 2026-09-25T04:59:28Z against head 54970cd9… (source-only; NOT RUN; no PG granted)"; lists exactly the six files above with matching hashes |
| `driver-v1-to-v2.diff` | `6b3ca350…`; I regenerated `diff binding/s7l-pg-proof.sh binding/v2/s7l-pg-proof.sh` and it is byte-identical to this file |

Driver v1→v2 delta (verified by my own diff; nothing else changed in 215 lines): (1) header comment; (2) `D=…/binding` → `…/binding/v2` (sentinel/run receipts under `binding/v2/run`, currently absent) and usage path; (3) pins: `EXPECT_PARENT=839b54c5…` added, `EXPECT_HEAD` → `54970cd9…`, `EXPECT_TREE` → `513c71d7…`, `EXPECT_SPEC_BLOB` → `052fa35d…`; `EXPECT_FIXTURE_SHA` re-filled with the identical `dc77a7c9…`; all other proof-object and tool pins identical to v1; (4) placeholder refusal covers head/tree/spec-blob too, and `EXPECT_HEAD` must differ from both base and v1 parent; (5) lineage: `HEAD^ == EXPECT_PARENT` (replacing v1's `HEAD^ == BASE_HEAD`), `EXPECT_PARENT^ == BASE_HEAD`, `EXPECT_PARENT^{tree} == f02205c6…`, base-ancestor check retained, and `git diff --name-only EXPECT_PARENT HEAD` must equal exactly the three granted paths. Lock handling, fixture calls, bootstrap, identity checks, the single jest invocation (`./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s7l.spec.ts --runInBand --ci`), stop/post logic, bounds and exit codes are unchanged from the v1 driver I attested in REVIEW_B.md. No placeholders remain (`grep __FILL` empty).

Pins independently re-derived and equal: EXPECT_HEAD/TREE/PARENT/BASE_TREE, spec blob `052fa35d…`, the nine unchanged object pins, and the ten tool sha256s (unchanged from v1: pg17/dist postgres/initdb/pg_ctl, psql wrapper `a200e38c…`, node `a03953a7…`, schema, package-lock, jest.rls.config.js, node_modules lockfile, generated client).

`freeze-v2.sh` vs `freeze.sh`: adds refusals for HEAD == v1, HEAD^ != v1, changed v1 tree, non-3-path delta, non-identical fixture, and altered v1 `BINDING.sha256 -c`; fills the three `__FILL_AFTER_FOLLOWUP_COMMIT__` pins from the committed head; otherwise identical. Read-only, report-never-edit preserved.

C (record only): the v2 freeze ran twice — the first pass (04:58:26Z) was taken before PINS/README/DELTA were finalised and is retained as `BINDING.sha256.first-pass-04-58-26Z`; the driver/fixture/freeze-v2 hashes are identical between passes (verified by diff), only the three document hashes differ. Acceptable and transparent.

## 6. Verdict for the one new PG proof

**GO** for exactly one execution of `binding/v2/s7l-pg-proof.sh` (outer `timeout -k 30 3900`) against head `54970cd937afc8dea689b33243961abfef8b9dd6` / tree `513c71d7c1390787e1521ccbfa46b30bb52b5462`, bound by `binding/v2/BINDING.sha256` (`01985b85…`), when the parent issues the separate single-PG grant and the canonical lock is free (the driver refuses a live holder with rc 75; S8-C held it at the time of my original review).

Basis: F1 (A) closed at source with the specified minimum guard and one regression case; F2 (B) closed with the S8-B owner-session pattern preserving every assertion; the follow-up is an ordinary Bradley commit on the preserved v1 candidate with exactly the three granted paths changed; scoped gates and genuine hooks pass; the v2 binding is the v1 driver I already attested plus only the mechanical versioned paths and lineage pins, all of which I re-derived. I found no new blocking defect in the changed surface.

## 7. Candid unverified runtime limitations (unchanged in kind from REVIEW_B.md §5)

- Nothing has run: no PG, no fixture init, no bootstrap, no jest on the RLS spec. Pinned catalog renderings (`g2-s7l-harness.ts` L76-89), the 55P03 lock-timeout stanza, L05/L12 crossed-write behaviour, worker barrier timing and `pg_stat_activity` polling remain unverified until the first run and may surface B-class proof adjustments source reading cannot exclude.
- L06 now depends on the fixture's default-privilege grant to `anon`/`authenticated` on tables owned by `postgres` (bootstrap L137) and on the ScoutImport RLS policies denying those roles; this is the original L06 assumption, unchanged and not runtime-verified here.
- The 48 unaffected Jest suites were not rerun on `54970cd9` (per grant; the source delta is confined to `classifyClosed` and two test files; tsc/eslint/prettier ran on the final tree via hooks).
- Prisma full-unique vs DB partial-unique residual and the C observations in REVIEW_B.md remain recorded, not promoted.
- psql 18.6 client vs PG 17.6 server untested in this lane.
