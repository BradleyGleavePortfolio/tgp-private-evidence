# S6 actual setup and C6-only: separate conditional grants

Parent EXEC-6c2a68ac, 2026-09-23. BOTH STAGES NOT ACTIVE. Each requires its own explicit parent activation and returned canonical runtime slot. Setup additionally requires both independent final-composition attestations; C6 additionally requires parent acceptance of actual setup. No new private-control layer.

## Scope, identity and ownership

Each stage individually T4, cumulative T4: privacy-sensitive behavior, trusted evidence/exclusion and recovery; T3 lifecycle/dependency triggers; bounded T1 NO. Sole executor `restore_s6_substrate_mue9osen`, requested Claude Fable 5 / High. Parent evaluates evidence; existing independent nonbuilders attest source, executor does not audit itself.

Exact source packet `execution/6c2a68ac/s6-exclusion-v1`, seal `001b840f721db38734a12f0db937655f2ff33d99a8a03da807724e45e698b9a4`,28 entries:

| Stage | Launcher hash | Colocated runner hash |
|---|---|---|
| Setup | `launch-s6-setup-exclusion.v1.sh` = `6035a8f4d726b65afcb381d82903f2b1cfe22602860eda72e84a5afe61a43624` | `run-c5-setup-npm-ci.v101y.sh` = `8a5a5161cc44ad349bc1923b54217bff84d5ba725a38d46c1adcaad6facf6633` |
| C6 | `launch-s6-c6-exclusion.v1.sh` = `ad8130e9b5acd5e222817335c26e971ddf0bd69e858cfaa117568b1af8310a78` | `run-c6-hazard-v5-conly.v101y.sh` = `692f8db79a283135d1a609bfcb99b1fd81bf09a527692af332805976f755bc66` |

Launch directly from this sealed packet with the correctly named sibling, not the historical observer or runner. Other sealed files in the packet do not change the selected runner. All primitive bytes remain4aebf96f; applicable S5 V32 private11PASS and earlier primitive25PASS are not rerun.

Product worktree `worktrees/s6-diagnostic`: head `d51a191098f483cea9abec6cc7e9f3beffd18c06`, tree `62bf67b88e0f123f1a23ee34a1a75cb43029d9fb`, lock blob `6c56385d33db5fa703f8dc37a78381b8e2ba89a1`, lock SHA-256 `840be0b8d5f4ed8272afd20290c8ebf6f6dacc394e6edae4ae5403e9fabe6b69`. Product/source baseline unchanged.

## Common frozen boundary

Read the exact stage's launcher/runner completely before invocation. After activation, record current pins/clean tree, needed tool identities/non-root/job-control-off, available disk/memory, absence of ancestor `/home/user/package.json`, fresh inner logs with no prior EXIT_RECORD, and no unresolved prior holder or marker at the four exact paths in the launchers. Use one attributable precondition census to establish no competing npm/Jest workload; do not signal or remove foreign work. Parent scheduling and the launcher's canonical nonblocking acquisition govern the slot, not a new independent lock-probe program.

Canonical mode only: unset all `S5X_*` overrides and inherited S6 lease variables in the launching environment. Use the matching stage grant variable, not a stale grant. The launcher retains fd9 through positive outer/every-inner session closure; do not put a timeout around this last holder and do not invoke the frozen C6 observer. Preserve actual raw launcher wait where observed, runner FIRST_EXIT/FINAL, cleanup/publication and release records separately. Unknown/live ownership or publication failure retains the holder; no manual signal, recovery, marker removal, retry, outer timeout or cleanup is authorized.

Accepted detached `setsid nohup` transport and raw-status capture are allowed. Source remains immutable. Read-only progress/identity/fd observations and hashes may establish the actual result and closure, not fabricate a release. No peer paths, private checkout, product commit/push, deployment, browser/source-account access or customer work.

## Stage S6-SETUP

One fresh install, after explicit activation only. `node_modules` must be absent; `execution/s6-diagnostic` and its inner setup logs must be fresh. Do not restore again or delete a partial installation.

Command payload:

```sh
setsid nohup env CHECKPOINT_DISABLE=1 S6_SETUP_GRANT=granted-by-parent \
  bash /home/user/workspace/execution/6c2a68ac/s6-exclusion-v1/launch-s6-setup-exclusion.v1.sh
```

Redirect to fresh `execution/6c2a68ac/s6-setup-result/` and retain exact command/launch/status evidence. This executes only the frozen `npm ci --no-audit --no-fund --loglevel=error --logs-dir=... --logs-max=10`, with existing1200/30 workload budget and1290/30/1380 launcher bounds. The frozen S6 command intentionally does NOT use `--ignore-scripts`; its lock-bound dependency lifecycle/prepare behavior is authorized here, including attributable local hook installation if produced. Do not transplant S5's different npm argv or run extra hooks/tests/generation.

Sole writes: worktree node_modules and attributable declared npm lifecycle output/Git hook metadata, ordinary npm cache and exact-lock registry reads, `execution/s6-diagnostic/**`, canonical lock through the launcher, and `execution/6c2a68ac/s6-setup-result/**`. Ancestor/platform node_modules and product tracked/index bytes must remain unchanged.

Acceptance: actual npm raw0, cleanup0, unchanged within-run ancestor inventory, clean product tree/lock, all20 strict module resolutions inside the worktree, runner FINAL0, launcher actual raw/final0 with valid release and no attributable survivors. Record any lifecycle/hook output honestly. Freeze result/manifest and release runtime. No setup audit is automatically added; parent directly evaluates frozen criteria. Success enables a separate C6 activation, not product clearance.

## Stage S6-C6-ONLY

After separate parent acceptance of actual setup20/20 and explicit activation. No reinstall or repeated A/B/D diagnostics. Verify unchanged workload packet `execution/op88/s6-c6-prep/MANIFEST.sha256` = `04d761f0421cfbdc99058bbbcf9c5ad4d420a76ae45b258c33c0ed0e925709a6`19 entries and `c6/MANIFEST.c6.sha256` = `34d3c3586f99a8873dff23e3485d8cae5608784efce17b7d3bcb05206926976d`11 entries. Existing hazardv5a91bb732, adapter3796be8f, instrumentcf470101 and classifier2715cf11 stay unchanged.

Command payload:

```sh
setsid nohup env S6_C6_GRANT=granted-by-parent \
  bash /home/user/workspace/execution/6c2a68ac/s6-exclusion-v1/launch-s6-c6-exclusion.v1.sh
```

Redirect to fresh `execution/6c2a68ac/s6-c6-result/`, preserving actual raw status. Sole writes: frozen runner's two declared untracked worktree test copies with its own hash-guarded cleanup, `execution/op88/s6-c6-prep/logs/**` and associated holder records, canonical lock through the launcher, and result packet. No network, install, product edits, hooks or original packet-byte changes. Run existing selftest15/5 then C90/20 only, runner budget180 and launcher240/30/300 unchanged. No `--forceExit`, extra negative controls or test-selection change.

The original `C6_EXECUTION_REQUEST.md` sections4–6 govern outcomes, except the obsolete observer topology is replaced by this exact reviewed O-A launcher. Preserve six-assertion/mode/overlap evidence, every raw inventory and C6-OUTCOME:

- i: two removeObserver residual timers plus hang; supports in-case orphan hypothesis, not acceptance.
- ii: zero timers and clean exit; hook fix sufficient for this file only, not app/native/P1 acceptance.
- iii: five timers plus hang; ordering hypothesis failed.
- iv: assertion/mode/overlap divergence; stop interpretation.
- UNCLASSIFIED: report raw, never relabel.

Neither raw0 nor143 means product acceptance. Require attributable complete execution/classification, separated child/runner/launcher statuses, cleanup/publication/ancestor truth, and actual released ownership; retain unknown or failed results exactly. Parent chooses the next product/proof action from observed evidence, not a new framework.

## Stops and authority

A concrete failure/timeout/unresolved ownership or unexpected write stops the affected stage without retries or recovery. An expected C6 budget-TERM outcome is classified under the frozen hypothesis table, not erased. Do not remove partial installs or unresolved holders. Bradley decision required: NO for these bounded local scopes; runtime remains inactive until each explicit activation.
