# TGP remediation and durable recovery

Bradley authorized S1–S5 remediation after all twelve R1 reports returned. S1/S2/S4 remediation and S3 proof have returned, with independent attestations pending; S5 is active. S6 remains held. All six R1 candidates were **NOT CLEARED**; publication is preservation, not approval, merge, deployment, enablement or customer acceptance.

## Current checkpoint

S3 subsequently returned its unchanged-head completion packet: [S3 evidence completion](s3-evidence-completion/README.md). Independent re-attestation is pending; this does not clear R1.

S1 returned a new remediation head `90a66475`: [S1 R2 candidate recovery](s1-r2/README.md), including synthetic 68/0 proof and the entire recovery packet. Independent R2 audit is pending.

S2 returned head `0b05fcf5`: [S2 R2 candidate and separate composition preview](s2-r2/README.md), including the 115-test log, all bundles and outside temporary evidence. The 394-test preview-parent proof does not attest the final S1/S2/S3 combined preview. Image and hosted workflow proof remain missing.

S4 returned head `c5a5ae12`: [S4 R2 source, package and loader proof](s4-r2/README.md), including 1678 passing tests, positive/negative-control browser proof and changed package hash `e2ee1f5c…`. Loader proof is not native import completion; independent R2 audits remain pending.

`checkpoint-1724/` captures available S1–S3 execution evidence at approximately 2026-09-20 17:24–17:26 UTC, before resumed remediation completes. Files retain their original claims and limitations, including stale historical milestone text; current findings and applicability are in `../audits/`. Capture does not retroactively validate a log or document.

- S1 source: `s1-database/bundles/s1-database-R1-620b47f.bundle`, frozen head `620b47fc8517fa5e5950c5b673baf8b002f5c78a`.
- S2 source: `s2-delivery/s2-delivery-r1.bundle`, frozen head `b801a776558d18acea2d03f19029f0ea85ffca39`. Held pre-override work survives in `s2-post-r1-held.bundle`, head `cb0bc91094fcad322b54a72c4ff317313e052c18`; it was not the R1 audit candidate.
- S3 source: `s3-backend/s3-backend-5c7b42b3.bundle`, frozen head `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06`. The duplicate 64 MB full-history bundle is omitted; the incremental bundle preserves the same candidate and requires only the public base below.
- Captured reports, scripts and logs include S2's available `/tmp` test logs. Synthetic localhost credentials are disposable fixture values, not production credentials. No database contents or production environment values are included.
- This historical checkpoint predates final packets linked above; it is not a claim that ongoing S5 work is fully captured.

## Restore source without the original sandbox

Clone `https://github.com/BradleyGleavePortfolio/growth-project-backend.git` and fetch its history. All three lane bundles require public base `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`, not an unpushed private prerequisite.

From that clone:

```sh
git cat-file -e c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7^{commit}
git bundle verify /path/to/lane.bundle
git bundle list-heads /path/to/lane.bundle
git fetch /path/to/lane.bundle '<listed-ref>:refs/heads/recovered-lane'
git worktree add ../recovered-lane recovered-lane
```

Verify SHA256SUMS from inside the checkpoint directory before importing. Preserve the original frozen heads; create new remediation branches. Archived shell scripts include original absolute paths and may require path adaptation; inspect before execution. Never run synthetic database teardown against a production endpoint.

## Ownership and publication policy

S1 alone owns schema/migration/generator changes; S2 owns delivery workflow composition; S3 owns backend reliability source and proof. Parent alone updates this archive and the [current handoff](https://github.com/BradleyGleavePortfolio/tgp-agent-context/blob/main/LAST_OPERATOR_STATE.md).

S4 has returned its new R2 candidate above. S5 resumed validation-only G2 proof from builder head `65b1da27d9dab4f51f5fad6d8a05be8b64e53dde` (same tree as its R1 audit snapshot). Held patches and prior failed evidence must be preserved, not silently substituted into old attestations. S5 routes schema/product defects to S1; it does not become a second migration owner.

The product repository is public. Unresolved security findings and associated candidate source are preserved here privately rather than disclosed publicly. Completed fixer work must include recoverable commits, scripts, logs, dispositions, checksums and exact head/tree identities; independently audited/merged/deployed states remain separate.
