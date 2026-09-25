# S8-C harness + spec correction — final receipt (S8C-BC-3 → BC-4 → BC-5, EXEC-DACEDDC8)

Builder `s8c_bootstrap_completion` (T4). Evidence repo NOT committed by the builder (parent publishes). No amend, no
`--no-verify`, no force push, no rerun of any consumed run. The v5 driver was never executed. Supersedes the interim receipt.

## Final pins
| item | value |
|---|---|
| **HEAD** | `f428db9ab65f638da1651b8cd792c6f93b4983c1` on `exec64/s8c-replacement` |
| **TREE** | `f2623be642ddfbba025ffe8360256a683ac57997` |
| lineage | `87018a42` (v5 ckpt) → `e0cee7e0` (bootstrap fix, v6) → `9cc76401` (harness) → `4d7d4b4e` (spec, 3 sites) → `f428db9a` (spec, User baseline) |
| changed blobs vs 87018a42 | `test/utils/g2-s8c-bootstrap.sh` `7c3fba471f991e3750eb56fd29e271101652196e` (unchanged since e0cee7e0); `test/utils/g2-s8c-harness.ts` `d5cbf877…` → **`1a8f17970a1095f9b802badacf093e773caabd76`**; `test/rls-g2-s8c.spec.ts` `dc804fde…` → **`9d701783eeb7701126d158b45bfee3d5f0f686b3`** |
| unchanged | prisma/, src/, docs/contracts trees identical to 87018a42 (v7 HEAD.txt); DB/PGH/WORKER blobs and all tool pins identical to v4 |
| checkpoint v7 | `s8c/checkpoints/v7/` bundle `s8c-f428db9a.bundle` `65aa9245…`, `MANIFEST.sha256` `1554ef88…` (6/6 OK), `e0cee7e0..HEAD.patch` `fb1e8774…` |
| binding v5 driver | `s8c/binding/v5/s8c-pg-proof.sh` **`b641db2d5fae07d9220e573a04cb512c5ec35814b08ae7c506c02499c314fd1d`** |
| binding v5 fixture | `s8c-fixture.sh` **`34a42ab8b2ffa75256f5fa600ca7a51bcdb3ae1f224ad989ff1ca7a4dd716f10`** |
| binding v5 manifest | `BINDING.sha256` **`2995ed837fd352e3ea663949cc74e66ca5eec4566444739e8b7f53aab87c9eba`** (10/10 OK); PINS.txt `0c18477f…` |
| run-prep v5 supervisor | `s8c/binding/v5/run-prep/supervisor.sh` **`5407d27458ea705c471dda2c328067ea0219233769826383e5f8770b099eabec`** (flag `S8C_PG5_GRANT=1`); PREFLIGHT.md `b752503a…`; RUN_PREP.sha256 |
| lane | `recovery-reset/proof-v5/clusters/s8-c`, socket `proof-v5/run/s8-c`, port 55642 (both ABSENT now) |

## Commits (each: one file, genuine lefthook hooks — prod-readiness, banned-casts, prettier, eslint, tsc, no-ai-tokens — all ✔; Bradley Gleave author+committer; no trailers)
1. **BC-3** `9cc76401` (slot 17:03:27–17:04:17Z): `catalog()` INSERT supplies `updated_at` (`now()`), +8/−3. Gate `harness-correction/s8c-harness-gate.sh`, logs `harness-correction/run/`.
2. **BC-4** `4d7d4b4e` (slot 17:12:37–17:13:28Z): F1 identity observation via `jsonAdmin`; F2 `toBeCloseTo(toPounds(100,'kg'), 9)` on `weight_lbs` only; F3 `count('User', id <> seed)`; unused `json` import removed (required by eslint hook). +9/−4. Gate `spec-correction/s8c-spec-gate.sh`; first launch stopped at its own eslint step (unused import; no commit attempted) — preserved `spec-correction/run-attempt1-lint-stop/`; second launch `spec-correction/run/`.
3. **BC-5** `f428db9a` (slot 17:18:09–17:19:01Z): both User-count sites → pre-writer baseline (`usersBefore`), +7/−4. Standing-permission sweep: `User` is the only migration-seeded table among those the spec counts (seed INSERTs exist only for BuildWeekDay, CoachBriefPushLedger, ContractTemplate, User, WearableMetricDef). Gate `spec-correction-bc5/s8c-spec-bc5-gate.sh`, logs `spec-correction-bc5/run/`.

## Diagnostics (non-accepting; `harness-correction/diagnostic/`; own scratch-lane scripts, never a frozen driver; all `flock -n`)
| run | slot | lane | head | result |
|---|---|---|---|---|
| (a) catalog | 17:02:44–17:02:53Z | `scratch/s8c-diag` fresh, bootstrap rc=0 | e0cee7e0 | 27 NOT NULL/no-default columns across the 5 raw-SQL tables; exactly one omitted (`ExerciseCatalogItem.updated_at`) |
| (b) suite | 17:04:52–17:05:44Z | `scratch/s8c-diag` | 9cc76401 | 10/13 → F1 F2 F3 (`FINDINGS.md`) |
| (b2) suite | 17:14:02–17:14:52Z | `scratch/s8c-diag` (reused) | 4d7d4b4e | 11/13 → F4 (masked 4th `count('User')`) + lane contamination (`spec-correction/STOP_FOR_DISPOSITION.md`) |
| **(b3) suite** | **17:19:51–17:20:57Z** | **`scratch/s8c-diag2` FRESH: initdb + unchanged bootstrap rc=0 (171, seed_users=1)** | **f428db9a** | **13 passed / 13 total, 51.3 s** — `b3/jest.log` sha256 `1bbd3d28403a83960d6688e8bbf2318eb5584f02eea1dbc94c48a31a1d5bee46` |
Every run exited with 0 lock holders, 0 postgres, 55644 free, scratch pg-data retained without `postmaster.pid`. The retained
v4 lane `proof-v4/clusters/s8-c` and the S7-L lanes were never touched. Slot order respected (S7-L v4 END 17:00:22Z observed first).

## Binding v5 derivation (`harness-correction/v5-prep/prepare-binding-v5-daceddc8.sh`, source-only)
From frozen v4 bytes (`BINDING.sha256` re-verified): binding dir, head/tree pins, SPEC + HARNESS blob pins, fixture pin,
`proof-v4`→`proof-v5` lane/socket in driver + fixture, both other-lane loops also enumerate `proof-v5/clusters/*/`, README §v5,
and **PINS.txt L57 fixed** (`DATA=$RUNTIME_ROOT/proof-v5/clusters/s8-c/pg-data SOCK=$RUNTIME_ROOT/proof-v5/run/s8-c`; v4 had
left it at the v3 paths). Asserted-count literal replacements; unchanged-pin diff against v4 empty; all six head-derived pins
re-read from git. Diffs: `s8c-pg-proof.sh.diff-v4-to-v5` `72b1f849…`, `s8c-fixture.sh.diff-v4-to-v5` `e5c8dd58…`,
`PINS.txt.diff-v4-to-v5` `93e8622f…`. First prep invocation stopped on its own over-strict self-check (my README-style comment
in the fixture mentions the retained v4 lane path); the unfrozen partial output (no manifest yet) was removed, the check
narrowed to non-comment lines, and the prep ran once more — recorded here; the frozen v5 is the single manifested output.

## Recorded operational notes
- BC-4 gate attempt 1 (eslint stop) and diag b2 attempt 0 (script's own env-name refusal before lock/PG) are preserved as-is.
- `checkpoints/v7/HEAD.txt` is labelled `T4 builder s8c_bootstrap_completion` (v6's "parent operator" label was class C).
- Scratch lanes `scratch/s8c-diag` (76 MB) and `scratch/s8c-diag2` remain on disk for the parent's disposition (destroy grant).
