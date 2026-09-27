# C2b-1 r2 independent review — T3

**Verdict: NO-GO.** Reviewed PR #32 at `5556c6a936adfcaefdffbbb1d72b2410d28952d6` against `a889f4ad`. The ten changed acceptance expectations are individually correct for their fixtures and the present C2a/C2b contract; none of those ten changes masks a corresponding defect. Independent review found additional defects in the unchanged production implementation, including a reproducible normalized-pipeline privacy/structure failure. No PR files were changed.

## The ten changed expectations

1. **Unmatched observation — CORRECT.** A `/clients` cluster with declared support zero is independently refused as `no_successful_get_evidence`; the `/unknown/1234` row receives `unmatched_observation`. Two refusals are correct (`roles.js:299–345`, test `:402–419`).
2. **Two dynamic segments — CORRECT.** `2001` is a four-digit year and `candidateKind` does not treat it as an ID (`url-templates.js:17–41`). The new `20001` matches `:id`, so the one joined observation exercises `template_not_replayable` as intended (`roles.js:54–68, 324–325`; test `:432–444`).
3. **Other origin — CORRECT.** Same-origin/method membership is required (`roles.js:286–305`). With zero joined rows against declared support one, `template_support_mismatch` takes precedence over the zero-GET reason (`roles.js:326–335`), alongside `unmatched_observation` for the source row (test `:446–456`).
4. **`__proto__` unsafe key — CORRECT.** Unsafe key aborts the endpoint as `unsafe_path_key` before metadata classification; it does not appear in output (`roles.js:19–41, 104–128`; test `:700–721`).
5. **`constructor` unsafe key — CORRECT**, same walk/refusal mechanism.
6. **`access_token` unsafe key — CORRECT**, credential policy rejects it as a container path.
7. **`session` unsafe key — CORRECT**, credential policy rejects it as a container path.
8. **`a b` unsafe key — CORRECT**, fails the conservative path-key syntax.
9. **`9leading` unsafe key — CORRECT**, fails the conservative path-key syntax.
10. **Literal-token allowlist — CORRECT as an observed-output assertion.** `clients`, `items` and `null` occur in the JSON produced from those fixture paths and shapes; `true` does not. `page` must sort before `paginated` under code-point order. This assertion is not, by itself, proof of vendor neutrality for arbitrary inputs (test `:741–796`).

## Findings, ordered by harm

### B1 — A one-off client identifier becomes a replay-compatible structural candidate

**Evidence:** `normalizeCaptureSnapshot` → `inferUrlTemplates` → `inferEndpointRoles` on a single successful GET of `https://coach.example/clients/101/workouts` with body `{"items":[{"id":5}]}` produces cluster template `/clients/101/workouts`, and roles returns a **list candidate** with that exact template and `replayCompatible: true`. Independently reproduced with Node in the review worktree. The C2a clusterer retains a literal for a segment without sufficient distinct IDs (`url-templates.js:191–248`); `safeTemplateLiteral` only screens address/long-digit patterns (`roles.js:70–87`) and `candidateFor` accepts the literal as replayable (`roles.js:245–260`). This is a legitimate normalized pipeline, not an invented malformed direct input.

**Harm:** A coach/client-specific path value is represented as reusable structure, and a later compiler could replay that particular client's endpoint or persist that value in learned knowledge. This conflicts with the north star's “structure only, never client data” invariant, even though this PR has no runtime wiring.

**Blocked:** Landing this candidate-inference seam as safe reusable blueprint evidence.

**Minimum closure:** Make literal-template reuse fail closed unless its segments are demonstrably structural (or explicitly keep the unproven path as non-replayable/non-persistable evidence); add a normalized one-off-ID regression, including a list response under an ID-bearing parent. Coordinate with C2a if the proof must be added upstream.

### B2 — Origin can echo a credential in direct calls

**Evidence:** `validCluster` checks only `typeof cluster.origin === "string"` (`roles.js:88–103`), and the member test compares unvalidated strings (`roles.js:286–289`). A direct call with both cluster and observation origin `https://person:password@coach.example`, path/template `/clients`, and an object-item list returns a `replayCompatible: true` candidate whose `endpoint.origin` contains `person:password`. Independently reproduced. The normal capture and C2a template path reject such origins (`input.js:155–177`, `url-templates.js:75–96`), so this is a boundary defect in the exported role function, not a claim that the current normalized pipeline passes credential-bearing origins.

**Harm:** If this pure public API receives malformed/untrusted intermediate data, it may expose an origin credential and label the result replay-compatible, contrary to the stated no-secret-output and fail-closed intent.

**Blocked:** Treating the exported inference function itself as a safe validator of untrusted C2a-like inputs.

**Minimum closure:** Validate origin syntax and credential absence at this seam, or explicitly make and enforce a trusted-validated-input precondition at its sole future call site; add a direct-origin regression.

### B3 — Shape limit is silently promoted into affirmative role evidence

**Evidence:** A legitimate normalized GET `/clients` with `{"items":[{"key0":0, ... "key200":200}]}` (201 properties) is within input's 500-key bound (`input.js:9–21, 93–113`), but `shapeSignature` returns `object(overflow)` past its 200-property bound (`shapes.js:33–92`). `classifyBody` treats that string as a uniform entity-item shape (`roles.js:136–149`) and `candidateFor` returns `roles:["list"]`, `replayCompatible:true`, `itemShape:"object(overflow)"` (`roles.js:219–260`). Independently reproduced through the complete C2a pipeline.

**Harm:** “Could not inspect this shape within budget” is misreported as sufficient evidence for a compatible list. Disparate large objects can all collapse to the same overflow signature, concealing contradictions.

**Blocked:** Acceptance of a replay-compatible list when structural validation exhausted its bounds.

**Minimum closure:** Refuse or mark non-replayable on any overflow/cycle/unsupported signature relevant to entity evidence; add a normalized 201-key (and shape-work-limit) regression.

## Secondary checks and verification

- Pure local module: no `chrome.*`, network operation, timer, randomness, AI execution, runtime import/call of `inferEndpointRoles`, or vendor literal was found in the new production file. Roles are candidate data, not a runnable blueprint. Stable sorted output and explicit refusals are present (`roles.js:263–354`).
- `git diff --check a889f4ad HEAD` passed. The focused role suite passed: **79/79** (`npx vitest run test/blueprint-roles.spec.js --reporter=dot`).
- `npm test` was attempted in the worktree. Initially dependencies were absent. After `npm ci --ignore-scripts --no-audit --no-fund`, the complete suite ran but did not reach a summary within the bounded local attempt (a 90-second timeout and then a 300-second bounded run); do not claim a fresh full-suite pass from this review. Builder's BUILD.md reports prior 1938/1938 on its environment, but that report is not this review's independent full-suite result.
- This review neither modified the PR nor committed the evidence report.
