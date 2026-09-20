# TGP R3 fixer and audit cycle

Authority: user explicitly directed on 2026-09-20 at approximately 22:37 UTC: continue through the audit cycle under the 22 rules and commence R3 fixer/audit rounds now.

## Governing rules

Read `repos/context/AGENT_RULES.md` in full, `execution/doctrine/EXECUTE.txt`, relevant routing doctrine, current `LAST_OPERATOR_STATE.md`, and relevant continuation-plan acceptance criteria. All cumulative lanes here are T4. Requested builder routing is Claude Fable 5 / High, using the available catalog name; never claim independently verified runtime identity from a requested model.

Use G01–G22, not superseded numerical quotas. G06/G09/G10/G11 require meaningful exact-head proof, two independent final-head attestations, explicit material closure and boundary/recovery proof. No candidate can certify itself or weaken its own gate. Auditors may share one attributable execution packet but must exercise independent judgment.

## Safe scope and ownership

All existing worktrees and R2 packets are frozen. Each builder creates a NEW successor worktree/branch from its exact R2 head and writes evidence under `execution/sN-r3`. Do not alter old candidates, audit reports or source bundles.

| Lane | Frozen base | New worktree / branch | Owned slice |
|---|---|---|---|
| S1 | `90a6647513f3566393764eee87237d9b5b1f150b` | `worktrees/s1-r3` / `execute/20260920-s1-r3` | Harness safety and discriminating DB proof; sole schema/migration/generator owner; E-specific recovery packet. |
| S2 | `0b05fcf5352287109ac88ed2ba3682e441e3a076` | `worktrees/s2-r3` / `execute/20260920-s2-r3` | Delivery workflow injection, mutation gating, verifier discovery, truthful recovery and lint. |
| S3 | `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06` | No new builder initially | Preserve accepted local proof; no gratuitous suite rerun. New integration may need scoped applicability/re-attestation. |
| S4 | `c5a5ae12c5b3c3e32a4601c99319ad7c0d980057` | `worktrees/s4-r3` / `execute/20260920-s4-r3` | Bounded auth response-body consumption and clear/re-establish recovery; changed-package proof. |
| S5 | `485c67973b56758fb9b8404579f5ddaec87136bd` | `worktrees/s5-r3` / `execute/20260920-s5-r3` | Validation-only race terminal assertions and identity-correct O recreation. Coordinate recovery directions with S1. |
| S6 | `55db31a0696ebd07d0cb9abb18ffd31dce29457d` | `worktrees/s6-r3` / `execute/20260920-s6-r3` | Coherent real fallback identity-cache semantics and truthful pairing copy; current R2 pair still completes independently on frozen predecessor. |

Read BOTH own-lane R2 reports in `repos/evidence/2026-09-20/audits/sN-r2/{a,b}/revision-1/REPORT.md` and `R2_PARENT_DISPOSITION.md`. S6 currently has a frozen preliminary A packet; parent supplies B when complete, without exposing either to the other current auditor. Do not restart unrelated reconnaissance.

Private source/evidence preservation is authorized through the parent publisher. No product push/PR/merge, deployment, store submission, hosted enforcement mutation, live DB/customer access, feature flag enablement, native dependency/crypto activation or public evidence exposure is authorized by this local repair cycle. Parent handles reserved authority when actually needed.

All new commits: author AND committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no AI trailers. Verify `git var` before commit and actual commit fields afterward. Use repository-local config; no force push or protection bypass.

## Execution discipline

Only 2 CPU / 8 GB RAM. The current S6 combined validation owns `execution/test-validation.lock` until it finishes. No heavy tests, dependency installs, builds, browser runs, database bootstrap or multi-process probes without an explicit parent slot. Never block-wait for the lock; use nonblocking flock and return the smallest requested execution plan.

Source reading, narrow edits and cheap static checks can proceed in parallel in isolated worktrees. Dependencies may be reused read-only only when package/lock/toolchain inputs match; disclose symlink and install provenance. Never modify another lane's dependency tree.

Before DB execution, S1 must prove disposable-target guards with offline negative tests. Database execution must be a new synthetic loopback fixture with enforced namespace, pinned port, bounded identifiers and explicit destructive confirmation; no host/provider/customer URL. Parent schedules S1 then S5 and integrated S1/S2 verifier probes. Synthetic execution is not hosted applicability.

Heavy run wrappers must preserve actual child exit codes, fail closed, stamp exact head/tree/clean state, relevant environment/toolchain/lock inputs, command/start/end, and capture failures. No hidden pipe-success, `--forceExit`, fake pass, expectation weakening or stale artifact reuse.

## Required repair outcomes

- S1: reject unsafe targets before DB connection/destruction; late-stage lock proves whole-file rollback, same-session timeout checks prove actual cleanup; success/failure claims separated. Resolve verifier role/grant expectations with source and synthetic evidence, not automatic privilege widening. E recovery must distinguish actual migration states/history/catalog/ownership/policy/data invariants and intentional rerun refusal.
- S2: untrusted dispatch values are data, not shell source; bounded app target; no hidden machine mutation in read-only diagnostics. Discovery failure cannot mean zero verifiers; required expected verifier coverage is established across the S1/S2 composition. Correct stage-specific deployment failure and rollback guidance. Run real shellcheck/actionlint before claiming lint.
- S4: timeout covers headers AND body, caller settlement/recovery survives body stalls and clear/re-establish, stale epochs cannot overwrite current session. Use regressions for actual never-resolving bodies, not only fetch rejection. Preserve byte-identifiable package and repeat necessary loader/control proof, not customer import claims.
- S5: terminal worker outcome and post-completion target state asserted, including meaningful refused branch where claimed. O fixture recreation must satisfy real Git identity gate. No schema, migration or service-source edits; S1 owns those.
- S6: real storage/cache/identity composition, fresh login, sequential legacy readers, restart, patch and logout; async operations must not silently disappear behind synchronous APIs. Keep copy within observed pairing state, not inferred import completion/absence. No new backend progress/revoke subsystem.

## Handoff and audit cycle

Send parent a concise initial plan, ownership intersections and minimal validation request. Implement after ordinary scope alignment; no routine user approval loop. Surface scope expansion/unexplained focused failure.

Return frozen exact head/tree, clean status, source bundle requiring known public base, report with stable finding dispositions, scripts/logs including failed attempts, package/hash where applicable, remaining unknowns and smallest follow-up. This is builder evidence, never self-audit.

Parent archives each returned packet unchanged, dispatches independent A and B reviewers against the frozen final candidate, preserves every verdict, resolves disagreements by evidence, and routes material findings to isolated successors. No automatic clearance from favorable labels, test volume or untouched inherited defects. Risk-scoped follow-up is required; cosmetics alone do not start another product round.
