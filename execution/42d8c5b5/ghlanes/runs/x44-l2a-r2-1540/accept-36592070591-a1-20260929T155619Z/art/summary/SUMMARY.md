# proof-lanes summary — mode FULL

- target HEAD: `f6dcee55eeece788028d9092c6379c21ff60048d`  TREE: `1261c3d791cbd26749d34c65ff712bfa908f4532`
- harness_sha: `0c97a84f1ca833bacdd7c20c2cfabf20430504a9`  run commit: `93a111fc2384e63b43fc2ec8346d00860a82b787`
- package-lock sha256: `b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55`  client index.d.ts: `2c819c8a8e2fd4afb59578893122b8e9c406bc1dc7821e643e7ef359c04aa56c`
- migrations at HEAD: 173 (last `20270124000000_scout_run_observation_expand`), exact applied set checked in every live job
- jobs: preflight=success run=success
- run: https://github.com/BradleyGleavePortfolio/growth-project-backend/actions/runs/36592070591

| lane | stage | serial lane status | passed/total | expected(static) | skipped | per-stage fast signal | jest s |
|---|---|---|---|---|---|---|---|
| s11 | rls-g2-s11 | PASS | 6/6 | 6 | 0 | PASS 6/6 | 51 |
| s11 | journey-core | PASS | 8/8 | 8 | 0 | PASS 8/8 | 184 |
| s11 | readiness | PASS | 6/6 | 6 | 0 | PASS 6/6 | 77 |
| s11 | settle-redrive | PASS | 8/8 | 8 | 0 | PASS 8/8 | 231 |
| s11 | journey-induction | PASS | 4/4 | 4 | 0 | PASS 4/4 | 82 |
| s11 | journey-full | PASS | 6/6 | 6 | 0 | PASS 6/6 | 90 |
| s11 | guard | PASS | 95/95 | >=11 | 0 | PASS 95/95 | 9 |
| **s11** | **TOTAL** | | **133/133** | | | | lane job 734 s |
| s10b | rls-s10b-s10c | PASS | 32/32 | 32 | 0 | PASS 32/32 | 132 |
| s10b | s10-unseen | PASS | 10/10 | 10 | 0 | PASS 10/10 | 11 |
| **s10b** | **TOTAL** | | **42/42** | | | | lane job 150 s |

Pins checked: 3
- EXPECT_guard=95 got 95
- EXPECT_TOTAL_s11=133 got 133
- EXPECT_TOTAL_s10b=42 got 42

**VERDICT: PASS**
