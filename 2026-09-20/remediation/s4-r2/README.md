# S4 R2: extension source, package and loader proof

Captured 2026-09-20 18:20 UTC. Remediation is written and tested; independent R2 audit is pending. Nothing here authorizes merge, deployment, enablement or claims native customer import completion.

## Exact candidate

- Head: `c5a5ae12c5b3c3e32a4601c99319ad7c0d980057`
- Tree: `5f3c8f6a729427ce6c23bcb1ba18dc7b986b7447`
- Branch: `execute/20260920-s4-importer`
- Public main: `0111be661922234d670bbf23e23d270eec1b4a4e`
- Preserved R1: `a6d885a10d7dbc64e99961f44e0f6fe7bea5dfba`, not cleared.

The R2 commits tighten legacy command sender checks, persist only error origins instead of full URLs, and repair the browser-proof harness. Parent verified the final worktree clean and the bundle valid; no public source branch was pushed.

## Recovery and package identity

[Revision 1](revision-1/) preserves the complete returned execution directory: source bundles, both old and new shipping packages, inventories, scripts, held patch, reports and passed/failed logs. Verify `SHA256SUMS` from inside that directory before use; it excludes itself.

The R2 bundle `s4-importer-c5a5ae1.bundle` has SHA-256 `f99feba3b4016159cb7ed9351a0f05d5e41f235a6ebf0210e23b170791d97ca9`. Actual `git bundle verify` reports complete history, so it has no missing prerequisite; the builder manifest's public-base description is conservative, not a private dependency.

```sh
git clone -b execute/20260920-s4-importer /path/to/s4-importer-c5a5ae1.bundle recovered-s4
git -C recovered-s4 rev-parse HEAD HEAD^{tree}
```

The final package is `artifacts/tgp-importer-extension-0.3.0-rc.1.c5a5ae1.zip`: 36 files, 209725 bytes, SHA-256 `e2ee1f5cc09094f3485c07db866d02f73f2a086d5a4d22e362da5e904b2e1e98`. Its hash differs from R1 because shipping `background.js` changed; the unsuffixed zip is the preserved old package, not the R2 deliverable.

## Applicable proof and limits

- `logs/full-gates.c5a5ae1.log` stamps clean head/tree and toolchain: 61 Vitest files, 1678 tests passed; lint, type-check, formatting and gates exit 0.
- `logs/browser-proof.r2c.log` and both corresponding JSON files stamp the same candidate and package: positive 11/11 pass, negative-control defect detected. Failed R1 and R2 attempts remain preserved.
- This is synthetic loader/package evidence on Linux headless Chrome 147, not native import completion or customer acceptance. Resolver restrictions and observed network hosts are not a proof of absolute network isolation; do not inherit the builder manifest's categorical no-egress sentence.
- `R2-CHECKPOINT.md`, R1 and held reports are historical. Final report and contemporaneous logs supersede their pending-proof status; use log timestamps for execution timing.
- `debugger` and optional host permissions remain unchanged and require consequence-based disposition at review. Package/browser proof is not yet CI-enforced; other platforms and store packaging remain unproven.

Two independent final-candidate R2 attestations are still required. Preserve the R1 reports as historical evidence; they do not clear the changed shipping package.
