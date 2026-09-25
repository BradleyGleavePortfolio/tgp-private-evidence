# S8C-BC-3 harness correction — receipt (INTERIM: steps 1–3 done, step 4 withheld for disposition)

Builder `s8c_bootstrap_completion` (T4) under S8C-BC-3 (class B harness-only closure, SCOPE.md 16:56Z). Evidence repo NOT
committed by the builder (parent publishes). Nothing rerun, amended, bypassed or force-pushed.

## 1. Harness fix (one file, one function)
- Static sweep of all raw SQL in S8-C test support: `STATIC_SWEEP.md` (`15c0cc03…`). Authoritative confirmation: diagnostic (a).
- Only omission: `ExerciseCatalogItem.updated_at` in `catalog()` (`test/utils/g2-s8c-harness.ts:113`). Fix: add `updated_at`
  to the column list and `now()` to VALUES, with a doc-comment. `harness.patch` `1a23604a…` (+8/−3). No product/schema/
  migration/spec-assertion change.

## 2. Diagnostics (non-accepting) — `diagnostic/FINDINGS.md`
- (a) rc=0: information_schema after 171 migrations confirms the single omission (27 required columns across the 5 tables).
- (b) jest rc=1 at the corrected clean head: **10 passed / 3 failed**; the `beforeEach` defect is closed; three further defects
  F1–F3 are outside the harness file and outside this grant (spec observation role; spec float-exactness assertion vs Prisma
  Float round-trip; spec `count('User')` vs the accepted seed migration's system coach). Details and closure candidates there.

## 3. Commit (gate `s8c-harness-gate.sh` `5202d87d…`, log `run/s8c-harness-gate.log` `60b30f42…`)
- Slot: ACQUIRED 17:03:27Z (flock -n, inode 674373, lslocks=1, postgres 0) → RELEASED 17:04:17Z.
- Pre: HEAD = `e0cee7e0…`, delta exactly `test/utils/g2-s8c-harness.ts`, +8/−3 (`run/delta-from-e0cee7e0.1file.patch` `8f604d31…`).
- Scoped prettier 3.9.9 (`recovery-reset/s8c/tools/prettier-3.9.9`, offline) `--check` rc=0; scoped eslint `--max-warnings 0` rc=0.
- `git commit -F commit-message.txt` (`5a3b4a3d…`) rc=0 with genuine lefthook hooks (`run/commit.raw.log` `f99c72e9…`):
  pre-commit prod-readiness-quick ✔, banned-cast-tokens ✔, prettier ✔, eslint ✔, tsc ✔ (46.17 s); commit-msg no-ai-tokens ✔.
  No trailers; author/committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`.
- **HEAD `9cc764013fd1d726dad082eebfa7def50800a6b2`**, parent `e0cee7e04bef88811310f6dde1fd921f45d103ad`,
  **TREE `820836142812caa98f035f6e0856ce2b71f0692f`**, changed blob `test/utils/g2-s8c-harness.ts`
  `d5cbf877…` → **`1a8f17970a1095f9b802badacf093e773caabd76`**; `git diff --numstat e0cee7e0 HEAD` = one file +8/−3; porcelain 0.

## 4. Checkpoint v7 / binding v5 / run-prep v5 — WITHHELD
Not produced: binding `9cc76401…` would fail PG-4c 3/13 (F1–F3). Producing v7/v5 now would consume the binding number on a
head that must change if the parent grants a spec-side closure. Awaiting parent disposition; the mechanical v4→v5 derivation
(proof-v5 paths, head/tree/blob/fixture pins, PINS.txt L57 fix, `S8C_PG5_GRANT` supervisor) is ready to run against whichever
head is final.

## Slot times (all `flock -n`, yielded to none because none held; S7-L END observed 17:00:22Z before the first acquire)
| hold | acquired | released | purpose |
|---|---|---|---|
| 1 | 17:02:44Z | 17:02:53Z | diagnostic (a): initdb + bootstrap + catalog query + stop |
| 2 | 17:03:27Z | 17:04:17Z | gate: prettier/eslint/hooked commit |
| 3 | 17:04:52Z | 17:05:44Z | diagnostic (b): RLS suite on scratch lane + stop |

Post-state after each: 0 holders, 0 postgres, 55641/55642/55644 free, scratch pg-data retained without `postmaster.pid`,
retained v4 pg-data untouched (no `postmaster.pid`), worktree porcelain 0.

## Recorded operational notes (no evidence altered)
- First gate launch attempt failed at the shell redirect (`run/` did not exist yet); no gate process started, no log written,
  no lock touched; `run/` was created and the gate launched once (this is the recorded run).
- `diagnostic/a|b/RECEIPTS.sha256` hash their own log before its final END line (driver pattern); complete-file hashes are in
  `diagnostic/FINDINGS.md`.
