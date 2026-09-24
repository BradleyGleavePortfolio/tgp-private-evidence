# R_REATTEST_A — reviewer A delta re-attestation (closure 1)

Basis: `R_CLOSURE_1_GRANT.md` (16:40Z), builder report `r-ready/R_CLOSURE_1_READY.md`. Delta-only per parent mail; unchanged bytes not re-reviewed (they carry from `R_ATTESTATION_A.md`). Read-only: git objects, binding files, receipts; no PG, no tsc/Jest, no lock. Reviewer B's directory not read. Written 2026-09-24 ~16:50Z. Route requested Claude Fable 5 / High — no telemetry, not claimed.

## Verdict: **GO** for `R_SINGLE_PG_PROOF_GRANT.md` on head `7d2895e1` with binding `r-pg-proof.sh` sha `787d34b0…`, subject to PRE-R3 at launch (§4).

B-1, B-2, B-3 from `R_ATTESTATION_A.md` are each closed by the minimum edit and nothing else moved. No new A/B finding.

## 1. New head (recomputed from git objects)
| Item | Builder claim | Recomputed | |
|---|---|---|---|
| HEAD | 7d2895e1fe03ea82353e8ce0b07aacaf66af74c8 | same | ✔ |
| TREE | 95cdfadc1ae993db23d0d1310ee8029c7867d147 | same | ✔ |
| parent | df36e331… | single parent df36e331… | ✔ |
| author / committer | Bradley Gleave <bradley@bradleytgpcoaching.com> | both, ts 1790267650 +0000 (16:34:10Z); raw object has no trailers/extra headers | ✔ |
| spec blob `test/rls-g2-r-ready.spec.ts` | 0ae7b764… | 0ae7b76489460dac33dff5434503a361a0acd063 | ✔ |
| migration.sql blob | dc04796… | dc0479687b46e4d862505b9c027902f6d1b6d3e9 | ✔ |
| down.sql blob | unchanged | 0bd52ec7… (= df36e331) | ✔ |
| bootstrap blob | unchanged | 67b77f7a… | ✔ |
| worktree | clean | porcelain 0 lines | ✔ |
| diff df36e331..HEAD | 2 files, +28/−15 | exactly `migration.sql` (22 lines) and `rls-g2-r-ready.spec.ts` (21 lines); 2 files, 28(+) 15(−) | ✔ confined to grant §3 |

## 2. Moved gate hunk (B-1, option a)
- `diff <(sort old migration.sql) <(sort new migration.sql)` is empty → position-only change; gate text and predicate byte-identical; `down.sql` untouched.
- New RAISE order: `unexpected identity prerequisite` (narrow loop, line 46) → **`wide identity already present` (line 58, immediately after `END LOOP;` line 48)** → `unexpected platform column prerequisite` (83) → `fence absent` (103) → `unresolved NULL provenance` (108) → `noncanonical provenance` (114) → `noncanonical staged provenance` (120).
- Consequence checked by reading: post-apply raw rerun now hits the wide-present gate before the column gate → spec assertions at (renumbered) lines 465 (R05), 475 (R11 shadow), 673 (stage-5 re-up) — still `/G2-R wide identity already present/`, unchanged text — become consistent. Pre-apply refusal cases (fence absent, NULL, noncanonical ×3) are unaffected because the wide-present gate passes when nothing R-named exists. R11 decoy (pre-apply) still raises `already present` via `to_regclass`/`conname`. Fail-closed atomicity unchanged (same DO block, same envelope).

## 3. R11 hunk (review B's B-2, per grant §2 "equivalent route")
- `expectRefusedUp(message, before, expectedWide: unknown = ABSENT)`; the only behavioural change is `expect(wide()).toEqual(expectedWide)`. All other callers (lines 255, 280, 292, 299, 306) pass two args → default `ABSENT` → semantics identical to before.
- R11: after each decoy step, `wideBefore = wide()`, `onlyDecoy(wideBefore)` asserts `ledgerNotNull === false`, at least one R-named object present, every index def contains ` ON public.g2r_decoy `, every check's relation matches `^(public\.)?g2r_decoy$`; then `expectRefusedUp(…, before, wideBefore)`. Tuple positions verified against `wide()` in `g2-r-ready-harness.ts`: indexes = `[relname, indexrelid, indisunique, indisvalid, indexdef]` (def at index 4 ✔), checks = `[conname, oid, conrelid::regclass::text, convalidated, def]` (relation at index 2 ✔). End-of-test `expect(wide()).toEqual(ABSENT)` after `DROP TABLE` retained (line 349). No `.skip`/`.only` introduced. No harness/fixture/other test change (diff stat confirms).
- This makes the previously vacuous-by-construction decoy assertion (`wide()` would have shown the decoy's objects, so `toEqual(ABSENT)` could not have passed) both correct and meaningful: nothing R-named lands on the two real tables, ledger stays nullable.

## 4. Binding refill
- `sha256sum -c BINDING.sha256`: 3/3 OK. Recomputed: `r-pg-proof.sh` **787d34b08f7abcbc18fa077eed29b15167fc762983f47fe58e3de6beb89b3cc2**; `r-fixture.sh` 6e71d754… (unchanged ✔); `derive-r-pg-proof.py` 97cc097e…; retained v1 `r-pg-proof.sh.v1-ac437b90` recomputes to ac437b90… ✔ (history preserved).
- Independent `diff v1 new` = exactly: header comment (line 2); lines 26–28 pins → 7d2895e1 / 95cdfadc / 0ae7b764 (match §1); line 45 `G2_R_DATA_DIRECTORY=$RDIR/pg-data` (B-2 closed; `RDIR=$PG17_HOME/clusters/r-ready` line 36 = fixture `DATA` parent ✔); lines 74–76 `H=$(git -C "$W" rev-parse --git-path hooks)` with relative-path guard, grep `$H/pre-commit` and `$H/commit-msg` (B-3 closed). Nothing else changed — isolation, once-only sentinel, `flock -n`, B-cluster hash-only/never-start, stop/post checks are the bytes attested in Phase 1.
- I evaluated the new hook expression read-only exactly as the binding will: `H=/home/user/workspace/worktrees/s7-b-drain/.git/hooks`, both files contain `lefthook` → PASS.
- Pins unchanged and still true: BOOTSTRAP 67b77f7a ✔, FIXTURE 6e71d754 ✔, NM_LOCK 05bc530a ✔, NM_CLIENT 7c367454 ✔ (client not regenerated; schema.prisma unchanged in this delta), POSTGRES/INITDB shas ✔ (Phase 1). `bash -n` OK; the only `__` occurrence is the placeholder-refusal pattern itself (line 65).
- `derive-r-pg-proof.py` mirrors both edits (two substitution pairs appended; v1 kept); builder states the runner was regenerated from it then pinned — consistent with the observed diff.

## 5. Hook receipts (appended, not rewritten)
- `receipts/13-closure1-commit.log`: genuine Lefthook v2.1.9 pre-commit — prod-readiness-quick ✔, banned-cast-tokens (R75 --cached, "no positive token change") ✔, prettier ✔, eslint ✔, tsc ✔ (73.60 s); commit-msg no-ai-tokens ✔; `[s7-r-ready 7d2895e] … 2 files changed, 28 insertions(+), 15 deletions(-)`; `COMMIT rc=0 elapsed=74s 2026-09-24T16:35:24Z`.
- `receipts/06-lock.txt` appended: `CLOSURE1 LOCK_ACQUIRED 16:34:10Z pid=21007 purpose=hooked-commit-only` → `LOCK_RELEASED_VERIFIED_FREE 16:35:24Z` (74 s). Commit ts 16:34:10Z falls inside. Receipts 01–12 bytes unchanged except 06 appended; `sha256sum -c RECEIPTS.sha256` 13/13 OK.
- Grant §3 "default Jest": the repo's Lefthook pre-commit does not run Jest; `jest.config.js` `testPathIgnorePatterns` excludes `<rootDir>/test/rls-.*\.spec\.ts$`, and `migration.sql` is read only by the PG proof, so the receipt-11 default-Jest result (3 suites / 90 tests, rc 0 on df36e331) is unaffected by this delta. I concur with the builder; no fresh default-Jest run needed (C, below).

## 6. PRE-R3 launch conditions (observed 16:47Z, read-only)
- `/home/user/pg17/clusters/` = `b-drain`, `b-drain.v4-failed-75a2863b-20260924T151250Z` only; no `r-ready` ✔
- `pgrep -cx postgres` = 0 ✔; port 55471 listeners = 0 ✔; no `r-ready/runtime*` ✔
- `test-validation.lock` free (`flock -n … true` succeeded) ✔
- B cluster `postmaster.pid` absent (Phase 1) — binding re-checks and hashes at preflight ✔
- Disk **3.6 GiB free** (`df -h`), above the grant's 3 GiB floor; below the 4 GiB I suggested in Phase 1. The run's largest writes are the old-root local clone (hardlinked objects, small), the O client generate, and a fresh ~50 MB cluster; B v5 completed within a comparable envelope. Not a blocker; parent's floor governs.

## 7. Findings
- A: none. B: none.
- C-R10: the spec's compile correctness under `jest.rls.config.js`/ts-jest is exercised only at run time (hook tsc covers the tsconfig scope; prettier+eslint covered the staged spec). Identical exposure existed for df36e331 and for accepted B v5; recorded, no work.
- C-R11: disk 3.6 GiB vs my 4 GiB suggestion — recorded; grant floor met.
- C-R1–C-R9 carried per grant; C-R7 left as-is per grant.

## 8. Scope
Source and binding delta only, local disposable PG17 synthetic lane. Not a run result; no PG15 CI, push, deploy or real drain.
