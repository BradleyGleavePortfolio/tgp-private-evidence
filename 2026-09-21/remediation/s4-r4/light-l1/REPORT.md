# S4 R4 — auth race fixer report (checkpoint 1: source frozen, UNVALIDATED)

Status: **IN PROGRESS — awaiting validation slot.** Nothing in this lane has been installed, built, tested, packaged or browser-executed. Only `node --check`, `bash -n`, git identity checks and a by-eye Prettier-style review have run. Every claim below about behaviour is a reading of the source, not a test result.

## Identity

| item | value |
|---|---|
| lane / worker | S4 R4 builder, `s4_r4_auth_race_fixer_mubv6s6j` |
| requested model | Claude Fable 5 / High |
| actual verifiable identity | API-hosted AI subagent (model identity not independently verifiable from inside the sandbox) |
| classification | **reimplementation** of the unpreserved R4 delta from archived R3 audit A/B findings; no historical recovery search performed (closed) |
| worktree / branch | `/home/user/workspace/worktrees/s4-r4`, `execute/20260921-s4-r4` |
| base (frozen) | `84471e99b278e964f7cb3f6bf9c78491064c41b7` (tree `f31a978034d0aa8a2c39615ade5ec0255a19b1d0`) |
| checkpoint head | `2bcf1563d85bc2109e99805e4ce1b06fce4dcdb3` |
| checkpoint tree | `3e23f91824689d1f179a116af948eae0ed5ae170` |
| working tree | clean at time of writing |
| commit identity | author + committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, verified with `git var` before and `git log --format=%an/%ae/%cn/%ce` after; no AI/co-author trailers |
| hooks | lefthook NOT installed in this clone (fresh clone, `prepare` never ran) → the checkpoint commit ran no pre-commit hooks. `--no-verify` was not used. Hook-equivalent gates (`npm run gates`, gitleaks) are scheduled in the slot. |
| remote | none configured; nothing pushed; no live action |
| patch | `artifacts/s4-r4-checkpoint1-84471e99..2bcf1563.patch` (sha256 `2ca23ea330aa39b6516723423b6371e378ce92a6e6514e811cee413b983d5d79`) |
| checkpoint-1 packet | `artifacts/checkpoint1-2bcf1563/` — git bundle (prereq public main `0111be66`, 20 commits, head `2bcf1563`, `git bundle verify` OK), patch, diff, diffstat, head-identity, MANIFEST.json, SHA256SUMS. Created 2026-09-21 23:43 UTC before any install/test, per parent instruction; retained even if a later formatting commit moves head. |

## Changed files (84471e99 → 2bcf1563; 6 files, +829/−67)

| file | kind of change | preserved-behaviour note |
|---|---|---|
| `shared/session.js` | executable | A-01 fix: epoch-recorded refresh slot, `detachStaleRefresh` replaces unconditional detach; new `sessionGeneration`, `getSessionGeneration()`, `clearTokensIfSession(generation)`; `clearTokens()` now `withStateLock(clearUnderLock)`. Public contracts of `getAccessToken`/`refreshAccessToken`/`clearTokens`/`establishSession`/`hasActiveSession` unchanged. Refresh body-deadline code path untouched. |
| `background.js` | executable | A-02 fix: runs bind to `generation`; `ownedAccessToken`, `sessionLossError`, `obsoleteRunError`, `TgpSessionReplacedError`, `SESSION_REPLACED_DETAIL`; generation checks before send/refresh/retry/settle/progress; obsolete runs broadcast `ingest_failed` with the replaced detail, never `auth_required`, never settle. Legacy `handleStartIngest` gets the same treatment. Re-export `export { clearTokens, getAccessToken }` retained. |
| `shared/log.js` | executable, 1 line | **Timeout behaviour preserved; bytes NOT unchanged**: one `KNOWN_EVENTS` entry `settlement_skipped_session_replaced` added. R3 timeout entries untouched. |
| `shared/replay/engine.js` | comment only | No executable bytes changed. |
| `test/refresh-admission-epoch.spec.js` | new | 5 session-level cases (below). |
| `test/session-ownership.spec.js` | new | 7 integration cases through the real router/worker/engine/session (below). |
| `shared/net.js`, `shared/pairing.js`, `scripts/browser-load-proof.mjs`, manifest, message kinds, backend contracts | **unchanged bytes** | accepted R3 body-timeout/loader repairs carried as-is; no message/manifest/backend contract widened. |

## Findings addressed (dispositions are PROPOSED until slot evidence + dual audit)

**S4-R3-A-01 / S4-R3-B-01 — duplicate refresh admission after establish/clear.**
Root cause (from archived audit A probe `coalescer-transition-probe.mjs`): `establishSession`/`clearTokens` detached *any* in-flight refresh, including one still queued behind the transition on the state lock; that run reads the NEW refresh token, so a caller arriving after the transition started a second refresh presenting the same token in parallel. Fix: the slot records the epoch the run snapshotted under (written inside the lock); transitions detach only runs whose recorded epoch is stale. Not-yet-snapshotted runs stay joinable. Regression: `refresh-admission-epoch.spec.js` case 1 (queued run joined, 1 fetch), case 3 (admitted during clear → no token presented, later session not poisoned); predecessor negative control case 2 (already-snapshotted stale run IS still detached).

**S4-R3-A-02 — obsolete caller clears the acknowledged replacement session.**
Root cause (audit A `stale-caller-probe.mjs`): a run that started under session A and hit 401 → refresh → null after session B was acknowledged called unconditional `clearTokens()` and broadcast "session expired", wiping B. Fix: `sessionGeneration` (identity, moved only by establish/clear, not by rotation) + `clearTokensIfSession`; worker runs re-check ownership before every act on the session and stop with an honest `ingest_failed` when superseded. Regression: `session-ownership.spec.js` cases stale-success / stale-reject / stale-timeout / retry-401-after-replacement / replacement-without-401; negative controls: current-session auth loss (refresh null, and refresh OK → retry 401) still clears tokens and broadcasts `auth_required` exactly once.

Predecessor control probes (`scripts/coalescer-admission-probe.mjs`, `scripts/stale-caller-probe.mjs`, adapted from audit A, dependency-free, no network) are prepared to run in the slot against both base 84471e99 (expected FAIL) and the candidate (expected PASS). The stale probe on the candidate waits for the terminal `ingest_failed` snapshot rather than `auth_required`.

## Proven / not proven

- Proven (L1-S4-PROBES light grant, 23:50Z, see `L1_PROBES_RESULT.md`): the two dependency-free offline predecessor-control probes PASS on candidate 2bcf1563 (exit 0) and FAIL on frozen base 84471e99 (exit 1) for exactly the A-01 (duplicate refresh presentation) and A-02 (replacement session wiped, auth_required) defects. Disclosed: the first four invocations were a harness path error (no probe executed); the probes then ran once. Also proven: syntax (`node --check`), commit identity.
- Not proven: stale-reject/stale-timeout probe modes; Prettier/ESLint/tsc conformance (Prettier line-break choices on a few statements were hand-checked, not tool-checked; a follow-up formatting commit is possible); vitest pass of the new and existing specs; `npm run gates`; package build; browser positive + negative-control proof; base-fail/candidate-pass probe pair. All scheduled in `VALIDATION_REQUEST_1.md` / `scripts/slot-run-1.sh`.
- Known risks to flag for auditors: (1) `test/session-ownership.spec.js` uses real timers with up to ~4000 macrotask ticks per wait and 15 s per-test timeouts — the engine paces source requests at 500 ms, so cases take a few seconds each; (2) the TIMEOUT case relies on vitest fake timers not faking `queueMicrotask` (vitest 4 default) — if it hangs, that case will be reworked, not skipped; (3) `clearTokensIfSession` returning `false` after `clearTokens()` by the popup (sign-out) is treated as "replaced/obsolete" — the run stops with the replaced detail and does not double-broadcast `auth_required`; the popup's own sign-out path already updates UI state.

## Requested next action

Grant validation slot per `VALIDATION_REQUEST_1.md` (single lock holder, ≤ 15 min, commands and bounds listed there). After a clean run on the final head: freeze bundle (prereq `0111be661922234d670bbf23e23d270eec1b4a4e`), zip + SHA256SUMS, browser proof JSONs, logs/meta, then dual independent audits. Old R3 zip evidence (`90883cad…`) is NOT inherited.
