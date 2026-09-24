# S8 readiness brief: S7 remainder + deterministic native writers (T3, read-only)

Grant `execution/ce3748cb/S8_READINESS_GRANT.md`, ~20:20Z. Reads only: `git show`/`ls-tree`/`grep` on backend `origin/integration/importer` c7a5fe8d (= "I"), N/Q1 `61b93cff` via `GIT_OPTIONAL_LOCKS=0 git -C worktrees/s7-nq1 show` (= "NQ"), extension `origin/land/s4-r6` aa0abd83 (= "X"), mobile `origin/main` c7641cb3, context `1ebbed7`, private evidence `c827842`. No edits, installs, runtime, index or ref writes. Requested model/effort are not telemetry and are not claimed. "PLAN" = `tgp-agent-context/handoffs/op81/CONTINUATION_AND_ROMAN_IMPORT_PLAN.md`; "MISSION" = `roadmap/M-IMPORTER-PRODUCT-MISSION_v1.md`.

## 1. What remains of S7 after C (Q1)

**Still inside the G2 chain (not "after C", but the gate for it):**
- **N/Q1 v2r**: the spec-only rebuild is in flight (`NQ1_V2R_REBUILD_GRANT.md`). There is no `nq1/SOURCE_READY_V2R.md` yet, and the v1 PG proof failed 15/20 (`nq1/NQ1_PG_PROOF_RESULT.md`). After that come two delta attestations and one PG run.
- **C phase 1 re-draft**: in flight. `worktrees/s7-c` holds only the untracked migration folder; the rest was lost.
- **C phase 2**: rebase onto the accepted N/Q1 head, the schema/doc/OpenAPI edits, and the hooked commit. Then two T4 attestations, and one PG run covering C01–C18 (`C_BUILD_GRANT.md`, `c/PHASE1_DRAFT_READY.md`).
- **Landing base (C)**: NQ sits on R `7d2895e1`, not on I `c7a5fe8d`. The PROD-CI-1 delta is `.github/workflows/migration-dry-run.yml` plus one line in `scripts/release.sh`, so the rebase or merge before landing is mechanical.

**S7 lifecycle/contract items with no implementation anywhere inspected** (S7 map `execution/e7d2385c/s7-mapping/S7_CANONICAL_CONTINUATION_MAP.md` §2 "Missing"; C1 decision `docs/decisions/2026-09-17-c1-durable-paired-intent.md` L64-69, L105):

| ID | Item | Current fact (evidence) | Canonical requirement | Owner |
|---|---|---|---|---|
| L1 | Server-accepted Start / cancel / deadline | No Start or cancel endpoint. Scout routes are only `progress`, `ingest/complete`, `import/status` (I `scout.controller.ts` L70/L90/L126), plus `ingest`, `reconstruct`, `reconstruct/roster`, `reconstruct/entities`. | PLAN L244-251: immutable `accepted_start_at`/`deadline_at`; duplicate Start returns the same run | backend (S7-L) |
| L2 | Single terminal arbiter, full vocabulary | The extension asserts `success|partial|failed` (I `scout.dto.ts` L108-109). `/complete` writes it verbatim into `ScoutImport.state` (I `scout.service.ts` L263-289). Read statuses omit `cancelled` (L151-157). | PLAN L245: `complete|partial|blocked|failed|cancelled|timed_out`, with one arbiter | backend (S7-L) |
| L3 | Execution epoch / commit fencing | Ingest has no settled/epoch check (I `scout-ingest.service.ts` L66-85). D-C1 accepted this for C only. | PLAN L251: cancel/timeout fences new ingest **and native commits** | backend (S7-L); S8 writers must check it |
| L4 | Scout run ↔ server-owned intent binding | Scout `intent_id` is a free client string (ingest ≤256, complete ≤128: I `scout.dto.ts` L124). `ImportIntent` is referenced only in `src/extension-pair/**` (git grep). | PLAN decision 5 (legacy intents never promoted); C1 doc L29-30 | backend (S7-L) |
| L5 | Intent-required review requests + one generated schema (S7-REV) | Mobile `importReviewApi.ts` L1-4 still says "contract 1.4.0". Review reads are family-paged, not intent-scoped. | PLAN decision 4; CQ-12 | sole generator owner |
| L6 | Per-family run counts | Only extension `final_counts` JSON and staged-row counts exist. | PLAN L248: `observed_unique` … `created_native`, `already_present_verified`, `unresolved` | S7-L shape; S8/S9 fill it |
| L7 | Disconnect/revocation, source principal/workspace attribution, capability negotiation | None exist (C1 doc L66-69). | PLAN L183, L235, L264-265 | **G3-AUTH owner** |
| L8 | C1 activation blockers | Code retirement/recycling and retention/erasure policy are undecided (C1 doc L80-83). | — | owner/policy (reserved) |
| L9 | Status transport | No mobile-readable run status (CQ-12). | PLAN decision 6 | backend + mobile |

S7-L means L1–L4 and L6, with L5 and L9 riding the same generator regeneration. L7 and L8 are outside backend-builder authority. S7-L is the critical dependency for S8-G and for UX-04/05. It is **not** a dependency for S8-0 through S8-C (§3).

## 2. Current native-writer coverage (Q2)

**Engine.** One parameterized family registry: `buildFamilyRegistry` (I `src/scout/reconstruct/families.ts` L138-145). The NQ writer (`scout-reconstruct.service.ts` L61-131, L268-306) does post-settle paging with a 10k-row ceiling, a transaction per row, a five-field ledger upsert with success-dominates precedence, and a ledger-derived tally. NQ does not touch `families.ts` or the mappers. C touches neither: C's owned paths are the migration, two `@@unique` lines, doc text and three reconstruct fake specs.

| Canonical family (closed allow-list, I `scout-reconstruct.dto.ts` L11-18) | Target today | Native TGP table? |
|---|---|---|
| `clients` | `Person` upsert on (coach, platform, source_person_id), writing only `display_name` (families.ts L60-88; schema L6920-6937) | **No.** `Person` is a scout-only, non-login record. The coach roster reads `User` (I `src/coach/coach.service.ts` L133-147). `Person` is used only by `families.ts` and `scout-roster.service.ts`. |
| `workouts` | Generic `ScoutReconstructedEntity` {client_source_id, label} (families.ts L97-130; schema L6981-6993) | **No.** `WorkoutProgram`/`WorkoutPlan`/`WorkoutPlanExercise` (L2183/L2141/L2298) are never written. |
| `client_history` | Same generic table | **No.** `WorkoutSession`, `ExerciseSet`, `CheckIn`, `WeightLog` (L862/L879/L1102/L930) are never written. |
| billing, messaging | Absent by design; reconstruct returns 400 for them | n/a (read-only billing history is required later, PLAN L306) |
| any other staged `entity_type` | Ingest accepts any string ≤128 chars (I `scout-ingest.dto.ts` L141). Reconstruct returns 400. | **Unmapped and unaccounted.** The live TrueCoach blueprint emits `notes` (X `extractors/truecoach/blueprint.js` L40-47), which has no family. |

**Native destination constraint (fact).** Every client-owned native table has a foreign key to `User`: `ClientWorkoutAssignment.client_id`, and `user_id` on `WorkoutSession`, `CheckIn`, `WeightLog` and `Habit`. D2 forbids minting an auth `User` for imported people (schema L6904-6911), and `User.email` is `@unique`. `Person` has no relation to `User`. Coach-owned native tables (`WorkoutProgram.coach_id/owner_user_id`, `WorkoutPlan.coach_id`) need no client principal. `ExerciseCatalogItem` is global (`slug @unique`, L4332), so it is not a coach-owned import target. `WorkoutPlanExercise.exercise_external_id` is a plain string reference. The native service writes that fire notifications are `assignPlan` and `assignProgramToClient` (I `workout-builder.service.ts` L551, L1336, L1401, L1531-1541). `createPlan` (L345) runs behind `assertCoach` and idempotency.

**Where site-specific semantics leak into core (NEW SOURCE → CORE DIFF ≠ 0):**
- **Backend, S8 scope.**
  - Per-source TypeScript mappers live in core: `src/scout/mappers/truecoach-{clients,entity}.mapper.ts` and `conformance-alpha.mapper.ts`.
  - The registry hard-codes its array (`source-mapper-registry.ts` L64-66) and documents "a new source is one implementing object + one registration line" (L22-24). That is two core file diffs per source.
  - TrueCoach field meaning is code, not data: `name` (clients mapper L57), `client_id`/`clientId` (entity mapper L70), and `title`/`name` (entity mapper L83). conformance_alpha is `profile.name`, `attributes.member_id`, `attributes.title`.
  - Family keys are the source's labels. The blueprint `entityType` is free text (X `shared/replay/blueprint.js` L19, L274), and no data maps a source step to a canonical TGP family.
- **Extension, S10 scope, recorded here only.** TrueCoach is wired into the extension core in four places:
  - `shared/replay/resolve.js` L7, L22: blueprint registry;
  - `shared/capture-policy.js` L23: `ALLOWED_CAPTURE_HOSTS = {app.truecoach.co}`;
  - `shared/protocol.js` L19: `TRUECOACH_API_BASE`;
  - `background.js` L37, L535-536: `TrueCoachExtractor` dispatch.
- **Not a leak:** the closed canonical-family allow-list and `unsupported_platform:<token>` fail-closed behaviour belong to the TGP side and are correct.

## 3. S8 decomposition (Q3), path-disjoint and in dependency order

**Decisions to freeze before the build grants.** All are parent-decidable except D-S8-2.
- **D-S8-1 (mapping authority).** Replace per-source TypeScript mappers with one generic, pure, total interpreter over a data-only `SourceMapping` spec. The spec gives, per source step, the canonical family and field paths (roles → JSON paths, id/soft-link/label, typed coercions), and skip reasons stay byte-identical. For S8, specs are repository-resident JSON data. S10 changes where they come from: induced, intent-bound blueprint data validated by the same interpreter. The locked envelope `{sourceId, sourcePlatform, capturedAt, payload}` (X `extractors/_interface.js` L32-39) is unchanged. **Recommended.**
- **D-S8-2 (client principal for native client-owned data) — material product direction, the only candidate for Bradley.** Options:
  - (a) add a nullable `person_id` beside the `User` FK on each client-owned native table, family by family, and make the coach roster union `Person` as "imported, not yet joined";
  - (b) import only coach-owned families until claim, reporting client-owned history as `unresolved:no_native_client_principal`.

  Two routes are excluded. A non-login `User` violates D2 and would need fabricated emails. An import-held parallel timeline is excluded by PLAN L313 ("do not … create a parallel domain store"). Recommended default: take (b) now, since it is truthful and unblocks S8-C, and freeze (a) as the target. D-S8-2 blocks only S8-D and S8-E.
- **D-S8-3 (native identity key).** Key native provenance on (coach, `source_namespace`, canonical family, source_id). Today `source_namespace` = `source_platform`; once G3 attribution lands it becomes platform + workspace. Current keys lack workspace scope (`Person` L6932, generic L6992), so two source accounts on one platform can merge (PLAN L309). Recommended: S8-B reserves the column; until G3, one workspace per (coach, platform) is a recorded limitation.
- **D-S8-4 (import context).** Native writers use persistence primitives with no notification, assignment, drip or email side effects. Coach edits are preserved, and conflicts become non-destructive `unresolved` (PLAN L311-313). Generic `update:{label}` overwrite semantics (families.ts L124) are not carried onto native tables.

| Slice | Scope | Repo / base | Owned paths (one writer each) | Tier (trigger) | Acceptance evidence | PG proof | Before C lands? |
|---|---|---|---|---|---|---|---|
| **S8-0** | Source-to-native contract per family, required before calling any family complete (PLAN L298): fields, units/time zones, relationships, conflicts, provenance, side-effect suppression, unresolved codes. Records D-S8-1 through D-S8-4. | backend, new doc on I | `docs/decisions/2026-09-2x-s8-native-contract.md` only | T3 (persistent cross-repo contract) | Parent acceptance plus one independent T3 review; cites schema lines | none | **Yes, now** |
| **S8-A** | Data-only mapping interpreter + canonical-family mapping; retire TS mappers; conformance equivalence | backend; draft on NQ `61b93cff`, rebase onto accepted NQ/C head | `src/scout/reconstruct/{families.ts (map only), source-mapper-registry.ts, mapping-spec.ts (new), sources/*.json (new)}`, `src/scout/mappers/**`, `test/scout/reconstruct/{truecoach-clients.mapper,truecoach-entity.mapper,conformance-alpha.mapper,source-mapper-registry}.spec.ts`, new `test/scout/reconstruct/mapping-spec*.spec.ts`. **Not** the three C-owned fake specs (`conformance-alpha.e2e`, `scout-reconstruct.families`, `scout-reconstruct.service`). | T3 (core contract; persisted output byte-equal). Promote to **T4** if any persisted value, schema or `persist` changes. | Every existing mapper fixture's interpreter output deep-equals the old mapper, including skip reasons. A third synthetic source added as **JSON + test only**, where the commit's `git diff --stat` shows zero `src/**/*.ts`, which proves CORE DIFF = 0 for mapping. `notes` and unmapped steps yield explicit `unresolved_family:<token>` (no silent 400). Also tsc, eslint, prettier, check-r75, affected default Jest, genuine hooks. | Not required (pure; writers unchanged). Accepted PG specs stay frozen. | **Yes**: source/unit now; commit after C lands (fake-spec overlap) |
| **S8-B** | Native provenance ledger expand: new `ImportNativeProvenance` (coach_id, import_intent_id?, source_namespace, entity_type, source_id, native_kind, native_id, outcome `created|already_present|unresolved`, reason) plus nullable ledger `target_kind` (closed CHECK). Answers CQ-14 without adding columns to every native table. | backend on accepted C head | `prisma/migrations/20270122000000_scout_native_provenance_expand/{migration,down}.sql`, `prisma/schema.prisma` (new model + ledger column only), `test/rls-g2-s8b*.spec.ts`, `test/utils/g2-s8b-*`, `test/scout/g2-s8b-db-guard.spec.ts` | **T4** (migration, RLS, persisted identity) | Expand/refusing-down/rerun; RLS anon/auth deny, service-role only; mixed version (NQ+C writer on S8-B schema unchanged); down refuses once any provenance row exists (forward repair). **Separate promotion stage after C** (D-C2). | **Yes**: PG17 single run + PG15 `migration-dry-run` on its PR | Draft SQL/harness now (disjoint dir); schema hunk and PG run after C accepted |
| **S8-C** | Coach-owned native writer: canonical `programs`/`workouts` → `WorkoutProgram`/`WorkoutPlan`/`WorkoutPlanExercise` in import context (templates, never assigned, no notification); exercise references left `unresolved:exercise_reference` unless an exact catalog match; provenance rows. | backend on S8-A + S8-B | `src/scout/reconstruct/native/**` (new), `families.ts` persist entries for the new families, `scout-reconstruct.dto.ts` (family list), new specs under `test/scout/reconstruct/native/**`, PG spec `test/rls-g2-s8c*.spec.ts` + utils | **T4** (writes coach-visible native customer data; side-effect boundary) | Replay creates zero duplicates or drift; coach edit preserved on re-import; cross-tenant isolation; notifications spy shows zero; ordering stable; tally = ledger; unresolved references counted. Contract regeneration by the generator owner. | **Yes**: PG17 single run (real service, concurrency, replay, RLS) | No (needs S8-A/B) |
| **S8-F** | Reader/result materialization over native kinds: roster/entities resolve by `target_kind`, native IDs for deep links, provenance filter "brought across" | backend on S8-C | `src/scout/scout-{entities,roster}.service.ts`, their DTO/controller text, the OpenAPI regeneration and its specs, **coordinated with S7-REV** under one generator owner | T3 (contract), T4 if identity/erasure semantics change | The entities reader materializes only `ScoutReconstructedEntity` (NQ `scout-entities.service.ts` L183) and the roster only `Person` (NQ `scout-roster.service.ts` L190). Native targets must not vanish (Q06 erased-target pattern). | One case folded into the S8-C PG run | No |
| **S8-D** | Roster bridge (`Person` visible in the coach client list) | backend + mobile | per D-S8-2 | T4 | per D-S8-2 | Yes | **Blocked: D-S8-2** |
| **S8-E** | Client-owned history writers (sessions/sets, check-ins, weights, notes, goals) | backend | per D-S8-2 | T4 | Typed values, time zones, historical ordering, no live triggers | Yes | **Blocked: D-S8-2** |
| **S8-G** | Server-side reconstruct orchestration after settle, over all families, epoch-fenced and deadline-bounded. Today only a coach-JWT `POST /scout/reconstruct` per family exists (I `scout-reconstruct.controller.ts` L81-87), with **no first-party caller**: the extension and mobile never call it (git grep). | backend | `src/scout/**` orchestration module (new) | T4 | Native commits rejected after cancel/timeout; one terminal arbiter input | Yes | **Blocked: S7-L (L1–L3)** |

**Order:** S8-0 ∥ S8-A (now) → C accepted → S8-B → S8-C → S8-F. S8-D and S8-E follow D-S8-2. S8-G follows S7-L. S8-A and S8-0 are the only product-moving items executable before C lands. S8-B drafting can also start, since its migration dir and harness are disjoint. The heavy slot is needed only for S8-B/S8-C/S8-F PG runs and default Jest. Staffing: one backend S8 builder (S8-A → S8-C) plus one parallel S8-B builder. The generator/contract owner is serialized with S7-REV/S7-L on `scripts/importer-contract.ts` and `docs/contracts/importer-openapi.json`.

## 4. S9 carry-forwards already recorded or found (Q4)

1. **D-C1** (`C_BUILD_GRANT.md` L12-18): the terminal outcome must not report complete while scoped `staged` rows remain unaccounted. C18(b) proves such rows are observable (present in staging, absent from the ledger).
2. **Offset paging is not a snapshot** (C brief F1; NQ1 brief §7 C(3)): the next replay converges and the tally is ledger truth. S9 reconciliation must compare staging identities to ledger identities, not only counts.
3. **`readDrainState` over-count after C** (C brief §3): it joins on narrow (c,i,e,s) (`scout-ledger-backfill.ts` L234-240), so cross-platform rows are reported as `mismatch`. Retire the backfill CLI or note it in the runbook.
4. **Unknown or unmapped staged family** (this brief §2): `notes` is staged but has no reconstruct path. It must become an unresolved-family row, and `complete` must be refused (PLAN L307; matrix E22).
5. **Extension-asserted terminal** (L2): `success` is persisted before any reconstruction, while native records are absent (matrix E25). The single arbiter must replace it.
6. **Relationship closure**: `client_source_id` is a soft link with no FK (families.ts L91-95; schema comment ~L6974). S9 validates workout → client links and program → plan ordering.
7. **10k per-pass ceiling** returns 409 (dto L98-107). It must surface as a truthful `partial` or `blocked`, not an opaque error.
8. **Coverage manifest (CQ-13), reason-code catalog (CQ-17), legacy-intent marker (CQ-18), cross-workspace duplicate ids (E30, D-S8-3).**

## 5. Findings (Safety ROI)

- **F1 — A (blocks S8-D/S8-E and the UX-06 "Open my clients" path only).**
  - Harm: imported clients never appear in the native `User`-based roster (coach.service L147), and client-owned native history cannot be written without fabricating users (D2).
  - Blocked: S8-D/E build scope.
  - Minimum closure: the D-S8-2 decision.
  - Unlocks: S8-D/E.
- **F2 — A (blocks S10 acceptance "≥1 site without per-brand code", MISSION §3.5.1; not the current TrueCoach proof).**
  - Harm: every new source needs core code, both in backend mappers and in extension core (§2).
  - Minimum closure: S8-A for the backend, S10 for the extension (resolve/capture-policy/protocol/background).
  - Unlocks: the CORE DIFF = 0 proof for mapping.
- **F3 — A (customer-enablement/truthful-terminal path only; flags are dark, so there is no local block).**
  - Harm: `notes` and any other unmapped family are silently absent while the run says `success` (§4 items 4-5).
  - Minimum closure: S8-A unresolved-family accounting plus S9 arbiter.
  - Unlocks: an honest partial.
- **F4 — A (S8-F/UX-06 only).**
  - Harm: `ledger.target_id` is untyped, and readers materialize only the two scout tables, so native targets would disappear from review.
  - Minimum closure: S8-B `target_kind` + S8-F.
- **C (record/continue):**
  - `clients` persist keys on the trimmed `sourcePersonId` (clients mapper L38) while the ledger and the generic persist use the raw `source_id`. S8-A should normalize once, uniformly.
  - `/complete` intent_id is ≤128 while ingest allows ≤256.
  - NQ base is R, not PROD-CI-1 (§1).
  - The stale mobile "contract 1.4.0" header.
  - `exercise_external_id` string references need an explicit unresolved policy.
  - No B findings: nothing here invalidates accepted proof.

No owner-reserved decision is needed for S8-0/A/B/C. D-S8-2 is the single candidate for Bradley, and only if the parent judges the native client-model change (option a) material. L7 (G3-AUTH) and L8 (retention/code retirement) remain existing owner/auth-owner items.
