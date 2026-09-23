# S2 V61 fresh five-set continuation grant

Parent EXEC-6c2a68ac. Status: CONDITIONAL, NOT ACTIVE until explicit parent activation after exact restoration acceptance. One execution only. Sole executor: `restore_s2_substrate_mue9eidh`, requested Claude Fable 5 / High; requested policy is not runtime telemetry. Executor is not an independent reviewer.

Tier: T4. Why: consequential trusted validation, recovery and process ownership evidence. T4 trigger scan: trusted validation/recovery. T3 trigger scan: lifecycle/state ownership. Bounded T1: NO, privilege/recovery. Parent owner: EXEC-6c2a68ac. Acceptance: raw0 for k/new1/new2/neg/neg2, truthful first-failure and NOTRUN ledger, exact manifests, permitted writes/signals only, final owned-process accounting, then two independent nonbuilder result attestations. Stop triggers: mismatch, collision, nonzero, incomplete publication, unknown ownership or scope expansion.

## Preserved exact authority

This is a fresh session grant, not inheritance of the previous worker/slot. The execution contract and source review applicability are unchanged from `execution/e8d546f9/S2_V61_CONTROL_GRANT.md` at private intake `41aa9ddd03525f987231472a7b18edaa4dcc93da`, except the current executor ID and fresh result-publication path below. Its full controls, first-failure rule, signal limits and exclusions remain binding.

- V61 manifest `ed2413420bd1ae917649cff6924683c8279f45fb31505e46ff10051d513d7b7a`.
- Driver `42d9362b8234141bf5f68a997a5c113ced8154f068fdb87384674b7dd875ddc1`.
- Frozen Request20 `0e8ab7ec594948179252b0bffcd9603f93df677b8a600d1fb0fbac40ef6a68ef`.
- Unchanged V57 runner `efa273c7de7d4bcc34b6f5be0fae74e412d73a5e82fc9e504a0e2a4c10367e1c`.
- Independent A manifest `4f90e2067d52e5491b0c45d9805faf5c329f5cca893f9b885fb0b857e37c1868`; k=120 addendum `18b7b9de0120fd330fc70ab404f7dd11700f6d14e8856903c41ef030890063be`.
- Independent B manifest `3e2b7744d553edeabdfe798f166a44817ac4c01b08bf2a91cd98eee2e5adf858`; budget addendum manifest `f565c4585dcc4410aeffa4eb74f67175355099ee5c729ad670c01059a986a0f8`.

No source correction is requested. Prior V59 failed result remains failed. P1/W1/C1 are retained by explicit relevant-input applicability, not rerun. K1/K2 repeat only because k is inseparable. Original V60 edit/revert disclosure remains unchanged.

## Preconditions

Parent accepts fresh exact restoration first: clean `worktrees/s2-runner53` at d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c; tree c0ab87d4dc584b2a7ccad53db16fa551b93fe359; predecessor 37/37; V57 15/15; V61 20/20; explicitly recreated ENV01 with empty writable `runner-selftest-r531/` and predecessor parent 0555. No npm/PostgreSQL setup is needed or granted for stub-only controls.

Read-only tool-version, /proc/process ownership and no-conflict prerequisite observations are permitted immediately before activation/execution. They do not authorize canonical-lock open/probe. No other runtime grant is active; current S5 auditors are read-only. Never import historical PIDs.

## Exact block

Run once from an unprivileged Bash caller with ambient errexit and job control OFF. Preserve all output and each actual raw status. Frozen request remains unchanged; only its already dual-reviewed caller value k=60 is superseded with k=120.

```sh
export GIT_OPTIONAL_LOCKS=0   # B57-06 (parent-allowed): the runner's read-only git status calls must not refresh the worktree index cache; inherited through env
D=/home/user/workspace/execution/e8d546f9/s2-v61/controls-proposed/run-controls-v61.sh
declare -A B=([probe]=20 [wdtest]=20 [wdcancel]=20 [k]=120 [new1]=60 [new2]=60 [neg]=90 [neg2]=150)
for s in k new1 new2 neg neg2; do   # CONTINUATION: probe/wdtest/wdcancel evidence retained from the V59 run (0/0/3), not repeated
  CTL_SET=$s CTL_BUDGET=${B[$s]} bash "$D"; rc=$?; echo "$s=$rc"
  if [ "$rc" -eq 0 ] || { [ "$s" = wdcancel ] && [ "$rc" -eq 3 ]; }; then continue; fi
  echo "STOP at $s (aggregate $rc)"; break
done
```

All five continued raw statuses must be 0. Shell loop/transport status is not a substitute. Each later set after a failure is NOT RUN. No retries, resumption, extra timeout/enclosure, optional controls, budget changes or manual recovery.

## Writes, signals and exclusions

Only Request20 runtime paths: V61 `controls-proposed/results/`; V57 `runtime/` and `runner-selftest-r57/`; for new1 only predecessor `runner-selftest-r531/` plus V61 `controls-proposed/stubs/test-validation.lock`. Fresh executor evidence goes to `execution/6c2a68ac/s2-v61-result/`, not the old result path. Additive timestamped outputs only; refuse collisions. Manifested candidate/predecessor files remain unchanged.

Only the frozen driver's reviewed identity-bound signals, controllers, watchdog and cleanup are allowed. Never signal caller/foreign groups, add a signal, or use old PIDs. No canonical lock open/probe, real DB/fixture, node/prisma/psql, install, network, product/client execution, source edit, hook, commit, public push or real-proof execution. `PROOF_REQUEST_21` remains HELD.

On any unexpected result, STOP, preserve exact facts and return. Retained holders or unknown census require parent disposition, not automatic cleanup. Freeze raw per-set ledger, executed caller and comparison, full logs, result directories, owned/controller/watchdog histories, pre/post source and manifest checks, final accounting and a non-self-including result manifest. Original failure evidence stays immutable. Two independent result reviews precede any real-proof grant.
