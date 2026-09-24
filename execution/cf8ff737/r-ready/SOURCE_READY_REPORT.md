# R identity-ready — SOURCE-READY report (T4 R builder → parent)

Status: **SOURCE-READY; WAITING for parent heavy-slot relay.** Brief §9 steps 1–5 complete; no gate, test, commit,
lock, or database action has been taken. Fable/High was requested for this builder; no telemetry is claimed.

## Done (receipts under `execution/cf8ff737/r-ready/receipts/`)
- `01-worktree-add.txt` — `worktrees/s7-r-ready` (branch `s7-r-ready`) added from accepted B head `0d69c7ba…` via `git -C worktrees/s7-b-drain worktree add`; s7-b-drain never written (porcelain clean, re-verified now).
- `02-deps-copy.txt` — independent `cp -a` of B's node_modules (no hardlinks; ≥3 GiB check passed; 4.7 GiB free now).
- `03-prisma-generate.txt` — R-only `prisma generate`; client `index.d.ts` sha `7c367454…` (differs from B's `bf679a16…`).
- `04-source-authored.md` — full file table with sha256s, D1–D4 application, C qualifications.

## Uncommitted R slice in `worktrees/s7-r-ready` (all within grant-permitted paths)
Modified: `prisma/schema.prisma`, `src/scout/scout-ingest.dto.ts` (D2 `IsCanonicalPlatformToken`), `test/scout/scout-ingest.validation.integration.spec.ts`.
New: `prisma/migrations/20270120000000_scout_identity_ready/{migration.sql,down.sql}`, `test/rls-g2-r-ready.spec.ts` (R01–R12),
`test/scout/g2-r-ready-db-guard.spec.ts`, `test/utils/g2-r-ready-{db.ts,pg-harness.ts,harness.ts,bootstrap.sh}`.
Guard identity uses `cardinality(t.tgattr::int2[]) = 0` (never `= '{}'::int2[]`). Fence retained (D3). Contract JSON NOT regenerated
(generator has no CLI plugin encoding the DTO rule; `docs/contracts/importer-openapi.json` byte-identical to HEAD) — C, recorded.
All B/S5 donor files verified blob-identical to HEAD.

## Pre-drafted while waiting (source-only, `execution/cf8ff737/r-ready/binding/`)
`r-fixture.sh`, `r-pg-proof.sh` (5 pins left as `__FILL_AFTER_COMMIT__`, refused by the script), `derive-r-pg-proof.py`,
`r-pg-proof.sh.diff-vs-b-v5`, `README.md`. Adds two read-only checks over B v5: B files blob-identical at R head; stopped
B cluster hashed/unchanged/never started. Not run.

## On relay, in order (first nonzero stops; receipts → `r-ready/receipts/05-…`)
1. `tsc --noEmit` (project config) 2. eslint on the two paths 3. `prettier --check` on slice files 4. `check-r75`
5. default Jest: `test/scout/g2-r-ready-db-guard.spec.ts`, `test/scout/scout-ingest.validation.integration.spec.ts`
   (+ `test/contracts/importer-contract.spec.ts` as cheap C1-surface evidence).
6. Ordinary hooked commit, author+committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no trailers, no amend, no push.
7. Fill pins → `PINS.txt`, `BINDING.sha256` → dual actual-head/binding attestations → request separate single-run PG grant.

## Known risk
TypeScript has not been type-checked yet (no runtime permitted pre-relay); a tsc/eslint nonzero would stop and be reported, not retried.
