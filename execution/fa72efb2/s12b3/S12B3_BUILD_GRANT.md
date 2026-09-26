# S12-B3 mobile run verdict screen (M-bind) — build grant (EXEC-FA72EFB2)
Grade T3 (customer-facing truth of a server verdict; "Do not fabricate server behavior in UI"; "Unknown does NOT silently become
zero"). Route: Claude Opus 5.5 builds; independent audit GPT-6 Sol.
Spec: s12/S12_PILOT_READINESS.md L141: read `GET scout/import/status` for the paired intent; render phase, terminal status and
reason code from server fields only; null/absent → "not known yet", never 0; mount the roster/entities read behind
EXPO_PUBLIC_FF_IMPORT_REVIEW (off by default). Server contract: backend worktrees/fa72-s11d2 (scout import status controller/DTO,
scout-roster.dto.ts incl. roster_bridge_pending ~L192) — decode fail-closed (unknown enum → explicit unknown state, not a crash, not
success). Reuse the landed readiness panel patterns (mobile main a876268c, PR #296: terminal success check, stale-read handling) and
the existing importer API client/types; plain-language copy (roster rows "imported, not yet joined"). No backend change.
Clone: `git clone --no-hardlinks /home/user/workspace/worktrees/fa72-mobile-rdy /home/user/workspace/worktrees/fa72-s12b3`
(standalone), origin → no_push://disabled-fa72efb2, Bradley identity; node_modules `cp -al` from worktrees/fa72-mobile-rdy/node_modules;
base = mobile main a876268c (verify `git ls-remote` of growth-project-mobile main with api_credentials github is not needed — the
parent confirms main = a876268c).
Gates (npm under `flock -w 3600 /home/user/workspace/execution/test-validation.lock` while PROOF_SLOT_FREE exists): tsc, lint, jest of
touched + related suites (full jest if feasible), banned-words test. ONE commit through hooks, Bradley, no trailers, no push.
Report s12b3/s12b3_build.md (screens, state table server-field → UI, decoder, LOC, commands+RC, head/tree, risks).
Rules: execution/fa72efb2/WORKER_RULES.md.
