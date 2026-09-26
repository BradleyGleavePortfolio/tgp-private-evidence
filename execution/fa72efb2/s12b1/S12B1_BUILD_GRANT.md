# S12-B1 pilot-coach allowlist — build grant (EXEC-FA72EFB2)
Grade T4 (authorization/tenant exposure of the importer surface in production). Route: Claude Fable 5 builds; GPT-6 Sol reviews.
Spec: s12/S12_PILOT_READINESS.md L139 (+ L165, L203, L216, L377) and finding B1 (flags are global). Default must be SAFE: flags on +
empty/absent allowlist ⇒ nobody gets the surface (fail closed); a caller not on the list gets exactly the existing uniform 404
(R-DARK-1) — no existence leak, no distinguishable error, no timing branch that reveals flag state. Follow the existing pattern
(src/**/community-feature-flag.guard.ts ~L24 and src/common/feature-flag/**); list parsing strict (UUIDs only, trim, reject junk
→ treat as empty + one startup warning, never "allow all"). Cover every route the readiness doc lists (extension/pair/init|session|
current, scout/runs/*, scout/ingest*, scout/runs/observation, scout/import/status, scout/reconstruct/*, roster/entities reads) —
verify the real route set with rg against controllers and FEATURE_GATED_ROUTES; the S8-D ungated unlink routes do not exist yet
(note for D5). No production flag change, no workflow change (S12-B6 is separate), no deploy.
Clone: `git clone --no-hardlinks /home/user/workspace/worktrees/fa72-s11d2 /home/user/workspace/worktrees/fa72-s12b1` (standalone;
NEVER `git worktree add` from repos/*), origin → no_push://disabled-fa72efb2, Bradley identity, node_modules `cp -al` from
worktrees/fa72-s11a1/node_modules, `npx lefthook install`; base aed23289024898cceca7385d3778cd7373b7424d (S11-D r3, landing by FF).
Specs: unit/e2e (no PG unless the existing e2e pattern needs it — then write it live-gated and name the lane): on-list 200 path,
off-list 404 byte-identical to flag-off 404, empty list 404, malformed list 404, flag off 404 regardless of list, every listed route.
Gates under `flock -w 3600 /home/user/workspace/execution/test-validation.lock` while /home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE
exists: prettier, eslint, tsc, jest of touched suites. ONE commit through hooks (Bradley author/committer, no trailers), no push.
Report s12b1/s12b1_build.md: design, route inventory (file:line), LOC prod/test, commands+RC, head/tree, PG lane needs, risks.
Rules: execution/fa72efb2/WORKER_RULES.md.
