# OP88-S6-C6-PREP — bounded two-hook hazard v5 discriminator preparation (report)

Builder: new S6 canonical builder (Fable per brief and owner amendment; actual runtime model/settings are not observable and are not asserted). Not the C5 auditor; no current peer output read other than the frozen `S6_C5_REVIEW_B.md` named as input. Sole writes: `execution/op88/s6-c6-prep/**` and the fresh, exclusively reserved `worktrees/s6-diagnostic` (source restoration only). No installs, tests, controls, Jest, probes, product/runner/instrument edits, commits or hooks. Allowed checks used: read, `sha256sum`, `diff`, `git` verification of the bundle, `bash -n`, `node --check`.

Product head `d51a191098f483cea9abec6cc7e9f3beffd18c06`, tree `62bf67b88e0f123f1a23ee34a1a75cb43029d9fb` — **unchanged**. This is a discriminator, not a product fix, and produces no clean-baseline, P1, native, import or release claim.

## 1. Inputs verified (`INPUTS.sha256`)
Governing: `OP88_WAVE1.md` (now `852429e7…`, contains §OP88-S6-C6-PREP; the C5 review bound an earlier `af46e2ce…` revision), `AGENT_RULES.md` `edd63115…`, `LAST_OPERATOR_STATE.md` (now `0d5cf67f…`, 21:01Z revision), `LAST_OEPRATOR_HANDOFF.MD` `a432be98…`, frozen `S6_C5_REVIEW_B.md` `2398cc9d…` (= its `MANIFEST.sha256` entry; unchanged).
Lane inputs: hazard v4 `ee9b94df…bba6`; adapter `3796be8f…35f3`; V3.1 runner `b7b328a5…0776`; `MANIFEST.v3.1.sha256` `1be2a176…` (10 entries; the six `diag/*` instrument files copied here re-hash identically, `s6diag.main.js` = `cf470101…c1d0`); setup `run-c5-setup-npm-ci.v3.sh` `91fe0f1b…7bd1` and its positive record; product bundle `s6-r3.bundle` `c0ad2994…9662`; pinned `lib-src/query-core_5.100.14_src_queryClient.ts` `33376a5b…` (`cancelQueries(): Promise<void>` = `findAll().map(q => q.cancel({revert:true,…}))`, `Promise.all(...).then(noop).catch(noop)`).

## 2. Exact source restoration (worktrees/s6-diagnostic; not a test, not a claim)
`git clone --no-hardlinks --no-checkout source/mobile` (baseline `a5933fd6…`, clean, untouched) → `git bundle verify` OK (bundle requires `a5933fd6…`, contains `refs/heads/execute/20260921-s6-r3` = `d51a1910…`) → fetch bundle ref → `checkout --detach d51a1910…`. Observed: HEAD/tree match the brief; base is ancestor; 15 commits over base; porcelain 0; `node_modules` absent; `package-lock.json` blob `6c56385d…`/sha `840be0b8…` and `package.json` sha `63e2e2e2…` equal the historical setup provenance; product lines cited by the review confirmed at head (`src/services/queryClient.ts:45` `gcTime: 10 * 60_000`; `src/services/authActions.ts:352` `queryClient.clear()`); `jest.setup.js` present; Jest config in `package.json` (`preset: jest-expo`, `setupFilesAfterEnv <rootDir>/jest.setup.js`); lockfile pins `@tanstack/query-core 5.100.14`.
Observation only (outside this lane; reported, not acted on): of the 15 commits over base, 7 carry author+committer `BradleyGleavePortfolio <264851314+…@users.noreply.github.com>` (`ed0342e` = #290 head, `d2f0d31` = #291 head, `3408867` = #292 head, `2235498`, `ba3fd40`, `8f0b584`, `4be69b9`) and 8 carry `Bradley Gleave <bradley@bradleytgpcoaching.com>` (incl. head `d51a191`); the review's §0 "author+committer Bradley Gleave" is therefore not literally true for every commit in the bundle. Historical preserved PR heads; no change requested here.

## 3. Hazard v5 — exact two-hook delta (`DIFF_hazard_v4_to_v5.patch`)
v5 `c6/inputs/persistedQueryCache.hazardControls.test.tsx` = `a91bb732716b500122e291714bf437872cb81930c020812042f84ed87f6a184d` (266 lines; v4 264).
```
 afterEach(async () => {
   await cleanup();
   jest.restoreAllMocks();
+  await qc.queryClient.cancelQueries(); // v5 …
   qc.queryClient.clear();
 });
-afterAll(() => {
+afterAll(async () => {
+  await qc.queryClient.cancelQueries(); // v5 …
   qc.queryClient.clear();
   qc.queryClient.unmount();
 });
```
Verified by `diff`: v4 L1–136 == v5 L1–136; v4 L146–264 == v5 L148–266 (whole `describe`, six `it` blocks, `MeProbe`, `mountForCurrentInputs`/`recommit`, `beforeEach`, `THROTTLE_IDLE_MS`, both in-case `signOut('user-B')` at v5 L234/L253 and both following `recommit()` L237/L255 untouched). No unmount-before-`signOut`, no timer masking/`unref`/`gcTime`/`--forceExit`, no assertion or overlap-check change. The header comment (v4 lineage lines 2–16) was deliberately left as-is to keep the delta literally to the two hooks; the C6 runner header and this report carry the v5 provenance. Mounted/in-flight `signOut` preconditions are preserved because nothing in v5 runs inside a case; the added `await` executes only after `cleanup()` in `afterEach` and in `afterAll`.

## 4. Runner: additive C-only wrapper, V3.1 untouched (`DIFF_runner_v3.1_to_c6.patch`; 66+/53− lines incl. header, 34+/45− non-comment)
`c6/run-c6-hazard-v5-conly.sh` derived from `b7b328a5…` (which is not modified anywhere). Declared differences, each necessary:
| Kind | V3.1 | C6 | Why |
|---|---|---|---|
| paths | `EX=execution/s6-diagnostic`, `V3=$EX/v3`, `DIAG=$V3/diag`, `IN=$EX/inputs`, `LOGS=$EX/logs/v3.1`, `c5v3.*` | `C6=execution/op88/s6-c6-prep/c6`, `DIAG=$C6/diag`, `IN=$C6/inputs`, `LOGS=execution/op88/s6-c6-prep/logs/c6`, `c6.*` | fresh workspace has no `execution/s6-diagnostic`; outputs must land in this builder's owned dir. `WT`, `LOCK`, `S6DIAG_WT`, env, `taskset` unchanged |
| manifest | `MANIFEST.v3.1.sha256` in `$V3` | `MANIFEST.c6.sha256` in `$C6` (non-self-including: `diag/*`, `inputs/*`, `c6classify.js`, `launch-c6-observer.sh`, runner) | new packet identity; instrument hashes inside it equal the V3.1 entries |
| inputs | five copies (hazard v4 gate `ee9b94df`, adapter, A/B/D specs) | two copies (hazard **v5** gate `a91bb732`, adapter `3796be8f`); `copy_source` collapsed to `$IN/$1` | v5 replaces v4; A/B/D are a brief non-goal |
| steps | selftest → A → B → D → C | selftest → C | brief: C-only; selftest kept because the install is fresh and the instrument must fit before its observation is trusted |
| budget | inner 360; per-step selftest 15+5, C 90+20 | inner 180; **same** per-step budgets | five steps → two; same C window keeps tick snapshots +1/3/6/10/20/40/70 s comparable with C5 |
| outcome line | `[ how = exited ] && "C-PERTURBATION-DIVERGENCE"` | `node c6classify.js … → C6-OUTCOME=` copied into `EXIT_RECORD`; `C-BEHAVIOURAL-DIVERGENCE`/`C-OVERLAPPING-ACT` lines kept and marked outcome (iv) | under v5 a clean exit is pre-declared outcome (ii), not a divergence |
| removed | `CONTINUE_AFTER_D_HANG` | — | no D step |
Unchanged and verified present by reading the diff: `set -u`, lock fd 9 + `9>&-`, owned setsid groups, zombie-aware `alive`, `run_owned` budget/grace/TERM/KILL, `reap_group` refusal of unowned pgids, M-1 stop on cleanup survivors, M-2 rm-failure count + porcelain gate, ancestor inventory gate, provenance HEAD gate, strict 20-module resolution, hash-guarded copy removal, `finish` fail-closed, `on_signal`/`on_exit` traps. `bash -n` OK; `node --check c6classify.js` OK; `bash -n launch-c6-observer.sh` OK.

## 5. Pre-declared outcomes and capture
Fixed in `C6_EXECUTION_REQUEST.md` §4–5 and implemented mechanically in `c6/c6classify.js`: (i) 2 residual 600000 ms `Query.removeObserver` timers at every post-teardown snapshot + hang ⇒ supports hook-fix insufficiency / §3b attribution; (ii) 0 + clean exit (`beforeExit`) ⇒ refutes attribution; (iii) 5 ⇒ cancellation-order hypothesis failed; (iv) any six-assertion/overlap/mode divergence ⇒ STOP (checked first); anything else `UNCLASSIFIED`. Authoritative raw captures: child `step=C first_exit rc= how=` (from `wait`), runner `FINAL rc=` plus the cleanup record lines, and the **outer** `timeout` wait status in `logs/c6/outer.exit` written by the detached, errexit-off observer `c6/launch-c6-observer.sh` (closes the C5 §5 gap; installed `timeout` is uutils 0.8.0, so the value is read, not assumed).

## 6. New prerequisite received 14:06 PDT (parent mail) — inherited spawn/PGID registration
Inspected and recorded in `C6_SETUP_CORRECTION_REQUEST.md`: setup `91fe0f1b` L86–87 and the C6 runner's `run_owned` L156–161 / `on_signal` L137 (inherited unchanged from V3.1, as is the S5 setup `74736a58` L91) spawn with `setsid … &`, `sleep 0.2`, sample `ps -o pgid=`, then register. Concrete risks: R1 a TERM during the window is handled after `sleep` with `CUR_PGID` empty ⇒ no reap, child (own session, unreachable by `timeout`'s group signal) survives while the census prints nothing and `CLEANUP_FAILURES=0`; R2 the sample can read the runner's own pgid before the child's `setsid(2)` ⇒ later `reap_group` TERMs the runner/timeout themselves; R3 the fallback relies on non-interactive-shell `setsid` no-fork behaviour that nothing asserts. Disposition: neither the unchanged setup nor the C6 runner is claimed mechanically grantable; a minimal register-by-confirmation shape is **proposed, not applied** (shared primitive across four scripts → single owner via parent; deterministic negative control required). If adopted, this builder re-freezes the C6 runner and both manifests; hazard v5 and instrument bytes do not change.

## 7. Implemented / tested / unrun
Implemented: hazard v5 bytes; C6 additive runner; `c6classify.js`; `launch-c6-observer.sh`; `MANIFEST.c6.sha256`; two diffs; execution, setup-correction and independent-review requests; exact source restoration at `worktrees/s6-diagnostic`. Tested: **nothing** (no Jest, node runtime, npm, controls or probes). Verified read-only/static: all hashes; bundle/head/tree/ancestry/clean status; byte-identity of untouched regions; `bash -n`/`node --check`. Unrun: setup, selftest, C step, classifier on real data, observer envelope, every pre-declared outcome. Unknown/unproven and left so: which hypothesis holds; app impact; C2–C4 cause; outer status of any run; uutils `timeout` semantics.

## 8. Remaining blockers (in order) and one smallest next action
Blockers: (B1) independent narrow review of this packet (`C6_INDEPENDENT_REVIEW_REQUEST.md`); (B2) parent disposition/owner for the spawn-registration primitive (§6) and, if adopted, re-freeze of the C6 runner; (B3) a separately granted positive fresh setup on the restored worktree (network egress and exclusive allocation explicit); (B4) then one C-only run under `C6_EXECUTION_REQUEST.md`. **Smallest next action:** parent assigns B1 and names the single owner for B2; nothing here executes before both.

## 9. Manifests
`MANIFEST.sha256` — every file in this packet except itself (non-self-including). `INPUTS.sha256` — external inputs bound above. `c6/MANIFEST.c6.sha256` — the subset the runner verifies at step 1. Outputs (`logs/`) do not exist yet.
