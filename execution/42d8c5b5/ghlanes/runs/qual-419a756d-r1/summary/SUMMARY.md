# proof-lanes summary

- HEAD: `419a756da4e6eebc28e22b19d0c08d72549f6d4e`
- TREE: `6ce65c1b47b76df72fbcd005d479feec58553a16`
- package-lock sha256: `b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55`
- generated client index.d.ts sha256: `2c819c8a8e2fd4afb59578893122b8e9c406bc1dc7821e643e7ef359c04aa56c`
- migrations at HEAD: 173 (last `20270124000000_scout_run_observation_expand`)
- harness: `609c0d83906a8908ec2f5e2ac6095faf8f3c6a3b` run https://github.com/BradleyGleavePortfolio/growth-project-backend/actions/runs/36349435510

| lane | stage | status | passed/total | expected(static) | skipped | bootstrap | jest s / job script s |
|---|---|---|---|---|---|---|---|
| s11 | rls-g2-s11 | PASS | 6/6 | 6 | 0 | PASS | 42 / 51 |
| s11 | journey-core | PASS | 8/8 | 8 | 0 | PASS | 186 / 196 |
| s11 | readiness | PASS | 6/6 | 6 | 0 | PASS | 79 / 91 |
| s11 | settle-redrive | PASS | 8/8 | 8 | 0 | PASS | 246 / 257 |
| s11 | journey-induction | PASS | 4/4 | 4 | 0 | PASS | 90 / 100 |
| s11 | journey-full | PASS | 6/6 | 6 | 0 | PASS | 94 / 106 |
| s11 | guard | PASS | 95/95 | >=11 | 0 | n/a | 9 / 15 |
| s10b | rls-s10b-s10c | PASS | 32/32 | 32 | 0 | PASS | 199 / 209 |
| s10b | s10-unseen | PASS | 10/10 | 10 | 0 | PASS | 16 / 28 |

- TOTAL s11: 133/133 (expected: 133)
- TOTAL s10b: 42/42 (expected: 42)

**VERDICT: PASS**
