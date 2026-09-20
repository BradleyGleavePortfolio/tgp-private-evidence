# S3 independent R2 audit A — backend reliability

Completed: 2026-09-20, approximately 21:26 UTC. Exact machine observations are timestamped in the accompanying check results and remote-observation record. [Audit checks][checks] [Remote observations][remote]

## Verdict

**CLEAR for the bounded S3 source-and-local-validation re-attestation at `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06`; NOT an unconditional cumulative merge clearance, release approval, or production-readiness claim.** I close every inherited S3 material execution-evidence gap listed below. I found no new material defect in the risk-scoped cumulative source review. The distinct governance, artifact, database and hosted recovery prerequisites remain open at their affected merge/release boundaries; this report does not waive them. This conclusion uses the source, actual test selection/assertions, preserved failures and attributable completed logs—not the builder's proposed disposition or the passed-test count alone. [R1 A][r1a] [R1 B][r1b] [Completed packet][packet] [Governance][rules]

### Reviewer identity and independence

- Role: independent R2 auditor A, a fresh review of the unchanged R1 candidate; I did not implement it.
- Requested model: this R2 task does not expose a model-selection value. The inherited lane routing records “Claude Fable 5 / High”; that is a requested routing label, not runtime verification. Actual known identity: API AI assistant using Perplexity Computer tools; specific provider/model/version/reasoning setting not exposed to this reviewer. [Operator state][state]
- Read both prior R1 reports, as required. Did not read or communicate with the other current R2 auditor; no subagents.
- Actions: read-only Git/source/log inspection, Python integrity/selection/graph calculations, Git bundle verification, and read-only GitHub PR/main queries. No candidate edits, installs, new Jest/build/typecheck execution, commits, pushes, deployments, hosted configuration changes or customer-data access.
- Loaded the document-review guide during initial skill selection; its annotated-office-document workflow is not applicable to this source-code/evidence audit. The task's audit-report contract governs this artifact. [R2 mandate][brief]

## 1. Candidate and evidence applicability

| Item | Independently verified result |
|---|---|
| Repository | `BradleyGleavePortfolio/growth-project-backend`, `worktrees/s3` |
| Head / tree | `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06` / `83211d25d714e4c539cd3aa248a06ef0658fc8e7` |
| Base / merge base | `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`; base is an ancestor |
| Cumulative change | 23 commits; 47 changed files; 18 changed `.spec.ts` files |
| Worktree | Clean at opening and final static verification |
| Commit identity | All 23 author and committer fields are `Bradley Gleave <bradley@bradleytgpcoaching.com>`; no co-author/signed-off/generated trailers found; no signature claim |
| Current remote observations | Main still `c23b9d9f…`; #524 OPEN/draft at `238f0f1f…`, base main; #525 OPEN/draft at `925780e0…`, base `fix/op80-backend-dependency-repair` |
| Completed packet | `repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2`; 34/34 checksum entries match |
| Recovery | Incremental bundle verifies against the existing base and advertises the exact S3 head |

Local results are retained in [audit_checks.json][checks] and [identity-and-remote.txt][remote]; remote PR observations are also available at [#524](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/524) and [#525](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/525). The S3 final commit is not the head currently shown by either public PR; I do not attribute their CI to this candidate. [Audit checks][checks] [Remote observations][remote]

R1 and R2 source identities are equal. The new logs therefore apply to the same source reviewed in R1, with an independent adequacy decision here. Relevant dependency inputs also match: the pre-fix `925780e0` and final `5c7b42b3` lockfiles are identical; the v3 lock has 1,150 entries, matching root dependency declarations, registry URLs and integrity values for all package entries. Scoped deepmerge/multer/Swagger overrides and the removal of the blanket minimatch override remain intact. [Audit checks][checks] [Manifest][manifest] [Dependency consumer tests][deps]

**Evidence limits:** checksum agreement proves packet integrity, not independent execution or cryptographic attestation of historical worktree cleanliness. Logs stamp Git identity, but do not all record a dirty-tree check or complete environment. I accept the frozen-source/provenance chain and explicit commands for this local scope; I do not turn it into a reproducible-image or all-environments claim. Install log 01 predates the final commit and lacks a head stamp; its dependency-input applicability is supported by the unchanged lock and later exact-head real-consumer tests, not by pretending that it is itself an exact-head install log. The install deliberately skipped lifecycle scripts and explicitly generated Prisma; Docker's normal lifecycle is a different, untested path. [Install log][log01] [Timing log][log14] [Dockerfile][docker]

## 2. Scope and independent challenges

I re-read every cumulative production-source change: readiness/cache behavior; HTTP/throttler/logging/process/startup diagnostics; Sentry configuration; and Scout push copy. I inspected manifest/lock resolutions, the real-consumer compatibility spec, the readiness specs, composed HTTP/SDK tests, D1/D2 cause-chain/public-envelope tests and their assertion helper. I reviewed the R75 checker/policy, CI/hook/Fly diffs, vulnerability-gate shell/negative controls and representative R75 enforcement/wiring/boundary tests. I did not repeat every R1 fixture-case review or treat unrelated repository code as newly audited. [Source diff inputs][health] [HTTP filter][filter] [Telemetry boundary][sentry] [Compatibility tests][deps] [R75 checker][r75]

Independent static checks:

1. Reconciled all four full-suite shards with the unchanged Jest selection configuration: **557 selected spec files = 545 distinct PASS paths + 12 whole-suite omissions**, no duplicated PASS path, and all **18 changed specs** present as PASS. All 12 omitted suites are byte-identical to base; their live-DB gating is unchanged. [Audit checks][checks] [Full suite][log10] [Jest configuration][jest]
2. Recomputed totals: **8,209 passed, 159 skipped, 5 todo, zero reported failures**. These are the *default selected suite*, not every repository test or live DB/RLS coverage. `test/rls/**` and `test/rls-*.spec.ts` remain excluded. [Audit checks][checks] [Full suite][log10] [Jest configuration][jest]
3. Checked all 34 packet digests, bundle applicability, exact head/tree/base, manifest/lock alignment, changed-spec selection, and the empty intersection of the 21 source-lint warning paths with changed paths. This proves those warning-bearing files are unchanged; it is not a separately executed baseline lint run. [Audit checks][checks] [Source lint][log06]
4. Compared claimed c12 proof with its actual body and wrapper, rather than accepting “identical probe” literally; inspected the original timeout, later passes and the script's exit propagation. Findings and residuals appear below. [Original failure][log02] [Diagnostic history][log08] [Timing evidence][log14] [Timing wrapper][c12wrapper]

## 3. Every inherited material finding: explicit closure

| Stable inherited ID | Decision and independent rationale | Boundary |
|---|---|---|
| **S3-A-001 / S3-B-01** — c12 / deepmerge real-consumer failure unresolved | **CLOSED as a compatibility execution-evidence gap, not as proven root cause.** Log 14 records three successful timed loads at 474/549/456 ms and the actual unchanged compatibility spec 10/10, its c12 case 498 ms. The stricter actual spec asserts resolved config path, schema, migrations and missing-config behavior. Log 10 independently records that spec PASS in the broader suite; log 08 records an earlier 3,955 ms pass. These show the actual composed consumer works with the override, without relaxing its 20 s guard. Host contention is plausible, not demonstrated as the unique cause. Fixed-bound/diagnostic quality remains S3-B-05. [Logs 14][log14], [10][log10], [08][log08], [actual test][deps] | No remaining S3 compatibility block on this head. A recurrent failure on an otherwise adequately provisioned runner reopens this ID; it must not be silently retried away or labeled pre-existing. |
| **S3-A-002 / S3-B-02** — final readiness fix unexecuted; red provenance weak | **CLOSED.** Log 11 has all three real readiness suites, 20/20, at exact head/tree and stamped 4 GB heap; log 10 also includes them. Log 16 prints and hashes the same controller probe, records the pre-fix head/tree and shared identical-lock dependencies, observes “still pending after 6000ms,” then observes fixed-head 503/settled. This is an acceptable behavioral red/green, not a full pre-fix Jest run; the new spec imports a constant absent from pre-fix source. Exit 0 of the observation script alone is not the red result—the recorded pending/settled observations are. [11][log11], [16][log16], [readiness spec][bounded] | Local response-bound/redaction proof closed. Actual DB cancellation, pool recovery and Fly routing are not proved. |
| **S3-A-003 / S3-B-03** — full suite, R75, tsc, build incomplete | **CLOSED for local validation.** Logs 09/13 show successful tsc/build at exact head; log 10 has four complete shards, each exit 0, covering all changed specs including R75, dependency audit and bounded readiness. The sharder explicitly exports the CI heap and preserves `PIPESTATUS[0]`, so its zero is not merely the output filter's status. Default-heap failures remain preserved; base CI already documents the 4 GB requirement. No source repair is warranted solely for those OOMs. Log 09 still does **not independently stamp NODE_OPTIONS**: the builder's env-launch statement is corroboration, not a new measured header. A successful exact-head typecheck is sufficient here without claiming the heap value was captured. [09][log09], [13][log13], [10][log10], [sharder][sharder], [CI][ci] | Does not close actual CI execution, Docker/lifecycle, hosted enforcement, Danger PR execution or production artifact proof. |
| **S3-A-004** — vulnerability scan state unknown | **CLOSED for the lockfile/time measured.** Log 15 records the actual whole-lockfile npm audit flags, Node 20.20.1/npm 10.8.2, explicit “found 0 vulnerabilities,” exit 0. This is distinct from fake-npm gate tests. The workflow shell fails on nonzero registry/tool status and requests prod/dev/optional/peer dependencies. This does not mean no vulnerabilities exist, nor establish future advisory state or required-check enforcement. [15][log15], [workflow][auditwf], [negative controls][audittest] | Re-run applicable vulnerability/artifact gates on the integration/release candidate and then-current advisory state. |
| **S3-A-005** — control-source lint never executed | **CLOSED.** Log 12 matches CI's seven-file `npx --no-install eslint --max-warnings 0` invocation and exits 0; the R75 enforcement spec also uses real ESLint to prove the checker is not ignored and an unused-variable mutation is detected. This is stronger than the unrelated source-only lint result. [12][log12], [CI][ci], [enforcement test][enforcement] | Local control lint closed; branch-required enforcement remains S2. |

### c12 causality: what is and is not established

The original child exceeded its real 20,000 ms `spawnSync` bound; its partial diagnostics were not exposed by the first failing assertion. The same selected test later completed repeatedly without an override or timeout change. Concurrent host load, very slow unrelated suites, and shorter timings after contention subsided support an environmental explanation, but there is no failing-child CPU/I/O trace, controlled intervention, randomized cold/warm experiment or CI p99 measurement. I do **not** conclude “contention proven,” “deterministically fixed,” or “pre-existing flake.” [Original failure][log02] [Diagnostic history][log08] [Measured runs][log14] [Test guard][deps]

The packet's “identical child body” phrase is too strong: the standalone script follows the same real `loadConfigFromFile` composition and fixture, but omits some assertions and the test's retain-on-failure/finally structure, adds timing output, and runs as a file rather than the spec's `node -e` body. Its displayed `loadConfigFromFile ms` is cumulative elapsed time from `t0`, not the load-only duration. These differences invalidate a literal byte-identical performance comparison, **not** the subsequently logged actual-spec PASS. The finite 20 s guard has large measured quiet-host margin but no proven CI guarantee. [Published probe][probe] [Actual spec][deps] [Timing log][log14]

Closing the evidence gap without proving unique historical causation is justified by reproduced real-consumer behavior, unchanged behavioral assertions, bounded failure, and no repeatable composition defect. It is not an acceptance of an unresolved demonstrated production hang. If the true spec begins exceeding the bound under controlled normal conditions, S3-A-001/S3-B-01 must reopen before relying on the override. [Measured run][log14] [Full-suite selection][log10] [Original finding conditions][r1a]

## 4. Source/boundary adequacy, not merely green logs

**Readiness:** `Promise.race` bounds the handler's wait at 3 s when the event loop runs; `finally` clears the timer; rejection/timeout bodies contain only static database status and timestamp. The fake-timer test distinguishes 2,999 from 3,000 ms; real HTTP verifies 503, no-store and <5 s locally; rejection vectors include strings, plain objects, null/undefined and a throwing string conversion. Liveness remains DB independent, and `/readyz` remains public, prefix-excluded and throttle/dunning-exempt. No new auth/tenant/data-writing route is introduced. These facts do not prove a hard real-time upper bound under event-loop starvation. [Controller][health] [Bounded test][bounded] [Public-boundary tests][publicready] [Main wiring][main] [Throttle guard][throttle] [Dunning guard][dunning]

**Physical resource/recovery distinction:** `Promise.race` neither cancels Prisma work nor limits arbitrary external probe concurrency. Late rejection is observed by the race, but a black-holed query may still occupy connections. The HTTP response improvement does not close database/pool recovery or abuse-envelope questions; Fly's new periodic check makes actual outage/recovery evidence important. Those are S1/S2 release prerequisites, carried under S3-A-011/A-017/B-10, not hidden inside the word “bounded.” [Controller][health] [Fly configuration][fly] [R1 B residual][r1b]

**ORM and credential diagnostic boundaries:** cause-chain classification is cycle-guarded, allows only a validated Prisma code into sanitized diagnostics, and precedes the modified logger/process/Sentry sinks. ORM Sentry events are replaced by a static allowlist. Logging/throttler/HTTP diagnostic paths use route templates or `[unmatched]`, not caller URLs. Real Nest composition tests intercept actual output and local SDK envelopes; the separate-process default-integration fixture checks incoming path/query/referrer metadata after SDK enrichment. This is meaningful selection of real code, not only a mocked `beforeSend` call. [Sanitizer][orm] [Filter][filter] [Composed tests][composed] [Default-integration fixture][sdkfixture] [Full suite][log10]

**No universal privacy claim:** the separate-process fixture disables sampled tracing; the ordinary-event allowlist preserves arbitrary exception/message/logentry text and stack frames; aggregate/non-Error wrapper classification is not generalized. Transactions/spans, attachments, unrelated application loggers and real serving-role isolation are not certified by these tests. The README correctly names this boundary. Echoing the caller's URL in the client envelope is deliberately retained and tested, distinct from exporting it to telemetry. Future consumers that put secrets into ordinary errors or introduce ORM-bearing aggregates require fresh boundary work rather than inheriting this attestation. [Sentry implementation][sentry] [README][obsreadme] [Default-integration fixture][sdkfixture] [Composed tests][composed]

**Dependencies and truthful outcomes:** the graph and tests cover actual scoped consumers, both deepmerge module conditions, config loading, multipart truncation/size rejection, WebSocket limits and YAML/Istanbul/Danger-local behavior. This is adequate for the measured dependency repair, not the full Danger GitHub DSL or a production image. Scout's successful transport push now says records were staged and migration is not verified; the legacy `import.complete` event name is not native completion proof. [Dependency tests][deps] [Manifest][manifest] [Scout source][scout]

**Gate boundaries:** R75 measures real Git blobs, detects index drift and malformed inputs, and the associated tests run the real checker and workflow/hook shell bodies with negative mutations. These are local functional proofs. Candidate-controlled policy/workflow content and non-certifying manual runs are not a trusted governance boundary. S2 must prove authoritative required-check selection and enforcement outside unilateral candidate control. [Checker][r75] [R75 wiring tests][wiring] [Policy][policy] [R100 workflow][r100]

## 5. All inherited nonmaterial/cross-lane dispositions

“Deferred” below means still present, not repaired. I independently agree these source follow-ups need not force a new S3 head just to obtain this local attestation; ownership transfer does not close a material release/control prerequisite. [R1 A][r1a] [R1 B][r1b] [Governance G10/G11][rules]

| IDs | R2 decision, consequence and reopen/closure condition |
|---|---|
| **S3-A-010 / S3-B-04** | **Deferred, latent client-copy defect.** ORM-caused 4xx retains 4xx status but uses 500 text; the helper proves nonempty text, not coherent semantics. Production-source search found no current HttpException ORM-cause producer; do not generalize this to impossibility through future libraries. Fix status-appropriate generic copy and assertions before such a producer/consumer relies on it. [Filter][filter] [Harness][harness] |
| **S3-A-011 / B unnumbered stranded-query residual** | **Open release recovery constraint, no new S3 source change required.** In-flight query cancellation/concurrency is not solved. S1/S2 must establish effective connection/query timeout behavior and restoration after outage for the deployed configuration; a 503 test is not that evidence. [Controller][health] [R1 B][r1b] |
| **S3-A-012 / S3-B-08** | **Deferred/intentional observability trade-off.** Trace/context/sdk/user/fingerprint/extra loss reduces diagnosis/correlation, but tightens the demonstrated error-event metadata boundary. Retaining `contexts.trace`/`sdk` is optional only after validating their actual data—not merely assuming those objects can never contain sensitive content. [Sentry][sentry] [README][obsreadme] |
| **S3-A-013 / S3-B-07** | **Deferred hygiene.** `stripSensitiveHeaders` is no longer called by `beforeSend`; obsolete test/documentation framing should be removed or labeled retained-for-callers. The wholesale metadata omission is stricter, so dead helper presence is not a leak. [Sentry][sentry] |
| **S3-A-014 / S3-B-12** | **Open S2/CI integration prerequisite.** Danger-local probe does not exercise `dangerfile.js` against the real PR DSL/API. No evidence here that the major bump breaks it; nevertheless, its applicable enforced PR job must run successfully before landing. [Compatibility spec][deps] [Danger workflow][danger] |
| **S3-A-015 / S3-B-11** | **Open governance/merge prerequisite; NOT closed by R75 passes.** A candidate can alter its own policy/checker/workflow. An enforced trusted control and eligible independent review must exist before relying on the gate. S2 owns resolution; this report cannot approve its absence. [Checker][r75] [Policy][policy] [Rules G01/G07/G17][rules] |
| **S3-A-016** | **Accepted limited trade-off.** Route-template/unmatched diagnostics reduce raw-URL detail and cardinality while preserving explicit request correlation. No claim of full async logger-context isolation follows. [Logging interceptor][logging] [Composed tests][composed] |
| **S3-A-017 / S3-B-10** | **Open S2 release/auto-deploy-merge prerequisite.** Literal Fly config tests do not demonstrate traffic withdrawal, lack of restart, startup grace, suspended-machine behavior or successful rerouting after recovery. Candidate comments are intentions, not hosting observations. [Fly][fly] [Config test][flytest] |
| **S3-B-05 / S3-A-001 diagnostic follow-ups** | **Deferred harness robustness.** Fixed 20 s bound and assertions that hide stderr make heavily contended failures expensive to diagnose. Quiet measurements do not justify automatic retries. On recurrence, retain stderr/status/signal/elapsed time and inspect host/environment before deciding whether to change the guard. [Spec][deps] [Timing][log14] |
| **S3-B-06** | **Deferred diagnosability.** Static startup/readiness events do not distinguish safe Prisma class codes such as authentication/unreachable categories. Consider validated code-only metadata later; do not restore raw driver strings. [Controller][health] [Prisma startup][prisma] |
| **S3-B-09** | **Deferred copy refinement.** Staging/noncompletion meaning is correct; “TGP” and “importer status” still need product-surface wording reconciliation. Does not falsely establish native import completion. [Scout][scout] |

Builder-only residuals are also not silently closed: aggregate traversal is unsupported; ordinary client URL echo remains; non-exiting uncaughtException reporting is inherited rather than proved safe recovery; and Node 26 types against a Node 20 runtime do not prove runtime API support. They do not introduce a demonstrated material defect in this reviewed delta, but constrain any universal reliability/privacy claim. [Builder report][builder] [Sanitizer][orm] [Main][main] [Manifest][manifest]

## 6. New R2 observation

### S3-R2A-001 — Proof precision and diagnostic wrapper status (nonmaterial evidence-quality follow-up)

The timing packet should be read as **same consumer path + separate actual-spec proof**, not byte-identical standalone/test scripts or a causal performance experiment. In addition, `c12-timing.sh` does not propagate each probe failure into an aggregate exit and ends with a pipeline without `pipefail`; `run-step2.sh` prints a child exit but does not return it as its own final status. Consequently a launcher/wrapper zero by itself cannot certify these steps. For this packet I inspected the actual three `probe exit=0` lines, assertion-bearing spec PASS/10-of-10 output, and each logged underlying exit; none is being accepted solely from a wrapper status. The full-suite sharder correctly captures Jest's `PIPESTATUS[0]`. [Timing wrapper][c12wrapper] [Step wrapper][stepwrapper] [Timing output][log14] [Sharder][sharder]

Owner: validation/evidence harness maintainer. Smallest follow-up: aggregate and propagate all underlying statuses; print full error/status/signal/stderr on probe failure; distinguish cumulative elapsed labels from phase durations. No candidate source edit or repeat of successful broad executions is required to resolve this packet's interpretation. This becomes material if a future proof cites only the launcher status or omits child results. [Current wrapper behavior][stepwrapper] [Probe test][deps]

## 7. Remaining gates and exact next action

**No additional S3 test execution is requested from parent for this unchanged head.** More full-suite reruns would not prove historical c12 causality or hosting behavior; the current attributable evidence is sufficient for the bounded source/local scope. Retain the original timeout/OOM/harness-error logs, this finding-level closure, and the packet unchanged. [Completed logs][packet] [Governance G10][rules]

Parent must still:

1. Obtain the other genuinely independent final-head attestation and reconcile any substantive disagreement without assuming my verdict transfers. [Rules G06/G10/G11][rules]
2. Complete S2's trusted-policy/required-check/reviewer route, actual applicable CI including Danger, source-to-artifact identity, dependency/lifecycle/image/SBOM/security checks and rollback/containment proof on the **integrated** candidate. No source-tree equality shortcut validates altered build/config inputs. [Rules G07/G16/G17][rules] [Dockerfile][docker]
3. Keep S1 authorization/serving-role and database recovery, and S2 effective Fly outage/recovery/configuration proof, as explicit release blockers. The focused platform proof must observe healthy routing → induced authorized DB unavailability → bounded redacted readiness/failing routing behavior → DB restored and pool/routing recovery, without exposing credentials or touching customers in this audit. This is the existing cross-lane prerequisite, not a request to run a live test now. If merging auto-deploys, these release prerequisites also block merge. [Rules G12/G15/G17][rules] [Fly configuration][fly] [R1 residuals][r1b]
4. Reassess evidence applicability after S1/S2 composition or any new head, especially the 3 s application / 5 s platform relationship, telemetry configuration, dependency graph and install/runtime identity. This report proves no G2 migration phases, hosted enablement or native customer outcome. [R2 mandate][brief] [Operator state][state]

**Final bounded disposition: S3's inherited material local-evidence findings are closed; source/local re-attestation is affirmative at the exact unchanged head. Overall governed landing/release remains NOT CLEARED by this report.** [Closure evidence][log10] [Readiness evidence][log11] [Compatibility evidence][log14] [Constitution][rules]

[brief]: ../../../../execution/R2_AUDIT_BRIEF.md
[rules]: ../../../../repos/context/AGENT_RULES.md
[state]: ../../../../repos/context/LAST_OPERATOR_STATE.md
[r1a]: ../../../../repos/evidence/2026-09-20/audits/s3-r1/a/revision-1/REPORT.md
[r1b]: ../../../../repos/evidence/2026-09-20/audits/s3-r1/b/revision-1/REPORT.md
[packet]: ../../../../repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/
[builder]: ../../../../repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/REPORT.md
[log01]: ../../../../repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/logs/01-npm-ci.log
[log02]: ../../../../repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/logs/02-focused-a.log
[log06]: ../../../../repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/logs/06-lint.log
[log08]: ../../../../repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/logs/08-f1-diagnostic.log
[log09]: ../../../../repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/logs/09-tsc-ci-env.log
[log10]: ../../../../repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/logs/10-full-jest-sharded.log
[log11]: ../../../../repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/logs/11-readiness-trio.log
[log12]: ../../../../repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/logs/12-control-source-lint.log
[log13]: ../../../../repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/logs/13-build.log
[log14]: ../../../../repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/logs/14-c12-timing.log
[log15]: ../../../../repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/logs/15-npm-audit.log
[log16]: ../../../../repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/logs/16-readiness-red-baseline-925780e.log
[sharder]: ../../../../repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/logs/run-full-sharded.sh
[c12wrapper]: ../../../../repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/logs/c12-timing.sh
[stepwrapper]: ../../../../repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/logs/run-step2.sh
[probe]: ../../../../repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/publication/f1-probe.js
[checks]: audit_checks.json
[remote]: identity-and-remote.txt
[manifest]: ../../../../worktrees/s3/package.json
[deps]: ../../../../worktrees/s3/test/dependency-compatibility.spec.ts
[health]: ../../../../worktrees/s3/src/health/health.controller.ts
[bounded]: ../../../../worktrees/s3/test/health-readiness-bounded.spec.ts
[publicready]: ../../../../worktrees/s3/test/health-readiness-public.spec.ts
[filter]: ../../../../worktrees/s3/src/filters/http-exception.filter.ts
[orm]: ../../../../worktrees/s3/src/observability/orm-diagnostics.ts
[sentry]: ../../../../worktrees/s3/src/observability/sentry-config.ts
[obsreadme]: ../../../../worktrees/s3/src/observability/README.md
[logging]: ../../../../worktrees/s3/src/observability/logging.interceptor.ts
[composed]: ../../../../worktrees/s3/test/observability/orm-composed-http.spec.ts
[sdkfixture]: ../../../../worktrees/s3/test/observability/fixtures/sentry-incoming-request.cjs
[harness]: ../../../../worktrees/s3/test/scout/diagnostics-public-harness.ts
[main]: ../../../../worktrees/s3/src/main.ts
[prisma]: ../../../../worktrees/s3/src/prisma.service.ts
[scout]: ../../../../worktrees/s3/src/scout/scout.service.ts
[throttle]: ../../../../worktrees/s3/src/throttler/user-throttler.guard.ts
[dunning]: ../../../../worktrees/s3/src/checkout/dunning-v2/dunning-lockout.guard.ts
[r75]: ../../../../worktrees/s3/scripts/check-r75.js
[policy]: ../../../../worktrees/s3/.github/r75-policy.json
[r100]: ../../../../worktrees/s3/.github/workflows/r100-quality-gate.yml
[wiring]: ../../../../worktrees/s3/test/ci/r75-wiring.spec.ts
[enforcement]: ../../../../worktrees/s3/test/ci/r75-enforcement.spec.ts
[auditwf]: ../../../../worktrees/s3/.github/workflows/dependency-audit.yml
[audittest]: ../../../../worktrees/s3/test/ci/dependency-audit.spec.ts
[ci]: ../../../../worktrees/s3/.github/workflows/ci.yml
[danger]: ../../../../worktrees/s3/.github/workflows/danger.yml
[fly]: ../../../../worktrees/s3/fly.toml
[flytest]: ../../../../worktrees/s3/test/ci/fly-readiness.spec.ts
[jest]: ../../../../worktrees/s3/jest.config.js
[docker]: ../../../../worktrees/s3/Dockerfile
