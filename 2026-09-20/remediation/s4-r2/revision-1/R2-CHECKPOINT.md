# S4 R2 early checkpoint — 2026-09-20 18:10Z (11:10 PDT)

Candidate head (local branch `execute/20260920-s4-importer`, worktree
`/home/user/workspace/worktrees/s4-importer`):

- head `c5a5ae12c5b3c3e32a4601c99319ad7c0d980057`
- tree `5f3c8f6a729427ce6c23bcb1ba18dc7b986b7447`
- chain: a6d885a (R1 frozen, unchanged) → a2a52fd (gating + origin-only text +
  harness rebind) → c5a5ae1 (worker-readiness wait)
- author/committer: Bradley Gleave <bradley@bradleytgpcoaching.com> (verified
  with `git log --format=%an/%ae/%cn/%ce`), no AI trailers
- shipping package (36 files, 209725 bytes):
  sha256 `e2ee1f5cc09094f3485c07db866d02f73f2a086d5a4d22e362da5e904b2e1e98`
  (changed from R1 `0b2f377d…` because background.js is a shipping file)
- recovery bundle `execution/s4-importer/s4-importer-c5a5ae1.bundle`
  sha256 `f99feba3b4016159cb7ed9351a0f05d5e41f235a6ebf0210e23b170791d97ca9`
  (contains branch + origin/main; needs only public base 0111be66)

Measured so far at c5a5ae1 (all under `execution/test-validation.lock`):

- positive browser proof: 11/11 PASS —
  `logs/browser-proof.r2c.log`, `logs/browser-load-proof.r2c.positive.json`
- negative control: DETECTED (no-receiver signature, 0 unrelated failures) —
  `logs/browser-load-proof.r2c.negative-control.json`
- focused vitest (router-principal-gate, start-import, start-import-hardening,
  ingest-auth): 33/33 pass (before commit; full suite running now)

Pending: full vitest / lint / type-check / format:check / gates at c5a5ae1
(`run-full-gates.sh c5a5ae1`, log `logs/full-gates.c5a5ae1.log`).

Failed runs preserved: r2a (both proofs aborted — root cause: attach raced
worker bindings; fixed in c5a5ae1), try1–3 (R1 harness bound to component
extension). Not clearance. Browser loader proof ≠ native import completion.
