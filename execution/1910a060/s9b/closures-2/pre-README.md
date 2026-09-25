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

Still unfilled (refused by the runner): `EXPECT_HEAD`, `EXPECT_TREE`, six S9-B blob pins, `EXPECT_FIXTURE_SHA`
(fill AFTER the gate's hooked commit; blobs are post-format), `RUNTIME_ROOT` and the seven tool pins (from the
runtime receipt), `BASE_HEAD`/`BASE_TREE` (M2). Fill order, roles, lane dirs, lock (`flock -n` fd 9 on the canonical
`test-validation.lock`, inode 667698), timeouts and stop semantics are as in `../v1/README.md`.
