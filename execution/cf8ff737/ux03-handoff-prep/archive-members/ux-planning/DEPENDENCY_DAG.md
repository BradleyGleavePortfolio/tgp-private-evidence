# Importer UX dependency DAG (source-only; UX-0N labels are not dependency order): revision 2

Worker `plan_importer_ux_lane`, parent EXEC-e7d2385c, revision 3 about 21:15 UTC (rev 2 preserved in `rev2-detailed/`) (rev 1 preserved in `rev1-original/`). Rev 2 changes: `M5-REBASE` node removed: #289–#292 heads are ancestors of S6 baseline `d51a1910` via composition commit `3e9249f`; new gate `S6-BASE` (S6 successor = mobile UX base); serialization of shared-file writers made explicit. Companion to `OFFICIAL_UX_JOB_AND_PR_MAP.md` (vocabulary in its §3). Edges are gates, not schedule dates. S1–S12 are mission phases, not a competing sequence; UX outcomes attach to whichever phase freezes the contract they consume.

## Graph

```text
  public main a5933fd6 ── #289 22354984 ─┐
                          #290 ed0342e9 → #291 d2f0d31c → #292 34088677 ─┴► 3e9249f compose (already in S6) ─► … ─► S6 baseline d51a1910 ─► accepted S6 successor (ordinary no-bypass commit, same-review final attestations; snapshot R2 tree acb41c2b, ten paths, 00-09 validating) = S6-BASE
  #293 003a9774 ─┐
  #294 5cbf0de3 ─┴► ROMAN-DONOR (targeted source compare onto S6-BASE; objects not in local store)
                                                   │
  JOURNEY-SPEC (UX-01.design, journey worker) ─────┼──────────────────────────┐
                                                   ▼                          ▼
              ┌──────── UX-07 design system & a11y (mobile T2, extension T1) ─┤  (cross-cutting; starts now)
              │                                    │                          │
              │    UX-02 Roman entry (T2) + J3 restyle (T2) ◄──┤   UX-01 account-scoped state (T4)
              │                                    │            │
  S7-1′ compose S3+S5 ─► S7-2′ C1 + forward-2.x regen ──────────┴─► UX-01 intent binding
              │                          │
              │           G3-AUTH freeze ┤ (revocation, attribution, capability, transport)
              │           EXT-PKG (WS1)  ┤
              │                          ▼
              ├──────────────► UX-03 desktop handoff & pairing (mobile T4 ∥ extension T4)
              │                          │
              │      S7-L lifecycle contract (Start/cancel/deadline/terminals/counts; MISSING)
              │                          ▼
              ├──────────────► UX-04 start/progress/stop (extension-owned Start; phone mirrors, may request Stop via server; extension T4 ∥ mobile T4)   ┐ same sole writer per repo:
              │                          │                                             │ mobile status/result files
              │      S9 reason codes ────┼─► UX-05 failure/partial/recovery (T4)       │ (ImportResultView, StatusFrame,
              │                          │                                             │  copy, i18n) and extension
              │      S7-REV review schema ─► UX-06 review-contract alignment (T2, disjoint files, separate writer)
              │      S8 native writers ──┐                                             │ popup.html / result.*
              │      S9 reconciliation ──┴─► UX-06 results & native deep links (T4)    ┘ → sequential 04 → 05 → 06
              │                          │
              └──────────────► UX-08 journey tests (as surfaces land) ─► packaged/second host (S11) ─► usability study + V1 traces (S12)
                                         ▲
                             privacy-owner scope ─► UX-08 funnel (T4)
```

## Edge table

| From (gate) | To (job) | Kind | Evidence that satisfies |
|---|---|---|---|
| [#289](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/289)–[#292](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/292) heads | S6-BASE | already satisfied (Class C: public branch bases lag) | `git merge-base --is-ancestor` each → ancestor of `d51a1910`; composition commit `3e9249f` (parents `34088677` + `22354984`); no new job, no rerun |
| Accepted S6 successor (existing S6 lane: bounded validation, ordinary no-bypass commit, same-review final attestations; snapshot R2 tree `acb41c2b`, ten paths, 00 to 09 validating; mobile repo has no hooks) | S6-BASE | hard for mobile code-start | existing S6 evidence; not rebought by UX; not a new review or test job |
| S6-BASE | UX-01.state, UX-02 flag gating, UX-03 (mobile), UX-04/05 (mobile), UX-06, UX-08 funnel | hard | S6 successor accepted as mobile base |
| [#293](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/293)/[#294](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/294) | ROMAN-DONOR | parent disposition | targeted source compare onto S6-BASE (objects absent locally); adopt as donors / cherry-pick / supersede with citation |
| ROMAN-DONOR | UX-02, UX-07, UX-04/05/06 (mobile) presentation | hard for code | disposition recorded |
| JOURNEY-SPEC | UX-01.state, UX-02, UX-03, UX-04, UX-05, UX-06, UX-07, UX-08 | hard for code, soft for design | `journey/*.md` accepted by parent |
| S7-1′ → S7-2′ | UX-01 intent binding, UX-03 | hard | regenerated forward-2.x contract byte-equal drift test; consumer fixtures; `rls-c1-setup` once |
| G3-AUTH | UX-03, UX-04, UX-01 sign-out semantics confirmation | hard | auth-owner freeze record of revocation/attribution/capability/transport |
| EXT-PKG | UX-03 (extension), UX-04 (extension), UX-07 (extension) packaged tests | hard for packaged proof | packaged-extension load test on min Chrome + stable |
| S7-L | UX-04, UX-05, UX-01 run-state consumer types | hard | generated contract + fixtures + old/new compatibility tests |
| S7-REV | UX-06 alignment | hard | single generated review schema; intent-required requests |
| S8 + S9 | UX-06 results/deep links; UX-05 reason codes | hard | owned native IDs in result manifest; reconciliation counts; relationship validation tests |
| UX-07 | every visible UX PR | soft (incremental) | a11y suite runs on each surface as it lands; UX-07 does not block code-start of UX-02 |
| UX-01…07 accepted | UX-08 journey tests | hard | surfaces exist |
| S11 second host | UX-08 packaged/second host | hard | same kernel on ≥2 hosts |
| S12 authorization + privacy scope | UX-08 study/V1/funnel | hard | approved data handling, authorized platform + accounts |

## Critical path (contract-driven, not UX-numbered)

`S7-1′ → S7-2′ → G3-AUTH → S7-L → UX-04 → UX-05 → (S8+S9) → UX-06 results → UX-08 (S11/S12)` (UX-04→05→06 are sequential under one mobile status/result writer). UX-03 hangs off S7-2′+G3-AUTH and can complete before S7-L. UX-01.state, UX-02, J3 restyle and UX-07 are off the critical path and are the only codeable items before any S7 contract; all of them base on S6-BASE.

## Parallel lanes that never collide

| Lane | Writers | Disjoint paths |
|---|---|---|
| Mobile journey entry UI (UX-02, J3 restyle, UX-07 primitives) | one sole writer | `import-journey/{ImportOfferCard,ImportSetupView,importJourneyUI}.tsx`, one mount each in `CoachHomeScreen.tsx`, `SettingsScreen.tsx`, `CoachNavigator.tsx` |
| Mobile status/result UI (UX-04 → UX-05 → UX-06 results, sequential) | one sole writer | `import-journey/{ImportProgressView,ImportStatusFrame,ImportResultView}.tsx`, `importJourneyCopy.ts`, `i18n/en.json` (copy/i18n shared with entry UI → coordinate as one file owner per PR) |
| Mobile state/pairing (S6/mobile state writer) | one writer | `src/storage/**`, `src/hooks/useExtensionPairing.ts`, `src/services/authActions.ts`, `src/analytics/events.ts`, `src/api/extensionPairApi.ts` |
| Mobile review contract | one writer | `src/api/importReviewApi.ts`, `src/types/importReview.ts`, `src/hooks/useReconstructCounts.ts` |
| Extension presentation (WS6; UX-03 → UX-04 → UX-05 sequential, UX-07 CSS) | one sole writer | `popup/.html`, CSS, new `popup/{run,result,task}.` presentation |
| Extension logic (WS1, not UX) | one writer | `background.js`, `shared/**`, `content/main.js`, `manifest.json` |
| Backend generator (S7) | sole generator owner (unassigned) | `scripts/importer-contract.ts`, `docs/contracts/importer-openapi.json`, schema |
| Design/spec (source-only) | journey worker + this worker | `execution/e7d2385c/ux-planning/**` |

Serialization points: `popup/popup.html` + `popup/result.*` (UX-03/04/05 extension: one writer, sequential); `ImportResultView.tsx`/`ImportStatusFrame.tsx`/`importJourneyCopy.ts`/`i18n/en.json` (UX-04/05/06 mobile: one writer, sequential; UX-04/05/06 are **not** independent writers); `importJourneyUI.tsx` (UX-07 ↔ UX-02); `authActions.ts`/`events.ts` (S6/mobile state writer ↔ UX-01/UX-08); navigation files (single navigation writer). Mobile ∥ extension remains valid because repositories differ. None touches the single heavy runtime slot; mobile Jest/tsc is CPU-bound and must be scheduled around S6/S7 hook/tsc steps.
