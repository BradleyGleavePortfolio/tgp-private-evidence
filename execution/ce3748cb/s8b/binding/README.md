# S8-B PG binding — substitution-only DRAFT (NOT RUN, NOT GRANTED, pins UNFILLED)

Source-only work under `execution/ce3748cb/s8b/**` (S8_B_DRAFT_GRANT). Nothing here has been executed against
PostgreSQL; no PostgreSQL process, cluster directory or worktree git state was touched by drafting (the derivation
script and `bash -n` were the only things run on these files). The runner is executed only under a SEPARATE single-run
PG grant, after the pre-steps its header lists (rebase onto the accepted C head, schema hunk, S8-B-only generate, gates,
hooked commit, pin fill). Promotion stage is its own, after C is accepted (D-C2), order-independent of S7-L1 (20270123).

| file | derived from | sha256 (draft, pins unfilled) |
|---|---|---|
| `s8b-fixture.sh` (95 lines) | S7-L `s7l/binding/s7l-fixture.sh` (6b3a76f4…) by substitution | `360b093b0f06360a45ad00cf6ed98d764f16d861227e827a466ba844d65b4b0b` |
| `s8b-pg-proof.sh` (246 lines) | S7-L `s7l/binding/s7l-pg-proof.sh` (draft d351870c…) by substitution + added read-only checks | `e208f3213f59949cbf770a8b9e8bad0834e9122feb5723d66010edd14acffa37` |
| `derive-s8b-pg-proof.py` | the exact substitution script that produces BOTH files (asserted match counts; re-run reproduces byte-identically) | `9d0713192569cdb2a721b21f1d55ab11ad092bd71a7727607a3df54106f9a937` |
| `s8b-pg-proof.sh.diff-vs-s7l` | `diff -u` S7-L runner → S8-B runner (253 lines) | — |

## Substitutions (identity only)
- lane dir `clusters/s7-l` → `clusters/s8-b` (`BDIR8`); socket `run/s7-l` → `run/s8-b`; `C1DIR`, `BDIR`, `RDIR`,
  `NDIR`, `CDIR` and now `LDIR` (clusters/s7-l) kept as retained stopped clusters (hashed in preflight, re-hashed in post,
  never started; ABSENT recorded as-is).
- port 55501 → 55511; `s7l_super`/`s7l_local_synthetic` → `s8b_super`/`s8b_local_synthetic`; DB `g2_s7l_disposable` →
  `g2_s8b_disposable`; CONFIRM `g2_s8b_disposable:55511`.
- markers `s7l-disposable-pg17` → `s8b-disposable-pg17`; DB comment → `s8b-g2-provenance-synthetic-disposable-fixture-safe-to-drop`.
- env prefix `G2_S7L_*` → `G2_S8B_*` (DATABASE_URL, CONFIRM, PASSWORD, PSQL, DATA_DIRECTORY, SERVER_VERSION, OLD_ROOT,
  OLD_CLIENT; markers `G2_S8B_OLD_ROOT_OK`/`G2_S8B_BOOTSTRAP_OK`; old-client dir `.g2-s8b-old-client`). No
  `G2_PG17_*`/`G2_B_*`/`G2_R_*`/`G2_NQ1_*`/`G2_C_*`/`G2_S7L_*` exported.
- `S7L_RUNNER_PID/S7L_STOP_TIMEOUT/S7L_FIXTURE_*` → `S8B_*`; spec `test/rls-g2-s8b.spec.ts`; bootstrap
  `test/utils/g2-s8b-bootstrap.sh`; old-root helper `test/utils/g2-s8b-old-root.sh` (drafted, uncommitted).
- roots: `D=execution/ce3748cb/s8b/binding`, `RT=execution/ce3748cb/s8b/runtime` (run/, old-root/), `W=worktrees/s8-b`.
- `EXPECT_NM_CLIENT_SHA` = `__FILL_AFTER_GENERATE__` (S8-B generated client; receipt 04); `EXPECT_NM_LOCK_SHA` unchanged
  `05bc530a…` (receipt 01 DONE at draft: isolated copy of the verified N/Q1 tree, hidden lock and N client hashes recorded).

## Structural change vs S7-L
- `OLD_HEAD` pinned to 29e60705 (accepted N/Q1 head = the head this worktree is on). The mechanical rebase onto the accepted
  C head re-pins it (runner, `g2-s8b-old-root.sh`, `g2-s8b-bootstrap.sh`, `g2-s8b-pg-harness.ts`, spec `EXPECTED_HISTORY`
  169 → 170) and adds the accepted C file blob pins where the comment marks the slot. The N/Q1 v1 ancestor check and the
  S5/B/R/N/Q1 file pins are kept unchanged.
- migration diff check: exactly `20270122000000_scout_native_provenance_expand/{migration,down}.sql` vs `OLD_HEAD`.
- read-only preconditions replaced: `prisma/schema.prisma` carries `model ImportNativeProvenance` and the ledger
  `target_kind String?`; `src/scout/native` absent (S8-C..E writers are not part of this proof); the four OLD-side
  writer/reader files (`scout-reconstruct.service.ts`, `scout-roster.service.ts`, `scout-entities.service.ts`,
  `reconstruct/families.ts`) are byte-identical to `OLD_HEAD` (mixed-version basis: the N writer never names `target_kind`).
- no other executable line changed (see the diff file; comment lines carry the S8-B text).

## What the runner does NOT do
No retry, no inherited-proof replay, no `prisma generate` outside the old root, no lock other than the single canonical
holder, no destroy (data dir retained; `s8b-fixture.sh destroy` is a separate marker-gated grant).
