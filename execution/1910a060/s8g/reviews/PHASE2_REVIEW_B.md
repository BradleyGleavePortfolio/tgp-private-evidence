# S8-G phase-2 review B (T4 independent, read-only) — committed head 820ce85b + binding v1

Reviewer B, execution 1910a060, 2026-09-25 ~15:30 PDT. Continues `SOURCE_REVIEW_B.md` (same reviewer). Reviewer A's
output was not read. Method: read-only git inspection of `/home/user/workspace/worktrees/1910a060-s8g`
(`GIT_OPTIONAL_LOCKS=0`; `cat-file`, `rev-parse`, `ls-tree`, `diff`, `show`), sha256 of evidence files, and a token-level
comparison of the committed test files against the reviewed candidate reconstructed in a scratch tree outside the
workspace. No npm, jest, prettier, lock, install or remote action.

## Verdicts

- **FINAL GO for exactly `820ce85be2ebf994112afbb90739eb9469ad628e`** (tree `7ede6dbb8f6f2d0ddcc349882a47ef67d415c32a`,
  sole parent `62471b116267fdec6746073c4b4c80a154d09834`). Product blobs are byte-identical to the SOURCE GO review;
  every non-formatting test delta is accounted for and none weakens an assertion; gate receipts are genuine and complete;
  hooks ran; Bradley identity; no trailers; exactly 14 PATHS. No class A or B against the commit.
- **Binding v1: NO-GO as drafted; GO-for-one-run-after-fill once B3 and B4 below are closed** (two small runner edits,
  both at the pin-fill step, no source change). My earlier B2 (LANE) and C1 (port) are closed; RUNTIME_ROOT, cluster
  marker, PG 17.6 pins, once-only sentinel, `flock -n` on inode 667698 and the bounded stop are correct.

## 1. Commit identity (verified read-only)

| Check | Result |
|---|---|
| `git cat-file -p 820ce85b` | tree `7ede6dbb…`, single `parent 62471b11…`, author = committer = `Bradley Gleave <bradley@bradleytgpcoaching.com>`, 1790375226 +0000 (2026-09-25T22:27:06Z) |
| Trailers | none (`Signed-off-by`, `Co-authored-by`, AI/tool tokens absent); message equals `gate/commit-message.txt` byte-for-byte |
| Worktree at review time | HEAD = 820ce85b; `git status --porcelain --untracked-files=all` empty |
| `git diff --name-status 62471b11 820ce85b` | exactly 14 paths: 2 M (`src/scout/lifecycle/lifecycle.service.ts`, `src/scout/scout-reconstruct.service.ts`), 12 A; `test/utils/g2-s8g-bootstrap.sh` mode 100755 |
| Blob sha1s at 820ce85b | all 14 equal `build/final-blob-hashes-820ce85b.txt` and the attempt-4 `STAGED_BLOB` log lines |
| **Product blobs** | `lifecycle.service.ts` `1a6db74e`, `scout-reconstruct.service.ts` `fb728502`, `family-plan.ts` `0a75e656`, `run-context.ts` `b07ebb85` — **identical to the blobs pinned in SOURCE_REVIEW_B.md**; SOURCE GO carries verbatim |
| Final patch | `git diff --binary 62471b11 820ce85b` sha256 `36b53f0c8d2efb1afa5d3e840a8ad7a9c32deb03ed3f440ada338fa7926a45dd` = `gate/attempt-4/s8g-a4-62471b116267-to-820ce85be2eb.patch` |
| Evidence checksums | `build/FINAL.sha256` verifies OK for `SOURCE_READY-FINAL.md`, `final-blob-hashes-820ce85b.txt`, `delta-reviewed-to-820ce85b.patch` |
| Unchanged at head | `prisma/schema.prisma` blob `2e328bbc` (sha256 `0eb41f9a…`), `package-lock.json` sha256 `b7fed5ed…`, `jest.config.js` `769a4146`, `jest.rls.config.js` `44c96915`; 19 accepted S7-L/S8-C pins in the runner loop all match at 820ce85b; all 17 S8-F blobs listed in `PINS.txt.unfilled` match at both 62471b11 and 820ce85b |
| Base-pin retarget | `G2_S8G_BASE_HEAD` (db.ts L135), bootstrap `BASE_HEAD` (L27) = `62471b11…`; `EXPECTED_MIGRATIONS = 172`; guard spec asserts the three pins are identical |

## 2. Test deltas: reviewed candidate → committed head

Reviewed tree = 62471b11 blobs + `build/s8g-candidate-62471b11.patch` (applies cleanly). Comparison against
`820ce85b` blobs, per file, with a tokenizer that ignores whitespace, line breaks, quote style and trailing commas (i.e.
everything Prettier changes):

| File | Token delta | Content |
|---|---|---|
| 4 product `src/**` | none (byte-identical) | — |
| `test/rls-g2-s8g.spec.ts` | **0** | formatting only; still 19 `it` blocks, no `skip`/`only` |
| `test/scout/orchestration/family-plan.spec.ts` | 0 | formatting only |
| `test/scout/orchestration/settle-hook.spec.ts` | 0 | formatting only |
| `test/utils/{g2-s8g-bootstrap.sh,g2-s8g-harness.ts,g2-s8g-pg-harness.ts,g2-s8g-worker.cjs}` | 0 (byte-identical) | — |
| `test/scout/orchestration/reconstruct-run.spec.ts` | FIX-1: `(s as Record<string,unknown>)[k]` → `s[k as keyof Staged]` (FakePrisma `select` helper; behaviour identical, no banned cast token). FIX-2: inline fixture spec gains `clientSourceId: { paths: [['client_id']], coerce: 'string_or_finite_number' }` for programs/workouts/client_history (parser requires it; fixture correctness, not an expectation change). Nothing else. | no weakening |
| `test/utils/g2-s8g-db.ts` | `'55643'` added to `REFUSED_PORTS` (now 16 entries incl. 55641/55642/55643); comment updated (55644 suggested). | closes C1 |
| `test/scout/g2-s8g-db-guard.spec.ts` | fixture URL/ack/port/maintenance/password URLs 55643 → 55644; **one refused case added** (`base.replace('55644','55643')`); mismatched-ack case now `g2_s8g_disposable:55643`; foreign-db ack cases use `:55644`; two Prettier reflows. `it` count 7 → 7, `expect(` count 62 → 62 plus the added refused entry in the array-driven loop. | no weakening |

No `it.skip`, `it.only`, `xit`, `describe.skip` or `describe.only` in any of the 14 files at 820ce85b.
Conclusion: the committed tests are the reviewed tests plus three disclosed, minimal, non-weakening changes (FIX-1,
FIX-2, C1 fold-in) and Prettier formatting.

## 3. Gate receipts (`gate/attempt-4/`)

- `gate.log`: `ACQUIRED pid=21509 fd9 inode=667698 waited=0s lslocks=1` at 22:15:23Z → `RELEASING stage=done rc=0` at
  22:27:57Z; `TERMINAL` = `RC=0 STAGE=done END=2026-09-25T22:27:57Z`. Single continuous run; lock file preserved.
- Node v20.20.1, npm 10.8.2; donor `node_modules` (S8-F worktree, hidden lock `05bc530a…`, client `index.d.ts`
  `9042e713…`) reused as an isolated copy; lefthook 2.1.9 hooks verified against the S8-F reference (normalized hashes
  equal) and pointing at the clone's own lefthook binary.
- `PRETTIER_CHECK_1 rc=0` (no rewrites needed — the tree was already formatted from attempt 1), `POSTFORMAT` sha256 of
  all 14 files equal their pre-format sha256 and the final blobs; `ESLINT rc=0`; `TSC rc=0 lines=0`.
- `JEST_TARGETED rc=0`: 4 suites / 86 tests. `JEST_FULL rc=0`: `Test Suites: 12 skipped, 577 passed, 577 of 589 total`,
  `Tests: 159 skipped, 5 todo, 9111 passed, 9275 total`, 6 snapshots, 634 s. `test/scout/g2-s8g-db-guard.spec.ts` PASS
  appears in the full log; `rls-g2-s8g` correctly did not run (excluded by default `testPathIgnorePatterns`).
- **Skipped suites are pre-existing:** the same `12 skipped / 159 skipped / 5 todo` figures appear in accepted prior
  gates — S7-L CI `12 skipped, 567 passed, 567 of 579`, S8-C CI `12 skipped, 571 passed … of 584`, NQ1 `12 skipped, 558
  passed … of 570`. Suite total 585 at 62471b11 + 4 new default-run S8-G suites = 589. The 18 spec files at 62471b11
  using `describe.skip`/conditional-describe patterns (community e2e/RLS live suites, `scout-entities.rls.live.spec.ts`,
  `test/rls/*`) are the population from which those 12 come; none is an S8-G file.
- Commit step: lefthook pre-commit `prod-readiness-quick`, `banned-cast-tokens`, `prettier`, `eslint`, `tsc` all ✔ (48 s);
  commit-msg `no-ai-tokens` ✔; `GIT_COMMIT rc=0` exactly once; `HEAD=820ce85b… TREE=7ede6dbb… parent=62471b11…`.
  `commit-attempt-1.raw.log` is the raw lefthook output of that single commit, not a second attempt.
- History (attempt 1 rc 73 tsc → FIX-1 → attempt 2 rc 73 targeted jest → FIX-2 → dev loop → attempt 3 aborted by the
  builder pre-commit → attempt 4 rc 0) is fully preserved with `TERMINAL`/`SHA256SUMS`/`freeze/` per attempt.

### Disclosed unlocked dev-loop iteration 1 — does it matter?

`dev-loop/hold.out`: `HELD 22:09:46Z` then `RELEASED 22:09:52Z` (holder killed with its tool shell); `iter-1.jest.log`
(4 suites / 85 tests, rc 0, ≈22:09:58Z) therefore ran with no lock held. Assessment: **immaterial to the commit's
evidence.** It was a read-only targeted jest run producing no edits and no state that any later receipt depends on;
`lslocks` showed no other holder, so no concurrent heavy run was disturbed; iteration 2 (86/86) and attempt 4 (86/86
targeted + full suite + commit) re-established every result under the held lock. Recorded as class C (process
disclosure, honest and complete); no closure required.

## 4. Binding v1 (`binding/v1/`, unfilled, unrun)

Verified against the files as of 22:17Z (`s8g-pg-proof.sh.unfilled` 21771 B, `s8g-fixture.sh` sha256 `b2dd548a…`,
`PINS.txt.unfilled`), the runtime receipt `execution/1910a060/runtime/RUNTIME_SETUP_RECEIPT.md`, the binaries, and the
accepted S8-F v2 runner as precedent.

| Item | Status |
|---|---|
| LANE / marker runner↔fixture | runner L50 `LANE=$CLUSTERS/s8-g`, fixture L26 `LANE=$RUNTIME_ROOT/clusters/s8-g`; `SOCK=$RUNTIME_ROOT/run/s8-g` in both; marker `s8g-disposable-pg17` in fixture init/start/destroy, runner `FIXTURE_INIT` grep, runner identity step, bootstrap and `g2-s8g-db.ts`. **B2 closed.** Own-lane skip present in both other-lane scans (preflight and post). |
| RUNTIME_ROOT | both `/home/user/workspace/execution/1910a060/runtime` (exists: `pg17/`, `tools/`, `npm-cache/`, `xdg-cache/`, `proof-s8f-v2/`); no reference to `execution/64e33dc7/recovery-reset`. OK |
| PORT / refused set | runner + fixture `PORT=55644`; committed guard refuses 55641/55642/55643; guard spec exercises all three. **C1 closed.** (Stale comment L135 still says "port 55643 free" — cosmetic.) |
| BASE pins | `BASE_HEAD=62471b11…`, `BASE_TREE=23614f0b…` (verified `rev-parse 62471b11^{tree}`); ancestry, prisma-tree-equal-to-base, package manifests, 19 accepted S7-L/S8-C blob pins — all match 820ce85b. |
| 17 S8-F blobs at 62471b11 | listed in `PINS.txt.unfilled` L67–90 and all 17 verified equal at 62471b11 and 820ce85b — **but not enforced by the runner** (the accepted-pin loop contains only the 19 S7-L/S8-C entries). Mitigated by `EXPECT_TREE` (whole-tree pin) → class C, see C3. |
| PG 17.6 pins | `postgres` `23cd1748…`, `initdb` `b7db9bc2…`, `pg_ctl` `af53d826…` equal the receipt and the binaries on disk; `--version` must end `17.6`; identity step requires `server_version_num=170006`; `pg17/PROVENANCE.txt result=success` present. OK |
| Node pin | `a03953a7…` equals `readlink -f /usr/local/bin/node` sha256. OK |
| **psql pin** | `EXPECT_PSQL_SHA=a200e38c…` = sha256 of `/usr/share/postgresql-common/pg_wrapper` (a Perl script; `readlink -f /usr/bin/psql`), and the runner exports `G2_S8G_PSQL=/usr/bin/psql` and uses `/usr/bin/psql` in `psqlq`. The real client `/usr/lib/postgresql/18/bin/psql` is `d1108fdb45b87f2313d7acfbb91a0a65ca97c6c2195f15d8ae9295121029ef67`, which is what the receipt (L50) and the accepted S8-F v2 runner (`EXPECT_PSQL_SHA=d1108fdb…`, `$PSQL`) pin. **B3.** |
| Expected Tests count | runner logs the `Tests:` line and checks only `JRC=0`; no `EXPECT_TESTS` assertion. S8-F v2 precedent: `EXPECT_TESTS=11` + `grep -qE "^Tests: +11 passed, 11 total"`. The committed spec has **19** `it` blocks. **B4.** |
| Once-only sentinel | `[ -e "$SENT" ] && … exit 76`; sentinel written by `finish` with `RC/STAGE/END/HEAD/LOCK_INODE`. OK |
| Canonical lock | `LOCK=/home/user/workspace/execution/test-validation.lock` must pre-exist (exit 75), `exec 9>>"$LOCK"; flock -n 9` (exit 75), inode logged at preflight/post/sentinel; fixture refuses standalone use unless `S8G_RUNNER_PID` is a live runner. OK |
| Bounded stop | `timeout -k 30 75 bash "$FIX" stop` with `S8G_STOP_TIMEOUT=45` (`pg_ctl -m fast -w -t 45`), survivor detection via `postmaster.pid`, then `pgrep -cx postgres = 0`, port listeners = 0, `postmaster.pid` absent, data dir retained; cleanup path on failure uses the same stop with a 60 s bound. Stage sum 60+60+900+75+1500+75 ≈ 2670 s < 3600 s outer. OK |
| Head pins | nine `__FILL_AFTER_ATTESTATION__` placeholders refuse execution; `gate/attempt-4/BINDING-PINS-820ce85be2eb.txt` values verified: HEAD/TREE, spec `86a944c1`, bootstrap `2ab85a13`, db `c654e6bd`, pgh `a0261246`, harness `ee2a41a2`, worker `65ee972d`, fixture sha256 `b2dd548a…` (matches the file on disk). Ready to fill. |
| Guard interplay | runner `G2_S8G_CONFIRM=g2_s8g_disposable:55644`, URL `s8g_super@127.0.0.1:55644/g2_s8g_disposable?schema=public&connection_limit=4` — accepted by the committed guard (55644 not refused, `connection_limit ≤ 10`). OK |

## 5. Findings

### Class A
None.

### Class B — binding only (the commit itself has none)

**B3 — psql pin is the pg_wrapper script, not the client binary.**
Harm: the proof's psql provenance is a version-selecting Perl wrapper; which client actually executed the fixture SQL is
not pinned, and the receipt's own "real psql" pin (`d1108fdb…`) is not what the runner checks. Decision blocked:
granting the one PG run with unattested client identity. Minimum closure (runner only, at pin fill):
`PSQL=/usr/lib/postgresql/18/bin/psql`; `EXPECT_PSQL_SHA=d1108fdb45b87f2313d7acfbb91a0a65ca97c6c2195f15d8ae9295121029ef67`
checked as `[ -x "$PSQL" ] && [ "$(sha "$PSQL")" = "$EXPECT_PSQL_SHA" ]`; `export G2_S8G_PSQL=$PSQL`; `psqlq` and the
`PRECONDITIONS_OK` version line use `"$PSQL"`. (The committed bootstrap/harness take the path from `G2_S8G_PSQL`, so no
source change.)

**B4 — no expected-test-count assertion.**
Harm: `JRC=0` alone cannot distinguish "19 cases passed" from a partially collected file; the accepted S8-F binding made
this assertion mandatory. Decision blocked: accepting a proof whose receipt does not state the case count. Minimum
closure: `EXPECT_TESTS=19` (equals the `it` count in `test/rls-g2-s8g.spec.ts` at 820ce85b) and, after `JEST_END`,
`grep -qE "^Tests: +$EXPECT_TESTS passed, $EXPECT_TESTS total" "$JLOG"` and `grep -qE "^Test Suites: +1 passed, 1 total"`
→ `fail` otherwise, logging `JEST_COUNT_OK`.

### Class C (recorded; not blocking)

- **C1 (from SOURCE_REVIEW_B) closed** in source (`'55643'` refused; 55644 suggested) and binding (`PORT=55644`).
- **C2 dev-loop iteration 1 ran without the canonical lock** — disclosed, read-only, superseded by locked re-runs; no
  effect on any attested result.
- **C3 17 S8-F blob pins not enforced by the runner** (present in `PINS.txt.unfilled` only). Covered by `EXPECT_TREE`;
  recommended cheap hardening at fill time: add `[ "$(git -C "$W" diff --name-only "$BASE_HEAD" HEAD | sha256sum …)" = <sha of the 14-path manifest> ]`
  or the 17 pins to the loop. SOURCE_READY-FINAL says "20 accepted pins"; the runner loop has 19.
- **C4 cosmetic runner text**: L135 comment "port 55643 free" (PORT is 55644); schema mismatch message says `!= 77f33bcd`
  while the pinned schema blob is `2e328bbc` (SOURCE_READY-FINAL claims this was fixed; it was not). Log text only.
- **C5** `EXPECT_SCHEMA_SHA`/`EXPECT_PKG_LOCK_SHA` comments still say `@1c5fbb04`; values are unchanged at 62471b11 and
  820ce85b (verified), so correct in substance.
- All class C items from SOURCE_REVIEW_B (deadline bounds the pass, S7-L clock/deadline windows, no phase predicate on
  `assertRunOpen`, unisolated `ProvenanceConflict` in the unmapped path, `RUN_FAMILY_ORDER`-covers-registry assertion,
  builder F3/F4/F9, worker 90 s timer) stand unchanged; product bytes did not move.

## 6. Order of operations recommended

1. Apply B3 and B4 (and optionally C3/C4) to `s8g-pg-proof.sh.unfilled`; `bash -n`; record the template→filled diff and
   sha256 in `BINDING.sha256`.
2. Fill the nine pins from `gate/attempt-4/BINDING-PINS-820ce85be2eb.txt` (already verified against 820ce85b; refill
   `EXPECT_FIXTURE_SHA` only if `s8g-fixture.sh` changes — it need not).
3. Independent attestation of the filled runner, then the separate single-run PG grant.

## 7. Evidence read

`worktrees/1910a060-s8g` git objects (`820ce85b`, `62471b11`, `1c5fbb04`); `s8g/build/{SOURCE_READY-FINAL.md,
final-blob-hashes-820ce85b.txt,FINAL.sha256,delta-reviewed-to-820ce85b.patch,s8g-candidate-62471b11.patch}`;
`s8g/gate/{DEV-LOOP.md,FIX-1.md,FIX-1.diff,FIX-2.md,FIX-2.diff,commit-message.txt,dev-loop/*,attempt-3/ABORTED,
attempt-4/*}`; `s8g/binding/v1/*`; `execution/1910a060/runtime/RUNTIME_SETUP_RECEIPT.md`;
`execution/64e33dc7/s8f/binding/v2/s8f-pg-proof.sh` (precedent, read-only); prior gate summaries under
`execution/daceddc8/landing/ci/*` and `execution/cf8ff737/nq1*` (skipped-suite baseline); system binaries
`/usr/share/postgresql-common/pg_wrapper`, `/usr/lib/postgresql/18/bin/psql`, `pg17/dist/bin/*`, `/usr/local/bin/node`
(sha256 only).

---

## Binding re-review 1 (diff-only, after CLOSURES-BIND-1) — reviewer B, 2026-09-25 ~15:50 PDT

**Verdict: GO for ONE run** of `binding/v1/s8g-pg-proof.sh` sha256 `4fccd1353edb47bfbeea0a7fab159660cee64f5356bccbf70280aba00705c40a`
with fixture `62de28baa4ad3a669729aa33bebdb603b72642e9a41a2a57345b344093b3d24d`, under the parent's separate single-run
PG grant. No class A or B remains. Nothing was executed here (`bash -n` only; the canonical lock was not touched; only
`stat` on the lock file).

### What was checked (read-only)

| Check | Result |
|---|---|
| `BINDING.sha256` | `sha256sum -c` OK for runner `4fccd135…`, fixture `62de28ba…`, `PINS.txt` `63c2122c…`, `README.md` `9e04de13…` (values as mailed). `bash -n` OK for runner and fixture. |
| Diff scope | `CLOSURES-BIND-1.runner-from-reviewed-unfilled.diff` (reviewed template → filled runner) contains only: header/comment text, the nine head pins, `PSQL`/`EXPECT_PSQL_SHA`/`EXPECT_TESTS`/`EXPECT_MIGRATIONS`/`EXPECT_LOCK_INODE` additions, lock-inode refusal, 18 added blob pins in the accepted-file loop, `$PSQL` substitution (3 sites), psql major-version check, B4 count block, other-lane scan widened to `proof-*/clusters/*/`, stale texts fixed. No stage, bound, sentinel, sentinel-write, `fail`/`finish`, jest command or fixture-stop line changed. Fixture delta vs `history/s8g-fixture.pre-BIND-1.sh`: header text and `PORT=55643→55644` only. `PINS.txt` delta: nine fills + the new pin lines + 17 S8-F entries; no removed pins. |
| **B3 closed** | `PSQL=/usr/lib/postgresql/18/bin/psql`; `EXPECT_PSQL_SHA=d1108fdb…` = sha256 of that binary on disk (re-measured); `"$PSQL" --version` = `psql (PostgreSQL) 18.6 (Ubuntu 18.6-0ubuntu0.26.04.1)` matches `^psql \(PostgreSQL\) 18\.`; `G2_S8G_PSQL=$PSQL` exported; `psqlq()` and `PRECONDITIONS_OK` use `"$PSQL"`; `/usr/bin/psql` no longer appears anywhere in runner or fixture. |
| **B4 closed** | `EXPECT_TESTS=19`; committed spec `820ce85b:test/rls-g2-s8g.spec.ts` has 19 top-level `it(` and no `it.each`/`test(`/`.skip`/`.only`/`it.todo` (the two regex hits are `.test(q)` on RegExp objects in helpers, not jest modifiers). Count block sits after `[ $JRC = 0 ] || fail $JRC`, before fixture-stop: `^Tests: +19 passed, 19 total` and `^Test Suites: +1 passed, 1 total`, else `fail 72` with the actual line logged; `JEST_COUNT_OK` logged. |
| Nine head pins | `EXPECT_HEAD` = `rev-parse 820ce85b`; `EXPECT_TREE` = `820ce85b^{tree}` `7ede6dbb…`; spec `86a944c1`, bootstrap `2ab85a13`, db `c654e6bd`, pg-harness `a0261246`, harness `ee2a41a2`, worker `65ee972d` all equal `rev-parse 820ce85b:<path>`; `EXPECT_FIXTURE_SHA=62de28ba…` = sha256 of the shipped `s8g-fixture.sh` (correctly re-pinned to the post-BIND-1 fixture rather than the gate-time `b2dd548a…`). `BASE_HEAD 62471b11` / `BASE_TREE 23614f0b` verified; placeholder `case *__*` refusal retained (no `__FILL` left in runner or PINS). |
| Runtime/tool pins vs disk | postgres `23cd1748…`, initdb `b7db9bc2…`, pg_ctl `af53d826…` (runtime `pg17/dist/bin`), node `a03953a7…` (`readlink -f /usr/local/bin/node`), `node_modules/.package-lock.json` `05bc530a…`, `.prisma/client/index.d.ts` `9042e713…` (real dir in the s8g worktree, populated by the gate), `prisma/schema.prisma` `0eb41f9a…`, `package-lock.json` `b7fed5ed…` — all equal on this host. `EXPECT_MIGRATIONS=172` matches guard/bootstrap; identity check now uses the variable. |
| Accepted-file loop | 37 `"path blob"` pins (19 S7-L/S8-C + `package-lock.json 354de3da` + 17 S8-F) — every one equals `820ce85b:<path>`. Prior C3 closed. |
| Runner↔fixture | `RUNTIME_ROOT` identical; runner `LANE=$CLUSTERS/s8-g`, fixture `LANE=$RUNTIME_ROOT/clusters/s8-g`; `SOCK=$RUNTIME_ROOT/run/s8-g` both; `PORT=55644` both (accepted by the committed guard; 55641/55642/55643 refused); marker `s8g-disposable-pg17` both; `ADMIN/SUPER=s8g_super`, same synthetic password; `DBNAME=g2_s8g_disposable`, confirm `g2_s8g_disposable:55644`. Fixture still refuses standalone use unless `S8G_RUNNER_PID` is a live `s8g-pg-proof.sh`. |
| Sentinel / lock | `SENT` exists → exit 76 (once-only); lock absent → 75; **new**: `stat -c %i "$LOCK"` must equal `EXPECT_LOCK_INODE=667698` (verified: current inode 667698) → 75; then `exec 9>>"$LOCK"; flock -n 9` → 75 if busy. `finish` writes `RC/STAGE/END/HEAD/LOCK_INODE` to the sentinel and holds fd 9 to exit. Unchanged from the reviewed template apart from the inode assertion (strictly tighter). |
| Bounded stop | unchanged: `S8G_STOP_TIMEOUT=45`, `timeout -k 30 75 bash "$FIX" stop`, failure path `timeout -k 30 60 … stop`, survivor detection, data dir retained; stage bounds 60/60/900/15×n/1500/75 inside the documented `timeout -k 30 3600` outer. `set -uo pipefail` same as the template and the accepted S8-F v2 runner (explicit `fail` handles cleanup). |
| Other-lane scan | widened to `$CLUSTERS/*/` and `$RUNTIME_ROOT/proof-*/clusters/*/`, skipping only `$LANE`; verified `runtime/proof-s8f-v2/clusters/s8-f` exists and `runtime/clusters` does not yet (glob-guarded by `[ -d ]`). S8-F lane is now recorded-and-never-started as intended. |
| Preflight state now | no `postgres` process, no listener on 55644, `runtime/run` and `binding/v1/run` absent — runner would pass its lane-absent preflight. |
| Stale text | `77f33bcd`, `55643 free`, `/usr/bin/psql`, `s8-c` all absent from runner and fixture. Prior C4/C5 closed. |
| Weakening | none: no assertion removed or loosened; only additions (inode, psql version, test count, 18 blob pins, wider lane scan). |

### Findings

- Class A: none. Class B: none (B3, B4 closed; B-BIND-1..3 as recorded by the builder are consistent with what I verified).
- Class C (record only, no closure needed before the run):
  - **C6** `history/BINDING.sha256.unfilled` attests the template; the final `BINDING.sha256` covers the four shipped files. The template→filled diff itself is attested only via this record and `CLOSURES-BIND-1.md`'s sha table — acceptable; the diff files' sha256 (runner-from-reviewed `23196b1e…`, runner `b1a2430e…`, fixture `ccfd79b3…`, pins `0bc4e6c4…`, md `1978aa9a…`) are noted here for the archive.
  - **C7** `EXPECT_FIXTURE_SHA` differs from `gate/attempt-4/BINDING-PINS-820ce85be2eb.txt` (`b2dd548a…`) because the fixture header/PORT text moved after the gate; the shipped fixture is the one pinned, so this is correct, but the grant record should cite `62de28ba…`, not the gate-time value.
  - **C8** The runner's `[ $JRC = 0 ]` check precedes the count check, so a jest exit 0 with a wrong count fails as 72 (correct); a jest exit ≠ 0 still surfaces the `Tests:` line via the pre-existing `grep -E '^(Test Suites|Tests…)'` tee — sufficient.

### Grant conditions restated
Run exactly once as `timeout -k 30 3600 bash execution/1910a060/s8g/binding/v1/s8g-pg-proof.sh` on this host with the
canonical lock free (inode 667698), worktree at 820ce85b and clean, no `postgres` running; accept only a sentinel with
`RC=0 STAGE=done` plus `JEST_COUNT_OK tests=19 suites=1` and `FIXTURE_STOP rc=0` in the log; destroy of the retained
data dir remains a separate grant.
