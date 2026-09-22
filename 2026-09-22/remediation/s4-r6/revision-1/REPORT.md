# S4 R6 — reporting-authority repair for S4-R5-A-01 (isolated successor to 88287cff)

Worker: sole S4-R6-REPORTING builder (continuation brief, S4-R6-REPORTING packet). Requested identity: Claude Fable 5 /
High; **actually observable identity: an API-hosted AI subagent with no exposed model name, version or reasoning
setting — not confirmed or denied.** No model telemetry is invented. This is a new implementation authored under the
mandated commit identity, not recovered history.

Authorization read in full: `execution/CONTINUATION_BRIEF.md`, `tgp-agent-context/AGENT_RULES.md`,
`tgp-private-evidence/LAST_OPERATOR_STATE.md`, `tgp-private-evidence/LAST_OEPRATOR_HANDOFF.MD`, root `DISPATCHES.md`,
`2026-09-21/orchestration/s4-r5-parent-disposition-0107.md`, both frozen R5 reviews
(`2026-09-21/audits/s4-r5/{a,b}/revision-1/REPORT.md`, read as prior-round history, not current peer verdicts) and the
R5 builder `REPORT.md` / `VALIDATION_REQUEST_1.md` / `artifacts/MANIFEST.md`. Only S4-R6-REPORTING was executed.

## 1. Restoration of the exact predecessor (bundle, not reimplementation)

| check | result |
|---|---|
| bundle | `2026-09-21/remediation/s4-r5/checkpoint-1-88287cff/artifacts/s4-r5-88287cff.bundle` |
| SHA256 | `f8de3d639e8765fec1a914ddf4fd220a1e89dbcc6c4492e2108addccdc1fcf97` — **matches** brief and R5 MANIFEST |
| `git bundle verify` | okay; contains `refs/heads/execute/20260921-s4-r5 = 88287cff…`; requires `0111be661922234d670bbf23e23d270eec1b4a4e` |
| public prerequisite | `source/extension` baseline HEAD `0111be66…` (unmodified, clean); cloned with `--no-hardlinks` into the isolated repository, remote removed; baseline and archive not edited |
| restored HEAD / tree | `88287cff47240aa58b5f0fea5da08670f1e87df6` / `a2879859882770f45b88f1651438436fd96376f9` — **both match** the brief |
| ancestry | `0111be66` and frozen R4 `2bcf1563` are ancestors; 21 commits over `0111be66` (matches R5 MANIFEST) |
| clean status | `git status --porcelain` empty after restore |
| author/committer of 88287cff | `Bradley Gleave <bradley@bradleytgpcoaching.com>` both, 2026-09-22T00:45:33Z |
| shipping blobs at 88287cff | `background.js` `5a6a4b8b…4ff721`, `shared/session.js` `b4f45900…2bbc2` — match R5 MANIFEST |

Isolated repository: `/home/user/workspace/worktrees/s4-r6`, branch `execute/20260921-s4-r6` (the restored
`execute/20260921-s4-r5` ref is retained at 88287cff for comparison). A read-only tree export of exact 88287cff is at
`execution/s4-r6/predecessor-88287cff/` (via `git archive`; plus one added file, see §4 R6-08) for predecessor probes.

## 2. Exact successor checkpoint

| item | value |
|---|---|
| HEAD | `91990ae9aec72f47a67591892ac09fa1f59d2f16` |
| tree | `840fb2855953d5363fbd144e11b3f81763d9cef7` |
| parent | `88287cff47240aa58b5f0fea5da08670f1e87df6` (unchanged; frozen) |
| public base | `0111be661922234d670bbf23e23d270eec1b4a4e`; 22 commits over it |
| author = committer (actual commit object inspected) | `Bradley Gleave <bradley@bradleytgpcoaching.com>` 2026-09-22T04:38:29Z; `git var` author/committer both checked before commit; `%(trailers)` empty; no AI trailer; repository-local `user.name`/`user.email` only |
| `--no-verify` | NOT used |
| working tree after commit | clean (`git status --porcelain` empty) |
| diffstat vs 88287cff | `background.js` +15/−6, `test/session-ownership-preflight.spec.js` +151; 2 files, +166/−6 |
| changed shipping bytes | `background.js` only — blob sha256 `e0e674345fd4e2e2d47267295669ae4114a4c057eccd32e3c28fef1f22ce8eb3` (git blob `f1ecb5cc…`). `shared/session.js` UNCHANGED (`b4f45900…2bbc2`). **The extension package changes; no ZIP/browser evidence is inherited.** |
| spec blob | `test/session-ownership-preflight.spec.js` sha256 `b03754b9ccd0a8cbafe37027cce48ae2332a04e86d9015c4c72f217babf3512f` |
| bundle | `artifacts/s4-r6-91990ae9.bundle` sha256 `af2c8207c9b04ca9089115e39e0a3298c6519b8f58b7238cc1a7c718a9bab0dd`; verify okay; requires `0111be66…`; head `refs/heads/execute/20260921-s4-r6 = 91990ae9…` |
| patch over 88287cff | `artifacts/s4-r6-91990ae9-over-88287cff.patch` sha256 `1f57346c7e56fe2b9647134d5bd1b2243dd318124bf8cdd6d2a86a08995c2a06` (format-patch, 1 commit); plain diff `…over-88287cff.diff` `aeb7bdca…b8544` |
| toolchain | node v20.20.1; **no `node_modules`, no install, no lock taken** |

### BLOCKER DISCLOSURE — commit hooks did not execute

`lefthook.yml` defines six pre-commit gates (secrets/gitleaks, banned, deploy-readiness, lint, type-check, format).
In this fresh workspace the hooks are **not installed** (`.git/hooks` contains only samples; `lefthook`, `eslint`,
`prettier`, `tsc`, `gitleaks` are absent; no `npm ci` is granted; the R5 "same-lock R4 dependency closure" named in
the parent disposition does not exist here — `worktrees/s4-r4/node_modules` is not present). The commit therefore
landed with **0/6 hook gates executed**. No hook was bypassed by flag, but the effect is the same and is reported as a
blocker, not glossed: `91990ae9` is a frozen candidate whose hook-equivalent gates (`npm run gates`, gitleaks staged/
history scan) are **pending** and must run at the next granted validation before any acceptance. If the parent prefers
a gate-attested commit object, recreate the identical tree under installed hooks (the tree `840fb285…` and the patch
are frozen for that purpose); that would change the head and require fresh attribution.

Dependency-free gate substitutes that DID run on the exact head: `scripts/check-js-syntax.mjs` (117 files OK, R6-21)
and `scripts/check-flag-discipline.mjs` (PAIRING_ENABLED=true, R6-12, on pre-commit bytes). `check-banned`,
`check-deploy-readiness`, `check-production-fixtures`, `check-hook-config`, `check-format`, lint and type-check need
`typescript`/`prettier`/`eslint`/`yaml` and did **not** run. Prettier style was matched by hand (double quotes, 80
columns, trailing commas); a real `format:check` is still required.

## 3. What changed (source) — minimal, `background.js` only

Frozen finding S4-R5-A-01 (auditor A): `preflightOwnedSession(generation)` classified the failure as
`{replaced:false}` while OLD was still current; that result returned across the `await` in `handleStartImport` /
`handleStartIngest`; a replacement B whose `establishSession` was queued on the state lock committed inside that
microtask gap (offsets 10 and 11 in A's enumeration, both entrypoints); `reportPreflightFailure(failure)` then
broadcast `auth_required` + "login required to import" while B was current and locally valid.

Repair (apply_patch-style exact edits, three hunks):

- `reportPreflightFailure(failure, generation)` now takes the accepted Start's admission-time generation and
  revalidates **synchronously at the notification**: `if (failure.replaced || getSessionGeneration() !== generation)`
  → `broadcastStatus({...emptySnapshot(), lastError: SESSION_REPLACED_DETAIL})` (no `auth_required`, nothing cleared,
  nothing of B read or presented); otherwise the unchanged genuine `broadcastAuthRequired("login required to import")`.
  There is no await between the check and the emission decision (`broadcastStatus` / `broadcastAuthRequired` decide
  synchronously; only Chrome message delivery is asynchronous).
- Both call sites (`handleStartIngest` :573, `handleStartImport` :819) pass `generation`.

Not changed: `shared/session.js` (refresh admission, coalescing, epoch fencing, `clearTokensIfSession`), `ownedAccessToken`,
`preflightOwnedSession`, run-time 401 paths, messages/manifest/backend contract, dependencies, popup/UX text, telemetry.
No new token authority; no session rewrite. Earlier credential fixes (R3/R4/R5) are preserved and re-probed below.

## 4. Evidence — offline, dependency-free, ≤60 s aggregate (actual ≈44 s wall for all probe/syntax runs)

All receipts in `logs/` with `R6-NN.meta.json` (head, dirty count, working-diff sha256, node, start) and `R6-NN.exit`.
"dirty" runs are pre-commit runs on the working tree whose `git diff` sha256 is stamped; post-commit runs (R6-15…21)
are on the clean exact head `91990ae9`. No network, no DB, no lock, no install, no browser, no vitest.

### 4a. New discriminator `probes/a01-late-reporting-discriminator.mjs` (sha256 `890d45f7…172fbc`)

Derived from auditor A's frozen `preflight-notification-boundary-probe.mjs` (sha256 `ccdc3bc3…f511f`): same
observation code (actual candidate modules through the repo's `test/helpers/background-mock.js`, synthetic HTTP/storage
only), root-parameterised, verdict per `--expect`, plus explicit controls: (a) offsets where OLD is still current at the
report must emit exactly one genuine `login required`; (b) offsets where B is current at the report must end with the
replaced detail, no `auth_required`, `NEW_R` stored, `hasSession:true`; universal: exactly one refresh presented
(`OLD_R`), B never presented/removed, replacement acknowledged, guard-independent terminal.

| receipt | root | expectation | exit | observation |
|---|---|---|---|---|
| R6-01 | predecessor export 88287cff | defect | **0 = reproduced** | 82 cases; **4 stale `auth_required` while B current: `start_import@10,@11`, `start_ingest@10,@11`** — exactly A's offsets; acknowledged-stale = 0 (A's temporal limit preserved); control (b) fails at those same 4 offsets; 58 OLD-current / 24 B-current at report |
| R6-02 | worktree, dirty (fix applied) | fixed | 0 | **0 stale**; 58 OLD-current all exactly-one genuine `login required`; 24 B-current all replaced/no auth_required/`NEW_R`/hasSession; 0 control failures |
| R6-03 | worktree, dirty | defect (inverted) | 1 (must fail) | fail-closed check: candidate no longer exhibits the defect |
| R6-13 | worktree, dirty (final pre-commit bytes) | fixed | 0 | as R6-02 |
| **R6-15** | **clean exact head 91990ae9** | fixed | **0** | **PASS_FIXED, 0 stale, 58/24 split, 0 control failures, 83 ms** |
| R6-16 | clean exact head | defect (inverted) | 1 (must fail) | corroboration only |

### 4b. Prior-round closure controls re-run unchanged (bytes verified equal to archive copies)

| receipt | probe | source | exit | result |
|---|---|---|---|---|
| R6-04 / **R6-17** | R5 `a01-preflight-barrier-discriminator.mjs --expect fixed` (`d1e1d428…`) | dirty / **clean 91990ae9** | 0 / **0** | pass, 0 failures (S4-R4-A-01 C3 barrier + unchanged-session import control) |
| R6-05 / **R6-18** | R5 `a02-queued-refresh-discriminator.mjs --expect fixed` (`93465881…`) | dirty / **clean** | 0 / **0** | pass, 0 failures (C1/C2/P-C: nothing of B presented, B unrotated) |
| R6-06 / **R6-19** | auditor B's unmodified `bound-admission-probe.mjs` (`ae6d3e12…`) | dirty / **clean** | 0 / **0** | pass, 26 checks, 0 failures (coalescing / bound admission / persist failure / generation-0 controls) |

Note: these probes self-stamp `head` via `git rev-parse` — R6-04/05/06 show `88287cff` because the working tree was
dirty at parent HEAD; my `R6-NN.meta.json` records dirty=1 and the working-diff sha256 for attribution.

### 4c. New attributable vitest cases (NOT executed under vitest — no toolchain)

`test/session-ownership-preflight.spec.js` +151: new `describe("… (S4-R5-A-01)")` with, for **both**
`start_import` and `start_ingest`, an enumeration of the replacement-commit offset 0..40 that asserts (per offset) no
`auth_required` emitted while a session other than the run's own is current, B's refresh token never presented/rotated/
removed, no non-refresh request, guard released; classifies each offset as OLD-current-at-report (→ exactly one genuine
`login required`) or B-current-at-report (→ replaced detail, intent null, `hasSession:true`), and requires both
classes to be non-empty (a non-discriminating enumeration fails). Plus a control where B pairs only after the genuine
report (one `auth_required`, no retroactive second notification, B intact).

To give attributable evidence without vitest, a **dependency-free loader shim** (`probes/spec-shim/`, `register.mjs`
`a4d73436…`, `hooks.mjs` `c4726257…`, `vitest-shim.mjs` `35186294…`, `run-spec.mjs` `41a98da3…`) maps `vitest` to a
minimal `describe/it/expect/vi` and re-instantiates the file: module graph on `vi.resetModules()`. **This is not
vitest** and proves only that the spec's assertions hold/fail against the real modules under Node 20:

| receipt | spec source | filter | result |
|---|---|---|---|
| R6-07 | candidate spec, dirty | new block only | 3/3 pass (both entrypoint enumerations + control) |
| R6-08 | **same new block copied onto the predecessor export** (`predecessor-88287cff/test/R6-CANDIDATE-COPY.…spec.js`, `16c49c83…`; differs from the committed spec only by the three prettier-style reflows shown in `logs/R6-08-spec-copy-vs-committed.diff`) | new block only | **exit 1: both entrypoint tests FAIL** with `expected [{"kind":"auth_required",…,"generation":22}] toEqual []`; control passes → the new tests discriminate the predecessor |
| R6-09 / R6-10 | whole spec, dirty | none | 17/19 then 18/19 after adding `toBeGreaterThanOrEqual` to the shim (R6-09's one extra failure was a missing shim matcher, not a product failure) |
| R6-14 | whole spec, final pre-commit bytes | none | 18/19 |
| **R6-20** | whole spec, **clean exact head** | none | **18 pass / 1 fail — the single failure is `start_import: preflight refresh TIMEOUT …` which calls `vi.useFakeTimers()`, deliberately unsupported by the shim (explained harness limitation, not a product failure)** |

Shim byte note: R6-07/08/09 ran a `vitest-shim.mjs` lacking only the `toBeGreaterThanOrEqual` matcher line added
before R6-10; all later runs used the hashed final bytes.

### 4d. Syntax and gate substitutes
`node --check background.js` and the spec (OK); `scripts/check-js-syntax.mjs` 117 files OK on dirty (R6-11) and clean
head (R6-21); `scripts/check-flag-discipline.mjs` OK (R6-12).

## 5. Findings status

| ID | status at 91990ae9 |
|---|---|
| **S4-R5-A-01** | **Source-closed at the synchronous notification boundary, offline scope only:** predecessor reproduces at exactly A's offsets (10, 11) on both entrypoints; candidate emits zero stale `auth_required` across 82 schedules; OLD-still-current genuine failure remains visible exactly once (58 schedules); B never presented/rotated/removed. Not proved: native Chrome scheduling, packaged behaviour, browser positive/negative, full suite. Requires two fresh independent exact-head attestations (neither from this builder). |
| S4-R4-A-01, S4-R4-A-02/S4-R4B-01 | Prior narrow closures preserved (R6-17/18/19 pass on clean head; `shared/session.js` byte-identical). |
| S4-R5B-01/02/03 (nonmaterial) | Unchanged; out of R6 scope. R5B-02 (transport failure of a still-current session worded as login required) is untouched by design — genuine current-owner failure stays visible. |
| S4-R5-A-E01 / E02 | Remain open evidence gaps (see VALIDATION_REQUEST_1.md). |

### Observation (not a proved finding, not implemented — reported for parent disposition only)
The run-time terminal 401 path (`sessionLossError` → `run.onAuthLost()` → `broadcastAuthRequired("session expired …")`,
`background.js` :594/:841) also has an await boundary between the lock-decided `clearTokensIfSession(run.generation)`
(which itself bumps the generation) and the notification. A replacement establish queued behind that clear could in
principle commit in the same kind of microtask gap before "session expired" is emitted. This was **not** probed or
changed: the simple `generation` recheck used for preflight does not apply (the genuine clear always advances the
generation), so a repair would need the post-clear generation carried through — a wider change than the authorized
reporting fix. Smallest proposed re-scope if the parent wants it examined: one offline enumeration probe mirroring
§4a at that boundary, before any source change.

## 6. Not done / limits (honest)
- No `npm ci`, full suite, `npm run gates`, gitleaks scan, package build, browser run, DB, network, or lock.
- Hooks: 0/6 executed at commit (blocker above).
- New vitest cases were executed only under the shim, never under vitest; the fake-timer R5 test was not exercised.
- Native Chrome microtask ordering is unverified; A's temporal limit stands: the counterexample (and its closure) is
  pre-acknowledgement-continuation, not a post-ack, browser or credential-misuse event.
- Requested-model identity is unobservable here.
- No audit clearance is claimed; this is builder evidence for two independent successor attestations.

## 7. Next required action
Parent: (1) decide on the hook-gate blocker (accept `91990ae9` as frozen candidate pending gates, or recreate under
hooks); (2) dispatch two independent exact-head reviews of `91990ae9` (source closure distinct from artifact/browser
attestation); (3) grant the single validation bundle in `VALIDATION_REQUEST_1.md`. No remote publication was performed.
