# S2-V61 five-set continuation — executor result: **all five raw statuses 0** (k=0, new1=0, new2=0, neg=0, neg2=0)

Executor: `restore_s2_substrate_mue9eidh` (T4 S2 builder/executor; requested Claude Fable 5 / High is policy, not observed telemetry). Executor is not an independent reviewer; this is raw evidence for two independent nonbuilder result reviews. Activation: parent mail 2026-09-23 ~15:43Z + `execution/6c2a68ac/S2_RESTORATION_ACCEPTANCE_AND_ACTIVATION.md` (sha256 f63eb903…3fca) at private HEAD `e24ab4e262ce1357bcc7a8cf394129723341c7f1`. Grant: `execution/6c2a68ac/S2_V61_CONTINUATION_GRANT.md` (0bf4040f…8b1f). Frozen request `CONTROL_REQUEST_20.md` 0e8ab7ec…68ef unchanged. Restoration receipt `s2-restore/MANIFEST.sha256` 0a07e1e2…9897 (parent-accepted).

## Outcome (raw, unchanged)

| set | budget | raw rc | controls | wall | result dir (publication ok, aggregate 0) |
|---|---|---|---|---|---|
| k | 120 | **0** | 6/6 (K1–K6, strike 0) | 40.06 s | `k-20260923T154436Z-8133` |
| new1 | 60 | **0** | 5/5 (K7pre, K7, K8pre, K8, K9) | 26.89 s | `new1-20260923T154516Z-13892` |
| new2 | 60 | **0** | 1/1 (K10) | 25.99 s | `new2-20260923T154543Z-17617` |
| neg | 90 | **0** | 3/3 (N1–N3) | 5.12 s | `neg-20260923T154610Z-18713` |
| neg2 | 150 | **0** | 6/6 (N4a/b, N5a, N5b, N6, N7, N8) | 55.84 s | `neg2-20260923T154615Z-19582` |

Caller stdout: `k=0`, `new1=0`, `new2=0`, `neg=0`, `neg2=0`; no `STOP` line. START 15:44:36.319Z, END 15:47:11.518Z (155.2 s). Nothing NOT RUN among the five. probe/wdtest/wdcancel were not run at top level (retained V59 0/0/3 per grant). k=120 headroom: wall 40.06 s. All five `CONTROLS_RESULT.txt` files contain zero FAIL lines; all five `SHA256SUMS` verify.

Nested child-driver result directories created BY the controls (expected nonzero by design, each published with its own receipt): `k-…154610Z-18784` (N1 refusal → 2), `k-…154611Z-18936` (N2 injected impossible expectation → 1; contains the only top-level-lane FAIL line, injected), `k-…154614Z-19313` (N3 budget → 3), `probe-…154633Z-23118` (N6 lock-held handoff → 4), `wdtest-…154634Z-23399` (N7 → 0), `wdcancel-…154651Z-23751` (N8 → 3). These are not caller-level statuses.

## Exact block and transport

`caller.sh` (e629af7b…33a2): preflight refusals (V61 20/20 + outer hash, driver hash 42d9362b…, V57 15/15, PRE-OK 37/37, worktree d5cd clean, EUID≠0), START line, then the grant block **byte-verbatim** (`evidence/block-as-embedded.sh` = `block-from-grant.sh` = `block-from-request20-k120.sh`, all 84fad6e5…a3a1; `block-from-request20.sh` 0c754822… differs only at `[k]=60`→`[k]=120`, diff retained), END line, done marker. Caller ran with monitor off, errexit off, pid/pgid/sid 8080; every driver ran in the caller's group (`pgid=8080` in each banner). Transport: `setsid -f nohup bash caller.sh > caller-stdout-stderr.txt 2>&1 < /dev/null` — same as the parent-accepted V59 transport, needed because this tool environment ends non-detached processes at each tool-call boundary; no timeout, enclosure, budget change or extra signal. `timeout_impl=timeout (uutils coreutils) 0.8.0` in every banner.

## Preflight / postflight (`prelaunch-snapshot.txt`, `postrun-snapshot.txt`)

Pre: census 0; canonical lock absent; V57 `runtime/`, `runner-selftest-r57/`, V61 `results/`, stubs lock all absent; ENV01 parent 0555, `runner-selftest-r531/` 0755 empty; WT d5cd porcelain 0; V61/V57/PRE manifests OK; bash 5.3.9, flock/setsid 2.41.3, pgrep 4.0.4, CLK_TCK 100, uid 2000. Driver pre-snapshots: `[]` in every set.
Post (15:47:54Z): 0 caller/driver/runner/stub/sleep/flock/timeout processes, 0 zombies, census 0; V61 20/20, V57 15/15, PRE-OK 37/37 unchanged; WT d5cd porcelain 0; baseline c23b porcelain 0; ENV01 parent still 0555. V57 lane lock `runtime/test-validation.lock` exists (size 0) and probes FREE (`flock -n`, lane-private lock only — the driver's own method); predecessor stubs lock `controls-proposed/stubs/test-validation.lock` exists (size 0). Canonical `execution/test-validation.lock` absent, never opened.

## Writes (complete) and signals

Writes, all inside the Request20 write set: V61 `controls-proposed/results/` (5 top-level + 6 nested dirs, each SHA256SUMS + CONTROLS_RECEIPT.txt); V57 `runtime/test-validation.lock`; V57 `runner-selftest-r57/` 13 timestamped runner outputs (all outer manifests OK; finals 0×3, 124, 143×4, 3, 70×2, 71×2 — each the control's intended scenario); `execution/s2-setup-prep/runner-selftest-r531/{20260923T154516Z (final 0), 20260923T154525Z (final 143)}` (v5.3.1 SHA256SUMS OK; 37 manifested predecessor files untouched); V61 `stubs/test-validation.lock`; this directory. Byte copies of every result/runner output directory are under `evidence/` (originals left in place).
Signals: only by the frozen driver's reviewed mechanisms (step-40 controllers at K3/K4/N4b, seam controller N5b, watchdog N7/wdtest child, self-cancel N8/wdcancel child, runner TERM to self-published groups). Executor sent none; imported no PID. `owned-history.txt` files retained; 5 `skip-*` provenance lines across sets (A04 expected evidence, e.g. K4 quarantine survivor reported, not signalled).

Observation for reviewers (not a deviation by this lane): during the run other parent-dispatched source-only lanes wrote to their own paths (`execution/6c2a68ac/{s3-restore,s5-source-restore,audits/*}`, `worktrees/s5-r4`) — outside every S2 path; the census pattern stayed `[]` in every driver snapshot and no lock contention occurred.

## Final ownership accounting

Nothing running, nothing held: caller 8080 exited; 0 matching processes; 0 zombies; lane lock FREE; canonical lock absent; no retained holder; no unknown census. Runtime slot released to parent EXEC-6c2a68ac with this accounting.

## Truth

Executed: the one granted sequence, once, five sets, all raw 0. Not done: retries, resumption, probe/wdtest/wdcancel rerun, any edit to request/driver/packets/predecessor, install, DB, network, product execution, commit, private-checkout write. Stub-only controls — not installation, PostgreSQL setup, real composition proof or product/release clearance. `PROOF_REQUEST_21` remains HELD. Independent result review required before any real-proof decision.
