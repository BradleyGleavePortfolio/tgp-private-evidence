# S4 R5 — Independent T4 Audit B (source verdict, revision 1, FROZEN)

Date: 2026-09-21 (America/Los_Angeles). Auditor: independent B (subagent). Parent is sole publisher.
Scope: parent R5 mail — challenge cumulative closure of S4-R4-A-01 and S4-R4-A-02 / S4-R4B-01 at the exact head below, both Start entrypoints, locked expected-owner refresh admission, same/current/unbound coalescing, reject/timeout/persist-failure/clear→re-establish. Source read-only; no install, no full/focused suite, no browser, no network, no DB, no commits, no lock. Writes only under `execution/audits/s4-r5/b/`. R5 A outputs NOT read; A not contacted.

## 0. Identity (G05)

- Requested: Claude Fable 5 / High (Sept 19 amendment).
- Observed: an API-hosted AI subagent with no observable model name, version, or reasoning setting. I cannot confirm or deny that the requested model was used. See `identity.txt`.

## 1. Subject and binding (G09)

| item | value |
|---|---|
| worktree | `/home/user/workspace/worktrees/s4-r5` |
| HEAD | `88287cff47240aa58b5f0fea5da08670f1e87df6` |
| tree | `a2879859882770f45b88f1651438436fd96376f9` |
| parent | `2bcf1563` (R4 head; control worktree `/home/user/workspace/worktrees/s4-r4`) |
| `git status --porcelain` | empty before and after my probes (both worktrees) |
| diff vs parent | `background.js` +104/−104, `shared/session.js` +94/−94, `test/refresh-admission-epoch.spec.js` +212, `test/session-ownership-preflight.spec.js` +647 (new), `test/session-ownership.spec.js` +7/−2. No other shipping file changed; `net.js`, `engine`, `popup`, `manifest` untouched. |
| builder bundle | `execution/s4-r5/artifacts/s4-r5-88287cff.bundle` — `git bundle verify` okay; `execution/s4-r5/SHA256SUMS` 0 mismatches |

All conclusions below are bound to `88287cff`. If the head changes, every conclusion is pending re-verification.

## 2. Exact-head source verdict

**Both material R4 findings are closed in source at 88287cff, by mechanism and by my own discriminating probe (candidate PASS 26/26 checks; predecessor 2bcf1563 FAILS exactly on the invariant-bearing checks).** No new material defect found. Three nonmaterial findings and one observability note below. Artifact attestation is WITHHELD (section 6).

### 2.1 S4-R4-A-01 (cold preflight bound late) — CLOSED at head

Mechanism verified by reading, not by builder claims:

- `background.js:550` (`handleStartIngest`) and `background.js:778` (`handleStartImport`): `const generation = getSessionGeneration();` is the first statement of each handler — before `detectPlatform`, before any `await`.
- Router `background.js:1086-1091` and `1106-1111`: `importInFlight = true; void handleStartX(message)…; sendResponse({ok:true})` — the handler body up to its first `await` runs synchronously inside the `onMessage` listener, so the generation is captured before the `{ok:true}` acceptance is sent. An "accepted Start" is therefore bound to the session visible when it was accepted. `establishSession` (`:1069`) is also dispatched synchronously from the same listener, so message order equals admission order.
- Preflight now goes through `preflightOwnedSession(generation)` (`:183`) → `ownedAccessToken(generation)` (`:157`) → `getAccessToken(generation)` (`shared/session.js:368`), which carries the binding into the cold refresh (`refreshAccessToken(expected)`, `:214`). Post-read generation check retained (`:172`). A refresh that stood down / was fenced surfaces as `TgpSessionReplacedError` (catch at `:164-168`), never as "no session".
- `reportPreflightFailure` (`:199`): replaced → `broadcastStatus({...emptySnapshot(), lastError: SESSION_REPLACED_DETAIL})`, **no** `auth_required`, nothing cleared; non-replaced → `broadcastAuthRequired("login required to import")` as before (only when the run's own session is still current and could not mint).
- Legacy `start_ingest` and `start_import` have identical structure (parity confirmed in diff).

Probe evidence (mine, section 4): S4 (warm preflight, B holding the lock at admission) → zero TGP requests, replaced detail, no `auth_required`, B intact, single-flight released. S6b (cold preflight refresh on the wire, B acknowledged, stale success returned) → only `OLD_RT` presented, zero ingest/progress/complete, replaced detail (not "login required"), no `auth_required`, storage still `NEW_RT`. On 2bcf1563 the same S6b yields `login required to import` + `auth_required` with B stored (A's C1 counterexample reproduced independently). S6a control: cold preflight mints OLD once and imports under `Bearer MINTED_FOR_OLD_RT`.

### 2.2 S4-R4-A-02 / S4-R4B-01 (queued refresh presents replacement's token) — CLOSED at head

Mechanism (`shared/session.js`):

- `RefreshRun = {epoch, generation, expected, obsolete}`; `refreshAccessToken(expectedGeneration)` (`:214`) binds when `Number.isInteger(arg)` — generation `0` (cold worker) binds correctly (probe S7).
- `refreshAccessTokenOnce` (`:272`): **under the state lock, before `readRefreshToken()`**, `run.generation = sessionGeneration`; if `run.expected !== null && run.expected !== sessionGeneration` → `run.obsolete = true`, returns `{token:null}` (`:279-284`). The replacement's refresh token is never read, never presented, never rotated by obsolete work. No network I/O under the lock (unchanged).
- Loop (`:221-244`): bound caller whose session already moved → `null` before any slot interaction (`:222`); `canJoinRun` (`:265`) refuses only runs bound to a *different* session; a bound caller that cannot join awaits the incompatible run's settlement and re-evaluates (`:233`); a bound joiner accepts a token only if `slot.run.generation === expected` (`:237`); an unbound caller that joined a run that stood down re-runs for the current session (`:239-242`).
- Callers: `makeSender` 401 path `refreshAccessToken(run.generation)` (`background.js:287`), `completeIngest` (`:381`), preflight via `getAccessToken(generation)`. **No unbound production caller remains** (`rg` over non-test sources) — unbound coalescing is preserved for API compatibility and exercised by tests/probe.
- Termination analysis (my challenge): a bound caller only waits (`:233`) on a run bound to a different generation that is still in the slot. A run bound to an older generation that already snapshotted is detached by the establish/clear epoch bump (`detachStaleRefresh`, `:82`), so a non-detached incompatible run is necessarily *pending* and stands down at its snapshot without network — the wait is bounded by lock handoff, not by a 15 s fetch. A bound caller cannot wait on a run bound to a *newer* generation because the `:222` check returns `null` first. An unbound caller re-runs (`:242`) only after joining a stood-down run, which requires a generation change per iteration; unbounded only under unbounded pairing churn. No livelock/deadlock found. `slot.promise` includes the `finally` vacate, so on `continue` the slot is already vacated or occupied by a fresh run.

Probe evidence: S5 (my R4 P-C schedule, ingest 401 fired from inside B's persist) → refresh tokens presented `[]`, storage `NEW_RT` (unrotated), ingest bearers `["Bearer OLD_ACCESS"]` only, no `/complete`, `ingest_failed` + replaced detail, no `auth_required`, `hasSession` true. On 2bcf1563: presented `["NEW_RT"]`, storage `ROTATED_FROM_NEW_RT`. S1: two NEW-bound callers waiting behind a pending OLD-bound run → OLD caller `null`, exactly one `NEW_RT` presentation, both NEW callers minted. S2: OLD-bound joiner of an unbound pending run across establish → unbound owner minted, OLD-bound joiner `null` (on base: `MINTED_FOR_NEW_RT` handed to the obsolete caller). S3: OLD-bound run on the wire, B lands, stale success fenced → `null`, B unrotated, NEW-bound caller presents NEW once. S7a/b: generation-0 cold binding mints OLD once; with B established mid-flight → `no_session` to the 0-bound caller, only `OLD_RT` presented, B intact.

**Explicit correction of my R4 expectation.** My frozen R4 P-C asserted "NEW presented exactly once by the coalescer" as the *expected* behaviour and labelled the violation nonmaterial. Under the parent's adopted authority invariant that expectation was wrong: an obsolete run has no authority over B's credentials, so the correct expectation is *nothing presented, B unrotated*. The builder's R5-21 receipt (my unmodified R4 probe exiting 1 on the candidate) is consistent with this and is **not** a regression. I do not rewrite the frozen R4 packet.

### 2.3 Preserved behaviours (checked)

- Same-session coalescing (two bound callers, one fetch) — builder spec `refresh-admission-epoch.spec.js:291`; my S1 covers two bound NEW waiters.
- Current-session cold refresh after SW restart (generation 0) — S6a (worker, generation as observed), S7a (module, generation 0).
- Persist failure of the replacement (`session_persist_failed`) → generation unchanged → OLD stays current → bound run proceeds under OLD — builder specs `:354` and `session-ownership-preflight.spec.js:426`; mechanism: establish commits generation only after persist (unchanged from R4).
- Reject/timeout with no transition → `login required` once (spec `:411`); reject/timeout *after* replacement → replaced, not login required (specs `:339`, `:355`).
- Clear → re-establish while refresh queued/on wire → stand down / fence, new session intact (specs `:383`, `:371`, `:561`).
- No lock held across network I/O; no backend/dependency/pairing-prohibition/manifest change; `net.js` unchanged.

## 3. Findings (stable IDs; defects vs evidence gaps vs external limits)

### Defects (all nonmaterial)

**S4-R5B-01 — Preflight "replaced" wording claims an import was in progress.** `background.js:199-206` broadcasts `SESSION_REPLACED_DETAIL` ("import stopped — your TGP session changed during the import. Start the import again.") when the replacement landed *during preflight*, i.e. before any crawl/ingest started. Consequence: cosmetic inaccuracy, action ("start again") correct; no state or credential effect. Scope: popup text. Owner: builder. Closure: distinct detail for the preflight case or documented acceptance. Severity: LOW / nonmaterial. Analogous to S4-R4B-05.

**S4-R5B-02 — Non-replaced preflight failure broadcasts "login required" + `auth_required` while tokens remain stored (inherited).** `preflightOwnedSession` returns `{replaced:false}` for any non-replaced error, including refresh transport failure/timeout of a still-current session; `broadcastAuthRequired` (`:495-501`) does not clear storage, so `request_session_state` still reports `hasSession: true`. Behaviour is byte-identical in intent to 2bcf1563 (the old `catch { broadcastAuthRequired(...) }`). Consequence: coach may be told to re-pair after a transient network failure. Scope: UX truthfulness; no security effect. Owner: builder/product. Closure: distinguish transport failure from rejection (cf. S4-R4B-03) or accept. Severity: LOW / nonmaterial, inherited, out of R5 scope.

**S4-R5B-03 — Stand-down has no log/telemetry event.** `shared/session.js:279-284` stands down silently (the run returns `{token:null}`); nothing distinguishes "stood down for obsolete owner" from "no refresh token" in logs. Consequence: field diagnosis of the exact schedules this round fixed relies on the popup detail only. Owner: builder. Closure: PII-free `refresh_stood_down` log event, or accept. Severity: LOW / observability, nonmaterial.

### Inherited nonmaterial items carried from R4 (status unchanged at head; not re-litigated)

S4-R4B-02 (`auth_body_cancel_failed` log noise; `net.js` unchanged), S4-R4B-03 (refresh network failure worded as "session expired"), S4-R4B-04 (unsettled intent / no server-side revocation boundary when a run stands down — R5 correctly leaves the old intent unsettled rather than settle it with B's bearer; spec `session-ownership-preflight.spec.js:522`), S4-R4B-05 ("import stopped" wording).

### Evidence gaps (block artifact attestation; not source defects)

- **EG-1** No fresh package zip built from `88287cff`. Shipping bytes changed vs 2bcf1563 (`background.js`, `shared/session.js`); zip `6fe9a7be…` (R4) is NOT inheritable.
- **EG-2** No full suite (≥1739 expected per builder), no `gates` run at head. Builder ran only lefthook (6 hooks, R5-13) and focused 42/42 (R5-12) using a symlinked `node_modules` from s4-r4 — attributable but builder-run, not independent.
- **EG-3** No gitleaks *scan* at head (install ≠ scan).
- **EG-4** No browser positive proof at head; R4's positive attempt aborted at `CDP timeout: Browser.getVersion` (harness issue, unresolved). No proper expected-failing negative control at any head — the base-good zip is a comparison, not a negative.
- **EG-5** My probe runs in a Node mock (`test/helpers/background-mock.js`), not Chrome MV3; `background.js` imports one shared `shared/session.js` instance, so worker-level schedules S4–S6 ran with generations 4–5, not 0. Generation-0 binding is covered at module level (S7) only.

### External / real-source limits

- Model identity unobservable (section 0).
- No backend involved: server-side refresh-token rotation/revocation semantics are assumed from the client contract; "B unrotated" means *client never presented it*.
- Time-boxed reading of the 647-line new spec: I read titles and the schedules relevant to my challenge, not every assertion.

## 4. My probe (offline, dependency-free, ≤60 s total)

`probes/bound-admission-probe.mjs` — single Node process, no network (fetch stubbed), no install, no lock, no shared state, source untouched (`git status --porcelain` empty afterwards in both worktrees). Node v20.20.1.

| run | root | head | exit | elapsed | result |
|---|---|---|---|---|---|
| candidate (final) | `worktrees/s4-r5` | `88287cff…` | 0 | 1086 ms | PASS, 0 failures, 26 checks + observations |
| predecessor control | `worktrees/s4-r4` | `2bcf1563…` | 1 | 16098 ms | FAIL: `S1.both_new_callers_minted`, `S1.storage_rotated_by_new_session_only`, `S2.old_bound_joiner_refused_B_token`, `S5.obsolete_run_presented_nothing`, `S5.B_unrotated`, `S6b.replaced_not_login_required`, `S6b.no_auth_required` |

Total wall time for all probe executions this round: ≈ 20 s (one earlier candidate run before adding S7 ≈ 1.2 s, final candidate 1.2 s, predecessor 16.2 s). Receipts: `probes/candidate.result.json`, `probes/predecessor.result.json` (+ stderr captures). The control fails only on invariant-bearing checks and passes structural ones, so the probe discriminates the fix rather than the harness.

Builder receipts examined (`execution/s4-r5/logs/R5-14..21*.meta.json`): all stamped `88287cff`, dirty paths 0; R5-14/15 discriminators exit 0 on candidate; R5-19/20 "expect-defect-must-fail" exit 1 on candidate (correct sign: candidate no longer exhibits the defect); R5-21 my R4 probe exit 1 (expected, see 2.2). I did not rerun builder scripts.

## 5. Disposition on parent's closure criteria (independent)

| criterion | verdict at 88287cff |
|---|---|
| Bind accepted Start before any async preflight, both entrypoints | MET (`:550`, `:778`, router sync) |
| Carry expected identity into locked snapshot/join and all worker callers | MET (`session.js:279`, callers `:163`, `:287`, `:381`) |
| Obsolete work never uses replacement credentials / mutates replacement state / falsely reports replacement auth required | MET (probe S4/S5/S6b; specs C1/C2/C3/P-C) |
| Preserve current-session cold refresh and coalescing | MET (S1, S6a, S7a; specs `:291`, `:390`) |
| No lock across network | MET (unchanged structure) |
| No backend/dependency/pairing-prohibition changes | MET (diffstat) |
| Attributable closure tests for both entrypoints, ingest/progress/settlement, both counterexamples | PRESENT in source (`session-ownership-preflight.spec.js` iterates both kinds; `:522` settlement) — **execution at head independently unverified** (EG-2) |

## 6. Attestation status

- **Source verdict at 88287cff: closure of A-01 and A-02/B-01 CONFIRMED; no material open source finding from B.**
- **Artifact / T4 final attestation: WITHHELD.** Required before I sign: fresh zip built from `88287cff` with blob-level equality to HEAD, full suite + gates at head, gitleaks scan at head, browser positive proof at head, and a *proper* expected-failing negative control — all with head-stamped receipts. On receipt I will file a separate dated addendum under `execution/audits/s4-r5/b/`; this report is frozen and will not be overwritten.
- If the head changes, all conclusions above are pending.

See `EVIDENCE_REQUEST.md` for the exact packet requested and `SHA256SUMS` for the non-self manifest of this packet.
