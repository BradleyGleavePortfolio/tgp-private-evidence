# draft-01-source: SEALED (immutable)

Sealed at (UTC): 2026-09-25T03:47Z by the S7-L replacement builder.
Base: 93389265a846095b846fa8f1fb0dad782fb6ee9f, branch exec64/s7l-replacement, worktree
/home/user/workspace/worktrees/64e33dc7-s7l.

MANIFEST.sha256 sha256 = 6485fe78cae2cd7c96ea34bc360ba9bb78ffe00f5d1ac20ed5418e0531f6831a (21 entries:
20 file copies under files/ + tracked-changes.patch). Verification at seal time: every entry OK; every
listed path in the live worktree is byte-identical to its files/ copy.

Contents: migration+down, schema hunk, src/scout/lifecycle/** (reason-codes, arbiter, dto, service,
run.controller), scout.module/dto/service/controller/ingest edits, analytics events keys,
scripts/importer-contract.ts (CONTRACT_VERSION 2.0.0-c1-s2.0), test/contracts/importer-contract.spec.ts,
test/scout/lifecycle/** unit specs, scout.service.spec.ts amendment.

NOT in this checkpoint (arrives in draft-02-full): test/utils/g2-s7l-* harness, test/rls-g2-s7l.spec.ts,
test/utils/g2-s7l-worker.cjs, test/scout/g2-s7l-db-guard.spec.ts, DRAFT_READY.md.

Sufficient for generate/tsc/unit-Jest/contract-regeneration feedback (no PG). Nothing in this directory
will be modified after this seal; later work is checkpointed under a new tag.
