# B/drain pinned PostgreSQL tooling recovery grant

Parent EXEC-CF8FF737, 2026-09-24. Routine local execution under Bradley's active EXECUTE authority, not deployment or a governance change.

## Concrete necessity and scope

The sealed B proof requires `/home/user/pg17/dist` and `/usr/bin/psql`, both absent in this fresh runtime. This blocks only that proof. Minimum closure is the already-recorded C1 tool distribution/client route, without recreating C1/S5 or running their accepted proof.

Sole executor: `b_drain_exact_recovery_and_remainder_mufn6ybc`. Run exactly the prepared `execution/cf8ff737/b-drain/pg-tooling/b-pg-env-recovery.sh`, SHA-256 `bce3ce1552bfb3bc9313eedb007b1e4decf191b0f5edf487b71fa00621f60ad2`. Its sole delta from the accepted C1 driver is the receipt-directory/log-name line.

Acquire the canonical nonblocking heavy slot `execution/test-validation.lock` using the existing driver. Outer bound `timeout -k 30 1500`. Record raw exits, tool identities, hashes and sentinel. Release the slot on exit. First failure or pin mismatch stops; no automatic retry or broadened installation.

- Client: recorded apt `postgresql-client-18` route, psql major at least 17, as prescribed by the inherited recipe.
- Server: PostgreSQL 17.6 Maven distribution, jar SHA-256 `23da5a044b4fb7a5a081a45008c95749c873305328d73f86aefd56922ce1d29d`, inner txz `26fa633461a3340913015503d0783d73a28384110257e2f17d9936bdf8b067c0`.
- Installed postgres SHA-256 `23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a`; initdb `b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a`; retain existing pg_ctl/version/provenance guards.

## Explicit exclusions

This is tooling recovery only. No initdb, cluster, database, migrations, fixture/bootstrap, O-client generation, Jest proof, C1/S5 reconstruction, product/dependency mutation, remote product write or deployment. No real data, credentials, customer action, new spending or external commitment.

The exact B candidate remains head `75a2863bf79a44f84050406d6878ec9a87f4053e`, tree `f4922ca070e887fb7f613ce955b12621b5c33156`. This grant does not replace either independent actual-head/binding attestation.

After tooling succeeds, return its receipt. The single B PG proof is still separately granted only after both independent attestations and tool preconditions are satisfied. Do not wait for that proof grant before performing this already-authorized tooling recovery.
