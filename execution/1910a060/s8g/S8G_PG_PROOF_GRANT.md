# S8G-PG-1: single S8-G real-PG proof grant

Parent EXEC-1910A060, 2026-09-25T23:0xZ. Authority: owner continuation reset (14:08 PT) and runtime clarification
(14:14 PT); `execution/1910a060/SCOPE.md`.

## Basis

- Exact candidate: `820ce85be2ebf994112afbb90739eb9469ad628e`, tree `7ede6dbb8f6f2d0ddcc349882a47ef67d415c32a`,
  sole parent `62471b116267fdec6746073c4b4c80a154d09834`, 14 PATHS, Bradley author/committer, no trailers. New
  candidate identity (old S8-G source bytes unrecoverable; built fresh from the durable design).
- Source reviews A/B: SOURCE GO (product), B closures done. Gate attempt 4 rc0 (full default jest 577 passed / 12
  pre-existing skipped suites). Phase-2 A/B: FINAL GO for exact 820ce85b.
- Binding `execution/1910a060/s8g/binding/v1/` after CLOSURES-BIND-1: runner `s8g-pg-proof.sh`
  `4fccd1353edb47bfbeea0a7fab159660cee64f5356bccbf70280aba00705c40a`, fixture `s8g-fixture.sh`
  `62de28baa4ad3a669729aa33bebdb603b72642e9a41a2a57345b344093b3d24d`; `BINDING.sha256` 4/4. Independent binding
  re-reviews A and B: GO for ONE run, no A/B.

## Grant

Executor: `prepare_current_runtime_and_s8_f_binding_muhgfhmn` (RT-NEW-1), sole heavy-slot grantee for this run.

1. Immediately before launch verify: canonical lock inode 667698 has no holder (poll >=60 s if busy; never steal);
   no postgres process; port 55644 free; lane `clusters/s8-g`, socket and `run/` sentinel absent; `BINDING.sha256`
   OK; runner/fixture sha256 equal the values above; clone `worktrees/1910a060-s8g` clean at 820ce85b.
2. Launch exactly once, unchanged: `timeout -k 30 3600 bash .../s8g/binding/v1/s8g-pg-proof.sh`, no env overrides.
3. First failure stops. No retry, edit or rerun without a separate parent disposition. Preserve all output.
4. Data directory retained; destroy not granted.
5. Report terminal sentinel, Jest summary (expect 19/19, 1 suite), receipts SHA256SUMS, stop state, lock release.

Not granted: other tests, gates, commits, pushes, PRs, landing, production access.
