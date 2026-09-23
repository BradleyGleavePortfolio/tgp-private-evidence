# S5-V32-A — final changed-candidate T4 review

Independent nonbuilder A; 2026-09-23. Read/hash/diff only: no candidate, syntax check, test, probe, lock, signal, or installation executed; no source changed; no current peer output read. This is an attestation, not an activation.

## Decision

**SOURCE-CLOSED; controls eligible for ONE private 180-second run after the other independent final-byte attestation and parent activation when the runtime slot is free. No new A/B blocker found.** The purchased decision is execution, not another certainty-only review cycle, under the [current scope](../../../../tgp-private-evidence/execution/6c2a68ac/SCOPE.md) and [owner doctrine](../../../../tgp-private-evidence/execution/6c2a68ac/OWNER_SAFETY_ROI_AND_EXECUTION_DOCTRINE.md).

## Exact inputs verified

| Seal / candidate | Independently checked SHA-256 |
|---|---|
| [Top seal](../../s5-v32-builder/SHA256SUMS.s5-v32-builder), 34/34 entries | `1f23abdcf2ca328f23371fa6018ceb1753553e8e21c65e8765881f814d0e0691` |
| [Source seal](../../s5-v32-builder/s5-setup-exclusion-v32/SHA256SUMS.s5-setup-exclusion-v32), 18/18 entries | `addc713d7297796cc98fccfb7c05bde770bedf341322a17a38850ed0cd25adba` |
| [Controls seal](../../s5-v32-builder/s5-setup-v32-controls/SHA256SUMS.s5-setup-v32-controls), 11/11 entries | `b99771a79d80e768a710475cd772e0fd1ccc37ca504fbfc723acabed039f036e` |
| [Launcher V32](../../s5-v32-builder/s5-setup-exclusion-v32/launch-s5-setup-exclusion.v32.sh) | `55acc00fe9b04d0e015f37bbdac90e582925c4b4564f7aaaa55c21a13304cf0a` |
| [Runner v101y](../../s5-v32-builder/s5-setup-exclusion-v32/run-s5-setup-npm-ci.v101y.sh) | `61b565e48fa4c14f765fe223bfc3a8baac27ca2867763c91e6a57135fc4ea1b3` |
| [Driver V32](../../s5-v32-builder/s5-setup-v32-controls/ctl-v32.sh) | `4323dc41953f321394e0ee98ffa7c2186943b83067b2cb6886a03aafbca35a3c` |
| [Fake V32](../../s5-v32-builder/s5-setup-v32-controls/fake-runner.v32.sh) | `045d5284993217e98b85932bb33d6ba6e9a272097070ffd1f3c0f42a7b02f838` |

All five supplied source/control diffs reproduced exactly by read-only comparison; manifest inventories are complete under their stated exclusions, and the top seal includes both `FREEZE.json` files. [Top inventory](../../s5-v32-builder/SHA256SUMS.s5-v32-builder)

Live G01–G22, current SCOPE, doctrine, the supplied prior V31 A/B reports, and the narrow V2 diagnostic qualification were read; no current V32 peer conclusion was consulted. [Authority/input register](FINDINGS.json)

## Finding closure and applicability

- **S5-V31-A-01 — CLOSED (class B).** Runner line 210 places the inherited current lease token in the truncating START publication before the early stamp/precondition/lease exits; launcher lines 188–193 require that exact token through either the unchanged INHERITED form or an anchored START with the current PGID and a trailing token delimiter, before deriving runner facts. [Runner delta](../../s5-v32-builder/s5-setup-exclusion-v32/diffs/runner-v101x-to-v101y.diff) [Launcher delta](../../s5-v32-builder/s5-setup-exclusion-v32/diffs/launcher-v31-to-v32.diff)
- The timestamp comparison is removed: a foreign-token START is rejected regardless of equal/future time or matching numeric PGID; retaining a timestamp floor would not strengthen the restored attempt-token contract. [Launcher lines 185–196](../../s5-v32-builder/s5-setup-exclusion-v32/launch-s5-setup-exclusion.v32.sh#L185)
- **V31-B-01 — CLOSED (class B).** Driver line 87 waits up to five seconds for the exact first live HEARTBEAT read by the unchanged P1 conjunction, before the permission fault is applied; P2’s token-bound ten-second SELF_HOLD wait is retained, and neither wait substitutes success for a missing asserted record. [Driver lines 84–108](../../s5-v32-builder/s5-setup-v32-controls/ctl-v32.sh#L84)
- **Assertions/P3c — ACCEPTABLE.** All ten predecessor assertions, including the two-line preservation assertion, are unchanged; the sole added assertion uses an attributable never-adopted shim to publish a same-number, non-old, foreign-token record and requires non-import, preserved seed hash, raw 143, recorded final90 release and a free private lock, with positive early-death P3b still last. [Control delta](../../s5-v32-builder/s5-setup-v32-controls/diffs/ctl-v31v2-to-v32.diff)
- **Early-death/raw truth — PRESERVED.** The token-bearing START permits the defined pre-INHERITED death branch to reach positive empty census and release with its actual raw status, while absent/unreadable/unbound evidence after adoption still holds unknown; raw status, cleanup, publication causes and release status remain distinct. [Launcher lines 190–250](../../s5-v32-builder/s5-setup-exclusion-v32/launch-s5-setup-exclusion.v32.sh#L190) [Runner lines 210–216](../../s5-v32-builder/s5-setup-exclusion-v32/run-s5-setup-npm-ci.v101y.sh#L210)
- **Primitive applicability — POSITIVE, not re-audited.** Both embedded blocks hash to unchanged `4aebf96f6b7c8962b7a4b10dfc25acb7a793a24744bc0e79de77675031b1c6c5`; the deltas add no primitive call/context or signal authority, preserve immediate spawn/register ordering, and change the real runner only in its header and START payload, with the canonical runner pin updated accordingly. [Source seal](../../s5-v32-builder/s5-setup-exclusion-v32/SHA256SUMS.s5-setup-exclusion-v32) [Launcher delta](../../s5-v32-builder/s5-setup-exclusion-v32/diffs/launcher-v31-to-v32.diff) [Runner delta](../../s5-v32-builder/s5-setup-exclusion-v32/diffs/runner-v101x-to-v101y.diff)

## One-shot execution boundary

Recommend the exact [requested command](../../s5-v32-builder/s5-setup-v32-controls/REQUEST_V32_CONTROLS.md), once:

```text
cd /home/user/workspace/execution/6c2a68ac/s5-v32-builder/s5-setup-v32-controls
S5X_OUT=<parent-selected fresh resolved absolute private root> S5_CTL_GRANT=granted-by-parent timeout --foreground -k 10 180 bash ctl-v32.sh
```

The grant must retain the existing non-root, job-control-off, fresh noncanonical/nonaliased output and exact-byte prerequisites, and state the actual timeout semantics rather than invent GNU availability; P3b supplies the planned runtime check of PGID/status propagation without an extra preliminary proof. [Control request](../../s5-v32-builder/s5-setup-v32-controls/REQUEST_V32_CONTROLS.md)

Write scope is the private output tree: logs/FAIL snapshots, seeds and shims, per-case private lock and holder/release/SELF_HOLD records and temporaries, outer attempt identity/adoption files, inner fake identity/START/SUB_READY records, prior archives, P2 FIFO/receipt/holder-copy artifacts and P3c seed hash; repairs remain the named permission restore and exact deposits plus empty obstacle directories, not recursive deletion. [Driver](../../s5-v32-builder/s5-setup-v32-controls/ctl-v32.sh) [Fake](../../s5-v32-builder/s5-setup-v32-controls/fake-runner.v32.sh) [Launcher](../../s5-v32-builder/s5-setup-exclusion-v32/launch-s5-setup-exclusion.v32.sh)

No new holder or foreign-process signal is introduced: driver `kill -0` is observation, timeout helpers bound their own readers/driver/workload, and the unchanged launcher owns refusal/escalation signaling; the inner bound is 20 seconds plus 2-second kill margin, normal poll bound 25 seconds, heartbeat 2 seconds, with the requested overall 180-second timeout plus 10-second kill margin. [Driver lines 57–78](../../s5-v32-builder/s5-setup-v32-controls/ctl-v32.sh#L57) [Launcher lines 221–249](../../s5-v32-builder/s5-setup-exclusion-v32/launch-s5-setup-exclusion.v32.sh#L221) [Timeout contract](../../s5-v32-builder/s5-setup-v32-controls/REQUEST_V32_CONTROLS.md)

A driver timeout or failed check does not prove a detached holder exited: retain all failed evidence, stop, and return any retained owner to the parent without last-owner killing or an automatic rerun; success must be actual driver status plus all eleven checks and resolved per-case ownership, not static expectations. [Driver stop/finish/waits](../../s5-v32-builder/s5-setup-v32-controls/ctl-v32.sh#L48)

## C qualification — record, qualify, continue

**S5-V32-A-C01:** `diag` is a post-conjunction snapshot, not contemporaneous per-operand truth and not a complete capture of every transient predicate input; it improves follow-up evidence but cannot identify a historical failed operand conclusively. [Driver lines 48–56](../../s5-v32-builder/s5-setup-v32-controls/ctl-v32.sh#L48)

This does not alter assertion semantics or invalidate the next bounded decision; no diagnostic fixer or extra audit cycle is requested under the [owner doctrine](../../../../tgp-private-evidence/execution/6c2a68ac/OWNER_SAFETY_ROI_AND_EXECUTION_DOCTRINE.md). Existing V2 failure and its unknown failed operand/cause remain unchanged, with no V2 rerun purchased here. [Prior result qualification](../../s5-v32-builder/s5-setup-v32-controls/inputs/s5-v2-result-b.FINDINGS.md)

## Separate truths

| Boundary | A disposition |
|---|---|
| Source closure | **CLOSED** for the named changed-candidate findings; no open class A/B finding. |
| Private proof | **GRANTABLE ONCE**, subject to second independent final-byte closure and parent slot activation; **NOT RUN** by this reviewer. |
| Canonical setup / T0 / S6 | **Not activated or proved here**; proceed through the already specified parent transitions after accepted private results and their actual prerequisites, without reopening unchanged evidence. [Source request](../../s5-v32-builder/s5-setup-exclusion-v32/FINDINGS_MAP_AND_REQUEST_V32.md) [Scope](../../../../tgp-private-evidence/execution/6c2a68ac/SCOPE.md) |
| Product clearance | **NONE**; private fake controls are not installed dependencies, real setup/T0, S6 behavior, integration, or customer acceptance. [Control request](../../s5-v32-builder/s5-setup-v32-controls/REQUEST_V32_CONTROLS.md) [G09/G18](../../../../tgp-startup/live/AGENT_RULES.md) |

