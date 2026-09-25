# S7-L independent review B (T4, nonbuilder) — candidate 839b54c5 / tree f02205c6

Reviewer: independent reviewer B (did not build; did not read REVIEW_A). Written 2026-09-25 ~05:00Z.
Mode: read-only inspection only. No product edits, Git writes, installs, formatters, compiler checks, tests, PG, lock acquisition or remote actions were performed. Only this file was created.

## 1. Identity reviewed (independently re-derived, read-only git)

| item | value |
|---|---|
| worktree | `/home/user/workspace/worktrees/64e33dc7-s7l`, branch `exec64/s7l-replacement`, `git status --porcelain --untracked-files=all` empty |
| HEAD | `839b54c53ccb252f95b4ec63df0b08595bbe7698` |
| tree | `f02205c60ad0bfeb24ce82d74b0025ee9a185df6` |
| parent (`HEAD^`) | `93389265a846095b846fa8f1fb0dad782fb6ee9f` (accepted S8-B head), base tree `a315dd651b8c54c2e82f2260fcc6058f0d13b64a` |
| author / committer | Bradley Gleave <bradley@bradleytgpcoaching.com> (both) |
| delta | 30 files, +5582/−35 (matches `gates/commit-attempt-3.raw.log`, `bundle/HEAD-839b54c53ccb.txt`) |
| base-identical (verified blob-equal to 93389265) | `test/rls-g2-s8b.spec.ts`, `src/scout/scout-reconstruct.service.ts`, `jest.rls.config.js`, `package.json`, `package-lock.json`, `lefthook.yml`, `.github/` |

### Filled binding (parent-delivered 04:39Z; every file read completely; hashes recomputed by me)

| file | sha256 |
|---|---|
| `binding/s7l-pg-proof.sh` (204 lines) | `3e97da2e51fdb7eab32cb828620e639d92c4ed9f6e527eadd2c4a8ae62cef307` |
| `binding/s7l-fixture.sh` (98 lines) | `dc77a7c9b52a439914fe0fdb0903bd6a55b1f47a692a5cda0a22c3a6522b3dd2` |
| `binding/PINS.txt` | `c41a53a7ed9e32b22f1ee8b4344cfc078f5960ae2203f2147a9199ec45148f0f` |
| `binding/README.md` | `22fe2dfaa02054559829ed567fdc4e30019758aad00d88d50c4d2a1c55f7a373` |
| `binding/freeze.sh` | `c891972bfe1de2fc9acc4a004fbff06fadb5e47a9109f549f9e70a31a6cedefa` |
| `binding/BINDING.sha256` | lists exactly these five; header "frozen 2026-09-25T04:39:00Z against head 839b54c5… (source-only; NOT RUN; no PG granted)" |

Pins re-derived by me from the committed head and all equal to the driver/PINS values: HEAD, tree, BASE_TREE; blobs spec `840b3fdc…`, bootstrap `ebef51fc…`, old-root `cb1137fe…`, db `384e1b74…`, pg-harness `d8b71d68…`, harness `f0860a8d…`, worker `a8fed545…`, guard spec `27fcba5f…`, migration tree `4ce57646…`, schema blob `2e328bbc…`. Tool sha256s re-computed and equal: pg17/dist `postgres` `23cd1748…` (17.6), `initdb` `b7db9bc2…`, `pg_ctl` `af53d826…`, `/usr/bin/psql` → `/usr/share/postgresql-common/pg_wrapper` `a200e38c…` (psql 18.6), node `a03953a7…` (v20.20.1), `prisma/schema.prisma` `0eb41f9a…`, `package-lock.json` `b7fed5ed…`, `jest.rls.config.js` `99c9f4f1…`, `node_modules/.package-lock.json` `05bc530a…`, `node_modules/.prisma/client/index.d.ts` `9042e713…`. Generated client carries all 10 S7-L ScoutImport lifecycle fields. Preflight state observed: `recovery-reset/clusters/s7l` and `recovery-reset/s7l/old-root` absent, port 55641 not listening, no `postgres` process, lock file `/home/user/workspace/execution/test-validation.lock` exists, `node_modules/.bin/prettier` absent, `node_modules` is a real directory and git-ignored.

## 2. Findings

Doctrine applied: A = blocks the affected path until fixed; B = blocks only the affected proof, minimal fix, run; C = record/qualify/continue, never independently creates a fixer/test/audit/delay.

### F1 — CLASS A (narrow): `classifyClosed` fences `timed_out` without a deadline check

Evidence: `src/scout/lifecycle/lifecycle.service.ts` L440-459 — after a zero-row gate the row is re-read unlocked (L441) and, if open and unfenced (L443), `fence(coachId, intentId, 'timed_out')` is called at L444 unconditionally. `fence()` L269-296 CAS predicate (L282-283) is `mode='server' AND terminal_status IS NULL AND fenced_at IS NULL AND execution_epoch = seen` — no `deadline_at` predicate. The gate itself (`assertRunOpen` L422-432) returns zero rows for *three* reasons: no visible row, fenced/terminal, or `deadline_at <= now()` (L428-429); `classifyClosed` treats "row now visible and open" as necessarily "past deadline". Decision `docs/decisions/2026-09-24-s7l-run-lifecycle.md` L131 (`now() > deadline_at` precondition for the `timed_out` transition) and L161-164 ("open but `now() > deadline_at` → the same request fences `timed_out`") require the deadline condition. Every other `timed_out` path checks the deadline in JS (start L206, cancel L244, `enforceDeadline` L479-488); this one does not.

Trigger (hypothesis with a concrete mechanism, not invented): a writer (ingest `scout-ingest.service.ts` L94-118, complete `scout.service.ts` L369-410, or progress) runs its gate while Start's insert transaction (L175-186) is not yet committed → zero rows → rollback → `classifyClosed` re-reads after Start commits → row open, `deadline_at` in the future → fenced `timed_out` / `deadline_exceeded` with `fenced_at < deadline_at`.

Concrete harm: a freshly started run becomes terminal seconds after Start; Start thereafter answers 409 `run_terminal` (confirmed by the candidate's own unit spec `test/scout/lifecycle/lifecycle.service.spec.ts` L771-773) and the partial unique index on `import_intent_id` prevents any second server run for that intent → the coach must re-pair a new intent. Silent, permanent, no operator signal beyond a misleading `deadline_exceeded`.

Exact decision blocked: acceptance of the S7-L writer-gate / closed-classification path (ingest, complete, progress 409 classification) as decision-conformant.

Minimum closure: in `classifyClosed`, when `row.terminal_status === null && row.fenced_at === null && row.deadline_at.getTime() > Date.now()` return `{ kind: 'not_started' }` (or let the caller retry the gate once) instead of fencing; optionally add `AND deadline_at <= (now() AT TIME ZONE 'UTC')` to the fence UPDATE for `reason === 'timed_out'`; one unit test in `lifecycle.service.spec.ts` covering "gate closed, row open, deadline in future → no fence". Note the L10 proof (`test/rls-g2-s7l.spec.ts` L821-879) uses `expire()` and does not exercise this race, so the PG proof is neither evidence for nor against it.

Execution unlocked: everything else (Start/Cancel routes, fence/arbiter/terminal write, migration, legacy paths, PG proof preparation). The fix is source-level and will change the head; see §4 on consequences for the binding.

### F2 — CLASS B (proof-only): L06 connects as NOLOGIN roles and will fail at runtime

Evidence: `test/rls-g2-s7l.spec.ts` L524-542 (L06) calls `sqlAs(role, …)` for `role ∈ {'anon','authenticated'}` at L528, L531, L532 and `refused(…, 'row-level security', role)` at L529. `sqlAs` (`test/utils/g2-s7l-pg-harness.ts` L69) → `asRole` (L47-51) sets the URL username to the role and `psqlRun` (L57-64) runs `psql -X -w -qAt -v ON_ERROR_STOP=1 <url>` with `PGPASSWORD` = the fixture password. Those roles are `NOLOGIN` (`test/utils/g2-s7l-bootstrap.sh` L101-102; `scripts/ci/supabase-shim.sql` L23-27); only `postgres` and `service_role` are altered to LOGIN (L105-106, verified L109-112), and the harness's own doc says so (`test/utils/g2-s7l-db.ts` L21: "anon/authenticated NOLOGIN, exercised only via SET ROLE"). Runtime: PostgreSQL answers `FATAL: role "anon" is not permitted to log in`; `execFileSync` throws at L528 before any assertion; even `refused(...)` at L529 would fail because the message does not contain `row-level security`. The accepted S8-B proof uses the correct pattern from the owner session (`test/rls-g2-s8b.spec.ts` L549-556: `SET ROLE ${role}; …`), and `postgres` holds `GRANT anon, authenticated, service_role TO postgres WITH ADMIN OPTION` (bootstrap L107) so `SET ROLE` works.

Concrete harm: none to product; the one granted PG proof run (single-shot, sentinel-guarded, driver L68) would fail in L06 and burn the run.

Exact decision blocked: GO for the one new PG proof as bound.

Minimum closure: rewrite L06 to `sql(\`SET ROLE ${role}; SELECT count(*) …\`)`, `refused(\`SET ROLE ${role}; ${serverRunInsert(…)}\`, 'row-level security')`, and `sql(\`SET ROLE ${role}; UPDATE …\`)` / `DELETE` (owner-session pattern); no harness change needed. Also correct the `sqlAs` docstring at pg-harness L67-68 if desired (C). This changes the spec blob (pinned `EXPECT_SPEC_BLOB=840b3fdc…`) and therefore requires a new head and a new binding version (freeze.sh refuses re-freeze, L12).

Execution unlocked: all other L01-L12 stanzas as written; the driver/fixture/binding shape is otherwise correct.

### C findings (record/continue)

- C1 `prisma/migrations/20270123000000_scout_run_lifecycle_expand/migration.sql` L141-154: `ScoutImport_mode_shape_check` omits the decision's invariant-2 clause `intent_id = import_intent_id::text` (decision L181-182); enforced only by the service insert (lifecycle.service.ts L175-186).
- C2 `src/scout/scout.service.ts` L404 / L548-570: `completeServerRun` sends `notifyComplete` with the extension's claim before the arbiter verdict; push text is truthful ("staged… Migration is not verified").
- C3 `scout.service.ts` ~L398-400: P2002 duplicate `/complete` on a still-open run returns ack without arbitrating; if the first caller died between commit and settle, the run stays `reconciling` until the lazy deadline.
- C4 `down.sql` L16 `SET LOCAL row_security = off` (same doctrine as C1/S8-B); app clock `new Date()` for `accepted_start_at` vs DB `now()` in the gate (minor skew).
- C5 Binding: `G2_S7L_PSQL=/usr/bin/psql` is a psql 18.6 client against the 17.6 server (pinned sha `a200e38c…`); harmless for the `-qAt` statements used. `FIXPASS=s7l_local_synthetic` is a synthetic disposable identity and passes `withFixturePassword`'s character check. Fixture closes fd 9 for postgres children (`s7l-fixture.sh` L37 `9>&-`), so the postmaster does not inherit the flock; jest does inherit fd 9 but exits before the driver.
- C6 Gate coverage vs final tree: the 49-suite affected Jest run (`gates/jest-affected.raw.log`, 48 pass / 1 fail) was executed on staged tree `7086b682…`; the committed tree `f02205c6…` differs in 13 files. I verified (whitespace/comma-normalised comparison) that all of them are Prettier formatting only except: `docs/contracts/importer-openapi.json` (regenerated, sha `fc42af0a…`, version `2.0.0-c1-s2.0`, ingest 409 enum), `test/contracts/importer-contract.spec.ts` (dig() fix + ingest-409 assertions; rerun 56/56 in `jest-contract-rerun-2.raw.log`), and `src/scout/scout-ingest.controller.ts` (Swagger `@ApiResponse 409` decorator + import only; no behavioural code). Pre-commit lefthook (prettier/eslint/tsc) passed on the final tree (`commit-attempt-3.raw.log`, `slot-3.log`). Adequate; recorded because the unit suites themselves were not rerun on the final tree.
- C7 `FINAL_RECEIPT.md` §Slot: the canonical lock is currently held by S8-C (pid 795); the driver refuses a live holder (rc 75). Parent sequencing item, not a defect.
- C8 Data directory is retained after the run by design (README, fixture L18-19); `destroy` is a separate marker-gated decision.

### Positives verified (not exhaustive)

Guard order owned→paired→superseded→existing (lifecycle.service.ts L159-170); idempotent Start via P2002 re-read (L189-196); gate is UPDATE-first per decision §3.1; fence uses `FOR NO KEY UPDATE` (lockRun L338-342) + epoch CAS + terminal write in the same tx; `writeTerminal` CAS; arbiter never emits `complete` without a verdict; legacy paths byte-unchanged; controller awaits async progress; routes `runs/start` and `runs/cancel` `@Roles('coach','owner')` 30/min; no new feature flag. Worker (`g2-s7l-worker.cjs`) constructs real `ScoutService`/`ScoutIngestService`/`ScoutLifecycleService` with constructor orders matching source; barriers match gate text (`last_observed_at =` L425) and `FOR NO KEY UPDATE` (L342). Migration/down set `lock_timeout 5s` so the 55P03 stanza (spec L263-270) is consistent. Old writer at 93389265 is a single `$transaction([completion.create, scoutImport.upsert])`, so the L05/L12 crossed-write expectation (spec L989-995) holds. `test/utils/g2-s7l-old-root.sh` is a real detached clone with the exact bootstrap step-4 gate and 171-migration count. Driver: `set -uo pipefail` with explicit rc checks; sentinel refuses rerun; `flock -n` on fd 9 held to exit; pins every proof object, tools and base-equal paths; preflight requires lane/OLD root absent, port free, no postgres; bounded stages (old-root 180 s, init 60 s, start 60 s, bootstrap 900 s, identity 15 s each, jest 1800 s, stop 75 s); runs exactly `./node_modules/.bin/jest --config jest.rls.config.js test/rls-g2-s7l.spec.ts --runInBand --ci`; post checks worktree/head/client/OLD root unchanged; exports only `G2_S7L_*`. Fixture: fresh-init-only, marker-gated start/destroy, loopback 55641, data dir matches the guard regex, bounded stop, destroy never discards a stop failure.

## 3. Applicable gates and receipts (read; not rerun)

- tsc rc 0 (`gates/tsc.raw.log`); eslint rc 0 (`slot-3.log` 04:29:31Z, `eslint-final.raw.log` empty); R75 rc 0 (`gates/r75.log` "no positive token change"); prettier 3.9.9 check rc 0 (`prettier-check-3.log`); contract regenerate rc 0 → `fc42af0a…`; Jest affected 49 suites 48/1 on tree 7086b682 then contract suite 56/56 on final (see C6); lefthook pre-commit + commit-msg pass (`commit-attempt-3.raw.log`); slot run 2 pid 26166 04:28:15-04:30:19Z rc 0, lock file preserved; bundles verified (`bundle/SHA256SUMS`, thin + full-history).
- freeze.sh design is sound (read-only re-derivation, report-never-edit, refuses dirty/base/identity/trailers/re-freeze) and its result (13 HEAD_PIN_OK, 10 TOOL_PIN_OK) is independently reproduced above.

## 4. Verdict for the one new PG proof

**NOT GO** for the one PG proof as currently bound (head 839b54c5 / tree f02205c6 / binding `BINDING.sha256` frozen 04:39Z).

Reasons, in order of weight:
1. F2 (B): `test/rls-g2-s7l.spec.ts` L06 (L524-542) cannot pass against the bootstrap's NOLOGIN `anon`/`authenticated` roles; the single-shot run would fail deterministically at L528. Running it now would consume the one grant to observe a known harness defect.
2. F1 (A): the `classifyClosed` deadline omission requires a source change to `src/scout/lifecycle/lifecycle.service.ts`; since the driver pins HEAD/tree and the fix produces a new head, the proof should bind to the corrected head rather than be run twice.

Path to GO (minimum): apply the two minimum closures above (L06 owner-session `SET ROLE` pattern; deadline check in `classifyClosed` + one unit test), re-run the source gates (tsc/eslint/prettier/R75/affected Jest) on the new head, commit, re-freeze a new binding version (new `EXPECT_HEAD`/`EXPECT_TREE`/`EXPECT_SPEC_BLOB`, new fixture-sha fill is unchanged), and re-review that binding. Everything else in the driver, fixture, bootstrap, old-root helper, worker, harness and spec L01-L05, L07-L12 is, on source inspection, ready and correctly bound; I found no other runtime-blocking defect.

## 5. Candid unverified runtime limitations

- No PG run has occurred; nothing in this review is runtime evidence. Pinned catalog renderings (`test/utils/g2-s7l-harness.ts` L76-89 `pg_get_constraintdef`/`pg_get_indexdef` strings), the 55P03 lock-timeout stanza, the crossed-write L05/L12 behaviour, barrier timing in the worker and the `blocked()` `pg_stat_activity` polling are unverified until the first run and may surface B-class proof adjustments that source reading cannot rule out.
- The 48 unaffected-by-content Jest suites were not rerun on the final tree (C6); tsc/eslint/prettier were.
- Prisma `@@unique([import_intent_id])` vs DB partial unique index remains an accepted residual (SOURCE_READY.md).
- psql 18.6 client vs 17.6 server untested in this lane (C5).
- I did not read REVIEW_A.md and did not audit any old accepted lane (93389265 and earlier) beyond the base-equality blob checks the driver itself asserts.
