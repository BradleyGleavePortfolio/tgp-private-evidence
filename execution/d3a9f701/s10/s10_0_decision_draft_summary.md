# S10-0 decision doc — draft 2 (post-review revision)

- File: /home/user/workspace/worktrees/d3a9-s10-0/docs/decisions/2026-09-26-s10-induction.md (UNCOMMITTED, untracked; worktree HEAD 771db62a)
- Draft 2 sha256: 319ff63692fa5e4eb772826cad5bfc362ee82cd1534e622b6fc0c577b1927414, 449 lines
- Draft 1 preserved: /home/user/workspace/private-evidence/execution/d3a9f701/s10/draft-1-c5f6186e.md (sha256 c5f6186e…b921)
- Review: /home/user/workspace/s10_0_review.md

Finding → section map:
1 (A) D-S10-1 verifier rule + manifest `verifiers`/V5; D-S10-2 vocabulary = ['none','source_signed_enumeration'] (page-chain deferred §5), SourceEnumerationStatementV1 signed by source, challenge-bound; D-S10-3 E4; D-S10-6 inv.1; R24, R39(f); §6 Q2.
2 (A) D-S10-2 run-level declaration (per-platform scope sets, multi-workspace = all scopes); E1/E4 scope equality; per-platform agreement only (Family fact); ScoutRunDeclaration table; declaration route; R25; Q5.
3 (A) D-S10-3 E6 (S10-C exports S9-B `resolveFamily`, 5407efae facts.service.ts L484-493; digest from its own grouping; disagreement fails closed); S10-C owned cell; R27.
4 (B) D-S10-4 Deletion bullet (BEFORE UPDATE OR DELETE trigger, REVOKE DELETE, cascade = referential cleanup only, rows stay pending Q3); R31; Q3.
5 (B) D-S10-5 pinned full B, ancestor check, porcelain --untracked-files=all, exact allowed set, bytewise diff, rg exit semantics, 3 negative controls; R40.
6 (B) D-S10-2 declaration; D-S10-3 "Emitted families" (coverage keys → required_families L69; zero-staged L66 kept); E1; R25.
7 (B) D-S10-7 S10-C owned cell (projectFamilies/projectToken, S9C-draft L731-805) + projection rule; R37.
8/9 (C) Header: current base 5407efae (S9-B landed), citation tree 771db62a (S9-A files present there, byte-identical at 5407efae), `5407efae:` and `S9C-draft:` prefixes.

## Draft 3 (re-review B-1..B-4)
- Draft 2 preserved: private-evidence/execution/d3a9f701/s10/draft-2-319ff636.md
- Draft 3 sha256: f29b95fa0c4e02b0fb6b99f8aadd427d8bb05f3c9ef42d79590c12fbfc95ec67, 480 lines
- B-1: D-S10-1 verifier rule (custody = external manifest-approval fact); D-S10-2 Trust (source-signed false statement outside evaluator; boundary = source key, Q1/Q2); R24 rewritten (a)-(k).
- B-2: D-S10-4 Deletion (only REVOKE + top-level trigger + cascade guaranteed; privileged nested deletes reserved to DB governance); R31 nested non-FK DELETE negative control + parent-cascade positive control.
- B-3: ScoutRunDeclaration shared challenge; declaration route atomic/nonempty/unique/replay-original-challenge/declaration_conflict/declaration_after_ingest; R29.
- B-4: snapshot_id -> snapshot_ref_digest (64 hex); "Signed-artifact encoding" bullet (base64 RFC 4648 §4 canonical, strict canonical JSON, Ed25519 over decoded bytes, size bounds); E4; R21.
- Only non-requested edit: G3/G4 bullets merged onto one line to meet the 480-line limit.
