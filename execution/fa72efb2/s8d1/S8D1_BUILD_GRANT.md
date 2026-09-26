# S8-D1 typed `person` handoff (create-only, provenance-verified) — build grant (EXEC-FA72EFB2)
Grade T4 (durable identity provenance + S9 completeness; re-graded by the independent review). Route: Claude Fable 5 builds;
independent review GPT-6 Sol; parent runs PG proofs. Hand-written production LOC estimate 200–300 (stop and report if > 1,000).
Contract: docs/decisions/2026-09-26-s8d-person-link.md §5.1 steps 1–4 + named specs, at /home/user/workspace/worktrees/fa72-s8d
fa72/s8d 7a7d18de (the doc is in review round 3 for unrelated D3/D4b text; §5.1 is closed — independent review s8d/s8d_review.md
Round 2: "B4 closed for D1", "S8-D1 GO"). Owner decision OWNER_DECISION_S8D_2026-09-26.md (D-S8-2 (a): no User minted; email never
an identity key). D1 depends on no owner OQ; it adds NO migration (the S11 lane pins 173 migrations — keep it so).
Clone: create /home/user/workspace/worktrees/fa72-s8d1 with `git clone --no-hardlinks /home/user/workspace/worktrees/fa72-s11d2`
(standalone; NEVER `git worktree add` from repos/*), `git remote set-url origin no_push://disabled-fa72efb2`, Bradley identity,
node_modules `cp -al` from worktrees/fa72-s11a1/node_modules, lefthook installed; base = fa72/s11d-r2 38d0d366730331e4edf19a14cda8247435b89431
(S11-D candidate on integration/importer 54be96f1; S11-D is in proof — parent re-bases you if it changes).
Scope: src/scout/reconstruct/families.ts (clientsFamily.persist → S8-C writer shape: findProvenance / verify / adopt pre-D1 /
create; typed result), src/scout/reconciliation/facts.service.ts readPersons (Deleted → removed), any S9 fixture/type the typed kind
needs, and specs. Honesty sweep (mandatory): every landed spec whose expectation changes because roster-bearing runs can now settle
`complete` — at least test/scout/s10/s10-unseen.pg.spec.ts case (h) (D2) and test/scout/s11/journey-full.pg.spec.ts leg B (S11-D)
— update ONLY the assertions the contract flips, state why in a comment, and keep `roster_bridge_pending` behaviour exactly as the
code now does (retiring it is S8-D2, not you). In journey-full, J20's full-range src-commit coverage check is anchored at HEAD and
would fail on your src commit: re-scope it to end at the S11 range end (the last S11 slice commit) with a clear comment — do not
weaken the per-commit slug/gate checks. Inventory other pg/unit specs asserting clients → unresolved/partial (rg) and list them.
Named D1 specs (no-DB unit where possible; pg specs for DB behaviour, live-gated like their lane): edited display_name survives
replay; Deleted Person → native_target_removed, stays Deleted, no new Person; Person of another coach / mismatched provenance
target owner → identity_conflict; pre-D1 Person adopted once then already_present; historical NULL-kind ledgers stay bucket f;
five repeated runs → one provenance row, identical outcomes; run `complete` only when every family is complete.
Gates (heavy only under `flock -w 3600 /home/user/workspace/execution/test-validation.lock` while
/home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE exists): prettier, eslint, tsc, no-DB jest of touched specs + src/scout
unit suites. NO PostgreSQL. Commit(s) through hooks (Bradley author/committer, no trailers), no push.
Report s8d1/s8d1_build.md: design, file:line, LOC (production vs test), spec inventory, which PG lanes/specs the parent must run
to prove it (with expected counts), commands+RC, head/tree, risks A/B/C. Rules: execution/fa72efb2/WORKER_RULES.md.
