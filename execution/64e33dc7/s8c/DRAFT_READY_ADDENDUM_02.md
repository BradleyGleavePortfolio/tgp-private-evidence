# DRAFT_READY addendum 02 — mapping-spec lines + candidate-bound PG driver (2026-09-24 21:10 PDT)

Source-only. No install, generate, compiler, Jest, hooks, initdb, server, bootstrap, migration or PG run. Worktree still uncommitted on `exec64/s8c-replacement` at base `93389265`.

## 1. Grant amendment "Draft-readiness amendment: program mapping and proof order" — implemented

`src/scout/reconstruct/mapping-spec.ts`, exactly two additive lines (sha256 `ef087870…5ba9`, in `checkpoint/TRACKED_EDITS.patch`):

- L122: `readonly programs?: EntityFieldRules;` inside `SourceMappingSpec.families`.
- L242: `if (family === RECONSTRUCT_FAMILY.programs) return spec.families.programs;` in `entityRules`.

Checked, not changed: the spec parser already validates family keys generically via `isCanonicalFamily` (L347-352), so a spec declaring `programs` parses with `ENTITY_FIELDS` without further edits; `resolveStep` (L251-257) resolves declared step keys only, so the accepted `conformance_beta` step `programs → workouts` and `test/scout/reconstruct/mapping-spec.third-source.spec.ts` L58 are unaffected; `mapping-spec.spec.ts` L62/L67 (`families.billing` / `steps.notes` not canonical) are unaffected. The `programs` feature and all programs proof cases are kept; DRAFT_READY §4 A1 is closed and its fallback is void. Accepted sidecars, fixtures and source-specific mappings are byte-identical.

Existing accepted tests that enumerate `['clients','workouts','client_history']` literally (`test/scout/scout-cursor.spec.ts` L44/L56, `test/scout/reconstruct/scout-reconstruct.controller.spec.ts` L80) iterate over those three values only; they do not assert list equality, so they are expected to stay green. They are not owned and were not touched; a failure there at the source gate will be preserved and reported, not patched.

## 2. Fresh candidate-bound PG driver (source-only, for dual review; no execution)

The proof driver now refuses to run against anything but ONE attested, clean, non-base candidate head:

- `test/utils/g2-s8c-db.ts`: `G2_S8C_CANDIDATE_HEAD_ENV`, `G2_S8C_BASE_HEAD`, pure `g2S8cCandidateHead(declared, checkedOut, porcelain)` — requires 40-hex, ≠ base, == `git rev-parse HEAD` of the runtime root, empty `git status --porcelain`.
- `test/utils/g2-s8c-pg-harness.ts`: `export const candidateHead` evaluated at import (fails the whole spec before any connection if unbound); `BASE_HEAD` now derives from `G2_S8C_BASE_HEAD`; worker config carries `head`.
- `test/utils/g2-s8c-worker.cjs`: asserts its own `git rev-parse HEAD` of `input.root` equals `input.head` before constructing the Prisma client.
- `test/utils/g2-s8c-bootstrap.sh`: requires `G2_S8C_CANDIDATE_HEAD`; asserts 40-hex, ≠ `BASE_HEAD`, == runtime-root HEAD, clean tree, `merge-base --is-ancestor BASE_HEAD HEAD`; prints `CANDIDATE_HEAD=<sha>`. Both modes (`bootstrap`, `verify-only`).
- `test/rls-g2-s8c.spec.ts`: new lane-identity case "is bound to one attested candidate head that descends from the base".
- `test/scout/g2-s8c-db-guard.spec.ts`: new case for `g2S8cCandidateHead` refusals + pin that bootstrap/harness carry the env name and base constant.

Required proof environment (for the later separate PG grant, not now): `G2_S8C_DATABASE_URL`, `G2_S8C_CONFIRM=g2_s8c_disposable:55642`, `G2_S8C_PASSWORD`, `G2_S8C_PSQL`, `G2_S8C_DATA_DIRECTORY`, **`G2_S8C_CANDIDATE_HEAD=<attested final head>`**. The value is unknown until the hooked commit exists and is attested; it is never defaulted in source. Any future runtime acquisition goes through the canonical nonblocking `execution/test-validation.lock` (untouched by S8-C); proof data/socket paths are separate.

`bash -n` (bootstrap) and `node --check` (worker) pass; nothing else executed.

## 3. Checkpoint refreshed

`checkpoint/**` re-copied (23 files + `TRACKED_EDITS.patch` sha256 `78c95a749e03a005734b642d714836cdafaa70cab557ee2a820daf928ca4c750`); `CHECKPOINT_MANIFEST.sha256` regenerated and verified. Changed since DRAFT_READY: `src/scout/reconstruct/mapping-spec.ts` (new), `test/utils/g2-s8c-db.ts`, `test/utils/g2-s8c-pg-harness.ts`, `test/utils/g2-s8c-worker.cjs`, `test/utils/g2-s8c-bootstrap.sh`, `test/rls-g2-s8c.spec.ts`, `test/scout/g2-s8c-db-guard.spec.ts`. All other checkpointed bytes unchanged.

## 4. Status

Queued for the heavy source-gate slot (S7-L holds the canonical lock, pid 17436 at 04:10Z). Generator: will only execute the unchanged generator in this worktree if/when the parent transfers execution narrowly; no script/version/spec ownership, no manual artifact edit, no drift test before regeneration; generated delta (expected: the two enums in DRAFT_READY §5) to be recorded from real output. Idle until explicit relay.
