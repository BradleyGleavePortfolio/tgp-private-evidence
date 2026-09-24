# R (G2-R identity-ready) — source authored, receipt 04

Worktree: `/home/user/workspace/worktrees/s7-r-ready` (branch `s7-r-ready`, base `0d69c7ba7e7d257311cfcb21fa325ebb1ddc1f1c`).
State: UNCOMMITTED working tree; NO gate, test, DB, or commit has run. Nothing under the heavy slot.
`git -C worktrees/s7-b-drain status --short` = clean (B worktree untouched).

## Files (sha256 of working-tree content)

| Path | Kind | sha256 |
|---|---|---|
| prisma/migrations/20270120000000_scout_identity_ready/migration.sql | new | 4d1188ea35f17abd8a3c429d7f406ac09abce792fb9d544d0c2f51ae28214cfe |
| prisma/migrations/20270120000000_scout_identity_ready/down.sql | new | 229670440ded04ba39b609cd193d276f632152388fa0377d68e27283ef700caa |
| prisma/schema.prisma | modified (+8 lines: two `@@unique` wide keys with `map`, comments; ledger `source_platform String?` retained = D1) | c8ce00f727c8aa98ee8ce58127d26c7850a0410602e8ebdc2776a2853f51d9d7 |
| src/scout/scout-ingest.dto.ts | modified (D2: `IsCanonicalPlatformToken` via `ValidateBy`/`buildMessage` delegating to `isCanonicalPlatform`; applied to `sourcePlatform`; `@ApiProperty` unchanged) | 4c0032851c8ca1c6c2b747e30d592bfce4935ad8c4f078e2955e8b443f0582ed |
| test/scout/scout-ingest.validation.integration.spec.ts | modified (+2 HTTP cases through the production pipe; +1 DB-free parity table vs `isCanonicalPlatform`, 32 inputs incl. `\n`, `\r\n`, NUL, length 256/257, non-strings) | 02593b241806294486e6e4276774e007fb6fdec090a6cc0c7c2942a0101b642c |
| test/utils/g2-r-ready-db.ts | new (from g2-b-drain-db.ts by substitution; +`'55461'` in REFUSED_PORTS) | ed58d88ff14df6921e4cc6810bbb90e187b916f8b1c7042c0bcd090991bff1ff |
| test/utils/g2-r-ready-pg-harness.ts | new (substitution only + header) | a1e06351166ace37212edd25cac2b21b6c8b603661051f519739e7cc449bfcde |
| test/utils/g2-r-ready-harness.ts | new (substitution + R_MIGRATION/rUpFile/rDownFile/rUp/rDown, WIDE_COLUMNS, CANONICAL_CHECK, `wide()`, `narrow()`) | 275c8099dca6382f02a863cd0e69c2c5e497482eac66f76abf55a9f876005dfc |
| test/utils/g2-r-ready-bootstrap.sh | new (substitution; step 7 also verifies both `*_identity_key` maps in the generated client) | 42e04338233e5e81304a2e73392767d092e832e2799fc605d18427dbe0421ec7 |
| test/scout/g2-r-ready-db-guard.spec.ts | new (port 55471; refuses 55461, `g2_b_drain_disposable`, `b_super`; marker regex `^r-`) | 32db8383772e364e250094d3aafc84560d462d38ac60bb97c71a2cce35f5f1b7 |
| test/rls-g2-r-ready.spec.ts | new (598 lines pre-format; R01–R12 in 5 stages) | 5ea2a5fdf845f98c65bbe508cd9e3289a9e50488719795677a2f4b441dd45d6c |

Byte-identical to HEAD (git hash-object == HEAD blob): g2-b-drain-db.ts, g2-b-drain-pg-harness.ts, g2-b-drain-harness.ts, g2-b-drain-bootstrap.sh, g2-b-drain-db-guard.spec.ts, rls-g2-b-drain.spec.ts, g2-pg17-db.ts, g2-pg17-harness.ts, g2-pg17-bootstrap.sh, g2-tq0-worker.cjs, docs/contracts/importer-openapi.json.

Substitution map applied (sed, then targeted edits): `g2-b-drain→g2-r-ready`, `g2_b_drain→g2_r_ready`, `G2_B_→G2_R_`, `g2BDrainTestTarget→g2RReadyTestTarget`, `b-disposable-pg17→r-disposable-pg17`, `b-g2-drain-synthetic-disposable-fixture-safe-to-drop→r-g2-ready-synthetic-disposable-fixture-safe-to-drop`, `b_super→r_super`, `B/drain G2 proof→R/ready G2 proof`, `g2b_→g2r_`.

## Decisions as implemented

- D1: ledger `source_platform String?` retained in schema.prisma; DB NOT NULL from R on; drift recorded as informational in the schema comment.
- D2: minimal custom class-validator decorator delegating to `isCanonicalPlatform` (no regex restated, no normalization); `@ApiProperty` untouched. Contract NOT regenerated: `scripts/importer-contract.ts` builds from the swagger document only (no CLI plugin in nest-cli.json), so class-validator rules are not encoded and `docs/contracts/importer-openapi.json` is unchanged (verified blob-identical). C1 pair surface: zero bytes changed.
- D3: fence retained; migration guard requires it exactly (`cardinality(t.tgattr::int2[]) = 0`, per grant); down leaves it.
- D4: base = accepted B v5 head 0d69c7ba only.

## Migration semantics (migration.sql)

Envelope: BEGIN; SET LOCAL lock_timeout 5s / statement_timeout 30s; LOCK both tables ACCESS EXCLUSIVE. Guards in order: narrow keys exact (`G2-R unexpected identity prerequisite`), E column shape / staging column shape (`G2-R unexpected platform column prerequisite`), fence exact (`G2-R fence absent`), none of the four R names present anywhere (`G2-R wide identity already present`), no NULL (`G2-R unresolved NULL provenance`), ledger canonical (`G2-R noncanonical provenance`), staging canonical (`G2-R noncanonical staged provenance`). Then SET NOT NULL, two CHECKs `source_platform COLLATE "C" ~ '^[a-z0-9][a-z0-9._:-]{0,255}$'`, two wide UNIQUE indexes. down.sql: same envelope; requires narrow keys intact and R exactly as shipped (else `G2-R unexpected identity prerequisite` / `G2-R wide identity absent`); drops the two CHECKs, two wide indexes, DROP NOT NULL; rows/values/narrow/fence retained; raw rerun refused.

## C qualifications (record / continue; no new work created)

1. Generated client `node_modules/.prisma/client/schema.prisma` differs from `prisma/schema.prisma` only by Prisma's formatter (column alignment, attribute order); both `*_identity_key` maps present; `index.d.ts` sha unchanged since receipt 03 (7c367454…).
2. Local R12 restores the catalog shape by catalog observation with OIDs stripped (`shape()`), not `pg_dump -s`; the harness binding carries no pg_dump path and the system pg_dump version is unverified against the PG17 server. CI `migration-dry-run` remains the `pg_dump -s` parity evidence.
3. `pg_get_constraintdef` rendering is compared with parentheses stripped (tokens exact); the exact parenthesization is not part of the contract.
4. `prettier --write` was run once on the slice-owned files as an authoring step (not a gate; `prettier --check` remains a relayed gate).
5. Bootstrap step 7 (the R client check) is script logic only until the runtime grant.

## Awaiting parent heavy-slot relay (not run)

tsc; eslint (two paths); prettier --check; check-r75; default Jest for `test/scout/g2-r-ready-db-guard.spec.ts` and `test/scout/scout-ingest.validation.integration.spec.ts` (+ `test/contracts/importer-contract.spec.ts` as cheap contract evidence). Then hooked Bradley commit (existing lefthook hooks in the shared `.git/hooks`; no `lefthook install`).

Known unverified risk until tsc runs: the R spec and harness additions have not been type-checked; first nonzero stops.

Disk after authoring: ~5 GB free (threshold 3 GiB not approached).
