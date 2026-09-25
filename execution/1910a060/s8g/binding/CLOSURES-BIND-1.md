# CLOSURES-BIND-1 — S8-G binding v1: Phase-2 B3/B4/B-BIND-1..3 + C items applied, pins FILLED (still NOT RUN)

Candidate untouched (`820ce85b` exact, worktree clean; no lock taken, no tests run). All edits are under `binding/v1/`; the
pre-review state is kept in `binding/v1-pre-review-snapshot/` and the reviewed `.unfilled` templates + pre-BIND-1 fixture/README in `binding/v1/history/`.

## Final files and sha256 (`v1/BINDING.sha256`, regenerated over exactly these four)
| File | sha256 |
|---|---|
| `v1/s8g-pg-proof.sh` (filled runner, 216 lines, `bash -n` OK) | `4fccd1353edb47bfbeea0a7fab159660cee64f5356bccbf70280aba00705c40a` |
| `v1/s8g-fixture.sh` (`bash -n` OK) | `62de28baa4ad3a669729aa33bebdb603b72642e9a41a2a57345b344093b3d24d` |
| `v1/PINS.txt` | `63c2122c275362706a8230e9e010d66dd39bbdacca36614e2083c9d634b985db` |
| `v1/README.md` | `9e04de132f5b375a0e598b0446bf74e92eb7f56fc95ec837eff4bbc827c30c18` |

## Diffs for the diff-only re-review
- `CLOSURES-BIND-1.runner.diff` — pre-review snapshot runner → final (186 lines; includes the earlier review-B/A B2 edits: lane s8-g, port 55644, base 62471b11, S8-F pins in PINS).
- `CLOSURES-BIND-1.runner-from-reviewed-unfilled.diff` — the `.unfilled` runner the reviewers saw → final (179 lines; BIND-1 only).
- `CLOSURES-BIND-1.fixture.diff` (27 lines: header lane/port text, `PORT=55644`), `CLOSURES-BIND-1.pins.diff` (102 lines).

## Item-by-item
| Item | Change (runner unless noted) | Verification done here (read-only) |
|---|---|---|
| **B3 / B-BIND-1** real psql | `PSQL=/usr/lib/postgresql/18/bin/psql`; `EXPECT_PSQL_SHA=d1108fdb45b87f2313d7acfbb91a0a65ca97c6c2195f15d8ae9295121029ef67`; precondition `[ -x $PSQL ] && sha == pin` and `"$PSQL" --version` must match `^psql \(PostgreSQL\) 18\.` (fail 70); `G2_S8G_PSQL=$PSQL`; `psqlq()` and PRECONDITIONS_OK log use `$PSQL` — no `/usr/bin/psql` (pg_wrapper a200e38c…) anywhere. Mirrors S8-F v2 CB1 lines 49-50/144-145. | `sha256sum /usr/lib/postgresql/18/bin/psql` = d1108fdb…; `--version` = `psql (PostgreSQL) 18.6 (Ubuntu 18.6-0ubuntu0.26.04.1)` |
| **B4 / B-BIND-2** test count | `EXPECT_TESTS=19`; after jest rc check: `grep -qE "^Tests: +19 passed, 19 total"` and `grep -qE "^Test Suites: +1 passed, 1 total"` on jest.log, else `fail 72`; logs `JEST_COUNT_OK`. | `git show 820ce85b:test/rls-g2-s8g.spec.ts | grep -cE '^\s*it\('` = 19; no `it.each`/`.skip`/`.only`/`test(` |
| **B-BIND-3** manifest | `BINDING.sha256` regenerated over runner/fixture/PINS/README (above). | — |
| **Fill** nine head pins | From `gate/attempt-4/BINDING-PINS-820ce85be2eb.txt`: HEAD 820ce85be2eb…, TREE 7ede6dbb…, spec 86a944c1, bootstrap 2ab85a13, db c654e6bd, pgh a0261246, harness ee2a41a2, worker 65ee972d. `EXPECT_FIXTURE_SHA` = **62de28ba…** — the fixture's sha after BIND-1 (the gate-time value b2dd548a… predates the fixture comment edits; the runner pins the file as frozen now). Placeholder-refusal `case *__*` retained; zero `__FILL` tokens remain in runner/fixture/PINS. | Static dry check against the clone: HEAD/tree OK, all 6 S8-G blob pins OK, fixture sha OK, psql OK, lock inode OK |
| **Runtime pins** | postgres 23cd1748…, initdb b7db9bc2…, pg_ctl af53d826…, node a03953a7…, nm lock 05bc530a…, client 9042e713…, schema 0eb41f9a…, package-lock b7fed5ed…, `EXPECT_MIGRATIONS=172` (identity check now uses it), PROVENANCE `result=success`. | All re-measured read-only on this host 2026-09-25 and equal |
| **C** other-lane scan | Both preflight and post loops now iterate `$CLUSTERS/*/` **and** `$RUNTIME_ROOT/proof-*/clusters/*/` (covers `proof-s8f-v2/clusters/s8-f`), skip only `${d%/} == $LANE`, name lanes relative to the runtime root (S8-F v2 pattern). | `runtime/proof-s8f-v2/clusters/s8-f` exists; `runtime/clusters` absent (S8-G will be the first lane there) |
| **C** 17 S8-F blob pins | Added to the accepted-file loop (plus `package-lock.json 354de3da`): loop now enforces 37 blobs at HEAD; failure text says `blob != 62471b11; S7-L/S8-C/S8-F accepted-at-base`. | All 37 verified equal at 820ce85b |
| **C** stale text | `!= 77f33bcd` → `sha256 != pin (blob 2e328bbc, identical at 1c5fbb04 and 62471b11)`; `port 55643 free` → `port $PORT (55644) free`; header/comment ports and `@1c5fbb04` annotations updated; fixture header lane/port text fixed. | `rg "77f33|55643 free|/usr/bin/psql|s8-c" v1/s8g-pg-proof.sh` → none |
| **Lock inode** | `EXPECT_LOCK_INODE=667698`; before `exec 9>>$LOCK; flock -n`, `stat -c %i` must equal it, else `REFUSED … exit 75`. | Lock file inode = 667698 |

Not changed: stage order/bounds, once-only sentinel, first-failure stop with bounded fixture stop, data-dir retention, the spec command
(`jest --config jest.rls.config.js test/rls-g2-s8g.spec.ts --runInBand --ci`, once). Nothing executed; binding awaits the parent's single-run grant.
