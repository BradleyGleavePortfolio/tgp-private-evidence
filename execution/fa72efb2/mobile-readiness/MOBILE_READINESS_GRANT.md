# UX-03/04 mobile readiness consumer (S11 M-bind, J6 render) — build grant (EXEC-FA72EFB2)

Grade T2 (meaningful user behavior inside the established mobile import architecture, flag-gated, reversible; honesty
rules below are the consequence driver). Requested route: Claude Sonnet 5.0. One independent audit follows.
Sole mobile writer for the pairing/status surface while this grant is open.

Clone: /home/user/workspace/worktrees/fa72-mobile-rdy (standalone clone of mobile main affc2818, branch
fa72/mobile-readiness, Bradley identity, push disabled). Do NOT push, open PRs, or touch backend/extension repos.

Server contract (defined, not yet landed — landing of this mobile work waits for backend S11-C to land):
backend PR #560, head 7fdcbc044dba1747d0db2f2750ced951f3b6b752, `docs/contracts/importer-openapi.json` schemas
`PairReadiness` and `PairSessionResult.properties.readiness` (read the bytes with
`git -C /home/user/workspace/worktrees/fa72-s11c show 7fdcbc04:docs/contracts/importer-openapi.json`, and the DTO/service
at the same commit, src/extension-pair/extension-pair.{dto,service}.ts). Returned only by `pair/session` and `pair/current`:
  readiness?: { run: 'none'|'open'|'terminal'; source_declared: boolean; declared_platforms: number|null }
Decision record semantics (D-S11-5, backend docs/decisions/2026-09-26-s11-journey.md):
- block absent => NOT KNOWN; never render as "no"/"not ready"/zero.
- source_declared true may read "declaration received"; NEVER "source authorized", "source ready", "connected",
  "verified". Real source authorization stays unknown (owner-reserved verifier).
- run 'terminal' carries no detail: terminal status/reasons stay on the existing import status read; do not invent them.
- declared_platforms is a count only (null when run is 'none'); no platform names.

Build (reuse existing code; smallest coherent change):
1. Types/parsing in src/api/extensionPairApi.ts (+ types): strict parse of the optional block; any malformed/unknown
   value => treat the block as absent (unknown), never coerce to false/0, never throw away the rest of the response.
2. Contract mirror: add a new fixture of the S11-C pair surface (keep the existing c1PairSurface fixture) and extend
   src/types/__tests__/extensionImport.contract.test.ts so drift from the 7fdcbc04 artifact fails.
3. useExtensionPairing exposes readiness (unknown when absent); ExtensionPairingPanel renders a neutral readiness row
   only when known, with copy that satisfies the rules above; accessible labels; no new feature flag and no flag default
   change (stays behind the existing import flags).
4. Tests: parser (present/absent/malformed/unknown enum), hook, panel render for each known state + absent, and a
   banned-words assertion (authorized|ready|connected|verified) on every readiness string.
Heavy commands (npm ci, jest, tsc, eslint) only as
`flock -w 3600 /home/user/workspace/execution/test-validation.lock bash -c '...'` and never while
/home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE is absent. npm cache: export
npm_config_cache=/home/user/workspace/execution/fa72efb2/runtime/npm-cache. Scope tests to the touched areas plus the
full `npm test` once at the end.
Commit locally (Bradley author+committer, no AI trailers, hooks on). Report:
execution/fa72efb2/mobile-readiness/builder_summary.md (files, LOC, commands+RC, head sha, open questions).
Rules: execution/fa72efb2/WORKER_RULES.md.
