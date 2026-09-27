# proof-lanes summary — mode FULL

- target HEAD: `419a756da4e6eebc28e22b19d0c08d72549f6d4e`  TREE: `6ce65c1b47b76df72fbcd005d479feec58553a16`
- harness_sha: `0c97a84f1ca833bacdd7c20c2cfabf20430504a9`  run commit: `63f8af92d3a3821758e28df0e063a5f63ecf17a5`
- package-lock sha256: `b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55`  client index.d.ts: `2c819c8a8e2fd4afb59578893122b8e9c406bc1dc7821e643e7ef359c04aa56c`
- migrations at HEAD: 173 (last `20270124000000_scout_run_observation_expand`), exact applied set checked in every live job
- jobs: preflight=success run=success
- run: https://github.com/BradleyGleavePortfolio/growth-project-backend/actions/runs/36351463274

| lane | stage | serial lane status | passed/total | expected(static) | skipped | per-stage fast signal | jest s |
|---|---|---|---|---|---|---|---|
| s11 | rls-g2-s11 | PASS | 6/6 | 6 | 0 | PASS 6/6 | 54 |
| s11 | journey-core | PASS | 8/8 | 8 | 0 | PASS 8/8 | 187 |
| s11 | readiness | PASS | 6/6 | 6 | 0 | PASS 6/6 | 80 |
| s11 | settle-redrive | PASS | 8/8 | 8 | 0 | PASS 8/8 | 238 |
| s11 | journey-induction | PASS | 4/4 | 4 | 0 | PASS 4/4 | 83 |
| s11 | journey-full | PASS | 6/6 | 6 | 0 | PASS 6/6 | 93 |
| s11 | guard | PASS | 95/95 | >=11 | 0 | PASS 95/95 | 9 |
| **s11** | **TOTAL** | | **133/133** | | | | lane job 755 s |
| s10b | rls-s10b-s10c | PASS | 32/32 | 32 | 0 | PASS 32/32 | 146 |
| s10b | s10-unseen | PASS | 10/10 | 10 | 0 | PASS 10/10 | 12 |
| **s10b** | **TOTAL** | | **42/42** | | | | lane job 168 s |

Pins checked: 3
- EXPECT_guard=95 got 95
- EXPECT_TOTAL_s11=133 got 133
- EXPECT_TOTAL_s10b=42 got 42

**VERDICT: PASS**
