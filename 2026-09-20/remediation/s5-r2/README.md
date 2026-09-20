# S5 R2: synthetic PostgreSQL E→T/Q0 compatibility proof

Captured 2026-09-20 18:58 UTC. The validation candidate is written and tested; independent R2 audits have not run and no clearance is claimed. No production, hosted or customer action occurred.

## Exact source and recoverability

- Head: `485c67973b56758fb9b8404579f5ddaec87136bd`
- Tree: `2fbf5028413557f99faea3f1de27b1352a4fe8d4`
- Branch: `execute/20260920-s5-g2`
- Product base: #529 `d7404cd4`; bundle prerequisite: public backend main `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`.
- R1 builder head `65b1da27d9dab4f51f5fad6d8a05be8b64e53dde` has the same tree as audit snapshot `785d9022`, not the same commit identity.

Parent verified clean head/tree, author and committer identity, and the bundle. The six changed files versus the product base are validation/test files only; S1 remains the sole schema/migration/generator owner.

[Revision 1](revision-1/) contains final and checkpoint source bundles, current runner, install scripts, all failed/passed logs, findings dispositions and historical checkpoints. `s5-g2-candidate.bundle` SHA-256 is `7b2e2e5ce1d4ebfb547357c799e03a3ad18c205bea58e4c3d70e1c6e49cf9b8d`; verify `SHA256SUMS` from inside the revision directory (it excludes itself).

```sh
git clone https://github.com/BradleyGleavePortfolio/growth-project-backend.git recovered-s5
git -C recovered-s5 bundle verify /path/to/s5-g2-candidate.bundle
git -C recovered-s5 fetch /path/to/s5-g2-candidate.bundle execute/20260920-s5-g2:recovered-s5
git -C recovered-s5 switch recovered-s5
git -C recovered-s5 rev-parse HEAD HEAD^{tree}
```

Generated `old-root-925780e0` and `old-client-925780e0` trees, dependencies, engine binaries and DB data are omitted: the manifest records their recreation from preserved source and the generated-client output-line modification. Reproduction of those recreation instructions in a fresh environment remains unperformed. Use the [archived S1 PG17 recreation instructions](../s1-r2/revision-1/infra/RECREATE_PG17_SYNTHETIC.md) and sibling `lane-pg.sh`; adapt absolute workspace paths before running. Use only the isolated disposable S5 database, never production.

The superseded `run-proof.sh.held-delta` is preserved as `.redacted`, with line 11 replaced to omit its fixture-password assignment. It is historical evidence, not the runnable current script. Current `run-proof.sh` requires the disposable password through `G2_PG17_PASSWORD`. Original logs remain byte-identical; credential-URL scan matches in guard test names are intentional unsafe-target negative fixtures, not production credentials.

## What the logs prove

- `20260920T184713Z`: guard 26/26, representative non-superuser BYPASSRLS `postgres` bootstrap, live 50/50. This run was on `5270e103` plus changes subsequently committed, not on an already committed final head.
- `20260920T185210Z`: confirmation at clean head `485c6797`, exact tree stamped, 4 GB Node heap, bootstrap succeeds, guard 26/26 and live 50/50, `PROOF_EXIT=0`.
- Scope is synthetic populated PG17.6 E→T/Q0 only. Later B/drain→R→N/Q1→C phases, hosted history drift, real serving-role suitability and customer acceptance are not proven.

## Cross-lane constraints requiring disposition

S1 returned a [bounded documentation-only disposition with parent applicability cautions](cross-lane/README.md); both frozen candidates remain unchanged. Directions are not implemented changes.

- Successful E reversed out of band cannot be recovered with `migrate resolve --rolled-back`; P3012 was reproduced. Carry S1's independently derived transactional forward repair and verification semantics.
- The old writer tally includes existing coach/intent/entity-type ledger rows, not just the current batch. Do not describe those totals as per-run completion.
- A paused T transaction expires at Prisma's default ceiling before E's lock timeout; a subsequent drained down can succeed while T fails closed. Drain/fencing must be enforced as a process boundary, not assumed from an in-flight lock.
- PG15 CI/documentation and measured PG17.6 fixture coverage remain distinct. Default CI does not execute this new proof.

Parent retains the #526/C1 ordering and staged-release fencing obligations. These are recorded constraints, not implemented remediation or independent audit verdicts.
