# S5 R3 independent audit A

**Disposition: NOT CLEARED for cumulative S5 validation-harness acceptance/merge at this head. Accept the attributable, bounded B3 observations; do not discard the 27/51 result.** A refusal can still execute destructive teardown, and the frozen lifecycle wrapper does not preserve its advertised cleanup/lock guarantees on abnormal termination. These are validation-surface defects, not a finding that the measured E/T assertions failed. The destroy path has a separate suppressed-failure defect. [Finding evidence](EVIDENCE_EXCERPTS.txt)

**Reviewed source:** `143d451ead6ccdbebd92ca3031ba7a89867d6cfc`, tree `d0e122d35022377196908b7d132fc34c1af2fc6b`; clean at audit checks. This is independent audit A, not implementation, builder certification, a parent disposition, or a release approval. [Independent verification](STATIC_VERIFICATION.txt)

## 1. Authority, identity, and review boundaries

I read the mandate and all four governing reads in full, both specified frozen R2 reports in full, the current B3 entry/packet, cumulative source changes, relevant retained failures and successful logs, and earlier finding dispositions. I did not read the current-round B report or conclusions, contact a peer, acquire the canonical lock, connect to a database, install packages, run tests/builds, invoke a browser, or access hosted services. Only static reads, Git inspection, hashing and evidence-file creation were performed; audit-owned outputs are confined to this directory. [Attestation](ATTESTATION.md) [Evidence inventory](EVIDENCE_INDEX.md)

Requested model: inherited orchestrator model. Observable runtime identity: an AI assistant accessed via an API; exact model identifier, provider/backend selection and reasoning setting are not exposed. The mandate's parent/build-model labels are instructions, not telemetry proving this auditor's identity. [Identity](IDENTITY.md)

The accepted base is `485c67973b56758fb9b8404579f5ddaec87136bd`. Actual direct ancestry is:

```text
485c67973b56758fb9b8404579f5ddaec87136bd
  -> 9f38ab033b08ae30ce2fc62d0150520239d6a5c8
  -> cf3e72f90ad63d40c1831d8b86141f2d16b7ba05
  -> b94c24889c8f5bf40a2749ad57c26173ab5ad64a
  -> 143d451ead6ccdbebd92ca3031ba7a89867d6cfc
```

All four descendant commits have Bradley Gleave as author and committer; the cumulative delta is seven test/helper files, +294/−15, with no application, Prisma schema/migration, generator or workflow delta. The terminal/race assertion changes are in `9f38`; the statement “no ... assertion changes in any S5 commit” in B3_MANIFEST line 6 is incorrect if read cumulatively, although the two post-B2 commits do not change those assertions. [Verification](STATIC_VERIFICATION.txt) [Manifest, line 6](../../../s5-r3/B3_MANIFEST.md)

## 2. Integrity and attribution

- The frozen checkpoint-5-B3 bundle verifies and advertises the exact candidate, requiring public-main prerequisite `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`; its SHA-256 is `e42aa021442a8a004bf796e2958461bf79d11c1666fe8fb08ef46dd80bd75b48`. All five checkpoint-5 input hashes and all twenty B3 log hashes independently match; the four current wrapper scripts equal their frozen copies. [Verification](STATIC_VERIFICATION.txt)
- `LOG_SHA256SUMS` entries are basenames relative to `execution/s5-r3/logs`, not relative to the checkpoint folder. My first check used the wrong root and printed twenty “MISSING” entries; the retained correction verifies all twenty. Those first entries are an auditor path-resolution error, not lost final logs. [Verification correction](STATIC_VERIFICATION.txt)
- Checkpoint-4 hashes match. Checkpoint-3's manifest improperly includes itself with the empty-file hash; the other six entries match. This is a historical manifest defect, not corruption of checkpoint-5. Do not rewrite that frozen original; attach a corrected, non-self-including historical manifest if needed. B3_MANIFEST line 5 also mistypes the bundle's abbreviated prefix (`...a008…` instead of `...a004...`); the actual SHA256SUMS is authoritative. [Verification](STATIC_VERIFICATION.txt) [Manifest, line 5](../../../s5-r3/B3_MANIFEST.md)
- B3's environment stamps exact `143d`/tree, clean state, dependency lock identity and pinned marked lane. Guard log lines 32–36 reports 27/27; live log lines 2645–2649 reports 51/51 in 225.618 seconds. The exit record reports `PROOF_EXIT=0`, `STOP_RC=0`, `DAEMON=none`; the sentinel reports no outer-bound cleanup. These are reviewed recorded observations, not an audit rerun. [Environment, lines 1–23](../../../s5-r3/logs/env-resume-20260922T002932Z.log) [Guard result](../../../s5-r3/logs/guard-unit-20260922T002932Z.log) [Live result](../../../s5-r3/logs/live-etq0-20260922T002932Z.log) [Exit](../../../s5-r3/logs/exit-resume-20260922T002932Z.log) [Sentinel](../../../s5-r3/logs/full-20260922T002932Z.sentinel)

## 3. Stable current findings and smallest closures

### S5-R3-A-01 — Failed pre-state/identity assertions do not prevent destructive teardown

**High; source defect; blocks S5 validation-harness merge/acceptance. Static control-flow finding, not a reproduced DB incident.**

`test/rls-g2-pg17-etq0.spec.ts:28–66` performs identity/marker and 164/E-absent assertions before setup writes, but `:80–85` unconditionally drops constraints and calls `resetData()` in `afterAll`. That function issues unscoped DELETEs against all five fixture tables (`test/utils/g2-pg17-harness.ts:118–121`). Installed Jest's hook handler catches a failed `beforeAll`, records errors, and still runs `afterAll`: `node_modules/jest-circus/build/jestAdapterInit.js:159–177,792–809,893–899,978–998`. [Exact source and Jest excerpts](EVIDENCE_EXCERPTS.txt)

Consequently, a marked, stopped cluster that passes runner preflight but has unexpected migration history, E column, role shape or client pre-state can fail setup and still be mutated by cleanup. A concrete static route is `resume` on a non-pristine marked cluster: the runner relies on the spec for its 164/E-absent check (`run-proof.sh:320–327`), while successful B3 deliberately left the cluster mutated. This contradicts the promised refusal-before-mutation boundary; it does **not** mean teardown ran on a wrong target in B3. [Runner excerpts](EVIDENCE_EXCERPTS.txt) [B3 final state, line 24](../../../s5-r3/B3_MANIFEST.md)

The unconditional teardown existed at accepted `485c` as well. I am not retroactively rejecting that successful run: R3's newly asserted markers and its explicit resume/pre-state refusal contract make the inherited teardown materially relevant now. [Base and final source verification](STATIC_VERIFICATION.txt) [Resume contract, lines 33–35](../../../s5-r3/SLOT_B2_PACKET.md)

**Smallest closure:** put teardown behind a flag set only after every read-only identity/pre-state gate passes, before the first intended setup mutation, so partial authorized setup can still clean up. Ensure every setup-refusal path performs no mutating cleanup. Add a focused offline hook/control-flow regression with recorded SQL calls: identity failure, marker failure and 165/E-present refusal must make zero DDL/DML calls, including afterAll; successful/partially started setup still cleans up. Freeze a successor and request exact-head proof; no application or migration changes are required.

### S5-R3-A-02 — Outer timeout cleanup reacquires rather than retains the canonical lock

**High; frozen runner/lifecycle defect; blocks acceptance of the “lock through cleanup/no surviving daemon” guarantee and further affected execution.**

`launch-full.sh:13–19` times out the runner, then invokes a new bounded `run-proof.sh stop` only for rc 124/137. `run-proof.sh` has no EXIT/TERM/INT trap; its cleanup function is reached only through explicit calls (`:183–197`). The postmaster is deliberately detached from fd 9, while the killed runner is the lock owner. On outer timeout there is a window after its fd closes and before the stop runner takes the nonblocking lock; another lane can acquire it, making the cleanup attempt return 75 without stopping the server. Other externally signaled exits are not covered by the launcher's rc test. Normal `finish` also records a surviving daemon but then releases the lock and exits. [Frozen runner and launcher excerpts](EVIDENCE_EXCERPTS.txt)

This is a control-flow defect in the advertised failure handling, not evidence that B3 timed out or leaked its daemon: B3 clean stop is recorded, and the outer bound was not hit. Normal child-failure handling correctly uses `PIPESTATUS[0]` and preserves the first failure; retain that behavior. [B3 exit](../../../s5-r3/logs/exit-resume-20260922T002932Z.log) [B3 sentinel](../../../s5-r3/logs/full-20260922T002932Z.sentinel) [Runner, lines 183–203](../../../s5-r3/checkpoint-5-B3/run-proof.sh)

**Smallest closure:** make a bounded supervisor own the lock through worker termination, stop and liveness verification, with explicit signal/timeout cleanup and separate first-exit/cleanup-exit records. Do not solve this by letting the daemon inherit the lock. Failure to stop must quarantine the affected lane and escalate, not claim guaranteed cleanup. Prove timeout, TERM, failed start and failed stop using an isolated fake lifecycle/lock harness first; any actual PG lifecycle proof requires a parent slot.

### S5-R3-A-03 — Destroy suppresses stop failure and can report success after deleting a live cluster

**High; frozen fixture-helper defect; blocks use of `destroy` and any fresh-full plan that depends on it.**

`s5-fixture.sh:54–56` checks the file marker, then executes `pg_ctl ... stop || true; rm -rf "$DATA"; echo S5_FIXTURE_DESTROY_OK`. A failed stop is explicitly discarded, deletion proceeds, and the last echo can also mask removal failure. The runner invokes this path directly (`run-proof.sh:273`) without the `SERVER_STARTED_HERE` cleanup/liveness check used for full/resume. This permits false success and removal while the postmaster is still alive. It is not a B3-observed action: B3 did not destroy the cluster. [Fixture and runner excerpts](EVIDENCE_EXCERPTS.txt) [B3 scope, lines 24,28](../../../s5-r3/B3_MANIFEST.md)

**Smallest closure:** refuse removal on a genuine stop failure or surviving process; distinguish an already-stopped, identity-verified cluster from failed shutdown; propagate removal failure and confirm absence before success. Retain first error and lock ownership. Add fake-stop-failure/removal-failure controls before any grant to delete the stopped B3 cluster. No destroy command is requested by this audit.

### S5-R3-A-04 — Zero attached sessions is logged, not enforced for live/resume

**Medium; enforcement/packet discrepancy; fix before reusing the runner for another live/resume slot. Does not invalidate observed B3 with zero sessions.**

Preflight stores `TARGET_SESSIONS` at `run-proof.sh:240` and reports success at `:244` without checking it; the only zero-session check is reset-specific at `:332`. Live/resume can proceed with a nonzero count despite the runner header `:13–16` and B2 packet `:33–35` describing this as a required pre-live fact. The retained “busy” negative is a **reset** test, not a resume refusal (`runner-preflight-stub-controls-20260921T233236Z.log:50–54`). [Runner](../../../s5-r3/checkpoint-5-B3/run-proof.sh) [Packet](../../../s5-r3/SLOT_B2_PACKET.md) [Stub control](../../../s5-r3/logs/runner-preflight-stub-controls-20260921T233236Z.log)

**Smallest closure:** require the pre-live target-session count to be exactly zero for the mutating proof paths, and add a no-DB stand-in control showing no generation/live child starts after a busy-target response. Accurately label the unavoidable snapshot nature of this observation; this is not a connection fence against an uncooperative process.

### S5-R3-A-05 — Client provenance evidence overstates one enforced check and hides a hash failure

**Low; actual evidence-stamping defect plus negative-control weakness; not a reason to reject the completed 51 assertions.**

The final generate-only log contains a real `sha256sum .../.prisma/client/runtime/library.js: No such file or directory` at line 4, an empty candidate runtime hash at line 5, then `G2_PG17_GENERATE_OK`. Bootstrap line 181 nests that failing hash in echo, so it does not fail the stage. Candidate generated `index.js` uses the installed `@prisma/client/runtime/library.js`, not that nonexistent relative path. The explicit engine-equality exit-6 gate is only for O (`bootstrap:173–174`), not the candidate, despite B3_MANIFEST line 20 implying that enforcement covers the candidate too. My static check finds all three engine files equal and the actual installed candidate runtime hashes successfully; it supplies missing observation, not retroactive enforcement. [Generate log](../../../s5-r3/logs/generate-only-20260922T002932Z.log) [Bootstrap excerpts](EVIDENCE_EXCERPTS.txt) [Independent provenance checks](PROVENANCE_STATIC.txt) [Manifest](../../../s5-r3/B3_MANIFEST.md)

The genctl negative accepts any nonzero exit (`run-proof.sh:283–286`), including timeout or an unrelated generation failure. The **recorded** negative really is the intended missing-client refusal (rc 1, “Could not resolve @prisma/client”), so the particular B3 control is valid; the reusable assertion is weaker than its description. [Runner](../../../s5-r3/checkpoint-5-B3/run-proof.sh) [Negative stderr](../../../s5-r3/logs/genctl-negative-20260922T002859Z.log) [Genctl result, lines 40–43](../../../s5-r3/logs/run-genctl-20260922T002859Z.log)

**Smallest closure:** resolve/hash the actual runtime entry, fail explicitly if required provenance reads fail, assert both engine comparisons if claiming both enforced, and require the expected refusal class/exit rather than any nonzero status. Correct the report without modifying frozen logs. No DB replay is needed solely to fix metadata.

### S5-R3-A-06 — Recreation packet is still checkpoint-2-specific; exact-head fresh full remains unproven

**Medium; recreation/evidence gap, not failure of the B3 resume result. Carry S5-R2B-01 narrowly.**

`RECREATE.md:1–14` still directs restore of checkpoint-2 and `cf3e72f9`, the head with the missing Result import. It is labelled checkpoint 2, so it is not a forged final recipe, but it cannot serve as final-candidate instructions. The final wrapper hardcodes the candidate/evidence directories (`run-proof.sh:36–40`); checking out a different restore directory alone would not make the frozen runner consume it. B3 correctly admits that the full init/bootstrap route was not rerun at `143d`; its role/database/164-migration bootstrap state came from B2 at `cf3`, while generation/live came from the final head. [Recreation instructions](../../../s5-r3/RECREATE.md) [Runner](../../../s5-r3/checkpoint-5-B3/run-proof.sh) [B3 limitation, line 28](../../../s5-r3/B3_MANIFEST.md)

**Smallest closure:** add an explicit checkpoint-5 recreation document with prerequisite public base, exact head/tree, checksum working directories, hardcoded-path mapping, approved dependency provenance, detached O creation and PG distribution provenance. Keep “recipe inspected” separate from “fresh full executed.” A fresh full is necessary only if claiming that stronger recreation/full-path closure; after the safety fixes it needs a new grant and an explicit plan for the existing cluster, not an automatic destroy or reuse.

### S5-R3-A-07 — Original npm install debug logs are not available at their cited paths

**Medium evidence-retention gap; no inference of concealment and no retroactive authorization.**

The B2 packet cites `/home/user/.npm/_logs/2026-09-22T00_11_05_805Z-debug-0.log` and `...00_11_29_579Z-debug-0.log`; neither exists there during this audit. I did not locate a retained copy in the inspected S5 packet/quarantine. Therefore I cannot independently attest the raw npm argv/cwd from those debug logs; those details remain the builder/parent's disclosed account. The retained bootstrap warning at line 518 and quarantined package/lock/modules corroborate the provenance incident, and the quarantine's three identifying hashes match the reported prefixes. [B2 packet, lines 8–17](../../../s5-r3/SLOT_B2_PACKET.md) [Bootstrap warning](../../../s5-r3/logs/bootstrap-20260922T001045Z.log) [Independent checks](PROVENANCE_STATIC.txt)

**Smallest closure:** parent preserves original debug logs if another retained copy exists, or explicitly records their absence and the limit of verification; do not recreate them from narrative or run another install. Preserve the existing quarantine, old B2 client and failed logs.

## 4. What the bounded proof does establish

### Marked-lane guards and ordinary refusal paths

Source pins loopback/port/database/admin/markers and strips hosted/libpq overrides, runs offline guards before flock, refuses foreign markers before connected mutation, uses one read-only maintenance batch, checks supported database names, and restricts reset to a marked target with no sessions. The final source's URL parser refuses unsafe hosts/ports/roles/password-bearing URLs/options and double-entry mismatches. The new guard case checks literal marker agreement in bootstrap, **not** live connected refusal behavior by itself. [Runner, lines 43–127,209–245,330–338](../../../s5-r3/checkpoint-5-B3/run-proof.sh) [Guard source](../../../../worktrees/s5-r3/test/utils/g2-pg17-db.ts) [Guard tests, lines 50–63](../../../../worktrees/s5-r3/test/scout/g2-pg17-db-guard.spec.ts)

The earlier offline control logs cover wrong pins/password/dependencies, foreign/blank markers, wrong server identity, unexpected roles/databases, connection failure, busy lock and reset refusal/order. These are stand-in controls, not real hostile-server trials. The first `233108Z` control attempt hit unintended repeated LOCK_BUSY; the later `233236Z` controls repair that attribution by showing the intended refusals and immediate free lock. Rev-4's first offline attempt also failed helper-pin matching; its retry's stop attempt hit LOCK_BUSY rather than proving actual stop. Do not count those failed attempts as successful lifecycle controls or as final-head replay. [First controls](../../../s5-r3/logs/runner-preflight-stub-controls-20260921T233108Z.log) [Later controls](../../../s5-r3/logs/runner-preflight-stub-controls-20260921T233236Z.log) [Rev-4 first](../../../s5-r3/logs/runner-rev4-offline-controls-20260922T000126Z.log) [Rev-4 retry](../../../s5-r3/logs/runner-rev4-offline-controls-20260922T000147Z.log)

### Bootstrap, old root and dependency provenance

The real detached O checkout is present at `925780e0a1906593e5383c618311b6b17364b8dc`, with 164 migration directories, identical candidate/O manifests and exact preserved reconstruction/roster/entity service bytes; its node_modules symlink resolves to the candidate tree. The new helper rejects an archive extraction, checks ancestry/detachment/source and ledger model shape, and defaults to a self-contained clone. This closes S5-R2-A-03's specific real-Git recreation defect, not every fresh-machine dependency/bootstrap claim. [Provenance checks](PROVENANCE_STATIC.txt) [Old-root helper, lines 24–82](../../../../worktrees/s5-r3/test/utils/g2-pg17-old-root.sh)

Final bootstrap exports `PRISMA_GENERATE_SKIP_AUTOINSTALL=1`, requires O output inside the old root, verifies the real resolved @prisma/client package equals the candidate package and uses the pinned CLI. B3 generated the O client at the new inside-root path and consumed it, rather than the quarantined-era B2 client. The final O engine, candidate engine and installed @prisma/engines binary are byte-equal; installed/quarantined Prisma package versions and lock integrity fields agree, but equality never authorizes the earlier install. [Bootstrap, lines 41–42,160–183](../../../../worktrees/s5-r3/test/utils/g2-pg17-bootstrap.sh) [Environment, lines 18–23,33–35](../../../s5-r3/logs/env-resume-20260922T002932Z.log) [Provenance checks](PROVENANCE_STATIC.txt)

B3 records ancestor package roots absent before/after and genctl records unchanged latest npm log plus intended refusal; that supports this pinned, no-auto-install generation path. It is not an exhaustive network monitor or a general proof that any future package execution cannot install. [Environment, lines 24–50](../../../s5-r3/logs/env-resume-20260922T002932Z.log) [Genctl, lines 40–43](../../../s5-r3/logs/run-genctl-20260922T002859Z.log)

### Two actual-T/down schedules: assertions versus observations

**Default-budget schedule:** spec `:829–913` now asserts terminal outcomes, rather than merely logging them. B3 observed `down-applied`, worker `500/P2022`, zero completion events; the selected source branch requires empty ledger, no Person/entity, column absent and history 165, then raw forward repair and one-to-one replay convergence. The green complete suite supports these executed assertions. It does not promise which 5-second budget always wins, and the mixed T-live/E-down 500 is explicitly an unsafe rollout characterization, not acceptable production recovery. [Spec excerpts](EVIDENCE_EXCERPTS.txt) [Live, lines 2506,2519,2533,2642](../../../s5-r3/logs/live-etq0-20260922T002932Z.log)

**Fixture-extended schedule:** spec `:915–960` passes `txTimeout:30000` to the fixture worker, forces the claim to outlive E's five-second lock budget, asserts a lock-timeout refusal with unchanged catalog/history and invisible uncommitted rows, then requires a successful single claim/target and exact completion-event payload after release. B3 records reconstructed 1/events 1 and passes this case. The timeout override is test-only; it does not change production transaction defaults or establish drain/fencing. [Spec excerpts](EVIDENCE_EXCERPTS.txt) [Worker](../../../../worktrees/s5-r3/test/utils/g2-tq0-worker.cjs) [Live, lines 2574,2643](../../../s5-r3/logs/live-etq0-20260922T002932Z.log)

The default schedule's alternative down-refused/durable-`error:Prisma.P2028` branch is now asserted **if selected**, but B3 did not select it. The 30-second refused schedule commits successfully and is not proof of that P2028 branch. Thus S5-R2-A-02 closes for measured terminal-contract coverage, while S5-R2B-03/04's timing and unobserved-branch limitations remain bounded. [Spec, lines 881–903,915–960](EVIDENCE_EXCERPTS.txt) [Prior R2 B, sections 4–6](../../../../repos/tgp-private-evidence/2026-09-20/audits/s5-r2/b/revision-1/REPORT.md)

## 5. Failures, authorization, and prior closures

B2's live attempt at `cf3` had TS2304 for the missing `Result` type and **zero test cases**; bootstrap's 164 success and its clean stop do not turn it into live proof. `b94` adds the missing type import; final B3 is the attributable executed 51-case proof. The auto-install incident and post-B2 ungranted commit/typechecks/offline probes remain disclosed deviations, not retroactively granted commands. I accept their existence as evidence where attributable, never as permission to repeat them. [B2 live failure](../../../s5-r3/logs/live-etq0-20260922T001045Z.log) [B2 exit](../../../s5-r3/logs/exit-full-20260922T001045Z.log) [Disclosure, lines 30–33](../../../s5-r3/B3_MANIFEST.md) [History verification](STATIC_VERIFICATION.txt)

Prior R2 bounded closures are preserved except the newly material no-mutation-on-refusal/lifecycle issues above; the historical successful role bootstrap, nonsuperuser DDL, heap completion, actual O/T execution, cursor/ledger/collision assertions and normal first-failure handling are not gratuitously reopened. [Prior A disposition table, lines 103–127](../../../../repos/tgp-private-evidence/2026-09-20/audits/s5-r2/a/revision-1/REPORT.md) [Prior B dispositions](../../../../repos/tgp-private-evidence/2026-09-20/audits/s5-r2/b/revision-1/REPORT.md)

| Stable prior finding(s) | Current bounded disposition |
|---|---|
| S5-A-01/02/04; S5-B-01/02/06 | Preserve measured closures; B3 adds attributable 27/51. A-01 here concerns refused setup, not whether successful tests ran. |
| S5-A-03 / S5-B-03; S5-R2B-08 | Preserve synthetic-role closure; actual hosted serving identity, owners and drift remain unverified. |
| S5-A-05 / S5-B-04; S5-R2-A-01 / S5-R2B-02 | Keep proof-gap closure and E-specific recovery-packet gap open. P3012 is measured, not a valid clean-history recovery command. |
| S5-R2-A-02 | Terminal assertions repaired and executed for the observed default branch plus the separate fixture-extended refused schedule; do not claim every alternative observed. |
| S5-R2-A-03 | Real-Git old-root defect closed; final full-recreation gap tracked separately by A-06 here. |
| S5-R2B-01 | Partially improved: fixtures now inspectable, generation resumed at exact head; fresh full at final head still not executed. |
| S5-A-06/07; S5-B-05 | Hosted drift/rolled-back-name applicability and PG15/CI truth labels remain release-owner work. |
| S5-A-08 / S5-B-07 | O downgrade/NULL resumption/narrow-collision/legacy-cursor behavior remain characterizations, not writer fencing or later-stage acceptance. |
| S5-A-09 / S5-R2B-05 | Retain ledger-scope accounting/contract-label caveat; no schema repair belongs to S5. |
| S5-A-10/11; S5-R2B-03/04/07 | Retain measured quality/coordination closures; port assertion now uses validated target.port; neither arbitrary portability nor default-P2028 execution is inferred. |
| S5-R2B-06 | Synthetic-password argv hygiene nit remains; not a real customer credential disclosure. |
| S5-A-12 | Parent's contract/integration dependency remains outside S5. |

This table applies the two frozen R2 reports to the inspected cumulative source and B3 evidence, not a current peer conclusion. [Prior A](../../../../repos/tgp-private-evidence/2026-09-20/audits/s5-r2/a/revision-1/REPORT.md) [Prior B](../../../../repos/tgp-private-evidence/2026-09-20/audits/s5-r2/b/revision-1/REPORT.md) [Verification](STATIC_VERIFICATION.txt)

## 6. Release boundary and parent next step

S5 is a **test/validation merge boundary**, not an E or T release. E raw forward rejects an already-present column (`migration.sql:37–43`); down refuses assigned provenance and does not repair successful Prisma history (`down.sql:51–56`). B3 again records P3012 on `resolve --rolled-back` for successful history. Do not direct a generic idempotent rerun or use resolve as if that state were failed. Prefer retaining E while rolling back compatible application behavior; any removal needs the separate reviewed drain/recovery packet. [E forward](../../../../worktrees/s5-r3/prisma/migrations/20270118000000_scout_ledger_platform_expand/migration.sql) [E down](../../../../worktrees/s5-r3/prisma/migrations/20270118000000_scout_ledger_platform_expand/down.sql) [P3012 observation, lines 2436–2445](../../../s5-r3/logs/live-etq0-20260922T002932Z.log)

Later **B/drain → R → N/Q1 → C**, actual hosted serving-role applicability, rollback/recovery authorization, native/flag activation and customer acceptance are not proved by this suite. The test fixture's `s5_super` administration, nonsuperuser BYPASSRLS `postgres` ownership and `service_role` runtime with synthetic API grants are explicit synthetic assumptions, not observed hosted deployment facts. [Spec scope, lines 1–7,28–77](../../../../worktrees/s5-r3/test/rls-g2-pg17-etq0.spec.ts) [Role constants, lines 14–25](../../../../worktrees/s5-r3/test/utils/g2-pg17-db.ts) [Canonical state](../../../../LAST_OPERATOR_STATE.md)

**Smallest parent action:** retain B3 as bounded evidence; dispatch only the validation-source/runner repairs in A-01–04 to the canonical builder, with A-05/06 packet corrections and A-07 retention follow-up. Re-audit the exact successor before another mutating slot. No product/schema edits, public push or current-head DB rerun are justified by this audit. If parent needs additional execution, the request file separates a minimal offline closure plan from a later conditional fresh-full request; neither is an authorization. [Execution request](EXECUTION_REQUEST.md) [Mandate, lines 29,34,46,50–56,70–74](../../../EXECUTION_MANDATE.md)

**Freeze:** this report and companion identity/evidence/attestation files are original independent audit A outputs; checksum manifest excludes itself. No peer result was used. [Attestation](ATTESTATION.md)
