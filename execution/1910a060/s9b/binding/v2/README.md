# S9-B real-PG proof binding — DRAFT v2 (source only; NOT RUN; NOT GRANTED)

v2 supersedes `../v1` after the parent's 14:13/14:59 PT relays; v1 is kept untouched as history.

Changes v1 → v2 (nothing else):

- `PORT=55645` filled in `s9b-pg-proof.sh`, `s9b-fixture.sh`, `PINS.txt` (parent choice; `g2-s9-db.ts` refuses
  55642/55643, the guard spec uses 55645 as its example/ack port and 55646 as the mismatch probe).
- `BASE_HEAD` / `BASE_TREE` are now `__FILL_M2__`: the candidate descends from M2 (S9-A `be88909f` composed onto
  `integration/importer` `62471b11`), not from `1c5fbb04` directly. The runner's fill check now covers both.
  Every accepted-path blob/tree the runner pins (schema `2e328bbc`, migrations `654550cb`, `jest.rls.config.js`
  `44c96915`, `src/scout/reconstruct` `c4ae4b8e`, `src/scout/lifecycle` `c345dd54`, `scout-reconstruct.service.ts`
  `711bfb09`, seven `g2-s8c`/`rls-g2-s8c` blobs) was verified identical at `1c5fbb04` and `62471b11` in the
  read-only clone, so those pins are unchanged. `EXPECT_SCHEMA_SHA` `0eb41f9a…` and `EXPECT_PKG_LOCK_SHA`
  `b7fed5ed…` also hold at `62471b11` (blobs `2e328bbc` / `354de3da`).
- S9-A blob pins are the ACCEPTED post-format blobs at `be88909f` (`types` `b7599427`, `coverage` `f50d9401`,
  `reconcile` `bcc85e49`, `reconcile.spec` `11f2a524`; sha256 `211b474a`/`eca66f33`/`d16158ad`/`dc084dce`), replacing
  the pre-format read-only copies (`bb28f151`/`e13c336a`/`3932cd3c`/`df887df5`).

Changes at CLOSURES-2 (parent disposition 15:31 PT after dual review of v2 — NO-GO as written, GO-for-one-run-after-fill
once closed; see `../../CLOSURES-2.md` for exact diffs):

1. `D=…/binding/v2`; every stale `v1` label removed (runner usage line and `EXPECT_FIXTURE_SHA` comment, fixture
   header, `PINS.txt` header / fixture-sha comment); the `G2_S8B_*` identity comment now lists `G2_S8G_*`, `G2_S8F_*`,
   `G2_S8C_*`, `G2_S8B_*`, `G2_S7L_*`.
2. `RUNTIME_ROOT=/home/user/workspace/execution/1910a060/runtime` is a literal in BOTH the fixture and the runner
   (the fixture previously pointed at the 64e33dc7 `recovery-reset` root). The runner cross-checks the fixture
   whole-line with `grep -qx`: `RUNTIME_ROOT=<its own>` and `PORT=55645; SUPER=s9_super; PASS=s9_local_synthetic;
   MARKER=s9-disposable-pg17`; any mismatch is refusal 70 before init.
3. psql: `PSQL=/usr/lib/postgresql/18/bin/psql` (the real client binary, not the `/usr/bin/psql` pg_wrapper),
   `EXPECT_PSQL_REAL_SHA=d1108fdb…` (RUNTIME_SETUP_RECEIPT.md; re-measured on this host), `--version` asserted
   `^psql \(PostgreSQL\) 18\.`, used for `G2_S9_PSQL`, `psqlq` and the PRECONDITIONS_OK line — mirror of
   `execution/64e33dc7/s8f/binding/v2/s8f-pg-proof.sh` CB1. `EXPECT_PSQL_REAL_SHA` is in the fill-refusal case list.
4. `EXPECT_TESTS=10` (`grep -c '^\s*it('` on `test/rls-g2-s9.spec.ts`); after jest rc 0 the runner requires
   `^Tests: +10 passed, 10 total` in `jest.log`, else `JEST_COUNT_FAIL` → 72.
5. `EXPECT_LOCK_INODE=667698`: asserted with `stat -c %i` immediately after `flock -n` succeeds; mismatch → 75.
6. Other-lane fingerprint scan (preflight and post) now iterates `$CLUSTERS/*/` (S8-G's `clusters/s8-g`) AND
   `$RUNTIME_ROOT/proof-*/clusters/*/` (S8-F's `proof-s8f-v2/clusters/s8-f`), keyed by the path relative to the
   runtime root, skipping only `$LANE`.
7. `EXPECT_FIXTURE_SHA` is FILLED now (`1ee36964…`, the fixture is head-independent) and `BINDING.sha256` lists the
   v2 files.

Still unfilled (refused by the runner): `BASE_HEAD`/`BASE_TREE` (M2), `EXPECT_HEAD`, `EXPECT_TREE`, six S9-B blob
pins (fill AFTER the gate's hooked commit; blobs are post-format), and the six remaining tool pins
(`EXPECT_POSTGRES_SHA`, `EXPECT_INITDB_SHA`, `EXPECT_PGCTL_SHA`, `EXPECT_NODE_SHA`, `EXPECT_NM_LOCK_SHA`,
`EXPECT_NM_CLIENT_SHA` — copy from `RUNTIME_SETUP_RECEIPT.md` at fill only after re-verifying each value). Fill order,
roles, lane dirs, lock (`flock -n` fd 9 on the canonical `test-validation.lock`, inode 667698), timeouts and stop
semantics are as in `../v1/README.md`. The runner has NOT been executed (it takes the lock before its first check).
