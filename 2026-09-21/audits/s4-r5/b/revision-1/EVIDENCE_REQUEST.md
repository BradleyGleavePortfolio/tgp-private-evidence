# S4 R5 audit B — evidence packet required before artifact attestation

All items must be stamped with head `88287cff47240aa58b5f0fea5da08670f1e87df6`, dirty-path count 0, exit codes, and sha256 of every artifact. Base-good zip results are a comparison, not a negative.

1. Fresh package zip built from 88287cff; file list + per-blob sha256 for blob-level comparison against `git ls-tree -r HEAD` (I will re-run my R4 blob comparison script pattern against it). Zip `6fe9a7be…` from 2bcf1563 is not inheritable (shipping bytes changed).
2. `npm ci` receipt (lockfile hash), then full suite at head (builder expects ≥1739 tests) and the `gates` run, with logs.
3. gitleaks `detect` scan at head (not merely install), report attached.
4. Browser positive proof at head with the loader harness (resolve or explain the `CDP timeout: Browser.getVersion` abort from R4).
5. Proper negative control: an expected-failing artifact/schedule (e.g. predecessor 2bcf1563 zip under the A-01 C1 or P-C schedule) that the same harness reports as FAIL, so the positive is discriminating.
6. Optional but useful: run `execution/audits/s4-r5/b/probes/bound-admission-probe.mjs <root>` inside the canonical environment on candidate (expect exit 0) and predecessor (expect exit 1 on the seven invariant checks listed in REPORT.md §4).

On receipt I will file a separate dated addendum in this directory; REPORT.md revision 1 stays frozen.
