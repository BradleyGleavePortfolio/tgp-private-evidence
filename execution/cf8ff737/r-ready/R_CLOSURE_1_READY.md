# R closure 1 — READY for delta re-attestation

T4 R builder → parent (cf8ff737), per `R_CLOSURE_1_GRANT.md`. Nothing run against PostgreSQL; no cluster touched; no push.
Fable/High requested for this builder; no telemetry claimed.

## New head
- **HEAD** `7d2895e1fe03ea82353e8ce0b07aacaf66af74c8` (parent `df36e3310d4088501c93bcac3ce07617d02c749d`), branch `s7-r-ready`
- **TREE** `95cdfadc1ae993db23d0d1310ee8029c7867d147`
- **SPEC blob** `HEAD:test/rls-g2-r-ready.spec.ts` = `0ae7b76489460dac33dff5434503a361a0acd063`
- migration.sql blob `dc04796…` (was `64d8daeb…`); bootstrap blob unchanged `67b77f7a…`; down.sql unchanged
- author + committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`; no trailers; no amend; worktree clean (porcelain 0)
- subject `fix(importer): gate wide identity first and pin the R11 decoy snapshot`

## Diff confinement
`git diff df36e331 HEAD --stat`: exactly 2 files — `prisma/migrations/20270120000000_scout_identity_ready/migration.sql` (+11/−11) and `test/rls-g2-r-ready.spec.ts` (+17/−4). 
- migration.sql: the "wide identity already present" block (2 comment lines + IF … END IF;) moved from after the fence gate to immediately after `END LOOP;`. Verified position-only: the sorted line multiset of old and new file is identical (`diff <(git show HEAD~1:… | sort) <(sort …)` empty). Guard order now: narrow → **wide-present** → column → fence → NULL → noncanonical ledger → noncanonical staging. Spec lines asserting `/G2-R wide identity already present/` on post-apply reruns (R05, R11 shadow, stage-5 re-up) are unchanged and now consistent.
- spec: `expectRefusedUp(message, before, expectedWide = ABSENT)` (grant §2 "equivalent route"); R11 snapshots `wide()` after each decoy step via `onlyDecoy()` (asserts `ledgerNotNull === false`, at least one R-named object present, every index def contains ` ON public.g2r_decoy `, every check's relation is `g2r_decoy` — i.e. nothing R-named on the two real tables) and passes the snapshot as `expectedWide`; the end-of-test `expect(wide()).toEqual(ABSENT)` after `DROP TABLE` is unchanged. No harness/fixture/other test change.

### Exact diff since df36e331
```diff
diff --git a/prisma/migrations/20270120000000_scout_identity_ready/migration.sql b/prisma/migrations/20270120000000_scout_identity_ready/migration.sql
index 64d8dae..dc04796 100644
--- a/prisma/migrations/20270120000000_scout_identity_ready/migration.sql
+++ b/prisma/migrations/20270120000000_scout_identity_ready/migration.sql
@@ -46,6 +46,17 @@ BEGIN
       RAISE EXCEPTION 'G2-R unexpected identity prerequisite';
     END IF;
   END LOOP;
+  -- Nothing this file creates may already exist under its name (raw rerun, partial state or a
+  -- decoy relation/constraint holding the name): refused, never dropped or adopted.
+  IF to_regclass('public."ScoutIngestEntity_identity_key"') IS NOT NULL
+    OR to_regclass('public."ScoutReconstructionLedger_identity_key"') IS NOT NULL
+    OR EXISTS (
+      SELECT 1 FROM pg_catalog.pg_constraint
+      WHERE conname IN ('ScoutIngestEntity_source_platform_canonical',
+                        'ScoutReconstructionLedger_source_platform_canonical')
+    ) THEN
+    RAISE EXCEPTION 'G2-R wide identity already present';
+  END IF;
   -- E must be present exactly as shipped: nullable TEXT, no default, no constraint. The
   -- staging column must be the accepted NOT NULL TEXT, no default, no constraint.
   IF NOT EXISTS (
@@ -91,17 +102,6 @@ BEGIN
   ) THEN
     RAISE EXCEPTION 'G2-R fence absent';
   END IF;
-  -- Nothing this file creates may already exist under its name (raw rerun, partial state or a
-  -- decoy relation/constraint holding the name): refused, never dropped or adopted.
-  IF to_regclass('public."ScoutIngestEntity_identity_key"') IS NOT NULL
-    OR to_regclass('public."ScoutReconstructionLedger_identity_key"') IS NOT NULL
-    OR EXISTS (
-      SELECT 1 FROM pg_catalog.pg_constraint
-      WHERE conname IN ('ScoutIngestEntity_source_platform_canonical',
-                        'ScoutReconstructionLedger_source_platform_canonical')
-    ) THEN
-    RAISE EXCEPTION 'G2-R wide identity already present';
-  END IF;
   -- Data preconditions: the drain is complete and every value is already canonical. A
   -- violation names the class only; no identifiers or values are raised.
   IF EXISTS (SELECT 1 FROM public."ScoutReconstructionLedger" WHERE source_platform IS NULL) THEN
diff --git a/test/rls-g2-r-ready.spec.ts b/test/rls-g2-r-ready.spec.ts
index a6f3f16..0ae7b76 100644
--- a/test/rls-g2-r-ready.spec.ts
+++ b/test/rls-g2-r-ready.spec.ts
@@ -99,13 +99,15 @@ const stagingInsert = (id: string, platform: string, role?: string, source = id)
 /** Refusal with the SQLSTATE visible: psql prints `ERROR:  <sqlstate>:` under verbose verbosity. */
 const refusedCode = (statement: string, sqlstate: string) =>
   refused(`\\set VERBOSITY verbose\n${statement}`, `ERROR:  ${sqlstate}:`);
-/** R's entry gate refused: nothing of R exists, history and rows are untouched. */
+/** R's entry gate refused: nothing of R exists (or, for a decoy holding an R name, exactly the
+ *  pre-refusal catalog), history and rows are untouched. */
 function expectRefusedUp(
   message: RegExp,
   before: { ledger: unknown; staging: unknown; applied: string },
+  expectedWide: unknown = ABSENT,
 ) {
   expect(() => sqlFile(rUpFile)).toThrow(message);
-  expect(wide()).toEqual(ABSENT);
+  expect(wide()).toEqual(expectedWide);
   expect(allLedger()).toEqual(before.ledger);
   expect(stagingSnapshot()).toEqual(before.staging);
   expect(appliedMigrations()).toBe(before.applied);
@@ -322,12 +324,23 @@ describe('stage 2: the entry gate on E+B — refusals leave everything untouched
     expect(decoyBefore.index).toBe(
       'CREATE INDEX "ScoutIngestEntity_identity_key" ON public.g2r_decoy USING btree (x)',
     );
-    expectRefusedUp(/G2-R wide identity already present/, before);
+    /** wide() sees the decoy's R-named objects; only the decoy may own them, never the real tables. */
+    const onlyDecoy = (w: any) => {
+      expect(w.ledgerNotNull).toBe(false);
+      expect(w.indexes.length + w.checks.length).toBeGreaterThan(0);
+      for (const [, , , , def] of w.indexes) expect(def).toContain(' ON public.g2r_decoy ');
+      for (const [, , rel] of w.checks) expect(rel).toMatch(/^(public\.)?g2r_decoy$/);
+    };
+    let wideBefore = wide();
+    onlyDecoy(wideBefore);
+    expectRefusedUp(/G2-R wide identity already present/, before, wideBefore);
     expect(decoy()).toEqual(decoyBefore);
     sql(`DROP INDEX public."ScoutIngestEntity_identity_key";
       ALTER TABLE public.g2r_decoy ADD CONSTRAINT "ScoutReconstructionLedger_source_platform_canonical" CHECK (x IS NOT NULL)`);
     before = snapshot();
-    expectRefusedUp(/G2-R wide identity already present/, before);
+    wideBefore = wide();
+    onlyDecoy(wideBefore);
+    expectRefusedUp(/G2-R wide identity already present/, before, wideBefore);
     expect(decoy()).toEqual({
       index: null,
       constraints: ['ScoutReconstructionLedger_source_platform_canonical'],
```

## Hook receipts (appended, not rewritten)
- `receipts/13-closure1-commit.log` — Lefthook v2.1.9 pre-commit: prod-readiness-quick ✔, banned-cast-tokens (check-r75 staged) ✔, prettier ✔, eslint ✔, tsc ✔ (73.6 s); commit-msg no-ai-tokens ✔; `[s7-r-ready 7d2895e] … 2 files changed, 28 insertions(+), 15 deletions(-)`; rc 0.
- `receipts/06-lock.txt` — appended: `CLOSURE1 LOCK_ACQUIRED 2026-09-24T16:34:10Z … purpose=hooked-commit-only`, `CLOSURE1 LOCK_RELEASED_VERIFIED_FREE 2026-09-24T16:35:24Z` (held 74 s, commit only).
- `receipts/RECEIPTS.sha256` recomputed (13 entries; 01–12 unchanged bytes except 06 appended).
- Note on grant §3 wording "hooks … and default Jest": the repository's Lefthook pre-commit does not include Jest, so no Jest ran in this closure (heavy slot was relayed for the hooked commit only). The two changed files are not imported by any default-Jest suite (`test/rls-g2-r-ready.spec.ts` runs only under `jest.rls.config.js`; `migration.sql` is read only by the PG proof), so the receipt-11 default-Jest result (3 suites / 90 tests, rc 0) is unaffected by this delta. If the parent wants a fresh default-Jest receipt on 7d2895e1 anyway, relay the slot and I will run it (≈60 s), no source change.

## Binding refill (`r-ready/binding/`)
- old filled sha `ac437b90057ab471f851f63cc3bbb7a3ffc8b62e220154c3b0c075e8ee38be15` (kept as `r-pg-proof.sh.v1-ac437b90`)
- **new filled sha `787d34b08f7abcbc18fa077eed29b15167fc762983f47fe58e3de6beb89b3cc2`**; substitution-only (regenerated, pins unfilled) `e5afc45b…`
- `r-fixture.sh` unchanged `6e71d7540aaf5703b7133e9081bd0146c831f9daa8178de5345983692c8b35f3`
- `derive-r-pg-proof.py` updated (two substitution pairs appended, mirror of the two edits; previous kept as `derive-r-pg-proof.py.v1`; diff `derive-r-pg-proof.py.diff-closure1-vs-v1`); the runner was regenerated from it and then pinned — reproducible.
- `PINS.txt`, `BINDING.sha256` recomputed; `sha256sum -c BINDING.sha256` 3/3 OK; `bash -n` ok; 0 placeholders.
- Hook check evaluated read-only exactly as the binding will: `git -C worktrees/s7-r-ready rev-parse --git-path hooks` → `/home/user/workspace/worktrees/s7-b-drain/.git/hooks`; both pre-commit and commit-msg contain `lefthook` → PASS.
- C-R7 (`$W/.git/MERGE_HEAD`) left as-is per grant.

### Binding diff (v1 → closure 1; `r-pg-proof.sh.diff-closure1-vs-v1`)
```diff
2c2
< # S7-3' R/ready real-PG proof — minimal execution binding (SOURCE ONLY; NOT RUN; NOT GRANTED; pins filled from head df36e33).
---
> # S7-3' R/ready real-PG proof — minimal execution binding (SOURCE ONLY; NOT RUN; NOT GRANTED; pins filled from head 7d2895e, closure 1).
26,28c26,28
< EXPECT_HEAD=df36e3310d4088501c93bcac3ce07617d02c749d
< EXPECT_TREE=74ddf4dd57657300d96b9a7b0cdd6e6237a52abd
< EXPECT_SPEC_BLOB=a6f3f166774fd8cb8cb639b99affcc1d7add81ee                 # test/rls-g2-r-ready.spec.ts at the R head
---
> EXPECT_HEAD=7d2895e1fe03ea82353e8ce0b07aacaf66af74c8
> EXPECT_TREE=95cdfadc1ae993db23d0d1310ee8029c7867d147
> EXPECT_SPEC_BLOB=0ae7b76489460dac33dff5434503a361a0acd063                 # test/rls-g2-r-ready.spec.ts at the R head
45c45
<        G2_R_DATA_DIRECTORY=$BDIR/pg-data G2_R_SERVER_VERSION=170006 \
---
>        G2_R_DATA_DIRECTORY=$RDIR/pg-data G2_R_SERVER_VERSION=170006 \
74,75c74,76
< grep -q lefthook "$W/.git/hooks/pre-commit" 2>/dev/null && grep -q lefthook "$W/.git/hooks/commit-msg" 2>/dev/null \
<   || { log "PRECONDITION_FAIL .git/hooks/pre-commit or commit-msg absent or not lefthook (hookless commit)"; fail 70; }
---
> H=$(git -C "$W" rev-parse --git-path hooks); case "$H" in /*) ;; *) H="$W/$H";; esac
> grep -q lefthook "$H/pre-commit" 2>/dev/null && grep -q lefthook "$H/commit-msg" 2>/dev/null \
>   || { log "PRECONDITION_FAIL $H/pre-commit or commit-msg absent or not lefthook (hookless commit)"; fail 70; }
```

## Exports
`export/closure1-df36e331..7d2895e1.patch`, `export/s7-r-ready-7d2895e1.patch` (format-patch), `export/s7-r-ready-closure1.bundle` (0d69c7ba..s7-r-ready, verified ok), `export/COMMIT_MSG_closure1.txt`.

## Lane state (read-only, 16:37Z)
`/home/user/pg17/clusters/` = `b-drain`, `b-drain.v4-failed-75a2863b-20260924T151250Z` only (no `r-ready`); no postgres processes; no `r-ready/runtime/`; port 55471 unclaimed by anything of mine; heavy slot free. **Disk 3.8 GiB free** (was 4.7 before the gate/commit tooling caches) — above the grant's 3 GiB floor, below reviewer A's suggested 4 GiB; flagging for the PRE-R3 decision.

## Request
Delta re-attestation by both reviewers (moved gate, R11 hunk, binding lines 2/26–28/45/74–76), then `R_SINGLE_PG_PROOF_GRANT.md` for
`timeout -k 30 3600 bash /home/user/workspace/execution/cf8ff737/r-ready/binding/r-pg-proof.sh` (sha `787d34b0…`). Not run until granted.
