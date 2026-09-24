# B/drain v5 — actual-head / hooks / gates / fresh-binding attestation (reviewer A, successor; same review)

Read-only recomputation against the live worktree, `execution/cf8ff737/b-drain/v5/**`, `execution/95633079/s7-b-drain/runtime-v5/binding/**`, and the host paths the template checks. No gate run, no PG start, no source re-audit, no peer B. Fable/High requested only; no telemetry claimed. Observed 15:31–15:36Z.

## 0. Disposition
**Head `0d69c7ba7e7d257311cfcb21fa325ebb1ddc1f1c` is BOUND as the v5 minimum correction: tree `d02f9b12…` (== the delta I bound in `B_DRAIN_V5_DELTA_BINDING_A.md`), parent `75a2863b…`, Bradley identity, pinned message, genuine hooks, granted gates all rc 0. The fresh filled binding is the five pin lines plus exactly one mechanical `RT=` line, which I dispose as necessary and bounded. A new one-run PG grant is READY from reviewer A's side with a single named precondition: the stopped first-proof cluster directory must be preserved-by-rename out of `$BDIR` immediately before the run, inside the grant, with pre/post hashes receipted.** No A/B finding open.

## 1. Commit — recomputed from the object
| Field | Observed |
|---|---|
| HEAD / tree / parent | `0d69c7ba…` / `d02f9b124bee52107f8ad2f286f8af611b859fe6` / single parent `75a2863b…` (v4-failed head retained in history, not rewritten); no `MERGE_HEAD` |
| author / committer | both `Bradley Gleave <bradley@bradleytgpcoaching.com>` 1790263703 +0000 |
| message | `fix(importer): recognize empty trigger column vectors` == `v5/commit-message.txt`; no trailers/AI tokens |
| `diff-tree -r 75a2863b HEAD` | exactly 2 `M` entries: `down.sql 91e646dd→7deaf700`, `scout-ledger-backfill.ts 957fb8c6→11d0a3fe` (== my precomputed blobs) |
| unchanged pins at HEAD | spec `9b31fd18…`, bootstrap `b4503eef…`, old-root helper `b9080538…`; O `925780e0` is ancestor; porcelain 0 |
| hooks | existing shims (`e5723334…`/`29f83d8e…`) verified by hash, not reinstalled; `05-commit.stderr` shows `call_lefthook run pre-commit` → ✔ prod-readiness-quick, banned-cast-tokens, prettier, eslint, tsc (43.7 s) and `run commit-msg` → ✔ no-ai-tokens; commit rc 0 |
| bundles | v5-only (`requires 75a2863b`), v4+v5 from `a0ea1bea` (ref `refs/s7/b-drain-v4-failed` preserved), full-history to graft `c23b9d9f` — all `is okay` |

## 2. Gates (receipts, no rerun)
Env reasserted (`.package-lock.json 05bc530a…`, client `bf679a16…`, Prettier 3.9.6 `6e922134…`, Lefthook 2.1.9); staged exactly the 2 paths, write-tree `d02f9b12…`. `tsc --noEmit -p tsconfig.json` rc 0; `eslint --max-warnings 0` and `prettier --check` on the one changed TS file rc 0 (C: staged-scope is correct — the other 7 TS blobs are byte-identical to the v4 blobs already gated at 15:03Z; the hooks additionally re-ran prettier/eslint on staged files); `check-r75 --mode=staged` rc 0; jest 2 suites / **42 passed / 42 total** rc 0. Sentinel `RC=0 STAGE=done END=15:29:09Z LOCK=released-on-exit`; no survivors; slot observed free at 15:35Z.

## 3. Fresh filled binding (`runtime-v5/binding/b-pg-proof.sh`, sha `e895b16e…`)
Diff vs sealed template `25eb6837…` (verified unchanged): the five pin lines (`EXPECT_HEAD=0d69c7ba…`, `EXPECT_TREE=d02f9b12…`, spec/bootstrap/fixture pins unchanged `9b31fd18…`/`b4503eef…`/`4525f01d…`) **plus one line**:
`RT=…/s7-b-drain/runtime` → `RT=…/s7-b-drain/runtime-v5`.
Disposition: **necessary and bounded.** The template refuses to run twice under one `RT` (`$SENT exists` → exit 76; `$RT/old-root exists` → PREFLIGHT_FAIL 71) and would otherwise overwrite the immutable first-run receipts. `RT` feeds only `R=$RT/run` and `G2_B_OLD_ROOT/G2_B_OLD_CLIENT`; `D=`, `BDIR`, `PORT 55461`, `DBNAME`, stage order, bounds and jest arguments are unchanged (confirmed by my own full diff — 12 changed lines total). Consequence accepted: the old-root checkout + O-client generation is re-created under `runtime-v5/old-root` by the sealed steps; the template's once-only rule means "reuse where identity permits" resolves to no reuse without a template change, which would be the larger deviation. `bash -n` OK; the only remaining `__` is the placeholder-refusal `case`. First-run `runtime/{run,old-root,binding}` mtimes 15:14:50Z or earlier — untouched.

## 4. Second-run host preconditions (observed now)
- PG dist `postgres 23cd1748…`, `initdb b7db9bc2…` present; `/usr/bin/psql` present; port 55461 free; 0 postgres procs; O ancestor true; S5 cluster absent.
- **Blocking precondition (named):** `/home/user/pg17/clusters/b-drain` exists (stopped first-proof cluster: `pg-data`, no `postmaster.pid`). Template line 96 `PREFLIGHT_FAIL $BDIR exists` and the pinned `b-fixture.sh` (`4525f01d…`, hardcoded `DATA=…/b-drain/pg-data`, refuses if present) would both stop the run at rc 71/72. Minimum closure = the builder's proposed single rename `mv /home/user/pg17/clusters/b-drain /home/user/pg17/clusters/b-drain.v4-failed-75a2863b-20260924T151250Z` (no deletion; record pre/post sha256 of `pg-data/global/pg_control` and `postgresql.conf`). Alternatives (changing `BDIR` in the template, or unsealing the fixture) are larger deviations and are not recommended. The path is outside the builder's owned areas, so the action must be authorised inside the PG grant and executed immediately before the run, then receipted.

## 5. Grant readiness
READY for a separate single-run grant: `timeout -k 30 3600 bash execution/95633079/s7-b-drain/runtime-v5/binding/b-pg-proof.sh`, one run, no retry, preceded within the grant by the §4 rename. Expected: F1–F4, F6, F7 resolve directly and F5, F8 as cascades; any residual failure is new evidence and stops honestly. Reviewer A will then bind `runtime-v5/run/{RECEIPTS.sha256,b-pg-proof.log,jest.log,sentinel}`, the 19-test summary, stop/no-survivor state, and the rename receipt under this same review.

## 6. C items (record, continue)
- eslint/prettier staged-scope on 1 file (§2) — correct scope, no gap.
- Old-root re-creation cost (~minutes) accepted over a template change.
- Retained first datadir is preserved, not deleted, by the rename; nothing about the failed run is rewritten.

Files: this note; `MANIFEST.sha256` updated.
