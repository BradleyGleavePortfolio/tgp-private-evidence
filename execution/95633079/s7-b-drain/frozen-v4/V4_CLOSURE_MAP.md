# v4 — single test-only successor of v3 (B-BD-FRESH-FAKE: reviewer B B-4 = reviewer A FB-3)

Grant: parent "GO minimum source-only v4" (2026-09-24 ~08:05Z). Executed: one file replaced with the already-proposed
successor bytes (`frozen-v3/successor-proposal/`), one pinned Prettier 3.9.6 `--check` (CLI sha256 `6e922134…7906e`
verified) under `flock -n execution/test-validation.lock` → pass, no `--write` needed, lock released immediately;
temp-index `write-tree`. NOT executed: env copy, install, generate, tsc, eslint, jest, hooks, commit, PG.

| | value |
|---|---|
| Base | HEAD `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992`, tree `87798e742c7b48f56b05e9b5c30efa877180a9b3` (unchanged; index clean; tracked files unmodified; 0 hooks) |
| v3 tree | `00b105ffe362c27808a38c44c6db1f733134f074` (frozen, `PACKET.v3.sha256` re-verified intact) |
| **v4 tree** | **`f4922ca070e887fb7f613ce955b12621b5c33156`** (temp index, no commit) |
| v4 vs v3 | exactly 1 `M`: `src/scout/scout-ledger-backfill.spec.ts` blob `3a97093a…` → `5477059a152a04a1fa9a117e3c1d184259ac3341`, 11 changed lines (`v3-to-v4.diff`); all other 10 paths/blobs/modes identical (`BLOBS.git-sha1` diff shows only that line) |
| v4 vs base | 11 `A` (`b-drain.v4.diff`, `NAME_STATUS.vs-base.txt`) |

## Hunk (test-only, DB-free unit spec, retry case)
Zero-retry assertion no longer reuses the drained `db` (no NULL row left; cumulative `transactions`). It now builds
`const fresh = new FakeLedger([row('a')]); fresh.fenced = true; fresh.faults = ['lock'];`, runs
`backfillLedgerPlatform(fresh, { batch: 500, lockRetries: 0 })` and asserts on `fresh`: one pass with
`chunks 0, lockFailures 1, stalledByLocks true`, outcome `'stalled'`, `fresh.transactions === 1` (exactly one attempt).
No product/library/SQL/live-spec/adapter/binding bytes changed; no test case added or removed; assertion set unchanged
except the fixture instance it targets. Reviewer prose differences on cumulative counts are moot for a fresh instance;
the real unit gate (phase A) settles one-attempt semantics.

## Unchanged from v3 (see `frozen-v3/V3_CLOSURE_MAP.md`)
F1 fence detection (library/down.sql/helper/live spec), F2 ACL proof, B-1 zero-retry bound, B-2 fixture history /
exact new-migration set, identity adapter (4 files + 2-file delta), `fixture-proposal-v3/` binding (unchanged; its pins
remain placeholders and are to be filled from the eventual committed head — the v4 spec blob is `5477059a…`).
Commit message: handoff §7 text unchanged.

## Next (on grants, in the corrected order)
isolated C1 node_modules copy + verify → `./node_modules/.bin/lefthook install` → affected gates (tsc, eslint,
prettier --check, check-r75, DB-free jest incl. `src/scout/scout-ledger-backfill.spec.ts` and
`test/scout/g2-b-drain-db-guard.spec.ts`) → ordinary Bradley-authored hooked commit → fill pins → separate PG grant
(`fixture-proposal-v3/binding/b-pg-proof.sh`, outer `timeout -k 30 3600`).
