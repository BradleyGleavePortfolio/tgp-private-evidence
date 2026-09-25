# S8-C replacement independent exact-candidate reviews

Parent grant, 2026-09-25. Two independent T4 nonbuilder reviews, requested route `claude_fable_5_1`, high. Requested routing is not actual runtime telemetry. No builder may attest its own candidate.

## Exact candidate

Worktree `/home/user/workspace/worktrees/64e33dc7-s8c`, branch `exec64/s8c-replacement`.

- Accepted parent: `93389265a846095b846fa8f1fb0dad782fb6ee9f`.
- New head: `527fe2bc24f954b26c0485c90345f237ce39a09d`.
- Tree: `d87a96267c2ec4f4d79d83d26e6b2928a56c8a85`.
- Scope: 24 changed paths, new replacement native writers/families, minimal typed ledger handoff, additive programs mapping member and generated artifact, plus new tests/proof sources.

The candidate is committed with Bradley author and committer through genuine hooks, with a clean worktree observed by the parent. Source gate failures are preserved under `s8c/gates/`; the final complete source receipt and filled private PG binding are being completed source-only. Begin source review now, but no final GO until the final receipt and filled binding are delivered.

## Required material and decision

Read the current `S8C_REPLACEMENT_BUILD_GRANT.md`, `S8C_SOURCE_GATES_GRANT.md`, the durable requirements and architectural decisions they name, and the builder's final source receipt when available. Accepted S8-A/B requirements remain applicable; no broad re-audit or proof rerun of unchanged accepted bytes.

Review the complete new candidate delta and its new PG proof sources, concentrating on tenancy, deterministic identity/replay, native provenance and precedence, atomic typed ledger handoff, explicit client-principal deferral, no historical side effects, bounded data-only rule execution, legacy behavior, final canonical family contract, and the fixed acceptance cases. Verify the actual source-gate receipts and narrow failed-gate closures without repeating tests.

Read the filled proof driver, fixture, pins and README completely when frozen, independently recompute exact candidate and binding/tool pins read-only, and decide whether this exact new candidate/binding supports a separately granted single new PG run. Inspect role entry and bootstrap compatibility in this proof; do not execute or probe it. Source readiness or GO is not runtime acceptance.

No reader/customer/flag activation is granted before accepted S8-F. No S8-D/E principal policy, S9 reconciliation, production, live source accounts or security-governance decision is implied.

## Independent surfaces

Reviewer A writes only `execution/64e33dc7/s8c/reviews/REVIEW_A.md`.
Reviewer B writes only `execution/64e33dc7/s8c/reviews/REVIEW_B.md`.

Do not read the peer's report, edit product/Git, install, compile, test, generate, acquire locks, initialize or operate PostgreSQL, push, merge or publish evidence. Preserve source isolation from S7-L and S8-F. Use apply_patch for your own report.

Every A/B finding must identify concrete harm, exact blocked decision, smallest closure and execution unlocked. Record and qualify C without creating blockers, fixes, controls or reruns. Give exact path/line and candidate/binding identity. Report GO or NOT GO for the single-proof grant, never product acceptance before its runtime result.
