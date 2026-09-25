# S8-F acceptance

Parent EXEC-1910A060, 2026-09-25T21:48Z. Decision: **ACCEPT** exact S8-F candidate
`e1ec2fecb71f315b6721d426ba0dacb84f304498`, tree `2fe0201ff132dfdc53ea82b3f26ed0fc8d1c65d6`,
parent `1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47`, author and committer Bradley Gleave
<bradley@bradleytgpcoaching.com>, no trailers. This is technical acceptance for nonproduction integration landing,
not production deployment, enablement or customer acceptance.

## Evidence

- Source and gates (historical, reused exactly, not rerun): 33/33 affected suites, genuine hooks, deterministic
  contract regeneration (`execution/64e33dc7/s8f/composition/COMMIT_READY.md`). Candidate recovered from the verified
  bundle `execution/64e33dc7/s8f/checkpoints/v1/s8f-e1ec2fec.bundle`; not rebuilt.
- Independent T4 source reviews A and B: both GO, no class A/B (`execution/1910a060/s8f/reviews/REVIEW_A.md`,
  `REVIEW_B.md`). Contract version `2.0.0-c1-s2.0` left unchanged (additive fields), dispositioned C by both.
- Binding v2 (`execution/64e33dc7/s8f/binding/v2/`, runner `3e43c8c8…`, fixture `4983477…`): independent dual GO for
  one run, no A/B (`REVIEW_A_V2.md`, `REVIEW_B_V2.md`). v1 immutable.
- Real-PG proof under grant S8F-PG-1: one launch 21:45:20Z, sentinel `RC=0 STAGE=done END=2026-09-25T21:46:01Z
  HEAD=e1ec2fec… LOCK_INODE=667698`; PostgreSQL 17.6 (170006), 172 migrations applied, committed bootstrap OK;
  `Test Suites: 1 passed, 1 total`, `Tests: 11 passed, 11 total`; stop state clean, data dir retained, lock released
  (`execution/64e33dc7/s8f/binding/v2/run/`, `PROOF_RUN_RECEIPT.md`, `SHA256SUMS`).

## Class C carried (no action required to land)

Provenance vouching keyed by `(coach_id, native_kind, native_id)` rather than ledger source identity; WorkoutProgram
visibility/owner not consulted (coach fence + provenance used); `format: uuid` descriptive; empty page with cursor;
`already_present` accepted though S8-C does not write it; runner RECEIPTS hashes the log before its final END line.
The 11 PG cases' first live execution is this proof.

## Next

Compose onto current integration/importer `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9` per
`execution/1910a060/landing/RECIPE.md` (predicted tree `23614f0b…`, 0 composition-affected suites), then land by
ordinary fast-forward after PR CI is green. `main` is not written.
