# S2 remediation and separate integration preview

Received 2026-09-20 17:59 UTC. Candidate head `0b05fcf5352287109ac88ed2ba3682e441e3a076`, tree `fba0a9f06127979005b70ca3da80584a1e2ce10c`, public base `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`. Author and committer are Bradley Gleave. The original R1 and held pre-override commits remain preserved.

## Complete returned packet

`revision-1/` contains the original returned S2 directory and `external-tmp/`, which captures all thirteen temporary files named in the builder manifest. Reports, source/checkpoint/held bundles, test logs, action-pin verification, SBOM, runtime-stage replay script/log and composition-conflict evidence are included. SHA256SUMS covers all captured files other than itself; all checks passed before publication.

The candidate bundle `s2-delivery-r2-final.bundle` requires only public base `c23b9d9f`. SHA-256: `6043baf58d6ba1c85846fdac7b43c3388754b30966e03f8aca222da95304831e`.

The separate preview is head `6b85395fd60a3a6fc91314f32f91a7cd2985b96c`, tree `801b5d3a40cf6b478c5a8f7636bf1e53dc130389`. Its bundle requires three heads: S2 `0b05fcf5`, S3 `5c7b42b3`, and S1 `90a66475`. Restore those three published candidate bundles first, then verify/import `s2-compose-preview.bundle`; all are available in this remediation archive. The preview is **not** S2's audit candidate.

## Evidence scope and unresolved limits

- The focused log records 115 passing tests. Binding to S2 head `0b05fcf5` is builder-attested; the captured log itself does not carry a contemporaneous head/tree header.
- The 394-test composition run was on preview parent `367c309401eebee03dea2ca5f194ffc417d16e28`, before the S1 merge. The builder's detailed REPORT makes this distinction, although the initial mail/checkpoint overstated applicability. **The final preview `6b85395f` was not rerun.** No automatic evidence inheritance is asserted.
- The S2 worktree had an untracked `worktrees/s2-compose-preview/` entry at receipt; identification and preservation disposition were requested. No clean-worktree claim is made.
- Isolated host replay of Docker runtime-stage commands is control evidence, **not an image build**. No changed hosted workflow executed, no production settings changed, no deployment/enablement occurred.
- Source findings are builder-dispositioned. Independent R2 review and final integrated evidence remain required.

State: written, committed, locally focused-tested with the provenance limit above, privately preserved; **not R2 audit-cleared, merged, deployed, enabled or customer-accepted**.
