# S8-D1 — typed `person` handoff build (T4) — 2026-09-26

Parent session fa72efb2. Grant: `execution/fa72efb2/s8d1/S8D1_BUILD_GRANT.md`. Rules: `execution/fa72efb2/WORKER_RULES.md`.
Contract: `docs/decisions/2026-09-26-s8d-person-link.md` §5.1 steps 1–4 (read at worktrees/fa72-s8d, 7a7d18de); owner decision D-S8-2 (a) — no User minted, email never an identity key.

## 0. Result

| Item | Value |
|---|---|
| Clone | `/home/user/workspace/worktrees/fa72-s8d1` (standalone `git clone --no-hardlinks` of worktrees/fa72-s11d2; origin `no_push://disabled-fa72efb2`; never `git worktree add`) |
| Branch / base | `fa72/s8d1` on `38d0d366730331e4edf19a14cda8247435b89431` (S11-D round 2, test-only) |
| HEAD | `42c8ed30d4c846740211959e189e448d4f72cb3d` |
| Tree | `650a32e4cf40ede417533928686aa68c58395902` |
| Author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` both; no trailers (grep for co-author/AI tokens: none) |
| Commit | `feat(scout): S8-D1 typed person handoff — create-only, provenance-verified clients writer` — through lefthook (pre-commit: prod-readiness-quick ✔, banned-cast-tokens ✔, eslint ✔, prettier ✔, tsc ✔ 49.7 s; commit-msg: no-ai-tokens ✔), under the heavy flock, RC 0 |
| Push / PR | none (rule 1) |
| Migrations | none (S11 lane pins 173) — the S8-B CHECKs already admit `person` for `ImportNativeProvenance.native_kind` and ledger `target_kind` |
| Production LOC (`git diff --numstat 38d0d366 HEAD -- src`) | +197 / −32 (net +165) — inside the 200–300 estimate, far below the 1,000 stop line |
| Test LOC (`-- test`) | +936 / −104 (net +832) |
| Working tree after commit | clean (`git status --short` = 0 lines) |
| **Parent mail 19:19Z** | `test/scout/s11/journey-full.pg.spec.ts` is **NOT** in the commit. I had edited it before the mail; I saved the diff to `s8d1/journey-full_leg-b_j20_required-changes.patch` and reverted the file (`git checkout --`). §6 lists the exact changes for the parent to apply on the landed S11-D r3 bytes. |

## 1. Design (contract §5.1 → code)

`clientsFamily.persist` no longer upserts a Person. It calls `persistPerson` (new `src/scout/reconstruct/native/person-writer.ts`), the S8-C writer shape, inside the engine's existing per-row transaction, returning a typed `PersistOutcome` the S8-C typed branch already ledgers (`target_kind: 'person'` + `target_id`, or `skipped` with the exact `unresolved:*` reason).

Identity keys (unchanged from S8-C / IMPORTER-F, deliberately): provenance and ledger use the **raw staged `source_id`** under the canonical family `clients` (S9's join key, `facts.service.ts` provenanceKey); the Person external ref uses the **mapper-trimmed `sourcePersonId`** (`@@unique([coach_id, source_platform, source_person_id])`). Pinned by `person-writer.spec.ts` case 1.

`persistPerson(tx, coachId, {source_platform, source_id}, 'clients', client)` — `person-writer.ts:82-132`:

1. **Step 1 — provenance is the identity** (`:95-99`, `verifyProvenanceTarget :67-80`, `verifyPerson :60-65`). `findProvenance`; if a row exists and `outcome !== unresolved`: `native_kind !== 'person'` or `native_id === null` → `unresolved:identity_conflict` (no Person read); `person.findUnique({id})` select `{id, coach_id, state}`; missing or `state === Deleted` → `unresolved:native_target_removed`; `coach_id !== coachId` → `unresolved:identity_conflict`; else `ok` with the existing id. **No write on any of these paths** — the accepted row (including a coach-edited `display_name`) is never touched (D-S8-4, create-only).
2. **Step 2 — pre-D1 adoption** (`:100-118`). No resolved provenance: `person.findUnique` by the external ref `(coachId, client.sourcePlatform, client.sourcePersonId)`. Found → `verifyPerson`; Deleted → `native_target_removed` with **no** provenance write and no re-create; live → `recordAlreadyPresent` (new, `native-provenance.ts:98-116`: create the row when none exists, update in place when an `unresolved` row exists) and return `ok`. Second run then takes step 1 (verify path, zero writes).
3. **Step 3 — create** (`:119-131`). `person.create` (state defaults `InvitePending`, no User, no email) then `recordCreated` (or `promoteToCreated` if an `unresolved` row existed — one provenance row per identity, never two). Target before provenance, same transaction: a provenance failure rolls the Person back (spec case 11).
4. **Step 4 — S9 reads Deleted as removed** (`facts.service.ts:1003-1021`). `readPersons` selects `{id, coach_id, state, updated_at}` and maps `archived_at: state === PersonState.Deleted ? updated_at : null`, so the frozen `checkNative` (null-ness of `archived_at`) yields bucket i `removed` for a Deleted Person and `foreign_owner` for another coach's; a NULL-kind historical ledger row never reaches it (bucket f stays f).

Contention: the engine's `retryContention` (unchanged) retries once on P2002/P2034; a lost `person.create` race converges on the retry through step 1 (the winner's provenance) or step 2 (adoption). Pinned in the engine unit spec (`p2002Once`).

What did **not** change (scope guard): `FAMILY_QUALIFIERS.clients = ['roster_bridge_pending']` (`facts.service.ts:146`, S8-D2 retires it); roster reader (`scout-roster.service.ts`, already admits kind NULL or `person`, excludes Deleted); engine typed branch; S9-A `reconcile.ts`; owner-reserved boundaries; no schema/migration.

Mission invariants: new source → core diff 0 (no slug in touched src: `rg -F` for the s10_unseen and s11_second fixture `source_platform` values over `src --type ts` → no match, RC 1); unknown never silently zero (NULL-kind ledgers stay bucket f — spec'd); owner boundaries untouched.

## 2. Files (path : lines) with sha256 at HEAD

Production (5):

| File | Change | sha256 |
|---|---|---|
| `src/scout/reconstruct/native/person-writer.ts` (NEW, 132 lines) | `persistPerson` :82-132; `verifyPerson` :60-65; `verifyProvenanceTarget` :67-80; `PERSON_SELECT` :51 | `6651f876…9a2037` |
| `src/scout/reconstruct/families.ts` | :7 import; `clientsFamily.persist` :88-96 → `persistPerson(...)`; doc comments (upsert wording removed) | `304c0b95…076f31` |
| `src/scout/reconstruct/native/native-provenance.ts` | `recordAlreadyPresent` :98-116 (new; create-or-promote to `already_present`, reason null) | `6def365f…51cbd4` |
| `src/scout/reconstruct/native/native-contract.ts` | `NATIVE_KIND.person = 'person'` :17 with doc | `eb22c4e6…02e7b` |
| `src/scout/reconciliation/facts.service.ts` | :2 `import { PersonState, type Prisma }`; `readPersons` :1003-1021 (select state/updated_at; Deleted → archived_at) | `803cb385…7beeb` |

Test (9):

| File | Change | sha256 |
|---|---|---|
| `test/scout/reconstruct/native/person-writer.spec.ts` (NEW, 246 lines) | 11 no-DB cases (§3) | `c0ffed2b…213f5d` |
| `test/scout/reconstruct/native/fake-native-tx.ts` | `persons` store :37; `person.findUnique` (by id / by ext ref) + `person.create` with P2002 on duplicate ext ref, **no upsert/update** (a call throws) :154-209; `persons` in `$transaction` snapshot/restore :250-277 | `83a7a1ff…101f276` |
| `test/scout/reconstruct/scout-reconstruct.service.spec.ts` | FakePrisma: `person.upsert` → `findUnique`/`create` + `importNativeProvenance` {findUnique, create, update}; `p2002Once` materialises the winner's Person **and** provenance; `LedgerRow.target_kind?`; ledger-upsert shape assertion now expects `target_kind: 'person'` (:444-457, commented); replay display-name test **flipped** to create-only (:775-793, commented); "preserves a committed success on failed replay" now injects the failure at `importNativeProvenance.findUnique` (poison on create can no longer fail a replay — commented, :375-385); 2 new D1 cases (:795-869) | `6aebb214…7863b7` |
| `test/scout/reconstruct/conformance-alpha.e2e.spec.ts` | FakePrisma same primitive swap (poison on create); replay test also asserts one provenance row per member | `909cc204…b8fa381` |
| `test/scout/reconstruct/mapping-spec.third-source.spec.ts` | **Missed in the pre-build inventory; found by the jest gate**: third FakePrisma with `person.upsert` → same swap; replay asserts `created` provenance for ath-1/ath-2, none for the skipped blank id | `7c97adf8…8dbc4` |
| `test/scout/reconciliation/facts.service.spec.ts` | new `describe('S8-D1 typed person kind …')` :664-763, 4 cases | `eb552829…d10b4b4` |
| `test/scout/reconciliation/reconcile.spec.ts` | 2 verdict cases in `cases` (:797-845): C6 negative (partial/unresolved_identities) and positive (complete with qualifier) | `c53e00b3…2fd12901` |
| `test/scout/s10/s10-unseen.pg.spec.ts` | header :27-36 rewritten; case (h) :430-472 **flipped** to `complete` (§4) | `364bac5d…890136` |
| `test/scout/s11/journey-induction.pg.spec.ts` | header comment :17-26 only (no assertion changes; file stages no roster row) | `95cbc694…5017d` |

Not touched: `test/scout/s11/journey-full.pg.spec.ts` (parent mail) — required changes in §6.

## 3. Spec inventory

### 3.1 New / flipped specs mapped to the grant's named D1 specs

| Named D1 spec | Where (no-DB unless marked) |
|---|---|
| Edited `display_name` survives replay | `person-writer.spec.ts` :69 (writer; calls = `[provenance.findUnique, person.findUnique]`, zero writes); `scout-reconstruct.service.spec.ts` :775 (engine, flipped from IMPORTER-F "updates the display name on replay" — comment states why); `native-writers`-style conformance replay (`conformance-alpha.e2e.spec.ts` idempotent replay) |
| Deleted Person → `native_target_removed`, stays Deleted, no new Person | `person-writer.spec.ts` :83 (Deleted and vanished; store byte-identical after); :177 (pre-D1 Deleted match: not adopted, no provenance row); `scout-reconstruct.service.spec.ts` :795 (engine tally `skipped 1`, ledger reason, Person stays Deleted, size 1); `facts.service.spec.ts` :706 (S9 `removed`, bucket i, reasons histogram) |
| Other coach / mismatched provenance target owner → `identity_conflict` | `person-writer.spec.ts` :105 (foreign coach; wrong `native_kind` decided from provenance alone), :121 (two coaches at the same ext ref → two Persons, isolated); `facts.service.spec.ts` :706 (S9 `foreign_owner` → `unresolved:identity_conflict`) |
| Pre-D1 Person adopted once, then `already_present` | `person-writer.spec.ts` :134 (calls = `[…, provenance.create]` first run, `[provenance.findUnique, person.findUnique]` second, name untouched); `scout-reconstruct.service.spec.ts` :830 (engine: ledger `target_kind person`, `target_id` legacy id, provenance row count 1 across two runs); `facts.service.spec.ts` :684 (`already_present` → `present_owned`) |
| Historical NULL-kind ledgers stay bucket f | `facts.service.spec.ts` :732 (NULL kind + a later `person` provenance row → still `evidence_only`, conditions `[unresolved_identities, coverage_basis_unknown]`); engine-handoff.spec (pre-existing, unchanged) |
| Five repeated runs → one provenance row, identical outcomes | `person-writer.spec.ts` :196 (5 runs, changing names; 1 Person, 1 provenance, `created`, name v0 kept) |
| Run `complete` only when every family complete | `reconcile.spec.ts` :797 (C6: verified clients + client-owned evidence family → `partial / unresolved_identities`, qualifier carried) and :830 (positive: complete with qualifier); `facts.service.spec.ts` :684 composition (clients clean → only `coverage_basis_unknown`) |
| Also | `person-writer.spec.ts` :31 (target-before-provenance order, raw vs trimmed ids), :208 (unresolved row promoted in place, 1 row), :239 (rollback); `facts.service.spec.ts` :754 (S9 reads Person only via the bounded id lookup) |

### 3.2 Specs asserting clients → unresolved/partial (inventory + disposition)

| Spec | Before | Disposition |
|---|---|---|
| `test/scout/s10/s10-unseen.pg.spec.ts` case (h) | `partial / unresolved_identities`, clients `evidence_only ×2` | **Flipped** (grant-mandated) — §4 |
| `test/scout/s11/journey-full.pg.spec.ts` J19 leg B + header | `partial / unresolved_identities` | **Not edited** (parent mail); exact changes §6 + patch file |
| `test/scout/s11/journey-induction.pg.spec.ts` | header narrative only; stages no clients | comment-only update; no assertion touched |
| `test/scout/reconstruct/scout-reconstruct.service.spec.ts` :662 (old) | "updates the display name on replay" | **Flipped** to create-only, commented |
| `test/rls-g2-s9c.spec.ts` R09 (`partial/unresolved_identities`), `test/rls-g2-s8g.spec.ts` | clients rows are `skipped unsupported_platform` (no mapper for the harness platform) | unaffected — verdict driven by other families; **not run here** (parent-only) |
| `test/rls-g2-s8c.spec.ts` | legacy ledger row inserted directly | unaffected |
| `test/rls-g2-s9.spec.ts` | 0 clients staged | unaffected |
| `test/rls-g2-s8f.spec.ts` | reader inserts Person rows directly | unaffected |
| Historic G2 lanes (`rls-g2-ledger-expand`, `tq0`, `pg17-etq0`, `b-drain`) | schema-frozen pre-S8-B lanes | Class C — already incompatible with post-S8-B engine writes; not D1's to re-audit |
| `test/scout/reconciliation/reconcile.spec.ts` R01(a) | clients `person` kind → complete | pre-existing S9-A truth D1 now realises live |

`rg -n "person\.upsert" src test --type ts` → 0 hits after the sweep (the only remaining "upsert" mention is the explanatory comment in the third-source fake).

## 4. Honesty sweep — what flipped and why

`s10-unseen.pg.spec.ts` case (h) (`:430-472`): terminal `partial`→`complete`, `reason_code`→null, `conditions`→`[]`, clients `{staged_unique 2, native_present_verified 2, unresolved 0, reasons [], qualifiers ['roster_bridge_pending'], completeness_basis 'source_signed_enumeration', observed_unique 2}`, workouts unchanged, `nativeCounts {persons 2, plans 2, programs 0}`, `evidenceRows 0`; **added**: `ImportNativeProvenance` count `entity_type='clients' AND native_kind='person' AND outcome='created'` = 2; `Person … state='InvitePending'` = 2 (no User minted; Person has no user_id column — D-S8-2 (a) is asserted through state). The in-test comment states the flip reason (the writer changed, the Persons were always written; S9 can now verify them). Cases (a)–(g) untouched. `roster_bridge_pending` behaviour untouched everywhere (asserted still present).

## 5. PG proof lanes the parent must run (parent-only; nothing here touched PostgreSQL)

| Lane | Spec | Expected |
|---|---|---|
| S10-B (`G2_S10B_DATABASE_URL`) | `test/scout/s10/s10-unseen.pg.spec.ts` | 8 cases pass: (a)–(g) unchanged; **(h)** `complete`, `reason_code null`, conditions `[]`, clients 2/2 verified, provenance `person/created` = 2, Persons InvitePending = 2, plans 2, programs 0, evidence rows 0 |
| S11 (`G2_S11_DATABASE_URL`) | `test/scout/s11/journey-full.pg.spec.ts` **after the parent applies §6 on S11-D r3** | J19 leg A unchanged (`complete`, roster empty); leg B `complete` / null / `[]`, clients cell `staged_unique = native_present_verified = observed_unique = roster size`, `unresolved 0`, qualifier `['roster_bridge_pending']`, `roster.result.roster_bridge_pending === true`, every person `InvitePending`, readiness `terminal` with no `partial`/reason leak; J20: pins+`S11_RANGE_END` resolve and are ancestors of HEAD; range walk `3db615c0^..38d0d366` finds no unpinned src commit; per-commit slug check 0 hits over 7 pinned commits; core-diff gate PASS at GATE_HEAD |
| S11 | `test/scout/s11/journey-induction.pg.spec.ts` | unchanged (comment-only edit) — J09–J11 identical outcomes |
| G2 rls lanes | `rls-g2-s8c/s8f/s8g/s9/s9c` | unaffected (§3.2); if the parent reruns them, expected identical counts — clients rows there never reach `persistPerson` with a registered mapper |

Note for the S11 lane: with D1's src commit on top of the S11 range, J20's **unmodified** "no src-touching commit in 3db615c0^..HEAD" walk would fail (42c8ed30 touches src and is not in SLICE_COMMITS) — that is exactly why the §6 re-scope is required before the lane runs on a D1-bearing head.

## 6. Required changes to `test/scout/s11/journey-full.pg.spec.ts` (for the parent to apply on landed S11-D r3 bytes)

Full unified diff (192 lines, against 38d0d366 bytes): `execution/fa72efb2/s8d1/journey-full_leg-b_j20_required-changes.patch`. The exact assertion changes:

**Leg B (J19 roster-bearing) — flip the terminal, keep the qualifier and roster read:**
1. `expect(run.terminal_status).toBe('partial')` → `.toBe('complete')`; `expect(run.reason_code).toBe('unresolved_identities')` → `.toBeNull()`; delete `expect(run.terminal_status).not.toBe('complete')`.
2. `expect(basis.report.conditions).toEqual(['unresolved_identities'])` → `.toEqual([])`.
3. `expect(clientsCell).toMatchObject({...})` → add `staged_unique: rosterIds.size, native_present_verified: rosterIds.size, unresolved: 0, reasons: []`; keep `completeness_basis: 'source_signed_enumeration'`, `observed_unique: rosterIds.size`, `qualifiers: ['roster_bridge_pending']`.
4. Keep unchanged: readiness `{run:'terminal', source_declared:true, declared_platforms:2}` and both `not.toContain('partial'|'unresolved_identities')` (still meaningful: nothing about the verdict may leak); `roster.result.roster_bridge_pending === true`; `accounting.staged === rosterIds.size`; ids equal the staged roster; every `person.state === 'InvitePending'`; cross-host roster equality.
5. Rename the `it(...)` title from "settles `partial/unresolved_identities` … NEVER `complete` at this head" to "settles `complete` (clients verified through the typed person handoff, qualifier roster_bridge_pending still carried)"; add a comment at the top of the case stating the S8-D1 flip reason (contract §5.1); update the file header paragraphs "MANDATORY HONESTY" and "Leg B" to past tense + D1 outcome (wording in the patch).

**J20 — re-scope the full-range walk (do not weaken slug/gate checks):**
6. Add `const S11_RANGE_END = '38d0d366730331e4edf19a14cda8247435b89431';` (S11-D round 2 — **if S11-D r3 lands as a new commit, the parent must pin r3's SHA instead**, since it becomes the last S11 slice commit) with a doc comment.
7. Pins case: iterate `[...SLICE_COMMITS, S11_RANGE_END]` for resolve + `merge-base --is-ancestor HEAD`.
8. Range-walk case: `git rev-list ${base}^..${head}` → `git rev-list ${base}^..${S11_RANGE_END}`; title "…in 3db615c0^..S11_RANGE_END…"; comment explaining that later slices (S8-D1) land src commits after the S11 range with their own evidence, so an S11 check must end at the S11 range end. Leave the per-commit `rg -F -l` slug check and the `s10-core-diff-gate.sh` check byte-identical.

## 7. Commands run (all RC recorded)

Light (no lock): `prettier --write/--check` (runtime prettier 3.9.9 via `npm_config_prefix`/PATH) RC 0/0 twice; `rg -F -l <d2 slug>|<a2 slug> src --type ts` RC 1 (no match) each; `git add -A`, `git status`, `git diff --numstat`, `sha256sum`.

Heavy — every one as `flock -w 3600 /home/user/workspace/execution/test-validation.lock bash -c '…'` (inode 686480 verified with `stat`; never probed/recreated), only after `[ -e …/PROOF_SLOT_FREE ]` succeeded, `NODE_OPTIONS=--max-old-space-size=3072`, `jest --runInBand`:

| # | Command | RC |
|---|---|---|
| 1 | `npx eslint --no-warn-ignored --max-warnings 0 <13 touched files>` | 0 |
| 2 | `npx tsc --noEmit -p tsconfig.json` | 2 — TS2339 ×2 (closure narrowing in two fakes) → fixed (`const wantedId`) |
| 3 | `npx tsc --noEmit -p tsconfig.json` | 0 |
| 4 | `npx jest --runInBand test/scout/reconstruct test/scout/reconciliation src/scout test/scout/s10/s10-unseen.pg.spec.ts test/scout/s11/journey-induction.pg.spec.ts` | 1 — 3 failures: (i) `person-writer.spec` implicit-any array under ts-jest → typed `PersistOutcome[]`; (ii) engine Deleted case used a second intent but the fake's `groupBy` tallies the whole ledger → modelled the fresh pass by `ledger.clear()` (commented); (iii) **`mapping-spec.third-source.spec.ts` FakePrisma still had `person.upsert`** (inventory miss) → swapped to the writer primitives |
| 5 | same jest set | 1 — 1 failure: "preserves a committed success on failed replay": poison on `person.create` can no longer fail a replay (create-only) → failure injected at `importNativeProvenance.findUnique` (commented) |
| 6 | `npx jest --runInBand test/scout/reconstruct/scout-reconstruct.service.spec.ts` | 0 (56/56) |
| 7 | `npx eslint … <14 files>; npx tsc --noEmit -p tsconfig.json` (final bytes) | 0 / 0 |
| 8 | `npx jest --runInBand test/scout/reconstruct test/scout/reconciliation src/scout test/scout/roster test/scout/s10/s10-unseen.pg.spec.ts test/scout/s11/journey-induction.pg.spec.ts` (final bytes) | **0 — 30 suites passed, 2 skipped (the two pg specs self-skip without their env and load cleanly), 699 tests passed, 13 skipped, 0 failed** |
| 9 | `git -c user.name='Bradley Gleave' -c user.email='bradley@bradleytgpcoaching.com' commit -F -` through lefthook | 0 |

Slot: `PROOF_SLOT_FREE` was absent when the first heavy gate was due (parent lane running); waited by polling `[ -e ]` every 30 s (no lock probe), present at 19:19:46Z; all heavy commands ran after that. No real-PG lane, `*.pg.spec.ts` live run, or `rls-g2-*` was run. No `npm install`/`prisma generate`; node_modules untouched. Evidence repo not git-committed.

## 8. Risks / findings (A/B/C)

- **B — journey-full.pg.spec.ts changes not in this commit (by parent instruction).** CLASS: proof-lane coherence. CONCRETE HARM: on a head carrying 42c8ed30 the unmodified J20 range walk fails (D1 src commit unpinned) and leg B asserts the pre-D1 `partial`. EXACT DECISION BLOCKED: S11 lane cannot be declared green on a D1-bearing head until §6 is applied. MINIMUM CLOSURE: parent applies §6 (8 numbered edits / the patch) on S11-D r3, pinning `S11_RANGE_END` to r3's SHA if r3 is a new commit. EXECUTION UNLOCKED: S11 lane run with the §5 expectations.
- **C — inventory miss, closed.** `mapping-spec.third-source.spec.ts` was not in my pre-build fake inventory; the jest gate caught it (RC 1 → fixed, RC 0). Recorded so the parent's review does not rely on my inventory alone; `rg person\.upsert` over src+test is now 0.
- **C — S9 `readPersons` relies on `updated_at`.** `archived_at` for a Deleted Person is `updated_at`, which is `NOT NULL @updatedAt` in the schema and `Date` in the Prisma type; `checkNative` reads only null-ness. No harm at the schema; noted because a fake with `updated_at` unset would classify a Deleted row as live (the facts spec sets it).
- **C — provenance namespace vs mapper platform.** `persistPerson` keys provenance on `client.sourcePlatform` (mapper spec) and the Person on the same value; the staged row's `source_platform` selected that mapper by exact key, so they are equal for every registered platform. Pinned indirectly by the third-source and conformance e2e specs (provenance rows carry the fixture platform).
- **C — real-PG contention path unproven here.** The P2002 lost-race → retry → converge path is pinned on the in-memory fake (`p2002Once` materialises Person + provenance). On PostgreSQL the interactive transaction aborts and Prisma surfaces P2002; the engine's retry opens a new transaction. Same mechanism S8-C relies on; a live lane case would be S8-D2's or the parent's call, not added in D1 (no DB here).
- **C — Deleted Person under an already-`reconstructed` ledger row.** Engine success precedence keeps the row `reconstructed` on replay (unchanged engine); S9 then reports it `removed` (bucket i) from the Person state itself — the honest read is S9's, pinned in `facts.service.spec.ts`. A fresh pass over the identity ledgers `skipped unresolved:native_target_removed` (engine spec :795).
- **C — historic G2 lanes** (`rls-g2-ledger-expand`, `tq0`, `pg17-etq0`, `b-drain`) are schema-frozen pre-S8-B lanes already incompatible with post-S8-B engine writes; not re-audited (rule 5).
- **C — `roster_bridge_pending`** stays exactly as before in code and in every assertion (facts.service.ts:146 untouched; asserted present in s10 (h), reconcile C6 cases, and the §6 leg-B text). Retiring it is S8-D2.

## Round 2 (parent mail 2 + the 19:47Z adjustment; 2026-09-26 19:20–19:55Z)

Instruction as executed: fetch S11-D round 3 `aed23289`, branch `fa72/s8d1-r2` at it, cherry-pick `42c8ed30`, run the hook commands by hand under flock, deliver the journey-full change **as a patch file only** (the 19:47Z mail: S11-D proof v2 failed again on J19, r4 pending — no journey-full commit), and give the complete PG proof list. **No journey-full commit was made**: the commit command was staged but exited on the `PROOF_SLOT_FREE` pre-check (RC 9, no git action) before the adjusted mail arrived; the working tree was then reset to HEAD and the adapted diff saved.

### R2.1 Heads / trees

| ref | commit | tree | note |
|---|---|---|---|
| S11-D r2 (round-1 base) | `38d0d366730331e4edf19a14cda8247435b89431` | `075c1513d54367abb796c35faac0bf2872acbace` | |
| S11-D r3 (new base) | `aed23289024898cceca7385d3778cd7373b7424d` | `6787b25531ab7614c9de70e745381a996d66b119` | fetched from `worktrees/fa72-s11d2`; descends from 38d0d366 (`merge-base --is-ancestor` true); `git diff --stat 38d0d366 aed23289` = only `test/scout/s11/journey-full.pg.spec.ts` (+17/−5: `report.coverage`→`report.families`, leg-A `redrive.pushes` 1→0) |
| **D1 candidate r2 = HEAD of `fa72/s8d1-r2`** | **`03b574e4cd2bbea4eb568003f51f663d1c32e6ca`** | **`d8a5437a2873fd95df0a1b46cd23d41f2d6296ee`** | cherry-pick of 42c8ed30 onto aed23289; author AND committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`; no trailers; message unchanged (`feat(scout): S8-D1 typed person handoff — create-only, provenance-verified clients writer`); clean pick, no conflicts |

`git diff --stat aed23289 03b574e4` = 14 files, +1133/−136 (identical to round 1's 14-file set); `git diff 42c8ed30 03b574e4` = exactly the r3 journey-full change (1 file, +17/−5) — the D1 bytes are byte-identical between 42c8ed30 and 03b574e4. Working tree clean; branch `fa72/s8d1-r2`; nothing pushed (origin remains `no_push://disabled-fa72efb2`).

Blobs at 03b574e4 (path | git blob | sha256):

| path | blob | sha256 |
|---|---|---|
| `src/scout/reconciliation/facts.service.ts` | `0f95ffe6d0c02c0c10399d6ffe1cb419c89bbca3` | `803cb385e2406be490d6ac93a6ec874145d8153419c3a10db64fea4a91a7beeb` |
| `src/scout/reconstruct/families.ts` | `1f2593619a3cc94ef5f96544371d49d83761874f` | `304c0b95bf07b48d41fbe31f32efacfd394bd05b23dee7fc390df8b865076f31` |
| `src/scout/reconstruct/native/native-contract.ts` | `1d99ef86a98c6447b2f34fcce67efd09da9720bc` | `eb22c4e6fce34a86f3e25cc3c6c69c970cbdb7b3cd9ae61eb428651ebff02e7b` |
| `src/scout/reconstruct/native/native-provenance.ts` | `b95f0224203ec1b0af2934e4eb4fbcd87d7d9c70` | `6def365fd937a10a9e7805cb8a25ed5d52bddef5d76dabb43cb485715251cbd4` |
| `src/scout/reconstruct/native/person-writer.ts` | `509f9cd4ffdf02d968a465058f6c3ecb66707b74` | `6651f87637b6141ea749e7290edb8b215aa683df1ab81b24366f3216729a2037` |
| `test/scout/reconciliation/facts.service.spec.ts` | `eb3c3a4ecdcf88a425240f5f2da821579ecbb467` | `eb5528293c6e0343aea67efa912ffdcd4136b961bfd7b3241b029cc4ad10b4b4` |
| `test/scout/reconciliation/reconcile.spec.ts` | `3b069621f41e8cfbbf6355aea01def1bd7426b53` | `c53e00b3534de0bbb3a12e9f0013c4a02954407c94adea27c789ba502fd12901` |
| `test/scout/reconstruct/conformance-alpha.e2e.spec.ts` | `0bc12d92e04060829a54370f3e1f029ee0b0e6b0` | `909cc204f91ab77cb57970c9f86d444a8d03b2af71812205f5db7b98f8bfa381` |
| `test/scout/reconstruct/mapping-spec.third-source.spec.ts` | `3305c7f0cf1202fee4a7cd345fdafd4b41686d85` | `7c97adf803da43ce9e474c1a93b75e68c67a67f008f50878b17bf0a05de8bdc4` |
| `test/scout/reconstruct/native/fake-native-tx.ts` | `1c7103b67dc4b74a86f0e5f00e081408b0667d2a` | `83a7a1ff91a982390a95ea4ada2d1ed06e1d53abebbe3022dccaa65de101f276` |
| `test/scout/reconstruct/native/person-writer.spec.ts` | `1bebd75e601b6ae6346ce51d3e3da20c66c0bfcd` | `c0ffed2b2be76bca3524d3051dfe79dee2ec955237ef1251507c53cfcc213f5d` |
| `test/scout/reconstruct/scout-reconstruct.service.spec.ts` | `93121b2319e7309497ef23f079c67ddad53851ab` | `6aebb2148806d2bc1520216f63d5221f9b383ce1d6ef994f7b782771863bb5b7` |
| `test/scout/s10/s10-unseen.pg.spec.ts` | `f651b16dc6106eca95e8aebb15b7beb299df3e29` | `364bac5d6ac13ab6b72f265855ce6415454dc9fcfd3e1c76a5df32346e890136` |
| `test/scout/s11/journey-induction.pg.spec.ts` | `235b72a18a2e08af2036e0a0e603e1c189d49873` | `95cbc6943a5db21bbdda3b1b1907a43025c88d70f656644a2cec704b5465017d` |

`test/scout/s11/journey-full.pg.spec.ts` at 03b574e4 is the untouched r3 blob `9ca2ebb6` (sha256 `110a02df004301f553fdbce44a77872d29f3484d6aa25fa7bb6bc914f79abffe`).

### R2.2 Hook commands run by hand on the cherry-pick (cherry-pick runs no pre-commit)

Slot check `[ -e …/PROOF_SLOT_FREE ]` passed; one `flock -w 3600 /home/user/workspace/execution/test-validation.lock bash -c '…'` with `NODE_OPTIONS=--max-old-space-size=3072`, files = `git diff --name-only HEAD^ HEAD` (14):

| hook command (lefthook.yml) | as run | RC |
|---|---|---|
| `node scripts/check-r75.js --mode=staged` | `node scripts/check-r75.js --mode=range --base=HEAD^ --head=HEAD` (index empty after the pick; range mode measures the same 14 committed files against aed23289; policy read at HEAD) → `OK — no positive token change` | 0 |
| `npx tsc --noEmit` | same | 0 |
| `npx eslint --no-warn-ignored --max-warnings 0 {staged_files}` | same, 14 files | 0 |
| `npx prettier --check {staged_files}` | same, 14 files → `All matched files use Prettier code style!` | 0 |
| prod-readiness-quick | `scripts/prod-readiness-precheck.sh` does not exist in this tree (the hook guards with `[ -x … ]` and is a no-op) | 127 from my direct invocation = file absent; hook semantics = skip |
| commit-msg no-ai-tokens | the lefthook regex applied to `git log -1 --format=%B` | grep RC 1 = no banned token |

### R2.3 journey-full: adapted patch, NOT committed

`journey-full_leg-b_j20_required-changes.r3.patch` (this directory; 202 lines; sha256 `96a8065df0f79e1477815ca141a75c98481bd5920f07b126f832e633843c50a5`), a `git diff` against the r3 blob `9ca2ebb6` (`git apply --check` of the round-1 patch against r3 = RC 0; then two edits below; prettier-formatted). It keeps both r3 changes (`report.families`, leg-A `redrive.pushes` 0) and adds:

1. **Leg B flip to what D1 produces** (comment cites the code): terminal `complete`, `reason_code null`, `conditions []`; clients cell `{staged_unique: rosterIds.size, native_present_verified: rosterIds.size, unresolved: 0, reasons: [], qualifiers: ['roster_bridge_pending'], …}`; `roster_bridge_pending` still asserted true, Persons still `InvitePending`, readiness `not.toContain` checks kept; `it` title renamed. Cited: `src/scout/reconstruct/families.ts:88-96` → `src/scout/reconstruct/native/person-writer.ts:82-132` (create + `person`/`created` provenance in one tx, :119-131); `src/scout/scout-reconstruct.service.ts:506` (typed branch ledgers `target_kind`); `src/scout/reconciliation/facts.service.ts:1003-1021` (readPersons, Deleted → removed); `src/scout/reconciliation/reconcile.ts:159-160` (bucket j `native_present_verified`).
2. **J20 re-scope**: `const S11_RANGE_END = 'aed23289024898cceca7385d3778cd7373b7424d'` (literal pin with comment naming the r3 commit as the last S11 slice commit); pins case iterates `[...SLICE_COMMITS, S11_RANGE_END]`; range walk `${base}^..${S11_RANGE_END}` instead of `..HEAD`; header comment. Slug check and core-diff gate not weakened.

Gates on the adapted file while it was in the working tree (all under flock, slot present): prettier `--check` RC 0; eslint RC 0; `tsc --noEmit` RC 0; `jest --runInBand test/scout/s11 test/scout/s10 test/scout/reconstruct test/scout/reconciliation src/scout` → 28 suites passed, 6 skipped (pg specs load-and-skip), 663 passed / 41 skipped, RC 0. Then `git reset HEAD -- <file>; git checkout -- <file>`; tree clean at 03b574e4.

**For r4**: when S11-D r4 lands, `S11_RANGE_END` must become the r4 SHA (one literal + its comment), and the hunk offsets may shift; the leg-B hunk itself depends only on the `byFamily`/`coverage` helpers r3 introduced.

### R2.4 COMPLETE PG proof list for D1 as a src change

Method: `rg` over every `test/**/*.pg.spec.ts`, `test/rls-g2-*.spec.ts` and their `test/utils/g2-*` harnesses/workers for paths reaching `clientsFamily.persist` (a staged `clients` row on a platform whose mapping spec is registered → `families.ts:88` → `persistPerson`), `ReconciliationFactsService.readPersons` (every settle tail: `facts.service.ts:1003`), and `reconcile` (every settle tail, pure). Counts = `grep -cE '^\s*it\('` at 03b574e4 (matches the binding scripts' pins).

**S11 lane (port per `s11d/binding/v2/s11-pg-proof.sh`; every stage) — the lane that exercises D1 live.** The S11 harness fixture spec registers `people → clients` (`test/utils/g2-s11-harness.ts:66-70`), and the worker builds the family registry from `src/scout/reconstruct/families` (`g2-s11-worker.cjs:96`), so every S11 transfer that stages a `clients` row now runs `persistPerson` on real PG.

| stage / spec | it() | reaches | expected after D1 |
|---|---|---|---|
| `test/rls-g2-s11.spec.ts` | 6 | none of the three (schema/identity/legacy-row reads; no gated transfer) | 6 passed, unchanged |
| `test/scout/s11/journey-core.pg.spec.ts` | 8 | **persist** (transfer stages `clients` p-1/p-2 :113-119) + readPersons + reconcile on every `complete`; `targetSnapshot` (persons/provenance/ledger) compared A-vs-A and B-isolated (:541-606) | 8 passed; terminal stays `partial` (client_history evidence + null coverage), asserted only as not-null; provenance now also holds `clients/person/created` rows — equality/isolation assertions hold |
| `test/scout/s11/readiness.pg.spec.ts` | 6 | none (no transfer) | 6 passed, unchanged |
| `test/scout/s11/settle-redrive.pg.spec.ts` | 8 | **persist** + readPersons + reconcile; J12 kills after the first committed per-row tx (a `clients` row → Person + provenance + ledger in one tx), redrive replays through `verifyProvenanceTarget` → no second Person/provenance; shape compared to the uninterrupted reference (persons count, provenance rows, ledger) | 8 passed; verdict equality holds under D1 (unit-pinned by `person-writer.spec.ts` :31/:208 and `scout-reconstruct.service.spec.ts` :775) |
| `test/scout/s11/journey-induction.pg.spec.ts` | 4 | readPersons + reconcile only (native-clean shape, zero `clients` rows; D1 touched its header comment) | 4 passed, unchanged |
| `test/scout/s11/journey-full.pg.spec.ts` | 6 | **persist** (leg B roster rows) + readPersons + reconcile; J20 walks the range | **on the r3/r4 bytes alone: leg B FAILS (asserts `partial/unresolved_identities`) and J20's `..HEAD` walk fails on D1's src commit** — with the r3 patch (or its r4 re-target) applied: 6 passed |
| `test/utils/g2-s11-db-guard.spec.ts` (no-DB) | 11 it + it.each (61+20+3) = 95 | none | 95 passed, unchanged |

S11 lane total: 6+8+6+8+4+6+95 = **133 passed** with the journey-full patch applied on the landed S11-D bytes; 131 + 2 failures without it.

**S10-B lane (port 55649).** Two bindings share the lane:

| binding / spec | it() | reaches | expected after D1 |
|---|---|---|---|
| `s10d2/binding/v2` (`d2-pg-proof.sh`, `jest --runTestsByPath test/scout/s10/s10-unseen.pg.spec.ts`) | 9 | **persist** (case (h) roster rows on the registered `s10_unseen` spec) + readPersons + reconcile | **9 passed** with D1's flipped case (h) (`complete`, provenance count 2, Person InvitePending 2); the pinned blob in that script (`EXPECT_D2_BLOB_PG=352cb340`) must be re-pinned to `f651b16d…` for this run |
| `s11b/binding/s10b-lane-v2` (`s10b-lane-pg-proof.sh`, `jest -c jest.rls.config.js test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts`) | 24 + 8 = 32 | `clients` rows staged on `synthetic-src-a` with **no registered mapper** → `skipped unsupported_platform` (`rls-g2-s10c.spec.ts:289` `rejected: 2`); readPersons/reconcile reached with empty person set | **32 passed**, unchanged |

**S9 / S8 lanes (`jest.rls.config.js`; no fa72efb2 binding script exists for them — run only if the parent wants belt-and-braces evidence):**

| spec | it() | clients path | expected |
|---|---|---|---|
| `test/rls-g2-s9c.spec.ts` | 10 | `unsupported_platform:${PLATFORM}` (:501) → writer never reached | 10 passed, unchanged |
| `test/rls-g2-s8g.spec.ts` | 19 | same (:15, :275) | 19 passed, unchanged |
| `test/rls-g2-s9.spec.ts` | 10 | 0 `clients` staged (`['clients', 0, 0, 'not_applicable']` :329) | 10 passed, unchanged |
| `test/rls-g2-s8c.spec.ts` | 13 | legacy ledger rows inserted by SQL; no persist | 13 passed, unchanged |
| `test/rls-g2-s8f.spec.ts` | 11 | Person rows inserted by SQL (:260); roster reader only | 11 passed, unchanged |
| `test/rls-g2-s8b.spec.ts` | 14 | S8-B ledger shape; no persist | 14 passed, unchanged |

Not reaching any of the three paths (listed for completeness, no run needed): `rls-g2-s7l` (24), `rls-g2-c-contract` (20 + each), `rls-g2-nq1` (6 + each), `rls-g2-r-ready` (17), `rls-g2-tq0` (7 + each), `rls-g2-pg17-etq0` (22 + each), `rls-g2-b-drain` (19), `rls-g2-ledger-expand` (5 + each) — their harness imports of `scout-reconstruct.service` are for engine/ledger tests on families other than `clients` or on platforms with no mapper.

**Minimum PG proof for D1 GO**: S10-B lane `s10-unseen.pg.spec.ts` (9) + S11 lane all stages (133 with the journey-full patch). `rls-g2-s10b/s10c` (32) recommended on the same lane since D1 changes `families.ts`, which that lane loads.

### R2.5 Commands + RC (Round 2)

| # | command | RC |
|---|---|---|
| 1 | `git fetch /home/user/workspace/worktrees/fa72-s11d2 aed23289…` ; `git merge-base --is-ancestor 38d0d366 aed23289` ; `git checkout -b fa72/s8d1-r2 aed23289` | 0 / 0 / 0 |
| 2 | `git -c user.name='Bradley Gleave' -c user.email='bradley@bradleytgpcoaching.com' cherry-pick 42c8ed30` → 03b574e4 | 0 |
| 3 | flock: check-r75 range / tsc / eslint 14 files / prettier 14 files / precheck.sh / no-ai grep | 0 / 0 / 0 / 0 / 127 (absent) / 1 (clean) |
| 4 | `git apply --check <round-1 patch>` ; `git apply` ; python edits (S11_RANGE_END → aed23289 + comments; leg-B code citations) ; `prettier --write/--check` | 0 / 0 / 0 / 0 |
| 5 | flock: eslint journey-full / tsc / jest (28 suites, 663 passed, 41 skipped) | 0 / 0 / 0 |
| 6 | commit attempt: `[ -e PROOF_SLOT_FREE ] \|\| exit 9` → **slot absent, no git action** | 9 |
| 7 | poll `[ -e PROOF_SLOT_FREE ]` every 30 s → present 19:47:10Z; adjusted mail received; `git diff --cached > …r3.patch` ; `git reset HEAD -- <file>` ; `git checkout -- <file>` | 0 |

### R2.6 Risks / findings (Round 2)

- **B1 (open, parent-owned by instruction)** — CLASS B. HARM: on the landed S11-D bytes, `journey-full.pg.spec.ts` leg B and the J20 `..HEAD` walk fail once D1's src commit is on the branch. DECISION BLOCKED: S11 lane GO for the D1 candidate. MINIMUM CLOSURE: apply `journey-full_leg-b_j20_required-changes.r3.patch` (re-target `S11_RANGE_END` to the r4 SHA if r4 changes the file) in one lefthook commit on the landed bytes. UNLOCKED: S11 lane 133/133.
- **C6** — `s10d2/binding/v2/d2-pg-proof.sh` pins `EXPECT_D2_BLOB_PG=352cb340` and `EXPECT_HEAD=275e458c`; a D1 run needs those re-pinned (`f651b16d…`, candidate head) — a binding edit, not a spec edit.
- **C7** — journey-core / settle-redrive assert shape equality, not the `clients` cell; D1's live effect there is provenance rows appearing and equality still holding. Only `s10-unseen (h)` and `journey-full leg B` assert the `complete` verdict live.
- No PG run, no push, no `git worktree add`, no npm install in Round 2. Evidence repo not committed.
