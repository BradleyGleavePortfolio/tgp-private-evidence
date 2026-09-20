# S2 remediation and separate integration preview

Received 2026-09-20 17:59 UTC. Candidate head `0b05fcf5352287109ac88ed2ba3682e441e3a076`, tree `fba0a9f06127979005b70ca3da80584a1e2ce10c`, public base `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`. Author and committer are Bradley Gleave. The original R1 and held pre-override commits remain preserved.

## Complete returned packet

`revision-1/` contains the original returned S2 directory and `external-tmp/`, which captures all thirteen temporary files named in the builder manifest. Reports, source/checkpoint/held bundles, test logs, action-pin verification, SBOM, runtime-stage replay script/log and composition-conflict evidence are included. SHA256SUMS covers all captured files other than itself; all checks passed before publication.

`revision-2/` preserves the corrected builder reports and unchanged source/logs. The 115-test run preceded the final commit; the 394-test run preceded its preview-parent commit. Original logs were not retrospectively stamped. The stray nested worktree was identified as a disposable clean checkout and removed by the builder; parent subsequently observed a clean S2 status. External temporary evidence remains preserved in revision 1.

The candidate bundle `s2-delivery-r2-final.bundle` requires only public base `c23b9d9f`. SHA-256: `6043baf58d6ba1c85846fdac7b43c3388754b30966e03f8aca222da95304831e`.

The separate preview is head `6b85395fd60a3a6fc91314f32f91a7cd2985b96c`, tree `801b5d3a40cf6b478c5a8f7636bf1e53dc130389`. Its bundle requires three heads: S2 `0b05fcf5`, S3 `5c7b42b3`, and S1 `90a66475`. Restore those three published candidate bundles first, then verify/import `s2-compose-preview.bundle`; all are available in this remediation archive. The preview is **not** S2's audit candidate.

## Evidence scope and unresolved limits

- The original focused log records 115 passing tests on a working tree before commit `0b05fcf5`, not an execution at that exact committed head. Its applicability is builder-attested and not self-stamped. A new bounded, contemporaneously identity-stamped focused run was requested on the unchanged final head; result pending.
- The 394-test composition run was on the working tree later committed as preview parent `367c309401eebee03dea2ca5f194ffc417d16e28`, before the S1 merge. **The final preview `6b85395f` was not rerun.** No automatic evidence inheritance is asserted.
- The untracked nested worktree issue at original receipt was resolved as described above; no candidate source changed.
- Isolated host replay of Docker runtime-stage commands is control evidence, **not an image build**. No changed hosted workflow executed, no production settings changed, no deployment/enablement occurred.
- Source findings are builder-dispositioned. Independent R2 review and final integrated evidence remain required.

State: written, committed, locally focused-tested with the provenance limit above, privately preserved; **not R2 audit-cleared, merged, deployed, enabled or customer-accepted**.
