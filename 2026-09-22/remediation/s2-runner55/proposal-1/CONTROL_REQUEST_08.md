# SLOT REQUEST 08 — bounded no-DB controls for runner v5.5 + driver v55. Request, not a grant (07 stays on parent HOLD; this supersedes it for the new bytes).

Inputs: runner v5.5 `c3a4d2a9a234dda141122a44d46a3902a8575001a26ffcadc2029080a768de49`; driver `controls-proposed/run-controls-v55.sh` `a5a2d73f8b0138362ef391c4cbd58ea846673be1846bfaf92561bde2a538312c`; stubs per `controls-proposed/stubs/SHA256SUMS.stubs`; K1 `3359b84a…` unchanged; frozen v5.3.1 `fb0d7ce4…` read-only (pre counterexamples). Any byte change → new request.

Scope: stub mode only, lane-private lock `controls-proposed/stubs/test-validation.lock`, no PostgreSQL/network/canonical lock/install/product/fixture writes. Signals only to identity-confirmed enclosure groups and recorded pids created by the invocation; pre-existing pattern matches → exit 2 without signals. Do NOT wrap the invocations in an external foreground `timeout` (would strand descendants); the driver enforces its own aggregate deadline including kill grace and a watchdog on the current exclusive enclosure.

Sequential, one attempt each, stop at the first nonzero (1 miss, 2 abort, 3 budget, 4 handoff failure):
```
cd /home/user/workspace/execution/s2-runner55/controls-proposed
CTL_SET=k    CTL_BUDGET=90 bash run-controls-v55.sh   # K1–K6 on v5.5 (declared maxima incl. grace sum to 85 s; historical actual ≈31 s)
CTL_SET=new1 CTL_BUDGET=60 bash run-controls-v55.sh   # K7pre/K7, K8pre(info)/K8, K9 boundary (≈25 s)
CTL_SET=new2 CTL_BUDGET=60 bash run-controls-v55.sh   # K10 hanging stop with owned stop group (≈30 s)
CTL_SET=neg  CTL_BUDGET=90 bash run-controls-v55.sh   # N1 decoy survives refusal, N2 miss→1, N3 exhaustion→3 (nested enclosed drivers, ≈30 s)
sha256sum -c --quiet /home/user/workspace/execution/s2-setup-prep/SHA256SUMS.outer   # after new1: frozen 37 files untouched
```
Allowance: 90+60+60+90 s hard (expected ≈120 s actual), negligible CPU/RAM. Outputs `controls-proposed/results/<set>-<utc>/` (CONTROLS_RESULT.txt, per-control logs, owned-pids.txt, owned-history.txt, pre-snapshot.txt, .encl/*.pgid, SHA256SUMS), runner outputs `runner-selftest-r55/<utc>/` (stamp, exit-codes, logs, .pgid/, SHA256SUMS, RECEIPT.txt, SHA256SUMS.outer); pre-runs additively under `s2-setup-prep/runner-selftest-r531/`.

Positive: each set exit 0; every runner control `receipt_status=ok`; K2 `final=0`, `CHECKPOINT_DISABLE=1` echoed by harness/discriminator/stop, `owned groups [none]`, stop census empty; K3 ordering; K4 72/QUARANTINE/no stop; K5 71; K6 3; K7pre reproduces A01 on v5.3.1, K7 `70` + deadline reason `quiescence-40-composition`; K8 `124`; K9 "BOUNDARY CONFIRMED" (labelled limitation); K10 `final=71 first_exit=0 fixture_stop=124`, hanging child dead, `cleanup_client_leak=yes`; N1/N2/N3 child exits 2/1/3 with decoy alive after N1.
Negative/abnormal: any miss → 1 and stop; survivors/lock/pattern → 4; deadline → 3; nothing retried. Not covered (stated): caller-group decoy negative (N4), startup-interruption (N5), intentional handoff-failure (N6) — designs listed in FINDINGS_MAP, not implemented.

Not requested: real mode, fixture lifecycle, destroy, install, proof. Independent A/B review of v5.5 precedes any grant of request 09.
