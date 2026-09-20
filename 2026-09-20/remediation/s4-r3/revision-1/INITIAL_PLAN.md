# S4 R3 fixer — initial plan (T4, builder evidence only)

Written 2026-09-20 22:42Z before any source edit.

## Identity

- Frozen base: `c5a5ae12c5b3c3e32a4601c99319ad7c0d980057` (tree `5f3c8f6a729427ce6c23bcb1ba18dc7b986b7447`), `worktrees/s4` untouched (verified clean, same HEAD after worktree creation).
- New isolated worktree: `worktrees/s4-r3`, branch `execute/20260920-s4-r3`, created from the exact base.
- Commit identity: per-worktree config (`extensions.worktreeConfig`), `git var` shows `Bradley Gleave <bradley@bradleytgpcoaching.com>` for author and committer. No global or shared-repo identity was set. No AI trailers.
- Requested builder routing: Claude Fable 5 / High. Actual known identity: API-hosted AI subagent; no provider/model/version identifier is exposed to me and none is claimed as verified.

## Findings being fixed (stable IDs)

- **S4-R2-A-01 (MATERIAL)**: `shared/pairing.js` and `shared/session.js` await `fetchWithTimeout` only until headers, then `res.json()` outside the deadline; a JSON prefix that never closes leaves pairing submit / coalesced refresh callers pending forever; after `clearTokens` + `establishSession` a new `refreshAccessToken()` joins the stale in-flight refresh.
- Parent disposition: bound pairing and refresh through body consumption, preserve epoch isolation, ensure clear/re-establish recovers from stalled work, add stall/recovery regressions, new package hash, repeat positive/negative loader proof.

## Minimal source change (3 shipping files + tests)

1. `shared/net.js`: pass the deadline `AbortSignal` as second argument to `consume(response, signal)` (backward compatible; existing callers ignore it). Add `readBoundedJson(response, signal, maxBytes)` — reads `response.body` through a byte-bounded reader (same pattern as `shared/ingest-ack.js`), cancels the reader on abort, falls back to `response.json()` when no stream is exposed (existing unit mocks). Throws a tagged `BodyError`; never echoes body bytes.
2. `shared/pairing.js`: consume the redeem body inside the `fetchWithTimeout` consumer; keep exact `pair_timeout` / `pair_network_error` / `pair_body_parse_error` categories and coach-facing copy; token material still only handed to `session_established`.
3. `shared/session.js`: consume the refresh body inside the consumer; keep `refresh_timeout` / `refresh_network_error` / `refresh_body_parse_error`; keep epoch-fenced commit unchanged. Coalescer: record the epoch the in-flight refresh belongs to; `clearTokens`/`establishSession` (under the state lock, at the epoch bump) detach the stale in-flight promise so a subsequent `refreshAccessToken()` for the new session starts its own fetch instead of joining stale work. The stale promise still settles for its own callers (null via epoch fence or timeout) and only nulls the slot if it is still the current one.
4. No manifest/permission/native/flag change. No change to background router, sender/origin gates, redaction, or the legacy entrypoint (S4-R2-A-02 stays a separate, explicitly non-owned residual).

## Regressions (vitest, deterministic fake timers)

- `test/auth-body-deadline.spec.js` (new): pairing — headers 200, real `Response` on an open `ReadableStream` with a JSON prefix that never closes → after deadline, resolves `{ok:false, error:"That took too long…"}`, `pair_timeout` logged, no `session_established` sent, deadline signal aborted. Same for a non-2xx stalled body. Refresh — stalled body → `null` after deadline, stored refresh token preserved, `refresh_timeout` logged. Oversized body → parse-error category, no token committed. Recovery — stalled refresh, then `clearTokens()` + `establishSession()`; a subsequent `refreshAccessToken()` performs its own fetch (2 fetches total), commits to the new epoch, stale refresh resolves `null`, and never overwrites the new access token. Also stalled refresh then `clearTokens()` alone → second refresh returns `null` without network.
- Existing tests (fetch-never-resolves, malformed body, stale rotation, coalescing) are preserved unchanged.

## Cheap checks I run here (no slot needed)

- `node --check` on edited files; dependency-free Node probe (`execution/s4-r3/scripts/auth-body-probe-r3.mjs`, derived from auditor A's probe) on base and candidate to show the stall now settles with the deadline and the coalescer detaches.
- Prettier formatting must be checked by the parent-slot gate run (no matching prettier/vitest/eslint tree exists locally: `worktrees/s4` has no `node_modules`; `/home/user/node_modules` and `worktrees/s6/node_modules` do not match the S4 lockfile — not reused).

## Parent slot request (serialized; smallest set)

1. Deterministic `npm ci` in `worktrees/s4-r3` (lockfile unchanged from base) — or a read-only symlink to a tree proven to match `package-lock.json`; disclose provenance.
2. `npm test` (focused: `test/auth-body-deadline.spec.js test/net.spec.js test/pairing.spec.js test/session-*.spec.js test/refresh-coalesce.spec.js`) then full `npm test` and `npm run gates`, wrapped with head/tree/dirty stamping and real exit codes.
3. `npm run package` → new hash (shipping bytes change: `shared/net.js`, `shared/pairing.js`, `shared/session.js`).
4. `npm run proof:browser` and `npm run proof:browser:control` against the new zip, positive and negative, with every failed attempt preserved.

## Ownership intersections

- None with S1/S2/S5/S6 (extension repo only). Shared `shared/net.js` change is additive and backward compatible; `background.js` consumers unchanged.


---
**STATUS (2026-09-20 23:05Z): EXECUTED. Frozen head `84471e99b278e964f7cb3f6bf9c78491064c41b7`, package sha256 `90883cad44cd78b60a18ab232aba0b965ae40ab6edb99054138cac61c0f6a9a7`. See REPORT.md.**
