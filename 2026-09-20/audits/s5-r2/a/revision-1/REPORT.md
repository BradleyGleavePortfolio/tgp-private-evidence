# S5 R2 audit A — bounded E→T/Q0 compatibility evidence

**Date:** 2026-09-20 UTC. **Consequence:** T4. **Disposition: ACCEPT the exact-head synthetic validation evidence, with the limits below; NOT CLEARED for cumulative G2 product promotion or release.** The repaired validation lane has attributable successful execution, but migration-specific operational recovery, actual runtime-role applicability, and affected writer-fencing gates remain open; directions in a disposition document do not close them. [Exact-head evidence][env] [Live results][live] [Cross-lane directions][cross] [Audit mandate][brief]

This is one independent attestation, not a two-reviewer clearance. I did not implement the candidate, read the other current R2 report, coordinate conclusions with another auditor, edit source, install dependencies, connect to a database, run tests, create a cluster, or publish anything. I inspected both prior R1 reports as required. The only outputs of this audit are this report and `VERIFICATION.txt`.

**Reviewer identity:** independent R2 auditor A. The supplied task/mandate identifies the lane but does not expose a selected-model execution receipt; the earlier R1 reports contain requested model labels, which are not proof of this R2 execution's identity. Actual known identity is an AI assistant accessed via API; provider, model/version and reasoning setting are not exposed to this auditor and are not attested. Tools used: read, bash/git/gh, Python hashing, and file output. [Mandate][brief] [Prior A][r1a] [Prior B][r1b]

## 1. Frozen identity and authoritative proof

I independently checked the candidate, ancestry, six-file delta, commit objects, bundle and packet hashes; these are recorded in the [bounded verification record][verification].

| Item | Verified value |
|---|---|
| Candidate head | `485c67973b56758fb9b8404579f5ddaec87136bd` |
| Candidate tree | `2fbf5028413557f99faea3f1de27b1352a4fe8d4` |
| Product base / merge-base | `d7404cd49578647cf72bb633819d8e86ffc3da3a` |
| O writer / ancestor of product base | `925780e0a1906593e5383c618311b6b17364b8dc` |
| Worktree status | Clean on repeated inspection, including final bounded checks |
| Proof commits | `65b1da27…` → `5270e103…` → `485c6797…`; first tree equals R1's `9bbc0223…` snapshot tree |
| Commit attribution | All three commit objects name Bradley Gleave as author and committer; that is Git metadata, not a claim of who performed each implementation action |
| Product-base delta | Six test/helper files; 1,357 additions, two deletions; no schema, migration, product service, generator, or workflow changes |
| Archived bundle | Verifies successfully; advertises the exact head; prerequisite `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` |
| Bundle SHA-256 | `7b2e2e5ce1d4ebfb547357c799e03a3ad18c205bea58e4c3d70e1c6e49cf9b8d` |
| Packet integrity | All 114 entries in revision-1 `SHA256SUMS` match |

Read-only remote verification found backend main at `c23b9d9f…`, [PR #528](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/528) OPEN at `8644715c429e7dde1dfeb71f7ad42b1bd9121eaf`, based on `agent/orchestrator/backend-repair-r3`, and [PR #529](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/529) OPEN at `d7404cd4…`, based on `agent/builder/g2-e-ledger-platform`; proof preservation is not product integration. [Verification][verification]

**Use run `20260920T185210Z` for the exact-head attestation.** Its environment log records clean HEAD `485c6797…`, tree `2fbf5028…`, Node 20.20.1, npm 10.8.2, and a 4,096 MB Node heap setting; the live connection confirms PostgreSQL server 17.6 (`170006`), while `psql 18.6` is merely the client version. [Environment][env] [Live identity/results][live]

| Component | Exact-head recorded outcome |
|---|---|
| Guard spec | 26/26, 9.136 seconds total Jest time. [Guard log][guardlog] |
| Bootstrap | 164 base migrations, independently generated O/current Prisma 6.19.3 clients, `G2_PG17_BOOTSTRAP_OK`. [Bootstrap log][bootlog] |
| Live ordered spec | 50/50, no skipped tests, 201.356 seconds. [Live log][live] |
| Runner | `PROOF_EXIT=0 STAGE=all TS=20260920T185210Z`. [Exit record][exit] |

The earlier green `184713Z` run was **not** on the clean committed head: its environment records `5270e103…` with three modified files. The builder's report correctly supplies the later committed confirmation, but the dispositions table's “184713Z … HEAD 485c6797” shorthand must not be used as exact-head evidence. This is an attribution-label caveat, not an unexplained final failure. [Earlier environment][earlyenv] [Builder addendum][builder] [Disposition table][dispositions]

This establishes an internally consistent, checksum-preserved historical run with inspectable source and query evidence. It does not establish a cryptographically signed execution environment, a fresh restore/replay by this auditor, production equivalence, or customer acceptance. [Archive inventory][manifest] [Verification][verification]

## 2. Review coverage and actions

Read the complete six-file validation delta and R1→R2 changes: the 850-line live spec, guard spec, DB guard, bootstrap, harness and worker change; inspected the archived runner, install scripts, reports, checkpoints, failed/successful logs, manifest and cross-lane disposition. Product-risk review covered E up/down in full; T reconstruct service, platform/cursor utilities and family registry; relevant O implementation; roster/entity and DTO/OpenAPI diffs; G2 decision documents; relevant Person/ledger/entity RLS migrations; and Jest/CI selection. Governing reads included current operator state, G01–G22, EXECUTE, the current staged plan and this dispatch. [Spec][spec] [Bootstrap][bootstrap] [Harness][harness] [Worker][worker] [E up][up] [E down][down] [T service][service] [Plan][plan] [Rules][rules] [Brief][brief]

Independent lightweight checks were successful: `git diff --check`, shell syntax for bootstrap and runner, Node syntax for the worker, bundle verification and all packet checksums. These are not a TypeScript build or live-test rerun. A read-only attempt to inspect the original `execution/s5-g2/old-root-925780e0` failed because that generated fixture directory is absent in this restored workspace; no reconstruction was attempted. Its deliberate archive exclusion and the recreation defect are addressed in finding R2-A-03. [Verification][verification] [Manifest][manifest]

Not audited as a complete product: pre-O backend changes, every body in the 164-migration chain, Prisma engine internals, all application controllers/authentication, S2 deployment execution, actual hosted schema/data, donor-wide inventory, or B/drain, R, N/Q1 and C implementations. The controlling sequence remains **E → T/Q0 → B/drain → R → N/Q1 → C**, as separately promoted artifacts; this report does not adopt R1 A-08's potentially conflicting suggestion to reorder that sequence. [Plan][plan] [Prior A][r1a] [Brief][brief]

## 3. What the proof supports — and what it does not

### Roles, RLS and fixture safety

The R1 superuser-DDL defect is repaired: synthetic `postgres` is a **non-superuser, BYPASSRLS, owning migration role**; product migration replay and E up/down use it. Workers use a LOGIN-enabled, non-superuser BYPASSRLS `service_role`. The superuser still performs fixture provisioning, auth shim/default grants/extensions and privileged diagnostics—not just database/role creation—so avoid the narrower claim that it was used “only” for creating roles/databases. This does not negate the observed non-superuser product DDL. [Bootstrap][bootstrap] [DB helpers][db] [Harness][harness] [Live identity][live]

The guard requires an explicit disposable loopback S5 target and confirmation, rejects known other-lane/common ports, embedded passwords and unexpected URL options, and validates server/data-directory identity; these controls limit accidental targeting but are not a production execution authorization. [Guard][db] [Guard spec][guardspec] [Guard results][guardlog]

The spec exercises forced-RLS denial after granting API roles privileges, so denial is not merely a missing-GRANT artifact; it tests select/update/delete on all four touched tables, explicit insertion denial on ledger/staging, and hostile-claim reads. It also tests that a non-BYPASSRLS owning role cannot remove provenance hidden by FORCE RLS, both populated and empty cases. A BYPASSRLS backend worker's positive tenant-scoping cases test service predicates, not database tenant isolation between backend callers. [Spec, stage 1][spec] [Bootstrap][bootstrap]

**Actual deployed app credentials/role remain unknown.** S1's runtime-role packet explicitly has not been executed against the serving application; Supabase administration metadata or a synthetic role named `service_role` cannot replace that measurement. Existing hosted drift and the two historically reported rolled-back migration names are not reproduced by this clean 164-migration fixture. Close synthetic role fidelity only; keep actual release applicability open. [Runtime-role packet][rolepacket] [Prior A, A-03/A-06][r1a] [Bootstrap][bootstrap]

### Populated preservation, accounting and O/T behavior

The fixture is not an empty-table happy path: it seeds 600 legacy ledger rows across four coaches, two intents and three families; O then processes 600 staged clients, yielding 588 Persons and 1,200 total ledger rows before E. E preserves ledger data apart from the new NULL column and preserves the catalog/OIDs/keys/RLS/policies under test; O subsequently adds 30 workouts, leaving 1,230 populated rows through the tested down/up and real Prisma-recorded E transition. These are synthetic records, including legacy references without actual target Persons—not a faithful production dataset. [Spec, stages 1–2][spec] [Live results][live]

The O response `staged=600, reconstructed=596, skipped=8, failed=21` is **whole coach/intent/family ledger totals**, including 25 prior rows; it is not “596 successes in this run.” The spec separately checks 588 new successes and 12 new failures. The T volume case uses 1,050 staged rows with 300 overlapping legacy rows, produces 1,040 targets and ten failures, claims 1,050 rows, and verifies replay without multiplying targets/ledger rows. This closes accounting-observation gaps, not the misleading service comment or a per-run accounting contract. [Spec lines 98–175, 298–315][spec] [T tally][service]

O and T run real service code with separately generated old/new clients in isolated processes, rather than swapping a mock schema flag. Bootstrap pins O's Git revision and relevant clean paths; the spec checks old service bytes and old/new schema shape. The harness injects test mapper failures and constraints, however, and invokes services directly: logged “500” behavior is the worker's error representation, not an HTTP/router/auth acceptance test. [Bootstrap][bootstrap] [Worker][worker] [Harness][harness] [Spec][spec]

T tests include exact-identity NULL/equal claims, all outcome paths, tenant/intent/family boundaries, late mismatch rollback for both new and pre-existing targets, and a mid-batch contradiction that preserves earlier committed rows without inventing a final tally. O-after-T remains intentionally unsafe for T-only precedence: O can downgrade success to failed/skipped and clear the ledger target reference while preserving provenance; O rollback can resume NULL creation. The tests **characterize**, rather than fix or authorize, these mixed-fleet effects. O replay also changes `Person.updated_at`; the comparison excludes that timestamp explicitly, so full byte-identical replay is not proved. [Spec, stages 1/3/3b][spec] [T service][service]

The retained staging key excludes family/platform and the ledger key excludes platform; corrected collision tests use distinct IDs and inspect the product constraint rather than accidentally tripping the helper primary key. Q0's tested narrow-schema pagination, scope/token rejection and legacy emission are meaningful; a deliberately widened temporary fixture demonstrates tied-row loss after v2→legacy chaining, not future-wide correctness. The temporary fixture does not implement R or Q1. [Spec, stages 3–4][spec] [T/Q0 decision][tdoc]

### Races, retries and recovery

Most concurrency tests use worker IPC barriers and observed PostgreSQL lock waits rather than uncontrolled sleeps; query evidence tests a real P2002 contention rollback and bounded full-transaction retry. SQLSTATE 40001 is raised by test SQL triggers: this exercises real PostgreSQL/Prisma retry plumbing but does not prove all naturally occurring serializable-isolation conflicts. Fixed windows and the observed 1,050-row runtime are workload observations, not capacity/SLA guarantees. [Harness][harness] [Spec, stage 3b][spec] [Live log][live]

The corrected lock-budget test holds a real service-role transaction using a controllable SQL session and obtains lock-timeout refusals for both up and down without mutation. The test asserts **combined** elapsed time of 5–30 seconds, observed about 11.3 seconds, not an independently measured 5–30-second assertion for each direction; each SQL file separately sets a five-second lock timeout. [Spec lines 794–816][spec] [E up][up] [E down][down] [Live log][live]

The separate actual-T-claim characterization observed `down-applied` and a worker failure `500/P2022` in both green runs: Prisma's interactive transaction expired while E down was waiting. Do not turn this observation into universal timeout ordering or a fencing mechanism. The branch is intentionally not fixed by assertion, and final worker/target invariants are insufficiently asserted in this one case (R2-A-02). [Spec lines 819–848][spec] [Exact-head log][live] [Cross-lane cautions][cautions]

Recovery evidence properly rejects the **incorrect prior R1 remediation recommendation**: successful E followed by out-of-band down leaves history at 165, ordinary `migrate deploy` falsely reports no pending migrations, and `resolve --rolled-back E` refuses with P3012. Raw forward E applied once to the now-absent-column catalog restores T function and three targets without history surgery. This is not repeated/idempotent forward repair, and the spec's `UPDATE ... source_platform=NULL` is artificial fixture preparation—not an implemented writer drain or authorization to erase recorded provenance. Stopping workers does not remove committed claims; the ordinary reversible alternative remains O code with E retained, carrying O's known limitations. [Spec lines 744–791][spec] [E decision][edoc] [Live recovery log][live]

## 4. Failed-run/root-cause review

I compared the failure summaries and changes with the final implementation rather than discarding non-green runs. The chronology below is supported by the retained logs and checkpoint/disposition record; the final committed run has no unexplained failing or skipped test. [Failure inventory][manifest] [Builder report][builder] [Final log][live]

| Run | Outcome and assessment |
|---|---|
| R1 original | Guard passes; missing `postgres` prevents bootstrap; fail-open runner continues into ~2 GB heap exhaustion, exit 137, no live assertions. Fixed role setup, stage gating and 4 GB configuration address different causes. [Prior A][r1a] [Prior B][r1b] |
| `181433Z` | Bootstrap refuses boolean text mismatch (`f:t:t` versus `false:true:true`); runner stops without live execution. [Bootstrap log][fail181433] |
| `181540Z` | Nonsuperuser extension creation fails with P3018; extensions moved to fixture superuser provisioning, not product migration execution promoted to superuser. [Bootstrap log][fail181540] [Bootstrap source][bootstrap] |
| `181632Z` | 49 failures from `data_directory` metadata permission in setup; privileged diagnostics separated from migration SQL. [Live log][fail181632] [Harness][harness] |
| `181914Z` | 49 failures from boolean-display expectation in setup, not 49 independent product regressions. [Live log][fail181914] |
| `182017Z` | 12 fail / 37 pass: worker exit without complete IPC result; tally expectation incorrectly excluded historical ledger rows; temporary owner lacks CREATE then leaks setup state; downstream E/history cascades; quoting/order expectations; real Prisma-versus-DDL timeout interaction. [Live log][fail182017] [Checkpoint][checkpoint] |
| `182819Z` | 10 fail / 39 pass: parent-only channel synchronization insufficient; child send/exit lifecycle still loses results; temporary-role cleanup dependency remains; timeout assumption persists. Final worker waits for send completion and disconnects, while parent coordinates receipt/channel closure/exit. [Live log][fail182819] [Worker][worker] [Harness][harness] |
| `183610Z` | 3 fail / 47 pass: O replay updates timestamps; quiet psql omits expected SET tags in two variants. Comparisons corrected without discarding target IDs, ordering, cursors or other fields. [Live log][fail183610] [Spec][spec] |
| `184148Z` | 1 fail / 49 pass: two claimed rows expected for the two staged inputs, not one. [Live log][fail184148] [Spec][spec] |
| `184713Z`, then `185210Z` | 50/50 before commit, then guard/bootstrap/50 live assertions succeed on clean committed head. Only the latter is the exact-head attestation. [Earlier environment][earlyenv] [Final environment][env] [Final results][live] |

The earlier timeout failure must **not** be dismissed using R1 A-11's blanket “infrastructure” characterization: it exposed a real client timeout/recovery interaction and led to a separate deterministic lock-holder test plus a bounded actual-client characterization. No product timeout was relaxed to hide it. [Prior A][r1a] [Spec stage 5][spec] [Builder observations][builder]

## 5. Explicit prior-finding dispositions

“Closed” below means closed for the stated synthetic S5 validation scope, not production clearance. Stable IDs are those in the two original reports. [R1 A][r1a] [R1 B][r1b]

| Prior ID | R2 A disposition and consequence |
|---|---|
| **S5-A-01** | **CLOSED, bounded:** attributable clean-head live proof now exists, 50/50. Not hosted proof. [Environment][env] [Results][live] |
| **S5-A-02** | **CLOSED:** bootstrap explicitly creates/verifies nonsuperuser `postgres`; base replay completes. [Bootstrap][bootstrap] [Run][bootlog] |
| **S5-A-03** | **Synthetic defect CLOSED; production applicability OPEN:** E/migrations run nonsuperuser; deployed app connection and exact target owners remain unverified. Blocks claiming representative live release mechanism, not accepting this synthetic result. [Harness][harness] [Runtime-role packet][rolepacket] |
| **S5-A-04** | **CLOSED:** effective 4 GB heap and full completion recorded. No performance guarantee inferred. [Environment][env] [Results][live] |
| **S5-A-05** | **Proof gap CLOSED; material E recovery-packet gap OPEN:** clean-history P3012 is measured; the prior auditor's proposed resolve step is rejected, not implemented. An E-specific recovery packet remains required (R2-A-01). [Stage 5][spec] [Directions][cross] |
| **S5-A-06** | **PARTIALLY CLOSED:** wrong-index/search-path/non-bypass-owner/populated-provenance negatives now execute. Live drift and two rolled-back names are not modeled; reconcile before affected migration release. [Stage 1][spec] [Prior finding][r1a] |
| **S5-A-07** | **OPEN, truth-labeling:** in-tree PG15 wording/CI scope not repaired by this test-only delta. Manual PG17 evidence is not current CI enforcement or proof of a PG15 compatibility floor. Correct release documentation before promotion. [E doc][edoc] [T doc][tdoc] [CI][ci] [Cautions][cautions] |
| **S5-A-08** | **Characterization CLOSED; affected fleet/fencing packet OPEN:** O downgrade and NULL resumption are confirmed. Parent must define and prove when precedence/backfill invariants can be relied on without changing the established stage order by implication. [Stages 3/3b][spec] [Plan][plan] [Cautions][cautions] |
| **S5-A-09** | **OPEN, service/documentation:** ledger-scope semantics confirmed; invariant/per-run wording remains misleading. No S5 schema change warranted. [T service][service] [Populated case][spec] |
| **S5-A-10** | **Local test-quality concerns substantially CLOSED:** distinct-ID/named-key collision assertions and explicit guarded reset path now exist; invalid staging fails before writes. The fixture remains S5-specific (including port identity), not a portable arbitrary-port tool. [Spec][spec] [Runner][runner] |
| **S5-A-11** | **Execution concern satisfied for this run, not universally closed:** measured volume and lock coordination pass in the serialized fixture; distinguish real timeout behavior from resource contention. [Results][live] [Stage 5][spec] |
| **S5-A-12** | **CARRY, parent integration dependency:** inherited contract 1.4.1 collision/order is not resolved by six test files; S5 neither owns nor attests C1/#526 contract integration. [Prior finding][r1a] [Delta verification][verification] |
| **S5-B-01** | **CLOSED:** role/bootstrap and missing live execution remedied on exact head. [Bootstrap][bootlog] [Results][live] |
| **S5-B-02** | **CLOSED:** runner gates stages and records effective heap; retained bootstrap failures demonstrate no subsequent live run in the same failed chain. [Runner][runner] [Failure bootstrap][fail181433] [Environment][env] |
| **S5-B-03** | **Synthetic DDL defect CLOSED; live-role boundary OPEN:** same bounded disposition as A-03; deliberately synthetic API grants/test constraints are not hidden production equivalence. [Bootstrap][bootstrap] [Spec][spec] [Role packet][rolepacket] |
| **S5-B-04** | **Proof gap CLOSED; material recovery packet OPEN:** same A-05; prior resolve recommendation contradicted by measurement. [Stage 5][spec] [Directions][cross] |
| **S5-B-05** | **OPEN:** same PG/version/CI truth boundary as A-07. Earlier local PG18 or PG15 statements are not interchangeable with this PG17.6 result. [Docs][edoc] [CI][ci] [Environment][env] |
| **S5-B-06** | **CLOSED for measured assumptions:** actual P2002 retry/query counts, fixture FK resets, old-client generation, observed waits and volume execute successfully. Not exhaustive concurrency or production load proof. [Bootstrap][bootlog] [Results][live] [Harness][harness] |
| **S5-B-07** | **CONFIRMED/CARRY:** narrow collisions, legacy emission/future tie loss, O downgrade, NULL resumption and ledger-total semantics remain explicit stage limits; later boundaries require separate proof. [Spec][spec] [Plan][plan] |

## 6. New R2 findings and exact affected boundaries

### S5-R2-A-01 — Generic cross-lane recovery direction is not valid verbatim for E

**Type:** recovery-guidance defect refining inherited A-05/B-04. **Material for E's operational recovery/release packet; not a defect invalidating the observed one-time synthetic repair. Owner: S1 via parent.**

The disposition directs copying an “idempotent forward file” rule and treats E's idempotence proof as already recorded, while E explicitly says raw reruns must fail and rejects an existing column; the spec asserts that rejection. The parent caution does not itself supply the missing migration-specific procedure. E's successful once-only restore after complete removal is therefore not the proposed idempotent replay guarantee. Blind retry after uncertain completion would fail, and treating a generic rule as implemented recovery leaves the operator without a truthful state-dependent action. [Cross-lane item 1][cross] [Parent caution][cautions] [E up][up] [Spec lines 141–154, 783–791][spec]

**Minimal closure:** write an E-specific packet distinguishing successful out-of-band reversal from a failed migration attempt; inspect actual catalog/history first; repair only the verified absent-column state with E's guarded transactional forward file; verify exact column, identities, policy/data invariants and application recovery afterward; on uncertain completion inspect rather than blindly replay; never edit history or erase provenance to manufacture rollback eligibility. This does not require making E idempotent or changing S1-owned SQL merely to match generic prose.

### S5-R2-A-02 — Actual-T/down characterization logs the terminal result but does not assert it

**Type:** nonblocking regression-test weakness for the bounded observed characterization; material if reused as complete automated proof of terminal fail-closed behavior/no partial targets. Owner: S5 test owner, dispatched by parent.**

At spec lines 842–844 `paused.done` is awaited and its result/failure logged, but neither is asserted; no post-completion target snapshot is compared. In the down-applied branch the empty-ledger assertion occurs **before** releasing/awaiting the worker. The observed final log contains 500/P2022, and other transaction tests provide substantial rollback evidence, but this one test could remain green after a terminal-result/partial-target regression. Do not repeat the builder's unqualified “invariants asserted” wording as covering those missing checks. [Spec lines 819–848][spec] [Builder observation 3][builder] [Actual log][live]

**Minimal closure:** snapshot relevant targets/ledger before starting the paused worker; after `done`, assert branch-specific allowed failure/result/event behavior and final ledger/target atomicity before forward repair. Retain either legal timeout ordering; do not assert that Prisma must always win. No source change or run performed by this auditor.

### S5-R2-A-03 — Archive-only O recreation recipe cannot satisfy bootstrap's Git identity gate

**Type:** nonblocking evidence-reproduction instruction defect; blocks claiming the current recipe is a successfully tested restore. Owner: packet owner via parent.**

The manifest proposes `git archive ... | tar ...` for `old-root`, but bootstrap lines 101–103 require `git -C "$G2_PG17_OLD_ROOT" rev-parse HEAD` to equal O and a clean relevant-path Git diff. A plain extracted archive is not that repository; it either has no Git metadata or resolves an unrelated ancestor checkout. The old fixture was intentionally excluded and recreation explicitly unexecuted, so this does not discredit the recorded historical run, but a future operator cannot follow the recipe literally through the current guard. [Manifest recreation][manifest] [Bootstrap identity gate][bootstrap]

**Minimal closure:** amend the recipe to a disposable detached clone/checkout at full O SHA (without modifying shared refs), then preflight `rev-parse HEAD`, relevant clean diff, identical package/lock content and absence of E before provisioning. Keep generated clients/dependencies separate and preserve exclusions for secrets/binaries. This correction can first be verified without a database or dependency install.

## 7. Cross-lane directions still unimplemented

None of the cross-lane response's proposed recovery, CI/docs, accounting or stop/start changes is implemented by that document; it explicitly says S1 source remained unchanged and E is not in S1's frozen tree. Its useful constraint statements must not be counted as finding closures or evidence inherited from S1. [Cross-lane disposition][cross] [Parent caution][cautions]

- **Accounting:** `source_platform` is a platform token, not a run ID; a suggested `WHERE provenance=<run>` filter is not a valid implementation of per-run accounting on this schema. Keep ledger-total labels truthful; any run-level contract requires a separate service design, not a schema change improvised by S5. [E schema change][up] [T service][service] [Cross-lane item 3][cross] [Parent caution][cautions]
- **Fencing:** “stop T + no active app-role sessions” is insufficient on its own: old writers, restarts/new arrivals, idle-in-transaction sessions and relevant locks remain material. No S2 process-control execution is in this proof. Also, an empty process list does not make existing non-NULL provenance disappear. [Cross-lane item 4][cross] [Parent caution][cautions] [E down][down]
- **Version truth:** no verified policy decision turns PG15 CI into a compatibility floor, and no historical runbook scenario becomes PG17-remeasured merely because these S1/S5 suites ran there. Correct precise scope rather than replacing version strings indiscriminately. [Parent caution][cautions] [CI][ci]
- **Contract integration:** parent retains C1 ordering/generator serialization; this test-only audit cannot resolve a sibling contract version collision. [Prior A-12][r1a] [Brief][brief]

## 8. Minimal follow-up and final decision

**No immediate additional database execution is necessary to accept the existing exact-head 26/50 synthetic evidence.** Repeating the entire suite independently would not answer the outstanding production-role, recovery-packet or process-fencing questions; G10 permits review of the attributable automated bundle. [Rules][rules] [Environment][env] [Results][live]

Smallest next actions, routed through parent:

1. **Before E promotion:** S1 produces/reviews the E-specific recovery packet in R2-A-01, including preservation of committed provenance and the supported retained-column rollback. Correct the unsupported idempotence direction, not the migration merely to fit it.
2. **Before relying on mixed-fleet/later-stage guarantees:** parent/S2 identify and exercise the actual stop/fence/restart boundary, including obsolete/newly arriving and idle-transaction writers; preserve established stage sequencing. This is a future boundary test, not a request to run all G2 now.
3. **Before claiming hosted applicability:** authorized owner supplies the metadata-only actual application-connection probe, touched-table owners and relevant failed/rolled-back migration identities; reconcile them against this fixture, then run only the resulting representative gaps. Do not fetch customer rows or secrets for this audit.
4. **Immediately, without DB work if desired:** packet owner corrects R2-A-03 and verifies the detached O Git preflight; service/docs owners correct ledger-total and PG-version labels. No changed source or green runtime is implied by those edits.
5. **When parent authorizes test improvement:** add R2-A-02's terminal assertions and run the smallest correctly initialized ordered proof. This spec depends on earlier stages recording E; invoking only its final named case against an arbitrary fresh database is not a valid shortcut. If the existing runner remains the fixture owner, one serialized guard→bootstrap→live replay on the new exact head is sufficient; preserve outputs. Do not run it now solely to repeat unchanged evidence. [Spec stage dependencies][spec] [Runner][runner]

**Final bounded verdict:** the six-file S5 validation delta and preserved committed-head run are credible initial **E→T/Q0 synthetic compatibility evidence**. No new material blocker to preserving or reviewing that validation evidence was found. **Overall cumulative G2 product clearance remains NOT CLEARED**, with inherited material recovery/fencing/live-applicability gates still open and new guidance/reproduction/test-quality qualifications above. Offline preservation of test evidence is distinct from landing the inherited product stack; any merge that auto-deploys is a release boundary and is not authorized by this report. Later B/drain, R, N/Q1, C; deployed/enabled behavior; customer acceptance; and production proof remain unproven here. [Brief][brief] [Rules][rules] [Plan][plan] [Directions][cross] [Results][live]

[verification]: VERIFICATION.txt
[brief]: ../../../R2_AUDIT_BRIEF.md
[rules]: ../../../../repos/context/AGENT_RULES.md
[plan]: ../../../../repos/context/handoffs/op81/CONTINUATION_AND_ROMAN_IMPORT_PLAN.md
[r1a]: ../../../../repos/evidence/2026-09-20/audits/s5-r1/a/revision-1/REPORT.md
[r1b]: ../../../../repos/evidence/2026-09-20/audits/s5-r1/b/revision-1/REPORT.md
[spec]: ../../../../worktrees/s5/test/rls-g2-pg17-etq0.spec.ts
[bootstrap]: ../../../../worktrees/s5/test/utils/g2-pg17-bootstrap.sh
[db]: ../../../../worktrees/s5/test/utils/g2-pg17-db.ts
[guardspec]: ../../../../worktrees/s5/test/scout/g2-pg17-db-guard.spec.ts
[harness]: ../../../../worktrees/s5/test/utils/g2-pg17-harness.ts
[worker]: ../../../../worktrees/s5/test/utils/g2-tq0-worker.cjs
[up]: ../../../../worktrees/s5/prisma/migrations/20270118000000_scout_ledger_platform_expand/migration.sql
[down]: ../../../../worktrees/s5/prisma/migrations/20270118000000_scout_ledger_platform_expand/down.sql
[service]: ../../../../worktrees/s5/src/scout/scout-reconstruct.service.ts
[edoc]: ../../../../worktrees/s5/docs/decisions/2026-09-18-g2-ledger-platform-expand.md
[tdoc]: ../../../../worktrees/s5/docs/decisions/2026-09-18-g2-transition-writer-cursors.md
[ci]: ../../../../worktrees/s5/.github/workflows/ci.yml
[rolepacket]: ../../../../repos/evidence/2026-09-20/remediation/s1-r2/revision-1/RUNTIME_ROLE_VERIFICATION_PACKET.md
[cross]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/cross-lane/S5_CROSS_LANE_DISPOSITION.md
[cautions]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/cross-lane/README.md
[builder]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/REPORT.md
[dispositions]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/FINDING_DISPOSITIONS.md
[manifest]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/PUBLICATION_MANIFEST.md
[checkpoint]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/CHECKPOINT-resume-1057.md
[runner]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/run-proof.sh
[env]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/logs/env-all-20260920T185210Z.log
[earlyenv]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/logs/env-all-20260920T184713Z.log
[guardlog]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/logs/guard-unit-20260920T185210Z.log
[bootlog]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/logs/bootstrap-20260920T185210Z.log
[live]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/logs/live-etq0-20260920T185210Z.log
[exit]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/logs/exit-all-20260920T185210Z.log
[fail181433]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/logs/bootstrap-20260920T181433Z.log
[fail181540]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/logs/bootstrap-20260920T181540Z.log
[fail181632]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/logs/live-etq0-20260920T181632Z.log
[fail181914]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/logs/live-etq0-20260920T181914Z.log
[fail182017]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/logs/live-etq0-20260920T182017Z.log
[fail182819]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/logs/live-etq0-20260920T182819Z.log
[fail183610]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/logs/live-etq0-20260920T183610Z.log
[fail184148]: ../../../../repos/evidence/2026-09-20/remediation/s5-r2/revision-1/logs/live-etq0-20260920T184148Z.log
