# S11-0 independent T0 review

**Verdict: NO-GO** on the draft at `f484d434…`. This is a read-only document review against committed `92b96715`; no tests or database work were run. G1 is real: the server `/complete` claim commits before inline settlement, while the P2002 replay branch returns an acknowledgement without calling the settle tail (`src/scout/scout.service.ts:375–410`). A gated, stored-epoch re-drive within that existing route is a suitably small repair; the arbiter remains the sole terminal writer (`src/scout/lifecycle/lifecycle.service.ts:414–445,486–510`). No new counts-to-Complete or unknown-to-zero rule is proposed.

## Findings

### B1 — The one-time harness and “A1 may start now” cannot both satisfy A2

**Where:** D-S11-6, lines 251–266; slice rows 301–302; J09–J11, lines 343–349.

**Blocked/harm:** The accepted S9-C worker supports neither pairing nor declaration/observation and composes only one optional mapping spec/rule (`test/utils/g2-s9c-worker.cjs:13,181–209`). A two-source signed-evidence run needs substantive worker composition, registry/fixture and authentication adapters, not just a changed action list. A1 starting on the present tree also cannot compose not-yet-landed S10-B/C code. Its pinned migration count/base (`test/utils/g2-s9c-pg-harness.ts:28–33`; bootstrap `:153–166`) become stale on S10-B/C landing, yet A2 is expressly forbidden from editing the shared harness. “Every other line byte-identical” is therefore not a viable implementation/proof rule. It would either block J09–J11 or silently encourage an unreviewed harness fork.

**Minimum textual fix:** Choose one: delay the single A1 harness until S10-B/C/D land and build all needed worker actions/DI/two-source fixtures once; **or** let A1 implement the currently available actions and assign A2 a strictly sequential edit to that *same* harness (including explicit base/migration descriptor transition, added S10 worker composition, and tests), with no fork. State which non-descriptor lines are allowed to differ from the donor. **Unblocks:** executable, nonduplicated A1/A2 proof and a clear one-writer schedule.

### B2 — “Two client principals” is not demonstrated by two direct-service workers

**Where:** D-S11-1 lines 74–93, D-S11-6 lines 261–266, J01/J07 lines 322–324 and 339–340.

**Blocked/harm:** The donor worker directly constructs `ScoutService`/`ScoutLifecycleService` and calls methods with a supplied coach id (`test/utils/g2-s9c-worker.cjs:54–76,181–215`). Two OS processes demonstrate separate caches and shared database locks, but do not by themselves demonstrate that a redeemed extension token can authenticate to Start or that phone and extension guards route to the same coach. The draft describes J01 as a cross-principal route proof without specifying an HTTP/guard harness.

**Minimum textual fix:** Either specify an authenticated HTTP/controller integration for the phone JWT and redeemed extension session, or narrow A1's claim to cross-process service/database composition and cite/require separate accepted route-principal tests for the H-C security boundary. **Unblocks:** a proof claim whose test mechanism matches the promised boundary.

### B3 — The readiness label can falsely imply source authorization

**Where:** journey step 3, line 108; D-S11-5 lines 229–246.

**Blocked/harm:** `source_declared` means only that a coach-scoped declaration row exists. S10 explicitly leaves whether that set authoritatively represents source accounts to G3-AUTH/Q5 (`docs/decisions/2026-09-26-s10-induction.md:473–483`). It is not a browser login, capability check, or verified source connection. Saying the phone may display “source ready” or treating the row as “Source authorized” risks a false readiness signal even though the field name itself is precise.

**Minimum textual fix:** Rename the server-observable step “declaration recorded”; prescribe neutral display semantics such as “declaration received,” never “source authorized/ready,” and state real authorization remains unknown until the owner-reserved verifier/principal policy. **Unblocks:** honest client binding without expanding the route.

### B4 — J07 demands 404 from a route deliberately returning 204

**Where:** D-S11-7(5), lines 283–285; J07, lines 339–340.

**Blocked/harm:** `POST scout/progress` explicitly returns 204 for a fenced or unstarted run, with no gated write (`src/scout/scout.controller.ts:66–85`; `scout.service.ts:125–154`). “Every cross-coach read or write is a uniform 404” is too broad and could prompt a breaking route change or an impossible acceptance assertion. The correct security property is no foreign state access/mutation, not one response code on every route.

**Minimum textual fix:** Scope 404 to the routes whose contracts require it; explicitly keep `/progress`'s 204 ignore behaviour and assert that it does not change or reveal another coach's run. Account for legacy-string semantics separately. **Unblocks:** J07 without altering the accepted API.

### C1 — Minor evidence/wording corrections

- D-S11-4 line 210 cites `lifecycle.service.ts:437–438` for the terminal CAS, but the actual call is at `:435` and the guarded SQL is in `writeTerminal` beginning at `:486`. Point there.
- G2 and J03 (lines 137–145, 328–330) state an unconditional one-flush-interval mirror bound; that only holds when the owner process survives and its scheduled flush succeeds. J04 correctly covers a lost pending snapshot. Add the condition.
- §7/Q-S11-4 list many owner reservations but omit S10 Q3's L8 retention and erasure policy for its three tables (`S10-DOC:479–480`). Add it explicitly; the readiness read does **not** itself set a retention policy.

## Cross-check conclusion

The code-backed citations sampled across the journey map, G1–G8 and the path table largely match the committed tree: pairing routes and `readSetup`, run Start and gate, ingestion key, progress cache, reconstruction/settle, status and roster routes, and production Redis guard were spot-checked. S11-B is sequenced behind S10-C for `lifecycle.service.ts`; S11-C's contract regeneration is sequenced behind S10-C's generator owner, and no proposed product file overlaps a concurrently owned S10 path. The synthetic J09 `complete` is a *local* source-signed fixture proof, not authority to enable real-platform Complete; Q-S11-4 correctly reserves that enablement. The B findings above need textual resolution before granting the slices.

## Delta review 1 (6bf712da)

**Verdict: NO-GO — B1, B2 and B3 close; B4's replacement introduces an impossible acceptance assertion.** Reviewed only the fix-1 diff. C1 remains as recorded above.

- **B1 closed.** D-S11-6 now names A1 and then A2 as sequential writers of *one* harness, allows the needed worker construction/registry and guard updates, and advances the base/migration descriptor after S10 lands (lines 265–295, 332–339). It no longer requires unmodified donor composition for a two-source scenario.
- **B2 closed.** D-S11-1 and J01 explicitly call this a direct-service, cross-process proof, not authentication of phone and extension principals (lines 90–105, 351–361). The cited route/guard spec files exist in the committed tree.
- **B3 closed.** Step 3 and readiness now say only “declaration recorded/received,” explicitly disallow “source authorized/ready/connected,” and reserve the real authorization decision (lines 119, 255–261).
- **B4 not closed — new B defect in the fix (minimum text correction required).** Revised J07 says a cross-coach `/progress` “gets 204” with **“no cached snapshot for the foreign run”** and “leaves nothing readable by either coach” (lines 376–382). That is not the accepted legacy-resolution behaviour: a UUID belonging to coach A resolves as *legacy* for coach B (`lifecycle.service.ts:221–241`), `recordResolvedProgress` caches it under B (`scout.service.ts:143–173`), and the flush persists a B-owned snapshot with no ingest-row FK (`:197–225`). Afterward B's `import/status` can read **B's own** snapshot (`:427–457`), so the draft's broad 404 statement for `import/status` (lines 312–319) also needs qualification for that sequence. None of this writes to or reveals A's rows. **Blocked/harm:** J07 would fail against accepted code or induce a breaking “fix” to legacy semantics. **Minimum fix:** Assert 204 and *no mutation/disclosure of coach A's data*; allow the B-scoped legacy snapshot and resulting B-scoped status, distinguish an initial foreign 404 from status after B has created its own evidence, and keep the separate legacy case. This restores the security property without changing the API.

## Delta review 2 (1ccebd53)

**Verdict: GO for the T0 document.** Reviewed only the fix-2 changes to D-S11-7(5) and J07. They now explicitly distinguish the initial 404 (no B-owned evidence) from a B-owned legacy snapshot/status after B posts progress using A's UUID, while asserting no access to or mutation of A's rows (`s11_0_decision_draft.md:312–324,381–392`). That matches `lifecycle.service.ts:221–241` and `scout.service.ts:143–173,197–225,427–457`; the prior B4 is closed. No new A/B defect appears in this delta. The original C1 citation, flush-bound and owner-list hygiene observations remain recorded, not blockers.
