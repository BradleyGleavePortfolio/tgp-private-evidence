# S7 addendum: accepted S3 / active S5 source overlap with PR526/528/529 — corrected next-slice decision

Worker `canonical_s7_continuation_map_muei9t11`, parent EXEC-e7d2385c, 2026-09-23 ~19:58 UTC. Source-only; isolated object stores under `s7-mapping/scratch/` (no worktree, no checkout, no hooks, no runtime, no product edit). S5/S6 worktrees untouched. Bundles fetched from the private archive via `gh` at ref `5975c7e7`, hashes verified against the acceptance records before use.

## 0. Correction to the first map

"0 submitted reviews" is public GitHub status only. Private independent review of the PR526/528/529 bytes is not derivable from this worker's inputs and is **UNKNOWN**, not "none exists". `S7_CANONICAL_CONTINUATION_MAP.md` §2/§5 amended in place; §4 superseded by §3 below.

## 1. Inputs (immutable, hash-verified)

| Artifact | Identity | Verified |
|---|---|---|
| Accepted S3 bundle `2026-09-23/6c2a68ac/s3-integration-validation/s3-into-s1s2-be0ba827-from-public-c23b9d9.bundle` | sha256 `d204a582acab8c07ec108ceca5411fa2786756742b1917c89fe76f85195e2d7b`, 273,998 B, head `be0ba8274e486dee77f15d18fe367a13ff08ecf5` tree `a584a1b9…`, requires `c23b9d9f` | = `S3_FINAL_INTEGRATION_ACCEPTANCE.md` |
| S5 bundle `2026-09-21/remediation/s5-r3/b3-pinned-resume/checkpoint-5-B3/s5-r3-candidate.bundle` | sha256 `e42aa021442a8a004bf796e2958461bf79d11c1666fe8fb08ef46dd80bd75b48`, head `143d451ead6ccdbebd92ca3031ba7a89867d6cfc` (ref `execute/20260921-s5-r3`) | = S5 restore report / `PIN_HEAD` |
| PR heads | `925780e0` (525), `881c4c79` (526), `8644715c` (528), `d7404cd4` (529) | live `gh`, unchanged |

Not retrieved: S5 staged tree `756a0d79` (working-tree patch `c36258b3`, 2 test files; not a commit, lives only in the S5 worktree) — irrelevant to product-byte overlap because it touches only `test/rls-g2-pg17-etq0.spec.ts` and `test/utils/g2-pg17-bootstrap.sh`.

## 2. Measured overlap (ancestry + `git merge-tree`)

**Accepted S3 `be0ba827` (47 commits over `c23b9d9f`):**
- Contains PR524 `238f0f1f` and PR525 `925780e0` as ancestors (via S3 candidate `5c7b42b3` = `925780e0` + `fix(health): bound the readiness probe`), merged into S1+S2 successor `d5cd9b8b` (S1: `20261224000000_rls_close_public_exposure` migration/verifier/harness; S2: delivery/CI/release controls, `.github/workflows` ×13, `scripts/release.sh`, Dockerfile).
- Does **not** contain 526, 528 or 529. `merge-base(be0ba827, 925780e0) = 925780e0`.
- Its 49-file delta vs `925780e0` intersects the changed paths of 526/528/529 in **zero** files (`s3-overlap/s3_vs_925780e0.name-status.txt`).
- `merge-tree be0ba827 × d7404cd` → clean (`c02e5121…`); `be0ba827 × 881c4c79` → clean (`d4bba4f1…`).

**Active S5 `143d451e` (32 commits over `c23b9d9f`):**
- **Is exactly PR529 head `d7404cd4` (and therefore PR528 `8644715c` and PR525 `925780e0`) plus 7 test-only commits**: `test/rls-g2-pg17-etq0.spec.ts`, `test/scout/g2-pg17-db-guard.spec.ts`, `test/utils/g2-pg17-{bootstrap.sh,db.ts,harness.ts,old-root.sh}`, and a modification of `test/utils/g2-tq0-worker.cjs`. Zero non-test paths in `d7404cd..143d451e` (`s3-overlap/s5_vs_d7404cd.name-status.txt`).
- So the G2 E and T/Q0 **product bytes already live inside the S5 lane**, byte-identical to the public PR heads; S5's pending fresh51 real proof is the PG17 E→T/Q0 proof of exactly that byte boundary. Does not contain S1/S2/S3 (`d5cd9b8b`, `be0ba827` not ancestors) nor C1.
- `merge-base(be0ba827, 143d451e) = 925780e0`; `merge-tree be0ba827 × 143d451e` → **clean**, tree `0f3a27ff92a9251d9f0733c9c9304aebeb3a8dfc`.

**C1 on the combined S3+S5 tree** (`merge-tree --merge-base=925780e0 0f3a27ff × 881c4c79`) → tree `4a614048…` with **exactly the same two single-line conflicts** as before: `scripts/importer-contract.ts` `CONTRACT_VERSION` (`1.4.1` vs `2.0.0-c1-s1.0`) and `docs/contracts/importer-openapi.json` `info.version`. `prisma/schema.prisma` auto-merges; migrations order `20261224 (S1 RLS) → 20270117 (C1) → 20270118 (E)`, no shared files.

## 3. Corrected next-slice decision

**Foundation = accepted S3 `be0ba827` ∪ S5 lane head.** Integrating 526/528/529 on stale `925780e0` (first map's S7-1) would discard S1's RLS-exposure migration, S2's delivery controls and the `5c7b` health fix, and would recreate substrate S5 already carries. Do not do it.

**Missing delta, precisely:** relative to S3 ∪ S5, the only product bytes not yet present are **C1 (#526, commits `8e25c27b`, `881c4c79`; 18 files, `src/extension-pair/**`, `ImportIntent` schema + `20270117000000_durable_import_setup`, `test/rls-c1-setup.spec.ts`, contract paths/DTOs)** plus the **one-constant contract-version reconciliation** and one re-pinned assertion in `test/contracts/importer-contract.spec.ts`. Nothing else.

| # | Slice | Tier | Owner | Frozen acceptance | Depends on |
|---|---|---|---|---|---|
| S7-1′ | **Compose foundation**: one local two-parent merge of accepted `be0ba827` and the actual S5 true-hooked head (successor of `143d451e`+`756a0d79`, once S5 07R–10 commits). Predicted textually clean (measured clean at `143d451e`; the 2-file staged S5 patch is test-only and outside S3's paths). No authored change. | T4 | one builder (S5's, after its commit) — parent assigns | `merge-tree` clean, tree == predicted modulo S5's final 2 test blobs; true hooks; Bradley identity; targeted suites only where bytes changed: none beyond S3's 31/825 + S5's own list; **no new real-PG run** — S5 fresh51 proves E/T-Q0, S3 composed 72/68/48 proves S1/S2 | S5 hooked head + its two exact-head reviews; S6 slot release |
| S7-2′ | **C1 onto foundation + generator reconciliation**: merge `881c4c79` onto S7-1′; resolve only the two version lines to one forward-2.x prerelease that subsumes the 1.4.1 cursor-limit repair; re-pin one assertion; regenerate artifact once (`contract:importer`); nothing else. | T4 (persisted generated contract, identity schema) | **sole schema/generator owner** (still unassigned — parent must assign) | conflicts == exactly the two measured lines; drift test byte-equal; targeted: `test/contracts/importer-contract.spec.ts`, `src/extension-pair/__tests__/*`; **one** real-PG run of `test/rls-c1-setup.spec.ts` only (C1's own, never run in any accepted lane; not E/T-Q0 again); two independent exact-head attestations | S7-1′ |
| S7-3′ | **G2 B/drain** — first genuinely new product stage (bounded resumable NULL→platform backfill + obsolete-writer fence, own migration, own real-PG spec), on S7-2′ | T4 | separate G2 builder (`src/scout/**` only) | preserves E/T semantics and both narrow indexes; separately promotable | S7-2′ (single schema lineage) |

Removed: the first map's S7-2 "real-PG proof of E/T-Q0 on the integrated head" — a double proof of the byte boundary S5 fresh51 already covers. Retained proof obligations after S7-2′: C1's `rls-c1-setup` once; everything else transfers.

## 4. Findings and decision

No new A/B. Class C recorded: (i) first map's stale-base slice withdrawn before dispatch (no work lost); (ii) private `g2-pg17` harness is the E/T-Q0 proof of record; public `rls-g2-ledger-expand`/`rls-g2-tq0` specs remain in the tree as source but are not scheduled to run (no double proof). Bradley decision required: **NO** — local, reversible composition and one already-existing feature slice; landing/deploy, retention/erasure and revocation semantics stay reserved as before.

Files: `s3-overlap/` (bundles, `bundle.sha256`, `s3-validation-REPORT.md`, name-status lists, four `merge-tree.*.txt`), `scratch/backend-s5` (full-blob isolated store with refs `refs/s7/s5-143d451e`, `refs/s7/s3-be0ba827`), `scratch/backend-ro` (blob-filtered store, `refs/s7/s3-be0ba827`).
