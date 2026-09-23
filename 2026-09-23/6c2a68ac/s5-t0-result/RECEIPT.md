# S5 T0 — exact predecessor diagnostic, one granted execution

Executor `repair_s5_binding_mue9vjso` (sole assigned runtime; not an independent auditor). Grant `S5_T0_GRANT.md` sha256 `f167ed7dd9c35d9614e92b8ea55e68e05241ad314d1b80017325462e8f1b63b9`; activation `S5_SETUP_DISPOSITION_AND_T0_ACTIVATION.md` `138d796409b1764348c3e8e9b3e86ae7cfee83421212f6fcef986ecae3a8962a`; qualified prerequisite = frozen setup packet seal `94584aa8…` (installed substrate 12/12 + unchanged bindings + accountable closure; **not** normal setup PASS — see `SETUP_RECEIPT_CORRECTION.md`). One attempt; no retry, repair, cleanup, signal, reinstall, DB, network, hook, generation, lock probe.

## Inputs (fresh `execution/6c2a68ac/s5-t0-input/`, read-only, all four pins exact before and after)
| file | sha256 |
|---|---|
| `controls-v101-t0/ctl-t0-only.v101.sh` | `51fb43b724ce1571a94c75f232651dc473804af85d75f4cfd9b5ef7e1406d62c` |
| `controls-v3/lib.sh` | `a08b762b89f50ef0d272da817b08290e07df326a85ea6759afda7baa0394bed2` |
| `controls-v3/teardown-gate/fake-harness.ts` | `2de5fe248126637b28cd0687fea3e4ce43e0c1552ba6a034b21479fac088ab21` |
| `controls-v3/teardown-gate/jest.control.config.js` | `a6eeb1cd1797388a2f81e5b2980bcc9b62e25852e3cd9923aa8168d482ab5e71` |

All four read completely; `bash -n` clean on both scripts. Preflight (`PREFLIGHT.txt`, 18:04:24Z): HEAD `143d451ead6ccdbebd92ca3031ba7a89867d6cfc`, dirty fingerprint `6850b32ef19436abe5b02f96c770f4c36ca8bea070e0c759310f17234c616aa0`, status = the pinned two `M` files; jest 30.4.2 / ts-jest 29.4.9 / typescript 5.9.3 / jest-circus 30.4.2 all resolved inside the worktree; npm record `05bc530a…`, 651 entries (no reinstall); QUARANTINE/SELF_HOLD absent, LEASE_HOLDER `state=RELEASED(...)`, no lock fd holder (path only stat'ed, never opened), no stale `/tmp/s5-r4-gate-*`, no jest processes, `data/` absent, `S5X_*`/`S5_LEASE_INHERITED` unset, monitor off.

## Command (literal grant text, via the accepted detached caller `caller.sh` `237c6ec3b86de7362665e6b82d042dc766d2a61bd76a78e3a5dafdbef7ee3569`; `set +e +m`; status captured directly, no pipeline)
```
S5_CTL_OUT=/home/user/workspace/execution/6c2a68ac/s5-t0-result/data \
S5_CTL_KEEP=1 S5_CTL_GRANT=granted-by-parent \
timeout --foreground -k 20 140 bash \
  /home/user/workspace/execution/6c2a68ac/s5-t0-input/controls-v101-t0/ctl-t0-only.v101.sh
```
Caller pid 28053 (sid/pgid 28053), start 18:04:38Z, end 18:04:40Z. `driver.stdout` = the driver log; `driver.stderr` 0 bytes; `caller.out` 0 bytes.

## Raw statuses, kept separate
| layer | actual |
|---|---|
| **driver raw** (`t0_driver_raw`, direct return of the `timeout … bash driver` line) | **0** |
| driver FINAL accounting | `AGGREGATE_ELAPSED 2s primary_rc=0 cleanup_rc=0 survivors=0 publication_failures=0`; `SUMMARY pass=6 fail=0` |
| **predecessor Jest child** (pid 28226, own session/pgid 28226, adopted `attempt-NdEQkg`) | **raw=observed 1** (in-shell wait), `validation_rc=1 how=exited state=released session=empty survivors=[]` — the expected nonzero: beforeAll throws |
| Jest summary | `Test Suites: 1 failed, 1 total`, `Tests: 51 failed, 51 total`, `Time: 1.109 s`; `not_the_disposable_db` ×51; `Exceeded timeout` ×0 |
| outer `timeout` | not reached (2 s of nominal 140+20) |

## Six checks (all executed, all PASS, from `data/control-20260923T180438Z.log`)
1. `I0.inputs` — candidate spec copy `01f3cfc0…` byte-identical to the dirty worktree file; predecessor spec `54c85d8d…` from `git show 143d451e:test/rls-g2-pg17-etq0.spec.ts`.
2. `T0.identity` — child 28226 confirmed pgid==sid==pid, direct child, not the caller group 28053 (`IDENTITY: pgid_sid=[28226 28226] self_pgid=28053 self_sid=28053 decoy=none`).
3. `T0.adoption` — IDENTITY published before release, `ADOPT` = `28226 attempt-NdEQkg` verified on the fresh path, rc not 75/76, publication_failures 0, complete IDENTITY/EXIT.
4. `T0.owned` — exit observed by in-shell wait within the 90 s budget; session 28226 POSITIVELY observed empty; `CENSUS RETIRED id=28226 (evidence only)`.
5. `T0.defect` — 3 mutating teardown calls recorded in `data/gate-…-T0.jsonl` after the refusal: `ALTER TABLE "Person" DROP CONSTRAINT IF EXISTS g2p_target_refusal; …`, `resetData` (`DELETE FROM "ScoutReconstructionLedger"; …`), `DELETE FROM "ScoutImport"` (all against the fake recording harness: no connection, no psql, no DB).
6. `T0.refusal_reason` — beforeAll failed at `expect(identity).toMatchObject(...)` with received `"database": "not_the_disposable_db"`; no hook timeout.

Record: 5 JSONL lines (2 reads then 3 mutating). This is the truthful reproduction of the predecessor defect (refusal followed by recorded mutating teardown) — a FAILING predecessor behaviour, not a product PASS and not a database mutation.

## Ownership closure (`POSTRUN_OBSERVATIONS.txt`, 18:05:30Z)
Caller 28053 and leader 28226 gone; sessions 28053/28226 empty; no jest/driver processes; no lock fd holders; lock mtime unchanged (17:51:45Z); `execution/s5-r4` untouched (0 files newer than preflight, QUARANTINE absent, holder still RELEASED). Synthetic root `/tmp/s5-r4-gate-ZcRECI` retained (`S5_CTL_KEEP=1`, 21 entries; node_modules is a symlink to the worktree) and copied to `control-root-copy.s5-r4-gate-ZcRECI/` (== retained root by `SHA256SUMS.control-root`, 10 files). Jest wrote its default transform cache under `/tmp/jest_1jk` (driver-owned Jest behaviour, not the worktree).

## Unchanged inputs/worktree
Four input hashes identical after; setup receipt seal `94584aa8…` re-verifies; HEAD, fingerprint `6850b32e…`, spec `01f3cfc0…`, npm record `05bc530a…` identical; 0 files newer inside `node_modules` or `.git`; index mtime 15:46:28Z. Only the `.git` directory's own mtime advanced (index.lock create/remove by the read-only `git status` in the driver gate and in preflight/postrun) — no file content changed.

## Writes
Executor: `s5-t0-input/**` (4 copies), `s5-t0-result/**`. Driver: `s5-t0-result/data/**`, `/tmp/s5-r4-gate-ZcRECI/**`, Jest cache `/tmp/jest_1jk`. Nothing under the worktree, source, index, modules, setup records, `execution/s5-r4`, `tgp-private-evidence`, Git or remotes.

## Grant acceptance
All six checks executed and PASS; actual nonzero Jest (1) preserved separately from driver raw 0; refusal `not_the_disposable_db` at `toMatchObject`; mutating teardown visible; not a hook timeout; driver raw 0; publication_failures 0; clean attributable final ownership; inputs/worktree unchanged. **Met** within this bounded scope. Bradley decision for T0's bounded local scope: NO (per grant). Nonclaims: no candidate behaviour, real database safety, native reconstruction, integration, customer acceptance or product clearance; Wave 6 remains failed; T1/T2/T3 not rerun; executor runtime identity is unasserted telemetry.
