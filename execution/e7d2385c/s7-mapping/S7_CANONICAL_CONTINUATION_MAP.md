# S7 canonical continuation map (source-only)

Worker `canonical_s7_continuation_map_muei9t11`, parent EXEC-e7d2385c, 2026-09-23 ~19:45 UTC. Requested Claude Fable 5 / High (requested setting, not observed runtime identity). Read/hash/diff only; nothing built, run, installed, edited or pushed. Sole writes: `execution/e7d2385c/s7-mapping/**`. Source retrieved via `gh` at immutable SHAs into `retrieved/`; a synthetic merge was computed with `git merge-tree` in an isolated no-checkout clone under `scratch/` (no worktree, no product edit).

## 1. Exact pointers (all verified live 2026-09-23; identical to intake grade register)

| Item | Head / tree | Base | State on GitHub |
|---|---|---|---|
| PR525 shared base | `925780e0a1906593e5383c618311b6b17364b8dc` | `238f0f1f…` (#524) | draft, 0 reviews |
| PR526 C1-S1 | `881c4c791727adef8d423931e1cca83a0ffbb9c9` (2 commits: `8e25c27b`, `881c4c79`) | 925780e0 | draft, 0 reviews, all listed checks SUCCESS, deploy gate SKIPPED |
| PR528 G2-E | `8644715c429e7dde1dfeb71f7ad42b1bd9121eaf` (1 commit) | 925780e0 | draft "WIP unreviewed", 0 reviews, checks SUCCESS |
| PR529 G2 T/Q0 | `d7404cd49578647cf72bb633819d8e86ffc3da3a` (commits `8644715c`, `fdbbaefb`, `d7404cd4`) | 8644715c | draft, 0 reviews, checks SUCCESS |
| merge-base(526,529) | `925780e0` — all three share one base; no rebase needed | | |
| Synthetic 3-way tree 529×526 | `bdf57ec63bc01445c4bd97e546fbbb314ea19008` (contains conflict markers; evidence only, not a candidate) | | |

Shared-file hashes (sha256) at each head: `retrieved/SHA256SUMS`. Backend main remains `c23b9d9f…` (auto-deploys; not touched).

## 2. Reuse map — implementation exists / reviewed-proven / missing

**Exists as source (PR heads), CI-green; public review status: 0 submitted GitHub reviews, all drafts. Private independent review status of these exact bytes is UNKNOWN to this worker (not asserted as absent). Correction 2026-09-23 19:55Z; see `S7_OVERLAP_ADDENDUM.md` — S5 `143d451e` in fact contains PR528/529 exactly, so E/T-Q0 bytes are inside the active S5 lane:**
- C1 (#526): `ImportIntent` model + `ExtensionPairCode.import_intent_id` composite FK, migration `20270117000000_durable_import_setup` (+down that fails closed under RLS), idempotent `pair/init` with `setup_nonce` (409 `setup_nonce_conflict`, 410 `setup_challenge_unavailable`), new bearer-only `POST pair/current` and `pair/session`, `import_intent_id` echoes on init/status/redeem, real-PG `test/rls-c1-setup.spec.ts`, contract prerelease `2.0.0-c1-s1.0`.
- G2 E (#528): nullable `ScoutReconstructionLedger.source_platform`, migration `20270118000000_scout_ledger_platform_expand` (+refusing down), real-PG `test/rls-g2-ledger-expand.spec.ts`. No API/DTO change.
- G2 T/Q0 (#529 on E): transactional provenance claim in `scout-reconstruct.service.ts`, `scout-platform.ts` token grammar, `scout-cursor.ts` legacy+v2 cursor decode (still emits legacy), cursor `maxLength` 512→8192 on `/scout/reconstruct/{entities,roster}`, contract `1.4.1`, real-PG `test/rls-g2-tq0.spec.ts`.

**Reviewed/proven and to be preserved, not re-audited:** S1–S4 local acceptances (`56fb0d22`, `d5cd9b8b`, `be0ba827` tree `a584a1b9`, `91990ae9`) per `S3_FINAL_INTEGRATION_ACCEPTANCE.md`. These heads are local-only (GitHub returns 422 for all six lane SHAs); their bytes live only in private bundles. Whether S1–S3 already carry any E/T-Q0 or C1 product bytes is a parent-held check against the private bundle, not derivable from remote. Observed hint: S5 head `143d451e` patches `test/rls-g2-pg17-etq0.spec.ts` and `test/utils/g2-pg17-bootstrap.sh`, which exist on no public ref — so a second, private E+T/Q0 real-PG proof lineage exists alongside the public PR528/529 specs (`rls-g2-ledger-expand`, `rls-g2-tq0`, PG18.6-local / PG15-disposable). Reuse decision, not defect: pick one proof harness per stage; do not run both.

**Missing (no implementation anywhere inspected):** G2 B/drain, R, N/Q1 (v2 cursor emission + legacy-boundary resolution), C; server-accepted Start/cancel/deadline, execution epoch/commit fencing; extension-connection disconnect/revocation and in-flight refresh fencing; source principal/workspace attribution; intent-required review requests / single generated response schema for mobile drift; native writers, relationships, reconciliation; retention/erasure and code-retirement policy (C1 doc names these activation blockers).

## 3. Actual C1/G2 generator collision (measured, not inferred)

`git merge-tree d7404cd 881c4c7` → exactly **two** content conflicts, both a single line:
1. `scripts/importer-contract.ts` L43–46: `CONTRACT_VERSION = '1.4.1'` (T/Q0) vs `'2.0.0-c1-s1.0'` + comment (C1). C1's `IMPORTER_BARE_PATHS` additions (`/extension/pair/session`, `/current`) auto-merge.
2. `docs/contracts/importer-openapi.json` `info.version` line. All other artifact hunks are disjoint (C1: 3 new schemas, 2 new paths, 4 changed pair schemas; T/Q0: 2 cursor params) and auto-merge — but this file is generated, so the real resolution is one regeneration, never a hand merge.
Everything else auto-merges: `prisma/schema.prisma` (C1 hunks at ~L237/L6737–6775, E hunk at ~L6917; merged tree contains both `model ImportIntent` and `source_platform String?`), migrations order 20270117 (C1) → 20270118 (E) with no shared files, `src/extension-pair/**` vs `src/scout/**`, disjoint tests/utils. Also affected: C1's `test/contracts/importer-contract.spec.ts` pins `contract.info.version === '2.0.0-c1-s1.0'` — one assertion to re-pin. So the "collision" is a one-constant version-lineage decision (1.4.x patch line vs forward-2.x prerelease), owned by the sole generator owner; T/Q0's own decision doc already says "sibling lifecycle contract versions require deliberate integration reconciliation." Class C: record and resolve inside the next slice; nothing blocks.

## 4. Smallest next executable product slices (graded before build)

**SUPERSEDED by `S7_OVERLAP_ADDENDUM.md` §3** (S7-1 must sit on accepted S3 + S5, not on stale `925780e0`; S7-2 double proof removed). Original table retained for provenance:

| # | Slice | Tier / why | Owner | Frozen acceptance | Depends on |
|---|---|---|---|---|---|
| S7-1 | **Generator/contract reconciliation candidate**: one local integration head of `d7404cd` + `881c4c7` on shared base `925780e0`; resolve only the two version lines to one forward-2.x prerelease that subsumes the 1.4.1 cursor-limit repair; re-pin the single version assertion; regenerate artifact once via the existing `contract:importer`; no other source change | T4 (persisted generated contract, identity/lifecycle schema) | newly assigned **sole schema/generator owner** (currently "reserved, no mutation owner" — parent assignment required) | merge conflicts == exactly the two predicted lines; regenerated artifact byte-equal (drift test); targeted suites only: `test/contracts/importer-contract.spec.ts`, `src/extension-pair/__tests__/*`, `test/scout/**` incl. `scout-cursor.spec.ts`; true hooks; Bradley author/committer; two independent exact-head attestations | S6 runtime slot release (uses the single heavy slot); no S1–S4 rerun |
| S7-2 | **Real-PG proof of the integrated head**, one harness: run `rls-c1-setup`, `rls-g2-ledger-expand`, `rls-g2-tq0` once against the S7-1 head on the disposable cluster already used by S2/S3 (PG17) — or explicitly adopt the private `g2-pg17-etq0` lineage if the parent confirms it covers the same bytes; never both | T4 | same builder; two nonbuilder reviewers | raw0 per spec, explicit disposable-DB guard satisfied, no fallback to app DB URLs; existing S2/S3 real-PG evidence transfers, not repeated | S7-1 head frozen; parent harness decision (§2 hint) |
| S7-3 | **G2 B/drain** (next unbuilt canonical stage): bounded resumable NULL→platform backfill + obsolete-writer fence, on top of S7-1 | T4 | separate G2 builder (disjoint `src/scout/**`, new migration only) | preserves E/T semantics and both narrow indexes; separately promotable artifact; own real-PG spec; original 21 recovery cases remain a donor, not a claimed result | S7-1 (needs single schema lineage); not S7-2 completion |

Do **not** start: mobile/extension consumer coding against the unfrozen contract (plan: "no M5 or extension-intent consumer coding begins against an unfrozen C1 contract"), Start/cancel/deadline or revocation design (G3 auth-owner freeze), any new safety/validator layer.

## 5. Dependency, ownership and frozen-acceptance checks

- All three PRs sit on `925780e0` (#525, itself a draft on #524 on main). Landing order remains #524 → #525 → (E → T/Q0 …) and C1; local integration does not imply any push/merge (backend main auto-deploys → later authority boundary, unchanged).
- Ownership: C1 = `src/extension-pair/**`, `test/rls-c1-*`; G2 = `src/scout/**`, `test/rls-g2-*`, `test/utils/g2-*`; shared = `prisma/schema.prisma`, `prisma/migrations/*`, `scripts/importer-contract.ts`, `docs/contracts/importer-openapi.json`, `test/contracts/importer-contract.spec.ts` → shared files need exactly one mutation owner (S7-1). #522 stays blocked/overlapping; #527 policy donor untouched.
- Frozen acceptance preserved: S1–S4 heads/seals unchanged and not re-read; S5 (`143d451e`+`756a0d79`) and S6 (`d51a1910`+`20c6594c`, 698cf631/15) remain their own lanes; S7 consumes the runtime slot only after S6/S5 release.
- Evidence that remains applicable: PR526/528/529 CI SUCCESS on exact heads (ordinary lane; note E doc: root `rls-*` specs are excluded from default Jest and hosted helper jobs, so CI green ≠ real-PG proof); S2/S3 real PG17 composition and disposable-cluster substrate (transferable harness, not a rerun); S3's 31/825 targeted pass at `be0ba827` (unchanged bytes). Evidence that does not transfer: any *public* acceptance of 526/528/529 bytes (none submitted on GitHub); private review of the same bytes via the S5 lane is the parent's record, not this worker's claim.

## 6. Findings

No new Class A or B finding. Class C (record/continue): (i) version-lineage collision above; (ii) two parallel E/T-Q0 real-PG proof lineages (public spec set vs private `g2-pg17-etq0`), choose one; (iii) 528 title still says "WIP unreviewed" — accurate, no action. Incomplete review of 526/528/529 is a missing execution step, not a discovered product defect.

**Bradley decision required: NO** for S7-1..S7-3 (local, reversible, no landing). Reserved for later, already-known boundaries only: retention/erasure and pairing-code-retirement policy before C1 activation; any main merge/deploy/flag; G3 revocation semantics freeze by the auth owner (design, not yet a Bradley call).
