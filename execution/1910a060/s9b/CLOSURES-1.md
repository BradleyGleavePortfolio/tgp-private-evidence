# S9-B CLOSURES-1 (parent disposition 15:16 PT; source-only edits, no lock/installs/tests/gates/commit)

Applied in `/home/user/workspace/worktrees/1910a060-s9b` (branch `exec1910/s9b`, HEAD still `1c5fbb04`). Three
files changed; the other eight owned files are byte-identical to SOURCE_READY §2. Pre-closure bytes were
reconstructed and hash-verified against the published shas before diffing (`pre-*` copies beside this file).

| File | pre sha256 (reviewed bytes) | post sha256 (CLOSURES-1) |
| --- | --- | --- |
| `src/scout/reconciliation/facts.service.ts` | `828c9d4c23ca1ff512ca26002d9888d4158eae5e2507cbfa859dabf95ef7f42b` | `e2f40a794b6cf9aa75e37e7d30ca66dd209280e70a5aa963c58eda085de58357` |
| `test/scout/reconciliation/facts.service.spec.ts` | `e72fb4b570d862cc33fce55934b2338db0f33a3ccf7e55d47666d21b0a951091` | `9dcfbd966757cc125262e8bdc353b97dc1baf2b5a6ff211a84bc90b382014f3c` |
| `docs/decisions/2026-09-25-s9-reconciliation.md` (Addendum A only; delta vs landed now +99/-0) | `2b60cdaa4379259c6c743108222bf0e5ec954ff62831b439082b907d0a93e3b1` | `be591e977c43fdce484292b79a1c247f2504b6056a340e5026f21a6599aa6515` |

Unchanged: `reconciliation.module.ts` `f2c1e447…`, `g2-s9-db.ts` `a1611c51…`, `g2-s9-pg-harness.ts` `8274a85b…`,
`g2-s9-harness.ts` `16a5aeac…`, `g2-s9-worker.cjs` `5e52b918…`, `g2-s9-bootstrap.sh` `8452feba…`,
`g2-s9-db-guard.spec.ts` `307d8fa4…`, `rls-g2-s9.spec.ts` `b854fd59…`. Landed doc text above Addendum A: 0 deletions.

## Closure map

1. **Fixture (A-B1 / B-B3)** — `verifiedPair` stages `programs`/`workouts` (was `blocks`/`routines`) so the staged
   rows join the S8-C-shaped ledger rows on the raw D-S9-2 wide identity; the "attaches failed / skipped /
   reconstructed" case and the "unresolved top-level provenance" case stage `workouts`. NEW negative case
   `does NOT join a step-token staged row to a canonical-token ledger row for the same id`: `routines/W1` staged,
   `workouts/W1` ledgered+provenanced → identity `ledger: null`, `ledger_without_staged` 1 (family and run). No
   assertion weakened; every prior `expect` is intact.
2. **R75 (A-B2 / B-B1)** — `facts.service.ts` default branch: `const passthrough: { status: string } = { status:
   led.status }; return passthrough as LedgerRowFacts;` (single typed assertion; unknown status still reaches
   S9-A's bucket k unrelabelled). Spec `client()`: `return db as FactsDb;` (`Row = Record<string, any>`, one
   assertion). Policy scan of all 10 owned files with the `.github/r75-policy.json` patterns (`{{gap}}` expanded,
   run as a standalone regex pass — not the repo gate): 0 hits across all 12 tokens. The worker's
   `.catch((e) => { console.error(e); process.exit(1); })` is a non-empty handler, not a swallowed-error form.
3. **eslint (B-B2)** — unused import `childSourceIdPrefix` removed (its doc-comment mention at L72 stays as prose).
   Import/declaration usage scan over the 9 `.ts`/`.cjs` owned files: no other single-reference symbol.
4. **Addendum A wording** — C-6 now states the accepted S9-A parser recognises codes by catalogue prefix and does not
   validate qualifier domains; domain validation before a DTO is recorded as an S9-C obligation. C-9 now states the
   service opens no transaction and issues only reads; the caller supplies one `Prisma.TransactionClient` and is
   responsible for `REPEATABLE READ`; the settle path's transaction is S8-G's (which also writes the terminal) — not
   called read-only; the status path's is opened by S9-C. Append-only preserved (`git diff --numstat` = 99 0).
   Evidence copy `S9_0_ADDENDUM_DRAFT.md` updated identically (`6cb90d92…`).
5. **Path deviation** — `test/rls-g2-s9.spec.ts` recorded as a parent-GRANTED added test-only path (SOURCE_READY §8;
   it is already named in both commit messages).
6. **Binding** — v1 historical/not to be used; v2 (`binding/v2/`) is the one; S9-A pre-format copies are not in
   commit ownership (gate re-bases onto M2; driver asserts they are gone and the accepted blobs are tracked).

## Gate artefacts updated

- `gate/PINS.env` `9e6d0bc7…`: `SHA_FACTS_SERVICE`, `SHA_FACTS_SPEC`, `SHA_DOC_ADDENDUM` re-pinned; new
  `DOC_ADDED_LINES=99`. `BASE=__FILL_M2__` still the only unfilled value.
- `gate/s9b-gate-1910.sh` `d0f27439…`: doc-delta precondition reads `DOC_ADDED_LINES` (was literal 96). `bash -n` clean.
- `gate/README.md` `67192979…`: delta note.

## Exact diffs

### facts.service.ts

```diff
--- a/src/scout/reconciliation/facts.service.ts
+++ b/src/scout/reconciliation/facts.service.ts
@@ -5,7 +5,6 @@
   CHILD_ENTITY_TYPE,
   NATIVE_KIND,
   PROVENANCE_OUTCOME,
-  childSourceIdPrefix,
 } from '../reconstruct/native/native-contract';
 import { buildNativeFamilies } from '../reconstruct/native/native-families';
 import {
@@ -537,9 +536,12 @@
           target_kind: isLedgerTargetKind(led.target_kind) ? led.target_kind : null,
           provenance: prov === null ? null : this.provenanceFacts(coachId, led, prov, children, native),
         };
-      default:
+      default: {
         // Out-of-type status: surfaced as-is so S9-A's catch-all (k) sees it, never re-labelled.
-        return { status: led.status } as unknown as LedgerRowFacts;
+        // `LedgerRowFacts` is a closed union; the single typed assertion widens `status` only.
+        const passthrough: { status: string } = { status: led.status };
+        return passthrough as LedgerRowFacts;
+      }
     }
   }
 
```

### facts.service.spec.ts

```diff
--- a/test/scout/reconciliation/facts.service.spec.ts
+++ b/test/scout/reconciliation/facts.service.spec.ts
@@ -117,7 +117,8 @@
         },
       );
     }
-    return db as unknown as FactsDb;
+    // `Row` is `Record<string, any>`; one typed assertion narrows the double to the service's seam.
+    return db as FactsDb;
   }
 
   private matches(row: Row, where: Row): boolean {
@@ -254,8 +255,11 @@
     week_index: 0,
     day_index: 1,
   });
-  stage(db, 'blocks', 'B1', { title: 'Block', weeks: 4, days: 3 }, PLATFORM, coach);
-  stage(db, 'routines', 'W1', { title: 'Day', block_id: 'B1', week: 1, day: 2 }, PLATFORM, coach);
+  // Staged under the canonical tokens: the S8-C writer keys its ledger rows by canonical family,
+  // and the D-S9-2 join is on the raw wide identity (token, platform, source_id) — see the
+  // negative case under "ledger join on the wide identity".
+  stage(db, 'programs', 'B1', { title: 'Block', weeks: 4, days: 3 }, PLATFORM, coach);
+  stage(db, 'workouts', 'W1', { title: 'Day', block_id: 'B1', week: 1, day: 2 }, PLATFORM, coach);
   ledger(db, 'programs', 'B1', 'reconstructed', { target_id: program.id, target_kind: 'workout_program' }, PLATFORM, coach);
   ledger(db, 'workouts', 'W1', 'reconstructed', { target_id: plan.id, target_kind: 'workout_plan' }, PLATFORM, coach);
   provenance(db, 'programs', 'B1', 'workout_program', program.id, 'created', null, PLATFORM, coach);
@@ -368,10 +372,10 @@
   describe('ledger join on the wide identity', () => {
     it('attaches failed / skipped / reconstructed facts and leaves the missing row null', async () => {
       const db = new FakeDb();
-      stage(db, 'routines', 'W1', { title: 'a' });
-      stage(db, 'routines', 'W2', { title: 'b' });
-      stage(db, 'routines', 'W3', { title: 'c' });
-      stage(db, 'routines', 'W4', { title: 'd' });
+      stage(db, 'workouts', 'W1', { title: 'a' });
+      stage(db, 'workouts', 'W2', { title: 'b' });
+      stage(db, 'workouts', 'W3', { title: 'c' });
+      stage(db, 'workouts', 'W4', { title: 'd' });
       ledger(db, 'workouts', 'W1', 'failed', { reason: 'error:Error' });
       ledger(db, 'workouts', 'W2', 'skipped', { reason: 'unresolved:missing_required_field:type' });
       ledger(db, 'workouts', 'W3', 'reconstructed', { target_id: 'evidence-1', target_kind: null });
@@ -398,6 +402,21 @@
       expect(facts.ledger_without_staged).toBe(1);
       expect(family(facts, 'workouts').ledger_without_staged).toBe(1);
     });
+    it('does NOT join a step-token staged row to a canonical-token ledger row for the same id', async () => {
+      // D-S9-2 wide identity is raw: `routines/W1` and `workouts/W1` are two identities even though
+      // both resolve to `workouts`. The ledger row is an orphan attributed to the family it evidences.
+      const db = new FakeDb();
+      stage(db, 'routines', 'W1', { title: 'a' });
+      ledger(db, 'workouts', 'W1', 'reconstructed', { target_id: 'p-1', target_kind: 'workout_plan' });
+      provenance(db, 'workouts', 'W1', 'workout_plan', 'p-1', 'created');
+      const facts = await service().collect(db.client(), COACH, INTENT);
+      const w = family(facts, 'workouts');
+      expect(w.identities.map((i) => [i.token, i.identity, i.ledger])).toEqual([
+        ['routines', identityKey(PLATFORM, 'W1'), null],
+      ]);
+      expect(w.ledger_without_staged).toBe(1);
+      expect(facts.ledger_without_staged).toBe(1);
+    });
     it('counts an orphan ledger row run-wide even when its token resolves to no family', async () => {
       const db = new FakeDb();
       stage(db, 'routines', 'W1', { title: 'a' });
@@ -478,7 +497,7 @@
     });
     it('carries an unresolved top-level provenance row verbatim (outcome, reason)', async () => {
       const db = new FakeDb();
-      stage(db, 'routines', 'W1', { title: 'a', client_id: 'C7' });
+      stage(db, 'workouts', 'W1', { title: 'a', client_id: 'C7' });
       ledger(db, 'workouts', 'W1', 'reconstructed', { target_id: 'ev-1', target_kind: 'scout_entity' });
       provenance(db, 'workouts', 'W1', 'workout_plan', null, 'unresolved', 'unresolved:no_native_client_principal');
       const facts = await service().collect(db.client(), COACH, INTENT);
```

### s9-reconciliation.md

```diff
--- a/docs/decisions/2026-09-25-s9-reconciliation.md
+++ b/docs/decisions/2026-09-25-s9-reconciliation.md
@@ -560,16 +560,19 @@
 - **C-6 (qualifier domains).** `unresolved_family:<token>` carries the staged token, which ingest
   accepts as any 1-128 character string; the token already projects as `families[].family`
   under the accepted S7-L contract, so no new exposure exists, but R14's PII guarantee does not
-  extend to tokens. The reason parser validates qualifier domains (family, field and model names
-  from the spec), not only the code prefix; anything else degrades to `reason_unrecognised`.
+  extend to tokens. The accepted S9-A parser recognises reason codes by their catalogue prefix
+  and does not validate qualifier domains; validating the qualifier against the spec's family,
+  field and model names before anything reaches a DTO is an S9-C obligation, recorded here, not
+  a property of the landed reconciler.
 - **C-7, second half (`qualifiers` enum).** `qualifiers[]` is a closed OpenAPI enum
   (`roster_bridge_pending` only in v1; append-only), never `string[]`. The 32-family R15 fixture
   and the CONSUMER_FREEZE L78 note stand as recorded in §3.
-- **C-9 (recompute-on-read).** S9-B collects every fact of one run inside a single read-only
-  `REPEATABLE READ` transaction (`Prisma.TransactionClient` passed in by the caller; the settle
-  path runs inside S8-G's transaction, the status path opens its own). Classification therefore
-  sees one snapshot across staging, ledger, provenance and native tables. S9-C adds a spec that
-  asserts S9-A's copy of the §3.7 catalogue equals S8-C's runtime `UNRESOLVED_CODE`.
+- **C-9 (recompute-on-read).** The S9-B facts service opens no transaction and issues only
+  reads; the caller supplies one `Prisma.TransactionClient` and is responsible for running it
+  at `REPEATABLE READ` so classification sees one snapshot across staging, ledger, provenance
+  and native tables. On the settle path that transaction is S8-G's (which also writes the
+  terminal); on the status path S9-C opens one for the read. S9-C adds a spec that asserts
+  S9-A's copy of the §3.7 catalogue equals S8-C's runtime `UNRESOLVED_CODE`.
 - **C-10 (wording).** `relationship_closure: 'not_applicable'` means "no bucket-j identity of the
   family carries a declared edge" (see A.2 deviation 5), never "not checked". R12's "`null` only
   for D-S9-3/D-S9-4 fields" also lists `media_policy`, `pagination_terminal_evidence` and
```
