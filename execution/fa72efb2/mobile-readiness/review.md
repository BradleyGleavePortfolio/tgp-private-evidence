# Mobile readiness consumer: independent T2 audit (EXEC-FA72EFB2)

Auditor: independent T2 reviewer, parent session fa72efb2. Read-only. No npm, jest, tsc or eslint was run, and nothing was edited or committed.
Subject: `/home/user/workspace/worktrees/fa72-mobile-rdy`, branch `fa72/mobile-readiness`, HEAD `89590423767f899918da5847efd0803a3ea847b4` (one commit on `affc281`), mobile draft PR #296.
Server truth: backend `7fdcbc04`, read with `git -C /home/user/workspace/worktrees/fa72-s11c show 7fdcbc04:<path>`.

## Verdict: NO-GO as-is. GO once B1 and B2 are closed.

Both closures are small: about 5 to 20 product LOC plus one test each. They do not require re-auditing anything else. Every other check passes or is C only.

## Byte identity (matches builder_summary.md)

| File | +/- | sha256 |
|---|---|---|
| src/types/extensionImport.ts | +101/-3 | 1dc13e035737edd3616c816d17adb6c53d1fea6b9b39884ca7d73370a1627efb |
| src/api/extensionPairApi.ts | +9/-0 | 91806122e6e20a179b4e93f4a44c0da3afa743ae4b96110ebc83954d8f831bbd |
| src/hooks/useExtensionPairing.ts | +86/-1 | 6bcc4dcaed5922210b16d28ba10a724a022a5329f28fd08c01cf1572bff5d964 |
| src/components/coach/ExtensionPairingPanel.tsx | +53/-1 | 5a247b29785acf9faf0da9feb36b0f08cd2550811946e04bd1b40f51682e8ebd |
| src/types/__fixtures__/s11cPairSurface.7fdcbc04.json | +899/-0 | 818bada2301e4b2e473cc4c269641f761a6a924d0c4b3f418d4575e7b0d53459 |
| src/types/__tests__/extensionImport.contract.test.ts | +161/-0 | 789b70210b968ea5c94001f1887d87746f842c156b037876e786e87e2cb7993a |
| src/hooks/__tests__/useExtensionPairing.test.tsx | +149/-1 | 6ad331a23c87d0067888e4501c993b0c00a2a5296e978630f325b97e5953924c |
| src/components/coach/__tests__/ExtensionPairingPanel.test.tsx | +115/-0 | 42d2052ba51414f3834c96d8264d207d06b3d05cd345b47ccd3298043b95139a |

Source artifact `7fdcbc04:docs/contracts/importer-openapi.json` sha256 is `889d25c6a529512596b01ba6554bbf4038ca7f33fdc66f6c9c14118b44dc53f4`. This equals the `$fixture.source.sha256` recorded in the fixture.

## Checks

### (1) Parser strictness and fail-closed unknown: PASS, with C findings

- `decodeReadiness` (src/types/extensionImport.ts:150-167) returns `undefined` in each of these cases:
  - a non-object or array (:151);
  - `run` outside the closed enum `['none','open','terminal']` (:119, :153-156);
  - a non-boolean `source_declared` (:157);
  - a `declared_platforms` that is neither null nor a finite number (:159-161).
- It never coerces to false or 0.
- It is folded into `decodePairCurrentResponse` independently (:222-228):
  - A bad block leaves the rest of the response intact.
  - The invalid-payload path returns `UNKNOWN_PAIR_CURRENT` before readiness is read, so no block attaches to a rejected reading.
- It matches the contract. `PairReadiness` has `type: number, nullable: true` for `declared_platforms`, with no `integer` and no `minimum`, and `required` lists all three fields (openapi at 7fdcbc04).
- **C1. Cross-field rules are not enforced.** The decoder comment admits this (:145-148). It accepts:
  - a negative count;
  - a non-integer count;
  - `declared_platforms: null` together with `source_declared: true`;
  - a count that disagrees with `source_declared`.

  The panel then renders `readiness.declaredPlatforms ?? 0` (ExtensionPairingPanel.tsx:364). That means a null count on a declared reading would display "Declaration received (0 sources)". This is literally unknown→zero, the pattern mission invariant 6 forbids, and a negative count would show as "-1 sources".
  - Why only C: the landed server cannot emit these. `readReadiness` returns null only on the `none` branch, together with `source_declared: false`. Otherwise it returns `Set(...).size`, which is an integer of 0 or more, with `source_declared = size > 0` (7fdcbc04 extension-pair.service.ts:238-244).
  - Recommended closure (cheap, can ride with B1): in `decodeReadiness`, require an integer of 0 or more, require `declared_platforms === null` exactly when `run === 'none'`, and require `source_declared === (declared_platforms ?? 0) > 0`; otherwise return `undefined`. Then drop the `?? 0` fallback.

### (2) Fixture is the exact 7fdcbc04 surface, and the drift test bites: PASS, with C findings

- I checked this mechanically (python, read-only):
  - All 5 path items are byte-equal as JSON to the artifact.
  - All 12 schemas are equal.
  - The fixture schema set equals the transitive `$ref` closure of those paths.
  - `openapi` is 3.1.0 in both.
  - The only schema added versus C1 is `PairReadiness`, and the only changed schema is `PairSessionResult`.
- The tests pin these properties (contract.test.ts):
  - the commit and the path set (:565-570);
  - "exactly one added schema" (:573-578);
  - `PairSessionResult.required` without readiness;
  - PairReadiness `required`, its enum, and `{nullable:true,type:'number'}`;
  - an enum mirror against `READINESS_RUN_STATES`.

  If the fixture were regenerated from a drifted artifact (enum, requiredness or nullability), or if the decoder enum changed, these tests fail.
- **C2.** The test title at :565 says "sha256 + commit pinned", but unlike the C1 block (:348-349) it does not assert `$fixture.source.sha256`. Add one `expect(...sha256).toBe('889d25c6…')` line.
- **C3.** As with C1, mobile CI cannot detect a later backend change. That needs a fixture regeneration, so it is a process issue, not a code issue.

### (3) Hook: the extra pair/current read. FAIL on B2, otherwise PASS

- **Single-flight.** Exactly one `extensionPairApi.current()` fires, from the `waiting→paired` branch only (useExtensionPairing.ts:444-447).
- **No retry storm.** There is no timer and no retry; the catch block swallows errors (:418-421).
- **No gating or demotion.** `go('paired')` runs before the read (:445), and the read only calls `emit('paired',…)` when a block decoded (:414-416).
- **Clearing and staleness.** Every `go(next !== 'paired')` clears the ref and bumps the epoch (:364-367). The late-response guard checks mounted, status and epoch (:410). On unmount, `mountedRef` is set false (:818).
- **Re-pair.** A re-pair goes through `go('minting')`, which bumps the epoch, so no stale reading can attach to the new session.
- **No fabricated server behaviour.** The data is exactly what the server returned.
- **C4.** The identity-change retire path sets status to idle with direct `statusRef`/`emit` calls (:705-720). It does not clear `readinessRef` or bump the epoch, so a prior reading rides along in `idle` state.
  - Harm: none today. The panel renders the row only in `paired` (Panel:198, :228), and the next `go('minting')` clears it. Any in-flight fetch is dropped by the `statusRef !== 'paired'` guard.
  - Recommended: clear the ref and bump the epoch there too, for symmetry.
- **C5.** The empty-body `pair/current` reads the coach's unsuperseded setup (7fdcbc04 service.ts:192-193). The hook does not check `decoded.importIntentId` against `importIntentIdRef.current`, nor `decoded.status === 'paired'`. A second-device `pair/init` inside that one round trip would attach the new setup's readiness to this card.
  - This is a narrow, real multi-device window, so it stays C.
  - Recommended: discard when both ids are non-null and differ, or use `pair/session(import_intent_id)` when the id is known.
- **B2: the snapshot is presented as current and goes stale in the primary flow.** See the Findings section.

### (4) Copy honesty, including a11y text: FAIL on B1, otherwise PASS

- The strings are "Import setup", "Not started yet", "Waiting for a declaration", "Declaration received (N source|sources)" and "Finished — check your import status for details" (Panel:356-367).
- None of them says authorized, ready, connected or verified. There are no platform names; only the count is shown. Terminal detail is not invented; the row points to the existing status read. An absent block renders no row (Panel:228-237).
- Accessibility: RN `Text` children are the accessible name. There is no `accessibilityLabel` override on `ChecklistRow`, so screen readers read the same strings, including the " ✓" suffix at :396. The card's `accessibilityLiveRegion="polite"` (:209) announces the late-arriving row.
- The card title "Connected to your computer" and the row "Connected to TGP as …" (:211, :217) are pre-existing landed bytes and refer to the pairing, not the source. They are out of scope and I did not re-audit them.
- **B1: the terminal run renders as a success checkmark.** See the Findings section.

### (5) Tests discriminate: PASS, with C findings

- Parser: 12 fail-closed cases, every enum member, and the fold / no-fold behaviour (contract.test.ts:600-690). These discriminate.
- Hook tests cover:
  - undefined before resolve;
  - one call with no arguments;
  - the none and terminal populations;
  - an omitted block, a malformed block and a transport rejection, each with `status` still `paired`;
  - clearing on cancel and retry;
  - a late response after cancel (hook test:1910).
- **C6.** In the late-response test, the status guard and the epoch guard both fire, so the epoch guard is never exercised on its own. The case that would isolate it is `paired → cancel → retry → paired` again before the first read resolves. This is not a defect.
- **C7.** The per-row sweep uses `JSON.stringify(getByTestId(...).props.children)` (Panel test:462). Those children are React elements on a host `View`, and under React 19.2 dev their `_owner` may be a circular Fiber. The result is one of two things:
  - JSON.stringify throws, and CI goes red. That is visible, not silent.
  - It serializes, and then it does sweep the text.

  The full-card sweep (:476-489) only matches "source (is )? X" phrases, so it guards against future regressions rather than the current strings. The exact-copy `toHaveTextContent` tests are the ones that actually discriminate. The PR #296 CI (node 22) decides this; the parent checks CI.
- There is no test for B1 (no ✓ on terminal) and none for C1's cross-field cases.

### (6) Flag gating unchanged: PASS

- The diff touches no `src/config/**`, no featureFlags and no flag defaults.
- The read is reachable only from `doPoll`, which is scheduled only by `start()`. `start()` returns early when the feature is off (useExtensionPairing.ts:489), and mirror hydration reads only when `enabled` (:736).

## Findings (A/B)

**B1: a terminal run shows as a completed or success check.**
- CLASS: honesty / fabricated server outcome (mission invariant 6; D-S11-5 "terminal carries no detail").
- CONCRETE HARM: `pending={readiness.run !== 'terminal'}` (Panel:235) renders the green `checkmark` icon and the label text "Import setup ✓" (:389-396) next to "Finished — …". But `terminal` covers failed, cancelled and timed_out runs; D-S11 G4 notes that a deadline-expired run ends `timed_out`. A coach, and a screen reader, gets a success mark for a run that may have failed, and may never open the status read the row points to.
- DECISION BLOCKED: landing PR #296 as-is.
- MINIMUM CLOSURE: render the readiness row with the neutral (pending) icon and no " ✓" for every `run` value, i.e. `pending` always true. Add one panel test asserting that the terminal row contains no "✓" and no checkmark icon. Optionally use "Ended" instead of "Finished".
- EXECUTION UNLOCKED: GO on the copy/rendering axis.

**B2: the readiness row is a one-shot snapshot shown as present tense, and goes stale in the flow the card itself directs.**
- CLASS: stale or false UI claim.
- CONCRETE HARM:
  - The only read happens at the instant `pair/status` flips to `paired` (useExtensionPairing.ts:444-447). At that instant no Start has been accepted, so the server returns `run: 'none'` (7fdcbc04 service.ts:238), and the row reads "Import setup: Not started yet".
  - The card then says "Continue on your computer" (Panel:239). Once the coach starts the import there, the phone keeps saying "Not started yet" indefinitely: `paired` has no poll, and the AppState handler refreshes only `waiting` (:800-805).
  - The coach returning to the phone sees a statement the server would now contradict. Plausible outcomes are a re-pair, which supersedes the setup, or a support contact.
  - Net effect: in the common path this row almost only ever displays a claim that becomes false.
- DECISION BLOCKED: landing PR #296 as-is.
- MINIMUM CLOSURE, either of:
  - (a) Preferred. In the existing AppState `active` handler, also call `fetchReadiness()` when `statusRef.current === 'paired'`, guarded by a small in-flight ref so it stays single-flight. It reuses the existing epoch and status guards (about 6 LOC), plus one hook test: foreground while paired produces exactly one more `current()` call and an updated reading.
  - (b) Make the copy point-in-time, e.g. "Not started when paired", with the other states qualified the same way.
- EXECUTION UNLOCKED: GO on the hook axis.

No A findings.

## C record (qualify and continue)

- C1: cross-field and integer validation, plus the `?? 0` in render; unreachable from the landed server. Recommended to fold into the B1 fix.
- C2: the S11-C fixture sha256 is not asserted in the test.
- C3: backend drift is detected only when the fixture is regenerated.
- C4: the identity-retire path does not clear readiness; not rendered.
- C5: no intent-id cross-check on the `pair/current` reading.
- C6: the epoch guard is not independently tested.
- C7: the row sweep may throw on circular React elements; CI (PR #296) decides.
- C8: the builder's tooling gap (no node_modules, no hooks) is real. The parent's CI gate on PR #296 is the closure for this, as the review grant states; it is not an audit finding.
- C9: local refs show `7fdcbc04` on `fa72/s11c` and `origin/land/s11c` only; I did not confirm it on backend `origin/main` from this clone. The grant states it is landed, and the parent owns that binding.

## Commands run (all read-only; all RC 0)

- `cat` of WORKER_RULES.md, MOBILE_READINESS_REVIEW_GRANT.md, MOBILE_READINESS_GRANT.md, builder_summary.md.
- `git log`, `git status --short`, `git show --stat HEAD`, `git diff HEAD~1 HEAD -- <each file>`, `git diff --numstat`, `sha256sum` of the changed files, and `grep -n` / `sed -n` on HEAD files (worktree fa72-mobile-rdy).
- `git -C worktrees/fa72-s11c show 7fdcbc04:docs/contracts/importer-openapi.json` (also written to /tmp/aud_s11c.json), `7fdcbc04:src/extension-pair/extension-pair.service.ts`, `7fdcbc04:src/extension-pair/extension-pair.controller.ts` and `7fdcbc04:docs/decisions/2026-09-26-s11-journey.md`.
- `git branch -a --contains 7fdcbc04` and `git log -1 origin/main` in fa72-s11c.
- A python3 read-only comparison of fixture versus artifact (paths, schemas, $ref closure, C1 delta).

I did not read the DTO file at 7fdcbc04; the OpenAPI schema and the service were sufficient. Nothing was written outside this review file and /tmp/aud_s11c.json.
