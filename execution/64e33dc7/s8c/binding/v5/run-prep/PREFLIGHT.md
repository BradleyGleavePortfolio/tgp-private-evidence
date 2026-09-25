# S8-C v5 proof — PREFLIGHT checklist and launch procedure (PG-4c / v5, not yet granted)

Prepared by `s8c_bootstrap_completion` 2026-09-25 ~17:26Z under S8C-BC-5 (harness + spec assertion corrections). Nothing here has run the driver. Authority to launch comes only from an explicit PG-4c (v5) grant in `execution/daceddc8/SCOPE.md` after both `BOOTSTRAP_CORRECTION_REVIEW_A.md` and `_B.md` are GO. The parent verifies every line below read-only immediately before the executor launches; the supervisor re-checks the same items and refuses (without launching, without writing anything except `run-prep/REFUSED.txt`) if any fails.

## A. Frozen candidate identity (must all match exactly)

| Item | Expected | Verify with |
|---|---|---|
| Worktree HEAD | `f428db9ab65f638da1651b8cd792c6f93b4983c1` | `git -C /home/user/workspace/worktrees/64e33dc7-s8c rev-parse HEAD` |
| Tree | `f2623be642ddfbba025ffe8360256a683ac57997` | `git -C … rev-parse 'HEAD^{tree}'` |
| Parent | `4d7d4b4ebdb7df2af593bbd809f7df23775fdf29` (lineage 87018a42 → e0cee7e0 → 9cc76401 → 4d7d4b4e → HEAD) | `git -C … rev-parse HEAD^` |
| Bootstrap blob (unchanged) | `7c3fba471f991e3750eb56fd29e271101652196e` | `git -C … rev-parse HEAD:test/utils/g2-s8c-bootstrap.sh` |
| Harness blob | `1a8f17970a1095f9b802badacf093e773caabd76` | `git -C … rev-parse HEAD:test/utils/g2-s8c-harness.ts` |
| Spec blob | `9d701783eeb7701126d158b45bfee3d5f0f686b3` | `git -C … rev-parse HEAD:test/rls-g2-s8c.spec.ts` |
| Porcelain | empty (0 lines) | `git -C … status --porcelain --untracked-files=all` |
| v5 driver `s8c-pg-proof.sh` | `b641db2d5fae07d9220e573a04cb512c5ec35814b08ae7c506c02499c314fd1d` | `sha256sum binding/v5/s8c-pg-proof.sh` |
| v5 fixture `s8c-fixture.sh` | `34a42ab8b2ffa75256f5fa600ca7a51bcdb3ae1f224ad989ff1ca7a4dd716f10` | `sha256sum binding/v5/s8c-fixture.sh` |
| `binding/v5/BINDING.sha256` | file sha `2995ed837fd352e3ea663949cc74e66ca5eec4566444739e8b7f53aab87c9eba`; `sha256sum -c` 10/10 OK | `(cd binding/v5 && sha256sum BINDING.sha256 && sha256sum -c BINDING.sha256)` |
| Supervisor `run-prep/supervisor.sh` | sha recorded in `run-prep/RUN_PREP.sha256` (see §D) | `sha256sum run-prep/supervisor.sh` |
| Pins inside the driver | `EXPECT_HEAD`/`EXPECT_TREE`/`EXPECT_BOOTSTRAP_BLOB`/`EXPECT_HARNESS_BLOB`/`EXPECT_SPEC_BLOB`/`EXPECT_FIXTURE_SHA` equal the six values above | `grep -E '^EXPECT_(HEAD|TREE|BOOTSTRAP_BLOB|HARNESS_BLOB|SPEC_BLOB|FIXTURE_SHA)=' binding/v5/s8c-pg-proof.sh` |

## B. Heavy-slot and runtime state (must all hold at launch)

| Item | Expected | Verify with |
|---|---|---|
| Canonical lock file | present, inode 674373 (this sandbox), size 0 | `ls -li /home/user/workspace/execution/test-validation.lock` |
| Lock holders | 0 | `lslocks \| grep -c test-validation.lock` → `0` |
| postgres processes | 0 | `pgrep -cx postgres` → `0` |
| Port 55641 (S7-L) | no listener | `ss -ltn \| grep -c ':55641 '` → `0` |
| Port 55642 (S8-C) | no listener | `ss -ltn \| grep -c ':55642 '` → `0` |
| Fresh lane | `recovery-reset/proof-v5/clusters/s8-c` ABSENT | `[ ! -e /home/user/workspace/execution/64e33dc7/recovery-reset/proof-v5/clusters/s8-c ]` |
| Fresh socket dir | `recovery-reset/proof-v5/run/s8-c` absent or empty | `ls -A …/proof-v5/run/s8-c` (error or empty) |
| Driver receipts dir | `binding/v5/run/` ABSENT (so `s8c-pg-proof.sentinel`, `s8c-pg-proof.log`, `jest.log`, `RECEIPTS.sha256` are all absent) | `[ ! -e binding/v5/run ]` |
| Once-only markers | `run-prep/LAUNCH.txt`, `run-prep/LAUNCHER.txt` ABSENT | `ls run-prep/` shows only `supervisor.sh`, `PREFLIGHT.md`, `RUN_PREP.sha256` |
| Other heavy lanes | no S7-L driver/Jest/tsc/prisma process live (`pgrep -af 's7l-pg-proof|jest|prisma'` empty apart from platform node) | read-only `ps` |
| Runtime pins (RT-2 receipts) | PG 17.6 `postgres` `23cd1748…`, `initdb` `b7db9bc2…`, psql 18.6 `a200e38c…`, node `a03953a7…`; builder `node_modules/.package-lock.json` `05bc530a…`, `.prisma/client/index.d.ts` `b6716a86…`, `.prisma/client/schema.prisma` `ded50406…` | `sha256sum` (the driver re-verifies all of these itself and stops on mismatch) |
| Time budget | ≥ 70 min of undisturbed slot (outer `timeout -k 30 3900`) | schedule |

Note on the driver's own preflight: a driver-side PREFLIGHT_FAIL writes the sentinel and consumes the single grant (rc71), whereas a lock-busy refusal (rc75, before the sentinel) does not. The supervisor's read-only pre-checks in §B exist so that a stale environment refuses *before* the driver is ever invoked.

## C. Launch (executor only, under the explicit PG-4c (v5) grant)

```
cd /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c/binding/v5/run-prep
S8C_PG5_GRANT=1 bash supervisor.sh
```
- The launch-mode process performs the §A/§B refusals read-only, writes `LAUNCH.txt`, then detaches itself (`setsid nohup bash supervisor.sh --child </dev/null >supervisor.stdout 2>supervisor.stderr &`) and returns immediately.
- The detached child runs exactly `timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c/binding/v5/s8c-pg-proof.sh` once, with stdin `/dev/null`, driver stdout → `run-prep/driver.stdout`, stderr → `run-prep/driver.stderr`; records `SUPERVISOR_START`, `PRE_LAUNCH` (lock holders/postgres/ports, read-only), `TIMEOUT_WRAPPER_PID`, `DRIVER_PID`, `LAUNCHER_EXIT rc=`, `POST` (holders/postgres/port/sentinel contents) and `END` in `run-prep/LAUNCHER.txt`, then hashes `LAUNCH.txt LAUNCHER.txt driver.stdout driver.stderr` into `run-prep/LAUNCH_RECEIPTS.sha256`.
- The supervisor never opens or flocks the canonical lock; only the unchanged driver takes fd9 and holds it to its exit. The supervisor never retries, never sends signals, never invokes a second driver on any rc (including outer-timeout rc 124/137).
- Poll: `cat run-prep/LAUNCHER.txt` until `END`; driver stage log is `binding/v5/run/s8c-pg-proof.log`, Jest output `binding/v5/run/jest.log`, sentinel `binding/v5/run/s8c-pg-proof.sentinel` (`RC= STAGE= END= HEAD= LOCK_INODE=`), driver receipts `binding/v5/run/RECEIPTS.sha256`.
- Tool-call timeouts must not be treated as failure; the detached process continues. Do not launch again if a tool call returns early.
- Afterwards: confirm `lslocks` shows 0 holders, `pgrep -cx postgres` 0, port 55642 free, `proof-v5/clusters/s8-c/pg-data` retained with no `postmaster.pid`; then write `binding/v5/run/PROOF_RUN_RECEIPT.md`. A full pass (`END rc=0 stage=post`, Jest all passed) accepts exactly this candidate; any other result is terminal for this grant and goes to disposition, never to a rerun.

## D. Preparation record

- `supervisor.sh` derived mechanically from `binding/v4/run-prep/supervisor.sh` (`798d9f7c…`): binding dir v4→v5, lane/socket `proof-v4`→`proof-v5`, grant flag `S8C_PG4_GRANT`→`S8C_PG5_GRANT`, PG-4→PG-5 wording, and the five pins (head, tree, driver, fixture, manifest); `supervisor.sh.diff-v4-to-v5` records every changed line. `bash -n` OK. No mode of it was exercised (the v4 flag gate was exercised once, recorded there; the logic is unchanged).
- The v5 driver, fixture, bootstrap, PG, Jest were NOT executed by this preparation. `binding/v5/run/` does not exist. `binding/v5/BINDING.sha256` (`2995ed83…`) covers the frozen v5 driver/fixture/PINS/README and the v4 copies + diffs; `run-prep/` is outside that manifest and has its own `RUN_PREP.sha256`.
- Retained lanes never adopted: `clusters/s8-c` (failed v3), `proof-v4/clusters/s8-c` (failed v4, pg-data retained, no postmaster.pid); both are enumerated by the v5 driver's other-lane loops and hashed pre/post. Scratch diagnostic lanes `scratch/s8c-diag` and `scratch/s8c-diag2` (port 55644) are outside every proof path and are not enumerated by the driver (their existence is recorded in `s8c/harness-correction/`).
- Non-accepting evidence for this head: `s8c/harness-correction/diagnostic/b3/` — the RLS suite at clean `f428db9a…` on a fresh scratch lane after the unchanged bootstrap: 13 passed / 13 (never acceptance; PG-4c on this binding is the only accepting run).
