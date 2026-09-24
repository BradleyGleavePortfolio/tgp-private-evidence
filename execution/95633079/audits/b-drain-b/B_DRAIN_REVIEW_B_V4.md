# S7-3′ G2 B/drain — reviewer B, same-review binding of the frozen v4 (single fresh-fake hunk + pins)

Read-only; no env/hooks/gates/commit/PG/index writes; peer-A unread. New additive file (no sealed input edited).
Scope strictly: the one changed hunk, its blob, the v4 tree and pin substitution. The ten unchanged files and all
C items keep their v3 dispositions (`B_DRAIN_REVIEW_B_V3.md`) and are not reopened.

## 1. Identity (independently re-derived)

| Item | Check | Result |
|---|---|---|
| v4 tree `f4922ca070e887fb7f613ce955b12621b5c33156` | tree object exists; on the same base HEAD `a0ea1bea…` / tree `87798e74…` (index clean, 11 untracked, 0 hooks, no `node_modules`) | as stated |
| v3 → v4 | `git diff --name-status`: exactly one `M` `src/scout/scout-ledger-backfill.spec.ts`; `--shortstat` 1 file, +7/−4; full `git ls-tree -r` diff of the two trees shows only that blob line (`3a97093a…` → `5477059a152a04a1fa9a117e3c1d184259ac3341`), modes `100644`, no path/case change | exactly one blob |
| base → v4 | 11 `A`, +2323 | matches `NAME_STATUS.vs-base.txt` / `b-drain.v4.diff` claim |
| Pins | `frozen-v4/BLOBS.git-sha1` == `git ls-tree -r f4922ca0` for the 11 paths; `git hash-object` of the working-tree spec == `5477059a…`; `SOURCE.sha256` OK against the worktree; `PACKET.v4.sha256` all OK | all match |
| Diff artefact | `sha256(git diff 00b105ff f4922ca0)` == `sha256(frozen-v4/v3-to-v4.diff)` = `3cdb4ff6…4e3` | identical |
| v3 packet, template | `PACKET.v3.sha256` and `fixture-proposal-v3/` untouched per closure map (not re-verified here; out of scope) | — |

## 2. The hunk (`src/scout/scout-ledger-backfill.spec.ts:270-280`)

Replaces the reuse of the drained `db` with `const fresh = new FakeLedger([row('a')]); fresh.fenced = true;
fresh.faults = ['lock'];`, runs `backfillLedgerPlatform(fresh, { batch: 500, lockRetries: 0 })` and asserts on
`fresh`. Comment text updated; no test added or removed; assertion set unchanged except the target instance.

Trace against the v3 library (`957fb8c6`, unchanged) and fake: `readDrainState` uses `$queryRaw` only (no
transaction) → `nulls = 1`, `fenced = true`. `runPass` → first chunk → `$transaction` #1 → fake shifts `'lock'`
→ throws the 55P03-shaped error → `isLockOrStatementTimeout` true → attempts allowed = `lockRetries + 1 = 1` →
`lockFailures 1`, `stalledByLocks true`, `chunks 0` → pass returned → run loop breaks on `stalledByLocks`.
`after`: `nulls = 1`, `fenced = true` → `decideOutcome(1, true, {0,0,0})` → explained 0 ≠ 1 → **`'stalled'`**.
`fresh.transactions === 1` (one attempt, nothing else touched the instance). `once.passes` has exactly one
element matching `objectContaining({ chunks: 0, lockFailures: 1, stalledByLocks: true })`. All four expectations
hold deterministically. This closes B-4 / B-BD-FRESH-FAKE exactly at the minimum granted.

Gate exposure unchanged: the file is discovered by the default `jest.config.js` root `src/scout`, type-checked by
`tsc --noEmit` (`strict: true`; `fresh` is a `FakeLedger`, same shape the file already uses), linted by ESLint
(`no-explicit-any` off, no new `any`), Prettier `--check` reported pass by the writer under the pinned 3.9.6 CLI;
no R75 token classes appear in the hunk.

## 3. Disposition

- `src/scout/scout-ledger-backfill.spec.ts` `5477059a…`: **SOURCE_GRANTABLE**.
- v4 tree `f4922ca070e887fb7f613ce955b12621b5c33156`: **SOURCE_GRANTABLE as a whole** — the ten unchanged blobs
  carry their v3 grants (product: `migration.sql` `55c85906`, `down.sql` `91e646dd`, `scout-ledger-backfill.ts`
  `957fb8c6`, `cli.ts` `bcc06577`; proof/adapter: live spec `9b31fd18`, helper `469cbd2a`, `g2-b-drain-db.ts`
  `cb60f3f4`, `g2-b-drain-pg-harness.ts` `c22a72c4`, `g2-b-drain-bootstrap.sh` `b4503eef` (100755), guard spec
  `4e1ed6ff`). No A or B findings open on v4. This is source grantability only; runtime remains ungranted
  until the actual committed head exists and its pins are bound.

## 4. Phase-A requirements with v4 pins substituted (order already agreed; unchanged otherwise)

1. Isolated copy of the accepted C1 `node_modules` into `worktrees/s7-b-drain`; verify `.package-lock.json`
   `05bc530a…6a44` and `.prisma/client/index.d.ts` `bf679a16…72d5`; no `npm ci`, no candidate `prisma generate`.
2. `./node_modules/.bin/lefthook install` (standalone repo → its own `.git/hooks`); confirm `pre-commit` and
   `commit-msg` reference lefthook.
3. Gates from that tree only, against the working tree that must still hash to v4 (`git write-tree` on a temp
   index == `f4922ca0…`; the 11 blobs == `frozen-v4/BLOBS.git-sha1`): `tsc --noEmit`; `eslint --max-warnings 0`
   + `prettier --check` on the 7 new/changed TS files; `node scripts/check-r75.js`;
   `jest src/scout/scout-ledger-backfill.spec.ts test/scout/g2-b-drain-db-guard.spec.ts`.
4. One ordinary Bradley-authored commit with the hooks executing (handoff §7 message, no trailers). Expected
   committed tree = `f4922ca070e887fb7f613ce955b12621b5c33156` (any other tree means the working tree moved and
   returns to same-review binding).
5. Fill `fixture-proposal-v3/binding/b-pg-proof.sh` pins from the committed head: `EXPECT_HEAD=<commit>`,
   `EXPECT_TREE=f4922ca070e887fb7f613ce955b12621b5c33156`,
   `EXPECT_SPEC_BLOB=9b31fd1813d25a1624ab04666e0b1be4743277ab` (`test/rls-g2-b-drain.spec.ts`),
   `EXPECT_BOOTSTRAP_BLOB=b4503eef525baa531eedb148f47828db3a4ade6f` (`test/utils/g2-b-drain-bootstrap.sh`),
   `EXPECT_FIXTURE_SHA=sha256(fixture-proposal-v3/binding/b-fixture.sh)` = `4525f01d…9eb9` (byte-identical to the
   reviewed v1 fixture); S5 donor pins already constant in the runner. Then a separate PG grant for exactly one
   `timeout -k 30 3600 bash fixture-proposal-v3/binding/b-pg-proof.sh`.
Reviewer B stays available for the actual head/pin binding and results; not a new audit track.
