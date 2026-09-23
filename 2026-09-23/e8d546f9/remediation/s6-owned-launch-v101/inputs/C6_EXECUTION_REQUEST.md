# OP88-S6-C6 — frozen C-only execution request (hazard v5 discriminator; NOT executed; no grant implied)

Target: mobile, base `a5933fd6de5616493de75f0db907098b149b955c`, exact product head `d51a191098f483cea9abec6cc7e9f3beffd18c06`, tree `62bf67b88e0f123f1a23ee34a1a75cb43029d9fb`, **unchanged** (restored at `/home/user/workspace/worktrees/s6-diagnostic`, see `S6_C6_PREP.md` §2). This is a discriminator between two hypotheses about the C5 orphan timers; it is not a product fix and cannot produce a clean-baseline or P1 claim.

## 1. Bytes (all under `execution/op88/s6-c6-prep/`; hashes in `MANIFEST.sha256`, runner-checked subset in `c6/MANIFEST.c6.sha256`)
| File | SHA256 | Status |
|---|---|---|
| `c6/inputs/persistedQueryCache.hazardControls.test.tsx` (hazard **v5**) | `a91bb732716b500122e291714bf437872cb81930c020812042f84ed87f6a184d` | NEW = v4 `ee9b94df…bba6` + exact two-hook delta `DIFF_hazard_v4_to_v5.patch` (L140 `await qc.queryClient.cancelQueries();` before the existing `clear()`; `afterAll` made `async` with the same `await` before its existing `clear()`; 3 added lines, 1 changed line; lines 1–136 and the whole `describe` block byte-identical to v4) |
| `c6/inputs/persistedQueryCache.hazardAdapter.tsx` | `3796be8fae738993bcc5c30dd7d4cf9b303329b8faa990ca03e31c2460cd35f3` | unchanged copy |
| `c6/diag/s6diag.{globalSetup,globalTeardown,main,selftest,setupAfterEnv,summarize}.js` | `c0e3f2bb…`, `5b4d6766…`, **`cf470101…c1d0`**, `425ddec6…`, `88d9dd8b…`, `cbf26855…` | unchanged copies, hashes equal to `MANIFEST.v3.1.sha256` entries |
| `c6/run-c6-hazard-v5-conly.sh` | see `MANIFEST.sha256` | NEW additive wrapper derived from V3.1 `b7b328a5…0776` (V3.1 file untouched); every difference is in `DIFF_runner_v3.1_to_c6.patch` and `S6_C6_PREP.md` §4 |
| `c6/c6classify.js` | see `MANIFEST.sha256` | NEW pure-Node post-run outcome classifier (runs in the runner shell after the Jest child has exited; never inside Jest; not part of the instrument) |
| `c6/launch-c6-observer.sh` | see `MANIFEST.sha256` | NEW caller-only observer envelope (detached, errexit off, writes `outer.exit`); not a workload group |
| V3.1 runner, `MANIFEST.v3.1.sha256`, hazard v4, C5 result packet | as preserved | immutable, not replaced |

## 2. Preconditions (all must hold; none holds today)
1. Independent narrow review of this packet frozen (`C6_INDEPENDENT_REVIEW_REQUEST.md`).
2. Parent disposition of the inherited spawn/PGID-registration risk (`C6_SETUP_CORRECTION_REQUEST.md` §3–4): the C6 runner inherits `run_owned` from V3.1 unchanged and therefore carries the same R1/R2 risk; if a correction is adopted, this builder re-freezes the runner and both manifests first.
3. A separately granted, positive, fresh setup on the restored worktree (`C6_SETUP_CORRECTION_REQUEST.md` §5): `node_modules` present in `$WT`, 20/20 strict resolutions, tree clean. Today `node_modules` is absent and the runner would `die provenance-node-modules-absent-setup-not-granted 2`.
4. Exclusive heavy allocation: no other Jest/npm in the sandbox; canonical lock free (the runner takes it on fd 9 and holds it through cleanup; a busy lock is `die lock-busy 75`, no retry).
5. `logs/c6/` does not yet contain `c6.EXIT_RECORD` or `outer.exit` (one run only; the observer refuses otherwise).

## 3. Exact invocation (parent-granted only)
```
bash /home/user/workspace/execution/op88/s6-c6-prep/c6/launch-c6-observer.sh
```
which records `LAUNCH_START.txt` and runs, detached and with errexit off,
```
setsid nohup timeout -k 30 240 bash /home/user/workspace/execution/op88/s6-c6-prep/c6/run-c6-hazard-v5-conly.sh \
  > /home/user/workspace/execution/op88/s6-c6-prep/logs/c6/run-c6.out 2>&1 < /dev/null ; echo $? > …/logs/c6/outer.exit
```
Bounds: inner `BUDGET=180` (selftest 15 + 5, C 90 + 20 — identical per-step budgets to C5's selftest and C), external 240 + 30. Installed `timeout` is uutils 0.8.0, not GNU: its wait status on a fired bound is to be **read from `outer.exit`**, not assumed 124/137. Steps: provenance → manifest → strict module paths → two declared untracked copies with v5/adapter fingerprint gates → selftest → **C only**. No A/B/D repetition, no `--forceExit`/`--detectOpenHandles`, no install, no product byte change.

## 4. Pre-declared outcomes (fixed before any run; `c6classify.js` prints `C6-OUTCOME=` and the runner copies it into `c6.EXIT_RECORD`)
| Outcome | Raw predicate (all post-teardown snapshots: `globalTeardown`, ticks, `SIGTERM`) | Meaning (and only this) |
|---|---|---|
| **(i)** `i-TWO-RESIDUAL-removeObserver-HANG` | `Tests: 6 passed, 6 total`, `overlapping act` = 0, mode line present; exactly **2** refed `Timeout` `delayMs 600000` at every snapshot, both stacks `Query.removeObserver (query.ts:377)`, creation instants (snapshot `t` − `ageMs`) at the T3/T4 `recommit` points; `how=budget-TERM` (rc 143) or `budget-KILL` (137) | supports `S6_C5_REVIEW_B.md` §3b attribution: the two in-case `signOut` orphans are unreachable from hooks; hook-only fix insufficient. Next decision is product-side (dual T4 review) or explicitly accepted test-side masking — neither is granted by this result |
| **(ii)** `ii-ZERO-CLEAN-EXIT` | 6/6, 0 overlap, mode line; **0** × 600000 at every snapshot; `how=exited`, rc 0, `beforeExit` event present | refutes the in-case attribution; hook fix sufficient for this file. Still not a clean-baseline/P1/app claim |
| **(iii)** `iii-FIVE-ORDERING-HYPOTHESIS-FAILED` | 6/6, 0 overlap, mode line; **5** × 600000 at every snapshot; hang | `cancelQueries()`-before-`clear()` ordering hypothesis (review L-3, thenable microtask order) is wrong; the proposal is ineffective |
| **(iv)** `iv-DIVERGENCE-STOP` | Tests line ≠ 6/6, or any `overlapping act`, or mode line absent (evaluated first) | perturbation divergence: STOP, do not interpret counts; preserve logs |
| `UNCLASSIFIED*` | anything else (1/3/4 timers, mixed paths, count changing across snapshots, hang with 0, exit with >0, no snapshot) | report raw; do not relabel into (i)–(iv) |

## 5. Authoritative raw exit capture (three separate records; never merge)
- **Child first exit**: `c6.EXIT_RECORD` line `step=C first_exit rc=<n> how=<exited|budget-TERM|budget-KILL>` (from `wait`), plus `c6.C.summary.txt` `exit_event=`/`beforeExit=` from the instrument.
- **Runner FINAL**: `c6.EXIT_RECORD` `FINAL rc=<n>` (primary rc preserved; any cleanup evidence forces nonzero/90). For (i)/(iii) FINAL is 143; for (ii) FINAL is 0 — **neither is acceptance**. Cleanup truth is read from the record lines `cleanup_exit=0` (selftest, C), `ancestor_inventory … UNCHANGED`, two `copy … removed (hash-guarded…)`, `worktree porcelain after cleanup: 0 line(s)`, `CLEANUP_FAILURES=0`, `final owned pgid=… members=[]`. No `FINAL` line ⇒ not a result.
- **Outer wait**: `logs/c6/outer.exit` written by the detached observer (`LAUNCH_END.txt` timestamps it). This closes the C5 gap; if absent, say so — do not reconstruct.
Outputs: `logs/c6/{LAUNCH_START.txt,LAUNCH_END.txt,observer.out,outer.exit,run-c6.out,c6.EXIT_RECORD,c6.provenance.txt,c6.manifest-check.txt (empty on success),c6.module-paths.txt,c6.fingerprint.txt,c6.selftest.out,c6.selftest.inventory.jsonl,c6.C.jest.log,c6.C.inventory.jsonl,c6.C.summary.txt,c6.C.checks.txt}`.

## 6. Recovery and non-claims
Owned groups only; on any survivor the runner quarantines and stops (M-1), nothing is retried or `--forceExit`ed; a retained copy is reported with its hash, never deleted. Original v4, C5 evidence, V3.1 runner and instrument stay immutable. Success of any outcome does not prove app harmlessness, historical C2–C4 cause, baseline/P1/native/import/release acceptance; final changed product still requires two independent exact-head attestations.
