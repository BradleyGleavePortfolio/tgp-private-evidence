# S1S2-REAL-B — Independent final actual-result / applicability addendum (T4, lane B)

Reviewer: independent nonbuilder/nonexecutor subagent of EXEC-6c2a68ac. Requested Claude Fable 5 / High is policy, not observed telemetry. Read/hash/diff only. Sole writes: this directory. Peer s1s2-real-a and parent conclusion not read.

## Verdict

**SCOPED ACCEPTANCE — no A-class, no B-class finding. S3 exact integration activation may proceed on this evidence.**

The frozen result `execution/6c2a68ac/s2-real-composition-result/` (MANIFEST `bbde4b0b…`, 103/103 OK) is exactly the one execution authorized by `S2_REAL_COMPOSITION_GRANT.md` (7d856374…) and its activation (e8dcfc61…): the command block is byte-identical across grant, PROOF_REQUEST_21 and the caller (22a29042…); the runner is the frozen efa273c7… (pinned by the block's own chained manifest check, preflight and postrun); stubs were unset; a real PG 17.6 loopback fixture, real Prisma 6.19.3 `migrate deploy`, real `scripts/release.sh` and the S1 R4 TRUNCATE discriminator ran on worktree head d5cd9b8b… / tree c0ab87d4…, which stayed clean before, after and now.

Raw statuses: `runner=0`; guard 72/72; refusals 64/64 (expected, no DB contact); fixture 0; composition 68/68 (0 FAIL); discriminator 48/48; fixture stop 0; `final=0 first_exit=0 cleanup_exit=0 survivors=none`; receipt and publication OK, deadline not exceeded; inner (90) and outer manifests verify on the pinned lane and the byte-identical copy.

## What this evidence establishes for S3 integration

- d5cd composes S1 (verify.sql 266e62e9…, guard, bootstrap, migration/down) with S2 (release.sh 8831f8f7…, contract) and the release gate behaves as specified on a real PG 17.6 database: refuses without the verifier, applies and verifies the candidate, propagates verifier failure, recovers, handles allowed-path drift, late-lock failure with whole-file rollback, and rolled-back-row recovery.
- The S1 R4 changed verifier is discriminating on real PG 17.6 for direct-anon, direct-authenticated and PUBLIC (effective-only) TRUNCATE drift; the predecessor false-greens in the same states; exact diagnostic text observed.
- Source inputs, installed CLI, fixture and lane manifests are unchanged; cleanup and ownership returned; no unexpected writes.

## Narrowed / not established (C, recorded)

- **Membership path (S1-R4B-01 / RB-02):** fixture roles are `NOINHERIT`, live roles `INHERIT`, and no control exercises role membership. This run proves direct + PUBLIC effective drift detection; the inherited-membership path is covered by documented `has_table_privilege` semantics only and remains **unobserved**. Not a blocker for S3 exact integration; carry into any hosted/live disposition.
- **Empty `runner_sha256` self-stamp (RB-01):** frozen runner hashes relative `$0` after `cd $WT`; identity is reliably established by the block's immediate `sha256sum -c` of the lane manifest pinning efa273c7… plus preflight/postrun hashes. No fixer; note only.
- Git telemetry-wrapper condition carried (census empty); leftover stopped fixture data dir means any repeat of this exact proof needs an authorized destroy first; executor read-only observations disclosed.
- Not proven and not claimed: merge, deployment, native importer reconstruction, customer acceptance, universal-importer completion, hosted grant ownership, PG 15 behaviour, live serving-role identity.

## Next permissible transition

Parent records S1/S2 real composition + discriminator evidence at d5cd as ACCEPTED (local real evidence) and activates **S3 exact integration** on the same frozen identities, carrying RB-01/RB-02 as recorded C items. No rerun, no new harness/controls, no additional audit cycle.

## Packet

`REPORT.md`, `FINDINGS.md`, `INPUTS_VERIFIED.sha256` (all inputs read), `MANIFEST.sha256` (non-self-including).
