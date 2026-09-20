# S1/S2 composition facts (read-only checks, 2026-09-20 23:00Z)
- S1 head `7cbbb03977455fcfb5da543bdaffaf5de3c45696` present locally (repos/backend); its only verifier is
  `prisma/migrations/20261224000000_rls_close_public_exposure/verify.sql` — matches the S2 contract entry exactly.
- `git merge-tree --write-tree 7cbbb039 1c6db2b6` → tree `cadade60d5bfabb5c9a99aa01b0519c63f69190c`, exit 0, no conflicts;
  the two heads touch disjoint files relative to base c23b9d9f (no overlapping paths).
- package.json blob `5758710b…` and package-lock.json blob `a23abae6…` are identical at S1 head, S2 head and base →
  S1's npm-ci tree is valid for S2 test/ci as a read-only share. No install performed here.
- Expected integrated `release.sh` outcome (not run): step 0 `verifiers_required = 1 (all present)`; step 4
  `verifiers_passed = 1 (discovered=1, required=1)` when the verifier passes against the synthetic DB.
