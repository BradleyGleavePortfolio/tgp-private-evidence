# S8-G delta review B — candidate 1279b419 (tree 44ece797) — VERDICT: GO

Read-only. No tsc/jest/npm/postgres run. Lock file not touched; only its inode was read with stat.

## (a) Diff and authorship
- `git diff 820ce85b 1279b419` changes only test/rls-g2-s8g.spec.ts (+6/-3). It contains exactly the three stated edits: isGate becomes `/SET last_observed_at\s*=/`, P01 rt-c gets `title: 'Client Push'`, and P11 now expects `refused(..., 'permission denied')` for ImportNativeProvenance SELECT.
- Parent is 820ce85b. Author and committer are both `Bradley Gleave <bradley@bradleytgpcoaching.com>`. No co-author trailer, no AI attribution, and no tokens in the message or the diff.
- Live pins: HEAD=1279b419ee60…, HEAD^{tree}=44ece797c918…, spec blob=7cae12ad492f….

## (b) Are the edits correct class-B closures?
- **isGate:** The only product statement that writes last_observed_at is the assertRunOpen gate UPDATE (lifecycle.service.ts:445), which is literally `SET last_observed_at = (`. Prisma ORM statements quote the column (`"ScoutImport"."last_observed_at"`), so they cannot match. No Prisma update of last_observed_at exists in src.
- **jest.log agrees:** In P03, P05 and P07-late, the extra item is the Prisma classifyClosed SELECT, which runs after a zero-row gate.
- **The narrower matcher can only lower counts.** Any earlier-passing assertion that had counted a SELECT would now fail; none can now pass vacuously.
- **Each of the 15 isGate uses checked:**
  - :373 (seg[0] is the gate) and :374 (8) — a run-pass with no classifyClosed.
  - :419, :420, :713, :744 (0) — still exact, since no gate is issued.
  - :525 (P04 run-pass, 2) — run-pass has no classifyClosed.
  - :591 (1), :610 (3), :644 (1), :654 (3) — open-gate paths with no SELECT. These passed on v2 and the counts stay the same.
  - :806 (1).
  - :472/473 (P03 3), :555/556 (P05 2), :669 (P07 late 1) — these now equal the actual gate count shown in jest.log.
  - The later P03/P05 index logic (the rollback after the last gate, then begin/lock) still anchors on the real gate. It first executes in v3.
- **P01:** The rt-c row now carries its own title. That makes the proof stronger, because the label can only come from the rt-c row. It also matches stagePlanned (spec :106-111) and the v2 failure (the old version got 'Push Day').
- **P11:** Migration 20270122000000 (migration.sql:173) runs `REVOKE ALL PRIVILEGES ... FROM anon, authenticated`. The v2 error text was `permission denied for table ImportNativeProvenance`. `refused` throws if the SQL succeeds, so the new assertion is stricter than '0 rows'. The INSERT row-level-security check and the ledger '0' check are unchanged.

## (c) Binding
- `diff v2 v3` on s8g-pg-proof.sh is identical to v3/DELTA-v2-v3.diff: only line 24 (D path → v3) and lines 33-35 (EXPECT_HEAD, EXPECT_TREE, EXPECT_SPEC_BLOB). The new pins equal the live rev-parse values.
- The old pins also matched the old commit: 820ce85b^{tree}=7ede6dbb… and its spec blob is 86a944c1….
- The fixture is the same in v1, v2 and v3: sha256 62de28baa4ad…3d24d, equal to EXPECT_FIXTURE_SHA. Line 58 sets FIX=$D/s8g-fixture.sh.
- `diff v1 v2` is identical to v2/DELTA-v1-v2.diff: D path plus EXPECT_LOCK_INODE 667698→692282. The live lock inode is 692282.
- tgp-private-evidence is a symlink to /home/user/workspace/private-evidence.
- The spec still has 19 `it(` calls and no it.each/skip/only, so EXPECT_TESTS=19 holds. The other harness blobs are unchanged because only the spec changed.

## Non-blocking (C, cosmetic)
- In v3, the comments on lines 3 and 48 still mention inode 667698 and "@820ce85b". They are stale text only; the checks they sit next to are correct. No fix required.

Blocking findings: none.
