# Post-C sequencing (parent ~00:10Z Sep 25)
C accepted at 1b6cc661; landing PR #536.
- S8-A: rebase its three commits onto 1b6cc661 (ordinary rebase, Bradley committer, hooks). If any S8-A file conflicts or changes content, independent delta re-check of that hunk only; otherwise record trees-equal-by-path and land via merge PR after #536.
- S8-B: phase 2 now on 1b6cc661: schema hunk (new model + ledger target_kind only), S8-B-only generate, pins OLD_HEAD=1b6cc661/history 170, gates, hooked commit, binding fill, export; then dual T4 attestation and a single PG grant. Migration 20270122.
- S7-L: L1 commit + L2 service/routes on 1b6cc661 in parallel (source + unit). Before its PG run, rebase onto the accepted S8-B head if S8-B is accepted by then (OLD_HEAD/history re-pinned); otherwise run on C and S8-B re-pins instead. schema.prisma hunks are model-disjoint; the second lander does the mechanical rebase.
- S8-C: after S8-A (landed) + S8-B (accepted). UX E2/M-bind: after S7-L2.
