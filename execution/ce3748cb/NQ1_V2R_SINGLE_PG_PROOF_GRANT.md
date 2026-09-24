# N/Q1 v2r single PG proof grant (T4) — parent ~22:00Z

Both independent delta attestations GO (`nq1-attest-a/ATTESTATION.md`, `nq1-attest-b/ATTESTATION.md`); no A/B; C records accepted as recorded.
Candidate `29e60705d8c4e1228fd1d2f248c7e53b6b8e56dd` (tree `511710ee`), runner `nq1/binding/nq1-pg-proof.sh` sha `aec60252…`, BINDING.sha256 3/3.

PRE-1 (preserving, no deletion): rename `execution/cf8ff737/nq1/runtime` → `execution/cf8ff737/nq1/runtime.v1-failed-61b93cff-<UTC>`; hash its files before/after into a receipt. `clusters/nq1` does not exist in this sandbox (moot, recorded).
Then exactly ONE unchanged run of the bound runner under the canonical flock (wait for the lock politely; never remove another owner's lock). No retry on failure; failures recorded unchanged; cleanup per runner. Sole executor: `n_q1_v2r_builder_mufyro9p`. Report `nq1/NQ1_V2R_PG_PROOF_RESULT.md`.
