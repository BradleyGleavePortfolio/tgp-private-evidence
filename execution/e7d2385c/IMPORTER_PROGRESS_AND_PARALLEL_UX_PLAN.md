# Importer Progress and Parallel UX Plan

The project is **safely paused at the owner's request**. All eight session workers are finished or checkpointed, and no task-owned validation process or runtime lock remained at the final check.

S1–S12 remain the data/system mission, with UX-01–UX-08 as the parallel customer-experience lane. The next operator resumes C1 from its preserved source/review checkpoint, not from a new implementation cycle; the detailed instructions are in `OPERATOR_PAUSE_AND_RESUME.md`.

## Done

| Work | What is complete | Boundary |
|---|---|---|
| S1–S4 | Previously accepted foundation, integration and technical proof | Their existing acceptance is retained; no duplicate proof runs |
| S5 | Exact backend candidate passed the fresh PostgreSQL 17.6 suite: 51/51, normal proof exit, successful stop and two independent final attestations | This proves the S5 boundary, not the whole importer |
| S6 | Identity-bound mobile cache and sign-out ordering accepted on the exact committed candidate, with both final attestations | Recorded receipt qualifications remain; this is not whole-importer acceptance |
| S7 foundation composition | Accepted S3 and S5 work combined into one exact local commit; formatting, lint, typecheck and commit-message checks passed, with both final attestations | This closes the foundation composition only, not all of S7 |
| UX inventory | Existing mobile work has been mapped into the new UX outcomes | Inventory is not new implementation or usability acceptance |
| UX planning package | Official job/PR map, dependency map, mobile journey specification, state/edge-case matrix and contract questions delivered | This completes the initial planning package, not the UX jobs' implementation |

The failed first S5 attempt and failed S6 P3 receipts remain recorded as failures. Later corrected evidence does not overwrite them.

## In progress, now paused

| Work | Preserved stopping point | What comes next after authorization |
|---|---|---|
| S7 C1 integration | Exact 18-path candidate is frozen, both independent source reviews are complete and grantable, and the intentional uncommitted merge is retained | Finish only outstanding execution-binding review, then authorize the existing ordinary-hook commit and targeted validation |
| C1 validation binding | Launcher and approved commit message are frozen; hooks, commit and targeted tests have never run | A fresh explicit grant is required; existing source reviews are not restarted |
| C1 real-database proof | Requirements for the existing 22-case proof are documented; the minimum fixture variant is not built | Build and review that bounded prerequisite, then later run the C1-only proof once |

S7's first hook refusal remains recorded; its later corrected commit passed without bypassing hooks. Accepted S3/S5 evidence transfers at its existing boundaries, rather than being repeated.

S6 passed typecheck, identity19/19, navigation4/4, persistence5/5, sign-out4/4 and regression25/25, plus the expected hazard-control outcome. Its strict log/count postcheck failures remain recorded with both reviewers' narrow qualifications, including the one-second exit warning followed by normal self-exit; they were not rewritten as clean passes.

## Planned, but not started as new implementation

| System work | Remaining outcome |
|---|---|
| Remaining S7 work after C1 | Missing backfill/drain and subsequent lifecycle stages |
| S8 | Native destination writers |
| S9 | Relationships and reconciliation |
| S10 | Unseen-source induction with no source-specific core changes |
| S11 | Complete customer journey and multi-host integration |
| S12 | Real acceptance and pilot proof |

The new UX lane is planning-only at this point. No new UX implementation PR, customer-facing prototype or usability session is claimed; existing mobile PRs remain reuse inputs rather than work to recreate.

## Official UX jobs and PR naming

| Job | Official name |
|---|---|
| UX-01 | Importer Journey & State Architecture |
| UX-02 | Roman Import Entry & Discovery |
| UX-03 | Desktop Handoff & Pairing Experience |
| UX-04 | Import Start, Progress & Stop Experience |
| UX-05 | Failure, Partial & Recovery Experience |
| UX-06 | Imported Results & Native Deep Links |
| UX-07 | Importer Design System & Accessibility |
| UX-08 | End-to-End Journey Usability Proof |

Proposed PR titles use the outcome directly, for example `UX-03: Desktop handoff and pairing experience`. A mobile or extension suffix can distinguish repositories; actual GitHub PR numbers are assigned only when a PR is opened.

## Reuse before building

- **Existing mobile foundation:** Dependency guards, flags, durable pairing and readable/copyable pairing codes from [PR #289](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/289), [PR #290](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/290), [PR #291](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/291) and [PR #292](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/292) are already in the S6 baseline lineage.
- **Presentation inputs:** The Roman views in [PR #293](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/293) and controlled status views in [PR #294](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/294) should be compared with the accepted S6 successor before adoption, rather than recreated.
- **Acceptance distinction:** Existing code, source review, runtime proof and unfamiliar-user usability results remain separate statuses. The 9/10 usability target is a target, not an observed result.

## Future parallelism, not active assignments

All assignments are currently stopped. After a fresh grant, independent planning can accompany one exclusive heavy-validation lane, with one writer for each overlapping product surface.

- **Eligible after resumption:** Outstanding UX-07 design-system/accessibility planning, handoff/readiness states, recovery copy, results questions and usability scenarios. Do not repeat the delivered journey specification.
- **Wait for real contracts:** Functional Start, Stop, progress, recovery and result bindings must consume defined server states and native destinations. Mock presentation must not imply backend behavior already exists.
- **Serialize shared files:** One mobile status/result writer and one extension presentation writer avoid conflicting edits within each repository.
- **Converge later:** UX-07 can begin alongside UX-01. UX-08's actual journey proof converges with S11/S12 rather than declaring the whole product complete early.

## Handoff protection

The saved checkpoint identifies completed steps, unfinished review parts, exact hashes, the next action and work that must not be repeated. A portable bundle plus the frozen patch preserves the uncommitted C1 candidate even if a later operator needs a fresh sandbox; restoring missing tooling is distinct from repeating accepted proof.

All prior continuation grants are revoked by the pause. Product publication, production enablement and real customer/source-account actions remain outside the authorization, and no new work should start until explicitly resumed.
