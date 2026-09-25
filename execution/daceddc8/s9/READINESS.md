# S9 reconciliation readiness (planning only; not a review, grant, audit or acceptance)

Lane `s9_readiness`, grant S9-READY-1 (`execution/daceddc8/SCOPE.md` "Additional grants"), 2026-09-25 ~16:40Z, T4 planner. Read-only: durable docs in `repos/tgp-agent-context`, private evidence, accepted backend `93389265` via `worktrees/64e33dc7-env`, candidate S7-L `a68cdac7` and S8-C `87018a42` via `git show HEAD:`. No product, git, lock, test or PG action; no re-audit of accepted work; nothing here is a verdict on S7-L or S8-C. "PLAN" = `repos/tgp-agent-context/handoffs/op81/CONTINUATION_AND_ROMAN_IMPORT_PLAN.md`; "MISSION" = `repos/tgp-agent-context/roadmap/M-IMPORTER-PRODUCT-MISSION_v1.md`; "S7L-DOC" = `docs/decisions/2026-09-24-s7l-run-lifecycle.md`; "S8-DOC" = `docs/decisions/2026-09-24-s8-native-contract.md` (both accepted at `93389265`).

## 1. S9 as defined in the sources (quoted, not invented)

- Slice name: `execution/e7d2385c/IMPORTER_PROGRESS_AND_PARALLEL_UX_PLAN.md:38` "| S9 | Relationships and reconciliation |"; `execution/e7d2385c/OPERATOR_PAUSE_AND_RESUME.md:25` "S9 relationships/reconciliation, S10 unseen-source induction".
- Outcome rule: PLAN:29 "no run says “complete” while a required family, historical period, relationship, or native destination is unknown, missing, conflicted, or unverified." PLAN:97 "Native reconciliation | Every discovered family and dependency is accounted for in usable native records or a non-success outcome".
- Method: PLAN:319 "For each family, reconcile unique source identities against verified created/already-present native identities and unresolved/rejected identities. Unsupported, unobserved, permission-blocked, or unknown is never silently zero". PLAN:321 "Success requires both structural completeness and native relationship validation, not just equal counts. If the platform provides no reliable completeness basis, final status remains incomplete". PLAN:323 "budget time for final reconciliation, and stop new work at the deadline".
- Report: MISSION:91 "every import produces a reconciliation report — imported vs. skipped vs. failed vs. out-of-reach, each with a reason; zero silent omissions." MISSION:93 "a forced partial … renders as `partial`/`failed` with an accurate account, never `complete`."
- Seam into S7-L: S7L-DOC:70-72 "3. reconciliation verdict present (S9) → its outcome; 4. otherwise `partial`, `reason_code='reconciliation_not_performed'`"; S7L-DOC:74 "`complete` is emitted only from a reconciliation verdict. S7-L never produces it."; S7L-DOC:266-267 "**S9:** supplies the reconciliation verdict consumed by arbiter step 3"; S7L-DOC:210-211 native buckets "`null` = 'not yet known' (never 0) until S8-B provenance / S9".
- Family-complete rule S9 must apply: S8-DOC:152-157 "A family is `complete` only when every staged identity is `created` or `already_present` **and** no child provenance row under any of its parents is `unresolved`… An unmapped family makes the run at most `partial` (PLAN L307). The terminal verdict itself belongs to the S7-L single arbiter, not to writers."
- S9 items named by S8-DOC: 200-201 late-resolved children "stay `unresolved` for S9"; 206-208 source value drift "needs a value fingerprint, which is an S9 reconciliation item"; 219 `relationship_missing` "S9 closes relationships"; 310 "The S9 reason-code catalogue (CQ-17) adopts this list"; 316-319 "Relationships are resolved only through provenance lookups on the D-S8-3 key… `client_source_id` stays a soft link with no foreign key… S9 validates closure."; 472-473 the 10,000-row ceiling "must surface as a truthful `partial` or `blocked` (S9), not an opaque error."
- Carry-forwards: `execution/ce3748cb/s8-prep/S8_BRIEF.md:83-90` items 1-8 (D-C1 unaccounted `staged` rows; compare staging identities to ledger identities, not counts; `readDrainState` over-count; unmapped `notes` → unresolved-family row and refuse `complete`; single arbiter replaces extension `success`; workout→client and program→plan closure; 10k ceiling; CQ-13 manifest, CQ-17 catalog, CQ-18 marker, E30). `execution/cf8ff737/C_BUILD_GRANT.md:18` "The terminal outcome must not report a complete import while scoped `staged` rows remain unaccounted." `execution/ce3748cb/s8-0/REVIEW.md:111` C4 "S9 reconciliation should check provenance and native existence, not only the ledger."
- UX dependency: `execution/ce3748cb/ux-readiness/UX04_06_BRIEF.md:51` "Blocked on S8/S9: any meaning for `created_native`"; :66 UX-05 "plus S9 for reconciliation reasons: a shared reason catalog (CQ-17)"; :88 UX-06 "**S9:** reconciliation and the coverage manifest (CQ-13)"; :177 "UX-06 results and deep links (T4): waits on **S8 + S9**".

S9 is therefore: (1) a pure verdict function producing the arbiter's step-3 input, (2) the fact collection behind it (staged identities × ledger × provenance × native existence × relationship closure), (3) the per-family reconciliation report / coverage manifest v1 that fills the S7-L `families[]` native buckets, (4) the reason-code additions those need. Not S9: writers (S8-C/D/E), orchestration and fencing (S8-G), readers (S8-F), `observed_unique` and completeness observation (S10), workspace attribution (G3-AUTH), routes or flags.

## 2. Frozen now vs. waiting

**Frozen (accepted at `93389265`, binding on S9).**
- Ledger identity `(coach_id, intent_id, entity_type, source_platform, source_id)` (`prisma/schema.prisma:6962`); `target_kind` nullable, closed CHECK `person|scout_entity|workout_program|workout_plan`, NULL = legacy writer (:6949-6952). `staged = reconstructed + skipped + failed` per intent is ledger truth.
- `ImportNativeProvenance` unique on `(coach_id, source_namespace, entity_type, source_id)`, indexed `(coach_id, native_kind, native_id)` and `(coach_id, import_intent_id)`; `import_intent_id` nullable UUID; `native_id` null exactly for `unresolved` (:6975-6992). Provenance is keyed without intent, so it cannot by itself say which run created a row.
- S8-DOC §3.2 family-complete rule, §3.5 conflict outcomes, §3.7 closed unresolved codes, §3.8 order and no-FK soft link, §3.9 `prescription:time` tag. S7L-DOC D-S7L-2 precedence, D-S7L-5 fixed codes (`unresolved_family` already exists), §5 `families[]` shape with null-never-0 rule, §8 seam text.
- Reader gate `terminal_status IS NOT NULL` and settled-intent 404 stay; S9 adds no read route.

**Waiting on S7-L acceptance (candidate `a68cdac7`; pin at acceptance, do not guess).**
- `ReconciliationVerdict {outcome: ServerTerminalStatus; reason_code: RunReasonCode | null}` (`src/scout/lifecycle/arbiter.ts:22-25`) — S9's output type. The arbiter takes it verbatim (:81-86).
- `RUN_REASON_CODES` closed list (`reason-codes.ts:46-53`): S9 needs additions (§4 below); that file is S7-L-owned until landed.
- `onTransferSettled(coachId, intentId, epoch)` runs `collectFacts` and `arbitrate({fence, reconciliation: null, ...facts})` inside the row-locked transaction (`lifecycle.service.ts:313-327`); `unmapped_families` = staged tokens not in the family registry (:392); `staged_by_family` groups by raw `entity_type` token, not canonical family (S8-G READINESS E4). `projectFamilies` hard-codes the four native buckets to `null` (:557-562).
- The S7-L contract lineage `2.0.0-c1-s2.0` and generator ownership.

**Waiting on S8-C acceptance (candidate `87018a42`).**
- Typed persist outcome `{ok, targetId, targetKind, unresolvedChildren}` and ledger reason grammar `unresolved:<code>[:<qualifier>]` (`native/persist-outcome.ts`, `native/native-contract.ts:71-83`); child rows encoded as `entity_type='workouts.exercise'` in provenance only (S8-DOC §3.3).
- Fact: "`import_intent_id` stays NULL here… attribution is a later G3 slice, never guessed" (`native/native-provenance.ts:16-17`). See finding F2.

**Waiting on S8-G (not started; `execution/64e33dc7/s8g/READINESS.md`).** S8-G owns the hook body and passes `reconciliation: null` (:16 "Build `{… reconciliation: null}` and call S7-L's CAS terminal writer"). S9's single integration point is that one argument. S8-G's N3 (:49) asks whether provenance `import_intent_id` is filled; S9 depends on the answer (F2).

**Independent of S8-F.** S8-F's frozen 15 paths (`execution/64e33dc7/s8f/build/CHANGED_PATHS.txt`) are entities/roster readers only; S9 never touches them and S8-F never computes counts (`s8f/READINESS.md:9` "Family counts belong to S7-L status, not to these readers").

## 3. Minimum seam and exact proposed writable paths (disjoint from S8-F and S8-G)

Design rule: S9 computes; it never writes `terminal_status`, `completed_at`, `reason_code`, ledger, provenance or native rows, and never fences. It runs inside the settle transaction S8-G already holds under the run row lock, so its facts are consistent with the CAS epoch, and it is bounded (per-family aggregate queries plus one existence join per `target_kind`; never per row) to respect PLAN:323.

1. **`reconcile(facts): {verdict: ReconciliationVerdict, report: ReconciliationReport}`** — pure, no I/O, no clock (mirrors arbiter discipline). Inputs per canonical family: staged identity set size and its intersection with ledger identities for this intent; ledger rows by `status`/`target_kind`; provenance outcomes for those identities with native-existence and coach-ownership verification result; unresolved child count; relationship closure result; `unmapped_families`; `completeness_basis`. Output: verdict per §1 rules plus a per-family report that fills `created_native`, `already_present_verified`, `rejected`, `unresolved` and an `unresolved_reasons: {code: count}` histogram; a bucket is `null` only when its basis is genuinely unknown, never a fabricated 0.
2. **`ReconciliationFactsService.collect(tx, coachId, intentId)`** — reads staging, ledger, provenance and the four native tables on the caller's transaction; groups tokens to canonical family through the accepted `resolveStep` (so S9 and S8-G share one grouping; closes E4 for S9 without touching S7-L's `collectFacts`).
3. **Optional persisted report** — `ScoutImportReconciliation (coach_id, intent_id, execution_epoch, report jsonb, created_at)`, expand-only, same fail-closed RLS posture as the ledger, written in the settle transaction. Purpose: the report that justified the verdict stays reproducible after the coach later edits or deletes native rows (PLAN says views refresh from the native domain, but the settle-time account must not drift). Parent decides persisted vs. recomputed-on-read; recommended persisted, because a recomputed report could contradict the stored terminal.
4. **Wiring (last, after S7-L, S8-C, S8-G are landed):** S8-G's hook passes `reconciliation: (await reconcile(...)).verdict` instead of `null`; `project` fills the four native buckets from the report; additive reason codes; one generator regeneration by its owner.

**Proposed sub-slices and exact writable paths (one writer each).**

| Slice | Scope | Writable paths | Not owned |
|---|---|---|---|
| S9-0 | Reconciliation decision doc: verdict predicate, report/manifest v1 shape, reason-code additions, persistence choice, F1/F2 dispositions | `docs/decisions/2026-09-2x-s9-reconciliation.md` (new) | any code |
| S9-A | Pure reconciler + report types + table-driven spec | `src/scout/reconciliation/{types.ts, reconcile.ts, coverage.ts}` (new dir), `test/scout/reconciliation/reconcile.spec.ts` | `lifecycle/**`, `reconstruct/**`, readers |
| S9-B | Facts service; optional report table; PG proof harness | `src/scout/reconciliation/facts.service.ts`, `src/scout/reconciliation/reconciliation.module.ts`; if persisted: `prisma/migrations/2027012400000x_scout_reconciliation_report_expand/{migration,down}.sql` + `prisma/schema.prisma` (new model only); `test/scout/reconciliation/facts.service.spec.ts`, `test/rls-g2-s9.spec.ts`, `test/scout/g2-s9-db-guard.spec.ts`, `test/utils/g2-s9-{bootstrap.sh,db.ts,harness.ts,pg-harness.ts,worker.cjs}` | every other migration; `families.ts`; `native/**`; `scout-reconstruct.*`; `scout-entities.*`; `scout-roster.*` |
| S9-C | Wiring after landings: the `reconciliation:` argument in the settled hook body, native-bucket fill in `project`/`projectFamilies`, additive `RUN_REASON_CODES`, module provider | `src/scout/lifecycle/lifecycle.service.ts` (two call sites only), `src/scout/lifecycle/reason-codes.ts` (additive entries only), `src/scout/scout.module.ts` (provider only), `test/scout/lifecycle/arbiter.spec.ts` and `lifecycle.service.spec.ts` (added cases only) | `run.controller.ts`, `scout.service.ts`, `scout.dto.ts`, `reconstruct/orchestration/**`, `scout-reconstruct.service.ts` |
| Gen | Contract regeneration for the new enum values and any additive `families[]` field | `scripts/importer-contract.ts`, `docs/contracts/importer-openapi.json`, `test/contracts/importer-contract.spec.ts` — **generator owner only**, sequenced by the parent after S7-L/S8-C/S8-F regenerations | S9 builders |

Disjointness check: S8-F (`scout-entities.*`, `scout-roster.*`, `test/scout/{entities,roster}/**`, `g2-s8f-*`) ∩ S9 = ∅. S8-G (`reconstruct/orchestration/**`, `scout-reconstruct.service.ts`, hook body, `g2-s8g-*`) ∩ S9-A/B = ∅; S9-C touches the hook body's one argument strictly after S8-G has landed (sequential, not concurrent ownership). S7-L and S8-C candidate paths ∩ S9-A/B = ∅. Private evidence: `execution/daceddc8/s9/**`.

## 4. Reason codes S9 needs (proposal for S9-0; additive to D-S7L-5)

Existing and reused: `unresolved_family` (unmapped token or no native destination), `reconciliation_not_performed` (S8-G/S9 absent). Proposed additions, all low-cardinality and PII-free (CQ-17): `unresolved_identities` (any staged identity in a mapped family is not `created|already_present` with a verified native row — covers D-C1 unaccounted rows, C4 removed targets, unresolved children, the 10k ceiling remainder, `no_native_client_principal`), `relationship_unverified` (a required soft link or program→plan ordering fails closure), `coverage_basis_unknown` (native reconciliation clean, but no completeness basis for at least one family; see F1). Per-row detail stays in the report histogram using the S8-DOC §3.7 strings, not in the run-level code.

## 5. Tier grading

| Slice | Tier | Trigger |
|---|---|---|
| S9-0 | T3 | Persistent cross-slice contract; one independent T3 review, cites S7L-DOC/S8-DOC lines |
| S9-A | **T4** | The only code path in the product that can emit `complete`; truthful terminals are a product safety invariant (UX map row UX-05 "T4 … no local verdict"); two independent exact-head reviews, table-driven spec over every fact combination |
| S9-B | **T4** | Real-PG reads over tenant data inside the terminal transaction; RLS; if the report table exists, migration/refusing-down/RLS proof |
| S9-C | **T4** | Touches the lifecycle terminal path and the status projection; dual review + one PG proof of the composed hook |
| Gen | T3 | Generated-contract change; drift spec byte identity |

## 6. Fixed acceptance cases (real services; one new PG proof for S9-B/S9-C bytes; no accepted-suite rerun)

- R01 Native-clean run (every staged identity `reconstructed` with typed `target_kind`, provenance `created|already_present`, native row present and coach-owned, zero unresolved children, closure verified): (a) `completeness_basis` present for every family → `complete`, reason `null`; (b) basis absent → `partial/coverage_basis_unknown`. Never `complete` under (b).
- R02 A row present in staging and absent from the ledger for this intent (C18(b) shape) → `partial/unresolved_identities`; the family's `unresolved` counts it; `complete` unreachable.
- R03 Staged `notes` (unmapped) → `partial/unresolved_family`; family row present with `created_native` null, `unresolved` = staged count, reason histogram `unresolved_family:notes`.
- R04 Ledger `reconstructed` but the native row is archived/deleted or provenance is `native_target_removed` → not counted native (C4); `partial/unresolved_identities`.
- R05 Equal counts, different identity sets (offset-paging carry-forward) → `partial`; identity-set comparison, never count equality.
- R06 Workout with `client_source_id` whose client has no `created|already_present` provenance → `relationship_unverified`; program→plan order mismatch against provenance child order → `relationship_unverified`.
- R07 Evidence rows (`target_kind` NULL or `scout_entity`) and `unresolved:no_native_client_principal` never count toward `created_native`/`already_present_verified`; a run staging any client-owned family is at most `partial` under the D-S8-2 interim.
- R08 10k per-pass ceiling leaves rows staged → `partial/unresolved_identities`; no 409 reaches the terminal.
- R09 Precedence preserved: with a fence present the S9 verdict is ignored (arbiter step 1); with claim `failed` and zero staged rows → `failed/transfer_failed` regardless of S9. S9 writes nothing; exactly one terminal write; CAS miss → no-op.
- R10 Determinism: identical facts → identical verdict and report; a replayed intent that converged `already_present` yields the same report shape with `created_native` per F2 disposition.
- R11 Tenant isolation: coach B's staging/ledger/provenance/native rows never enter coach A's facts; RLS anon/authenticated denial on any new table; service-role rollback leaves no report row.
- R12 Unknown never 0: a bucket without basis is `null`; a `0` appears only with a stated basis (e.g., zero staged in a mapped family with basis present).
- R13 Legacy runs: S9 is never invoked; `scout.service.spec.ts` and legacy `/complete` byte-identical.
- R14 Codes: every emitted `reason_code` is in the closed enum; the report contains no free text, source payload, name or email.
- R15 Projection: before terminal the four native buckets stay `null`; after terminal they equal the persisted (or recomputed) report; `observed_unique` stays `null` (S10).
- R16 Budget: the reconciliation read set is O(families) queries; a synthetic 10k-row intent reconciles within the S8-G proof's deadline window with no per-row query (statement capture).

## 7. Prerequisites checklist

- [ ] S7-L candidate accepted (dual GO + one v4 PG proof) and landed on `integration/importer` — pins `ReconciliationVerdict`, `RunReasonCode`, hook signature.
- [ ] S8-C candidate accepted and landed — pins persist outcome, reason grammar, child encoding, `import_intent_id` fact.
- [ ] S8-G READINESS E1-E6/N1-N4 pinned; S8-G built and landed before S9-C (S9-A/B/0 do not wait for it).
- [ ] Parent decisions in S9-0: F1 (`complete` predicate and basis), F2 (bucket attribution), persisted vs. recomputed report, `blocked` vs `partial` for the ceiling case (recommend `partial`; `blocked` stays reserved for `revoked`).
- [ ] Generator-owner slot for one regeneration after S7-L/S8-C/S8-F lineage (`2.0.0-c1-s2.0` → next).
- [ ] Heavy slot for one S9 PG proof (RLS + composed hook), serialized after the composition gates in `SCOPE.md` "Heavy-slot queue".
- [ ] No owner action required for S9-0/A/B/C (see §9).

## 8. UX lanes S9 unblocks (per `UX04_06_BRIEF.md`)

- UX-05 (M-bind reason catalog, `UX04_06_BRIEF.md:66`, :174-175): unblocked by S9-0 freezing the additive codes and the Gen regeneration; still waits on S7-L artifact and G3-AUTH for Stop.
- UX-04 `created_native` meaning (:51, :187 "Ready to use / created_native from real data | S8/S9"): unblocked after S9-C fills the buckets; F2 decides whether the per-run split or only the union is truthful at first.
- UX-06 results and deep links (:88, :177): needs S8-F (owned native ids) **and** S9-C (CQ-13 manifest v1). Manifest v1 carries `completeness_basis` per family; with S10 absent it reads `none`, and the UX shows the CQ-13 fallback disclosure rather than a coverage claim.
- Not unblocked by S9: Stop (S7-L + G3-AUTH), review alignment (S7-REV), enabling `importReview`.

## 9. Owner-reserved items (unchanged; S9 needs none)

D-S8-2 client principal (client-owned families stay `unresolved:no_native_client_principal`, so TrueCoach runs staging `client_history` cannot reach `complete` until it is decided — S9 reports this truthfully, does not resolve it); G3-AUTH workspace attribution (E30 duplicate-id merge across workspaces remains a recorded limitation S9 cannot detect); production deployment/enablement, `main` merge, flags, external commitments per `SCOPE.md`. No owner-reserved decision is required for S9-0/A/B/C.

## 10. Findings (Safety-ROI)

- **F1 — A (blocks S9-0's `complete` predicate only; no local harm today, flags dark).** Class: truthfulness of terminal. Harm: PLAN:321 requires a completeness basis, but `observed_unique` "stays null until an observation contract exists (S10)" (S7L-DOC:211-212); if S9 issued `complete` on native reconciliation alone, a run that missed source pages (offset paging is not a snapshot, `S8_BRIEF.md:84`) would say `complete`, violating MISSION:93. Decision blocked: whether S9 v1 may emit `complete` without a per-family completeness basis. Minimum closure: S9-0 records (i) `complete` requires a basis; until S10, native-clean runs settle `partial/coverage_basis_unknown` (recommended, literal PLAN:321 and MISSION:91), or (ii) a named extension-side terminal evidence is admitted as an "alternative completeness basis", which is an observation-contract question and belongs to S10. Execution unlocked: S9-A build and its R01 table.
- **F2 — A (blocks the per-run `created_native` / `already_present_verified` split only; verdict unaffected).** Class: overstated counts. Harm: provenance has no intent attribution (`native-provenance.ts:16-17`; key without intent, schema:6989), so a replay run would count rows created by an earlier intent as `created_native`, and UX-04/06 would show "sent as stored" (PLAN:248 "HTTP 200 is not proof every record was created"). Decision blocked: bucket attribution. Minimum closure (either): (a) S8-G's transaction writes `import_intent_id` on provenance insert — the server run has the UUID (`ScoutImport.import_intent_id`), so this is S8-G N3 answered "fill", no schema change; or (b) S9 v1 leaves the split `null` and reports only the verified union inside the report histogram. Recommend (a) as target, (b) as the interim if S8-G lands first. Execution unlocked: S9-B bucket fill and R10.
- **C (record and continue).** (1) `collectFacts` groups by staged token; S9 groups via `resolveStep` and leaves S7-L's `unmapped_families` untouched. (2) Reason-code additions require the generator owner; sequence after S7-L/S8-C/S8-F regenerations. (3) Ceiling case: `partial` recommended; `blocked` stays G3's. (4) Value-fingerprint drift detection (S8-DOC:206-208) is a later S9 increment (S9-D) needing a stored fingerprint; not in v1. (5) `readDrainState` over-count (`S8_BRIEF.md:85`) is a CLI/runbook note, not S9 code. (6) D-S8-2 interim makes `complete` unreachable for any run staging client-owned families; truthful, recorded. No B findings: nothing here invalidates accepted proof.

## 11. Next step

No S9 writer, slot, PG or review grant is requested now. S9-0 can be drafted as evidence-only on the accepted docs plus the two candidate pins; S9-A can be drafted against `ReconciliationVerdict` once S7-L is accepted; S9-B/C wait on landings per §7. When the parent records F1/F2 dispositions, this file takes a one-line delta, not a rewrite.
