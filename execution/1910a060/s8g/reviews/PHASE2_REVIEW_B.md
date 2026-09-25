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
