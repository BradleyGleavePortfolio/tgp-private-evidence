# S8-C v4 proof — PREFLIGHT checklist and launch procedure (PG-4, not yet granted)

Prepared by `s8c_bootstrap_completion` 2026-09-25 ~16:46Z under the parent's source-only follow-up to S8C-BC-2. Nothing here has run the driver. Authority to launch comes only from an explicit PG-4 grant in `execution/daceddc8/SCOPE.md` after both `BOOTSTRAP_CORRECTION_REVIEW_A.md` and `_B.md` are GO. The parent verifies every line below read-only immediately before the executor launches; the supervisor re-checks the same items and refuses (without launching, without writing anything except `run-prep/REFUSED.txt`) if any fails.

## A. Frozen candidate identity (must all match exactly)

| Item | Expected | Verify with |
|---|---|---|
| Worktree HEAD | `e0cee7e04bef88811310f6dde1fd921f45d103ad` | `git -C /home/user/workspace/worktrees/64e33dc7-s8c rev-parse HEAD` |
| Tree | `b249efb66e22f4c13529f255f3510d4a81314a99` | `git -C … rev-parse 'HEAD^{tree}'` |
| Parent | `87018a421f5be1064767d2cdd32e75ca935f7cdb` | `git -C … rev-parse HEAD^` |
| Bootstrap blob | `7c3fba471f991e3750eb56fd29e271101652196e` | `git -C … rev-parse HEAD:test/utils/g2-s8c-bootstrap.sh` |
| Porcelain | empty (0 lines) | `git -C … status --porcelain --untracked-files=all` |
| v4 driver `s8c-pg-proof.sh` | `73b291dba1725353583f27d61cb162017a95bc3d9aca0810227cfae0212db2bd` | `sha256sum binding/v4/s8c-pg-proof.sh` |
| v4 fixture `s8c-fixture.sh` | `c59326b56d8aaedf2cd509fb602cb64eb41620bf4c0c1773e2b4c5c6710685e9` | `sha256sum binding/v4/s8c-fixture.sh` |
| `binding/v4/BINDING.sha256` | file sha `c2cfd0a3f65b3889c41eef24313658be626651adc3f5205f9d11e50883dc5f03`; `sha256sum -c` 10/10 OK | `(cd binding/v4 && sha256sum BINDING.sha256 && sha256sum -c BINDING.sha256)` |
| Supervisor `run-prep/supervisor.sh` | sha recorded in `run-prep/RUN_PREP.sha256` (see §D) | `sha256sum run-prep/supervisor.sh` |
| Pins inside the driver | `EXPECT_HEAD`/`EXPECT_TREE`/`EXPECT_BOOTSTRAP_BLOB`/`EXPECT_FIXTURE_SHA` equal the four values above | `grep -E '^EXPECT_(HEAD|TREE|BOOTSTRAP_BLOB|FIXTURE_SHA)=' binding/v4/s8c-pg-proof.sh` |

## B. Heavy-slot and runtime state (must all hold at launch)

| Item | Expected | Verify with |
|---|---|---|
| Canonical lock file | present, inode 674373 (this sandbox), size 0 | `ls -li /home/user/workspace/execution/test-validation.lock` |
| Lock holders | 0 | `lslocks \| grep -c test-validation.lock` → `0` |
| postgres processes | 0 | `pgrep -cx postgres` → `0` |
| Port 55641 (S7-L) | no listener | `ss -ltn \| grep -c ':55641 '` → `0` |
| Port 55642 (S8-C) | no listener | `ss -ltn \| grep -c ':55642 '` → `0` |
| Fresh lane | `recovery-reset/proof-v4/clusters/s8-c` ABSENT | `[ ! -e /home/user/workspace/execution/64e33dc7/recovery-reset/proof-v4/clusters/s8-c ]` |
| Fresh socket dir | `recovery-reset/proof-v4/run/s8-c` absent or empty | `ls -A …/proof-v4/run/s8-c` (error or empty) |
| Driver receipts dir | `binding/v4/run/` ABSENT (so `s8c-pg-proof.sentinel`, `s8c-pg-proof.log`, `jest.log`, `RECEIPTS.sha256` are all absent) | `[ ! -e binding/v4/run ]` |
| Once-only markers | `run-prep/LAUNCH.txt`, `run-prep/LAUNCHER.txt` ABSENT | `ls run-prep/` shows only `supervisor.sh`, `PREFLIGHT.md`, `RUN_PREP.sha256` |
| Other heavy lanes | no S7-L driver/Jest/tsc/prisma process live (`pgrep -af 's7l-pg-proof|jest|prisma'` empty apart from platform node) | read-only `ps` |
| Runtime pins (RT-2 receipts) | PG 17.6 `postgres` `23cd1748…`, `initdb` `b7db9bc2…`, psql 18.6 `a200e38c…`, node `a03953a7…`; builder `node_modules/.package-lock.json` `05bc530a…`, `.prisma/client/index.d.ts` `b6716a86…`, `.prisma/client/schema.prisma` `ded50406…` | `sha256sum` (the driver re-verifies all of these itself and stops on mismatch) |
| Time budget | ≥ 70 min of undisturbed slot (outer `timeout -k 30 3900`) | schedule |

Note on the driver's own preflight: a driver-side PREFLIGHT_FAIL writes the sentinel and consumes the single grant (rc71), whereas a lock-busy refusal (rc75, before the sentinel) does not. The supervisor's read-only pre-checks in §B exist so that a stale environment refuses *before* the driver is ever invoked.

## C. Launch (executor only, under the explicit PG-4 grant)

```
cd /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c/binding/v4/run-prep
S8C_PG4_GRANT=1 bash supervisor.sh
```
- The launch-mode process performs the §A/§B refusals read-only, writes `LAUNCH.txt`, then detaches itself (`setsid nohup bash supervisor.sh --child </dev/null >supervisor.stdout 2>supervisor.stderr &`) and returns immediately.
- The detached child runs exactly `timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c/binding/v4/s8c-pg-proof.sh` once, with stdin `/dev/null`, driver stdout → `run-prep/driver.stdout`, stderr → `run-prep/driver.stderr`; records `SUPERVISOR_START`, `PRE_LAUNCH` (lock holders/postgres/ports, read-only), `TIMEOUT_WRAPPER_PID`, `DRIVER_PID`, `LAUNCHER_EXIT rc=`, `POST` (holders/postgres/port/sentinel contents) and `END` in `run-prep/LAUNCHER.txt`, then hashes `LAUNCH.txt LAUNCHER.txt driver.stdout driver.stderr` into `run-prep/LAUNCH_RECEIPTS.sha256`.
- The supervisor never opens or flocks the canonical lock; only the unchanged driver takes fd9 and holds it to its exit. The supervisor never retries, never sends signals, never invokes a second driver on any rc (including outer-timeout rc 124/137).
- Poll: `cat run-prep/LAUNCHER.txt` until `END`; driver stage log is `binding/v4/run/s8c-pg-proof.log`, Jest output `binding/v4/run/jest.log`, sentinel `binding/v4/run/s8c-pg-proof.sentinel` (`RC= STAGE= END= HEAD= LOCK_INODE=`), driver receipts `binding/v4/run/RECEIPTS.sha256`.
- Tool-call timeouts must not be treated as failure; the detached process continues. Do not launch again if a tool call returns early.
- Afterwards: confirm `lslocks` shows 0 holders, `pgrep -cx postgres` 0, port 55642 free, `proof-v4/clusters/s8-c/pg-data` retained with no `postmaster.pid`; then write `binding/v4/run/PROOF_RUN_RECEIPT.md`. A full pass (`END rc=0 stage=post`, Jest all passed) accepts exactly this candidate; any other result is terminal for this grant and goes to disposition, never to a rerun.

## D. Preparation record

- `supervisor.sh` `bash -n` OK. Flag gate exercised once with `S8C_PG4_GRANT` unset: `REFUSED rc=70 2026-09-25T16:45:47Z` (first refusal line; nothing else ran, no driver, no lock, no writes beyond the scratch `REFUSED.txt`, which the builder removed before hashing this directory). No other mode was exercised.
- The driver, fixture, bootstrap, PG, Jest were NOT executed. `binding/v4/run/` does not exist. `binding/v4/BINDING.sha256` unchanged (`c2cfd0a3…`); `run-prep/` is outside that manifest and has its own `RUN_PREP.sha256`.
- Modeled on `s7l/binding/v3/run/supervisor.sh` + `LAUNCHER.txt` and the S8-C v3 `run/LAUNCH.txt` + `supervisor.stdout/stderr` pattern; differences: outer bound 3900 (SCOPE §PG-4, was 3600 in S8-C v3), explicit grant flag, once-only and read-only pre-checks, driver stdout/stderr kept separate, DRIVER_PID recorded.
