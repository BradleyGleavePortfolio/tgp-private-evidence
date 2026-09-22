# S6 C5 V3 — execution-only successors (frozen; NOT executed; no grant requested yet beyond what the parent decides)

Prepared per `EXECUTION_REPAIR_WAVE_2.md` §"S6 plan disposition" and reviewer B `audits/s6-v2-plan/b/REPORT.md` (read in full). No product/source edit, no npm, no Jest, no controls. V1/V2 packets and all receipts immutable (`MANIFEST.sha256`, `v2/MANIFEST.v2.sha256` still verify). Only `bash -n`, `node --check`, `sha256sum`, `grep` on the lockfile and file copies were performed.

## Frozen bytes — `v3/MANIFEST.v3.sha256` (non-self-including, verifies from `v3/`)
| File | SHA256 | Lineage |
|---|---|---|
| `diag/s6diag.main.js` | `cf4701010365cb87326c17c901c4f6c941b84ea5d3dceb3f4c5e38c21e51c1d0` | exact positive-self-checked V3 instrument (B-01 closed) |
| `diag/s6diag.selftest.js` | `425ddec601bd5c1d53fa23833ad433afafec648c827ef2ed15659871c8276a28` | unchanged |
| `diag/s6diag.globalSetup.js` / `globalTeardown.js` / `setupAfterEnv.js` / `summarize.js` | `c0e3f2bb…ab9c` / `5b4d6766…3e42` / `88d9dd8b…8846` / `cbf26855…6e06` | byte-identical to V1/V2 |
| `diag/specs/s6diag.{A,B,D}.*.test.js` | `e8c07fcc…06c` / `78f98d1a…2630` / `6a3be8a8…95c8` | byte-identical to V1/V2 |
| `run-c5-resource-inventory.v3.sh` | `1664fd4776d95c83353bba869def899660099d6be811f311c75e0c352c35f69f` | successor of V2 `a38994e4…2120` |
| `run-c5-setup-npm-ci.v3.sh` | `91fe0f1b1db951a3d41b34afba528bb2e3815ba89f0154b917aeb01d9b197bd1` | successor of V2 `6fa69510…3324` |
Inputs unchanged: hazard v4 `ee9b94df…bba6`, adapter `3796be8f…35f3` (`../inputs/`, `../MANIFEST.sha256`).

## Diagnostic runner V3 — finding map (66 changed lines vs V2 after version-token normalisation; supervision core unchanged)
- **B-01 binding:** `DIAG=$EX/v3/diag`, manifest check `MANIFEST.v3.sha256`, logs `logs/v3/c5v3.*`. All five hooks/specs the run needs are in `v3/diag`.
- **B-02:** strict list = the 20 modules present as top-level `node_modules/<name>` entries in the d51 lockfile (verified by grep: each 1 match; `@babel/preset-env` 0 matches → removed); `require.resolve` wrapped in try/catch → `BAD <m> unresolved` line + rc 1 → `die module-paths 5` with the reason in `c5v3.module-paths.txt`. Same 20-name list as the setup after-check.
- **B-03:** the five untracked copies are tracked by `COPIES_PLACED`; at finish, each is removed **only if** `sha256(copy) == sha256(frozen source)`; otherwise retained and reported (`RETAINED: bytes differ`) and counted as a cleanup failure. Worktree porcelain after cleanup logged.
- **B-04:** children started with `9>&-` (lock fd not inherited).
- **B-06:** C's expected preserved hang = `how=budget-TERM rc=143` **or** `how=budget-KILL rc=137`, each with ≥1 post-teardown snapshot; wording in runner and here.
- **Fail-closed (parent):** `CLEANUP_FAILURES` counts any nonzero per-step `cleanup_exit`, owned-group survivor at final accounting, ancestor-inventory CHANGED, or retained copy. `finish <primary>`: if `CLEANUP_FAILURES>0` and primary rc was 0 → FINAL rc 90; nonzero primary keeps its rc. `FIRST_EXIT` always recorded before FINAL and never altered. `final_accounting` idempotent (`ACCOUNTED`), so the EXIT trap no longer duplicates lines.
- Unchanged: lock on fd 9 held by runner to exit; `setsid` owned PGIDs; zombie-aware poll; per-step budgets selftest 15+5, A 45+15, B 45+15, D 60+15, C 90+20; inner `BUDGET=360`; external `timeout -k 30 420`; six-assertion / zero-overlapping-act / mode-line checks on C; `C-PERTURBATION-DIVERGENCE` if C exits on its own.
- B-07 (root vs evicted label) left as a documented limitation — would change the instrument hash; not needed for interpretation.
- Note: step 0 re-runs the V3 self-check inside the run (15+5 s). Parent said the known-positive instrument need not be self-tested again for unchanged bytes; it is kept because it is cheap and pins the runtime, but can be treated as informational.

Invocation (when granted; after setup):
```
mkdir -p /home/user/workspace/execution/s6-diagnostic/logs/v3 && \
setsid nohup timeout -k 30 420 bash /home/user/workspace/execution/s6-diagnostic/v3/run-c5-resource-inventory.v3.sh \
  > /home/user/workspace/execution/s6-diagnostic/logs/v3/run-c5.v3.out 2>&1 < /dev/null &
```
Positive: `c5v3.EXIT_RECORD` has provenance/manifest/module-paths/copy-inputs rc 0; A `PROCESS_EXITED_ON_ITS_OWN`; B rc 0; D rc 0 (or documented D-HANG); C `Tests: 6 passed, 6 total`, `overlapping_act 0`, mode line present, `how=budget-TERM|budget-KILL`, ≥1 snapshot after `globalTeardown` in `c5v3.C.inventory.jsonl`; `CLEANUP_FAILURES=0`; ancestor UNCHANGED; all five copies removed; porcelain 0. Negative: any `STOP_FIRST_FAILURE`, FINAL 90, retained copy, survivor, or C exiting cleanly (perturbation divergence — not success).

## Setup successor V3 — finding map
- **Parent Q1 (V2 line 82):** post-install `reap_group` rc captured (`CE`); nonzero → `CLEANUP_FAILURES++`; owned survivors at final accounting also counted; `finish 0` becomes FINAL rc 90 with the primary `npm-ci rc=0` preserved in `FIRST_EXIT`; node_modules state then declared unverified.
- **Parent Q2:** ancestor `/home/user/node_modules` inventory (names+mtimes hash) equality is a GATE: CHANGED → `CLEANUP_FAILURES++` → FINAL ≠ 0. The runner never writes there.
- **B-04:** `9>&-` on the npm child.
- **B-05 (disclosed, unchanged):** `npm ci --no-audit --no-fund --loglevel=error --logs-dir=<evidence>/logs/setup-v3/npm-logs --logs-max=10` without `--ignore-scripts` (same as C1's successful install; project has no prepare/postinstall; third-party lifecycle scripts and `$HOME/.npm` writes are inherent to the grant). Parent may require `--ignore-scripts`; that would be a one-token change and new hash.
- Unchanged guards: runner-held lock, cwd==WT, HEAD d51, clean tree, `node_modules` absent before (one install only), `/home/user/package.json` absent, budget 1200+30 s owned-group TERM/KILL, tree clean after, lockfile sha unchanged, strict 20-module resolution.

Invocation (when granted; S2 must have released the canonical lock, else rc 75 fail-closed):
```
mkdir -p /home/user/workspace/execution/s6-diagnostic/logs/setup-v3 && \
setsid nohup timeout -k 30 1290 bash /home/user/workspace/execution/s6-diagnostic/v3/run-c5-setup-npm-ci.v3.sh \
  > /home/user/workspace/execution/s6-diagnostic/logs/setup-v3/run-setup.out 2>&1 < /dev/null &
```
Positive: `setup.EXIT_RECORD` `FIRST_EXIT npm-ci rc=0 how=exited`, `cleanup_exit=0`, ancestor UNCHANGED, `CLEANUP_FAILURES=0`, `FINAL rc=0`; `setup.module-paths.txt` 20× `OK … /worktrees/s6-diagnostic/node_modules/…`; porcelain 0. Negative: anything else; partial `node_modules` is reported, never retried.

## Unchanged
Ownership question, hypotheses H-A'…H-E, discriminator and what success does not prove: `../C5_PROPOSAL.md` §2/§4/§5/§9. Receipts: `../logs/selftest/` (V1 rc 1), `../logs/selftest-v2/` (V2 rc 3), `../logs/selftest-v3/` (V3 rc 0). Ungranted-probe disclosure: `../v2/UNGRANTED_PROBE_DISCLOSURE.md`. Worktree d51 clean, `node_modules` absent.
