# S12 (real acceptance and pilot): readiness up to the owner boundary (EXEC-FA72EFB2)

- **Grade:** T3 planning. This document changes no code or schema, runs nothing, and decides nothing that belongs to
  the owner. Every owner-reserved step appears as a question for Bradley with a **recommended default**. A default is
  a recommendation only. It is not a decision.
- **Grant:** `execution/fa72efb2/s12/S12_PREP_GRANT.md`. **Rules:** `execution/fa72efb2/WORKER_RULES.md`.
- **Read trees (source only):**
  - Backend: `worktrees/fa72-s11d2` at `aed23289`. That is S11-D round 3 on `54be96f1` (S11-A2 r2, the current
    `integration/importer` head in the local tracking refs).
  - S8-D record: `worktrees/fa72-s8d` at `77b7f0b` (round 3, blobs identical to `f91dea4d`,
    `LAST_OPERATOR_STATE.md` L33).
  - Mobile: `repos/mobile` `origin/main` = `a876268c`. I read it through `git show`, so the local checkout (`affc2818`)
    was not touched.
  - Extension: evidence only. No extension clone exists in this workspace.
- **Path conventions:** unprefixed `path Lx` means the backend read tree. `EV:` means
  `repos/tgp-private-evidence/execution/`. `S8D:` means `worktrees/fa72-s8d/docs/decisions/2026-09-26-s8d-person-link.md`.
- **Decision records:** `docs/decisions/` is abbreviated as S7L-DOC, S8-DOC (`2026-09-24-s8-native-contract.md`),
  S9-DOC, S10-DOC (`2026-09-26-s10-induction.md`) and S11-DOC (`2026-09-26-s11-journey.md`).
- **Freshness caveat:** landing state is taken from the local tracking refs and `EV:fa72efb2/LAST_OPERATOR_STATE.md`
  (19:25Z). I did not fetch from GitHub.

---

## 0. The facts that shape S12

These facts come from source. They change what a real pilot can honestly show.

1. **No shipped client drives the server-mode journey that S11 proved.** The landed extension (`a889f4ad`,
   `EV:1910a060/extension/LANDED.md` L6-11) creates legacy run ids. Per `EV:daceddc8/e2/CONSUMER_FREEZE.md` L74:
   "The extension-minted runs (`imp-…`/`ext-…`) are never `POST /scout/runs/start` intents, so today they are
   `mode: legacy`". L97 of the same file lists "Any `POST /scout/runs/start` binding" as not done.
   - S11 proves the paired → Start → claim → settle chain only with direct-service workers (S11-DOC L96-106).
   - Automating declaration, observation, claim and claim replay in the extension is owner question Q-S11-2
     (S11-DOC L484-486; S10-DOC Q4 L481).
   - So a pilot run through today's extension would be a legacy run. In a legacy run the terminal is whatever the
     extension claims, not a server verdict.
2. **No real platform can settle `complete`.**
   - "S10 ships no verifier for any real platform" (S10-DOC L87-89).
   - Until Q2 is answered, extension-asserted evidence never proves anything, and production `complete` stays off
     (S10-DOC L476-478; Q-S11-4, S11-DOC L490-491).
   - The only real platform with a mapping in `src` is TrueCoach (`src/scout/reconstruct/sources/truecoach.json`:
     families `clients`, `workouts`, `client_history`). It has **no** native rules file and **no** induction manifest.
     `src/scout/reconstruct/native/sources/` and `src/scout/induction/sources/` contain only `s10_unseen.json`.
   - A mapping with no manifest leaves every family `known: false` (S10-DOC L80-81).
   - What an honest pilot terminal looks like today:
     - `partial`, with `coverage_basis_unknown` or `unresolved_identities`;
     - the `clients` rows stay `partial/unresolved_identities` (qualifier `roster_bridge_pending`) until S8-D1 lands
       (S8D §5.1 L665-673; `test/scout/s11/journey-full.pg.spec.ts` L341-396);
     - no native programs, because TrueCoach has no `programs` family or native rules.
3. **The flags are global, not per coach.**
   - `FEATURE_GATED_ROUTES` is three environment booleans (`src/common/feature-flag/feature-flag-not-found.middleware.ts`
     L20-31), read on every request (L41-42).
   - No pilot-coach scoping exists for `/api/scout/*` or `/api/extension/pair/*`. A per-caller allowlist precedent does
     exist: `FEATURE_COMMUNITY_API_ALLOWLIST` (`src/community/community-feature-flag.guard.ts` L24-29).
4. **Production has not received the current code.**
   - Backend `main` = `1c10e2a1` (`EV:fa72efb2/TAKEOVER.md` L17). `integration/importer` is 29 commits ahead of
     `main` in the local refs.
   - Of those 29 commits, one adds a migration: `20270124000000_scout_run_observation_expand` (S10-B).
   - As of 2026-09-25, production was running image `5076a07a` (2026-07-23). The last deploy failed because of
     "overdue invoices" on Fly (`EV:daceddc8/prod/PR530_MERGE_SAFETY.md` L17). The deploy preconditions D1-D6
     (L94-100) were not all met then.
   - The current production state is **unknown** from source.
5. **The mobile app can pair but cannot show the verdict or the roster.**
   - Landed on mobile `main`: the pairing panel and the S11-C readiness row (`src/components/coach/ExtensionPairingPanel.tsx`
     L44-47, L371-376).
   - Not mounted anywhere: `useReconstructCounts` (defined only in its own file).
   - The import-journey leaves are "Not registered, production-reachable, integrated" (`src/screens/coach/import-journey/README.md`
     L3-4).
   - No mobile source reads `GET /api/scout/import/status` or `GET /api/scout/reconstruct/roster` (`git grep` on
     `a876268c`, test files excluded).
   - Both mobile flags are build-time and off by default (`src/config/featureFlags.ts` L411-433; `.env.example` L142, L148).

---

## 1. What "S12 accepted" means

I propose splitting S12 in two. S12a delivers the import with no client contact. S12b delivers the client invite
after S8-D4b and S8-D5 land together (S8D §3.5 L600-608). Splitting keeps the first real-data step free of any
client-facing side effect (D-S11-7(6), S11-DOC L335-337).

**S12a is accepted when:**
- one named pilot coach, on one named real source account (one workspace, per S8-DOC L99-101), completes the journey
  in §1.1 in the agreed environment;
- the run ends in a terminal that matches the server's settled basis (whatever that terminal is);
- every family that the pilot report cannot prove is shown as unknown (§3.6);
- zero client-directed messages are sent;
- zero cross-tenant rows or reads occur.

**S12b is accepted when** the pilot coach invites at least one consenting imported person through D-S8-LINK L2-L4,
and the link, the confirmation and the 30-day undo (L7) all behave as the S8-D record specifies with real delivery.

### 1.1 Step-by-step journey and existing coverage

| # | Pilot step | Landed proof that already covers it synthetically | What only a real account adds | State |
|---|---|---|---|---|
| 1 | Coach installs the extension | Extension `main` `a889f4ad` (LANDED.md L6-11, CI and CodeQL green L31-33). Not published (L36) | A real Chrome profile, the install channel (CWS or unpacked side-load), a real extension id and CORS origin | Build exists. Distribution is **owner** (Q-S11-2, CWS) |
| 2 | Pairs (phone ↔ computer) | C1 pairing; **J01** (`test/scout/s11/journey-core.pg.spec.ts` L161); H-C authentication stays with the route specs (S11-DOC L100-106); readiness **J17/R1-R6** (`readiness.pg.spec.ts` L73-162); mobile panel `a876268c` | Real coach JWT, real phone and computer, `FEATURE_EXTENSION_PAIRING` in the hosted environment | Server and mobile landed. Flag is **owner** |
| 3 | Declares the source (optional) | S10-B; **J09**, **J11** (`journey-induction.pg.spec.ts` L157, L437-477) | Nothing provable. There is no real verifier, so a declaration only marks the scope (S11-DOC L266-271) | Server landed. Extension emission is **owner** (Q4) |
| 4 | Presses Start once | S7-L; **J01**; the replayed Start is identical | The extension must send Start with the **paired** intent id. It does not today (CONSUMER_FREEZE L74, L97) | **Gap.** Needs an extension build (Q-S11-2) |
| 5 | Imports from ONE real source account | **J02** (batches alternate between hosts), **J05** (cancel races ingest), **J09** (two synthetic platforms) | Real extractor behaviour on real pages, real volume, real field shapes, real rate limits, the real deadline | Mechanism landed. The real source is **owner** |
| 6 | Claim, settle, survive a process loss | **J12-J16** (`settle-redrive.pg.spec.ts` L238-467); S11-B `dda794d7`; **J19** leg A (`journey-full.pg.spec.ts` L168) | Real redeploys and machine restarts during a run; the real `SCOUT_RUN_DEADLINE_MS` (Q-S11-1) | Landed, except that J19 is the S11-D proof that is still pending |
| 7 | The run settles truthfully | **J06** (deadline), **J10** (`partial/coverage_basis_unknown`, null counts), **J19** leg B (`partial/unresolved_identities` + `roster_bridge_pending`), D2 R39 (a)-(f) | Whether a **real** mapping produces the expected families and reasons. The expected pilot terminal is `partial` (§0.2) | Landed. `complete` for a real platform is **owner** (Q-S11-4) |
| 8 | Roster and programs are visible in mobile | Step-11 roster read in **J02/J19**; `GET scout/reconstruct/roster` and `…/entities` (landed); mobile `importReviewApi` reads `/scout/reconstruct/entities` (L37) behind `EXPO_PUBLIC_FF_IMPORT_REVIEW` | A mobile pilot build with the flags on; a verdict screen; roster rows marked "imported, not yet joined" (S8-D2 + UX-D2); programs only if the platform gets native rules | **Gap.** Mobile M-bind, S8-D1, S8-D2 and UX-D2 are buildable (§2b) |
| 9 | Client invite per D-S8-LINK (S12b) | None yet. S8-D3/D4a/D4b/D5 and UX-D4/D5 are not built (S8D slice plan L739-761) | Real email delivery to a real client, real OTP, a real "Is this you?", a real 30-day undo | Buildable. Enabling `FEATURE_PERSON_LINK` with real clients is **owner** (S8D L609-610) |
| 10 | Disconnect or revoke the source | Only the reserved `revoked` fence seam (S11-DOC table row 12, L130) | Everything | **Owner** (G3-AUTH) |

Across all steps:
- tenant isolation: **J07**, R6, D-S11-7(5) (S11-DOC L322-334);
- no client-facing side effects: **J08**, R38 (S11-DOC L335-337; S10-DOC L441-442);
- CORE DIFF = 0: **J20**, which passed live (`EV:fa72efb2/s11d/PROOF_V1_FINDING.md` L4-5).

---

## 2. Readiness checklist

### 2a. Done on `integration/importer` (proven synthetically, landed)

| Item | Commit | Evidence |
|---|---|---|
| S7-L run lifecycle, C1 pairing, S8-G native pass, S9-B/S9-C reconciliation | on `integration/importer` | S11-DOC L11-13 |
| S10-A/B/C/D: induction, declaration, observation, settled basis, D2 real-PG 9/9 | `275e458c` (D2) | `LAST_OPERATOR_STATE.md` L55-56 |
| S11-A1 (J01-J08) | `3db615c0` | ibid. L69 |
| S11-C readiness block + contract regeneration | `7fdcbc04` | ibid. L64 |
| S11-B re-drivable settle (J12-J16) | `dda794d7` | ibid. L49 |
| S11-A2 two-source induction (J09-J11), END 127/127 | `54be96f1` | ibid. L40 |
| Mobile readiness panel | mobile `a876268c` | ibid. L49 |
| Extension E2 "Check status" server read | extension `a889f4ad` | LANDED.md L6-11 |
| Owner decision D-S8-2 option (a) + D-S8-LINK L1-L8 | evidence `5a3e9f2` | `OWNER_DECISION_S8D_2026-09-26.md` L100-121 |

Pending in the parent's pipeline, and not claimed as done:
- S11-D r3 `aed23289` (J19/J20, PR #565; proof v1 failed on spec defects, `s11d/PROOF_V1_FINDING.md`);
- the S8-D decision-record doc `77b7f0b` (PR #566, stacked);
- S8-D1 (building).

### 2b. Buildable now without the owner (source work on `integration/importer` or mobile `main`, flags dark)

| Slice | What | Grade | Depends on | Why it is needed for S12 |
|---|---|---|---|---|
| S12-B1 | **Pilot-coach allowlist** for the gated importer surface. For example, `FEATURE_SCOUT_PILOT_COACH_IDS` checked after auth on `extension/pair/init|session|current`, `scout/runs/*`, `scout/ingest*`, `scout/runs/observation`, `scout/import/status` and `scout/reconstruct/*`. A caller not on the list gets the same uniform 404 (R-DARK-1). Follows the `community-feature-flag.guard.ts` L24-29 precedent. `redeem` is unauthenticated but only accepts codes minted by `init`, which is gated. | **T4** (tenant and auth boundary; ≈80-150 product lines; route and guard specs) | S11-D landed | Without it, turning a flag on in production enables the importer for every coach (§0.3). Setting the flag's value stays **owner** |
| S12-B2 | **Test-manifest production exclusion** (D2 C1). A generic mechanism so that `s10_unseen` (and any `testOnly` manifest or verifier) is refused or not loaded when `NODE_ENV=production`. Must keep the D-S10-5 gate green (the gate is re-pinned in the same reviewed landing). | T3 (≈30-60 lines) | S11-D landed | C1: with the committed test key, a production run declaring `s10_unseen` could be proven `complete` (own tenant only) (`EV:fa72efb2/s10d2/d2_review.md` L217-222). Whether this is required before enablement is owner question 7 |
| S12-B3 | **Mobile M-bind:** read `GET scout/import/status` for the paired intent; render the phase, the terminal and the reason code from server fields only; show null and absent values as "not known yet", never 0; mount the roster and entities read behind `EXPO_PUBLIC_FF_IMPORT_REVIEW`. | T2/T3 (mobile) | none (the contract has landed) | Step 8. Without it the pilot coach cannot see the truthful verdict on the phone |
| S8-D1 → S8-D2 → UX-D2 | Typed `person` handoff, the roster `imported_people[]` field and its markers, and mobile roster rows labelled "imported, not yet joined" | T4, T4, T2 (S8D L747-748, L759) | S11-A2 (D1); D1 (D2) | Step 8 roster. Also flips the `clients` family out of `unresolved_identities` (S8D L707-708) |
| S8-D3 → D4a → D4b + D5 → UX-D4/D5 | Schema and RLS rewrite (this closes the out-of-band RLS gap for WorkoutSession/WeightLog/Habit, S8D L165-170), invite, claim and undo | T4 (S8D L749-752, L760-761) | S11-A2 + S11-D proofs on the 173-migration pin (S8D L781-783) | S12b only. The owner questions OQ-2/7/10 have interim defaults (S8D L802-813) |
| S12-B4 | **Pilot runbook + read-only observation pack:** SQL/`psql` queries (never run by builders) that produce the §3.4 pilot report from `ScoutImport`, the ledger, provenance, declaration/observation rows and the settled basis, plus a documented flag on/off procedure | T1/T2 (docs + SQL, no product code) | none | §3. Makes the pilot report reproducible and "unknown-safe" |
| S12-B5 | **Production RLS check script** (read-only catalog query of `pg_policies` / `pg_class.relrowsecurity` / `relforcerowsecurity` for WorkoutSession, WeightLog, Habit, CheckIn, ClientWorkoutAssignment\*) written and reviewed, **not run** | T2 | none | Owner question 8. Makes the check a single approved read |
| S12-B6 | Add `FEATURE_SCOUT_RECONSTRUCT` (and the S12-B1 allowlist variable) to `fly-feature-flags-set.yml`. Today it pushes only INGEST + PAIRING (L9-10, L34-41) | T2 (`.github/workflows/**` requires review) | S12-B1 | Without it the roster and entities reads stay dark even after the flags are set (`scout-roster.controller.ts` L78-81) |
| S12-B7 | **Native mapping for the chosen real platform** (per-source JSON only, CORE DIFF = 0, the D-S10-5 shape) | T2/T3 data-only | Owner question 2 (platform), plus real field shapes | Programs and workouts become native rows instead of evidence. The rows still cannot be `complete` without a verifier |

### 2c. Owner-reserved (each item is a plain-words question for Bradley; §4 orders them)

Note on sequence: items 10 and 11 below are answered before items 5, 6 and 12 in the §4 order.

1. **Real source platform and account.** "Which platform, which account, and whose clients' data do we use for the
   first real import?" (SCOPE `EV:1910a060/SCOPE.md` L116-119: live source accounts are reserved.)
2. **Consent and data handling for real client data.**
   - "Do the people in that account agree to their data being copied into TGP for this test?"
   - "How long do we keep the imported rows, and how do we delete them if you or they ask?" (retention is S10 Q3,
     S10-DOC L479-480. There is no demonstrated delete route for the insert-only tables, S10-DOC L250-259.)
3. **Environment and production deployment.**
   - "Do we run the pilot in production, or do we first stand up staging?" Staging is only a checklist today
     (`docs/staging-execution-tracker.md` L26, L144, unchecked).
   - "May `integration/importer` go to `main` at an exact commit you approve, and then be deployed?" Backend `main` =
     `1c10e2a1`, and there is one new migration in range.
4. **Production feature flags.** "May we turn on `FEATURE_EXTENSION_PAIRING`, `FEATURE_SCOUT_INGEST` and
   `FEATURE_SCOUT_RECONSTRUCT` in production, only for the pilot coach (after S12-B1)?" `FEATURE_PERSON_LINK` stays
   absent until S12b.
5. **Extension distribution (CWS) and automation (Q-S11-2).**
   - "May we build an extension version that runs the paired import by itself: Start, send, finish, retry finish?"
   - "Do we give it to the pilot coach as a private side-load, or publish it on the Chrome Web Store?"
   - Extension `main` also needs a non-author approval (`EV:daceddc8/SCOPE.md` L352).
6. **G3-AUTH.** "Are you OK with the pilot having no 'disconnect source' button and supporting one source workspace
   per coach per platform, with revocation done by the coach logging out and removing the extension?" (S8-DOC
   L96-101; S11-DOC L476.)
7. **D2 C1.** "Before any production flag goes on, must test-only source keys be excluded from production builds?"
8. **The RLS environment check.**
   - "May someone run one read-only query on the production database to list the real security policies on
     WorkoutSession, WeightLog and Habit?"
   - Those policies exist only in the out-of-band `prisma/migrations/rls_fitness_backend.sql`, not in any migration
     directory (S8D L137-140; `LAST_OPERATOR_STATE.md` L36).
   - The check must happen before any person-owned writer (S8-E) or the S8-D3 policy rewrite goes live.
9. **Q-S11-1 (the deadline).** "How long may one import run before it is stopped as timed out: keep 5 minutes, or
   raise it?" (`lifecycle.service.ts` L70-72, L224-231; S11-DOC L170-177.)
10. **Q-S11-3 (enablement order).** "Do you agree to this order: backend fully rolled out first, then the flags for the
    pilot coach, then the extension build, then the mobile pilot build?" (S11-DOC L487-489.)
11. **Q-S11-4 (= S10 Q2/Q5).** "Until a real source verifier and G3-AUTH exist, is an honest `partial` with named
    reasons an acceptable pilot result, with a real-platform `complete` kept switched off?"
12. **Spending.**
    - "May we pay the overdue Fly invoices so deploys work again (`PR530_MERGE_SAFETY.md` L95)?"
    - "May we pay for a mobile pilot build (EAS or TestFlight) if one is needed?"
    - No SMS spending: OQ-13 stays email-only (S8D L813).
13. **Q-S11-2** is item 5. **The S8-D owner questions OQ-2/7/10** (S8D L807-811) matter only for S12b. Each has an
    interim default already in force, and S12b ships those defaults unless Bradley answers differently.

---

## 3. Pilot safety

### 3.1 Tenant isolation (pilot coach only)
- **Synthetic proof:** J07 and R6 show that a second coach can neither read nor write the first coach's intent, run,
  declaration, observation or native rows. The same holds across two processes (S11-DOC L322-334, L391-402).
  Every S8 and S10 write is keyed by the token's `coach_id` (S8D §4 L654).
- **In real hosting:** "only the pilot coach" is **not enforceable today**, because the flags are global (§0.3).
  Closure is S12-B1: the allowlist, plus the default of an empty allowlist when the flags are on.
- **Additional pilot limits:**
  - one source workspace per coach per platform (S8-DOC L99-101);
  - no second platform in the pilot;
  - the pilot coach is not also a client of another coach (S8D OQ-4, L797).

### 3.2 Kill switches (fastest first)
1. **One run:** `POST scout/runs/cancel` from the phone. This fences the run `cancelled` exactly once (J05).
2. **The whole surface:** set the flag(s) to anything other than `'true'`. Every gated route answers the uniform 404,
   because the value is read on every request (middleware L41-42). The operator workflow sets the flags with
   `fly secrets set`, which restarts the machines once (`fly-feature-flags-set.yml` L9-10). Any open run then stays
   open in the database. When the flag comes back on, the first status read fences it `timed_out` (lazy deadline,
   J06). Nothing is ever turned into zero or `complete`.
3. **Pilot coach only:** remove the coach id from the S12-B1 allowlist.
4. **Client-facing (S12b):** `FEATURE_PERSON_LINK` off. The unlink routes stay mounted, so a flag-off never strands an
   open undo (S8D L611-635).

### 3.3 Rollback
- **Code:** revert on `main`, let CI, CodeQL and SBOM run, then dispatch again. This is forward-only
  (`.github/workflows/fly-deploy.yml` L22-25). An emergency image route exists (runbook §7, L561).
- **Schema:** applied migrations stay applied. Rollback means a reviewed forward reverse migration
  (`docs/deploy-runbook.md` L557, L565). The S10-B migration adds only empty insert-only tables and additive columns.
  Its `down` is not a production tool.
- **Imported data:**
  - S8 native writes are create-only and carry provenance (S8-DOC L108-109). The rows a pilot created can therefore be
    identified exactly through `ImportNativeProvenance`.
  - **No** reviewed delete route exists for native rows or for the S10 insert-only tables (S10-DOC L250-259).
  - Deleting pilot data is a separately authorized L8 retention and erasure action (owner question 2).
  - Until then the default is: rows stay, and the pilot coach can archive or edit them in the app.

### 3.4 What is observed and logged
- **Database (the source of truth):**
  - `ScoutImport` (mode, phase, epoch, `accepted_start_at`, `deadline_at`, `last_observed_at`, stored claim,
    `terminal_status`, `reason_code`);
  - the completion ledger and `ImportNativeProvenance`;
  - `ScoutRunDeclaration` and observation rows;
  - the settled basis (`families[]` with `known` and `observed_unique`).
- **Analytics events, coach-scoped, with intent id and status fields only:**
  - `SCOUT_RUN_STARTED` (`lifecycle.service.ts` L295), `SCOUT_RUN_FENCED` (L406), `SCOUT_RUN_SETTLED` (L468);
  - `SCOUT_INGEST_COMPLETED` (`scout.service.ts` L349, L420, first claim only);
  - `SCOUT_IMPORT_STATUS_READ` (L515), `SCOUT_IMPORT_STATUS_INVALID` (L554);
  - reconstruct and roster read events (`src/analytics/events.ts` L111-166).
- **Push:** one coach-directed `import.complete`, sent on the first claim only. Its copy says "Migration is not
  verified" (S11-DOC L179-186, G5, class C). The pilot report must not treat this push as the verdict.
- **Not observed:** anything on the source platform's side, and anything the extension did not send. Both stay
  unknown.
- The pilot report is produced from the S12-B4 read-only pack.

### 3.5 Success and stop criteria
**Success (S12a):**
- exactly one run for the intent and exactly one terminal write;
- the terminal equals the verdict recomputed from the settled basis;
- every reason code is from the closed catalogue;
- every family is `known` with a count, or explicitly unknown;
- the roster read lists exactly the reconstructed people, labelled "imported, not yet joined" after S8-D2;
- replaying the run creates no second native or provenance row;
- zero client-directed sends (the J08 property holds in real data);
- zero rows or reads for any other coach;
- the coach performed no routine actions after Start. If the extension build is not automated, this criterion is
  recorded as not met, not waived.

**Stop immediately (flag off, preserve everything, report class A or B):**
- any cross-tenant row or read;
- any client-directed message;
- a `complete` terminal on a real platform;
- a count shown as 0 where the basis is unknown;
- a duplicate native identity after a replay;
- a 5xx loop on ingest or settle;
- any write the pilot coach did not start;
- the coach or a client withdrawing consent.

### 3.6 "Unknown does NOT silently become zero" in the pilot report
- A family with `known: false`, or an `observed_unique` that is null, is written as **"unknown (reason)"**. It is
  never written as 0, "none" or "complete" (D-S11-7(4), S11-DOC L320-321; J10).
- A missing mirror snapshot, readiness block or declaration is reported as "not known". It is never reported as "no"
  (S11-DOC L271).
- `timed_out` and `cancelled` are reported as themselves, with the counts that were actually persisted. They are
  never reported as "failed with 0 records".
- Counts come only from persisted rows (S11-DOC L155-158). The extension's claim is reported separately, as the
  extension's statement, beside the server verdict.
- Families the platform has but TGP has no destination for are listed as "not imported: no destination", with the row
  count staged (OQ-9 default, S8D L810). Examples: notes, goals, measurements, profile fields, and `client_history`
  until S8-E.
- A `partial` is reported with every reason code and qualifier (for example `roster_bridge_pending`), never rounded
  up.

---

## 4. The smallest owner decision set that unblocks S12, in order

Each item: the question in plain words → **Recommended default (a recommendation, not a decision)** → what it unblocks.

1. **What counts as a successful pilot?** "Until a real verifier exists, will you accept an honest `partial` with named
   reasons as a pass, and keep a real-platform `complete` switched off?" (Q-S11-4 / S10 Q2, Q5)
   → *Recommended:* yes. S12a passes on a truthful `partial`. Real-platform `complete` stays off.
   → Unblocks: the acceptance definition (§1). Without it, S12 cannot pass.
2. **Which real account?** "Which platform and which account do we import from, and whose clients are in it?"
   → *Recommended:* TrueCoach, the only real platform with a mapping in `src`, using Bradley's own coach account or
   one friendly coach. One workspace. A small roster (≤ 20 people).
   → Unblocks: S12-B7 (native mapping) and the pilot runbook.
3. **Consent and keeping the data.** "Will the coach (and, where you want it, their clients) agree in writing that
   their data is copied into TGP for the test? How long do we keep it, and who can ask for deletion?"
   → *Recommended:* written consent from the pilot coach. No client contact in S12a. Keep the rows (today's
   tombstoning) until S10 Q3 is decided. Pilot data deletion only by a separately approved, reviewed script.
   → Unblocks: using real data at all.
4. **Where does the pilot run?** "Production, or a staging copy first?"
   → *Recommended:* production, with the pilot allowlist (S12-B1) and every other coach dark. A new staging stack adds
   cost and a second set of secrets without testing the real deploy path. If Bradley prefers staging, this becomes a
   spending question.
   → Unblocks: items 5 and 6.
5. **Pay Fly and deploy.** "May we clear the overdue Fly invoices, create the protected GitHub `production`
   environment, merge an exact `integration/importer` commit you approve into `main`, and deploy it with every flag
   off?"
   → *Recommended:* yes, at one pinned 40-hex sha after S11-D, S12-B1 and S12-B2 land. Follow D1-D6 in
   `PR530_MERGE_SAFETY.md` L94-100, including the one-time image build proof (D3).
   → Unblocks: any hosted real run.
6. **Flags for the pilot coach only.** "May we switch on pairing, import and review in production for the pilot
   coach's account only?"
   → *Recommended:* yes, after the deploy has fully rolled out and the S12-B1 allowlist holds exactly one coach id.
   `FEATURE_PERSON_LINK` stays absent.
   → Unblocks: steps 2 and 4-8 in production.
7. **Test keys out of production (D2 C1).** "Must test-only source keys be excluded from production builds before the
   flags go on?"
   → *Recommended:* yes (S12-B2). It is cheap, generic, and closes a synthetic-`complete` path.
   → Unblocks: item 6 without residual C1.
8. **The extension that runs the import by itself (Q-S11-2, CWS).** "May we build an extension version that uses the
   phone-paired setup, presses nothing after Start, and retries the finish step itself? Can we give it to the pilot
   coach as a private side-load instead of publishing it on the Chrome Web Store?"
   → *Recommended:*
   - yes to Start, send, finish and finish-retry under the paired intent;
   - no declaration or observation relay in S12, because no real verifier exists;
   - the build goes through the extension's normal review, with Bradley's non-author approval on `main`;
   - distribution is an unpacked side-load for the pilot coach only;
   - no CWS publication in S12.
   → Unblocks: step 4, and makes step 7 a server verdict instead of a legacy claim.
9. **Run time limit (Q-S11-1).** "How long may one import run before we stop it as timed out?"
   → *Recommended:* keep one fixed window (no renewable lease) and set `SCOUT_RUN_DEADLINE_MS` = 1 800 000 (30 min)
   for the pilot. Then look at the real duration and revisit.
   → Unblocks: a realistic run size. The default of 5 minutes risks a truthful but useless `timed_out`.
10. **Switch-on order (Q-S11-3).** "Do you agree the order is backend fully rolled → pilot flags → extension build →
    mobile pilot build?"
    → *Recommended:* yes. It is S7L-DOC L238's rule extended to S11-B.
    → Unblocks: the rollout plan.
11. **No disconnect button (G3-AUTH).** "Are you OK with the pilot having no in-product 'disconnect source', with one
    source workspace per coach per platform?"
    → *Recommended:* yes, for S12a only. Revocation is: cancel the run on the phone, log out of the source, remove the
    extension. G3-AUTH stays owner-reserved for general release.
    → Unblocks: S12a without G3-AUTH.
12. **Mobile pilot build.** "May we make a pilot mobile build (internal TestFlight / Play internal track) with the import
    screens on, and pay any build cost?"
    → *Recommended:* yes, an internal track only, with `EXPO_PUBLIC_FF_EXTENSION_IMPORT` and
    `EXPO_PUBLIC_FF_IMPORT_REVIEW` on in that build alone.
    → Unblocks: step 8 on the pilot coach's phone.
13. **RLS check (needed before S12b or any S8-E writer, not for S12a).** "May someone run one read-only query on the
    production database to confirm the WorkoutSession, WeightLog and Habit security policies really exist?"
    → *Recommended:* yes. Run the reviewed S12-B5 script once, by Bradley or under his explicit approval, results
    recorded in evidence. If it finds a gap, it is class A and S8-D3 closes it before any person-owned writer.
    → Unblocks: S12b and S8-E.
14. **S12b client invite.** "Once invite, claim and undo are all built and proven, may the pilot coach invite one
    consenting client by email?" OQ-2/7/10 keep their interim defaults (S8D L807-811) unless Bradley answers them.
    → *Recommended:* yes, one client, email only (OQ-13 default), after D4b and D5 land together and item 13 is done.
    → Unblocks: S12b.

Items 1-12 are the minimum for S12a. Items 13-14 are needed only for S12b.

---

## 5. Findings (Safety ROI)

- **B1: global flags; no pilot scoping.**
  - CLASS: B.
  - CONCRETE HARM: turning any flag on in production enables unaccepted import routes for every coach who crafts
    requests. The mobile and extension entry points are off or not public, which reduces but does not remove this.
  - EXACT DECISION BLOCKED: owner items 4 and 6.
  - MINIMUM CLOSURE: S12-B1 (T4), or the owner explicitly accepting global exposure.
  - EXECUTION UNLOCKED: production flags for the pilot.
- **B2: no client drives the server-mode journey.**
  - CLASS: B.
  - CONCRETE HARM: a pilot through today's extension produces a legacy run. Its terminal is the extension's claim, so
    S12's "settles truthfully" would be unproven while looking done.
  - EXACT DECISION BLOCKED: S12a acceptance, step 7.
  - MINIMUM CLOSURE: owner item 8, then an extension server-mode build (T3/T4 in the extension lane).
  - EXECUTION UNLOCKED: steps 4-7 on a real account.
- **B3: a real platform cannot be `complete`, and TrueCoach has no native rules.**
  - CLASS: B, for the acceptance definition only (no code defect).
  - CONCRETE HARM: an acceptance bar of "complete, with programs visible" cannot be met honestly.
  - EXACT DECISION BLOCKED: owner item 1.
  - MINIMUM CLOSURE: the owner accepts `partial` as a pass, and S12-B7 after item 2.
  - EXECUTION UNLOCKED: the S12a pass/fail definition.
- **B4: out-of-band RLS for WorkoutSession, WeightLog and Habit.** This is a known item, recorded in
  `LAST_OPERATOR_STATE.md` L36 and S8D L137-140.
  - CLASS: B, for person-owned writers only.
  - CONCRETE HARM: if production lacks those policies, person-owned rows are readable by direct database access.
  - EXACT DECISION BLOCKED: S8-E, and S8-D3 going live.
  - MINIMUM CLOSURE: owner item 13 plus S12-B5.
  - EXECUTION UNLOCKED: S12b and S8-E. It does not block S12a, which writes no person-owned rows.
- **C (recorded, not blocking):**
  - D2 C1 test key (S12-B2);
  - the operator flag workflow omits `FEATURE_SCOUT_RECONSTRUCT` (S12-B6);
  - the 5-minute default deadline (owner item 9);
  - the push is keyed to the claim, not the verdict (G5; copy owner UX-05);
  - a flag-off mid-run leaves the run open until a later status read fences `timed_out`, which is truthful;
  - the current production image and schema state are unknown from source and must be read back before item 5;
  - the local tracking refs may lag GitHub.
