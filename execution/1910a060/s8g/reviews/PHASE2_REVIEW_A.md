# S8-G PHASE-2 REVIEW A (T4 independent non-builder, read-only)

Reviewer: review A (author of `SOURCE_REVIEW_A.md`). Read-only git inspection of `worktrees/1910a060-s8g` (no npm/jest/lock/checkout), evidence under `execution/1910a060/s8g/{build,gate,binding}`. Reviewer B's output not read. Sole write: this file.

## Verdicts

- **FINAL GO for acceptance of exact commit `820ce85be2ebf994112afbb90739eb9469ad628e`** (tree `7ede6dbb8f6f2d0ddcc349882a47ef67d415c32a`, sole parent `62471b116267fdec6746073c4b4c80a154d09834`). Product blobs are byte-identical to the reviewed ones; every non-formatting test delta is verified and none weakens a test; gate receipts are genuine and internally consistent; the dev-loop process deviation does not touch the evidence relied upon.
- **Binding v1: NO-GO as-is; GO for one run after fill once B-BIND-1..3 are closed** (three small runner/receipt edits, no design change). Closures are precedent-backed (S8-F v2) and listed with exact text.

## (1) Product identity — verified

`git diff-tree -r 62471b11 820ce85b`: exactly 14 paths, +3877/−14, 2 M + 12 A, `g2-s8g-bootstrap.sh` mode 100755 — exactly the granted PATHS. Product blobs at 820ce85b vs my applied review tree (`/tmp/s8g-review-a/base`, from the reviewed patch):

| Path | 820ce85b | reviewed |
|---|---|---|
| src/scout/lifecycle/lifecycle.service.ts | `1a6db74e41370d3dc34f7bc74996c2e097a0e9e5` | identical |
| src/scout/scout-reconstruct.service.ts | `fb72850284e33249b4b682bbf3f1d28a914357b6` | identical |
| src/scout/reconstruct/orchestration/family-plan.ts | `0a75e656d2b1f9d0b411599c6cbd15c684815df4` | identical |
| src/scout/reconstruct/orchestration/run-context.ts | `b07ebb853344d59b3b2dd6ac4dcf8d0d1f9182fe` | identical |

SOURCE_REVIEW_A product GO applies verbatim. Unchanged at base and head: `prisma/**` (schema blob `2e328bbc`), `package-lock.json`, `lefthook.yml`, `package.json`, `jest.config.js`, `jest.rls.config.js` (`git diff --stat` empty). Final patch `gate/attempt-4/s8g-a4-62471b116267-to-820ce85be2eb.patch` sha256 `36b53f0c…` equals `git diff --binary 62471b11 820ce85b` recomputed by me.

## (2) Test deltas reviewed → committed — verified, no weakening

Method: reconstructed the reviewed rebased tree (62471b11 archive + `s8g-candidate-62471b11.patch`, apply clean), then compared each test file with the 820ce85b blob after a formatting-neutral normalization (strip all whitespace, strip trailing commas before `)]}`), reporting residual token differences.

| File | reviewed → head | residual non-formatting delta |
|---|---|---|
| test/rls-g2-s8g.spec.ts | `3c8491bd` → `86a944c1` | **none** (prettier only) |
| test/scout/orchestration/family-plan.spec.ts | `46a36eac` → `829ad280` | **none** |
| test/scout/orchestration/settle-hook.spec.ts | `d0334d6c` → `4465515d` | **none** |
| test/scout/orchestration/reconstruct-run.spec.ts | `bdb01c0a` → `497798e1` | FIX-1: `(s as Record<string, unknown>)[k]` → `s[k as keyof Staged]` (FakePrisma `select` helper, TS2352 closure; same semantics). FIX-2: the inline fixture source spec gains `clientSourceId: { paths: [['client_id']], coerce: 'string_or_finite_number' }` for programs/workouts/client_history — the rule the accepted S8-A parser requires and which the live harness `SPEC` already had; fixture correction, not an assertion change. |
| test/scout/g2-s8g-db-guard.spec.ts | `10781eca` → `4009f753` | dev-loop iter-2: fixture port 55643 → 55644 throughout; **one refused case added** `base.replace('55644','55643')`; mismatched-ack case now uses `:55643` as the wrong port. |
| test/utils/g2-s8g-db.ts | `da34f70d` → `c654e6bd` | dev-loop iter-2: `'55643'` added to `REFUSED_PORTS`; comment updated (55643 = retained S8-F lane, 55644 suggested). |
| bootstrap.sh, harness.ts, pg-harness.ts, worker.cjs | identical blobs | none |

Counts: `it(` 19/8/9/12/10 and `expect(` 198/62/16/45/36 unchanged per file (db-guard's `it.each` table gained one row). No `.skip`, `.only`, `xit`, `xdescribe`, `.todo` anywhere in the committed test files. FIX-1/FIX-2/iter-2 diffs in `gate/FIX-1.diff`, `gate/FIX-2.diff`, `gate/dev-loop/iter-2.diff` match what I measured.

Closure of my SOURCE_REVIEW_A B1/B2: **closed.** `build/SOURCE_READY-FINAL.md` binds identity to the committed head with per-file blob+sha256 (`final-blob-hashes-820ce85b.txt`, all 14 verified by me against `820ce85b:<path>`); the rebase is committed (parent 62471b11), base pins in bootstrap/db.ts/db-guard are 62471b11, and the binding's `BASE_HEAD`/`BASE_TREE` are `62471b11…`/`23614f0b…` (I verified `62471b11^{tree}` = `23614f0b…`).

## (3) Gate receipts — genuine and consistent

- `gate/attempt-4/SHA256SUMS`: 23 entries, all OK. Lock: `ACQUIRED pid=21509 fd9 inode=667698 waited=0s` 22:15:23Z → `RELEASING … rc=0` 22:27:57Z (canonical inode confirmed: `stat` of `execution/test-validation.lock` = 667698).
- Toolchain: prettier 3.9.9 via pinned prefix (`PREFIX_VERIFY rc=0 56/56`), `PRETTIER_CHECK_1 rc=0` (no rewrites), `ESLINT rc=0`, `TSC rc=0 lines=0`, donor node_modules pinned (`NM_HIDDEN_LOCK 05bc530a…`, `NM_CLIENT_INDEX_DTS 9042e713…`), lefthook 2.1.9 with own hooks normalized-equal to the reference clone's.
- POSTFORMAT sha256 per file in `gate.log` equal `final-blob-hashes-820ce85b.txt` sha256 (spot-checked all 14, e.g. lifecycle `14fadc5e…`, spec `208f36b1…`, bootstrap `3241806c…`); STAGED_BLOB lines equal the committed blobs; `STAGED_TREE=7ede6dbb…` equals the commit tree.
- Jest targeted: `4 passed / 86 tests` (`jest-targeted.raw.log`). Full default: `Test Suites: 12 skipped, 577 passed, 577 of 589 total; Tests: 159 skipped, 5 todo, 9111 passed, 9275 total; Snapshots 6 passed; 634 s`. `rls-g2-s8g` absent from the full log (correctly ignored by `testPathIgnorePatterns`).
- **Skips pre-existing:** the same `12 skipped` suites / `159 skipped` tests / `5 todo` appear in accepted S7-L CI (`daceddc8/landing/ci/s7-l/build-and-test-108167074028.log`: `12 skipped, 567 passed, 567 of 579`), S8-C CI (`12 skipped … of 584`), and NQ1 (`12 skipped, 558 of 570`, `159 skipped, 5 todo`). Suite total 589 = base + the 4 new default-suite specs. Not introduced by S8-G.
- Hooks: `commit-attempt-1.raw.log` (the single commit's hook transcript) shows pre-commit `prod-readiness-quick, banned-cast-tokens, prettier, eslint, tsc` ✔ and commit-msg `no-ai-tokens` ✔; `GIT_COMMIT rc=0`. Clone `.git/hooks/{pre-commit,commit-msg}` are lefthook stubs.
- Identity: author = committer = Bradley Gleave <bradley@bradleytgpcoaching.com>, timestamp 1790375226 (22:27:06Z, inside the lock window); message equals `gate/attempt-4/commit-message.txt`; **no trailers** (body ends "No migration."); no merge parent; worktree clean at review time.
- Attempt history is coherent: a1 rc 73 (tsc) → FIX-1 → a2 rc 73 (jest fixture) → FIX-2 → dev loop → a3 launched and `ABORTED_BY_BUILDER stage=jest-full` before commit (`attempt-3/ABORTED`) → a4 rc 0. No attempt produced a commit other than 820ce85b.

## (4) Process note — dev-loop iteration 1 ran without the lock

Facts (`gate/DEV-LOOP.md`, `dev-loop/HELD`/`RELEASED`/`hold.out`): holder HELD 22:09:46Z, lost by process-group teardown and RELEASED 22:09:52Z; iter-1 jest (targeted 4 suites, ≈22:09:58Z–22:10:09Z, 85/85) therefore ran with the canonical lock free. Builder disclosed it unprompted.

Assessment: **C — does not affect evidence validity.** (a) Nothing from iter-1 is relied upon: its tree predates iter-2 (85 vs 86 tests) and the acceptance evidence is attempt-4, whose targeted and full runs both executed under the held lock (22:15:23Z–22:27:57Z). (b) Iter-1 wrote nothing but jest's cache and made no edits. (c) No concurrent holder existed (`lslocks` 0; the S9-A compose run ended 22:09:36Z, the next started 22:28:04Z), so no shared resource was contended. (d) Iter-2 and attempt 4 used the `timeout`-wrapped holder and were slot-compliant. Record as a process deviation with disclosure; no re-run needed.

## (5) Binding v1 (`binding/v1/`, unfilled, unrun) — GO for one run after fill, conditional on B-BIND-1..3

Current file identities: runner `s8g-pg-proof.sh.unfilled` sha256 `b600ef12…`, `s8g-fixture.sh` `b2dd548a…`, `PINS.txt.unfilled` `aab0be75…`, `README.md` `f7e98301…`.

Verified OK:
- **LANE consistency runner↔fixture:** both use `RUNTIME_ROOT=/home/user/workspace/execution/1910a060/runtime` (exists; `pg17/PROVENANCE.txt result=success`), `LANE=$RUNTIME_ROOT/clusters/s8-g`, `DATA=$LANE/pg-data`, `SOCK=$RUNTIME_ROOT/run/s8-g`; runner exports `G2_S8G_DATA_DIRECTORY=$LANE/pg-data` and asserts `SHOW data_directory` equals it; fixture INIT marker prefix matches the runner's grep. The S9-B defect (fixture pointing at a non-existent 64e33dc7 root) is **not** present here.
- **PORT 55644:** runner `PORT=55644`, fixture `PORT=55644`, `G2_S8G_CONFIRM=g2_s8g_disposable:55644`; committed `g2-s8g-db.ts` refuses 55641/55642/55643 and not 55644; no other harness under `test/utils/` references 55644. Preflight requires port free and `pgrep -cx postgres` = 0.
- **BASE pins:** `BASE_HEAD=62471b11…`, `BASE_TREE=23614f0b…` (verified), runner asserts base tree and ancestry, prisma tree unchanged vs base.
- **Accepted pins:** the 19 accepted-file blob pins embedded in the runner all match `820ce85b:<path>`; `package-lock.json` pinned by sha256 (`b7fed5ed…` = base object). All **37** path=blob pins in `PINS.txt.unfilled` (20 S7-L/S8-C/base + 17 S8-F) match `820ce85b` (verified by me). Note: the 17 S8-F pins are in PINS.txt only, not in the runner loop; `EXPECT_TREE` transitively pins them, so this is documentary (C-BIND-4).
- **Tool pins:** postgres/initdb/pg_ctl sha256 at `$DIST/bin` equal `23cd1748…`/`b7db9bc2…`/`af53d826…`; donor `.package-lock.json` `05bc530a…` and `.prisma/client/index.d.ts` `9042e713…` equal the pins; `prisma/schema.prisma` sha256 `0eb41f9a…` equals the base object.
- **Once-only sentinel** (`exit 76`), **canonical lock** `exec 9>>$LOCK; flock -n 9` (exit 75; inode 667698 logged; never deleted), fixture refuses standalone use unless `S8G_RUNNER_PID` is a live `s8g-pg-proof.sh`, data dir retained, destroy marker-gated, bounded stages, jest exactly once with `--runInBand --ci`, post-run porcelain/HEAD/client re-checks, other-lane pg_control unchanged.
- Head pins to fill (`gate/attempt-4/BINDING-PINS-820ce85be2eb.txt`): EXPECT_HEAD `820ce85b…`, EXPECT_TREE `7ede6dbb…`, spec `86a944c1`, bootstrap `2ab85a13`, db `c654e6bd`, pgh `a0261246`, harness `ee2a41a2`, worker `65ee972d`, fixture sha256 `b2dd548a…` — all consistent with the head and the current fixture file.

### B-BIND-1 — psql pin binds the Debian `pg_wrapper`, not the 18.6 client binary
- Evidence: `EXPECT_PSQL_SHA=a200e38c…` with check `sha "$(readlink -f /usr/bin/psql)"`; on this host `readlink -f /usr/bin/psql` = `/usr/share/postgresql-common/pg_wrapper` (sha256 `a200e38c…`, a dispatcher script). The real client `/usr/lib/postgresql/18/bin/psql` is sha256 `d1108fdb45b87f2313d7acfbb91a0a65ca97c6c2195f15d8ae9295121029ef67` and is not pinned. `G2_S8G_PSQL=/usr/bin/psql` and `psqlq` use the wrapper. This is the S8-C carry-over that S8-F v2 closed (S8-F REVIEW_B_V2: `PSQL=/usr/lib/postgresql/18/bin/psql d1108fdb… ✓`).
- Harm: the tool used to install the accepted history and to perform identity/RLS assertions is not identity-pinned; a different client resolved by the wrapper would be accepted silently.
- Decision: block the binding run only. Minimum closure (per S8-F v2 precedent): `PSQL=/usr/lib/postgresql/18/bin/psql`; `EXPECT_PSQL_SHA=d1108fdb…`; check `[ "$(sha "$PSQL")" = "$EXPECT_PSQL_SHA" ]` and `"$PSQL" --version | grep -Eq '^psql \(PostgreSQL\) 18\.'`; export `G2_S8G_PSQL=$PSQL` and use `$PSQL` in `psqlq`. Update PINS.txt accordingly.

### B-BIND-2 — no expected test-count assertion after jest
- Evidence: after `JEST_END` the runner only echoes the `Test Suites|Tests` lines and gates on `rc`. The committed spec has exactly **19** `it(` cases (0 `it.each`, 0 skips). S8-F v2 added `EXPECT_TESTS` (REVIEW_A_V2/REVIEW_B_V2 accepted it as "strictly stronger"); S9-B review classed its absence B.
- Harm: a future `describe.skip`/focused edit or a partially-run suite could produce rc 0 with `N skipped` and be accepted.
- Decision: block the binding run only. Minimum closure: add `EXPECT_TESTS=19` to the pins and, after `JEST_END`: `grep -Eq "^Test Suites: +1 passed, 1 total" "$JLOG" && grep -Eq "^Tests: +$EXPECT_TESTS passed, $EXPECT_TESTS total" "$JLOG" || fail 72`.

### B-BIND-3 — `BINDING.sha256.unfilled` is stale (hashes the pre-review snapshot, not v1)
- Evidence: `BINDING.sha256.unfilled` lists runner `cbd87c06…`, fixture `d717bf3d…`, PINS `ec60260c…`, README `f7e98301…`; these equal `binding/v1-pre-review-snapshot/*`, while the current v1 files are `b600ef12…`, `b2dd548a…`, `aab0be75…` (README unchanged). The post-review runner and fixture are therefore not covered by the binding's own manifest.
- Harm: the binding freeze does not attest the bytes that will be filled and run.
- Decision: block only the binding attestation. Minimum closure: regenerate `BINDING.sha256.unfilled` from the current files (after B-BIND-1/2 edits), and record the template→filled diff + sha256 in `BINDING.sha256` at fill time as PINS.txt prescribes.

### C (record, continue)
- C-BIND-1 Stale text: runner header L4 and step-1 comment L135 still say "port 55643"; README L6 says "port 55643"; runner L120 failure message still reads `prisma/schema.prisma != 77f33bcd` although SOURCE_READY-FINAL states it was fixed (the pin value `0eb41f9a…` is correct; message only). Fix when filling.
- C-BIND-2 `EXPECT_SCHEMA_SHA`/`EXPECT_PKG_LOCK_SHA` comments say "@1c5fbb04"; values are identical at 62471b11 (verified), so correct but should read 62471b11.
- C-BIND-3 Other-lane scan covers only `$CLUSTERS/*/`; the retained S8-F lane lives at `runtime/proof-s8f-v2` and is not hashed before/after. Liveness is still excluded by `pgrep -cx postgres = 0` and the port check; optional: include `proof-s8f-v2` in the pg_control hash scan.
- C-BIND-4 The 17 S8-F blob pins are in PINS.txt but not enforced by the runner loop; `EXPECT_TREE` pins them transitively. Optional: add them to the accepted-pin loop for symmetry.
- C-GATE-1 `gate/attempt-4/commit-attempt-1.raw.log` is the hook transcript of the single successful commit (name suggests a retry; there was none — `GIT_COMMIT rc=0` once).
- SOURCE_REVIEW_A C1–C8 stand unchanged (product bytes identical).

## Bindings for the parent

- Accept exactly `820ce85be2ebf994112afbb90739eb9469ad628e` / tree `7ede6dbb8f6f2d0ddcc349882a47ef67d415c32a` on parent `62471b11…`; product blobs `1a6db74e / fb728502 / 0a75e656 / b07ebb85`; 14 PATHS.
- Binding v1 may be filled and granted one run only after B-BIND-1 (real psql pin `d1108fdb…`), B-BIND-2 (`EXPECT_TESTS=19` + 1 suite), B-BIND-3 (regenerate the binding manifest) are applied; then fill the nine head pins from `BINDING-PINS-820ce85be2eb.txt` (fixture sha will change if the fixture is edited — it should not need to be; only the runner/PINS/manifest change).

---

## Binding re-review 1 (diff-only, after CLOSURES-BIND-1) — **GO for ONE run**

Read-only. Runner not executed, canonical lock not touched (inode read via `stat` only). Reviewer B not read.

### Identity of what was re-reviewed
`binding/v1/`: `s8g-pg-proof.sh` sha256 `4fccd1353edb47bfbeea0a7fab159660cee64f5356bccbf70280aba00705c40a` (216 lines), `s8g-fixture.sh` `62de28baa4ad3a669729aa33bebdb603b72642e9a41a2a57345b344093b3d24d`, `PINS.txt` `63c2122c275362706a8230e9e010d66dd39bbdacca36614e2083c9d634b985db`, `README.md` `9e04de132f5b375a0e598b0446bf74e92eb7f56fc95ec837eff4bbc827c30c18`; `BINDING.sha256` covers exactly these four and `sha256sum -c` passes 4/4. `history/s8g-pg-proof.sh.unfilled` is byte-identical to the template I reviewed (`b600ef12…`), and applying `CLOSURES-BIND-1.runner-from-reviewed-unfilled.diff` to it reproduces the filled runner exactly (`4fccd135…`), so the diff is the complete change. `bash -n` passes on runner and fixture. No `__FILL`, `/usr/bin/psql`, `a200e38c`, `77f33` or `55643 free` remains in runner/fixture/PINS (README keeps them only in its explicitly superseded "historical" section; PINS mentions `a200e38c` only to say it is no longer the pin).

### B-BIND-1..3 — closed
- **B-BIND-1 (psql):** `PSQL=/usr/lib/postgresql/18/bin/psql`, `EXPECT_PSQL_SHA=d1108fdb…`; precondition `[ -x $PSQL ] && sha == pin` plus `"$PSQL" --version` must match `^psql \(PostgreSQL\) 18\.`; `G2_S8G_PSQL=$PSQL`; `psqlq` and the PRECONDITIONS_OK log use `$PSQL`. Verified on disk: sha256 of that binary = `d1108fdb…`, `--version` = `psql (PostgreSQL) 18.6 (Ubuntu 18.6-0ubuntu0.26.04.1)`. Matches the S8-F v2 pattern. Closed.
- **B-BIND-2 (test count):** `EXPECT_TESTS=19`; after the rc gate: `grep -qE "^Tests: +19 passed, 19 total"` and `grep -qE "^Test Suites: +1 passed, 1 total"` on `jest.log`, else `fail 72` (STARTED=1 → bounded fixture stop). Verified `820ce85b:test/rls-g2-s8g.spec.ts` has exactly 19 top-level `it(`, 0 `it.each`, 0 skip/only/todo. Regexes match Jest's summary format and reject any `skipped`/`failed`/`todo` variant. Closed.
- **B-BIND-3 (manifest):** `BINDING.sha256` regenerated over the current four files; verified 4/4 OK. Closed.

### All filled pins verified against `820ce85b` objects, the runtime on disk, and the clone
| Pin | Verified |
|---|---|
| `EXPECT_HEAD` `820ce85b…` / `EXPECT_TREE` `7ede6dbb…` | = clone `HEAD` / `HEAD^{tree}` |
| `BASE_HEAD` `62471b11…` / `BASE_TREE` `23614f0b…` | = `62471b11^{tree}`; base is the sole parent |
| 6 S8-G proof blobs (spec `86a944c1`, bootstrap `2ab85a13`, db `c654e6bd`, pgh `a0261246`, harness `ee2a41a2`, worker `65ee972d`) | all = `HEAD:<path>` |
| 37 accepted-file blob pins in the runner loop (20 S7-L/S8-C/base incl. `package-lock.json 354de3da` + 17 S8-F) | 37/37 = `HEAD:<path>` |
| `EXPECT_FIXTURE_SHA` `62de28ba…` | = sha256 of the current `s8g-fixture.sh` (pre-BIND-1 fixture `b2dd548a…` differs by one comment line only) |
| `EXPECT_PSQL_SHA` `d1108fdb…` | = `/usr/lib/postgresql/18/bin/psql` |
| `EXPECT_POSTGRES/INITDB/PGCTL_SHA` | = `runtime/pg17/dist/bin/{postgres,initdb,pg_ctl}`; `PROVENANCE.txt result=success` |
| `EXPECT_NODE_SHA` | = resolved `node` (v20.20.1) |
| `EXPECT_NM_LOCK_SHA` / `EXPECT_NM_CLIENT_SHA` | = clone `node_modules/.package-lock.json` / `.prisma/client/index.d.ts` (isolated real directory inside the clone, not a symlink) |
| `EXPECT_SCHEMA_SHA` / `EXPECT_PKG_LOCK_SHA` | = clone `prisma/schema.prisma` / `package-lock.json` (= base objects) |
| `EXPECT_TESTS=19`, `EXPECT_MIGRATIONS=172` | = 19 `it(`; 172 migration directories at HEAD |
| `EXPECT_LOCK_INODE=667698` | = `stat -c %i execution/test-validation.lock`; asserted before `exec 9>>; flock -n` |
PINS.txt and the runner agree on every one of the 23 named pins (compared programmatically).

### Runner ↔ fixture consistency
Both: `RUNTIME_ROOT=/home/user/workspace/execution/1910a060/runtime` (real path, exists), `LANE=$RUNTIME_ROOT/clusters/s8-g`, `DATA=$LANE/pg-data`, `SOCK=$RUNTIME_ROOT/run/s8-g`, `PORT=55644`, superuser `s8g_super`, `MARKER=s8g-disposable-pg17` (= `G2_S8G_CLUSTER_MARKER` in the committed guard). Runner exports `G2_S8G_DATA_DIRECTORY=$LANE/pg-data` and asserts `SHOW data_directory`; INIT/START marker greps match the fixture's echo lines; fixture refuses standalone use unless `/proc/$S8G_RUNNER_PID/cmdline` contains `s8g-pg-proof.sh` (the filled file name matches). Current state (read-only): `runtime/clusters` and `runtime/run/s8-g` absent (fresh-lane preflight will pass), port 55644 has no listener, `pgrep -cx postgres` = 0, clone clean with no `MERGE_HEAD`.

### No weakening, no new A/B
Stage order and bounds, once-only sentinel (76), first-failure stop with bounded fixture stop, data-dir retention, marker-gated destroy, the single jest command (`--config jest.rls.config.js test/rls-g2-s8g.spec.ts --runInBand --ci`, once) and all post checks are unchanged. Changes are strictly additive or tightening: lock-inode assertion, real-psql pin + version check, test-count assertion, 18 additional accepted blob pins, other-lane scan extended to `$RUNTIME_ROOT/proof-*/clusters/*/` (covers the retained S8-F lane `proof-s8f-v2/clusters/s8-f`, which exists) with the own-lane skip by full path (`${d%/} != $LANE`), `EXPECT_MIGRATIONS` used in the identity check, stale text corrected. My C-BIND-1..4 are all addressed.

### C (record only)
- C-RR-1 README's "Original v1 notes" section still mentions `.unfilled` files, base 1c5fbb04 and port 55643; it is labelled historical/superseded at the top, so no action required.
- C-RR-2 Unmatched globs in the other-lane loop stay literal under `set -u` without `nullglob`; `[ -d "$d" ] || continue` handles them (no failure path).

**Verdict: binding v1 as frozen in `BINDING.sha256` (runner `4fccd135…`, fixture `62de28ba…`, PINS `63c2122c…`, README `9e04de13…`) — GO for ONE run under the parent's single-run PG grant.**
