# S3 independent audit B — round 2 (T4, backend reliability/dependency candidate, unchanged R1 head)

Status: **CLEARED (bounded) — S3-lane final-head attestation B.** Every inherited material evidence gap (S3-A-001…005, S3-B-01…03) is closed on attributable exact-head evidence; no material source defect was found in R1 or R2 review; two nonmaterial R2 notes are recorded. This is a merge-eligibility attestation for the S3 lane only. It is not release readiness, not cross-lane clearance, and it does not certify hosted, Docker, Fly, workflow, RLS or customer behaviour.

Report written 2026-09-20 ~21:15Z. Independent check transcript: `execution/audits/s3-r2/b/INDEPENDENT_CHECKS.md`.

## 0. Identity, independence, tooling

- Role: independent R2 auditor B. Did not implement any part of the candidate. Did not read the current R2 auditor A report and had no contact with that auditor. Read both R1 reports (required for inherited closure).
- Requested model per dispatch rules: "Claude Fable 5, High". Actual known identity: Claude (Anthropic) running as a Perplexity Computer subagent; the runtime does not expose the concrete model version or reasoning setting, so neither is claimed.
- Actions: read-only `git`/`rg`/`sed`/`python3`/`sha256sum` against the pinned worktree and archived packet; two read-only fetches of published package sources (`@prisma/config@6.19.3`, `c12@3.1.0` on unpkg) to judge test adequacy. No installs, no candidate edits, no commits, no lock acquisition, no heavy tests, no hosted or customer systems, no subagents.

## 1. Exact candidate (independently verified)

| Item | Value |
|---|---|
| Repository | BradleyGleavePortfolio/growth-project-backend |
| Pinned worktree | `/home/user/workspace/worktrees/s3` (clean; no `node_modules`) |
| Base | `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` (ancestor of head) |
| Head | `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06` — **identical to the R1 head**; no source change since R1 |
| Tree | `83211d25d714e4c539cd3aa248a06ef0658fc8e7` |
| Range | 23 commits, 47 files, +5385/−712; 23/23 author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>` (G05 fields; not a signature claim) |
| Pre-fix head | `925780e0a1906593e5383c618311b6b17364b8dc`, tree `911bea30d2e58c2573dd8af948c27d8bd4ccb952`; differs from head by exactly `src/health/health.controller.ts` and `test/health-readiness-bounded.spec.ts`; `package.json`/`package-lock.json` identical between the two heads |
| Packet | `repos/evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/` at evidence commit `7ab6af940c16f087dcaabbf07a55e9154405e68a`; all 34 SHA-256 entries verify; logs are byte-identical to revision-1 (only prose and `publication/` differ); bundle `s3-backend-5c7b42b3.bundle` verifies against the pinned worktree and carries head `5c7b42b3` |

## 2. Review scope

Because the source is unchanged from R1, R2 is a risk-scoped re-attestation, not a second full source audit. I:

1. Re-read the whole boundary surface I consider consequential for a T4 reliability/redaction lane: `src/health/health.controller.ts`, `src/filters/http-exception.filter.ts`, `src/observability/{orm-diagnostics,process-errors,sentry-config}.ts`, the diffs of `src/main.ts`, `src/prisma.service.ts`, `src/common/cache-control.interceptor.ts`, `src/filters/throttler-exception.filter.ts`, `src/observability/logging.interceptor.ts`, `test/health-readiness-bounded.spec.ts`, `test/dependency-compatibility.spec.ts` (harness + c12 case), `.github/workflows/dependency-audit.yml`, the `ci.yml` and `fly.toml` deltas, `jest.config.js`, `tsconfig*.json`, `package.json` overrides and the resolved chain `@prisma/config → c12 → deepmerge-ts`.
2. Read every new packet log (01–16), all runner scripts, `REPORT.md`, `R1_DISPOSITIONS.md`, `PUBLICATION_MANIFEST.md`, the packet README with parent cautions, and both R1 reports.
3. Challenged the new evidence's applicability (head/tree/env binding), adequacy (does the passing test prove the claimed seam), and completeness (does the full run cover the default selection) with the independent checks summarised in §3.

Not re-done: R1's exhaustive lockfile graph diff, override consumer mapping, R75 checker/policy reading, workflow-by-workflow reading, and scout copy review. Those R1 conclusions stand unless contradicted below; none were.

## 3. Applicability and adequacy of the new exact-head evidence

| Log | Binding | Adequacy judgement |
|---|---|---|
| 09 tsc (CI heap) | head/tree/node/npm stamped; **`NODE_OPTIONS` not recorded**; no end timestamp | Exit 0. The identical command OOM'd deterministically at the ~2 GB default heap 9 minutes earlier (05). A larger heap is the only plausible deciding input; the disposition says it was passed via `env` on the launch line but no script in the packet shows it (`run-step.sh` does not stamp env). Corroboration: `npm run build` (13, env stamped) type-compiles `src/**` under `tsconfig.build.json` exit 0; ts-jest compiled every test file in run 10 under relaxed strictness. Test-file strict type-check therefore rests on 09 alone. Accepted, with the provenance caveat recorded as S3-R2B-01. |
| 10 full jest, 4 shards, CI heap | header stamped; `run-full-sharded.sh` exports the 4 GB heap; loadavg per shard 4.7→2.2 | All 4 shards exit 0, `overall_exit=0`. Shard totals sum to 557 suites, which equals my independent count of spec files selected by `jest.config.js` (roots × `\.spec\.ts$` minus `test/rls/**`, `test/rls-*.spec.ts`), so the selection is the full default suite with no overlap or omission. 545 PASS / 12 skipped / 0 FAIL; 8209 tests passed / 159 skipped / 5 todo. Every suite in the candidate diff appears as PASS (incl. `dependency-compatibility`, `health-readiness-bounded`, all four `r75-*`, `r100-pathspec`, `dependency-audit`, `fly-readiness`, `orm-composed-http`, `sentry-incoming-request`). Skipped-suite names are not printed under `--silent`; the builder's attribution (DB-gated `describe.skip` suites in `test/community/**`, `test/mwb-3-*`) is consistent with source and none of those files is in the diff (S3-R2B-02, informational). |
| 11 readiness trio | fully stamped (`NODE_OPTIONS`, loadavg 0.08) | 3 suites / 20 tests PASS at head. The `readiness_database_unavailable` line in the output comes from `health.controller.spec.ts` (the bounded spec mocks `Logger.prototype.error`), so it is not a sign of the timeout path misfiring. |
| 12 control-source lint | fully stamped | Exact CI command, `--max-warnings 0`, exit 0. |
| 13 build | fully stamped | `nest build` exit 0, 30 s. |
| 14 c12 timing | fully stamped, loadavg 1.67 | Probe body printed with sha256 and is the same code path as the spec case (same `require('@prisma/config')`, fixture, `loadConfigFromFile`, `ConfigFileNotFound`). 474/549/456 ms ×3; spec 10/10 with the c12 case at 498 ms. |
| 15 npm audit | fully stamped, 17:26:36Z | 0 vulnerabilities at `--audit-level=high` over the whole locked graph. Time-dependent by nature. |
| 16 red baseline | head `925780e0`/tree `911bea30` stamped, probe printed verbatim with sha256, command recorded; `node_modules` symlinked (valid because the lockfile is identical between the heads — verified) | Pre-fix: handler still pending after 6000 ms. Fixed head: `readiness_database_timeout` event, `status 503`, settled. Attributable red→green for the only behavioural change in the final commit. B-02's request to run the bounded spec itself on the pre-fix head is genuinely impossible: the spec imports `READINESS_TIMEOUT_MS`, which `925780e0` does not export (verified). |
| 02, 05, 07, 08 (failed/OOM/partial) | stamped | Preserved unchanged as failed evidence; each has a passing successor at the same head. |

## 4. Inherited material findings — closure decisions (stable IDs)

### S3-A-001 / S3-B-01 — c12 + `deepmerge-ts@8` real-consumer probe: one ETIMEDOUT vs later passes; root cause not directly measured
**Decision: CLOSED as an evidence gap. Composition-defect hypothesis refuted; contention attribution accepted as the explanation, recorded as inference.**

Reasoning, independent of the builder's:
- Adequacy of the test: `@prisma/config@6.19.3` passes `deepmerge` from `deepmerge-ts` as c12's `merger`, and `c12@3.1.0` invokes `_merger(...)` unconditionally to produce `r.config` (both verified from published sources). The spec asserts the merged config values, so a passing c12 case genuinely exercises `deepmerge-ts@8` under its real consumer. This is the decisive proof for the riskiest override and it is now green in seven independent executions at the same tree (08 spec, 08 standalone, 14 ×3, 14 spec, 10 full suite), across loadavg 1.7–5.2.
- A deterministic hang is excluded by 7/7 completions. A nondeterministic hang inside a single-threaded, file-read-then-transpile loader with no concurrency has no mechanism and no second observation. The one failure was an external `spawnSync` kill at exactly the 20 000 ms bound, with the fixture directory retained (child never reached `finally`), i.e. slowness, not a crash.
- Independent corroboration that run 02 was host-starved rather than c12-specific: `test/rate-limit.spec.ts` took 606.8 s in run 02 and under the 5 s slow threshold in run 10 at the same tree; `scout.service.spec.ts` took 98 s in 02. A 100× slowdown of unrelated suites in the same process is what host contention looks like.
- What remains genuinely unknown: the failing child itself was never timed, so the attribution is inference, and CI-runner headroom for the fixed 20 s bound was not measured. Quiet-sandbox cost is ≈0.5 s (≈40× headroom).

Consequence of the residual: a required gate may produce a false red under extreme host load. That fails closed (blocks, never passes bad code), so it is a cycle-time/test-robustness cost, not a safety defect. Carried as nonmaterial follow-up under S3-B-05 (see §5). Not blocking.

### S3-A-002 / S3-B-02 — final fix's own test never executed at head; red baseline lacked provenance
**Decision: CLOSED.** Log 11 (3/20 PASS, fully stamped) and log 10 (PASS in shard 3) execute `test/health-readiness-bounded.spec.ts` at head. Log 16 gives an attributable red on `925780e0` and green on `5c7b42b3` with the same probe. My own re-read of `health.controller.ts` confirms: bound 3000 ms < Fly 5 s; timer cleared in `finally`; private `ReadinessTimeout` marker prevents misclassifying an ORM rejection as a timeout; both failure branches log static events with no driver text; client body is fixed `database_unavailable`; `Promise.race` subscribes to both promises so a late `$queryRaw` rejection cannot become an `unhandledRejection`; `/readyz` is throttler-whitelisted, `/api`-prefix-excluded and `no-store` via decorator and interceptor.

### S3-A-003 / S3-B-03 — tsc, full suite, R75 suites, build unevidenced; env not stamped
**Decision: CLOSED**, with one nonmaterial provenance caveat (S3-R2B-01). tsc exit 0 (09); full default suite 545/545 non-skipped suites PASS with all four `r75-*` suites (10); build exit 0 (13). Default-heap OOMs (05/07) are the CI-documented pre-existing heap requirement (`ci.yml` sets `--max-old-space-size=4096` for both steps on main) and are not candidate regressions.

### S3-A-004 — `npm audit` state unknown
**Decision: CLOSED for this lockfile as of 2026-09-20T17:26Z** (0 high/critical, whole graph, exit 0). Advisory state is time-dependent; the new workflow will re-evaluate on every PR/push and weekly, and it fails closed by design. Whether that check is *required* remains S2's branch-protection evidence.

### S3-A-005 — CI "Lint control sources" not run
**Decision: CLOSED.** Log 12: exact CI command, exit 0.

## 5. Inherited nonmaterial findings — R2 disposition (no source change requested)

| ID | R2 judgement | Why nonmaterial on this head (consequence-based) |
|---|---|---|
| S3-A-010 / S3-B-04 — 4xx `HttpException` with ORM cause renders 500 text | Agree: latent, deferred | Independently re-grepped: no `HttpException` in `src/` is constructed with an ORM `cause`; the only custom error carrying `cause` (`ProviderHttpError`) extends `Error` and maps to the generic 500 envelope. No customer can receive the incoherent envelope on this head. Must be fixed together with the first producer (D1 lane); deferral rationale is product consequence, not audit-binding preservation — acceptable. |
| S3-B-05 / S3-A-001(b)(c) — fixed 20 s child bound; assertion order hides child stderr on timeout | Agree: follow-up | Fails closed; ≈40× quiet headroom; CI headroom unmeasured. Smallest fix unchanged from R1: measured/env-overridable hang-guard bound plus a single combined assertion so a timeout prints child output. |
| S3-B-06 — startup/readiness logs drop Prisma class code | Agree: follow-up | Redaction goal met; the new timeout/unavailable split already restores the most operationally useful distinction. |
| S3-B-07 / S3-A-013 — `stripSensitiveHeaders` dead in production path | Agree: hygiene | Replacing allowlist is stricter. |
| S3-B-08 / S3-A-012 — non-ORM Sentry events drop `contexts.trace`, `sdk`, etc. | Agree: documented trade-off | Loses trace linking, leaks nothing. Optional re-allow of `contexts.trace`/`sdk`. |
| S3-B-09 — scout push copy wording | Agree: product-copy owner | Direction (no completion claim) satisfies G02. |
| S3-A-016 — diagnostics path is route template or `[unmatched]` | Agree: accepted | Low-cardinality labels, `request_id` retained. |
| S3-A-011 / B residual — stranded `$queryRaw` after the 3 s bound | Agree: strict improvement, cross-lane | Realistic outages (connection refused/black-hole) fail within Prisma `connect_timeout` and release the slot; only a server-side hung statement on an established connection can pin pool slots, which needs connection-string/`statement_timeout` parameters owned by S1/S2. |
| S3-A-014 / S3-B-12 — danger 13 end-to-end | S2 workflow lane | Dev-only; fails visibly in CI if broken. |
| S3-A-015 / S3-B-11 — R75 policy read from candidate head; S3-A-017 / S3-B-10 — Fly check activation semantics | S2 lane prerequisites, not adjudicated here | Recorded as merge-adjacent/release prerequisites in §7. |

## 6. New R2 findings

### S3-R2B-01 (nonmaterial, evidence provenance) — tsc pass (log 09) does not record the heap setting that made it pass
- Consequence: the strict type-check of `test/**` (excluded from `tsconfig.build.json`) at head is attested by a log whose deciding input is inferred, not recorded. G09 asks for material inputs to be bound. Practically the outcome is near-certain (deterministic OOM at default heap, later pass; build and ts-jest corroborate), so this does not change my verdict, but it is the one inference left in the material evidence chain and it costs ~1–2 minutes to remove.
- Smallest action: see §8 item 1. If that re-run exits non-zero, this clearance is void for S3-A-003 and the head needs a fix.

### S3-R2B-02 (informational) — skipped suites in the full run are counted but not named
- `--silent` with the default reporter prints counts only. Attribution to pre-existing DB-gated suites is consistent with source and none is in the diff, so acceptance is unaffected. Future full-run logs should include `--verbose` or a `--json` summary so skips are attributable by name (G08 "record intentional skips").

No new material finding. No unexplained failure remains: every failed/aborted log (02, 05, 07, 08 first attempt) has a documented harness or host cause and a passing successor at the same head.

## 7. Boundaries: what this attestation does and does not cover

- **Covered (S3 lane, merge-eligibility):** cumulative source `c23b9d9f..5c7b42b3` reviewed at R1 by two auditors and risk-re-read at R2; exact-head build, type-check, lint, control lint, full default jest suite, R75 range check, lockfile advisory audit; readiness red→green; identity fields.
- **Not covered / prerequisites owned elsewhere:** branch protection and required-context wiring for `dependency-audit.yml`, the rewritten R75 job and "Lint control sources" (S2); Fly readiness-check activation semantics and interplay with `auto_stop_machines` (S2, S3-A-017/B-10); candidate-controlled R75 policy trust (S2, S3-A-015/B-11); danger 13 end-to-end (S2); connection-string bounds for stranded queries (S1/S2); RLS suites (need Postgres); Docker image build; any deployment, enablement or customer evidence; S5 G2 proof. Merge is not deployment authorization (G17).
- **Evidence validity limits:** `npm audit` result is as of 17:26Z on 2026-09-20; all runs are on Node v20.20.1 / npm 10.8.2 on the 2 vCPU sandbox, not a CI runner. Any new head requires a fresh applicability decision (G09); my re-review scope for a follow-up head would be the changed files plus re-execution of the affected logs.

## 8. Requested precise extra execution (through parent; builder worktree `/home/user/workspace/worktrees/s3-backend`; test lock; ~2 min)

1. **Stamped tsc re-run (closes S3-R2B-01):**
   `NODE_OPTIONS=--max-old-space-size=4096 ./run-step2.sh 17-tsc-ci-env-stamped npx tsc --noEmit -p tsconfig.json`
   Acceptance: `exit=0` with `NODE_OPTIONS='--max-old-space-size=4096'` in the header. Recommended before merge because it is cheap; my attestation does not hinge on it, but a non-zero exit would void it.

No other execution is requested. I do not ask for a repeat of the full suite, build, audit, or readiness runs: their logs are bound to the exact head with stamped environment and I found no adequacy defect in them.

## 9. Verdict

**CLEARED (bounded) at head `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06`, tree `83211d25d714e4c539cd3aa248a06ef0658fc8e7`, for S3-lane merge eligibility.**

- All eight inherited material evidence gaps are closed on attributable exact-head evidence whose adequacy I independently checked (§3–4).
- No material source defect in the cumulative diff; the nonmaterial items in §5 and the two R2 notes in §6 are follow-ups whose consequences are bounded and explained, none of which a customer can hit on this head or which weakens a boundary.
- Residual risk accepted here is limited to: an environment-sensitive fail-closed test bound (S3-B-05), an unstamped heap setting on one passing log (S3-R2B-01, removable in ~2 min), and time-dependent advisory state. Any residual-risk acceptance beyond that (S2 hosting/protection items, S1 connection parameters) is not mine to grant and remains a release prerequisite.
- This is one of the two independent T4 attestations. It does not substitute for auditor A's, was not informed by it, and does not constitute release acceptance (G18) or cross-lane clearance for S1/S2/S4/S5.
