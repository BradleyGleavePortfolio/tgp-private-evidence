# S11-A2 (J09–J11, induction on two hosts) — build grant (EXEC-FA72EFB2)
Grade T4 (proof only; completeness/terminal truth across hosts). Route: Claude Fable 5 builds; independent T4 review after.
Authority: docs/decisions/2026-09-26-s11-journey.md (in the clone) — D-S11-6 (A2 = the ONLY next writer of test/utils/g2-s11-*
and its guard spec; one reviewed change), §3 J09–J11, §5/§6 slice table row S11-A2 (paths: test/scout/s11/journey-induction.pg.spec.ts;
test/fixtures/scout/s11/**; sequential edit of test/utils/g2-s11-* + guard spec). Q-S11-4: J09 is a local synthetic proof only.
Base: create worktree /home/user/workspace/worktrees/fa72-s11a2 (standalone clone like the others: Bradley identity, push
disabled `no_push://disabled-fa72efb2`, node_modules hard-linked `cp -al` from worktrees/fa72-s11a1/node_modules, lefthook
installed) at dda794d7e8bee0482a7ad373795fcc51dcf54bb5 (S11-B r2, in proof; = integration/importer 275e458c + 2 S11-B commits;
S11-B touches no g2-s11 harness file). If S11-B r2 fails its proof the parent re-bases you.
MANDATORY LEARNING from D2 (s10d2/d2_diagnose_fix.md): at this head a run that stages any `clients` row cannot settle
`complete` (legacy clients handoff → ledger target_kind NULL → S9-A bucket f → C-ID unresolved_identities) until S8-D
(owner-reserved). J09 `complete` must use the native-clean shape for BOTH platforms (clients declared + source-signed as empty
enumerations, identities native), exactly as test/scout/s10/s10-unseen.pg.spec.ts r2 (a) does; say so in the spec header.
J10: second platform staged but undeclared → partial/coverage_basis_unknown with observed_unique null for that family (assert
exact reason/conditions so C-ID never masks C-COV). J11: declaration on P1 races the first batch on P2 → declared-then-ingested
XOR declaration_after_ingest, never both (use a deterministic barrier like settle-redrive.pg.spec.ts J13 does; no sleeps as sync).
The second synthetic platform must be data only (fixtures/registry under test/fixtures/scout/s11/**; NEW SOURCE → CORE DIFF = 0:
no src/ change at all). Worker actions: add `declare` and `observe` (+ the S10-B/S10-C service composition the worker needs)
following the D-S11-6 rules; keep everything else as A1 left it; update the guard spec (test/rls-g2-s11... / the harness guard
— find it) so its counts/shape assertions match.
Gates (heavy only under `flock -w 3600 /home/user/workspace/execution/test-validation.lock` AND only while
/home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE exists; pause otherwise): prettier (runtime/tools/prettier-3.9.9),
eslint on touched files, tsc via the commit hook, no-DB jest of touched specs (pg specs must skip cleanly without env), the
guard spec. NO PostgreSQL. ONE commit through hooks (Bradley author/committer, no trailers), no push.
Report s11a2/s11a2_build.md: design, files+LOC, each J case's assertions and why they are guaranteed by code (file:line),
worker action contract, commands+RC, head/tree/blob shas, expected live counts per spec (for the binding), risks.
Rules: execution/fa72efb2/WORKER_RULES.md.
