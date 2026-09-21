# S4 R4 plan — duplicate-refresh admission and obsolete-caller session clearing

Builder: S4 R4 fixer (requested Claude Fable 5 / High; actual verifiable identity: API-hosted AI subagent, model/version not exposed at runtime). Not an auditor; no self-clearance.

## Tier header

- Tier: T4
- Why: changes authentication ownership (which caller may destroy the local session) and the refresh coalescer that guards single-use refresh-token presentation.
- T4 trigger scan: session trust, credentials/token handling, destructive local token cleanup.
- T3 trigger scan: concurrency/state authority inside one module + its worker callers (already T4).
- Bounded T1: NO (privilege, concurrency, persistent session state).
- Canonical builder: Claude Fable 5 / High. Parent owner: GPT 6 Astra.
- Acceptance evidence: focused regressions mirroring the archived R3 A/B probes (A-01 pending-establish schedule, A-02 stale-caller replacement schedule with success/rejection/timeout variants, unchanged-current-session auth-loss control), full Vitest, gates, exact-head package, loader positive/control on changed shipping bytes, two independent final-head attestations.
- Promotion triggers: any need to change message contracts, manifest/permissions, backend behaviour, or to hold the state lock across network I/O.

## Base and ownership

- Frozen base: `84471e99b278e964f7cb3f6bf9c78491064c41b7` (tree `f31a978034d0aa8a2c39615ade5ec0255a19b1d0`), cloned from `initialization/recovered/s4-r3-84471e99` (unchanged) into `worktrees/s4-r4`, branch `execute/20260921-s4-r4`. Local `main` ref added at public main `0111be661922234d670bbf23e23d270eec1b4a4e` so the repository's own diff-scoped gates resolve their base. No remote configured (no push possible).
- Sole writer: `worktrees/s4-r4`, `execution/s4-r4`.
- This is a **reimplementation** of the unpreserved R4 delta from the archived R3 audit findings (S4-R3-A-01, S4-R3-A-02, S4-R3B-01). No historical recovery search.

## Findings addressed

| ID | Root cause at 84471e99 | Fix |
|---|---|---|
| S4-R3-A-01 / S4-R3B-01 | `establishSession`/`clearTokens` detach the coalescer slot unconditionally; a refresh admitted while a transition holds the lock has not snapshotted yet, will snapshot the NEW state, but is detached — a second caller starts a parallel refresh with the same refresh token. | Slot records the epoch its run snapshotted under (`null` until the snapshot, written inside the lock). Transitions detach only runs whose recorded epoch is now stale; a pending run stays joinable. Slot vacated in `finally` only by its owner (kept). |
| S4-R3-A-02 | `makeSender` treats every `null` from `refreshAccessToken` as authority for unconditional `clearTokens()` + `onAuthLost()`; the retry-401 path likewise; a run also keeps sending/settling under whatever session is current. | New `sessionGeneration` (bumped only by establish/clear, not by rotation). Runs bind to the generation at start. Per batch the sender acquires the token and verifies ownership; destructive cleanup goes through `clearTokensIfSession(generation)` under the state lock — clears and expires only when the run's session is still current; otherwise the run stops as obsolete (`TgpSessionReplacedError`) without touching the replacement, without `auth_required`, and without settling/sending under replacement credentials. `completeIngest`/`postProgress` for a run are fenced the same way. |

Preserved (behaviour AND bytes unchanged): body-timeout/loader repairs in `shared/net.js`, `shared/pairing.js`, `scripts/browser-load-proof.mjs`; manifest/permissions; message kinds; public `getAccessToken`/`refreshAccessToken`/`clearTokens`/`establishSession`/`hasActiveSession` contracts.

Preserved behaviour, bytes NOT unchanged (correction 2026-09-21 16:40 PDT after parent inspection): `shared/log.js` — the accepted R3 timeout-event allow-list entries are untouched; one net-new `KNOWN_EVENTS` entry `settlement_skipped_session_replaced` is added so the worker can distinguish a settlement skipped because the session was replaced from a genuine `settlement_network_error`. `shared/replay/engine.js` — comment-only change (documents that abort callers may be obsolete-run callers); no executable bytes changed. The final applicability report separates "preserved timeout behaviour" from "unchanged bytes" file by file.

## Tests to add

- `test/refresh-admission-epoch.spec.js` (session module): A-01 schedule (refresh admitted during establish's persist → one fetch, both callers minted); clear-during-pending schedule; snapshotted-then-replaced run detached (new session refreshes on its own); stale finally cannot vacate the new slot; same-epoch joins.
- `test/session-ownership.spec.js` (worker integration via real router): A-02 schedule with stale refresh SUCCESS, stale refresh REJECTION (401), stale refresh TIMEOUT; retry-401 after replacement; unchanged-current-session auth loss still clears + `auth_required` exactly once (negative control, existing behaviour); obsolete run never sends a batch or settlement with the replacement token.
- Predecessor negative controls: dependency-free probe `execution/s4-r4/scripts/session-race-probe.mjs` run against base `84471e99` (expected FAIL on both schedules) and the candidate (expected PASS) — offline, single process, no installs.

## Validation request (deferred to parent slot)

Nothing heavier than `node --check` and reading runs before a slot is granted. Requested slot commands, in order, under `flock -n execution/test-validation.lock`: `npm ci`; focused Vitest (new specs + session/auth-body/hardening specs); `npm test`; `npm run gates`; `npm run package`; browser positive + negative control on the new zip. Expected total < 15 min, 2 CPUs.
