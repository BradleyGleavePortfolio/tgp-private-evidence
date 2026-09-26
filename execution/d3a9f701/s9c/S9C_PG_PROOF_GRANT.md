# S9C-PROOF-1 GRANT — parent d3a9f701, 2026-09-26T03:36:57Z
- Candidate: 98133050bb62cc8a506badef67ccfcc317601db1 (tree 7756a39f, parent 5407efae), S9-C gate-2 rc=0 (gate/HEAD-98133050bb62.txt sha256 0c72c05d…01ea, 22 blob lines).
- Reviewed bytes == committed bytes: all 22 paths sha256+mode equal the freeze-2 pins (lifecycle.service.spec.ts re-pinned 8e375e75 after the R75 delta). Reviews: A GO + B GO on freeze-2 and on delta 2.
- Binding v1 s9c-pg-proof.sh filled (sha256 9f2c20dcf4c945c6639d3d20f6ca9bdd641da1709cbfb25e1676f7003ac3b277; template preserved): EXPECT_HEAD/TREE + 6 harness blobs from the gate receipt; EXPECT_RECONSTRUCT_DELTA = native-rules.ts (parent-granted additive export, both reviews GO). Fixture sha ca1e563d unchanged.
- Slot free at grant: lslocks 0, postgres 0, port 55646 free. Lane: port 55646, db g2_s9c_disposable, admin s9c_super, runtime/clusters/s9-c.
- ONE run. On failure: preserve, classify A/B/C from jest.log; never auto-rerun.
