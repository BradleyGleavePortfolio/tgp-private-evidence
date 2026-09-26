# S11-D (J19 full journey, J20 core diff) — build grant (EXEC-FA72EFB2)
Grade T2 (proof composition, spec cases only; per docs/decisions/2026-09-26-s11-journey.md slice table). Route: Claude Sonnet 5.
Authority: that decision record §3 J19/J20, D-S11-6 ("S11-B, S11-C and S11-D add spec cases only … A case needing a new worker
action stops and is re-graded"), §4 invariants. Allowed paths: test/scout/s11/journey-full.pg.spec.ts (new) only; the J20 check may
live in that spec or a no-DB spec under test/scout/s11/ — no harness (test/utils/g2-s11*) edits, no src/prisma edits.
Base: create worktree /home/user/workspace/worktrees/fa72-s11d (standalone, Bradley identity, push disabled
`no_push://disabled-fa72efb2`, node_modules `cp -al` from worktrees/fa72-s11a1/node_modules, lefthook installed) at
03e7a2344ef95b019c751983527bbc9f78200921 (S11-A2 candidate on integration/importer dda794d7; A2 is in review/proof — the parent
re-bases you if it changes). Use A2's harness actions (induction.*), A1's pair actions, S11-B's re-drive pattern, S11-C readiness.
MANDATORY: at this head a run that stages any `clients` row cannot settle `complete` until S8-D (owner-decided, not yet built;
s10d2/d2_diagnose_fix.md). J19 must stay honest: J01 → J09 (native-clean, `complete`) → J12 (interrupt + replayed re-drive gives the
identical verdict) → J17 (readiness terminal) on two processes; the final native roster read (importer-G, scout-roster.service.ts)
must list exactly the reconstructed identities — for the native-clean run that is the exact empty roster (assert it is empty
because none were staged, not because of a failure) PLUS a second, clearly separated roster-bearing leg that settles
`partial/unresolved_identities` with qualifier `roster_bridge_pending` and whose roster read lists exactly the staged people as
imported, not yet joined. State in the header that the roster-bearing leg flips to `complete` when S8-D lands (owner decision
OWNER_DECISION_S8D_2026-09-26.md). J20: `rg -F -l` for every source slug (incl. s10_unseen and the A2 second source) over each S11
`src` hunk (git diff 3db615c0^..HEAD -- src, or the S11 slice commits — define exactly) finds none, and scripts/s10-core-diff-gate.sh
passes against its pinned B — implement as a deterministic check with a clear failure message.
Gates (heavy only under `flock -w 3600 /home/user/workspace/execution/test-validation.lock` while
/home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE exists): prettier, eslint, tsc via hook, no-DB jest (pg spec skips cleanly),
guard spec still 95. NO PostgreSQL. ONE commit through hooks (Bradley author/committer, no trailers), no push.
Report s11d/s11d_build.md: design, each assertion's code guarantee (file:line), commands+RC, head/tree/blobs, expected live count,
risks. Rules: execution/fa72efb2/WORKER_RULES.md.
