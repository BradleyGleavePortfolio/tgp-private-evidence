# S10-D D2 independent review (T4) — synthetic unseen source `s10_unseen`

Parent: EXEC-FA72EFB2. Grant: `execution/fa72efb2/s10d2/D2_REVIEW_GRANT.md`. Rules: `execution/fa72efb2/WORKER_RULES.md`.
Reviewer posture: read-only. No jest, tsc, eslint, prettier, npm, PG, lock; no edits; no commits. Nothing under the
subject worktree was written.

## Verdict: GO

No A or B finding. Every finding below is C (record, qualify, continue). The 8 D2 files prove the north-star invariant
as designed: the new source is 59 lines of JSON in `src/` and 0 lines of TypeScript/JavaScript; no core path names the
slug or a `u10_*` key; the observer key is never a verifier; signatures bind the server challenge, the scope digest,
the family and the id-set digest; unknown stays unknown; the test assertions discriminate.

## Subject as read

Worktree `/home/user/workspace/worktrees/fa72-d2`, HEAD `6a33df9b` (`git log -1`), `git diff --name-only 6a33df9b`
empty (no tracked file modified), `git ls-files --others --exclude-standard` = exactly the 8 allowed paths, all mode
644 regular files, no symlinks (`find -type l` empty). sha256 (all equal to the builder summary and re-checked at the
end of the review; bytes did not change while I read):

| path | sha256 | lines |
|---|---|---|
| src/scout/reconstruct/sources/s10_unseen.json | cce631bd9ad29efa80f32881891034916cd7ad75c21a6b85e66a85435684eded | 23 |
| src/scout/reconstruct/native/sources/s10_unseen.json | 3da5ba57a6617b214ce64133e19902cfe45e4752b5cc96dc43e5421814f2ac80 | 18 |
| src/scout/induction/sources/s10_unseen.json | 14f7168bf77f156d9a7ba6f709d0422da322afff58c0b14e1787a786fea175f2 | 18 |
| test/fixtures/scout/s10_unseen/staged-rows.json | 64d20d72bb62ee95b4944053588715910e2773a61817e6d52f235e5631c2b646 | 38 |
| test/fixtures/scout/s10_unseen/statements.json | 101fb407b5901465690ab59da121e78fc2d2703ed8b74cfa11c1a9bcde7e330d | 13 |
| test/fixtures/scout/s10_unseen/signer-test-key.json | f7652e25fab3e32bd82f394de0fb0e32dbb02559e761c1ec87a54977ff8611cf | 15 |
| test/scout/s10/s10-unseen.e2e.spec.ts | 54ea91c28877a45ab88f1cb2df9a375566c28222d7cb39709a879eb9396f3450 | 367 |
| test/scout/s10/s10-unseen.pg.spec.ts | d37a65c86b64d4ad853653b0a96c9270a7b51ab9962e8607db21e4ce440ce514 | 361 |

Also read: `docs/decisions/2026-09-26-s10-induction.md` (D-S10-1 L60-89, D-S10-5 L297-320, R27/R39/R40/R41
L408-451), `scripts/s10-core-diff-gate.sh`, `src/scout/induction/{verify,parse,manifest-registry,observation.service,
observation.controller,digest}.ts`, `src/scout/reconciliation/{facts.service,reconcile}.ts`,
`src/scout/reconstruct/{mapping-spec,source-mapper-registry}.ts`, `src/scout/reconstruct/native/{native-rules,
native-rule-registry,native-families}.ts`, `src/scout/reconstruct/orchestration/family-plan.ts`,
`src/scout/scout-reconstruct.service.ts`, `src/scout/scout-platform.ts`, `test/utils/g2-s10b-{pg-harness,db,harness}.ts`,
`jest.config.js`, `nest-cli.json`, the B-side specs touched by `7746a87`, and the S10-A fixtures under
`test/fixtures/scout/s10_pure/`.

## Commands run (all read-only; RC in brackets)

- `git status --short`, `git log --oneline -3`, `git diff --stat`, `git diff --name-only 6a33df9b` [0, empty diff]
- `sha256sum` / `wc -l` / `stat -c %a` over the 8 paths; `find <4 dirs> -type l` [0, no symlinks]
- `rg -F -l s10_unseen src --type ts` [1 = no hits]; `rg -l 'u10' src --type ts` [1]; `rg -n 'u10_' src/scout/reconstruct/*.ts` [1]
- `rg -F -l s10_unseen src` [0: exactly the three JSON files]
- `git ls-files --others --exclude-standard | rg '^src/.*\.(ts|js)$'` [1 = no TS/JS added under src]
- `git diff --quiet 6a33df9b -- scripts/s10-core-diff-gate.sh nest-cli.json` [0, unchanged]
- one `node -e` ed25519 check (sign/verify with the fixture private keys against the manifest public key; JSON.parse of
  the five data files) [0]: source key verifies against the manifest key: true; observer key: false; each fixture
  public key equals the key derived from its private key; all five JSON files parse.

## Question 1 — Core diff = 0

**Answer: yes.**

- Only the 8 allowed paths: `git status --porcelain` lists exactly those 8 untracked paths and zero modifications;
  they equal the gate's `ALLOWED` array (`scripts/s10-core-diff-gate.sh` L28-36) and D-S10-5's allowed set
  (`docs/decisions/2026-09-26-s10-induction.md` L303-306).
- No TS/JS in `src`: the three `src` additions are `.json` (59 lines total). `rg` for `^src/.*\.(ts|js)$` over the
  untracked set exits 1.
- No slug / `u10_*` key in `src/**/*.ts`: `rg -F -l s10_unseen src --type ts` exits 1 (gate check [5] as specified at
  L307-309); `rg -l 'u10' src --type ts` exits 1. The slug appears under `src` only in the three JSON files.
- Data declares meaning; no code special-cases the source:
  - mapping spec (`src/scout/reconstruct/sources/s10_unseen.json` L4-8 steps, L9-21 families, L22 sharedIdSpaces) uses
    only the S8-A grammar: `paths` + `coerce ∈ FIELD_COERCIONS` (`mapping-spec.ts` L77), `sharedIdSpaces` validated
    generically at `mapping-spec.ts` L407-430;
  - native rule set (`native/sources/s10_unseen.json`) uses `integer` and `enum` rule kinds with `map`/`default`
    (`native-rules.ts` L44-55); `default: "strength"` is in `WORKOUT_PLAN_TYPES` (`native-contract.ts` L136);
  - manifest (`induction/sources/s10_unseen.json`) matches `InductionManifestV1` (doc L57-63); cross-checks V2/V3/V4
    run generically in `buildInductionRegistry` (`manifest-registry.ts` L119-150): `expectedFamilies` = spec families
    (both `clients, programs, workouts`), `nativeRules: 'declared'` ⇔ rule set loaded, rule-set families
    `{programs, workouts}` ⊆ expectedFamilies.
  - Dispatch is by loaded data: `buildSourceMapperRegistry()` (`source-mapper-registry.ts` L84-88), `loadNativeRuleSets()`
    (`native-rule-registry.ts` L23-52), `loadInductionManifests()` (`manifest-registry.ts` L25-58); the evaluator
    dispatches on `basis_kind` only (`verify.ts` L18-20, L196-210). `isCanonicalPlatform` is a token-format check, not
    an allow-list (`scout-platform.ts` L2-9).
- Gate script and `nest-cli.json` are byte-identical to base 6a33df9b; `nest-cli.json` L11-13 already copies all three
  `sources/*.json` directories as assets (D1), so nothing per-source is needed in the build.

## Question 2 — Security / honesty

**Observer key never a verifier.** The manifest lists exactly one verifier, `s10_unseen.source.d2`
(`induction/sources/s10_unseen.json` L10-16); the observer pair `s10_unseen.observer.d2` exists only in
`test/fixtures/scout/s10_unseen/signer-test-key.json` L9-14 and is loaded by nothing under `src` (`rg fixtures src
--type ts`: no fixture reads). The e2e asserts it: verifiers `toEqual([KEYS.source.key_id])` and
`not.toContain(KEYS.observer.key_id)` (e2e L288-289). Verification looks the key up per package by `key_id`
(`verify.ts` L224-225) so an unlisted key yields `null` → `known: false`. My node check confirms the observer
private key does not verify against the manifest public key.

**Signatures bind the server challenge + id-set digest.** The signed statement (e2e L99-111; pg L160-172) carries
`challenge_b64`, `id_set_digest`, `observed_unique`, `account_scope_id_digest`, `family`, `source_platform`,
`issued_at`, `snapshot_ref_digest`, `terminal`, `date_window`, `statement_version`. The server checks: signature over
the decoded statement bytes (`verify.ts` L229), platform/scope/family match (L232-234), challenge equality with the
declaration (L235), terminal/date_window (L236), `issued_at ∈ [accepted_start_at, received_at]` (L238-239), and the
statement's `id_set_digest` against the staged digest (L324-326) with count consistency (L327-330). Store time does
not verify (`observation.service.ts` L266-297 is grammar + declared-unit + manifest checks), so observer-signed
evidence is stored and fails only at settle — exactly what R39(f) exercises. In the pg spec the challenge is the
server's random one (`declared.challenge_b64`, pg L209-216, L256) and `issued_at` is placed strictly after the run's
`accepted_start_at` and before the upload (pg L247-251).

**Independent reference digests.** The test's `referenceIdDigest` (e2e L70-77; pg L49-56) is length-prefixed,
bytewise-sorted, distinct ids — the same construction as `identitySetDigest` (`digest.ts` L77-90) but written
independently; the empty set is sha256 of nothing = `EMPTY_IDENTITY_SET_DIGEST` (`digest.ts` L93). `statementBytes`
(sorted keys, compact JSON) matches `canonicalJson` for these ASCII/null/integer values (`digest.ts` L36-63) so
`parseStatementBytes` L150's canonical-bytes check passes.

**Unknown stays unknown.** e2e (e) L324-328: omitted programs statement → `{known: false}`, others known; e2e (f)
L330-335: every family `{known: false}`; pg (f) L345-353: `completeness_basis 'none'` and `observed_unique null` for
every family, reason `coverage_basis_unknown`. No `0` appears where the basis is absent; the `0` at e2e L303 is the
source-signed empty set (statement `observed_unique: 0` with the empty-set digest), which is the D-S10-6 §2 rule.

**No fabricated completeness.** `complete` is asserted only in pg (a) and R41 after a real S8-G pass with native rows
and the source-signed basis on every token (pg L294-307). The synthetic key is described as a stand-in for a source,
never as a real platform's completeness (e2e header L11-12; doc L314-318).

**Test keys vs production paths (the grant's explicit question).** Facts:
- The PUBLIC key is in a production-loaded manifest: `loadInductionManifests()` runs in `ObservationService.registry`
  (`observation.service.ts` L109-115) and `ReconciliationFactsService.defaultRegistry` (`facts.service.ts` L358-368),
  and `nest-cli.json` L13 copies `scout/induction/sources/*.json` into `dist`. The PRIVATE key lives only under
  `test/fixtures/scout/s10_unseen/` (not an asset; nothing under `src` reads `test/fixtures`).
- Could a production run accept statements signed with the committed private key? **Yes, but only a run that declares
  platform `s10_unseen`.** The verifier lookup is per package (`verify.ts` L224 `pkg.manifest.verifiers`), the
  package is chosen by the declared platform (L278), the statement's `source_platform` must equal that platform
  (L232), and observe() refuses evidence whose `(platform, scope)` is not declared or whose platform has no manifest
  (`observation.service.ts` L267-273). No real-platform unit can be proven with this key; there is no shipped verifier
  for any real platform (doc L86-89) so no real-platform run can reach `complete` at all today.
- Concrete consequence: a coach holding a valid bearer token on a deployment with `FEATURE_SCOUT_INGEST` on could
  self-certify a `complete` verdict for a fictional platform in their own tenant, having staged their own rows (which
  they could already do for `conformance_alpha`/`truecoach` — "registration is dispatch, not authorization",
  `source-mapper-registry.ts` L84-88). No cross-tenant read/write (D-S10-6 §4), no customer-facing side effect (§5).
- This is the shape D-S10-1 chose on purpose ("The only verifier it ships is the synthetic `s10_unseen` test key
  (D-S10-5). Its private half exists only in named test fixtures", doc L87-89), and the precedent for synthetic data
  in `src` is `conformance_alpha.json`/`conformance_beta.json`. **Classification: C** (finding C1 below): no decision
  is blocked and no third party is harmed; recorded for the owner as a follow-up design choice, not a D2 defect (a fix
  would be a generic core edit, out of D2 scope by construction).
- The D2 key pair is fresh: `vK4m1R…` (key_id `s10_unseen.source.d2`) ≠ the S10-A pure fixture `B4PqUo…`
  (`s10_unseen.source.test`), so the B-side invariant "no shipped manifest trusts the fixture signer"
  (`test/scout/reconciliation/facts.service.coverage.spec.ts` L610-616) holds against D2's manifest.

## Question 3 — Do the R39 (a)-(f), R41, R27 assertions discriminate?

**e2e (no-DB, all through repository-default loaders):**
- (a) L297-305: requires `known === true && covers_staged_identities === true` for all three families AND exact
  counts 2/0/2. An evaluator regression to `{known: false}`, a wrong digest, a wrong count, or the two-step
  `workouts` id space failing to merge each fails. Discriminates.
- (c)/(d) L307-313: `workouts` count 3 with the client-linked row; all three known with the undeclared row present.
  Discriminates (an undeclared token leaking into a digest or breaking partition agreement fails).
- R27 L315-322: canonical-token row counted (programs `observed_unique 1`) AND the negative (statement omitting it →
  `{known: false}`). Both directions asserted; not vacuous.
- (e) L324-328 and (f) L330-335: the same `coverage()` helper produces `known: true` in (a), so (e)/(f)'s only
  variable is the omitted family / the signer — a vacuous "everything unknown" would be caught by (a). Discriminates.
- (b) L337-349: both directions of V6 (`not.toThrow` without the rule set, `toThrow(/nativeRules 'absent'/)` with it).
- R41 load half L352-366: on-disk spec parses; the same spec minus `sharedIdSpaces` is refused by
  `parseSourceMappingSpec` AND by `loadSourceMappingSpecs(dir)` with `/shared id space/` — message at `mapping-spec.ts`
  L420-423. Discriminates.
- Structural checks L188-208 (slug walk over `src/**/*.ts`, all three JSONs loaded, both registries `.has(PLATFORM)`),
  L230-256 (S8 seam `unresolved_family:programs` vs S9/S10 `resolveFamily → 'programs'`; planner leaves
  `programs`/`client_history` unmapped) match `source-mapper-registry.ts` L101-109 / `mapping-spec.ts` L251-257,
  `facts.service.ts` L264-276 and `family-plan.ts` L94-101 as read.

**pg (real PG17):**
- (a) L291-308: `complete`, `reason_code null`, `conditions []`, `source_signed_enumeration` on all three tokens,
  native counts `{persons 2, plans 2, programs 0}`, zero evidence rows. Strong and non-vacuous.
- R41 L310-317: native counts unchanged after a second run over the same ids, and the second run `complete`. The
  harness `intent()` supersedes and creates a NEW intent (`g2-s10b-harness.ts` L42-48), so this is "replay the
  identities in a later intent" (R35 precedent) — a valid reading of R41 "replaying the intent creates no second
  native row". See C3 for a small tightening.
- (b) L319-323: `partial/unresolved_identities`. By code read: workouts rows take the evidence path when no rule set
  exists → `classifyReconstructed` bucket `unresolved`, code `evidence_only` (`reconcile.ts` L136-146) → C-ID →
  `unresolved_identities` is the first held condition (`reconcile.ts` L330-352). Consistent with doc R39(b).
- (c) L325-330: asserts `partial`, non-null reason, and `conditions` contains `unresolved_identities` without pinning
  the first code — robust to whether C-REL also holds for the soft client link. Discriminates (a `complete` fails).
- (d) L332-336: `partial/unresolved_family`: the `client_history` row forms an unmapped entry (`facts.service.ts`
  L84-86) → C-FAM first (`reconcile.ts` L332-337); it is excluded from every digest (`resolveFamily` null) so coverage
  stays known, which is why `unresolved_family` and not `coverage_basis_unknown` is expected. Discriminates.
- (e) L338-343: `partial/coverage_basis_unknown` AND the members token still shows `source_signed_enumeration` —
  proves unknown is per-family, not a blanket failure.
- (f) L345-353: `coverage_basis_unknown`, every basis `none`, every `observed_unique null`.
- R27 live L355-360: `partial`, coverage not the failing condition, 0 `WorkoutProgram`. By code read the canonical
  `programs` row is grouped into the mapped `programs` family (`facts.service.ts` L78-86) but never planned
  (`family-plan.ts` L94-100) → no ledger row → `not_reconstructed` (`reconcile.ts` L105-114) → `unresolved_identities`.
  The spec deliberately pins only `partial` (builder's stated first-run caution). See C4.

**Builder's doc tension (R39(a) vs "stages one declared family by canonical token").** The builder is right that
both cannot hold in one run without a core edit: the S8-G planner ledgers a canonical token without a `steps` entry
as unmapped (`family-plan.ts` L94-100). Splitting (a) (no programs row; programs proven as the empty set) from R27-live
(canonical-token row → truthful `partial`) is the honest reading and the only one compatible with CORE DIFF = 0.
Classification C (C5): a doc clarification for the parent, not a D2 defect.

**Builder's first-run risks** ((a) `complete` depending on S9 C-REL/C-ID classification of coach templates with no
program link and on Person verification; R41 second run `complete`; R27-live reason code): all C. Each rests on
S9-C/S10-C mechanics already proven for native-clean runs (R33, R35 in S10-C); a first-run correction, if any, would
be to an expectation, not to the design. None of the specs has been executed — the parent runs them.

## Question 4 — PG spec: lane by import only, guards intact, runs alone

- Import only: pg L76-78 `require('../../utils/g2-s10b-pg-harness')`, `g2-s10b-harness`, `g2-s10b-db` inside
  `beforeAll`; no new helper file, no harness fork (the 8 paths contain no `test/utils/**`).
- Guards ride with the import: `g2-s10b-pg-harness.ts` L42-43 throws without database/password/psql/data-directory;
  L45 `g2S10bTestTarget(raw, G2_S10B_CONFIRM)`; L47-51 `g2S10bCandidateHead(G2_S10B_CANDIDATE_HEAD, git rev-parse
  HEAD, git status --porcelain)` (clean-tree and attested-head checks at `g2-s10b-db.ts` L139-158). Consequence: the
  spec cannot run against the current uncommitted worktree; the gate worker's commit is a precondition (as the summary
  states).
- Skip path: `LIVE = typeof G2_S10B_DATABASE_URL === 'string'` (pg L31-32); `describe.skip` means `beforeAll` and the
  `require`s never run, so the default `jest.config.js` suite (roots include `<rootDir>/test`, L81-82; ignore
  patterns L121-126 do not cover `test/scout/s10/`) collects the file without a hard fail. Top-level work is
  fixture JSON reads and `jest.setTimeout` only.
- Runs alone: `reset()` (pg L95-103) deletes the chain's tables DB-wide via the migration role, so it must not run
  concurrently with `rls-g2-s10b.spec.ts`; the summary says so and the parent-run recipe uses `--runInBand
  --runTestsByPath` on the single file. Services run in-process as `service_role` with the candidate's generated
  Prisma client (pg L79-88), the same posture as the S9-C worker; the (b) injection uses the accepted instance-field
  seams with precedent in `test/utils/g2-s8g-worker.cjs` L187-192 and `g2-s9c-worker.cjs` L191.

## Findings (all C)

**C1 — Shipped public test key + committed private key.** A production run that declares platform `s10_unseen` can
be proven `complete` by anyone with the repository's fixture private key and a coach bearer token, in that coach's
own tenant only. Evidence: `induction/sources/s10_unseen.json` L14; `signer-test-key.json` L7; `nest-cli.json` L13;
`verify.ts` L224, L232; `observation.service.ts` L267-273. No real platform's trust is affected; spec-mandated by
D-S10-1 (doc L87-89). Recommendation for the owner (outside D2): decide later whether test manifests should be
excluded from production builds by a generic mechanism; not a blocker.

**C2 — PG spec bypasses the HTTP layer.** Controller methods are called directly (pg L209-216, L263-266), so
JwtAuthGuard / ValidationPipe whitelist are not on the proof path. Auth and DTO rejection are S10-B's proofs (R21,
R29); the D2 proof is chain truth. Record only.

**C3 — R41 `before` is not pinned.** pg L313-315 compares counts before/after but does not assert `before` equals
`{2, 2, 0}`; a first run that created nothing would still pass this comparison (the `complete` assertion at L316 and
test (a) make this practically non-vacuous). Optional tightening: `expect(before).toEqual({persons: 2, plans: 2,
programs: 0})`. Not required for GO.

**C4 — R27-live pins only `partial`.** pg L355-360. By code read the reason is `unresolved_identities`
(`not_reconstructed`, `reconcile.ts` L105-114). After the first green run the parent may pin it; keeping it loose is
acceptable since the discriminating claim (not `complete`; coverage not the failing condition; 0 programs) is
asserted.

**C5 — Doc tension recorded.** D-S10-5's "stages one declared family by canonical token without a `steps` entry" and
R39(a) "all declared units verified → complete" hold in different runs (a) and R27-live. Suggest the parent notes this
in the S10 doc or the D2 acceptance record so a later reader does not read (a) as covering the canonical-token row.

**C6 — In-suite slug walk covers `.ts` only.** e2e L194 checks `name.endsWith('.ts')`, matching gate check [5]
(`rg … --type ts`). `src` holds no `.js`; the gate's checks [3]/[4] cover any non-allowed path bytewise anyway.

**C7 — Lint/format not assessed here.** `as any` casts (e2e L269-274) and `require()` under an eslint-disable (pg
L67-71) mirror the S9-C worker style; prettier/eslint are the gate worker's; formatting-only changes would not alter
this review.

## Open risks / not proven

- No spec was executed by me or the builder; the live expectations are derived by reading the code paths cited above.
- The pg spec needs the attested, clean, committed head (guards at `g2-s10b-pg-harness.ts` L42-51); it cannot run on
  the uncommitted worktree.
- B-side compatibility (not re-audited, checked for consistency only): `7746a87` replaced the empty-disk premises; the
  S10-A pure fixture shares the slug `s10_unseen` and its spec families equal D2's manifest `expectedFamilies`
  (`test/fixtures/scout/s10_pure/mapping/s10_unseen.json` L11-21 vs `induction/sources/s10_unseen.json` L4), so
  `service('default')` in `facts.service.coverage.spec.ts` L163-168 composes without a V2/V3/V6 throw, and the keys
  differ (L610-616 holds). The builder's BLOCKERS 1-4 therefore appear addressed at base 6a33df9b.

## Minimum closure for A/B findings

None — there are no A/B findings.
