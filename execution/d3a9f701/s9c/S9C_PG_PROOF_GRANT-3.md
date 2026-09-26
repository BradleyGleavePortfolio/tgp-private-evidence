# S9C-PROOF-3 GRANT — parent d3a9f701, 2026-09-26T04:09:43Z
- Candidate 2e9f6c054b86b749b58a9232c79153a872d9ec18 / tree 02e7b312c7a318e80c1e468854ef2555a10e8873 / sole parent 5407efae (gate-3 rc=0, receipt gate-3/HEAD-2e9f6c054b86.txt, 22 blobs).
- vs gate-2 98133050: only test/rls-g2-s9c.spec.ts differs (5c9abafb → c4b4458d); its delta == fix-r11/r11-fix.diff; every other tree entry identical.
- Binding v3 = v2 with only D, EXPECT_HEAD, EXPECT_TREE, EXPECT_SPEC_BLOB changed (DELTA-from-v2.diff); EXPECT_TESTS=10; fixture byte-identical (ca1e563d…). Runner sha256 46ce7de07c08e3693935e85c27ce1097ae61e619544e0441fe5ad80ea7fce167. Pre-approved by A and B ("R11 fix + binding v3 rule"), all B conditions verified mechanically.
- PROOF-1 (v1, rc70 preconditions) and PROOF-2 (v2, 9/10) remain consumed and preserved.
- ONE run; on failure preserve, classify, never auto-rerun.
- 2026-09-26T04:10:35Z attempt-0 refused rc=71 at preflight: lane runtime/clusters/s9-c existed (PROOF-2 keeps its data dir by design). No PG started, no test run. Preserved at binding/v3/refused-0/; PROOF-2 lane moved (not deleted) to runtime/set-aside/s9c-proof2-cluster. Relaunch 1 under this grant.
