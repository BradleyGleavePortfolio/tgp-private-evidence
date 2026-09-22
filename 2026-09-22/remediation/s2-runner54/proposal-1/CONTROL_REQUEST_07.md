# SLOT REQUEST 07 — bounded no-DB controls for runner v5.4 + driver v54 (S2-R54-EXECUTION-SAFETY). Request, not a grant.

Inputs (exact bytes): runner v5.4 `3f404479476c5b6a662c946268fd8ed59e3d69c867176431d921aca743604327`; driver `controls-proposed/run-controls-v54.sh` `6638ec06fd517a390546cfd28ae3d2a23398e56a5ee6e98c27872e348889c6a4`; stubs `controls-proposed/stubs/SHA256SUMS.stubs`; frozen v5.3.1 `fb0d7ce4…1bfc` read-only for the `pre` counterexamples; K1 script unchanged `3359b84a…0483`. Any byte change → new request.

Scope: stub mode only (`S2_RUNNER_STUBS`), lane-private lock `controls-proposed/stubs/test-validation.lock`, no PostgreSQL, no network, no canonical lock (file never opened), no product/source/fixture writes, no install. Real head/dirty/lockfile/closure checks inside the runner are real (read-only git). Signals only to pids/groups recorded by the invocation; pre-existing pattern matches → refusal exit 2 without signals.

Four sequential invocations, each its own budget-enforced wall clock (driver stops with nonzero on miss/abort/exhaustion; do not start the next set after a nonzero):
```
cd /home/user/workspace/execution/s2-runner54/controls-proposed
CTL_SET=k    CTL_BUDGET=60 bash run-controls-v54.sh   # K1–K6 regression on v5.4 bytes (historical 30.85 s on v5.3)
CTL_SET=new1 CTL_BUDGET=60 bash run-controls-v54.sh   # K7pre/K7 leader-exits-first, K8pre(info)/K8 inner timeout, K9 unnamed-escape boundary (~25 s)
CTL_SET=new2 CTL_BUDGET=60 bash run-controls-v54.sh   # K10 hanging fixture stop (~25 s)
CTL_SET=neg  CTL_BUDGET=60 bash run-controls-v54.sh   # N1 decoy survives refusal, N2 miss→exit 1, N3 exhaustion→exit 3 (~15 s)
```
Total allowance requested: 4 × 60 s hard (expected ≈ 100 s actual). Resources negligible (sleep/bash). Outputs: `controls-proposed/results/<set>-<utc>/` (CONTROLS_RESULT.txt, per-control driver logs, owned-pids.txt, pre-snapshot.txt, SHA256SUMS) and runner outputs under `runner-selftest-r54/`; `pre` runs additionally write under `s2-setup-prep/runner-selftest-r531/` (additive; the 37 frozen files are unchanged — verify with its SHA256SUMS.outer afterwards).

Expected (positive): set k exit 0 with K2 `final=0 … deadline_exceeded=no … survivors=none` and "recorded groups [...]" before stop, K3 ordering SIGNAL<REAP ok<stop, K4 72/QUARANTINE/no stop, K5 71 with first_exit 0, K6 3; set new1 exit 0 with K7pre reproducing A01 on v5.3.1 (success stamped while the unnamed child lives), K7 `final=70` and child gone, K8 `final=124` and grandchild gone, K9 "BOUNDARY CONFIRMED" (escapee survives v5.4 — labelled limitation, not a pass); set new2 exit 0 with K10 `final=71 first_exit=0 fixture_stop=124 cleanup_seconds 20–27`; set neg exit 0 with child exits 2/1/3 and the decoy alive after refusal.
Expected (negative/abnormal): any miss → aggregate 1 and stop; recorded-owned survivors listed and cleaned only by recorded pid; lane lock FREE at end; canonical lock file untouched.

Not requested: real mode, fixture lifecycle (D3–D6/F6–F9), destroy, proof (06b stays on HOLD), install. Success proves only stub-mode control behaviour of these bytes; independent A/B successor review of v5.4 remains required before any real proof.
