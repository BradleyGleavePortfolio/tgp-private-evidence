# S5 R3 audit A — smallest conditional execution request

**No execution is authorized or requested now at current head.** Static evidence is sufficient to return the findings; rerunning the existing live proof would not close unsafe refusal or abnormal-cleanup control flow. [Audit findings](REPORT.md)

## Exact current candidate, if parent requires a control-flow reproduction

- Source HEAD `143d451ead6ccdbebd92ca3031ba7a89867d6cfc`.
- Tree `d0e122d35022377196908b7d132fc34c1af2fc6b`.
- Frozen wrapper input identities: checkpoint-5-B3 SHA256SUMS.
- Dependency basis: existing A1 pinned candidate tree, hidden lock SHA-256 `05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44`; no installs.
- No DB or network needed; use a separately frozen, parent-reviewed offline control driver which records SQL/lifecycle intents instead of issuing them.
- Minimal reproduction target: invoke registered setup and teardown under the installed Jest hook semantics with an injected pre-state assertion failure and fake SQL adapters. Expected current behavior is mutating teardown intents after refusal, not a pass.
- Driver must never import a module that constructs a real connection or executes psql. Stop for review if that isolation cannot be demonstrated statically.
- Artifact destination must be assigned to the builder by parent, not this frozen audit directory.

No executable command is supplied for a driver that does not yet exist; inventing one would turn this audit into an implementation or an unreviewed connection risk.

## Smallest successor closure plan

1. Canonical S5 builder repairs only the validation surface: validated-setup teardown gating; lifecycle supervision/cleanup ownership; fail-closed destroy; pre-live busy-session refusal; accurate provenance stamping.
2. Freeze successor HEAD/tree and changed wrapper hashes; parent reviews an offline driver first.
3. Grant a bounded offline slot only: predecessor negative and successor positive controls for setup refusal, partial setup cleanup, busy resume, TERM/timeout, stop failure and removal failure. Use a temporary **noncanonical** fake lock/daemon model inside the driver; any use of the actual runner or canonical infrastructure needs explicit parent scheduling. Preserve true rc and expected failure records.
4. Metadata-only fixes do not justify a DB replay. A source change affecting the live spec needs applicable final-head execution before final acceptance; preserve original B3 evidence rather than overwriting it.
5. Only if parent seeks full fresh-bootstrap closure: new exact-head plan for marked disposable PG17.6 loopback `127.0.0.1:54325`, database `g2_s5_etq0_disposable`, admin `s5_super`, `/home/user/pg17/clusters/s5`, fixed cluster/database markers; canonical nonblocking lock continuously across preflight, mutation and cleanup; offline guards first; no network install, hosted access or product/schema writes.
6. That stronger proof is the ordered guard → real O preflight → fresh init → start → connected preflight → 164 bootstrap → pinned generation → 51 live cases → stop/liveness chain, bounded to the existing 30-minute envelope plus explicitly supervised cleanup on the 2-CPU/8-GB lane. The final repaired wrapper's exact command, source stamp and cleanup policy must be frozen in its request before grant.
7. Existing B3 cluster is not pristine. Do not silently `resume`, `reset`, `destroy` or overwrite it. Parent must explicitly approve its preservation/replacement/removal after A-03 closes; no such operation is part of this audit.

The next executable plan belongs to the canonical builder and parent scheduler. This document is a minimum scope/acceptance request, not a retrospective grant for any earlier builder action.
