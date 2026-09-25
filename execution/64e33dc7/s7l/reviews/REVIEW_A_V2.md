# S7-L independent review A — V2 changed-question re-attestation (F1/F2 closure, new head lineage, filled binding v2)

Reviewer: independent reviewer A (T4, nonbuilder). Written 2026-09-25T05:0xZ under `S7L_MINIMUM_CORRECTION_GRANT.md`. Scope is ONLY: F1 closure, F2 closure, new head/parent/tree lineage, applicable gates on the follow-up, and the changed filled binding v2. The unchanged source audit is not repeated; `REVIEW_A.md` (sha256 `4e12ad6c8ca7f6f3b869264a94db7547d6938eb1ca7802f930c8578b8feb404a`) is preserved unaltered and remains the historical record. Read-only inspection only: no product/Git/runtime writes, no tests, installs, formatters, compiler, hooks, PG, lock acquisition or remote actions. `REVIEW_B.md` / `REVIEW_B_V2.md` not read.

## 1. Identity re-attested (all recomputed read-only)

| Item | Value | How |
|---|---|---|
| v2 head | `54970cd937afc8dea689b33243961abfef8b9dd6` | `git rev-parse HEAD` in `/home/user/workspace/worktrees/64e33dc7-s7l`; `status --porcelain` 0 lines |
| v2 tree | `513c71d7c1390787e1521ccbfa46b30bb52b5462` | `rev-parse HEAD^{tree}` |
| Exact parent | `839b54c53ccb252f95b4ec63df0b08595bbe7698` (v1 candidate, tree `f02205c6…`, preserved — not amended) | `rev-parse HEAD^`; v1 bundle/binding untouched (`binding/BINDING.sha256` still lists v1 driver `3e97da2e…`) |
| Parent's parent | `93389265a846095b846fa8f1fb0dad782fb6ee9f` (accepted base) | `rev-parse HEAD^^`; `merge-base --is-ancestor 93389265 HEAD` true |
| Commit | ordinary follow-up; author+committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`; message body plain prose, no trailer block; hooked (`correction/commit-attempt-1.raw.log`: pre-commit prod-readiness-quick / banned-cast-tokens / prettier / eslint / tsc all ✔, commit-msg no-ai-tokens ✔) | receipt read |
| Delta 839b54c5→54970cd9 | exactly `src/scout/lifecycle/lifecycle.service.ts` (+7/−1), `test/scout/lifecycle/lifecycle.service.spec.ts` (+16), `test/rls-g2-s7l.spec.ts` (+7/−4); 3 files +30/−5; `git diff --name-only` sorted = the three granted paths and nothing else | full diff read |
| Changed blobs | lifecycle.service.ts `5949a29357f46d545456e178a70069d26c4cc5ad`; lifecycle.service.spec.ts `52d4f14457f44f005fad836923a305d239538bc7`; rls-g2-s7l.spec.ts `052fa35d5c03658a5ee90cebe5e6eca467311d0d` | `rev-parse HEAD:<path>`; equal to PINS.txt / CORRECTION_RECEIPT |

## 2. F1 (class A) — fresh-run fenced `timed_out` after a zero-row gate: CLOSED

`src/scout/lifecycle/lifecycle.service.ts` `classifyClosed` (head L444-452): after `readRun`, for an open row (`terminal_status === null && fenced_at === null`) the new guard `if (row.deadline_at !== null && row.deadline_at.getTime() > Date.now()) return { kind: 'not_started' };` runs BEFORE `this.fence(coachId, intentId, 'timed_out')`. Assessment:
- Matches the grant's minimum closure exactly: an open, not-yet-expired row is answered `not_started` (409 `run_not_started`, the same answer the failed gate implied) with no fence and no write; the expired-row lazy `timed_out` path and the no-row / legacy / fenced / terminal branches are unchanged (diff shows no other logic touched). Comment extended to state the reasoning.
- Clock basis is consistent: `deadline_at` is computed by the service from the app clock at Start (`accepted_start_at`/`deadline_at`, unchanged code), so comparing it with `Date.now()` uses the same clock; the SQL gate's `deadline_at > now()` comparison is unchanged. A null `deadline_at` on an open server row (excluded by the migration CHECK) falls through to the previous path — no widening.
- Regression case added (`test/scout/lifecycle/lifecycle.service.spec.ts` L399-413): future deadline (+60 s) open row → `{ kind: 'not_started' }`, `closedConflict` code `run_not_started`, and `$transaction`, `$queryRaw`, `$executeRaw`, analytics `capture` all `not.toHaveBeenCalled()`. The existing expired-row case (L385-397, `deadline_at: now − 5 ms` → `fenced/timed_out`) is preserved verbatim; no case deleted or weakened (diff is pure addition). Suite result 29/29 (`correction/jest-lifecycle-unit.raw.log`, `slot-4.log` `JEST_LIFECYCLE rc=0`).
- Consequence for the PG proof: L10 (real lazy deadline) uses expired rows and is unaffected; no S7-L PG case depends on fencing a fresh open row. Concrete harm (permanent terminal on a brand-new run, burned unique intent) is removed. Nothing further blocks acceptance of the lifecycle bytes on this question.

## 3. F2 (class B) — L06 logging in as NOLOGIN roles: CLOSED

`test/rls-g2-s7l.spec.ts` L06 (head L524-545): `sqlAs(role, …)` / `refused(…, role)` replaced by owner-session `sql(\`SET ROLE ${role}; …\`)` for the SELECT (`toBe('0')`), the refused INSERT (`refused(\`SET ROLE ${role}; ${serverRunInsert(...)}\`, 'row-level security')`), the UPDATE and the DELETE; the count-unchanged and `phase='reconciling'` = 0 assertions and the `service_role` BEGIN…ROLLBACK case (`sqlAs('service_role', …)`, L537-544) are unchanged. Assessment:
- Mechanism is valid on the fixture: `g2-s7l-bootstrap.sh` L101-102 creates `anon`/`authenticated` `NOLOGIN NOINHERIT`, L107 `GRANT anon, authenticated, service_role TO postgres WITH ADMIN OPTION` (so the owner session may `SET ROLE`), L137 default privileges grant ALL on public tables to the API roles, so the refusal exercised is the RLS decision (`row-level security`), not a privilege or connection error. `service_role` retains harness-only LOGIN (L106), so the stage-4 workers and the rollback case are unaffected. This is the accepted S8-B P06 pattern (`test/rls-g2-s8b.spec.ts` L549-564). `sql()` = `psqlRun(migrationUrl …)` runs the two statements in one psql invocation as the owner (`g2-s7l-pg-harness.ts` L65).
- Coverage preserved: every original assertion is present with the role reached differently; nothing removed.
- Correction to my original report: `REVIEW_A.md` §3 listed L06 as proving anon/authenticated denial; at head 839b54c5 that case would have failed at connection time (role not permitted to log in) and consumed the single proof. I missed this; Review B's finding stands and is now closed.

## 4. Applicable gates on the follow-up (receipts read, not rerun)

`correction/slot-4.log`: canonical lock ACQUIRED in-process fd9 pid 10350 04:56:44Z; PREFIX_VERIFY rc0 (pinned prettier 3.9.9, 56 ok lines); PRETTIER_CHECK_1 rc0 (3 files, no rewrite); ESLINT rc0; R75 rc0; JEST_LIFECYCLE rc0 29/29; GIT_COMMIT rc0 → HEAD 54970cd9 / TREE 513c71d7 Bradley/Bradley; thin + full bundles rc0; RELEASING 04:57:54Z (lock file preserved). Hooks in `commit-attempt-1.raw.log` as above (tsc 46.8 s, heap 4096 per the relay script). Per the grant, NOT run and NOT claimed: the 48 unaffected suites, contract regeneration (no contract surface changed — the delta touches no DTO/controller/OpenAPI file), any PG. `bundle/v2/` and `CORRECTION_RECEIPT.md` read; consistent with the above.

## 5. Filled binding v2 (read completely; every hash recomputed)

Location `/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v2/`. `sha256sum -c BINDING.sha256`: 6/6 OK. `BINDING.sha256` file sha256 `01985b8561fda734e8f4d9821dd9e2e231fd819d2ba63bae5f28735575531be2`.

- `s7l-pg-proof.sh` `0287a941655b0ff9ec19a306af943fd93c357c00b6187f6ad31dfc90c1de2705`
- `s7l-fixture.sh` `dc77a7c9b52a439914fe0fdb0903bd6a55b1f47a692a5cda0a22c3a6522b3dd2` — `cmp` byte-identical to v1 `../s7l-fixture.sh`
- `PINS.txt`, `README.md`, `DELTA-v1-to-v2.md`, `freeze-v2.sh` — listed OK in `BINDING.sha256`; all read in full. `BINDING.sha256.first-pass-04-58-26Z` retained as history (not an execution input).

Driver v1→v2 delta: I ran `diff ../s7l-pg-proof.sh s7l-pg-proof.sh` and it is byte-identical (`cmp`) to the recorded `driver-v1-to-v2.diff` (44 lines). The changes are exactly: header comment; usage path and `D=…/binding/v2` (run receipts under `binding/v2/run`); pins `EXPECT_PARENT=839b54c5…` added, `EXPECT_HEAD`→`54970cd9…`, `EXPECT_TREE`→`513c71d7…`, `EXPECT_SPEC_BLOB`→`052fa35d…`; placeholder refusal widened to head/tree/spec-blob; `EXPECT_HEAD` must differ from base AND v1 parent; exact-parent check `HEAD^ == EXPECT_PARENT` (replacing v1's `HEAD^ == BASE_HEAD`) plus `EXPECT_PARENT^ == BASE_HEAD`, `EXPECT_PARENT^{tree} == f02205c6…`, base-ancestor check retained, and `git diff --name-only EXPECT_PARENT HEAD` must equal exactly the three granted paths. No change to lock handling (in-process `flock -n` fd9 held to exit; fixture closes fd9 for PG children), fixture calls, bootstrap, identity checks, the single jest invocation `./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s7l.spec.ts --runInBand --ci`, stop/post logic, stage bounds, `timeout -k 30 3900`, exit codes 70-76, refused-port list, or lane names (55641 / `g2_s7l_disposable` / `s7l-disposable-pg17` / `recovery-reset/clusters/s7l/pg-data`). Accepted suites still never invoked; no production or other live lane addressed.

Pins verified against the v2 head: all 8 `EXPECT_*_BLOB` (spec, bootstrap, old-root, db, pg-harness, harness, worker, guard spec) equal `git rev-parse HEAD:<path>`; `EXPECT_MIGRATION_TREE` `4ce57646…` and `EXPECT_SCHEMA_BLOB` `2e328bbc…` equal the head objects (unchanged from v1, as expected: no migration/schema change in the delta). Tool pins are unchanged from v1 and I re-checked the three most likely to drift read-only: `node_modules/.prisma/client/index.d.ts` `9042e713…`, `jest.rls.config.js` `99c9f4f1…`, `node_modules/.package-lock.json` `05bc530a…` — all match; the postgres/initdb/pg_ctl/psql/node/package-lock pins were verified by me in the original review and their files are outside the delta. Lane state now: `recovery-reset/clusters` and `recovery-reset/s7l/old-root` absent, `pgrep -cx postgres` = 0, port 55641 no listeners, lock file present and unheld per the slot-4 release record.

## 6. Findings on the changed question

No class A or B finding. Class C (record only, no action created):
- C-V2-1: `README.md` §"Known A/B residuals" reuses the v1 wording "Known A/B residuals" for items that are all class C in both reviews (Prisma full-unique vs DB partial-unique, legacy spec doubles, unverified catalog renderings, no S9 path). Label only; no decision consequence.
- C-V2-2: Original review C1 (missing `deadline_at <= now()` predicate in the `timed_out` fence SQL, `lifecycle.service.ts` L278-283) is now shielded by the F1 guard on the only caller path; the SQL predicate itself is unchanged. No consequence given the guard; not promoted.

Unverified, stated candidly: nothing here verifies runtime. The PG proof has still never been executed; F2's `SET ROLE` mechanism is validated by reading bootstrap/harness and the accepted S8-B precedent, not by a run; pinned catalog renderings, gate/fence/CAS/deadline semantics on real PG, RLS byte-equality and down/up identity remain proven only by the pending single-shot run. No S9 verdict path, no deployment or customer acceptance is claimed.

## 7. Decision

**GO** for exactly ONE execution grant of the single new PG proof, bound to:
- head `54970cd937afc8dea689b33243961abfef8b9dd6`, tree `513c71d7c1390787e1521ccbfa46b30bb52b5462`, exact parent `839b54c53ccb252f95b4ec63df0b08595bbe7698` (tree `f02205c6…`), base `93389265a846095b846fa8f1fb0dad782fb6ee9f`;
- binding v2: driver `binding/v2/s7l-pg-proof.sh` sha256 `0287a941655b0ff9ec19a306af943fd93c357c00b6187f6ad31dfc90c1de2705`; fixture `binding/v2/s7l-fixture.sh` sha256 `dc77a7c9b52a439914fe0fdb0903bd6a55b1f47a692a5cda0a22c3a6522b3dd2`; `binding/v2/BINDING.sha256` file sha256 `01985b8561fda734e8f4d9821dd9e2e231fd819d2ba63bae5f28735575531be2`;
- invocation exactly `timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v2/s7l-pg-proof.sh`, single-shot (sentinel under `binding/v2/run`), first failure stops, data directory retained.

The v1 binding (`binding/s7l-pg-proof.sh` `3e97da2e…`) is superseded for execution by this v2 and must not be run: it pins the v1 head and would refuse (rc 70) on the current worktree. Any v2 precondition/preflight/identity mismatch at run time is a refusal, not a reason to edit pins; a proof failure is evidence to be read, not retried. This is not runtime acceptance; acceptance requires review of the observed jest result and retained receipts after the run.
