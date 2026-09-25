# Offline proof-state recovery

These are exact offline copies of stopped, synthetic disposable proof lanes. Creating the archives did not acquire the test lock, start PostgreSQL, run a test, change a product file or alter any original failure receipt.

## Contents

- **s7l-failed-v2-lane.tar.gz:** retained `clusters/s7l`, including the failed first lifecycle proof's database, configuration, control file and log.
- **s8c-failed-v3-lane.tar.gz:** retained `clusters/s8-c`, including the native-writer proof's bootstrap-refused state.
- **s7l-failed-v3-lane.tar.gz:** retained `proof-v3/clusters/s7l`, including the natural 23-pass/1-fail lifecycle proof's final 172-migration state.
- **s7l-old-clients.tar.gz:** both generated custom-output OLD clients, preserving the exact private runtime modules discussed in the causal reviews.
- **package-runtime-library.js:** exact shared package runtime used by the S7-L worktree, retained for module-provenance comparison.
- **candidate-generated-clients.tar.gz:** each candidate's generated schema copy, index.d.ts and index.js. In particular the S8-C schema copy hashes to `ded50406332707e4fd473a75e0a5407d54eb309085a99edcaaceaa05cb25b249`; the normalization diagnosis remains reproducible without copying all dependencies.
- **Raw PG logs:** separate readable copies of the three lane logs, without modifying the originals.

`MANIFEST.sha256` seals the initial archive batch and `CLIENT_SUPPLEMENT.sha256` seals the generated-client supplement. The parent `../RECOVERY_INDEX.sha256` includes both manifests and this explanation; `CAPTURE_RECEIPT.txt` records stopped-state prerequisites and conf/control hashes. Each archive has a member list.

## Restrictions and restoration

Verify hashes before extracting, inspect member lists, and extract only into a new isolated evidence directory. Archive paths are relative to the old runtime root or workspace; no archive should be unpacked over a live worktree or active cluster.

These stopped databases are historical evidence, not a fresh proof lane. Do not start them, remove old sentinels, infer a test pass from their contents or use them to bypass fresh-lane guards. A new operator must separately grant provisioning and execution for any new candidate; older scripts retain absolute paths and consumed sentinels by design.

Full product source is in the lane-specific Git bundles and patches. Dependency/tool binary installations are not copied wholesale, and their identities remain pinned by the existing setup receipts and binding manifests.
