# N/Q1 slice (final wide-selector writer + cursor v2 emission / legacy-boundary resolution) — readiness brief

Status: read-only brief (T3 writer). No code, worktree, test, push, lock or ref write. Evidence = git object reads at R head
`7d2895e1fe03ea82353e8ce0b07aacaf66af74c8` (B `0d69c7ba` + R `df36e331` + `7d2895e1`) unless marked. "Handoff Lnn" = `/tmp/tgp-private-evidence/execution/95633079/s7-b-drain/evidence/CYCLE3_ROLLOUT_IMPLEMENTATION_HANDOFF.3300d315.md`. Route requested Claude Opus 5 / XHigh; no telemetry claimed.

## 0. Source of truth (blob @7d2895e1, lines)

| File | Blob | N/Q1-relevant fact |
|---|---|---|
| `src/scout/scout-cursor.ts` (83) | `734b9e6b` | **Q0 exists.** Max 8192 (L7); ORDER `source_id:asc,source_platform:asc` (L8); `value()` non-empty, ≤256 code points, no NUL/surrogate (L11-22); `v2.` prefix (L35); exact base64url roundtrip (L38); legacy roster = raw source id, unbound (L39-42); c/i/s valid and c=coach,i=intent,f=family (L46-54); canonical object key order `{v,c,i,f,o,s,p}` (L55-57); v2 needs `v===2` + `isCanonicalPlatform(p)` (L58); exact JSON re-encode (L59); all failures `400 'malformed cursor'` (L62). Legacy → source-only predicate (L66,69); v2 → `OR[s>b.s, (s=b.s ∧ p>b.p)]` (L70-72); order: legacy/first page `{source_id}` only, v2 `[source_id, source_platform]` (L75-83). **No encoder in module.** |
| `src/scout/scout-roster.service.ts` (201) | `58236753` | Decode family `'clients'` (L59); 404 settled gate (L85); ledger page `...scoutCursorWhere(after)`, `select {source_id,target_id}` (no p), `orderBy scoutCursorOrder(after)`, `take limit+1` (L102-106); RepeatableRead (L115); `next_cursor = encodeCursor(last.source_id)` (L126); `encodeCursor` = raw base64url s → **legacy, unbound** (L199-200). Doc "ordered by source_id" (L33). |
| `src/scout/scout-entities.service.ts` (209) | `cf39a652` | Family fail-closed, `clients` excluded (L66-68; DTO L64-71); decode (L76); same page shape (L109-113), RepeatableRead (L122); emits `encodeCursor(c,i,f,s)` (L132) = JSON `{c,i,f,o:'source_id:asc',s}` (L20, L206-208) → **legacy, scope-bound**. Doc L37. |
| DTOs / controllers | `49df4e7d` `69643519` `0585fd10` `722700b7` | Cursor text "Accepts legacy and scoped v2 tokens; emits legacy" (roster.dto L47, entities.dto L77); `@MaxLength(SCOUT_CURSOR_MAX_LENGTH)` (roster.dto L52, entities.dto L84); 400 descriptions roster.controller L43-48, entities.controller L50-55. |
| Contract | `ba827258` `55c864ea` `eeda5bbe` | `CONTRACT_VERSION '2.0.0-c1-s1.1'` (scripts/importer-contract.ts L48; "Not consumer-frozen" L45-47); generated JSON version L899, "emits legacy" L2001 (entities), L2115 (roster); pin test/contracts/importer-contract.spec.ts L442. |
| `src/scout/scout-reconstruct.service.ts` (356) | `a16bc817` (= T blob; R did not touch it) | Staging page `orderBy {source_id}` + `skip` (L84-91); noncanonical staged p → 409 `ProvenanceConflict` (L180-181, class L327-331); success txn persist→claimAndWrite under `retryContention` (L209-224); non-ProvenanceConflict error → `writeOutcome(failed)` (L225-235), whose own failure propagates (L246-252); narrow identity {c,i,e,s} (L265-270); upsert `where coach_id_intent_id_entity_type_source_id`, create carries p, `update:{}` (L272-278); claim `updateMany OR[{p:null},{p:row.p}]` must be 1 (L279-286); success-dominates precedence (L291-299); P2002/P2034 retry once (L334-345). Doc L35-37 still narrow. |
| `prisma/schema.prisma` | `bd3e0078` | Ledger `source_platform String?` (L6945), narrow unique (L6951), D1 comment (L6952-6955), wide `ScoutReconstructionLedger_identity_key` (L6956). DB is NOT NULL + canonical CHECK since R (migration.sql L124-129, wide indexes L135-137). Ledger has no relations/cascades; `src/` has no ledger delete. |
| Unit tests | `8286de57` `85c6dd3e` `d4ce62ec` `ca402ea4` `181ea64b` `be107491` `b50d98c2` | scout-cursor.spec (v2/legacy/malformed/worst-case Unicode); reader fakes filter `source_id.gt` and sort by s only (roster spec L129-139; entities spec L107); writer fakes nullable p + narrow selector (service.spec L29,L143,L160-164; families.spec L29,L131,L148-152; conformance-alpha.e2e L137,L256,L273-277). |
| PG proofs (reuse, don't rerun) | `b3af897e` `0ae7b764` `aa35e7e2` | S5 etq0 stage 4 (L1002-1110): Q0 real-PG pages, v2 accepted, cross-scope 400, hidden/erased targets, **tie characterization via temporary future-schema fixture** (drop ledger narrow index in try/finally, L1056-1082; "Q1 is required before widening" L1073), 8192 bounds (L1084+). R spec (678 lines) has no reader case. Shared worker drives real roster/entities/reconstruct with per-process `root`/`client` (L10-17, L78-95); barriers `staged`/`before-ledger`/`claimed` (L49,58,63 — `claimed` fires only on a claim `updateMany` carrying p). |

## 1. Current reader / Q0 state (answer to Q1)

- Q0 is landed on both readers: dual decoder, v2 tie-break predicate, 8192 bound. **Q0/Q1 do not collapse**; Q1 = emission + legacy resolution + first-page order only.
- Both readers still emit legacy (roster unbound raw s; entities scope-bound JSON) and order the first/legacy page by `source_id` only. On R this is still exact (narrow (c,i,e,s) unique ⇒ no ties); it is the C counterexample.
- Writer after R: still T (narrow selector + null-claim), byte-identical to the accepted T blob; Prisma `String?` over a NOT NULL column (D1).
- Only callers of the cursor module: the two services (+ DTOs). Endpoint binding holds through family: roster ⇔ `f='clients'`, entities ⇔ non-person families.

## 2. First-party consumer check (mobile / extension)

- Mobile main `c7641cb3` (read via blob-identical `worktrees/ux03c-compose` @c7641cb: `f2abfecf`, `232f462b`, `d95034cd`; the landing clone is partial and lacks these blobs): only `GET /scout/reconstruct/entities` (importReviewApi.ts:37); cursor passed through opaquely (importReviewApi.ts:33; useReconstructCounts.ts:53,56 `getNextPageParam: last.next_cursor ?? undefined`); schema `next_cursor: z.string().nullable()` — no format/length check (types/importReview.ts:46). The hook is **not mounted** in production code (ExtensionPairingPanel.reconstruct.test.tsx:104-109) and flag `importReview` defaults false (featureFlags.ts:433). No roster-endpoint consumer (useRosterReviewDelta reads coachStore).
- Extension (`ext-full` HEAD `0111be6`; also `b-ux07/head 6fd7e4a`, `b-s4/... 91990ae`): calls only `/api/scout/ingest`, `/ingest/complete`, `/progress`. Its cursor code (shared/replay/engine.js:342-347) paginates **source** platforms and never touches TGP reader tokens.
- ⇒ v2 emission needs **zero** mobile/extension change; no consumer parses tokens.

## 3. Proposed cursor v2 contract (normative for Q1)

1. **Format:** `"v2." + base64url(utf8(JSON.stringify({v:2,c,i,f,o:"source_id:asc,source_platform:asc",s,p})))`, key order exactly as the decoder's canonical object (scout-cursor.ts L56). One shared builder is used by encoder and decoder so they cannot drift.
2. **Roundtrip:** `decode(encode(x)) === x` for every emitted boundary; decoder keeps exact base64url + exact JSON re-encode (L38, L59): no extra keys, whitespace, reordering, duplicates, padding.
3. **Binding:** c = authenticated coach, i = request intent, f = family (roster `'clients'`; entities its family). Cross-coach/intent/family/endpoint ⇒ 400 before any page read (existing behaviour).
4. **Bounds:** c/i/s `value()`; p `isCanonicalPlatform` (≤256, `[a-z0-9][a-z0-9._:-]*`); total ≤8192 enforced pre-decode (L34) and by DTO. Worst case (three 256-code-point fields of `\u00XX` escapes + 256-char p) ≈ 6.6k chars < 8192. Emission-side: s is ≤256 UTF-16 units at ingest (scout-ingest.dto.ts L70) and PG text excludes NUL, so every stored boundary is emittable; the encoder asserts `value(s) && isCanonicalPlatform(p)` and fails closed rather than emit an undecodable token.
5. **Emission:** every page with more rows emits v2 from the **last ledger row of the page** (`select` adds `source_platform`); ledger-anchored, so hidden/erased targets never stall paging.
6. **Ordering:** all pages, including the first and legacy-resolved ones, use `ORDER BY source_id, source_platform` and the lexicographic OR predicate.
7. **Legacy resolution (Q1):** inside the same RepeatableRead transaction, after the 404 gate: `findMany where {coach, intent, entity_type, status:'reconstructed', source_id:s} select {source_platform} take 2`. Exactly one row with canonical p ⇒ boundary (s,p). Zero or ≥2 ⇒ 400, documented as "restart pagination from the first page"; no page read. Roster legacy tokens stay unbound and are resolved **only** inside the requested (coach, intent, 'clients') scope, never widened.
8. **On R this is observationally identical to Q0** for every legitimately emitted legacy token (narrow uniqueness ⇒ ≤1 row; boundaries are reconstructed rows, which never leave that status (L291-299) and are never deleted). The only R-visible change: a forged or cross-intent roster legacy token naming an absent s is now 400 instead of silently continuing.
9. **Fixed release capability**, no flag/config switch (handoff L140).

Parent-decidable choices (recommendation first):
- **P1** Unresolvable legacy message: reuse `'malformed cursor'` (zero new public strings; existing no-reflection tests apply; restart documented in DTO/controller 400 text) vs a new distinct "restart" message.
- **P2** Missing boundary on R: always 400 (single code path) — recommended. A source-only fallback on R would need runtime schema detection = the configuration switch the handoff forbids.
- **P3** Contract version label: bump prerelease (e.g. `2.0.0-c1-s1.2`), regenerate once, update pin L442; C1 pair-surface subset must stay byte-identical (only the two cursor descriptions + 400 texts change).

## 4. Final required-p writer (N)

- Prisma ledger `source_platform String` (L6945) and rewrite the D1 comment (L6952-6955); regenerate client (removes the informational DROP NOT NULL drift). No migration packaged; C (narrow drop, C.down refusal) out of scope.
- Upsert on `coach_id_intent_id_entity_type_source_platform_source_id` (five fields); create unchanged; `update:{}` unchanged.
- Delete the null-claim `updateMany` (L279-286); it is dead under the wide selector and no longer type-checks. Precedence `updateMany` (L291-299) keyed on the five-field identity.
- Staging page order `[{source_id},{source_platform}]` (L88) — deterministic final-writer order (exact on R already; needed at C).
- Keep target-before-ledger lock order (L211-212), `retryContention` P2002/P2034 once (M06/M07 concurrent races), `ProvenanceConflict` for noncanonical staged p (L180).
- **Narrow collision on R** (existing ledger (c,i,e,s,p1), staged (s,p2)): T answers 409 (claim count 0, L286). N's wide arbiter misses, INSERT hits the narrow key ⇒ P2002 twice ⇒ `writeOutcome` P2002 twice ⇒ raw 500 (no fabricated row). Required N outcome: map a persistent narrow-key P2002 to `ProvenanceConflict` (409, nothing written) = T parity. Product reachability on R is fixture-only (staging (c,i,s) unique + DO-NOTHING ingest + exact-join backfill ⇒ ledger p = staged p), so this is an acceptance requirement, not a blocker.
- Native vs emulated Prisma upsert branch is **recorded** from query logs (M01), not assumed.
- Retype fakes: nullable p → `string`, narrow selector → five-field selector, drop OR-claim emulation (files/lines in §0).
- Unchanged: families.ts persist (targets already platform-qualified), backfill raw SQL, tally.

## 5. Release / slice decomposition (answer to Q4)

**"Emit v2 only after all live readers decode v2" is satisfied in ONE release on R.** Live readers at R are T/Q0 (decode v2: L35-73; real-PG evidence etq0 L1025-1027, L1069-1077) or N/Q1. O images are gone before R (R row precondition "after O/invalid old ingress drained", handoff L96; O is NOT compatible on R, L70). Mixed pods are token-compatible both ways: Q1 v2 → Q0 uses tie-break; Q0 legacy → Q1 resolves. Rollback N/Q1 → T/Q0 on R is token-safe (handoff L97). Mobile/extension need nothing (§2). ⇒ one N/Q1 release artifact; no separate Q1-first release.

Release preconditions (release-owned, not local blockers): R deployed (N/Q1 on E is NOT compatible, L72 — the required-p client cannot read NULL history); drain every T/Q0 image before C (L97).

One candidate, three owned sub-slices (disjoint paths; one writer each):

| Sub-slice | Owned paths | Tier / review | Estimate (net) |
|---|---|---|---|
| NQ1-a Q1 reader | `src/scout/scout-cursor.ts`, `scout-roster.service.ts`, `scout-entities.service.ts`, `scout-roster.dto.ts`, `scout-entities.dto.ts`, `scout-roster.controller.ts`, `scout-entities.controller.ts` (400 text); `scripts/importer-contract.ts` (L48 only); `docs/contracts/importer-openapi.json` (regenerated only); `test/contracts/importer-contract.spec.ts`; `test/scout/scout-cursor.spec.ts`; `test/scout/roster/scout-roster.service.spec.ts`; `test/scout/entities/scout-entities.{service,contract}.spec.ts`; controller specs only if they pin changed text | alone = T3 | src 110-200; tests 150-250 (handoff L241: 200-380 per reader slice incl. tests) |
| NQ1-b N writer | `prisma/schema.prisma` (ledger L6945 + comment only); `src/scout/scout-reconstruct.service.ts`; `test/scout/reconstruct/{scout-reconstruct.service,scout-reconstruct.families,conformance-alpha.e2e}.spec.ts` | T4 (persistent identity arbiter + generated client; same class as `R_IDENTITY_READY_BUILD_GRANT.md` L11) | src 40-90; tests 60-150 (handoff L244: 180-330 incl. Q1 emission) |
| NQ1-c PG proof (test-only) | `test/rls-g2-nq1.spec.ts`; `test/utils/g2-nq1-{db.ts,pg-harness.ts,harness.ts,bootstrap.sh}`; `test/scout/g2-nq1-db-guard.spec.ts`; `test/utils/g2-nq1-worker.cjs` only if a new barrier is needed | proof, part of the T4 candidate | 1,200-1,700 (R precedent ≈1,600 across six files, mostly substitution) |

- Candidate tier **T4**: two independent adversarial exact-head reviews, lenses (1) writer identity/concurrency/client, (2) cursor contract/pagination completeness. NQ1-a and NQ1-b are compile-independent (the resolution guard `isCanonicalPlatform(row.source_platform)` type-checks under `String?` or `String`); schema.prisma is owned only by NQ1-b.
- Recommended staffing (parent-decidable): builder 1 = NQ1-a then NQ1-b in one worktree, builder 2 = NQ1-c substitution in parallel from the R harness files, composing on builder 1's head. One builder sequential is the fallback.
- Base: R-accepted head. src/unit work may start from `7d2895e1` now (N/Q1 touches no R migration/harness path; only schema.prisma L6945-6955 is near R's hunk) and rebase if R closure changes; the PG run waits for R acceptance and the heavy slot.
- Not owned: every migration, C, native writers, backfill, B/S5/T-Q0/R harness files and specs (byte-identical, incl. `g2-tq0-worker.cjs`), CI/release, mobile, extension.

## 6. Proof needs

Default Jest (+ tsc, eslint two-path, prettier, check-r75, hooked Bradley commit, as R):
- cursor: encoder output exact shape/key order; `decode(encode)` roundtrip for worst-case values; emitted max token ≤8192 through ValidationPipe; all existing malformed/cross-scope cases unchanged.
- readers: fakes extended to OR predicate + (s,p) sort + `source_platform` select (fake-only; PG is authority); every page emits v2; first page ordered (s,p); legacy resolves 1 → same page as before; 0 → 400 with no page read; resolution inside the transaction after the 404 gate; roster legacy never leaves (coach, intent, 'clients').
- writer: five-field selector; no claim step; narrow P2002 → 409 nothing written; P2002/P2034 retry retained; precedence unchanged.
- contract: version pin, regenerated JSON, pair-surface subset unchanged; guard spec for the new PG identity.

Live PG17 proof `test/rls-g2-nq1.spec.ts` — R pattern reused: sixth disposable identity `g2_nq1_disposable`, cluster marker `nq1-disposable-pg17`, `G2_NQ1_*` env, five-placeholder binding, single-run grant, heavy slot `execution/test-validation.lock`. History S1, C1, E, B, R applied by file; `migrate deploy` must apply **nothing** (N/Q1 has no migration). "Old" process role = T: detached checkout of the accepted R head + T client generated there (substituting `G2_R_OLD_ROOT/CLIENT`, g2-r-ready-pg-harness.ts L27-28, L175-181). N barriers use `staged`/`before-ledger` (N has no claim, so `claimed` never fires).

| ID | Case (source) | Pass condition |
|---|---|---|
| N01 | Clients / catalog (M01) | N client from candidate schema, T client from R head, both on R; catalog byte-identical before/after; zero pending migrations; N query log records native-vs-emulated upsert and five-field selector. |
| N02 | N on R | New staged rows reconstruct; replay mints nothing; per-family tally equals T on the same fixture; ledger p = staged p. |
| N03 | Mixed T+N (M06) | Paused T/N workers, both orders, same identity: one ledger row, one target; success dominates failed/skipped both ways; P2002 retry path observed. |
| N04 | Narrow collision (fixture) | Ledger (s,p1) + staged (s,p2): N → 409, ledger/target unchanged; T same fixture → 409 (parity). |
| N05 | N/E negative (M01) | N client on E with one NULL-p history row fails closed (no fabricated outcome, no partial write); recorded as the release-order precondition. |
| N06 | Rollback N→T | After N writes, T replays/continues on R with identical ledger/targets; T/Q0 readers enumerate the same union. |
| Q01 | Emission | Every non-final page v2 with exact canonical JSON; first-page SQL orders (s,p); union = ledger reconstructed set; RepeatableRead observed; clients + one entity family. |
| Q02 | Both directions (M09) | Chains Q1→Q0→Q1 and Q0→Q1→Q0 with limit=1: exact union, no dup/skip. |
| Q03 | Legacy resolution | Q0-emitted roster and entities legacy tokens → Q1 returns the same next page as Q0; forged/absent s → documented 400, no page read; a roster token from intent A resolves only inside intent B. |
| Q04 | Ties (M09; etq0 L1056-1082 technique) | Temporary future-schema fixture (drop ledger narrow index, restore in finally): limit=1 over s tied across p1..p3 → Q1 enumerates all exactly once (closes etq0 L1073 limitation); Q0 fed Q1's v2 tokens also enumerates all; legacy boundary with ≥2 tied rows → 400 restart. |
| Q05 | Scope / endpoint | v2 roster token on entities (and reverse), foreign coach/intent → 400 `malformed cursor`; foreign-scope rows invisible (etq0 L1028-1038 pattern). |
| Q06 | Erased / missing targets | Foreign/deleted/`Deleted` targets hidden, cursor still advances, final `next_cursor` null (etq0 L1039-1052 pattern). |
| Q07 | Bounds | Maximal emitted v2 token ≤8192 accepted back by Q1 and Q0; >8192 and malformed → bounded 400 without reflection. |

Acceptance = N01-N06, Q01-Q07 once on the exact candidate head with raw receipts, gates green, both T4 reviews closed. No deployment, real-environment drain or customer acceptance is claimed. M07 (N+N final-writer races on C) and M08 stay with C.

## 7. Findings (Safety ROI)

- **B1 — shared generated client during the running R proof.** Harm: if the N/Q1 worktree reuses R's `node_modules` by hard link, `prisma generate` for the `String` flip can rewrite inodes that R's live workers load (`resolve(root,'node_modules/.prisma/client')`, g2-r-ready-pg-harness.ts L181), making R receipts non-attributable; it can also corrupt N's own client provenance. R's client files currently have link count 1 (read-only stat). Blocks: N/Q1 environment setup while R proof runs. Minimum closure: before generate, give the N worktree its own non-linked `node_modules/.prisma` (link count 1 verified) or generate only after the R run. Unlocks: parallel N/Q1 build now.
- No A findings. Q0 limitation (source-only legacy on R) is exact under narrow uniqueness; its fix is scope, not a defect.
- **C (record only):** (1) the accepted etq0 spec pins Q0 legacy emission (L1019-1027, L1071-1075) and the B/R specs run the T writer from the candidate root; they stay evidence for their own heads, are not edited or rerun at N/Q1, and default Jest ignores `test/rls-*`. (2) Mobile header says "contract 1.4.0" (importReviewApi.ts:3), stale label, no action. (3) Staging `skip` offset paging is safe only because reconstruct is post-settle (reconstruct L30); unchanged. (4) Process: a scratch schema copy at `/tmp/nq1_schema.prisma` was created and removed outside the workspace; one `git grep` in the partial mobile clone tried a lazy promisor fetch and failed at authentication before any transfer; later reads used `GIT_NO_LAZY_FETCH=1`. Nothing was written to `worktrees/s7-r-ready`. (5) No other active lane in SCOPE/DISPATCHES owns these paths (handoff L142 reconcile check).

## 8. Owner-reserved

None for build or local proof. Handoff owner row L274 (version/deprecation) is parent-decidable here: the contract is not consumer-frozen (L45-47), the only consumers are first-party and treat the token as opaque (§2), and Q1 deprecates nothing (legacy is still accepted and resolved). Stays with Bradley: production deployment/enablement of the N/Q1 image (release gate), and any later decision to stop accepting legacy tokens (not N/Q1).

## 9. Next bounded task (dispatch when parent freezes P1-P3)

`nq1_final_writer_reader_t4_build`: new isolated worktree from the R-accepted head (or `7d2895e1` with rebase); non-linked `.prisma` (B1); NQ1-a → NQ1-b per §3-4; NQ1-c substitution from the R harness (identity/markers per §6, R/B/S5 files byte-identical); gates; hooked commit; report head/tree/blobs/`index.d.ts` hash; filled PG binding; request single-run grant; on grant run N01-N06, Q01-Q07 once, preserve receipts under `execution/cf8ff737/nq1/runtime/**`, release slot, return without self-acceptance. Then two T4 reviews. Out of scope: C migration, narrow-key drop, C.down, native writers, G3-AUTH, mobile/extension edits, deploy/push/merge.
