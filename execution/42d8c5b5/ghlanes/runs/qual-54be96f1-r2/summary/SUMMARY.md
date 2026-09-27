# proof-lanes summary

- HEAD: `54be96f18c314cae35d1e5d3000af9f06d693d81`
- TREE: `435fec782672214c7e8e81b2eb91f8f9266331b4`
- package-lock sha256: `b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55`
- generated client index.d.ts sha256: `2c819c8a8e2fd4afb59578893122b8e9c406bc1dc7821e643e7ef359c04aa56c`
- migrations at HEAD: 173 (last `20270124000000_scout_run_observation_expand`)
- harness: `ad0267d24393f9a0432f1260c6c0bf433f58a0e1` run https://github.com/BradleyGleavePortfolio/growth-project-backend/actions/runs/36349189355

| lane | stage | status | passed/total | expected(static) | skipped | bootstrap | jest s / job script s |
|---|---|---|---|---|---|---|---|
| s11 | rls-g2-s11 | PASS | 6/6 | 6 | 0 | PASS | 54 / 64 |
| s11 | journey-core | PASS | 8/8 | 8 | 0 | PASS | 136 / 145 |
| s11 | readiness | PASS | 6/6 | 6 | 0 | PASS | 75 / 85 |
| s11 | settle-redrive | PASS | 8/8 | 8 | 0 | PASS | 235 / 246 |
| s11 | journey-induction | PASS | 4/4 | 4 | 0 | PASS | 86 / 97 |
| s11 | guard | PASS | 95/95 | >=11 | 0 | n/a | 9 / 15 |
| s10b | rls-s10b-s10c | PASS | 32/32 | 32 | 0 | PASS | 194 / 205 |
| s10b | s10-unseen | PASS | 9/9 | 9 | 0 | PASS | 16 / 28 |
| s11 | journey-full | SKIP_ABSENT_AT_HEAD | | | | | |

- TOTAL s11: 127/127 (expected: 127)
- TOTAL s10b: 41/41 (expected: 41)

**VERDICT: PASS**
