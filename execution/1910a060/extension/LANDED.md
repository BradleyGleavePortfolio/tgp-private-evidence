# EXT-LAND-1 landed

Exact owner authorization: current explicit takeover and continuation reset;
predecessor execution/daceddc8/SCOPE.md EXT-LAND-1 names the same bridge.

On 2026-09-25 at 21:07Z extension main advanced by two ordinary non-force pushes:

1. 0111be661922234d670bbf23e23d270eec1b4a4e
   to 8901d5f50eaadd6bad19e933c9e76b6539299669.
2. 8901d5f50eaadd6bad19e933c9e76b6539299669
   to a889f4ade0e13d9f45aabd69c5878ff07e2038bf.

Both exact candidates had green checks and valid linear ancestry before execution.
No new product commit was created; no accepted test was rerun locally.
Only enforce_admins was temporarily disabled. Approval count, required checks
and every other protection field remained unchanged. It was restored immediately
after the two pushes; canonicalized complete protection JSON compared byte-identical
to pre-state, then an independent readback at21:09Z again matched.
Raw response bodies and command receipt are in this directory.

PR27 is MERGED at8901d5f5. E2 exact head is now on main, but PR30 initially remained
OPEN because its base is land/s4-r6. That is PR bookkeeping, not an unlanded product.
No claim of PR30 merge is made without subsequent verification.

Subsequent bookkeeping: retarget to main was refused by GitHub because main already
contains the exact head ("There are no new commits between base branch main and
head branch land/e2-status-server"). A routine close was blocked by the execution
platform and was not retried. Verified PR30 remains OPEN; no product bytes removed.
Do not re-execute the protection bridge to resolve this cosmetic PR state.

Main push CI and CodeQL are green on a889f4ad:
- https://github.com/BradleyGleavePortfolio/tgp-importer-extension/actions/runs/36189788925
- https://github.com/BradleyGleavePortfolio/tgp-importer-extension/actions/runs/36189788919

Only CI, CodeQL and secrets-scan workflows exist at this head.
Chrome Web Store publication was not performed and remains reserved.
