# S7-3′ B/drain — same-review binding of frozen v4 (single fresh-fake hunk + new pins only)

Reviewer A, continuation of `B_DRAIN_V3_BINDING_REVIEW_A.md` (immutable). Read-only git/blob comparisons and file reads only; no env, hooks, gates, commit, PG, index writes. Peer B unread. The ten unchanged files and all Class C items are not reopened.

## 0. Disposition

**v4 tree `f4922ca070e887fb7f613ce955b12621b5c33156` is SOURCE_GRANTABLE for phase A (source-only).** The only defect open after v3 (FB-3 = B-BD-FRESH-FAKE) is closed by exactly the agreed minimum hunk; nothing else changed. No A/B finding remains against the source. Actual head/pin binding and the PG run remain later, separate grants.

## 1. Pins independently recomputed

| Item | Result |
|---|---|
| Base | HEAD `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992`, tree `87798e742c7b48f56b05e9b5c30efa877180a9b3`; tracked unmodified; index clean; 0 non-sample hooks; no `node_modules` |
| v4 tree | `f4922ca070e887fb7f613ce955b12621b5c33156` exists as a tree object; working files == v4 blobs and modes for all 11 paths (`verify/v4-blobs.git-sha1` == `verify/v4-wt-blobs.git-sha1`); == `frozen-v4/BLOBS.git-sha1`; `frozen-v4/files/...spec.ts` byte-equal; `SOURCE.sha256` 11/11; `PACKET.v4.sha256` all OK |
| v4 vs v3 | exactly one `M`: `src/scout/scout-ledger-backfill.spec.ts` `3a97093a…` → `5477059a152a04a1fa9a117e3c1d184259ac3341`, mode 100644→100644; the other 10 paths have identical blob ids and modes (`git ls-tree` diff shows only that line); recomputed `diff-tree -p` byte-equal to `frozen-v4/v3-to-v4.diff` (11 changed lines) |
| v4 vs base | 11 `A`, +2323; recomputed diff byte-equal to `frozen-v4/b-drain.v4.diff` |
| S5 donors | `0e73d76d`, `ab9aaab4`, `85a636ba`, `4fed8bcd`, `b9080538` identical at HEAD and in the v4 tree |
| Formatter | Builder reports Prettier `--check` pass with no `--write`; consistent with the hunk (no format-only delta to reconcile) |

## 2. The hunk (spec lines 270-280)

Replaces the reuse of the drained shared `db` with `const fresh = new FakeLedger([row('a')]); fresh.fenced = true; fresh.faults = ['lock'];`, runs `backfillLedgerPlatform(fresh, { batch: 500, lockRetries: 0 })`, and retargets the counter assertion to `fresh.transactions`. Assertion set otherwise unchanged (one pass `{chunks 0, lockFailures 1, stalledByLocks true}`, outcome `'stalled'`). No case added/removed; comment updated.

Static trace against the library: `row('a')` is `{platform: null, matches 1, staged 'truecoach'}`; `readDrainState` uses `$queryRaw` directly (not counted); pass 1 → `runChunk` → `$transaction` (count 1) throws the injected 55P03 → `isLockOrStatementTimeout` true → attempt loop `0 <= 0` ends → `lockFailures 1`, `stalledByLocks true`, `chunks 0` → loop breaks → after: `nulls 1`, `fenced true`, unresolved 0 → `decideOutcome` = `'stalled'`; `fresh.transactions === 1`. All four expectations hold; one-attempt semantics is what the real phase-A jest settles.

## 3. Phase-A requirements with v4 pins substituted (already agreed; unchanged otherwise)

Source/grant for env reuse and hooks (no PG): isolated copy of the accepted C1 `node_modules` into the worktree + verification against C1 records (`.package-lock.json 05bc530a…`, `.prisma/client/index.d.ts bf679a16…`) → `./node_modules/.bin/lefthook install` (record `.git/hooks/pre-commit`, `commit-msg`) → `tsc --noEmit -p tsconfig.json`; `eslint --no-warn-ignored --max-warnings 0` and `prettier --check` on the 8 TS files; `node scripts/check-r75.js --mode=staged` with the 11 v4 paths staged; `jest src/scout/scout-ledger-backfill.spec.ts test/scout/g2-b-drain-db-guard.spec.ts` → ordinary Bradley-authored commit through the installed hooks whose tree must equal **`f4922ca070e887fb7f613ce955b12621b5c33156`** → pins.

## 4. Later pin binding (before any PG run)

Fill `fixture-proposal-v3/binding/b-pg-proof.sh`: `EXPECT_HEAD` = committed head; `EXPECT_TREE` = `f4922ca070e887fb7f613ce955b12621b5c33156`; `EXPECT_SPEC_BLOB` = `9b31fd1813d25a1624ab04666e0b1be4743277ab` (`test/rls-g2-b-drain.spec.ts`, unchanged since v3); `EXPECT_BOOTSTRAP_BLOB` = `b4503eef525baa531eedb148f47828db3a4ade6f`; `EXPECT_FIXTURE_SHA` = sha256 of the unchanged `b-fixture.sh`. Preconditions in the template already pin the five S5 donors and lefthook hooks. Then a single run under a separate PG grant with outer `timeout -k 30 3600`; reviewer A binds `RECEIPTS.sha256`, jest summary, sentinel and survivor/listener evidence. Unit-spec blob at v4 is `5477059a…` (not pinned by the template; covered by `EXPECT_TREE`).

## 5. Files written by this section
`B_DRAIN_V4_BINDING_REVIEW_A.md`, `verify/recomputed.v3-to-v4.diff`, `verify/recomputed.v4.diff`, `verify/v4-blobs.git-sha1`, `verify/v4-wt-blobs.git-sha1`, `MANIFEST.v4.sha256` (all files in this directory; earlier manifests untouched).
