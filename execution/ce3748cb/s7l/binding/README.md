# S7-L1 PG binding — pins FILLED to the S7-L2 head (NOT RUN, PG run NOT GRANTED)

**Status 2026-09-24 (SOURCE_READY):** S7-L1 (`0ef55965`) and S7-L2 (`7ab9cc37` + follow-up `12de0bbd`, tree `28a7400b`) are committed on `s7-l` through
lefthook. `s7l-pg-proof.sh` now carries the filled pins (OLD_HEAD = accepted C head `1b6cc661`, EXPECT_HEAD/TREE/SPEC/BOOTSTRAP,
fixture and generated-client sha256, N/Q1 blobs re-pinned to their `1b6cc661` values, the accepted C blob block added at the
marked slot). Filled sha256: `ed85a5a4700cf3c3359ad51a806ae060ae9e54953c2930bba05b48083197fd35` (see `PINS.txt`; the substitution-only
form `d351870c…` is what `derive-s7l-pg-proof.py` describes). Still NOT executed against PostgreSQL. The runner runs only under a
separate single-run PG grant; if S8-B lands on `integration/importer` first, re-pin OLD_HEAD (runner + committed harness) per
POST_C_SEQUENCING before that run.

---
*Original draft README follows.*

Source-only work under `execution/ce3748cb/s7l/**` (S7L_L0_L1_GRANT). Nothing here has been executed against
PostgreSQL; no PostgreSQL process, lock, cluster directory or worktree git state was touched by drafting (the derivation
script and `bash -n` were the only things run on these files). The runner is executed only under a SEPARATE single-run
PG grant, after the pre-steps its header lists (rebase onto the accepted C head, schema hunk, S7-L1-only generate, gates,
hooked commit, pin fill).

| file | derived from | sha256 (draft, pins unfilled) |
|---|---|---|
| `s7l-fixture.sh` (95 lines) | C `c/binding/c-fixture.sh` (cf342f4b…) by substitution | `6b3a76f499038b61fe6ee650a157f3798f1e441824a873630d1d9e929e379566` |
| `s7l-pg-proof.sh` (233 lines) | C `c/binding/c-pg-proof.sh` (draft c84ffb12…) by substitution + added read-only checks | `d351870c34c99e2e7c4e2608bda177aa1a79f3488e9d0901f65d5a85c95d3a1c` |
| `derive-s7l-pg-proof.py` | the exact substitution script that produces BOTH files (asserted match counts; re-run reproduces byte-identically) | `185cddcce215c31d4ec4a908fd0c3e46a4d3695630e3417c444a49dfd1e97c7a` |
| `s7l-pg-proof.sh.diff-vs-c` | `diff` C runner → S7-L runner (229 lines, whole-line) | — |

## Substitutions (identity only)
- lane dir `clusters/c-contract` → `clusters/s7-l` (`LDIR`); socket `run/c-contract` → `run/s7-l`; `C1DIR`, `BDIR`, `RDIR`,
  `NDIR` and now `CDIR` kept as retained stopped clusters (hashed in preflight, re-hashed in post, never started).
- port 55491 → 55501; `c_super`/`c_local_synthetic` → `s7l_super`/`s7l_local_synthetic`; DB `g2_c_disposable` →
  `g2_s7l_disposable`; CONFIRM `g2_s7l_disposable:55501`.
- markers `c-disposable-pg17` → `s7l-disposable-pg17`; DB comment → `s7l-g2-lifecycle-synthetic-disposable-fixture-safe-to-drop`.
- env prefix `G2_C_*` → `G2_S7L_*` (DATABASE_URL, CONFIRM, PASSWORD, PSQL, DATA_DIRECTORY, SERVER_VERSION, OLD_ROOT,
  OLD_CLIENT; markers `G2_S7L_OLD_ROOT_OK`/`G2_S7L_BOOTSTRAP_OK`; old-client dir `.g2-s7l-old-client`). No
  `G2_PG17_*`/`G2_B_*`/`G2_R_*`/`G2_NQ1_*`/`G2_C_*` exported.
- `C_RUNNER_PID/C_STOP_TIMEOUT/C_FIXTURE_*` → `S7L_*`; spec `test/rls-g2-s7l.spec.ts`; bootstrap
  `test/utils/g2-s7l-bootstrap.sh`; old-root helper `test/utils/g2-s7l-old-root.sh` (drafted, uncommitted).
- roots: `D=execution/ce3748cb/s7l/binding`, `RT=execution/ce3748cb/s7l/runtime` (run/, old-root/), `W=worktrees/s7-l`.
- `EXPECT_NM_CLIENT_SHA` = `__FILL_AFTER_GENERATE__` (S7-L1 generated client; receipt 03); `EXPECT_NM_LOCK_SHA` unchanged
  `05bc530a…` (receipt 01: isolated copy of the verified N/Q1 tree, hidden lock and N client hashes recorded).

## Structural change vs C (the OLD side moves from N/Q1 to the S7-L base)
- `NQ1_HEAD` → `OLD_HEAD`, pinned to 61b93cff (N/Q1 v1) while drafting because that is the head this worktree is on; the
  mechanical rebase onto the accepted C head re-pins it (runner, `g2-s7l-old-root.sh`, `g2-s7l-bootstrap.sh`,
  `g2-s7l-pg-harness.ts`, spec `EXPECTED_HISTORY` 169 → 170) and adds the accepted C file blob pins where the comment marks
  the slot. The N/Q1 v1 ancestor check and the seven N/Q1 file pins are kept.
- migration diff check: exactly `20270123000000_scout_run_lifecycle_expand/{migration,down}.sql` vs `OLD_HEAD`.
- added read-only preconditions: `prisma/schema.prisma` carries the S7-L1 ScoutImport hunk (`mode`, `import_intent_id`);
  `src/scout/lifecycle` absent (S7-L2 is not part of this proof).
- no other executable line changed (see the diff file; comment lines carry the S7-L text).

## What the runner does NOT do
No retry, no inherited-proof replay, no `prisma generate` outside the old root, no lock other than the single canonical
holder, no destroy (data dir retained; `s7l-fixture.sh destroy` is a separate marker-gated grant).
