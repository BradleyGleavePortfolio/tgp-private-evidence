# UX-07 shared accessibility/presentation test plan (design-only)

Parent EXEC-95633079. Bounded T2 planning-only, no authority. This is a **test plan**, not a test run: no test is executed, installed, or scheduled by this document, and it does not mandate new test systems. Per parent disposition, the working rule is: **apply only the checklist rows relevant to a changed surface, through existing test infrastructure** (the mobile Jest/RTL toolchain and whatever contrast/lint step already exists), not a standing requirement to build or run eight new test systems. It tells the mobile UX-07 writer and the extension presentation writer what to prove and what evidence shape to produce when they implement, so both consume one shared method without conflict, per this task's requirement for "actionable per-surface acceptance and ownership handoff." It does not create a new audit/control per the SafetyROI doctrine's C-class rule ("C never creates another fixer/audit cycle by itself") — it reuses the acceptance rows in `ACCESSIBILITY_ACCEPTANCE_CHECKLIST.md` as the thing being tested, and reuses the existing a11y test donors already named in the official map (`#292`, `#294`) rather than inventing a new harness.

## 1. What already exists (reuse, do not recreate)

| Existing asset | What it proves | Source |
|---|---|---|
| `import-journey/__tests__/` a11y suite donors from #292 | Digit-by-digit pairing-code announcement, real clipboard-result reporting, 1.6× scale cap | `OFFICIAL_UX_JOB_AND_PR_MAP.md` PR table; journey J5 |
| #294 component tests (controlled, no lifecycle engine) | `ImportProgressView`/`ImportResultView`/`ImportStatusFrame` render callbacks correctly in isolation | `OFFICIAL_UX_JOB_AND_PR_MAP.md` PR table |
| Existing mobile Jest/RTL toolchain | Component-level render and interaction tests | implied by S6/mobile repo, no new toolchain proposed here |

UX-07's test plan is additive only where the checklist rows above are not already covered by these donors, and it explicitly reuses their pattern (typed local copy, side-effect guards, callback-only views) rather than introducing a new test framework, consistent with the doctrine's delete-test ("If a standard tool already solves the problem: USE THE STANDARD TOOL").

## 2. Check types mapped to existing infrastructure (apply selectively per changed surface, not as eight mandatory new systems)

These are not eight new test systems to stand up. They are eight **check types**, each already expressible through the mobile repo's existing Jest/RTL toolchain or an existing lint/contrast step, or the extension's own existing test tooling once it has one. An implementer touching one surface runs only the check types relevant to what actually changed on that surface (e.g., a copy-only change to one panel needs the contrast check and the relevant component assertions, not all eight). No new CI job, harness, or standing test system is proposed by this table.

| Check type | Proves | Method (existing tooling only) | Owner | Run when |
|---|---|---|---|---|
| 1. Static token/contrast check | A11Y-08, token exclusion list §2 rows | Automated contrast check via the existing lint/test step, computing foreground/background ratio against actual token pairs | mobile UX-07 writer; extension presentation writer | Any surface where text/background token pairing changed |
| 2. Component render/interaction test | A11Y-01, A11Y-02, A11Y-04, A11Y-11 through A11Y-15 | RTL/Jest tests per component: touch-target size assertion, focus-order assertion, text+glyph presence assertion for the state variant(s) that actually changed | mobile UX-07 writer (sole writer of `importJourneyUI.tsx` per `DEPENDENCY_DAG.md`) | Any component whose markup/state logic changed |
| 3. Dynamic-type / 200% zoom snapshot | A11Y-03 | Snapshot or visual-regression pass at 100% and 200% OS text scale (and the 1.6× pairing-code cap case) for the changed screen | mobile UX-07 writer | Any screen whose layout or type sizing changed |
| 4. Reduced-motion parity snapshot | A11Y-06 | Snapshot pass with `prefers-reduced-motion`/OS reduce-motion forced on; assert static equivalents present and no animation-only state cue | mobile UX-07 writer; extension presentation writer | Any surface that introduced or changed a transition/animation |
| 5. Screen-reader announcement test | A11Y-05, A11Y-12, A11Y-14 | Accessibility-tree/announcement assertions (existing RTL a11y query patterns from #292) confirming one polite announcement per state change, not per tick | mobile UX-07 writer | Any surface whose announced states changed |
| 6. Roman on/off parity test | A11Y-09 | Render both flag states of the changed surface; assert identical layout/information, absent portrait when off | mobile UX-07 writer | Any surface with a Roman-on/off variant that changed |
| 7. Extension popup layout test | A11Y-16, A11Y-17 | Fixed-viewport layout check (popup's constrained width/height) at default and 200% browser zoom; focus-order and target-size assertions in the popup DOM | extension presentation writer | Any popup panel whose actual existing markup changed |
| 8. Honest-unknown / offline-copy assertion | A11Y-18, A11Y-19, A11Y-20 | Component tests that pass "not yet known" / "not sent" / `unknown`-decoded fixtures into the changed view and assert the exact truthful copy renders (never blank, never zero, never a false "sent"/"stopped" claim) | mobile UX-07 writer (mobile); extension presentation writer (popup adverse states, once UX-05 extension lands) | Any surface whose unknown/offline rendering changed |

Check types 1–8 map one-to-one onto the acceptance rows in `ACCESSIBILITY_ACCEPTANCE_CHECKLIST.md`; no check type exists without a named acceptance row behind it, per the doctrine's "no hypothesis-free failure invention." None is mandatory on every PR — each applies only when its acceptance row is actually implicated by the surface that changed.

## 3. Sequencing and ownership (must not conflict with other UX writers)

- Check types 1, 2, 3, 4, 5, 6, when relevant to what changed, apply to `importJourneyUI.tsx` and are owned by the **mobile UX-07 sole writer**, who is also the mobile entry-UI writer sharing that file with UX-02 (`DEPENDENCY_DAG.md` "Parallel lanes"). This plan does not add a second writer to that file.
- Check types 1, 4, 7, 8 (extension portion), when relevant, apply to `popup/*.html`/CSS and are owned by the **extension presentation writer**, who is sequential across UX-03 → UX-04 → UX-05 → UX-07 CSS per the same table. UX-07's extension checks are additive to whatever popup markup exists at the time that writer's own UX-03/04/05 work lands; UX-07 does not gate or reorder that sequence.
- Check type 8's extension half cannot apply meaningfully until UX-04/UX-05 extension presentation exists (adverse and unknown states are those surfaces' content), so it is **recorded now as a deferred check, not run now** — consistent with "GATED (must wait)" states already declared for UX-04/05 extension in `DISPATCH_READY_REGISTER.md`. This plan does not change that gate.
- No check here runs, is scheduled, or is claimed as passing by this document. This is a specification of what "green" means per surface, for the implementer to apply selectively, through existing infrastructure, when that surface actually changes — matching `DEPENDENCY_DAG.md`'s description of UX-07 as "soft (incremental): a11y suite runs on each surface as it lands."

## 4. Evidence shape when a check is actually run (for the future implementer, not produced here)

When a check type is applied to a changed surface, record: surface id (Jn / extension popup panel name), acceptance row id(s) covered, pass/fail per state variant enumerated in the matrix, and the exact fixture used for honest-unknown/offline cases. This is proportional evidence per the SafetyROI doctrine (reversible, local, non-customer test evidence; no dual-audit ceremony for a component test) — a single component-test run through existing infrastructure is sufficient; this plan does not request a second validating layer over these checks absent a demonstrated defect, and does not request a new test system beyond what already exists.

## 5. What this test plan does not do

It does not run any test, touch any worktree, install any dependency, or claim any current pass/fail state. It does not create a new fixer/audit/control loop: findings from any future run are ordinary A/B/C classification under the SafetyROI doctrine at implementation time, not a new governance instrument. It does not block UX-02's code-start (per `DEPENDENCY_DAG.md`, UX-07 is soft/incremental on every visible PR).
