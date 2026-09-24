# B/drain v5 single real-PostgreSQL proof grant

Parent EXEC-CF8FF737, September 24, 2026. This separately grants one local disposable-database proof of the corrected B candidate. It is not a deployment, a remote product publication, or customer acceptance.

## Preconditions satisfied

- Actual local head: `0d69c7ba7e7d257311cfcb21fa325ebb1ddc1f1c`
  - Tree: `d02f9b124bee52107f8ad2f286f8af611b859fe6`
  - Single parent: the failed v4 head `75a2863bf79a44f84050406d6878ec9a87f4053e`, preserved in history
  - Author and committer: Bradley Gleave
  - Message: exactly `fix(importer): recognize empty trigger column vectors`
- The only change from v4 is the two granted predicate replacements, which use `cardinality(t.tgattr::int2[]) = 0`.
- Genuine Lefthook hooks ran.
- Gates passed: tsc, eslint, prettier and check-r75 all returned rc 0, and Jest passed 42/42.
- Independent reviewer A bound the head and binding, and found it READY with one named precondition. See `b-review-a/B_DRAIN_V5_ACTUAL_HEAD_BINDING_REVIEW_A.md`.
- Independent reviewer B attested the head and binding, found no A or B issues, and found it GRANT-READY conditional on PRE-1. See `b-review-b/B_DRAIN_REVIEW_B_V5_DELTA_AND_HEAD_ATTESTATION.md`.
- The v5 filled runner's SHA-256 is `e895b16e1ef369a6a8a952ae224d5cd202b3da54b74614e14d0d4c3a9b4a0123`.
  - It differs from the v4 filled binding by exactly three lines: EXPECT_HEAD, EXPECT_TREE, and `RT=…/runtime` → `…/runtime-v5`.
  - The parent accepts the RT line as a necessary mechanical change. Without it, the sealed once-only runner would refuse to start or would overwrite the immutable first-run receipts. RT changes only receipt and old-root locations.
  - The spec (`9b31fd18…`), bootstrap (`b4503eef…`), fixture (`4525f01d…`), port, database, bounds and Jest arguments are unchanged.

## Exact execution

The sole executor is `b_drain_exact_recovery_and_remainder_mufn6ybc`. Work in this order:

### 1. PRE-1: preserving rename only

The rename runs immediately before the runner.

Before the rename, record:

- the absence of `postmaster.pid`
- 0 postgres processes
- port 55461 free
- the SHA-256 of `pg-data/global/pg_control`
- the SHA-256 of `pg-data/postgresql.conf`
- `du -s`

Then run exactly:

```text
mv /home/user/pg17/clusters/b-drain /home/user/pg17/clusters/b-drain.v4-failed-75a2863b-20260924T151250Z
```

After the rename, record the same two hashes at the new path. Write all of this to `execution/95633079/s7-b-drain/runtime-v5/PRE1_RENAME_RECEIPT.txt`.

Rules for the rename:

- Nothing may be deleted, started, modified or reused.
- If any precheck fails, or if the target already exists, stop before the runner and report.

### 2. Run the filled runner once, unchanged

```text
timeout -k 30 3600 bash /home/user/workspace/execution/95633079/s7-b-drain/runtime-v5/binding/b-pg-proof.sh
```

The runner's own bounded sequence is authorized. It will:

1. Take the canonical nonblocking lock.
2. Reassert all pins.
3. Create and start only the B disposable PG17 fixture.
4. Recreate the pinned obsolete-writer old-root under `runtime-v5/old-root`, including its sealed old-client generation.
5. Run the approved bootstrap with the 164 old migrations.
6. Assert B identity.
7. Run `test/rls-g2-b-drain.spec.ts` once with the sealed Jest arguments.
8. Stop only the owned fixture, then retain the new datadir and all raw evidence.
9. Verify that no owned process survived and the port is free.
10. Release the slot.

### Prohibited throughout

- Recreating or rerunning S5 or C1
- Reusing the first-run datadir or old-root
- Editing source, spec, harness, fixture or binding
- Reinstalling or copying dependencies, beyond the sealed old-client generation inside the bootstrap
- Hidden retries
- Using live data
- Writing to a remote product repository

The first nonzero exit stops the work. Preserve the failure, sentinel and all output, then report the exact stage and the smallest closure. Do not erase or overwrite `runtime/run/`, the original binding `a64d24de…`, or the renamed first datadir.

## After exit

Notify the parent immediately with:

- the exit code
- the head
- the 19-test result count
- the fixture stop state
- survivor and port observations
- the PRE-1 receipt
- slot release

Both independent reviewers continue their existing reviews to bind this one run and render final findings. There is no new source audit or duplicate heavy proof, and the builder cannot self-accept.

If the run passes, reviewer dispositions come next, followed by parent B acceptance and then R activation under `R_IMPLEMENTATION_DECISIONS_PENDING_B_ACCEPTANCE.md`. If it fails, B stays unaccepted, the failure is diagnosed from its receipts only, and a minimum A/B closure follows. There is no automatic rerun.

C items carried, recorded without gating:

- the open-handle cascade (C-11)
- lint scope limited to the one TS file (C-12)
- the cost of recreating old-root
