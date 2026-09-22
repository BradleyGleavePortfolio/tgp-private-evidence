# S4 R5 — narrow repair of S4-R4-A-01 / S4-R4-A-02 (isolated successor to 2bcf1563)

Worker: `s4_r4_auth_race_fixer_mubv6s6j` ("S4 R5 fixer"). Requested identity: Claude Fable 5 / High; actual
verifiable identity: API-hosted AI subagent. Work is a **reimplementation** authored under the mandated
identity, not recovered history.

Authorization: parent mail 11 (R5 narrow repair AUTHORIZED, sole S4 writer, isolated successor from 2bcf1563,
frozen 2bcf1563 preserved for review) + `execution/S4_R4_PARENT_DISPOSITION.md`.

## Exact checkpoint

| item | value |
|---|---|
| worktree | `/home/user/workspace/worktrees/s4-r5` (branch `execute/20260921-s4-r5`) |
| HEAD | `88287cff47240aa58b5f0fea5da08670f1e87df6` |
| tree | `a2879859882770f45b88f1651438436fd96376f9` |
| parent | `2bcf1563d85bc2109e99805e4ce1b06fce4dcdb3` (frozen R4, untouched: `worktrees/s4-r4` status clean) |
| public base | `0111be661922234d670bbf23e23d270eec1b4a4e` (bundle prerequisite) |
| author = committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no trailers, `--no-verify` NOT used |
| pre-commit hooks | lefthook v2.1.12 ran all six (secrets/gitleaks, banned, deploy-readiness, lint, type-check, format) — all ✔️, receipt `logs/R5-13-checkpoint-commit.log` |
| working tree after commit | clean (`git status --short` empty) |
| bundle | `artifacts/s4-r5-88287cff.bundle` sha256 `f8de3d639e8765fec1a914ddf4fd220a1e89dbcc6c4492e2108addccdc1fcf97`, `git bundle verify` okay, requires `0111be66…`, head `refs/heads/execute/20260921-s4-r5 = 88287cff…` |
| patch over 2bcf1563 | `artifacts/s4-r5-88287cff-over-2bcf1563.patch` sha256 `f9be88be97b4b12c9282cca984f9abf0ad2a746fc16c4e66ec7e25fc1be686fc` |
| diffstat vs 2bcf1563 | `background.js +/-104`, `shared/session.js +/-94`, `test/refresh-admission-epoch.spec.js +212`, `test/session-ownership-preflight.spec.js +647 (new)`, `test/session-ownership.spec.js +7/-2`; 5 files, +1018/−46 |
| changed shipping bytes | `background.js` (blob sha256 `5a6a4b8b…4ff721`), `shared/session.js` (`b4f45900…2bbc2`) — **yes, the extension package changes; no zip evidence is inherited from 6fe9a7be** |
| toolchain | node v20.20.1, npm 10.8.2, package-lock sha256 `262d4b69…cdae8` (unchanged), gitleaks 8.30.0 |

Disclosure — toolchain link for the commit: `worktrees/s4-r5` has no `node_modules` (no install authorized). The
shared `.git/hooks/pre-commit` (installed by R4's `npm ci` via `prepare`) runs `npm run lint/type-check/format:check/...`
in the committing worktree, so for the commit only I symlinked `worktrees/s4-r5/node_modules →
worktrees/s4-r4/node_modules` (same package-lock, no install), ran the commit under the stamped wrapper (hooks ran
inside the 180 s bound; 10.5 s), then **removed the symlink** (`git status` clean). The same link was used for the two
≤60 s focused vitest runs and the local prettier/eslint/tsc checks below. First commit attempt (R5-10) failed because a
vitest cache dir had already created `node_modules/.vite`, so the link landed inside it — corrected, no source impact.
Second attempt (R5-11) failed the type-check hook on JSDoc typing in the NEW spec file only — fixed in the spec, no
source change.

## What changed (source)

No message/manifest/backend contract change, no dependency, no generic framework, pairing never disabled, no lock
held across network.

### `shared/session.js` — bound refresh admission (S4-R4-A-02 / S4-R4B-01)
- `RefreshRun = { epoch, generation, expected, obsolete }`; `refreshInFlight` is a `RefreshSlot {promise, run}`.
- `refreshAccessToken(expectedGeneration?)` / `getAccessToken(expectedGeneration?)` — optional binding to the
  caller's session generation. Unbound (no argument) semantics unchanged (all existing callers/tests keep working).
- Bound call: (1) returns `null` immediately if `expected !== sessionGeneration` on entry; (2) never joins a run bound
  to a **different** session (waits for the slot to vacate, then loops — never a parallel presentation); (3) under
  the state lock at snapshot, `run.generation = sessionGeneration`; if `run.expected !== sessionGeneration` the run
  sets `obsolete`, returns `null` **without reading the refresh token** (nothing presented, nothing rotated);
  (4) a bound joiner accepts a shared run's token only if `slot.run.generation === expected`.
- Unbound joiner of a run that stood down re-runs once for the current session (legitimate refresh preserved).
- Same-session callers still coalesce onto one fetch. Rotation/epoch fencing, `detachStaleRefresh`, failure-safe
  persist unchanged.

### `background.js` — Start owner bound at admission (S4-R4-A-01)
- `const generation = getSessionGeneration()` is now the FIRST statement of both `handleStartIngest` and
  `handleStartImport` (router invokes them synchronously → bound at admission, before any await).
- `ownedAccessToken(generation)` → `getAccessToken(generation)`; a throw/return after a generation change becomes
  `TgpSessionReplacedError`.
- New `preflightOwnedSession(generation)` → `null | {replaced: boolean}`; `reportPreflightFailure`: replaced →
  `broadcastStatus({...emptySnapshot(), lastError: SESSION_REPLACED_DETAIL})` (no `auth_required`, nothing cleared);
  otherwise the existing `broadcastAuthRequired("login required to import")`.
- `makeSender` (ingest 401 path) and `completeIngest` (settlement 401 path) call `refreshAccessToken(generation)`.

## Closure evidence (candidate 88287cff vs predecessor 2bcf1563), all receipts in `logs/`

Cheap ≤60 s single-process offline probes under the parent's mail-11 light grant (lock NOT taken; S6 holds the heavy
slot). Every receipt stamps head/tree/dirty/toolchain/command/start-end/exit.

| probe (derived from) | candidate 88287cff | predecessor 2bcf1563 |
|---|---|---|
| `a01-preflight-barrier-discriminator.mjs` — reviewer A C3 schedule (rotation persist held, B queued behind it) + unchanged-session control | `--expect fixed` PASS: refresh presented `[OLD_R]` only, **zero** requests under B's bearer, B `NEW_R` stored intact, no `auth_required`, honest stop (`lastError` = replaced detail, intent null); control imports all routes under `OLD_MINTED_A`, `ingest_succeeded` (R5-14; pre-commit R5-01) | `--expect defect` PASS: reproduces A-01 — `/api/scout/ingest`, `/progress`, `/ingest/complete` all under B's bearer, `ingest_succeeded` under B (R5-02) |
| `a02-queued-refresh-discriminator.mjs` — reviewer A C1 + C2 and reviewer B P-C schedules, verdict per identity invariant | `--expect fixed` PASS: C1 no `auth_required`, B intact; C2 and P-C refresh tokens presented by the obsolete run = `[]`, storage still `NEW_R`/`NEW_RT` (unrotated), `ingest_failed` + replaced detail, hasSession true (R5-15; pre-commit R5-03) | `--expect defect` PASS: C1 `auth_required` "login required to import" while `NEW_R` stored; C2 presented `NEW_R` → `ROTATED_FROM_NEW_R`; P-C presented `NEW_RT` → `ROTATED_FROM_NEW_RT` (R5-04) |
| inverted expectation on candidate (fail-closed check of the discriminators) | `--expect defect` exits 1 on candidate for both (R5-19, R5-20) | — |
| R4 builder probes (`coalescer-admission-probe`, `stale-caller-probe success/reject`) — R3/R4 closures preserved | all PASS on 88287cff (R5-16/17/18; pre-commit R5-05/06/07) | (passed on 2bcf in R4) |
| reviewer B's **unmodified** `pending-admission-replacement-probe.mjs` | exit 1 **by design**: P-A (clear→establish coalescing: one NEW fetch, both minted) all PASS; P-C `spec_invariant_old_run_never_presented_NEW_RT = true`, no auth_required, no COMPLETE, hasSession; the three B design-level checks `pending_run_presented_NEW_RT_exactly_once` / `replacement_rotated_by_that_refresh` / `memory_access_is_minted_for_NEW` FAIL because the parent adopted the identity/authority invariant over B's "present once" model (R5-21) | (B reported PASS on 2bcf) |

Reviewer A's original `independent-race-probe.mjs` hard-codes its roots (s4-r4 + base export) and lives in the
frozen audit dir, so it was not pointed at the candidate; the root-parameterised derivatives above keep A's
observation code and change only the verdict side.

Focused regressions (vitest via the linked sibling toolchain, ≤60 s, single process):
- R5-12: `refresh-admission-epoch`, `session-ownership-preflight`, `session-ownership`, `refresh-coalesce`,
  `ingest-auth` → **5 files, 42/42 pass**, 6.3 s. (R5-08 first run had one failing NEW test whose expectation was
  wrong about the number of ingest batches — test corrected, no source change; R5-09 42/42.)
- New `test/session-ownership-preflight.spec.js` (16): C3 barrier and C1 on **both** `start_import` and
  `start_ingest`; preflight rejection and timeout after replacement; clear→re-establish during preflight;
  pending-establish FAILURE (`session_persist_failed`) → OLD stays current and the run proceeds under it; C2 ingest
  401 behind establish; P-C pending admission; settlement `complete` 401 behind establish (one COMPLETE under OLD
  bearer, none under B, run left unsettled, replaced detail); ingest 401 behind clear→re-establish; controls: cold
  preflight success on `start_import`, cold rejection → `login required` exactly once on both entrypoints, 401→refresh
  with no transition, rotation persist failure fails closed (auth_required once, minted bearer never used).
- `test/refresh-admission-epoch.spec.js` +9 session-level: bound stand-down (null, nothing presented, B unrotated,
  current session still refreshes), stale-generation caller null before fetch, same-session coalescing, unbound
  joiner re-run presents NEW once, NEW-bound caller never joins OLD-bound run, pending-establish failure → OLD
  presented once, clear→re-establish stand-down + new-session coalescing, bound cold `getAccessToken` stand-down,
  unchanged-session bound cold control.
- `test/session-ownership.spec.js`: comment only (B-01 claim precision) — the invariant there is explained as resting
  on the 401 gate + fenced commit for its schedules, with the queued-admission schedules pointed at the new spec.

Static (linked toolchain, no install): prettier check clean; eslint clean; `tsc -p jsconfig.json` clean (exit 0);
all six lefthook gates ✔️ at commit.

## Not done / deferred (honest)
- No heavy slot used: no `npm ci` in s4-r5, no full suite, no `npm run gates` outside the hook, no package build,
  no browser. The shipping bytes changed → a fresh zip + positive **and** negative browser proof are required before
  any acceptance (see `VALIDATION_REQUEST_1.md`).
- A3 browser harness root cause (`--remote-debugging-pipe` fd4 silent) remains diagnosed-not-fixed; the request
  below front-loads the Chrome-alone pipe discriminator and falls back to base-zip control, per mail 11.
- Reviewer B's probe fails on the candidate by design (documented above); B's P-A positive control passes.

## Request
Dual independent follow-up audits of 88287cff (source + probes), then the single validation bundle in
`VALIDATION_REQUEST_1.md`. Frozen 2bcf1563 stays untouched in `worktrees/s4-r4` for comparison.
