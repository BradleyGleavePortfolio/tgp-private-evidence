# S5 R3 audit A — evidence index

All paths below are workspace-relative unless absolute. Line numbers in REPORT.md refer to the original inspected files, not the excerpt file's own line numbering. Source/link hashes and identity checks are preserved in [STATIC_VERIFICATION.txt](STATIC_VERIFICATION.txt), [PROVENANCE_STATIC.txt](PROVENANCE_STATIC.txt), and [INPUT_IDENTITIES.json](INPUT_IDENTITIES.json).

## Governing reads — complete

- [Execution mandate](../../../EXECUTION_MANDATE.md), 75 lines.
- [Agent rules](../../../../repos/tgp-agent-context/AGENT_RULES.md), 166 lines.
- [T0–T4 grading/model-routing doctrine](../../../../initialization/attachments/TGP_T0-T4_PR_Slice_Grading_and_Model_Routing_Doctrine.txt), 330 lines.
- [EXECUTE operator doctrine](../../../../initialization/attachments/TGP_EXECUTE_Autonomous_Executive_Operator_Doctrine.txt), 275 lines.
- [Canonical operator state](../../../../LAST_OPERATOR_STATE.md), 72 lines at the initial governing read.

## Prior reports and context

- [Frozen R2 A report, complete](../../../../repos/tgp-private-evidence/2026-09-20/audits/s5-r2/a/revision-1/REPORT.md).
- [Frozen R2 B report, complete](../../../../repos/tgp-private-evidence/2026-09-20/audits/s5-r2/b/revision-1/REPORT.md).
- Relevant prior findings: [R1 A](../../../../repos/tgp-private-evidence/2026-09-20/audits/s5-r1/a/revision-1/REPORT.md), [R1 B](../../../../repos/tgp-private-evidence/2026-09-20/audits/s5-r1/b/revision-1/REPORT.md).
- [Checkpoint-1 parent note](../../../../repos/tgp-private-evidence/2026-09-20/remediation/s5-r3/checkpoint-1/PARENT_NOTE.md), distinguishing rejected early runner from execution authority.
- No current-round B report/conclusion was consulted.

## Entry and authorization/evidence narrative — complete

- [B3_MANIFEST](../../../s5-r3/B3_MANIFEST.md).
- [SLOT_B3_RESULT](../../../s5-r3/SLOT_B3_RESULT.md).
- [SLOT_B2_PACKET](../../../s5-r3/SLOT_B2_PACKET.md).
- [SLOT_B2_RESULT](../../../s5-r3/SLOT_B2_RESULT.md).
- [SLOT_B3_REQUEST](../../../s5-r3/SLOT_B3_REQUEST.md).
- [SLOT_A1_RESULT](../../../s5-r3/SLOT_A1_RESULT.md).
- [Historical checkpoint-2 report](../../../s5-r3/REPORT.md).
- [Historical checkpoint-2 recreation](../../../s5-r3/RECREATE.md).

## Frozen final input packet

- [Bundle](../../../s5-r3/checkpoint-5-B3/s5-r3-candidate.bundle).
- [run-proof.sh](../../../s5-r3/checkpoint-5-B3/run-proof.sh), read completely.
- [s5-fixture.sh](../../../s5-r3/checkpoint-5-B3/s5-fixture.sh), read completely.
- [launch-full.sh](../../../s5-r3/checkpoint-5-B3/launch-full.sh), read completely.
- [npm-ci.sh](../../../s5-r3/checkpoint-5-B3/npm-ci.sh), read completely.
- [SHA256SUMS](../../../s5-r3/checkpoint-5-B3/SHA256SUMS), all five entries independently checked.
- [LOG_SHA256SUMS](../../../s5-r3/checkpoint-5-B3/LOG_SHA256SUMS), all twenty entries independently checked against the logs directory.
- Checkpoint-3/4 original bundles/patch manifests were inspected for attribution/integrity without modification; checkpoint-3's self-inclusion error is recorded, not repaired in place.

## Candidate source coverage

The cumulative accepted485c→143d diff was read in full. Changed helper files were read fully; all modified and adjacent spec sections were read, with focused review of beforeAll/afterAll and the final two schedules. Relevant unchanged service transaction/tally logic and E up/down were also inspected. [Git scope verification](STATIC_VERIFICATION.txt)

- [Main proof spec](../../../../worktrees/s5-r3/test/rls-g2-pg17-etq0.spec.ts).
- [Guard tests](../../../../worktrees/s5-r3/test/scout/g2-pg17-db-guard.spec.ts).
- [Target guard](../../../../worktrees/s5-r3/test/utils/g2-pg17-db.ts).
- [Bootstrap](../../../../worktrees/s5-r3/test/utils/g2-pg17-bootstrap.sh).
- [Old-root helper](../../../../worktrees/s5-r3/test/utils/g2-pg17-old-root.sh).
- [Harness](../../../../worktrees/s5-r3/test/utils/g2-pg17-harness.ts).
- [Worker](../../../../worktrees/s5-r3/test/utils/g2-tq0-worker.cjs).
- [Product reconstruction service](../../../../worktrees/s5-r3/src/scout/scout-reconstruct.service.ts), transaction/tally/retry context.
- [E forward](../../../../worktrees/s5-r3/prisma/migrations/20270118000000_scout_ledger_platform_expand/migration.sql) and [E down](../../../../worktrees/s5-r3/prisma/migrations/20270118000000_scout_ledger_platform_expand/down.sql), complete.
- Installed Jest hook handler and defaults, candidate generated Prisma runtime import, and old-root/quarantined dependency identities were read statically; none was executed. [Key excerpts](EVIDENCE_EXCERPTS.txt) [Dependency comparisons](PROVENANCE_STATIC.txt)

## Principal execution records reviewed

- A1 initial interrupted install and successful second-install/guard records: `logs/npm-ci-20260921T233753Z.log`, `npm-ci-20260921T234342Z.log`, `exit-npm-ci-20260921T234342Z.log`, and A1 result/slot narrative.
- B2: [bootstrap](../../../s5-r3/logs/bootstrap-20260922T001045Z.log), [zero-case compile failure](../../../s5-r3/logs/live-etq0-20260922T001045Z.log), [environment](../../../s5-r3/logs/env-full-20260922T001045Z.log), [fixture](../../../s5-r3/logs/fixture-20260922T001045Z.log), [exit](../../../s5-r3/logs/exit-full-20260922T001045Z.log).
- B3: [genctl result](../../../s5-r3/logs/run-genctl-20260922T002859Z.log), [negative](../../../s5-r3/logs/genctl-negative-20260922T002859Z.log), [resume environment](../../../s5-r3/logs/env-resume-20260922T002932Z.log), [guard](../../../s5-r3/logs/guard-unit-20260922T002932Z.log), [generation](../../../s5-r3/logs/generate-only-20260922T002932Z.log), [live assertions/results](../../../s5-r3/logs/live-etq0-20260922T002932Z.log), [exit](../../../s5-r3/logs/exit-resume-20260922T002932Z.log), [sentinel](../../../s5-r3/logs/full-20260922T002932Z.sentinel), [fixture](../../../s5-r3/logs/fixture-20260922T002932Z.log), run/preflight/oldroot records.
- Earlier negative controls: [offline refusals](../../../s5-r3/logs/runner-negatives-20260921T233017Z.log), [first preflight stand-in attempt](../../../s5-r3/logs/runner-preflight-stub-controls-20260921T233108Z.log), [corrected preflight controls](../../../s5-r3/logs/runner-preflight-stub-controls-20260921T233236Z.log), [first rev-4 controls](../../../s5-r3/logs/runner-rev4-offline-controls-20260922T000126Z.log), [retry rev-4 controls](../../../s5-r3/logs/runner-rev4-offline-controls-20260922T000147Z.log).

Large live/launcher transcripts were range-read for run identity, important outcomes/failures, error signatures and final summary, rather than treating every routine worker trace as separate new evidence. Final-log byte integrity was checked for all twenty manifested files. [Verification](STATIC_VERIFICATION.txt)

## Independent audit artifacts

- [REPORT.md](REPORT.md): findings, closures, scope and disposition.
- [IDENTITY.md](IDENTITY.md): requested versus observable runtime identity.
- [ATTESTATION.md](ATTESTATION.md): independence/actions/limits.
- [EXECUTION_REQUEST.md](EXECUTION_REQUEST.md): non-authorizing minimum follow-up scope.
- [STATIC_VERIFICATION.txt](STATIC_VERIFICATION.txt): Git/bundle/hash checks, including retained correction.
- [PROVENANCE_STATIC.txt](PROVENANCE_STATIC.txt): old-root, engine/runtime, quarantine and missing-original-log checks.
- [EVIDENCE_EXCERPTS.txt](EVIDENCE_EXCERPTS.txt): exact numbered source/log excerpts with input hashes.
- [INPUT_IDENTITIES.json](INPUT_IDENTITIES.json): static input file identities at packet assembly, not a replacement for the builder's frozen manifests.
- `SHA256SUMS`: final audit-output manifest, excluding itself.
