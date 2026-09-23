# S2 V59 control result disposition

Parent EXEC-e8d546f9, 2026-09-23. This is operational disposition, not an independent audit.

## Observed result

The single granted sequence stopped at `k`, raw aggregate 1. Frozen executor manifest `d749a4b1a3c2671a73e7672e1d86a0c064860a5931904a3c4bc710c2308d24f0` verifies 8/8; its `RESULTS_AND_INPUTS.sha256` verifies all 116 bound inputs/results.

Actual ledger: probe 0, wdtest 0, wdcancel 3 (the documented standalone exception), k 1. Within k, K1 and K2 passed, K3 missed two assertions, and K4–K6 were not run. new1/new2/neg/neg2 were not run. No batch success is claimed.

K3 requested cancellation at elapsed 3 seconds and expected active step 40. The actual runner stamp records TERM in `30-fixture-init`; its final record is 143, cleanup 0, reap ok, fixture interrupted, composition and fixture stop not run, survivors none. This does not establish the intended step-40 cleanup ordering. No predicate is waived.

## Retention and scope

Executor reports all owned/controller/watchdog work ended, no zombies, private lane lock free, canonical lock untouched, exact source manifests unchanged, d5cd clean, and predecessor parent restored to 0555. The slot is closed as a failed, fully preserved execution, not a passing control sequence. ENV01's new output directory remains empty; new1 never ran.

All four set directories and both runner output directories are preserved unchanged. The publication includes an `evidence/` mirror using original workspace-relative paths; the original absolute-path manifest is retained verbatim. This packaging does not replace or rewrite original evidence.

## Next scope

Independent A/B result reviews examine exact actual evidence, passed-subset applicability, failure placement, cleanup and smallest continuation. They do not re-audit all frozen source or read each other's current conclusions.

Builder `s2_v5_8_concrete_repair_mude34f9` owns source-only `execution/e8d546f9/s2-v60/`: correct only K3 placement using attributable existing readiness evidence, not a larger guessed sleep or weakened assertion. Runner, product and other mechanisms stay unchanged unless a concrete necessity is returned before expansion. The continuation request must preserve valid completed evidence and cover corrected K3 plus unrun controls; any unavoidable repeat or selector change must be explicit.

No rerun, real fixture, install, network, database, or `PROOF_REQUEST_17` execution is granted. Changed final control bytes require two independent exact-delta attestations and a separate continuation grant.
