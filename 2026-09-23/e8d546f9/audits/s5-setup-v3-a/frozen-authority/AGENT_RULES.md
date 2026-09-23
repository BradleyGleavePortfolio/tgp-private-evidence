# TGP Agent Rules

Status: EFFECTIVE 2026-09-18, adopted by explicit operator instruction. This is TGP's canonical constitution; the [adoption record](DECISION_LOG.md#2026-09-18-adopt-the-risk-tiered-constitution) states its authority and review limitations. Procedural reductions dependent on automated controls apply only after those controls are verified.

Purpose: deliver excellent software with the least process that reliably protects customers, data, work, and truthful decisions. Move quickly on reversible work, apply strong judgment at consequential boundaries, and prove integrated product quality at release.

## Authority, quality, and ownership

### G01: One constitution, explicit authority

This file replaces the old numbered rules, audit-process addenda, and conflicting generic procedure in continuation plans. It does not erase historical evidence, unresolved material findings, product acceptance criteria, or dependency ordering.

Repository policy defines executable checks and domain-specific parameters. It cannot silently weaken this constitution. Changes to governance, trusted enforcement, review identity, or evidence publication are Tier 4. No candidate may approve its own weaker gate. Operator authority and applicable execution-platform restrictions still apply.

Existing concrete security, compatibility, retention, and recovery parameters remain effective until their owned replacements are approved. This transition protection does not preserve superseded generic audit ceremony or explicitly deleted volume quotas.

### G02: Customer quality is the outcome

Deliver correct, coherent, usable, accessible, reliable behavior against explicit acceptance criteria. Customer-visible flows must provide real outcomes or accurate, actionable limitations and errors. Never present a stub, partial import, queued request, or local test as completed customer value.

Review changed experiences for clarity, WCAG 2.2 AA accessibility, approved localization conventions, failure states, recovery, performance, and visual coherence. Missing unrelated features are not automatic scope expansion. Use an approved truthful product boundary rather than hiding a failure or building an unrequested subsystem.

### G03: Work within a clear mandate

Each change has an owner, bounded scope, acceptance criteria, and known prerequisites. Small changes need only a concise description. Validate uncertain APIs, dependency versions, and architectural assumptions before expensive implementation.

Act autonomously within approved scope and reversible authority. Obtain explicit approval for new spending, external communications, destructive or irreversible actions, changes to the security/governance mandate, or commitments outside that authority. Record consequential decisions once; do not write a decision essay for routine implementation.

### G04: Never lose work or overwrite another owner

Use an isolated branch/worktree and one writer for each owned mutable area. Coordinate overlapping changes before writing. Preserve meaningful work in approved durable storage at checkpoints and before handoff, pause, context loss, or risky operations. Meet the operator-approved recovery window; until one is adopted, retain the existing safe checkpoint cadence.

Publish concise handoffs containing the current source, remaining work, blockers, and next action. Preserve original evidence and clearly distinguish recovery from reimplementation. Never fabricate missing history. Do not push secrets, customer data, or private audit material into a public repository.

### G05: Authentic identity and provenance

Until explicitly changed by the operator, commits require author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, with no AI co-author attribution. Verify both fields on the commit actually landed. Do not confuse these fields with a verified cryptographic signature or independent human review.

Use a merge route compatible with protected branches and the approved identity policy. If they conflict, stop for an operator decision; do not bypass protection. Record actual tools and reviewers honestly. Never invent a model identity, approval, signature, or execution result.

## Risk, verification, and review

### G06: Classify by consequence, not file size

Use the highest applicable tier for the cumulative change and its dependencies. Labels, small PRs, documentation extensions, flags, and apparent reversibility do not lower actual blast radius. Policy, tests, or configuration that weaken a critical boundary inherit that boundary's tier.

| Tier | Scope | Minimum assurance |
|---|---|---|
| 0 | Trivial, reversible content or cosmetic change with no behavior, contract, accessibility, security, or enforcement effect | Applicable deterministic checks, clean diff, identity, normal CI; no mandatory AI audit |
| 1 | Isolated private implementation with bounded effects and good automated coverage | Appropriate tests, static/security checks, targeted AI code review, clean CI |
| 2 | Meaningful customer or business behavior | Tier 1 checks, applicable contract/integration validation, one independent adversarial audit, material finding closure |
| 3 | Shared architecture, infrastructure, contracts, or cross-cutting primitives | Strong coverage, architecture review, one independent adversarial audit; add a second independent lens for the triggers below |
| 4 | Auth, privilege, RLS, tenancy, PII, money, credentials, destructive data, irreversible migration, security or enforcement boundaries | Comprehensive relevant tests and security analysis, exact-head/artifact evidence, two independent adversarial audits, explicit closure, boundary and recovery proof |

Tier 3 requires a second independent lens when multiple repositories are affected, persistent data contracts change, concurrency/state authority changes, a foundational primitive changes, blast radius is difficult to bound, or the first auditor identifies material architectural uncertainty. Architecture review may be part of an appropriately qualified independent audit rather than a separate ceremony.

Release acceptance is an additional integrated-system gate, not a tier applied to every PR. When blast radius is uncertain, use the higher plausible tier until the uncertainty is resolved. Downgrades require a recorded rationale and approval independent of the change author.

### G07: Deterministic gates are trusted and fail closed

CI enforces the applicable formatting, lint, type, build, test, secret, vulnerability, static-analysis, contract, ownership, and policy checks. Scope them to affected inputs where the selection mechanism is proven; otherwise use broader checks. Local hooks are fast feedback, not a second manual certification ritual.

A required check must actually execute, examine the intended source, and produce valid evidence. Skipped, missing, stale, empty, errored, or disabled scans are not success. Required checks and their applicability come from trusted policy outside the candidate's unilateral control. Verify enforcement with negative tests and actual repository settings, not workflow filenames or green badges alone.

### G08: Tests prove behavior, not volume

Test acceptance criteria, relevant regressions, failure modes, and consequential boundaries with meaningful assertions. Use integration, adversarial, concurrency, migration, and real-environment tests where unit tests cannot prove the claim. Record intentional skips and their effect on acceptance.

Use coverage and performance budgets as diagnostics and executable policy, not substitutes for judgment. Do not require a universal test-to-source LOC ratio, blanket PR-size exception essay, or fabricated tests for documentation. Broad changes still require broad validation. A claimed pre-existing failure needs attributable baseline evidence; never relabel a regression as a flake.

### G09: Bind every claim to its real evidence

Distinguish implemented, tested, reviewed, merge-eligible, landed, deployed, and product-accepted. State what ran, on which source and relevant environment, what passed, what did not run, and what remains unknown. GitHub mergeability, a plan review, or a passing unit suite is not release readiness.

Bind evidence to repository, relevant base/head, checks, and material inputs such as dependencies, toolchain, configuration, and policy. Use immutable references; use hashes for external/build artifacts where needed, not every prose document. Evidence can be reused only when its relevant inputs and validity remain unchanged. A changed head requires a new applicability decision and attestation, not an automatic claim of inherited approval.

### G10: Independent review is proportional and genuinely independent

Meet G06's review requirement. Tier 1's targeted review is a focused code-review pass, not a mandatory full independent audit. For Tier 2 and above, independent auditors did not implement the change, receive an unbiased brief, and exercise their own judgment. Auditors are read-only against candidate source; a designated publisher preserves their reports. Tier 4's two auditors are independent of the authors and each other. A second token for the same account is not a second reviewer.

Auditors focus on hidden failure modes, architecture, boundary violations, misunderstood product behavior, and overclaimed evidence. They may share one attributable automated test bundle, but must challenge its adequacy and request additional execution when necessary. Independence does not require duplicate heavy test runs.

Fixes receive risk-scoped follow-up and explicit finding closure. Unrelated prose changes do not restart product audits. Material changes invalidate affected conclusions; Tier 4 still requires both independent final-head attestations. Do not satisfy dual review by copying another auditor's verdict.

### G11: Block on consequence, not cosmetic labels

Unresolved material correctness, security, reliability, data integrity, maintainability, or customer-quality findings block the affected merge or release. A low severity label does not waive a material defect. Unresolved architectural uncertainty at a consequential boundary is material.

Pure naming, formatting, comment preference, or internal aesthetic disagreement is normally nonblocking; fix it when cheap or during ordinary cleanup. Do not start an audit loop solely for cosmetics. Record material findings once with stable ID, consequence, affected scope, owner, and closure evidence. Inherited findings are not rediscovered and rewritten for each PR, but remain blockers wherever their risk applies.

Auditor disagreements require evidence-based disposition, not majority voting or relabeling. Any permitted residual-risk acceptance must name the authorized owner, limits, expiry, and rationale. This cannot waive unresolved material Tier 4 or release safety findings.

## Engineering safety and product integrity

### G12: Protect security and tenant boundaries

Enforce authentication, authorization, roles, tenant ownership, and input validation at the relevant server/data boundaries. Supabase tables use enabled RLS with explicit role/operation policies. Privileged paths must not silently bypass tenant or authorization guarantees. Test cross-tenant, denied-role, revoked-session, and unauthorized-access cases.

Use parameterized queries, safe output handling, protected credentials, appropriate cryptography, secure transport, constrained CORS, quotas, and bounded resource use. Do not expose secrets, sensitive internals, or PII in errors or logs. Rotate exposed credentials and preserve incident evidence. Maintain domain-specific security parameters in tested policy. Scanners supplement, not replace, boundary reasoning.

### G13: Preserve data, privacy, and financial correctness

Use database constraints, atomic writes, concurrency controls, and replay/idempotency protection appropriate to the operation. Money uses integer minor units or suitable decimal arithmetic. Model instants, civil dates, time zones, retention, deletion, and audit evidence deliberately; blanket soft deletion or indiscriminate before/after PII logging is not a privacy policy.

Migrations must preserve supported readers/writers and prove safe rollout against representative populated data. Prove rollback where possible; where it is unsafe or irreversible, require explicit authorization, recovery/forward-repair proof, and a bounded rollout. Never claim that a down migration restores lost data. Maintain verified backups and restore capability for the applicable recovery objectives.

### G14: Keep contracts and dependencies coherent

Maintain authoritative schemas and generated contracts, compatibility tests, versioning appropriate to consumers, and validated event/configuration registries. Update dependent artifacts together. Breaking changes require an explicit compatibility and migration plan; do not freeze a contract by assertion.

Respect the dependency graph across branches, repositories, and releases. Recover source before claiming it exists; recover validation separately. Select maintained dependencies for actual need, lock and verify the resolved graph, and remediate vulnerabilities under explicit security policy. Validate uncertain versions and APIs before dispatch.

### G15: Engineer reliable runtime behavior

Bound external calls, retries, list sizes, and resource consumption. Avoid unbounded queries, blocking work, unsafe concurrency, leaked subscriptions, and unrecoverable optimistic updates. Use observability, health/readiness signals, and performance budgets appropriate to actual service risks.

Critical failures must be visible and actionable. Noncritical failures may degrade gracefully without corrupting state or pretending success. Redact diagnostics and preserve useful correlation. Restore breached reliability objectives with priority proportional to customer impact; do not declare every missed metric a company-wide P0.

### G16: Ship a trustworthy production artifact

Build reproducibly from identified inputs. Exclude development-only code, tooling, tests, and unintended dependencies from production artifacts. Apply relevant secret, dependency, static, infrastructure, and artifact checks; maintain release dependency inventory/SBOM and traceable build identity.

Deployment configuration must be validated against the actual environment without disclosing secrets. Missing security, product, or feature switches must not silently activate functionality. A readiness summary must report specific checks and unknowns, never assert universal safety.

## Merge, release, and operating state

### G17: Merge and deploy through enforced paths

Protect canonical branches against unreviewed or unverified writes, force pushes, and unauthorized bypass. Require the applicable checks and tier review on the candidate actually landed, with safe base/head reconciliation. Any newly constructed merge commit needs proven evidence applicability; equal source trees alone do not establish equal build or deployment inputs.

Merge is not deployment authorization. If merging automatically deploys, all applicable release requirements become merge prerequisites until those operations are safely separated. Use staged rollout, observation, and a real rollback/containment path appropriate to risk. Feature flags do not make unsafe data writes reversible.

### G18: Release acceptance proves the system

Identify the exact integrated candidate across repositories, artifacts, contracts, configuration, and migrations. Reconcile compatibility, material findings, and supported old/new behavior. Run integrated tests and product acceptance against the actual release scope, including failure/recovery paths and representative customer journeys.

Require security/reliability review, adversarial review, and customer-experience quality review. Retain Tier 4 dual independent assurance for critical boundaries in the release. Distinct review questions may share an appropriate reviewer or valid prior evidence, but required independence cannot be collapsed.

Use the approved product plan's measurable acceptance criteria. Do not substitute mocks, empty runs, unsupported platforms, partial results, or a plan-level verdict for real-system proof. No unresolved material release findings, and no broader readiness claim than the evidence supports.

### G19: Keep one small, attributable current-state view

Query GitHub and build systems for facts they own. Keep only state they do not own in a minimal versioned registry: scope, owner, tier, dependencies, acceptance references, material finding IDs, and review/evidence references. Every generated snapshot has observation time and provenance. Stale, conflicting, or unavailable facts remain explicit.

Preserve history in Git and immutable evidence, not by appending every superseded sentence to the live operating view. Read the current summary and fetch deeper evidence on demand. Never treat a file named `current-state` as authoritative merely because it is JSON.

### G20: Escalate uncertainty without stopping unrelated work

Pause the affected boundary for ambiguous ownership, missing prerequisite, material review disagreement, unbounded blast radius, compromised evidence, or unavailable required controls. Identify the smallest safe next action and obtain the needed decision or evidence.

Separate findings from incomplete review and infrastructure failure. Preserve work before recovery or cancellation. Monitor active work for useful progress, not ritual updates; investigate stale ownership in relevant lanes rather than sweeping every repository on every task.

## Keeping the system small

### G21: Prefer the simplest adequate implementation

Question the need, delete unnecessary work, simplify, then accelerate and automate what remains. Favor clear ownership, existing suitable primitives, and cohesive code. Introduce abstractions, caching, dependencies, and process only for a demonstrated problem.

Use measured limits and context, not universal line counts, comment ratios, mandatory library reuse, or aesthetic doctrine. Address a bug's relevant repeated causes without turning a bounded change into unlimited refactoring. Customer quality and maintainability still matter.

### G22: Make governance earn its cost

A new permanent rule needs a concrete hazard, an owner, and the least costly effective enforcement. Prefer a short invariant plus a tested control; do not require prose, CI, and an auditor to duplicate every rule.

Measure cycle time, review effort, rework, escaped defects, incidents, recovery, and customer acceptance. Remove or revise controls that do not improve outcomes. Retain manual protection only where the replacement is absent or unproven, scoped to that gap. Simplification succeeds when delivery improves without worsening real safety, not when word count alone falls.
