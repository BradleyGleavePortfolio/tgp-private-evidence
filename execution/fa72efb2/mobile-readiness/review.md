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

---

# Round 2 delta (HEAD a876268c07ceaec5ae56b489466922dfbcda1a05, parent 89590423)

Scope: a delta audit of the one new commit, read-only under the same rules. The Round 1 bytes that are unchanged are not re-audited.
The commit's author and committer are both `Bradley Gleave <bradley@bradleytgpcoaching.com>`, with no trailers. Parent 89590423 was not amended.

## Verdict: GO (no A, no B). CI on PR #296 (node 22.13) remains the build/test gate, and the parent checks it.

I did not run tsc, lint or jest. The builder's reported local RCs (node v20) are their claim, not something I verified.

## Delta bytes

| File | +/- | sha256 @a876268c |
|---|---|---|
| src/components/coach/ExtensionPairingPanel.tsx | +22/-4 | 9f2dced85961a634db4de58f0f69e891631a26a7cfce6e4a9cafd5dbe9dfc775 |
| src/hooks/useExtensionPairing.ts | +51/-11 | fd38a64881793512e727c28446b86ef01ba15dae24e186fcc92cb242754bca19 |
| src/types/extensionImport.ts | +21/-9 | ce06daf89b77b08e58284c89749c9ee9c70c9c2aea1539c1e6bfc9252b0070af |
| src/components/coach/__tests__/ExtensionPairingPanel.test.tsx | +176/-13 | e30f09646b366d3eeba7c115891f9956ef692dc6d5d6fd4acd6fa54cfabc9340 |
| src/hooks/__tests__/useExtensionPairing.test.tsx | +152/-0 | d4845e7071399207e1c437bbc1cc0d291ac7a91a1d96b3fe4384dc136a6ed3dd |
| src/types/__tests__/extensionImport.contract.test.ts | +30/-0 | c48f20de675b64149eded5e731f7376ae22624cceeecb596525b85f11adeb5a7 |

The fixture is unchanged, so the Round 1 byte-equality result against 7fdcbc04 still holds.

## B1: CLOSED

- The readiness row now passes bare `pending` for every `run` value (ExtensionPairingPanel.tsx:249).
- `ChecklistRow` therefore takes only the `ellipse-outline` / `textMuted` branch and the `''` suffix branch; no "✓" is emitted. The row has no accessibilityLabel override, so its accessible name is the plain text, which carries no success marker.
- The terminal copy is now "Ended — check your import status for details" (:373).
- Tests:
  - A terminal-specific test (Panel test:535) asserts no "✓", no "checkmark", the muted colour present and the primary colour absent. The theme mock values `#999`/`#2c4a36` match the constants (test:26-27 vs :32-33).
  - A parametrized test covers none/open/terminal (:554).
  - These discriminate: reverting to `pending={run !== 'terminal'}` turns the icon primary-coloured and adds " ✓", which would fail both tests.

## B2: CLOSED

- **Foreground re-read.** The AppState `active` handler calls `fetchReadiness()` when `statusRef.current === 'paired'` (useExtensionPairing.ts:843), in addition to the existing `waiting` poll resume.
- **Single-flight, per epoch.** `readinessInFlightEpochRef` returns early when a read in the same epoch is outstanding (:417-418), and is released in `finally` only by its own epoch (:446). Because it is scoped by epoch, a stale read in flight cannot block a new epoch's read after a re-pair.
- **No retry loop.** There is no timer; a failure is swallowed, and only an OS foreground event or a new paired transition triggers another read. The number of reads is bounded by user app switches.
- **Late responses discarded.** The mounted/status/epoch guard is unchanged (:426), and the C5 intent check was added (:434-438).
- **Cleared on every exit from `paired`.** `go()` clears the reading and bumps the epoch (:373-375), and so does the identity-retire path (:747-749, the C4 closure).
- **Copy.** The present-tense strings ("Not started yet" and the others) are now refreshed whenever the coach returns to the app, which is the moment the card is looked at again after "Continue on your computer". That is sufficient for point-in-time honesty.
- **Tests** (hook test:1942-2010):
  - foreground while paired produces a second call and an updated reading;
  - a foreground overlapping an in-flight read produces no second call, and a new call follows once the first settles;
  - a foreground while waiting produces no `current()` call.

## C closures: all verified

- **C1 CLOSED.**
  - The decoder now requires a non-negative integer (extensionImport.ts:168), `null` exactly when `run === 'none'` (:171), and `source_declared === (declared_platforms ?? 0) > 0` (:173). Any violation yields `undefined`.
  - The panel's `?? 0` is gone. The `as number` at Panel:382 is sound: `sourceDeclared === true` means count > 0, which implies non-null.
  - `effectiveCount = declared ?? 0` (:172) is used only in the cross-check and never rendered, so it is not an unknown→zero leak.
  - Six fail-closed cases plus the valid `open/false/0` case are in the contract test (:633ff). Round 1 test inputs all still satisfy the new rules.
  - This matches the server exactly (7fdcbc04 service.ts:238-244).
- **C2 CLOSED.** The fixture sha `889d25c6…` is asserted inline (contract test:567).
- **C4 CLOSED.** See :747-749 above.
- **C5 CLOSED.**
  - The reading is attached only when `!thisIntent || !readIntent || thisIntent === readIntent` (:434-438).
  - `readIntent` is null only on `UNKNOWN_PAIR_CURRENT`, which never carries readiness, so the effective relaxation is only for a legacy pairing with no intent id. That is acceptable.
  - `importIntentIdRef` is fed by the pair/status echo (:468), which the tests rely on. Mismatch and match tests are at hook test:2013ff.
- **C6 CLOSED.**
  - The hook test at :2052 runs: paired → cancel → retry → paired again (new epoch), then resolves the first-epoch read.
  - At that point status is `paired`, so only the epoch check can reject the stale read.
  - It discriminates: removing `readinessEpochRef.current !== epoch` would attach the stale `open/1` reading and fail the final expectation.
- **C7 CLOSED.**
  - The per-row and a11y sweeps now walk string leaves of `toJSON()` (`collectText`, Panel test:395), not `JSON.stringify` of React elements, so there is no circular-Fiber risk.
  - The unqualified banned-word regexes (`\b(authorized|ready|connected|verified)\b`) now apply to the row's own text in every state, which makes them actually discriminating on the row.
  - The full-card sweep keeps the narrow "source … X" form because of the pre-existing, out-of-scope "Connected to your computer" and "Connected to TGP as" strings.

## Overclaim sweep of the delta

- The only new user-visible string is "Ended — check your import status for details".
- New non-comment lines containing authoriz/ready/connect/verif are only the test assertions that forbid them.
- The new code carries no platform names. `truecoach` appears only as the existing test `platformId` prop.
- Nothing new asserts server state beyond what the server returned.

## Round 2 C record (qualify and continue)

- **C10.** A failed foreground re-read keeps the previously read value (hook :398-446 doc, catch/omit paths). The same applies to an omitted block or an intent mismatch. The row can therefore show the last reading from an earlier foreground rather than going back to "unknown".
  - Impact: limited, since it is still a real server reading for this intent, and the next foreground retries.
  - Optional: clear to `undefined` when a successful response omits the block. The server itself treats omission as "read failed, unknown".
- **C11.** A phone left open on the card with no background/foreground cycle gets no refresh. Screen lock and unlock does produce an `active` event. This is acceptable under B2's minimum closure; no timer poll is wanted.
- **C12.** In the B1 tests, the `'checkmark'` substring assertions are inert because the Ionicons glyph is not literal text in this environment, as the test itself documents. The colour and "✓" assertions carry the check.
- **C13.** The builder's local gate RCs are unverified by me; CI on PR #296 decides.

## Commands run (Round 2; all read-only; all RC 0)

- `git log --oneline -3`, `git status --short`, `git diff 89590423 a876268c --stat|--numstat|-- <files>`, `git show a876268c -s --format=…`, `git rev-parse HEAD`.
- `git show a876268c:<file> | sha256sum` for each changed file.
- `grep -n` / `sed -n` on HEAD files, and on builder_summary.md from its Round 2 section.
