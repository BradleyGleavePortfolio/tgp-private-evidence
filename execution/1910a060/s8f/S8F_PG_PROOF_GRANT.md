# S8F-PG-1: single S8-F real-PG proof grant

Parent EXEC-1910A060, 2026-09-25T21:5xZ. Authority: Bradley owner continuation reset (14:08 PT) and runtime
recovery clarification (14:14 PT); `execution/1910a060/SCOPE.md`.

## Basis

- Exact candidate: `e1ec2fecb71f315b6721d426ba0dacb84f304498`, tree `2fe0201ff132dfdc53ea82b3f26ed0fc8d1c65d6`,
  parent `1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47`. Reused exactly from the verified bundle; not rebuilt.
- Source: independent reviews A and B both GO, no A/B (`s8f/reviews/REVIEW_A.md`, `REVIEW_B.md`).
- Binding v2: `execution/64e33dc7/s8f/binding/v2/`, runner `s8f-pg-proof.sh`
  `3e43c8c8697c245700f581823816e5a43e1419f1b7739d8651d53b08b6a37f4c`, fixture `s8f-fixture.sh`
  `4983477330f11597de5b3350c45aaf9dd1ff0bc4278b00cec980f7d6f11e8f5f`. Independent v2 reviews A and B both
  GO for ONE proof run, no A/B (`REVIEW_A_V2.md`, `REVIEW_B_V2.md`). v1 remains immutable.
- Runtime: fresh 1910a060 namespace; PG 17.6 bytes equal the predecessor artifact hashes; no old-instance claim.

## Grant

Executor: `prepare_current_runtime_and_s8_f_binding_muhgfhmn` (RT-NEW-1), sole heavy-slot grantee for this run.

1. Immediately before launch, verify: canonical lock `/home/user/workspace/execution/test-validation.lock`
   inode 667698 has no holder; no postgres process; port 55643 free; lane and v2 `run/` sentinel absent;
   `BINDING.sha256` OK; runner/fixture sha256 equal the values above. If any fails, do not launch; report.
2. Launch the v2 runner exactly once, unchanged, with its documented command and bounds, lock via `flock -n`
   (never steal). No flags, env overrides or edits beyond those the v2 README documents.
3. First failure stops. No retry, no edit, no rerun without a separate parent disposition. Preserve all output.
4. Data directory retained; destroy is not granted.
5. Report terminal sentinel, Jest summary, receipts SHA256SUMS, stop state and lock release.

Not granted: any other test, gate, commit, push, PR, landing, contract regeneration, production access.
