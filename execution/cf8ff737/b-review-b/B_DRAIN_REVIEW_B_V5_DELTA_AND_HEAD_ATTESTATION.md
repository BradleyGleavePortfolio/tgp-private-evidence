# B/drain v5 — Reviewer B (successor) exact-delta, actual-head/hooks/gates and fresh-binding attestation

Reviewer: independent non-builder reviewer B **successor** (session cf8ff737). Requested T4 Fable/High; no runtime telemetry observable, none claimed. Scope: v5 delta vs v4 only, actual receipts, binding applicability. No gate run, no full source re-audit, no runtime, no peer-A material.
Grant read: `execution/cf8ff737/B_V5_MINIMUM_CORRECTION_AND_PHASE_A_GRANT.md`. Builder receipts: `execution/cf8ff737/b-drain/v5/**`.

## 1. Exact delta (independently re-derived from the live repo)

`git diff-tree -r 75a2863b 0d69c7ba` = exactly 2 entries, both `M 100644→100644`:

| Path | v4 blob | v5 blob |
|---|---|---|
| `prisma/migrations/20270119000000_scout_ledger_obsolete_writer_fence/down.sql` | `91e646dd…` | `7deaf700…` |
| `src/scout/scout-ledger-backfill.ts` | `957fb8c6…` | `11d0a3fe…` |

`--numstat` 1/1 each; the complete textual diff is the two authorized lines and nothing else:
```
-      AND t.tgattr::int2[] = '{}'::int2[]
+      AND cardinality(t.tgattr::int2[]) = 0
-      AND t.tgattr::int2[] = '{}'::int2[] AND t.tgnargs = 0 AND t.tgconstraint = 0`;
+      AND cardinality(t.tgattr::int2[]) = 0 AND t.tgnargs = 0 AND t.tgconstraint = 0`;
```
No formatting churn; all other 2152 tree entries (paths, modes, blobs) identical between the two trees — hence the accepted v4 source verdict transfers to every unchanged blob and my review scope is these two predicates. `cardinality()` of a 1-dim zero-length array is 0 (and of a 0-dim array is 0), so the fix is dimension-independent and matches the root cause in my diagnosis note §3. Committed blobs in `gates/06-committed-blobs.txt` match.

## 2. Actual head / identity

- HEAD `0d69c7ba7e7d257311cfcb21fa325ebb1ddc1f1c`, tree `d02f9b124bee52107f8ad2f286f8af611b859fe6`, single parent `75a2863b…` (failed v4 head preserved as history, not erased).
- Author == committer `Bradley Gleave <bradley@bradleytgpcoaching.com>` 2026-09-24T15:28:23Z; message exactly `fix(importer): recognize empty trigger column vectors`; empty body; no trailers.
- Worktree clean (porcelain 0). Detached HEAD (C-6 carried). Bundles: v5-only (requires 75a2863b) and v4+v5 (contains `refs/s7/b-drain-v4-failed` → 75a2863b, requires a0ea1bea) both verify; full-history bundle recorded to the shallow graft.

## 3. Hooks and gates (from `v5/gates/*`, driver `phase-a-v5.sh`, lock held fd9)

- PREFLIGHT_OK 15:27:25Z: env pins reasserted — `.package-lock.json` `05bc530a…`, Prisma client `bf679a16…`, Prettier target `6e922134…` 3.9.6, lefthook 2.1.9, hooks `pre-commit e5723334…` / `commit-msg 29f83d8e…` (identical to v4), 649 entries. STAGED_OK tree `d02f9b12…` (== committed tree).
- Gates: tsc rc0 (45 s), eslint `--max-warnings 0 src/scout/scout-ledger-backfill.ts` rc0, prettier --check rc0 ("All matched files use Prettier code style!"), check-r75 staged rc0 ("OK — no positive token change"), jest `scout-ledger-backfill.spec.ts` + `g2-b-drain-db-guard.spec.ts` 2 suites 42/42 rc0. GATES_OK 15:28:23Z.
- Genuine hook receipts in `05-commit.stderr`: lefthook pre-commit summary ✔️ prod-readiness-quick (no-op, C-3 carried) / banned-cast-tokens / prettier / eslint / tsc (43.7 s); commit-msg ✔️ no-ai-tokens; `05-commit.rc` = 0; COMMIT_OK 15:29:08Z; DONE / STOP stage=done rc0 15:29:09Z.
- eslint/prettier were scoped to the one TS file; `down.sql` is not an eslint/prettier target, and the pre-commit hook's own prettier/eslint filtered both staged files — consistent with v4.

## 4. Fresh filled binding `execution/95633079/s7-b-drain/runtime-v5/binding/b-pg-proof.sh`

- sha `e895b16e…0123`; `BINDING.sha256` 5/5 OK; `bash -n` OK. Sealed template `25eb6837…` and v4 filled binding `a64d24de…` byte-unchanged; `PROPOSAL.v3.sha256` 3/3 OK.
- Diff vs the v4 filled binding is exactly 3 lines: `EXPECT_HEAD`→`0d69c7ba…`, `EXPECT_TREE`→`d02f9b12…`, and `RT=…/runtime`→`…/runtime-v5`. `EXPECT_SPEC_BLOB 9b31fd18…`, `EXPECT_BOOTSTRAP_BLOB b4503eef…`, `EXPECT_FIXTURE_SHA 4525f01d…`, postgres/initdb/node_modules pins, `D=`, port 55461, DB name, roles — all unchanged from v4.
- **RT line (mechanical, necessary, bounded):** `RT` drives only `R/LOG/SENT/JLOG` (l.22) and `G2_B_OLD_ROOT`/`G2_B_OLD_CLIENT` (l.45, l.117). With the original RT the template itself refuses (sentinel "runs once" / `$RT/old-root exists` → 71) and would overwrite the failed run's receipts. It touches no fixture, DB, spec or gate identity; the old-root checkout + O-client generation is simply re-created under `runtime-v5/old-root` by the sealed steps (identity-pinned, ~10 s in v4). Applicable. `runtime-v5/run` and `runtime-v5/old-root` currently absent ✔.

## 5. Smallest named precondition before one run (not yet satisfied)

**PRE-1 — retained v4 datadir collides with the fixed cluster path.** `BDIR=$PG17_HOME/clusters/b-drain` is hard-coded in both the runner (PREFLIGHT l.96: `$BDIR exists → fail 71, fresh init only; never adopt`) and the pinned `b-fixture.sh` (`4525f01d…`, cannot change). `/home/user/pg17/clusters/b-drain` currently EXISTS (76 M, first proof's retained datadir; `postmaster.pid` absent, 0 postgres procs, port 55461 free). As filled, the v5 runner would fail closed at PREFLIGHT rc 71 without touching anything.
Minimum preserving closure (== builder's proposal §3, independently reached): one filesystem rename outside the runner, e.g. `mv /home/user/pg17/clusters/b-drain /home/user/pg17/clusters/b-drain.v4-failed-75a2863b-20260924T151250Z`, with pre/post `sha256sum` of `pg-data/global/pg_control` and `postgresql.conf` recorded in the receipt. No deletion; no binding line change; no fixture-script change. This is a filesystem action outside the builder's owned area and needs to be named in the parent's PG proof grant.
Not acceptable alternatives: editing `BDIR` in the binding (a fourth non-placeholder change to a sealed template) or deleting the failed datadir (history loss).

No other precondition found: S5 cluster absent (runner requires ABSENT), C1 cluster absent (recorded as-is), `925780e0` ancestor check unaffected by the delta, PG tooling still present at pinned sha `23cd1748…` (unchanged since 15:12Z run).

## 6. Findings

- No A. No B against the delta, head, gates, hooks or binding.
- **PRE-1** is a named precondition, not a defect: the runner's own fail-closed refusal already guards it.
- C-6 (detached HEAD) carried; the v4+v5 bundle names `refs/s7/b-drain-v4-failed`, so history is recoverable regardless.
- C-3 carried (prod-readiness-quick no-op). C-12: eslint/prettier scope is the single TS file; SQL is outside both tools — same as v4, correct.

## 7. Disposition

**Reviewer B: v5 delta + actual head `0d69c7ba` + gates/hooks + fresh binding `e895b16e…` ATTESTED. One-run PG proof is GRANT-READY conditional on PRE-1 (single preserving rename of the retained v4 datadir, recorded with hashes).** Run command unchanged in form: `timeout -k 30 3600 bash /home/user/workspace/execution/95633079/s7-b-drain/runtime-v5/binding/b-pg-proof.sh` under the canonical slot. Expected if the fix is correct: 19/19, natural Jest exit, `END rc=0`. I will bind the actual v5 PG result under this same review; not a final pass until then. Nothing landed, deployed or product-accepted.
