# S7-L v4 proof — PREFLIGHT checklist and launch procedure (PG-4b, not yet granted)

Prepared by `s7l_worker_correction_builder` 2026-09-25 ~16:55Z under the parent's source-only follow-up to S7L-WC-1. Nothing here has run the driver. Authority to launch comes only from an explicit PG-4b grant in `execution/daceddc8/SCOPE.md` after both `reviews/WORKER_CORRECTION_REVIEW_A.md` and `_B.md` are GO. The parent verifies every line below read-only immediately before the executor launches; the supervisor re-checks the same items and refuses (without launching, without writing anything except `run-prep/REFUSED.txt`) if any fails.

## A. Frozen candidate identity (must all match exactly)

| Item | Expected | Verify with |
|---|---|---|
| Worktree HEAD | `df713fd9217df524915348ef8a42c797f288dde1` | `git -C /home/user/workspace/worktrees/64e33dc7-s7l rev-parse HEAD` |
| Tree | `796f437fea80550a379b5f54dc485bc5dbba67e1` | `git -C … rev-parse 'HEAD^{tree}'` |
| Parent | `a68cdac70d81aea384fdc99c01c9c983a08e80eb` (then 54970cd9 → 839b54c5 → 93389265) | `git -C … rev-parse HEAD^ HEAD^^ HEAD^^^ HEAD^^^^` |
| Worker blob | `155ffdccd3d4e472cede84e7b11523d18201b450` | `git -C … rev-parse HEAD:test/utils/g2-s7l-worker.cjs` |
| Spec blob | `94e7fac4b8cbb8a8e2146700cbdc7ce9129b9f92` (unchanged from v3) | `git -C … rev-parse HEAD:test/rls-g2-s7l.spec.ts` |
| Porcelain | empty (0 lines) | `git -C … status --porcelain --untracked-files=all` |
| v4 driver `s7l-pg-proof.sh` | `8b03f4c247362bc3a255f8490c90e0e8ae546e6c08f89cfb0e3bcbdee0f1fa8f` (mode 644, invoked via `bash`) | `sha256sum binding/v4/s7l-pg-proof.sh` |
| v4 fixture `s7l-fixture.sh` | `74aed2611c9abb507b65697fa1b88834d5e8afe876e12c7d19f1068873e8e751` | `sha256sum binding/v4/s7l-fixture.sh` |
| `binding/v4/BINDING.sha256` | file sha `6c912b961e3df418008e60f61f47566019ffd7f79c6ae1aa29dc6a79d527f52c`; `sha256sum -c` 9/9 OK | `(cd binding/v4 && sha256sum BINDING.sha256 && sha256sum -c BINDING.sha256)` |
| Supervisor `run-prep/supervisor.sh` | `eb9bb86bac4b85cb5e88173882680a92a95f628ac059e2dde789d775827111ce` (also in `RUN_PREP.sha256`) | `sha256sum run-prep/supervisor.sh` |
| Pins inside the driver | `EXPECT_HEAD`/`EXPECT_TREE`/`EXPECT_PARENT`/`EXPECT_WORKER_BLOB`/`EXPECT_FIXTURE_SHA` equal the values above (the supervisor greps them) | `grep -E '^EXPECT_(HEAD|TREE|PARENT|WORKER_BLOB|FIXTURE_SHA)=' binding/v4/s7l-pg-proof.sh` |

## B. Heavy-slot and runtime state (must all hold at launch)

| Item | Expected | Verify with |
|---|---|---|
| Canonical lock file | present, inode 674373 (this sandbox), size 0 | `ls -li /home/user/workspace/execution/test-validation.lock` |
| Lock holders | 0 (the S8-C v4 proof, if still running, holds it — wait for its END, never signal it) | `lslocks \| grep -c test-validation.lock` → `0` |
| postgres processes | 0 | `pgrep -cx postgres` → `0` |
| Other proof/Jest processes | none (`s7l-pg-proof.sh`, `s8c-pg-proof.sh`, jest) | `pgrep -af 's7l-pg-proof\|s8c-pg-proof\|jest'` empty |
| Port 55641 (S7-L) | no listener | `ss -ltn \| grep -c ':55641 '` → `0` |
| Port 55642 (S8-C) | no listener | `ss -ltn \| grep -c ':55642 '` → `0` |
| Fresh lane | `recovery-reset/proof-v4/clusters/s7l` ABSENT (the sibling `proof-v4/clusters/s8-c` may exist, stopped; the driver checks it as another lane and never touches it) | `[ ! -e /home/user/workspace/execution/64e33dc7/recovery-reset/proof-v4/clusters/s7l ]` |
| Fresh socket dir | `recovery-reset/proof-v4/run/s7l` absent or empty | `ls -A …/proof-v4/run/s7l` (error or empty) |
| Fresh OLD root | `recovery-reset/proof-v4/s7l/old-root` ABSENT | `[ ! -e …/proof-v4/s7l/old-root ]` |
| Driver receipts dir | `binding/v4/run/` ABSENT (so `s7l-pg-proof.sentinel`, `s7l-pg-proof.log`, `jest.log`, `RECEIPTS.sha256` are all absent) | `[ ! -e binding/v4/run ]` |
| Once-only markers | `run-prep/LAUNCH.txt`, `run-prep/LAUNCHER.txt`, `run-prep/REFUSED.txt` ABSENT | `ls run-prep/` shows only `supervisor.sh`, `PREFLIGHT.md`, `RUN_PREP.sha256` |
| Builder `node_modules` | real directory (not symlink); `.package-lock.json` `05bc530a…`; `.prisma/client/index.d.ts` `9042e713…` (in-lane generate from schema `0eb41f9a…`) | `sha256sum` (the driver re-verifies and stops on mismatch) |
| Runtime pins (RT-2 receipts) | PG 17.6 `postgres` `23cd1748…`, `initdb` `b7db9bc2…`, `pg_ctl` `af53d826…`, psql 18.6 `a200e38c…`, node `a03953a7…`, `package-lock.json` `b7fed5ed…`, `jest.rls.config.js` `99c9f4f1…`, `pg17/PROVENANCE.txt` `result=success` | `sha256sum` (driver re-verifies all of these itself) |
| Time budget | ≥ 70 min of undisturbed slot (outer `timeout -k 30 3900`; inner soft sum 3165 s) | schedule |

Note on the driver's own preflight: a driver-side PRECONDITION/PREFLIGHT_FAIL (rc70/71, after the flock) writes the sentinel and consumes the single grant, whereas a lock-absent or lock-busy refusal (rc75, driver L76-77, before the sentinel) does not. The supervisor's read-only §B checks exist so that a stale or busy environment refuses *before* the driver is ever invoked.

## C. Launch (executor only, under the explicit PG-4b grant)

```
cd /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v4/run-prep
S7L_PG4_GRANT=1 bash supervisor.sh
```
- The launch-mode process performs the §A/§B refusals read-only, writes `LAUNCH.txt`, then detaches itself (`setsid nohup bash supervisor.sh --child </dev/null >supervisor.stdout 2>supervisor.stderr &`) and returns immediately.
- The detached child runs exactly `timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v4/s7l-pg-proof.sh` once, with stdin `/dev/null`, driver stdout → `run-prep/driver.stdout`, stderr → `run-prep/driver.stderr`; records `SUPERVISOR_START`, `PRE_LAUNCH` (lock holders/postgres/ports, read-only), `TIMEOUT_WRAPPER_PID`, `DRIVER_PID`, `LAUNCHER_EXIT rc=`, `POST` (holders/postgres/port/sentinel contents) and `END` in `run-prep/LAUNCHER.txt`, then hashes `LAUNCH.txt LAUNCHER.txt driver.stdout driver.stderr` into `run-prep/LAUNCH_RECEIPTS.sha256`.
- The supervisor never opens or flocks the canonical lock; only the unchanged driver takes fd9 and holds it to its exit. The supervisor never retries, never sends signals, never invokes a second driver on any rc (including outer-timeout rc 124/137).
- Poll: `cat run-prep/LAUNCHER.txt` until `END`; driver stage log is `binding/v4/run/s7l-pg-proof.log`, Jest output `binding/v4/run/jest.log`, sentinel `binding/v4/run/s7l-pg-proof.sentinel` (`RC= STAGE= END= HEAD= LOCK_INODE=`), driver receipts `binding/v4/run/RECEIPTS.sha256`.
- Tool-call timeouts must not be treated as failure; the detached process continues. Do not launch again if a tool call returns early.
- Afterwards: confirm `lslocks` shows 0 holders, `pgrep -cx postgres` 0, port 55641 free, `proof-v4/clusters/s7l/pg-data` retained with no `postmaster.pid`; then write `binding/v4/run/PROOF_RUN_RECEIPT.md`. A full pass (`END rc=0 stage=done`, Jest 24/24 passed, `applied_migrations` recorded as observed) accepts exactly this candidate; any other result is terminal for this grant and goes to disposition, never to a rerun.

## D. Preparation record

- `supervisor.sh` `bash -n` OK; exactly one real driver invocation line (`timeout -k 30 3900 bash "$DRIVER"` in `--child` mode); no `flock`, no `kill`. Flag gate exercised once with `S7L_PG4_GRANT` unset: `REFUSED rc=70 2026-09-25T16:54:05Z` (first refusal line; nothing else ran, no driver, no lock, no writes beyond the scratch `REFUSED.txt`, which the builder removed before hashing this directory). No other mode was exercised.
- The driver, fixture, bootstrap, PG, Jest were NOT executed. `binding/v4/run/` does not exist. `binding/v4/BINDING.sha256` unchanged (`6c912b96…`); `run-prep/` is outside that manifest and has its own `RUN_PREP.sha256`.
- Prepared while the S8-C v4 proof was running under the canonical lock: the lock, ports, `proof-v4/*/s8-c` and every process were left untouched (this preparation only wrote under `s7l/binding/v4/run-prep/`).
- Modeled on `s7l/binding/v3/run/supervisor.sh` + `LAUNCHER.txt` and `s8c/binding/v4/run-prep/supervisor.sh` + `PREFLIGHT.md`; S7-L specifics: grant flag `S7L_PG4_GRANT`, lane/socket/old-root `proof-v4/{clusters,run,s7l/old-root}` for s7l, sentinel `s7l-pg-proof.sentinel`, driver pin greps include `EXPECT_PARENT` and `EXPECT_WORKER_BLOB`, readability (not exec bit) check because the frozen v4 scripts are mode 644 and invoked via `bash`, extra refusals for a live proof/Jest process and a symlinked `node_modules`.
