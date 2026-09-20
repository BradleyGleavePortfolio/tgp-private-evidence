# S2 delivery controls — independent R2 audit A

Completed 2026-09-20 UTC. **Bounded verdict: NOT CLEARED for cumulative T4 merge/activation.** A reproducible privileged-workflow shell-injection defect remains; hosted enforcement, image/build evidence, integrated migration/recovery, and final composition are separately unproved, not invented code failures. ([Probe results](probe-summary.txt), [revision-3 packet](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/REPORT.md))

## 1. Independence, identity, scope

Reviewer: independent R2 auditor A, this AI assistant in the Computer tool environment. The lane handoff requests Claude Fable 5 / High; this auditor's actual provider/model version and reasoning setting are not exposed, and I do not attest that the requested model was supplied. Tools actually used: read-only Git inspection, Bash, Python, PyYAML, jq, and offline synthetic fixtures. No builder participation, current R2 peer report access, peer coordination, subagents, candidate edits, installs, hosted calls, commits, publication, deployment, or activation.

| Identity | Independently observed |
|---|---|
| Repository/worktree | `BradleyGleavePortfolio/growth-project-backend`, `/home/user/workspace/worktrees/s2` |
| Base / merge base | `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` |
| Exact audited head | **`0b05fcf5352287109ac88ed2ba3682e441e3a076`** |
| Exact tree | **`fba0a9f06127979005b70ca3da80584a1e2ce10c`** |
| Evidence/context snapshots | `7ab6af940c16f087dcaabbf07a55e9154405e68a` / `7e731732691b3370ba4e891efcae49e16e8512db` |
| Worktree/commit identity | Clean before and after probes; five cumulative commits have Bradley Gleave author and committer, `bradley@bradleytgpcoaching.com`, no co-author trailer. |

The table is supported by [identity capture](identity.txt) and [post-probe checks](static-checks.txt); these are local immutable-snapshot observations, **not fresh GitHub PR/head/settings observations**.

Reviewed the cumulative base→head controls and R1→R2 delta: all changed workflow/control/image/doc files, the focused tests and fixtures, supporting `fly.toml`, package/build inputs, CI/readiness/migration workflow wiring, runtime file-writing locations, and the S1 `verify.sql` integration interface. Read both prior R1 reports, latest S2 revision-3 packet and logs, S2 cross-lane directions, and S5's four-item cross-lane disposition; did not audit S1/S3/S5 product implementations or the combined preview as a new final candidate. ([R1 A](../../../../repos/evidence/2026-09-20/audits/s2-r1/a/revision-1/REPORT.md), [R1 B](../../../../repos/evidence/2026-09-20/audits/s2-r1/b/revision-1/REPORT.md), [packet](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/REPORT.md), [S5 directions](../../../../repos/evidence/2026-09-20/remediation/s5-r2/cross-lane/S5_CROSS_LANE_DISPOSITION.md))

Governance applied: G01–G22, particularly G05–G11 and G16–G18; EXECUTE; G0 delivery prerequisites and the separately promoted G2 phases, not obsolete universal LOC/test-volume ceremony. ([Constitution](../../../../repos/context/AGENT_RULES.md), [EXECUTE](../../../doctrine/EXECUTE.txt), [plan](../../../../repos/context/handoffs/op81/CONTINUATION_AND_ROMAN_IMPORT_PLAN.md))

## 2. Evidence accepted and challenged

- **115/115 exact-head focused tests accepted as shared attributable evidence**, not rerun by me: the revision-3 log stamps `0b05fcf5…` / `fba0a9f0…`, clean status, Node 20.20.1, npm 10.8.2, and `jest_exit=0` before/after the run; I reproduced its SHA256 `92370aa454a81c5eeab06be0cd9228cf884e914e3b6a85d412f9457b1a52c94b`. ([Test log](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/s2-r2-test-at-0b05fcf5.log), [identity capture](identity.txt))
- The earlier runtime-stage host replay is stamped **`cb0bc910…`**, records install/build/assertion success, and neither builds an image nor exercises final `USER node` runtime/release behavior or the newly added verifier loop. ([Replay script](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/local-runtime-stage-replay.sh), [replay log](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/local-runtime-stage-replay.log), [Dockerfile](../../../../worktrees/s2/Dockerfile))
- **394/394 is not evidence for final preview `6b85395f…`**: it predates the S1 merge, and the final S2+S3+S1 preview remains unexecuted; this review does not promote that result into combined clearance. ([Manifest](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/MANIFEST.md))
- I ran syntax checks on seven changed shell scripts and parsed workflow YAML; neither is actionlint, shellcheck, workflow execution, or Docker validation. ([Static checks](static-checks.txt))
- I ran eleven small serial offline probes in this audit directory only; no database, browser, real Fly/GitHub CLI, credentials, or heavy test suite was used. ([Probe program](probe.py), [results](probe-summary.txt))

| Probe | Actual outcome / interpretation |
|---|---|
| P01 valid API fixture + archived 357-component SBOM + actual release lockfile | Gate exits 0. |
| P02 zero-rule CodeQL | Gate exits 1. |
| P03 unprotected environment | Gate exits 1. |
| P04 newest failed CI run | Gate exits 1. |
| P05 three required SBOM names only, fabricated versions `999.999.999` | Gate exits 0: assertion is not complete closure/version verification. |
| P06/P07 actual workflow run text + harmless hostile app string | Shell command substitution executes in logs-dump and recent-auth secret step. |
| P08/P09 isolated release step 4 with fake Prisma | Success counted; failing verifier exits 1. |
| P10 same step with failing verifier discovery | Exits 0 and reports zero verifiers. |
| P11 expected SHA/tag + other image repository + critical health check | Image verifier exits 0: label/digest shape check, not health/build-origin attestation. |

Each outcome has its own log beside [the reproducible probe program](probe.py); [summary](probe-summary.txt) lists exit codes. P08–P10 isolate the exact step-4 text with only its hard-coded temporary log path relocated; they are not an end-to-end `release.sh`/Prisma/PostgreSQL run.

## 3. New findings

### S2-R2-A-01 — Privileged operator workflows interpret dispatch inputs as shell programs

**Material source defect; blocks cumulative S2 T4 merge clearance and use of the affected workflows. Owner: S2.**

`fly-logs-dump.yml` embeds `inputs.app` directly in `run:` shell text, `fly-secrets-list.yml` embeds `github.event.inputs.app`, and `fly-recent-auth-set.yml` embeds both `inputs.confirm` and `inputs.app`; several affected steps hold `FLY_API_TOKEN`, and the recent-auth mutation step also holds the application auth secret. ([Logs dump L20–33](../../../../worktrees/s2/.github/workflows/fly-logs-dump.yml), [secrets list L15–19](../../../../worktrees/s2/.github/workflows/fly-secrets-list.yml), [recent-auth L20–51](../../../../worktrees/s2/.github/workflows/fly-recent-auth-set.yml))

P06/P07 substituted an app string containing a harmless `$(printf … > audit-marker)` into the actual YAML step text and executed it with an offline fake `flyctl`; both markers were created, proving input becomes executable code rather than an opaque app argument. ([P06 expanded line](p06-expanded-logs-line.sh), [P06 result](p06-logs-input-shell-execution.log), [P07 expanded step](p07-expanded-recent-auth-step.sh), [P07 result](p07-recent-auth-input-shell-execution.log))

Consequence: an identity allowed to dispatch an ostensibly bounded operator action can run arbitrary code in a credential-bearing step without changing protected source; action commit pins do not mitigate that path, and environment approval on recent-auth authorizes the whole job rather than sanitizing the input. This is inherited code in workflows deliberately touched and included in S2's cumulative privilege-hardening claim, not introduced by R2's pin change. ([Affected workflows](static-checks.txt), [R2 cumulative claim](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/REPORT.md))

Smallest fix: pass **all** inputs into `env:` and use quoted shell variables, like the safe pattern already used by `fly-feature-flags-set.yml`; validate/allowlist the production app, and add execution-level negative tests using `$()`, quotes, newlines, and shell separators in these three workflows. ([Existing safe pattern](../../../../worktrees/s2/.github/workflows/fly-feature-flags-set.yml))

### S2-R2-A-02 — “Read-only” logs-dump is actually an unprotected machine-start route

**Material activation/hosted-configuration blocker; also prevents closing inherited S2-B10. Owner: S2.**

`fly-logs-dump.yml` has no `environment:` but calls `flyctl machine start "$MID"` and ignores failure; the R2 packet classifies it among the three read-only workflows left outside `production`, which is factually wrong. ([Workflow L11–33](../../../../worktrees/s2/.github/workflows/fly-logs-dump.yml), [builder disposition](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/REPORT.md))

Consequence: while a repository-level Fly token is available, this route can restart a deliberately stopped old machine outside production approval and invalidate containment/drain assumptions; after the token is removed, the workflow instead loses access, which must be an intentional disabled capability rather than an undocumented breakage. ([Workflow](../../../../worktrees/s2/.github/workflows/fly-logs-dump.yml), [token-move proposal](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/LANDING_PROPOSAL.md), [S5 drain direction](../../../../repos/evidence/2026-09-20/remediation/s5-r2/cross-lane/S5_CROSS_LANE_DISPOSITION.md))

Smallest fix: either remove machine start and make the workflow genuinely read-only with a suitable read-only identity, or bind the mutation to production approval, main-only eligibility, explicit intent and the recovery/drain coordination policy; remove repository-scoped deploy credentials before treating environment isolation as enforced.

### S2-R2-A-03 — Verifier discovery errors are converted into “zero verifiers passed”

**Bounded fail-open source defect in the new catalog-verifier control; material for relying on that control on the integrated S1 release, not evidence that an actual database verification failed. Owner: S2.**

`done < <(find … | sort)` does not propagate the process-substitution pipeline's failure to the parent loop, and zero verifiers is explicitly accepted; P10 supplies a discovery failure and gets exit 0 with `verifiers_passed = 0`. ([Release L185–200](../../../../worktrees/s2/scripts/release.sh), [P10](p10-verifier-discovery-failure.log))

The ordinary positive/failing-verifier paths work (P08/P09), but the test in `delivery-artifact.spec.ts` is a string-order/regex assertion and does not cover discovery failure; a missing/unreadable migration tree or broken enumeration can therefore omit the catalog control instead of failing visibly. ([P08](p08-verifier-success.log), [P09](p09-verifier-failure.log), [test L491–509](../../../../worktrees/s2/test/ci/delivery-artifact.spec.ts))

Smallest fix: collect the verifier list through an explicitly checked command/pipeline before the loop, then iterate the captured list; distinguish successful empty enumeration on standalone S2 from failure, and on the integrated release assert the required S1 verifier is present. Add negative enumeration and real Prisma drift-failure evidence before activation.

### S2-R2-A-04 — “Production closure re-proof” accepts an incomplete, wrong-version SBOM

**Nonblocking assurance/claim limitation for source merge; exact release inventory remains an activation prerequisite. Owner: S2.**

The assertion excludes known dev-only `name@version` pairs and checks three required package **names**, but never requires the rest of the production closure or matches required package versions to the release lockfile; P05 passes the full gate with only those three names at fabricated versions. ([Assertion L35–58](../../../../worktrees/s2/scripts/ci/assert-prod-sbom.sh), [P05](p05-incomplete-wrong-version-sbom.log))

This is not proof that the real archived/npm-generated SBOM is wrong or that an untrusted party can replace a trusted run artifact; it means the advertised independent re-proof is narrower than complete closure equivalence, and the sidecar only detects inconsistent bytes between two files supplied together. ([SBOM workflow L48–91](../../../../worktrees/s2/.github/workflows/sbom.yml), [gate L151–178](../../../../worktrees/s2/scripts/ci/release-evidence-gate.sh))

Smallest fix: either accurately call this a denylist/sentinel-package check, retaining the trusted generator as the closure authority, or compare normalized expected production package/version sets with explicit platform/optional-dependency handling; do not claim it proves the image inventory.

### S2-R2-A-05 — Recovery guidance still overstates what a failed deploy leaves untouched

**Material before release/recovery use; not an additional automatic-merge trigger. Owner: S2 with S1 for database semantics.**

Runbook §3 step 3 says a deploy abort leaves previous machines running and requires no manual revert; however this workflow can fail **after** deployment in image/readiness checks, and a catalog verifier can fail **after** successful migration application while the old application still uses the changed database. ([Runbook L284–288](../../../../worktrees/s2/docs/deploy-runbook.md), [deploy L181–213](../../../../worktrees/s2/.github/workflows/fly-deploy.yml), [release L152–199](../../../../worktrees/s2/scripts/release.sh))

The same section's “previous image still expects the new schema” is not a compatibility proof, and the inherited S2 cross-lane note's “re-dispatch previous main sha” conflicts with the implemented forward-only gate. ([Runbook L306–310](../../../../worktrees/s2/docs/deploy-runbook.md), [cross-lane recovery note](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/CROSS_LANE_DISPOSITION.md), [SHA equality check](../../../../worktrees/s2/scripts/ci/release-evidence-gate.sh))

Smallest fix: split pre-migration failure, migration/verification failure, and post-rollout failure; require actual machine/catalog observations and schema-compatibility evidence before rollback/forward repair, with containment/drain and authorization where required. Treat the current forward-revert path as canonical, explicitly supersede the earlier redispatch advice, and drill recovery before activation.

## 4. Prior R1 dispositions on this exact head

“Closed in source” below is not hosted execution or activation clearance; both original reports remain the stable finding records. ([R1 A](../../../../repos/evidence/2026-09-20/audits/s2-r1/a/revision-1/REPORT.md), [R1 B](../../../../repos/evidence/2026-09-20/audits/s2-r1/b/revision-1/REPORT.md))

| Stable inherited IDs | Independent R2 disposition |
|---|---|
| S2-A-01 | **Source fix accepted, hosted prerequisite open.** Reviewer-presence + `can_admins_bypass == false` are required and P03 rejects the unprotected case; this does not verify actual identity eligibility, environment branch restrictions or branch protection. ([Gate L180–187](../../../../worktrees/s2/scripts/ci/release-evidence-gate.sh), [P03](p03-unprotected-environment.log)) |
| S2-A-02 / S2-B4 | **Closed in source.** Empty/errored CodeQL is rejected; P02 independently confirms zero rules fails. ([Gate L136–149](../../../../worktrees/s2/scripts/ci/release-evidence-gate.sh), [P02](p02-empty-codeql.log)) |
| S2-A-03 | **Narrow original defect closed:** gate really reruns the assertion; complete-closure wording remains too strong under new S2-R2-A-04. ([Gate L170–178](../../../../worktrees/s2/scripts/ci/release-evidence-gate.sh)) |
| S2-A-04 / S2-B6 | **Partially closed.** Previous machines, filtered evidence, explicit forward-only route, failure-labelled manifest are implemented; recovery wording/drill still open under S2-R2-A-05. ([Deploy](../../../../worktrees/s2/.github/workflows/fly-deploy.yml), [delivery recovery](../../../../worktrees/s2/docs/delivery-controls.md)) |
| S2-A-05 / S2-B7 | **S2 mitigation accepted, integrated migration boundary open.** Diff/unknown requires acknowledgement; it neither queries actual pending production migrations nor proves backup, compatibility, approval, or phase separation; verifier discovery needs S2-R2-A-03. ([Delta script](../../../../worktrees/s2/scripts/ci/migration-delta.sh), [release](../../../../worktrees/s2/scripts/release.sh)) |
| S2-A-06 | **Closed in source.** Uploaded machine views omit config/env/services and check output; raw snapshots stay in runner temporary storage. ([Filter](../../../../worktrees/s2/scripts/ci/filter-machines.sh), [deploy L157–208](../../../../worktrees/s2/.github/workflows/fly-deploy.yml)) |
| S2-A-07 / S2-B1 | **Direct action-reference finding closed.** Full SHA pins are present and the archived pin-resolution evidence supports intended action versions; this is not a pin on the downloaded Fly CLI, base image, apt packages or runner image. ([Pin log](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/action-pin-verification.log), [Dockerfile](../../../../worktrees/s2/Dockerfile), [documented limit](../../../../worktrees/s2/docs/delivery-controls.md)) |
| S2-A-08 | **Substantively closed.** Repository-local delivery-control doc replaces dangling private proposal references and SBOM test citation is corrected; residual old rule labels are nonblocking. ([Delivery doc](../../../../worktrees/s2/docs/delivery-controls.md), [assertion header](../../../../worktrees/s2/scripts/ci/assert-prod-sbom.sh)) |
| S2-B2 | **Open activation evidence gap, not image-failure finding.** Host replay does not replace final-head Docker/user/release and hosted workflow evidence. ([Manifest](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/MANIFEST.md)) |
| S2-B3 | **Proposal existence/explicit-input fixes accepted; actual trust enforcement open.** Script requires review-count and app-id decisions; no settings application/readback or authorized reviewer route is demonstrated here. ([Script](../../../../worktrees/s2/scripts/setup-branch-protection.sh), [proposal](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/LANDING_PROPOSAL.md)) |
| S2-B5 | **Closed in source.** Every matching job must be completed/success rather than selecting the first match. ([Gate L117–127](../../../../worktrees/s2/scripts/ci/release-evidence-gate.sh)) |
| S2-B8 | **S2 inputs composed, integrated result not cleared.** Dependency-audit job name with comma is parsed using `|`; standalone S2 intentionally cannot release until S3 exists; final preview remains unexecuted. ([Gate L52–58](../../../../worktrees/s2/scripts/ci/release-evidence-gate.sh), [manifest](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/MANIFEST.md)) |
| S2-B9 | **Source changes accepted, runtime proof open.** `USER node` and runtime-stage `SCARF_ANALYTICS=false` are present; TypeScript remains dev-optional, and the build-stage install still has its separate lifecycle behavior. ([Dockerfile L40,84–114](../../../../worktrees/s2/Dockerfile)) |
| S2-B10 | **Not closed.** Five setters are environment-bound, but logs-dump also mutates production and retains no environment; see S2-R2-A-02. ([Workflow](../../../../worktrees/s2/.github/workflows/fly-logs-dump.yml)) |
| S2-B11 | **Scope/sidecar fixes accepted.** Manifest explicitly says npm-only, checks matching sidecar, excludes OS/Node/engine claims; no SBOM-to-image equivalence is established. ([Gate L164–176,204–205](../../../../worktrees/s2/scripts/ci/release-evidence-gate.sh), [scope](../../../../worktrees/s2/docs/delivery-controls.md)) |

R1 observations about PR eligibility of `build-sbom` are resolved by its PR trigger; rulesets-versus-protected-branches semantics, a real review identity and secret-store migration are still hosted prerequisites, not inferred from YAML. ([SBOM trigger](../../../../worktrees/s2/.github/workflows/sbom.yml), [proposal](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/LANDING_PROPOSAL.md))

## 5. Trust, artifact, prerequisite and recovery boundaries

**Trusted enforcement:** exact SHA/run/job filtering, empty-scan rejection, artifact sidecar checks, and environment-presence checks are meaningful local controls; the policy/required-workflow set and workflow logic still live in candidate-controlled source, so binding check names to the Actions app does not by itself prevent a PR from changing that app's workflow/policy to pass itself. The independent review/authorized landing route and actual hosted protection remain G07/G17 prerequisites, especially the S3 candidate-policy issue acknowledged by the cross-lane disposition. ([Gate](../../../../worktrees/s2/scripts/ci/release-evidence-gate.sh), [protection script](../../../../worktrees/s2/scripts/setup-branch-protection.sh), [S3 policy disposition](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/CROSS_LANE_DISPOSITION.md), [G07/G17](../../../../repos/context/AGENT_RULES.md))

**Settings recovery caution:** `setup-branch-protection.sh` is explicitly a destructive full PUT, but its backup step treats *any* failed GET as “no existing protection (or not readable)” and continues with an empty backup; an unreadable baseline is not a recovered baseline, so fail on non-404 failures before authorized use. The private proposal also predates the final dependency-audit requirement and still uses the old post-deploy artifact name; derive the final payload/run instructions from the final audited composition instead of executing that old template verbatim. ([Script L189–211](../../../../worktrees/s2/scripts/setup-branch-protection.sh), [proposal](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/LANDING_PROPOSAL.md), [current requirements](../../../../worktrees/s2/scripts/setup-branch-protection.sh))

**Artifact binding:** the post-deploy verifier checks serving-group started machines, expected tag/SHA label, digest syntax and one converged digest; it does not compare against an independently captured build digest, verify `GH_REPO`/registry, inspect content, or require passing health checks. P11 demonstrates the scope; the separate curl readiness step must not be confused with per-machine check validation, and docs §3's “and passing checks” and verifier header's “built … by this workflow run” exceed the function's own evidence. ([Verifier L12–16,36–55](../../../../worktrees/s2/scripts/ci/verify-fly-release.sh), [P11](p11-image-label-only.log), [docs §3–4](../../../../worktrees/s2/docs/delivery-controls.md), [readiness step](../../../../worktrees/s2/.github/workflows/fly-deploy.yml))

**Migration boundary:** the delta is a source comparison against running-image `GH_SHA`, not the database ledger/catalog; unknown baseline plus an acknowledgement deliberately proceeds, and `release.sh` applies all pending migrations before verifier execution. Therefore no acknowledgement may be promoted into proof of production history, backup/restore readiness, serving-role suitability, or safe E→T/Q0→B/drain→R→N/Q1→C staging. ([Delta](../../../../worktrees/s2/scripts/ci/migration-delta.sh), [release](../../../../worktrees/s2/scripts/release.sh), [G2 plan](../../../../repos/context/handoffs/op81/CONTINUATION_AND_ROMAN_IMPORT_PLAN.md))

**S5 cross-lane directions read and retained as future prerequisites, not implementation:**

- Successful E reversed out-of-band needs proven-idempotent transactional forward repair plus catalog truth; `resolve --rolled-back` is not the remedy for a successful migration, and S1's proof cannot be silently applied to E. ([S5/S1 item 1](../../../../repos/evidence/2026-09-20/remediation/s5-r2/cross-lane/S5_CROSS_LANE_DISPOSITION.md))
- PG17.6 synthetic proof is not a PG15 execution claim; current CI services still use PG15, and the proposed “compatibility floor” wording/version handling has not been implemented here. ([CI L217,319](../../../../worktrees/s2/.github/workflows/ci.yml), [item 2](../../../../repos/evidence/2026-09-20/remediation/s5-r2/cross-lane/S5_CROSS_LANE_DISPOSITION.md))
- O's accounting figures are ledger-wide, not this-run reconstruction counts; this does not require an S2 schema change or certify product completion. ([Item 3](../../../../repos/evidence/2026-09-20/remediation/s5-r2/cross-lane/S5_CROSS_LANE_DISPOSITION.md))
- Draining is an application-process boundary, not a migration lock-timeout guarantee; worker stop/observed inactivity/migration/restart ordering is unimplemented in this release workflow and must exist before relevant B/drain/recovery use. ([Item 4](../../../../repos/evidence/2026-09-20/remediation/s5-r2/cross-lane/S5_CROSS_LANE_DISPOSITION.md), [workflow](../../../../worktrees/s2/.github/workflows/fly-deploy.yml))

S1 remains sole schema/migration/generator owner; S2's verifier wiring neither authorizes live database changes nor closes S1 applicability, and S3 readiness/recovery and S5 later phases remain independent dependencies. ([R2 mandate](../../../R2_AUDIT_BRIEF.md), [cross-lane dispositions](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/CROSS_LANE_DISPOSITION.md))

## 6. Final bounded verdict and smallest follow-up

**No cumulative T4 merge attestation at `0b05fcf5…`: S2-R2-A-01 is a concrete credential-boundary source defect, not a missing hosted test.** Fix the three input-to-shell paths and the verifier discovery defect, resolve the logs-dump privilege classification, then obtain risk-scoped independent final-head follow-up; this does not require reopening unrelated product work. ([P06/P07](probe-summary.txt), [discovery failure](p10-verifier-discovery-failure.log))

**No activation or integrated release clearance:** inherited S2-B2/B3/B7/B8/B10 and the recovery concerns remain open at their stated boundaries, even if source fixes are landed separately; the hosted/image gaps and unexecuted combined preview are not evidence of an actual failed build/deployment or fabricated merge defects. ([Prior-disposition evidence](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/REPORT.md), [manifest](../../../../repos/evidence/2026-09-20/remediation/s2-r2/revision-3/MANIFEST.md))

Smallest parent actions:

1. Route S2-R2-A-01/02/03 to S2 for narrow remediation and offline negative tests; route S2-R2-A-05 to S2/S1 recovery-document owners.
2. Reconcile the actual protected identity-compatible landing payload, outside-candidate trust, token scope and mutation-route inventory before using hosted settings; no hosted action is authorized by this audit.
3. Once source/composition is final, serialize only the missing meaningful executions: final image build/run as `node`, integrated `release.sh` success/drift/failure against representative PostgreSQL, and exact-head composed CI; do not substitute the 394 pre-S1 preview result.
4. Obtain authorized actual GitHub/Fly execution and readback, build/digest/inventory evidence, per-machine readiness, and containment/recovery proof before production activation.

No unexplained command/test failure occurred in this audit; intentional rejections and unexpected acceptances are listed with reproducible evidence, and no heavy-test slot was requested or held. ([Probe summary](probe-summary.txt), [static checks](static-checks.txt))

**Written/reviewed only. Not merged, deployed, enabled, customer-accepted or production-proven by this audit. Parent is sole publisher.**
