# proof-lanes summary — mode PARTIAL

- target HEAD: `419a756da4e6eebc28e22b19d0c08d72549f6d4e`  TREE: `6ce65c1b47b76df72fbcd005d479feec58553a16`
- harness_sha: `0c97a84f1ca833bacdd7c20c2cfabf20430504a9`  run commit: `6ca69429b122718149bbfb69e2cebf03ca984b87`
- package-lock sha256: `b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55`  client index.d.ts: `2c819c8a8e2fd4afb59578893122b8e9c406bc1dc7821e643e7ef359c04aa56c`
- migrations at HEAD: 173 (last `20270124000000_scout_run_observation_expand`), exact applied set checked in every live job
- jobs: preflight=success run=success
- run: https://github.com/BradleyGleavePortfolio/growth-project-backend/actions/runs/36351497200

| lane | stage | serial lane status | passed/total | expected(static) | skipped | per-stage fast signal | jest s |
|---|---|---|---|---|---|---|---|
| s11 | guard | PASS | 95/95 | >=11 | 0 | PASS 95/95 | 10 |
| **s11** | **TOTAL** | | **95/95** | | | | lane job 16 s |
| s10b | s10-unseen | PASS | 10/10 | 10 | 0 | PASS 10/10 | 17 |
| **s10b** | **TOTAL** | | **10/10** | | | | lane job 27 s |

Pins checked: 1
- EXPECT_guard=95 got 95

**VERDICT: PARTIAL (diagnostic subset; NOT a proof; aggregate exits 78 by design)**
