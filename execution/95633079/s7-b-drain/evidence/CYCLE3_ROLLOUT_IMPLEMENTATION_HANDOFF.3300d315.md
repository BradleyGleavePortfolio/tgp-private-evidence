# Cycle 3 rollout readiness — implementation handoff

**Status: PROPOSED / UNPROVEN.** This operational handoff mechanically renders the existing findings; it adds no implementation, test evidence, SQL execution, or release approval. All newly specified SQL, transition-writer, backfill, reader-token, and promotion behavior is proposed. Existing 21-case proof applies only to the preserved candidate and its reported environment.

**Next assignment:** D diagnostics, four paths, only after the parent’s sole dependency writer releases ownership. Proposed database order: E → T/Q0 → B and old-writer drain → R → N/Q1 → C. No stage is authorized to execute by this handoff.

**Preservation:** Original DOCX, structured findings, frozen inputs and evidence remain untouched. No product/index edits, installs, database calls, product tests, product generation, remote research, or subdelegation.

**Structured assertion inventory:** [All 21 original case names, spans and verbatim excerpts](rollout_readiness_findings.json). The inventory includes 62 original expect expressions; this is not a new test result.

## Cycle 3 • Recovery rollout readiness

READ-ONLY FINDINGS • 17 September 2026 • Requested Astra inherited; runtime identity unverified. Audience: parent release owner and sole backend builder. This is a concrete design proposal, not implementation, deployment approval, or an R14/R100 audit.

Pinned evidence for this section: [brief](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/brief.md.txt); [rules](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/rules.md.txt); [original build](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/original-build.md.txt); [live summary](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/live-summary.json.txt).

### Decision in one sentence

Do not ship the preserved atomic migration during a rolling deployment: use nullable expansion → narrow-selector transitional writer/readers → bounded provenance backfill and old-writer drain → required-platform dual-index schema → final-selector writer → a separate contract release. Preserve all original proof and add real mixed-version, concurrency, and pagination proof before activation.

### Three blocking findings

1. Old reconstruction creates omit ledger source_platform and use a four-column Prisma selector. The frozen recovery immediately requires the field and removes that selector’s unique index. A successful final-state test run cannot establish mixed-version compatibility.

2. Keeping narrow indexes during expansion is necessary but continues silent cross-family/platform deduplication through createMany(skipDuplicates). Final identity semantics begin only when both narrow indexes are removed. Reader pagination must be ready at that same boundary.

3. The existing database/proof kernel is 897 workflow-net lines before additional compatibility work. It is not a ≤400-line release. Earlier, independently useful prerequisites can reduce later deltas; moving required proof after activation cannot.

### Frozen inputs and observed drift

| Input | Identity / treatment |
| --- | --- |
| Backend / recovery | c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7 / a8908132a9c4882dbe80f9fbc1052532c7e68c3b. Read via bare /tmp/tgp-op80-backend-compose.git; recovery is a tree, not a landed commit. |
| Canonical context | ad2259c0649e4e53a663a2600343da1a08ac8b35 at /tmp/tgp-op80-cycle2-inputs/context. All 2,020 rules/addendum lines read. Rules SHA256 606e6c75fe68667c48703d83e0fed58d435f60949cd257f6a7c1f47e9fd4ec79. |
| Shared context drift | Observed HEAD 9b878855c698c69bc7242479c4de9ad28312b296. Requested RECOVERY_SEQUENCING.md is supplemental shared input, absent at immutable ad2259c; not silently substituted for canonical rules. |
| Declared matrix, not remote-verified | Brief timestamp 2026-09-17T21:03:21Z; importer #21 head fc7fdf6e50df08cccad86da37c8b0f15f4b72e81 / base 0111be661922234d670bbf23e23d270eec1b4a4e; mobile a5933fd6de5616493de75f0db907098b149b955c. |

Existing evidence only: original parent run reports 21 passed / 0 pending, exit 0, PostgreSQL 18.6 and unchanged patch hash e678a85a599b6dd81ab0f3881cc779378a9ab866d05f18b44120aa4d2452b6d4 before/after. No test, database operation, install, product generation, remote call, commit, or subdelegation was performed here. The 27-path uncommitted candidate remains preserved.

## 1 / Actual identity and SQL contracts

These are traced contracts, not hypothetical alternate keys. Abbreviations: c=coach_id, i=intent_id, e=entity_type, p=source_platform, s=source_id. “SQL shape” below is a compatibility model; capture the exact SQL from each separately generated pinned Prisma client in the future proof.

Pinned evidence for this section: [base schema](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-schema.txt); [new schema](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/new-schema.txt); [base reconstruct](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-reconstruct.txt); [new reconstruct](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/new-reconstruct.txt); [base ingest](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-ingest.txt); [new ingest](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/new-ingest.txt).

| Surface | Old O at c23b9d9 | Frozen final F at a8908132 |
| --- | --- | --- |
| Staging DB unique | (c,i,s)<br>ScoutIngestEntity_coach_id_intent_id_source_id_key | (c,i,e,p,s)<br>ScoutIngestEntity_identity_key |
| Staging Prisma selector | coach_id_intent_id_source_id<br>Generated contract; ingest does not call it. | coach_id_intent_id_entity_type_source_platform_source_id<br>map changes DB index name, not selector. |
| Ledger DB unique | (c,i,e,s)<br>ScoutReconstructionLedger_coach_id_intent_id_entity_type_source_id_key | (c,i,e,p,s)<br>ScoutReconstructionLedger_identity_key |
| Ledger Prisma selector | coach_id_intent_id_entity_type_source_id<br>Actually used in two upsert sites (base lines 249–300). | coach_id_intent_id_entity_type_source_platform_source_id<br>Both success and skipped/failed paths changed. |
| Ledger INSERT / UPDATE | Create omits p; update changes status, target_id, reason, not p. | Create supplies p from staged row; update still changes status, target_id, reason. |
| Staging INSERT | createMany({data, skipDuplicates:true}); data already contains p. | Same write mechanism; canonical validation tightened. |
| Dedup / time | received − inserted count; captured_at and payload are values, not keys. | Same count arithmetic. All remaining unique constraints can cause DO NOTHING. |

The staging conflict model is INSERT … ON CONFLICT DO NOTHING without a specific conflict target. Dual indexes therefore do not selectively prefer the wider identity. For ledger upsert, a native ON CONFLICT (c,i,e,s) needs a matching unique arbiter; a client-emulated read/update path can instead select a non-unique identity after contraction. Which Prisma branch runs must be recorded, not inferred from the API name.

Old code against a required-p schema can fail on INSERT with NOT NULL (23502); even an upsert intended to hit an existing record must not be assumed safe. An absent native conflict arbiter can yield 42P10. New code on old schema can fail on missing p (42703 / Prisma missing-column error). A new selector with an old generated client fails type/runtime validation before SQL; required-p result materialization on nullable history is also unsafe.

Target identities are already platform-qualified: Person uses coach_id_source_platform_source_person_id; generic reconstructed entities use coach_id_source_platform_entity_type_source_id. No new target identity table or guessed platform is needed. Existing owner scoping and per-family status tally remain; no UNION tally that counts transition rows twice.

## 2 / Binary × schema compatibility

O = frozen old writer/reader. T = proposed optional-p writer retaining the narrow selector plus Q0 dual-decoder/legacy-emitter readers. N = proposed final-selector writer plus Q1 dual-decoder/v2-emitter readers. F = unchanged frozen recovery, which lacks the reader bridge. All “compatible” cells are static expectations requiring the proofs on page 9.

Pinned evidence for this section: [base schema](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-schema.txt); [new schema](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/new-schema.txt); [base roster](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-roster.txt); [base entities](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-entities.txt); [new up](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/new-up.txt); [new down](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/new-down.txt).

| Binary | S0: old schema | E: p nullable; narrow only | R: p required; both narrow + wide | C: p required; wide only |
| --- | --- | --- | --- | --- |
| O | Baseline existing behavior. | Additive columns not selected; creates NULL, updates leave p unchanged. Expected compatible. | NOT compatible: creates omit p; invalid old ingress may hit new CHECK. Do not permit old writers. | NOT compatible: missing p and absent narrow arbiter; old source-only cursors skip tied identities. |
| T / Q0 | NOT compatible: p does not exist. | Intended overlap with O; NULL claim requires transaction; old identity semantics remain. | Intended overlap with N; T always supplies p and uses retained narrow index. Q0 accepts v2. | NOT compatible: narrow selector no longer unique. Must drain before C. |
| N / Q1 | NOT compatible: column and wide unique missing. | NOT compatible: wide unique missing; required model cannot read NULL history safely. | Intended deployment landing zone. Writes both-compatible, but new distinct identities still collide on narrow keys. | Intended final state after proofs; lexicographic reader handles shared s across p. |
| F frozen | Missing-column/client contract failure. | Not a safe landing zone. | Writer expected compatible, but do not market wide semantics; legacy readers remain. | Final writer evidence exists; whole API NOT ready: source-only pagination counterexample. |

### Concrete reader counterexample

Roster (97–105, 125) and entities (104–113) order/filter on source_id alone. With two reconstructed platforms for source_id=1042, limit=1 returns one; the next source_id > 1042 excludes the other. Frozen recovery does not change these files. This is a static counterexample, not a newly executed live failure.

### Required client contracts

E schema.prisma adds ledger source_platform String? and retains its old @@unique. Do not invent a nullable five-field compound selector. R changes to String and adds mapped five-field @@unique while retaining both old declarations. N may use a final-only generated schema against the additive R database; extra narrow DB indexes remain active regardless. C removes obsolete declarations only after T is drained.

Keep generated client artifacts isolated by binary image/package during tests. A single process with one overwritten generated module is not mixed-version proof. Negative controls must show N/E and O/R rejected, and retained narrow indexes preventing premature cross-platform claims.

## 3 / Implementation stages: schema and promotion

Proposed new migration directories use fresh monotonic identifiers selected against the eventual integration head: <new>_scout_ledger_platform_expand (E), <new>_scout_identity_ready (R), <new>_scout_identity_contract (C). Do not rewrite historical applied migrations or deploy the preserved atomic widening SQL as the rolling plan.

Pinned evidence for this section: [new up](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/new-up.txt); [new down](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/new-down.txt); [base release](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-release.txt); [base migration ci](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-migration-ci.txt); [base ingest rls](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-ingest-rls.txt); [base ledger rls](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-ledger-rls.txt).

| Stage / files | SQL / behavior / entry gate | Fallback and exit |
| --- | --- | --- |
| E • first expand<br>prisma/schema.prisma<br>…expand/{migration.sql,down.sql} | Add only ledger source_platform TEXT NULL, no DEFAULT. Keep both narrow unique indexes and all RLS. No ingestion canonical CHECK yet: old O admits inputs it would reject. Verify public table/index OIDs and exact prerequisite definitions; transaction, lock_timeout=5s, statement_timeout=30s. Deploy migration before T. | O continues E. Preferred rollback is keep harmless column. E.down only after p-aware writers drained and assigned provenance can be exactly recovered from canonical staging or an approved restore artifact; otherwise refuse column loss. Own up/down/rerun proof required. |
| T + Q0 • transition<br>src/scout/scout-reconstruct.service.ts<br>reader paths (page 6)<br>own tests | Use optional-p generated client and narrow selector; supply p in every create and transactionally claim NULL without overwriting another p. Readers accept both token versions, emit legacy. Deploy after E; keep old identity behavior. | Rollback to O on E is structurally possible, but resumes NULL creation; halt R promotion and repeat final backfill after draining O again. Do not claim wide identities. |
| B • bounded reconciliation<br>scripts/scout-ledger-platform-backfill.ts<br>own SQL/behavior tests | Exact (c,i,e,s) provenance join; update NULL only in bounded chunks. No default/trigger inference. Report unresolved/mismatch counts. Final sweep only after every old writer is drained and restart-fenced. Details on page 5. | Stop on ambiguity, orphan, invalid p, or stalled progress; retain rows and schema E. Repeated safe chunks resume; never reset already populated p. |
| R • second expand / tighten<br>…ready/{migration.sql,down.sql}<br>prisma/schema.prisma | After O/invalid old ingress drained and NULL=0: add/validate both canonical CHECKs, SET NOT NULL ledger p, create both five-field unique indexes, KEEP narrow indexes. Same public ownership/definition guards and bounded atomic locking. T remains compatible. | Failure rolls back R only, leaving E (not S0). R.down after N is gone drops wide indexes/checks and NOT NULL, retaining p and narrow keys. Preflight actual volume; timeout means stop/redesign, not extend blindly. |
| N + Q1 • new writer<br>reconstruct + readers + tests | On R, deploy required-p five-field client; final writer ordering; reader emits v2 only once all live readers already decode v2. Separate release: do NOT package C migration in this image. | Rollback N→T is allowed on R after reader token compatibility proven. Narrow indexes still constrain identity. Drain every T writer/Q0 legacy emitter before C. |
| C • contract / activation<br>…contract/{migration.sql,down.sql}<br>prisma/schema.prisma + proof | All active/restart-eligible writers N, compatible readers, completed required proof. Atomically drop both narrow indexes, preserving required p, wide uniques, checks and RLS. This is the feature activation boundary. | C.down atomically recreates both narrow indexes but KEEPS wide + p + checks (returns R). Refuse 23505 if either table relies on new identities; no deletion. Post-collision rollback is N-compatible forward repair only. |

The actual release script applies all pending migrations before rolling the new application. E, R, and C must therefore be separate promoted release artifacts, not merely separate directories in one commit. Migration CI also applies all migrations then tests each new directory’s down/up; bundling E/R/C invalidates that isolation. Preserve this gate and rehearse actual stage boundaries.

## 4 / Transition writer and backfill specification

This is pseudocode-level behavior for the future builder, not executed SQL or generated product code. The minimum design retains two existing tables and explicit release gates; no shadow ledger, trigger, queue, or invented platform value.

Pinned evidence for this section: [base reconstruct](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-reconstruct.txt); [new reconstruct](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/new-reconstruct.txt); [new up](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/new-up.txt); [base families](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-families.txt).

### T: preserve provenance in every ledger path

Use the existing narrow where selector (c,i,e,s). In a transaction: upsert ledger with create {…narrow fields, source_platform: staged.p, status, target_id, reason}; update only status/target_id/reason. Then updateMany scoped to the same narrow identity AND (p IS NULL OR p=staged.p), SET p=staged.p. Require affected count=1; otherwise throw a typed provenance conflict so all preceding changes roll back. Validate staged.p is canonical before the transaction; never substitute “unknown”.

Successful reconstruction keeps target upsert + ledger upsert + claim in the SAME transaction. Skipped/failed ledger paths need the same transactional claim discipline even without a target. An old O update leaves non-NULL p intact; the retained staging narrow key prevents an alternate-platform staged row coexisting under that identity. Unexpected non-NULL mismatch fails closed, not repaired by overwrite.

Preserved code retries P2002 once around the successful target/ledger transaction, not the skipped standalone path. Define bounded retry behavior for each transitional branch and test actual contention. A failed/skipped attempt racing success must not silently downgrade a committed reconstruction; decide the intended status precedence before implementation. Existing sequential evidence does not settle it.

### B: bounded, unambiguous and resumable

Operator-only script uses fixed, parameterized/static SQL and the service role; it is not an HTTP endpoint or SECURITY DEFINER helper. Start with batch size 500, subject to representative timing proof. Each transaction sets lock_timeout=5s and statement_timeout=30s, takes a SHARE lock on staging to freeze source mutations for that chunk, and selects ledger candidates ordered by id FOR UPDATE SKIP LOCKED with LIMIT 500.

Resolve only an exact coach + intent + entity_type + source_id match with exactly one staging row and canonical p. The old staging unique index guarantees at most one match on the wider join, not that a match exists. Update only NULL p. Preserve ledger id/status/reason/target_id/timestamps and all staging payload/bytes. Separately detect non-NULL disagreements; never overwrite them.

Repeat eligible NULL batches; do not use a one-way high-water mark that permanently misses locked rows. Zero updated rows with unresolved NULL rows means STOP, not completion. Old O can add NULL after any chunk, so require all O processes, workers, in-flight transactions and restart paths drained before the final zero-NULL sweep. Direct maintenance/staging writers must participate in the release exclusion.

Preflight/report: total and NULL ledger counts; exact resolvable count; orphan, invalid and mismatch counts; batch updated/unresolved counts; bounded elapsed/lock failures. Keep payloads, credentials and identifiers out of routine logs. Orphans require explicit provenance recovery/restore ownership, not guesswork or record deletion.

### R constraints and scale stop

CHECK on each p: source_platform COLLATE "C" ~ '^[a-z0-9][a-z0-9._:-]{0,255}$'. R’s full-table validations/index builds are NOT bounded by B’s 500 rows. Production size, index-build duration and acceptable write pause are unknown. If a representative rehearsal cannot fit the explicit lock/statement budget, stop for a separate online-validation/index-build design and its failure-recovery proof; do not label this fallback tested.

## 5 / Reader bridge, security and rollback ownership

The compatibility-aware promotion principle uses the already preserved AWS reference, not a new web lookup. The implementation boundary is dictated by this repository’s release script, two unique keys, and actual reader cursors.

Pinned evidence for this section: [base roster](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-roster.txt); [base entities](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-entities.txt); [base release](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-release.txt); [base ingest rls](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-ingest-rls.txt); [base ledger rls](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-ledger-rls.txt); [aws](https://aws.amazon.com/builders-library/going-faster-with-continuous-delivery/).

### Q0 → Q1: readers before widened identities

Both src/scout/scout-roster.service.ts and scout-entities.service.ts need a scoped lexicographic boundary (source_id, source_platform). Query: source_id > s OR (source_id = s AND source_platform > p); order by source_id asc, source_platform asc. This preserves the old primary ordering and adds the missing tie-break. Retain RepeatableRead per request, coach/intent/family scope, page bound, owner-scoped target materialization and erasure filtering.

Define token v2.<base64url JSON> carrying {v:2,c,i,f,o:"source_id:asc,source_platform:asc",s,p}; enforce exact decode/encode roundtrip, scope and endpoint/family binding, and validated length bounds. Q0 decodes legacy+v2 but emits legacy; Q1 decodes both and emits v2 only after O readers are gone. This is a fixed release capability, not a new long-lived configuration switch. On E/R, Q0 retains the old source-only predicate for legacy tokens (still safe under narrow uniqueness); its v2 branch uses the tie-break. Q1 on R/C resolves legacy boundaries to p. Thus NULL legacy history on E is not forced through required-p decoding.

Translate a legacy boundary only when exactly one surviving scoped ledger row identifies its canonical, non-NULL p. Ambiguous or missing legacy boundary after widening returns a documented 400/restart-pagination response rather than silently skipping tied rows. Existing roster legacy tokens are unbound source IDs; never widen their query scope. No v2 is legitimately emitted on nullable E. Reconcile the accepted pagination lane on its exact integration head before assigning overlapping files.

### RLS does not change

Both tables already ENABLE and FORCE RLS. Staging: p_scout_ingest_service_role_all (PERMISSIVE ALL to service_role, true/true); deny_all_anon_scout_ingest and deny_all_authenticated_scout_ingest (RESTRICTIVE ALL, false/false). Ledger mirrors this with p_scout_reconstruction_service_role_all and deny_all_{anon,authenticated}_scout_reconstruction. Keep roles/policies unchanged at every stage; backfill is privileged operational access, not a new bypass path.

Original live RLS probes exercise staging, not ledger. New proof must cover ledger and affected target authorization too; do not promote “21 passed” into cross-table RLS evidence.

### Parent-owned promotion / rollback boundary

Parent records deployed and restart-eligible binary SHAs, worker/process inventories, queue/in-flight drain, database transaction drain and direct-writer exclusion. Existing FEATURE_SCOUT_INGEST / FEATURE_SCOUT_RECONSTRUCT switches are emergency route controls, not proof of drain; direct service calls bypass HTTP flags. If lifecycle fencing cannot be evidenced, stop at E/T rather than contracting.

C.down→R permits N to continue and T only after successful narrow-index recreation. Then drain N before R.down→E. E.down→S0 additionally requires recoverable provenance before dropping p. After a single conflicting new identity exists, refuse C.down atomically and retain every row. Use N-compatible forward repair or temporarily stop writers while preserving staged data/replay; no deduplication-by-deletion and no obsolete-image restart.

Parent retains migration, deployment, database, generator and test-slot ownership. This report acquires no execution resource and authorizes no production action.

## 6 / Preserve all 21 original live cases

Stable IDs below map the original 572-line live file, not a replacement set of 21 weaker tests. The JSON companion contains each original case name, source span and verbatim source excerpt so reviewers can compare every expect expression. H means a separately executable, current-base-useful harness prerequisite.

Pinned evidence for this section: [live proof](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/live-proof.txt); [live results](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/live-results.json.txt).

| ID / lines | Original assertion obligations | Stage mapping / adaptation |
| --- | --- | --- |
| 01<br>140–156 | Cross-family same s: insert count 2 and stored types exactly client/workout. | C; the enabling index drop and this discriminator ship together. |
| 02<br>158–166 | Three distinct entity types sharing s: received − count = 0. | C; negative control on R still deduplicates. |
| 03<br>170–178 | Full five-tuple replay: count 0; stored count 1. | Useful H baseline; rerun E/T/R/N and C exact-identity state. |
| 04<br>180–197 | Different captured_at is still replay: count 0, total 1. | H baseline onward; retain timestamp-out-of-key assertion. |
| 05<br>199–205 | Same-tuple duplicate within one batch collapses: count 1. | H baseline onward and C. |
| 06<br>207–215 | Different intent: next count 1, total 2. | H baseline onward and C; keep intent scope. |
| 07<br>217–224 | Different coach: next count 1. | H baseline onward and C; keep coach scope. |
| 08<br>228–250 | Collision-free full reverse: old staging index present, wide absent, staging rows byte-equivalent before/down/up. | C.down→R.down→E.down→E/R/C returns full S0/C boundary; every stage also proves its own down/up. C.down alone intentionally retains wide index. |
| 09<br>252–267 | Cross-family collision blocks reverse with duplicate error; two rows and wide key remain. | C.down; failure atomic and data-preserving. |
| 10<br>271–277 | Staging relrowsecurity and relforcerowsecurity are true. | H baseline, E, R and C; no relaxation. |
| 11<br>279–306 | Exactly 3 staging policies: exact names/roles, ALL commands, permissive service true/true, restrictive anon/auth false/false. | H baseline and each schema stage; enumerate catalog values, not policy existence alone. |

Preserve assertion strength and original input fixtures when adapting migration entry states. IDs 08 and 17 explicitly require a full reverse/forward chain in addition to stage-local checks; silently dropping wide-index absence or column-absence checks is not preservation. Keep the original frozen suite intact as a reference; any builder refactor must supply an assertion-level diff and retain all terminal behavior proofs in the activating release.

## 7 / Preserve all 21 original live cases

Stable IDs below map the original 572-line live file, not a replacement set of 21 weaker tests. The JSON companion contains each original case name, source span and verbatim source excerpt so reviewers can compare every expect expression. H means a separately executable, current-base-useful harness prerequisite.

Pinned evidence for this section: [live proof](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/live-proof.txt); [live results](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/live-results.json.txt).

| ID / lines | Original assertion obligations | Stage mapping / adaptation |
| --- | --- | --- |
| 12<br>309–342 | Real service: two platforms received=2/deduped=0; changed timestamp/payload replay deduped=2 and stored rows unchanged. | C with real service/client, not only mocked insertion. |
| 13<br>343–352 | Decoy-schema index is excluded from application index catalog. | H catalog helper and E/R/C ownership tests. |
| 14<br>353–359 | Raw migration rerun throws; index names unchanged and one row retained. | Each E/R/C raw rerun fails atomically; full chain has explicit entry-state tests, not unchecked IF NOT EXISTS. |
| 15<br>362–407 | Shadow search_path cannot redirect up/down; cross-family insert count 2; shadow narrow and wide indexes survive. | E/R/C use schema-qualified objects; C cross-family proof and full reverse chain keep decoys untouched. |
| 16<br>409–433 | Three staged platforms (truecoach/conformance_alpha/unknown), same workout s: reconstructed=2, skipped=1, failed=0; repeat leaves 3 ledger rows and 2 targets. | C real reconstruction + second replay; unknown is actual staged value, not invented backfill provenance. |
| 17<br>434–456 | Exact legacy match backfills truecoach, retaining skipped status. Orphan re-up throws NULL error, leaves narrow key and no p column at original pre-expand boundary. | B exact provenance + R refusal; deliberately changed stage boundary: R failure retains E nullable column. Full drained safe unwind to S0 must preserve the original column-absence assertion. Do not claim literal old atomic shape at R. |
| 18<br>457–470 | Platform collision blocks reverse; staging wide index and both rows remain. | C.down; no lossy narrowing. |
| 19<br>471–530 | Non-superuser/non-bypass anon/auth: read/update/delete=0, insert 42501; hostile permissive policy cannot undo restrictive read/update/delete denial. Inherited service-role probe: authorized CRUD counts, transaction rollback leaves original row. | H baseline plus E/R/C. Preserve role flags, grants, transaction rollback and all CRUD checks. Original hostile INSERT probe is not concurrent with hostile policy; add that stronger check separately. |
| 20<br>532–547 | Ledger-only platform collision blocks reverse, leaves 2 ledger rows, wide keys present and first narrow-index creation rolled back. | C.down atomically recreates BOTH narrow indexes; verify no half-narrow state. |
| 21<br>548–571 | Unrelated public object owning expected narrow-index name: migration refuses owner mismatch, decoy table unchanged. | E/R prerequisite guards; C entry/down guards matched to their actual stage; retain exact wrong-owner discriminator. |

Preserve assertion strength and original input fixtures when adapting migration entry states. IDs 08 and 17 explicitly require a full reverse/forward chain in addition to stage-local checks; silently dropping wide-index absence or column-absence checks is not preservation. Keep the original frozen suite intact as a reference; any builder refactor must supply an assertion-level diff and retain all terminal behavior proofs in the activating release.

## 8 / New live proof still required

No item below was run here. Original local proof is PostgreSQL 18.6; the checked CI service uses PostgreSQL 15 and migration dry-run pins 15.18. The old summary’s “not CI 16 equivalence” wording is stale: neither 18.6 evidence nor a written design proves this actual CI environment.

Pinned evidence for this section: [live summary](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/live-summary.json.txt); [new ci](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/new-ci.txt); [base migration ci](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-migration-ci.txt); [base reconstruct](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-reconstruct.txt); [new reconstruct](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/new-reconstruct.txt); [new target helper](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/new-target-helper.txt); [new target boundary](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/new-target-boundary.txt); [new ci proof](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/new-ci-proof.txt).

| ID | Boundary | Discriminating proof | Required by |
| --- | --- | --- | --- |
| M01 | Isolated clients / SQL | Separately generated O/T/N clients in isolated processes; capture actual INSERT, native-vs-emulated upsert, selector, result materialization and SQLSTATE. Negative controls O/R, N/E, O/C. | Before E/T and R/N promotion |
| M02 | Mixed O + T on E | Simultaneous creates/replays for success, skipped and failed branches; NULL claim, O update retains p, no mismatch overwrite and target/ledger atomic rollback. | T |
| M03 | Concurrent migration / backfill | O writes during E lock; lock-timeout atomicity. O inserts after B chunk create late NULL; final drain/sweep required. T claim vs B update and staging mutation serialize correctly. | E, B |
| M04 | Provenance negatives | Orphan, invalid p, wrong family, wrong coach/intent, ambiguous/incorrect prerequisite, non-NULL mismatch, erased staging and SKIP LOCKED retries. No fabrication; no stalled-success report. | B, R |
| M05 | Ready-state refusal | NULL/noncanonical rows cause R atomic refusal; retained old indexes; T still operates. Measure lock/index-build/validation budgets at representative size. Fence obsolete restart paths. | R |
| M06 | Mixed T + N on R | Both real selectors address same ledger; all status paths and unique-conflict retries. New identities remain blocked by narrow keys; verify dedup counts accurately describe that transitional state. | N |
| M07 | Final writer races | N+N same full tuple ⇒ one ledger and one target, correct replay; different platform/family ⇒ distinct outcomes. Success vs failure/skip has explicit non-downgrade semantics or blocks release. | C; no mocked substitute |
| M08 | Concurrent ingest and rollback | ON CONFLICT count accuracy with concurrent replay and new identities. C/down against in-flight writes, staging collision and ledger-only second-index failure; all rows retained, no partial schema. | C |
| M09 | Cursor compatibility | Q0/Q1 decode both directions; limit=1 tied s across p; legacy ambiguity/missing boundary gives documented restart, cross-scope rejection, erased/missing target behavior, bounds. No O reader or T writer active at C. | Q0/Q1 before C |
| M10 | Security / object identity | Stage-specific exact policy catalogs; non-superuser non-bypass CRUD with hostile permissive policies on staging and ledger; affected target owner checks; wrong schema/owner/definition/invalid-index negatives. | H/E/R/C |
| M11 | CI and boundary graph | Run each stage’s complete history and own down/up/rerun; manifest all preserved IDs with zero pending/skipped. Target-selection guards and actual CI job invocation fail closed. PostgreSQL 15 CI rehearsal required. | Every stage; full terminal 21 at C |
| M12 | Snapshot / settled ingestion | Late ingest between reconstruction count, offset pages and final tally: determine supported sealing/quiescence contract and test it. Existing one-time settled gate is not a stable snapshot guarantee. | Decision before activating C |

Measure real concurrency with independent connections/process barriers and assert final rows, status and rollback state—not Promise.all over mocks. Failed proofs block promotion. Original 21 final-state cases are preserved evidence, not a waiver for M01–M12.

## 9 / Honest size and test-density forecast

Measured figures come from the preserved 27-path numstat and actual workflow pathspec. Forecasts are estimates for unbuilt relative PRs; no stage below is certified to fit or pass. Do not hide tests, collapse lines, move required proof after feature activation, or relax the actual gate.

Pinned evidence for this section: [numstat](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/numstat.tsv.txt); [sequencing measurements](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/sequencing-measurements.json.txt); [base gates](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/base-gates.txt); [rules](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/rules.md.txt); [new target boundary](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/new-target-boundary.txt).

Full candidate: +1,550 / −127 across 27 paths. Actual workflow: +1,453 / −118 = 1,335 net counted lines; canonical production excluding tests/docs: +273 / −57 = 216 net. The workflow includes tests, migrations, scripts and CI, while schema.prisma is outside that actual LOC pathspec. These are different measures.

R74 density denominator is added src TS/JS, not all SQL/production lines. Full canonical density = 1,192/158 = 7.544; actual workflow also includes added script TS/JS, giving 1,192/159 = 7.497. The supplemental sequencing measurement’s “wider canonical denominator” note should not be read as including SQL/YAML in R74. Every PR must recalculate both actual workflow and canonical measures.

| Slice | Measured starting point / scope | Forecast actual net / density obligation |
| --- | --- | --- |
| D diagnostics | 4 paths, 133 net; 54 src / 85 tests = 1.574. | 170–220 net. ≥23 additional meaningful test lines needed if src stays 54; forecast 35–80 new tests gives 120–165/54. |
| V validation + contract | 192 net; 83 src + 1 script; 137 tests. | 225–300 net. ≥31 more meaningful tests for actual 168/84; canonical minimum 166/83. Keep old identity comment until C. |
| H useful baseline harness | Original helper 59 + target guard 110 + live file 572 (≈138 setup); CI 19 + CI proof 50. | 320–460 net; mostly tests/CI. Not automatically ≤400. Original target guard reads future live file and cannot be detached unchanged. |
| E nullable expand | Fresh SQL pair + schema + real O/E, rollback/rerun guards. | 100–190 net; ~20–40 SQL plus 80–150 test/support. TS density applies if helper source is added. |
| T transitional writer | New transaction/claim behavior; all branches + actual O/T overlap. | 280–440 net; ~60–100 source additions and 180–260 test additions plus edits. Couple test budget to ≥2× actual source; high end may block. |
| Q0/Q1 reader bridge | Both reader paths/cursors; per-reader functional slices on current base. | 200–380 net per reader slice, conditional on already-landed helper. ≥2× added TS/JS tests; integration overlap can change estimate. |
| B bounded backfill | Operational runner ~40–70 source additions + SQL + negatives/concurrency. | 200–360 net; tests ~140–230, always ≥2× actual source. No generic migration framework. |
| R dual-index ready | ~50–80 SQL + ~160–260 proof/support; schema required p. | 220–380 net; SQL not density denominator, but database behavior proof mandatory. |
| N final writer on R | Frozen writer delta 21/17 plus client/mocks/mixed-mode proof and Q1 emission. | 180–330 net, if reader decoding already landed; source/test ratio recalc at actual relative base. |
| C activate / refuse lossy down | Both index removals atomic + surviving original terminal cases + new C concurrency. | 360–550 net even after useful prerequisites. No claim of a fit. If minimum meaningful delta exceeds 400, STOP for parent scope/sequence redesign. |

Accounting remains complete: measured D 133 + V 192 + kernel 897 + adjacent tests 113 = 1,335. Adjacent tests are reconstruction deltas 1+4+6+27=38 and mixed ingest-idempotency delta 75; allocate each assertion with its behavior, not discard it. Docs and schema are still reviewed despite workflow exclusion. The kernel unchanged is unsplittable as a ≤400 PR; at C both-table contraction, lossy-down refusal and discriminating activation proof form a genuinely coupled unit. Earlier baseline-useful replay/RLS proof is legitimate; feature-only dormant/skipped tests are not.

## 10 / Smallest next writer task and open decisions

Recommendation is bounded and dependency-aware: after the sole backend dependency writer releases its ownership, parent assigns D diagnostics first. This report itself does not claim a writer, generator, database or test slot.

Pinned evidence for this section: [sequencing](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/sequencing.md.txt); [new diagnostics tests](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/new-diagnostics-tests.txt); [numstat](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/numstat.tsv.txt); [rules](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/rules.md.txt).

### D • exact builder scope

Own only src/filters/http-exception.filter.ts, src/observability/orm-diagnostics.ts, src/observability/sentry-config.ts, and test/scout/scout-diagnostics.integrity.spec.ts. Reconstruct the preserved diagnostics delta against the parent-selected exact base; preserve its 85 test lines and assertions. No Prisma schema, migrations, contract generator, package/lock, ingest identity, recovery tree or consumer edits.

Add discriminating coverage, not line padding: cyclic diagnostic causes terminate; ordinary errors preserve intended behavior; malformed P-code strings are not forwarded; initialization/Rust-panic error class/name handling; beforeSend originalException hint detects wrapped ORM errors even without an event type; ordinary events retain expected data while sensitive headers redact; exact safe tags/response sanitization. First compare existing branches to avoid duplicate tests.

Acceptance: meaningful tests cover added branches; if source stays 54 added lines, ≥108 actual added test lines (at least 23 beyond original 85); forecast ~170–220 workflow-net, then remeasure the real diff and banned-token gate. Parent-authorized focused tests/typecheck/lint/build/doctrine and R14 exact-tree audit still required. No product check was run here. Do not treat a source grouping as an already independently passing PR.

### If parent requires database work next

H must be a genuinely executable baseline harness with target-selection refusal, useful existing-key replay/RLS tests and CI invocation proof on its own current base. The preserved 110-line boundary suite directly reads the future 572-line live suite: it cannot be extracted unchanged as a free prerequisite. Build no skipped feature tests or dangling file dependency to manufacture a ≤400 result. If meaningful H cannot fit, return the measured coupling for parent redesign.

### Exact decisions before the relevant stage

| Owner / gate | Decision still open |
| --- | --- |
| Parent + integration owner / before D/V | Exact post-dependency base and sole-writer release; allocate accepted pagination overlaps; reconcile supplemental shared context drift. |
| Parent + DB owner / before B/R | Production volume, representative rehearsal target, tolerable write pause, drain/restart fencing, orphan provenance/retention recovery policy. No database facts inferred here. |
| Backend domain owner / before T/C | Status precedence under concurrent success vs skipped/failed reconstruction; late-ingest sealing/quiescence contract. Implement and prove chosen invariant, or block C. |
| API/contract owner / before Q1/C | Document legacy cursor restart behavior and bounded token format; decide release version/deprecation impact across both endpoints and consumers. |
| Parent / each actual PR | Measure smallest meaningful source+proof delta on landed prior stage; if >400 actual lines, redesign sequence/scope without exemption or deferred activation proof. |
| Parent release owner / before R/C | All mixed-version and down/up boundary evidence, PostgreSQL 15 parity, policy/catalog identity, exact image eligibility and independent audit cycle. No static approval substitutes. |

## 11 / C1 relation, decision record and closeout

Frozen C1 slices are separate provisional local artifacts, not landed consumer contracts. Keep their original pins and evidence; integrate serially in the parent’s generator lane, then regenerate and revalidate against the actual composed surface.

Pinned evidence for this section: [c1 build](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/c1-build.md.txt); [c1a](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/c1a.md.txt); [c1b](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/c1b.md.txt); [new adr](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/new-adr.txt); [rules](file:///home/user/workspace/operator80/execution/recovery-rollout-design/evidence/rules.md.txt).

| Slice | Frozen identity / contract | Implication |
| --- | --- | --- |
| C1a | Input c23b9d9; tree 404dd55d2fde7ab9fab46fb4ea1d27a9d79a7556. Contract 1.5.0; 11 paths / 27 schemas. SHA256 e46b04339f03ff56a5f4dccd8e4e12312c98b9896d7339a8fd4c8ee946b8d00f. | Issuance/storage/echo only, no owner-session route. Reported 202 net; 165/57 density; 158 focused tests. |
| C1b | Input exactly C1a tree; tree 660e436ecbf911b6984b40ed43d135e3dc308378. Contract 1.6.0; 12 paths / 29 schemas. SHA256 f4f2af9aab589b0af491785d901fa51bb4e30ee15de70a0c2e6156338c03b9c2. | Known-ID owner session. Reported 252 net; 176/80 density; 175 focused tests. Use relative patch, never cumulative patch as a second main-relative slice. |

Actual C1/recovery composition conflicts are docs/contracts/importer-openapi.json and scripts/importer-contract.ts, not schema. Recovery validation’s 2.0.0 lineage must not be overwritten by C1’s 1.5.0/1.6.0 metadata. If recovery 2.0 is the settled released base and additions remain additive, 2.1/2.2 are plausible sequential C1 versions—not frozen assignments. Reader contract decisions or intervening work may change them; parent owns final versions/hashes and deterministic generation.

Original complete C1 tree 3c3d09cf95851fb91e66ed20fe770a1a8164845c has separate mapped 18-check synthetic PostgreSQL 18.6 evidence. This is neither recovery mixed-version proof nor consumer readiness. M5/extension/mobile must consume only the integrated frozen contract; pairing is setup, not accepted Start, native data or completion. No consumer release is authorized.

### R138 decision record • proposed, not merge authority exercised

Goal/invariants: preserve ingest identity, replay and provenance while allowing old/new overlap, unchanged RLS and bounded rollback. Options: (A) frozen stop-writer atomic widening—small source delta but rejects rolling compatibility and remains oversized with proof; (B) nullable field plus inference trigger—hides lifecycle work and cannot manufacture missing/ambiguous provenance; (C) E→T/B→R→N→C with reader bridge—chosen, more releases but explicit compatibility and refusal boundaries.

Musk five principles: question the assumed “three PRs”; delete duplicate audit/delegation work, never required assertions; simplify to the existing two tables; accelerate independent D/V and useful H; automate promotion only after tested boundaries. Hyperscaler question: could an on-call owner identify live binary/schema state and safely stop at every boundary? Require version fencing and real rehearsal, not confidence.

GOOD without BAD: retain old-writer compatibility and deterministic provenance without a shadow database or guessing trigger. Root cause: changing a required column and unique arbiter in one rolling promotion invalidates the old generated client, while source-only cursors cannot enumerate newly distinct identities. Structural prevention is dual-index readiness plus old-writer drain, staged client contracts and the reader tie-break—not merely a rollback warning.

Blast radius is Scout staging/ledger writer, reader and release boundaries; target identity schema and RLS semantics are unchanged. Deliberately not built: runtime inference trigger, shadow ledger, generic migration framework, new queue, consumer feature, audit bypass or oversized-PR waiver. Any actual merge still requires the canonical R14 cycle and exact-tree evidence.

### Closeout

All findings, immutable source snapshots, hashes, original case excerpts and this editable report are saved only under /home/user/workspace/operator80/execution/recovery-rollout-design/. Source/product indexes and frozen inputs were not edited. No active execution resource is held; release all readiness-lane ownership to parent and the sole backend builder. Status is design proposed / proof outstanding, not CLEAN.

## Execution closeout

**Ownership released.** Parent and sole backend builder retain source-writer, migration, generator, database, deployment and product-test resources. No resource is held by the readiness lane. All new behavior remains proposed until implementation, real boundary proof, actual gate measurement and the canonical audit cycle complete.

VERDICT: FINDINGS
