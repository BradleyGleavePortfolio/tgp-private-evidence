# S2 V61 five-set control continuation grant

Parent EXEC-e8d546f9, 2026-09-23. Individually T4, stub-only control continuation. Sole executor `s2_v5_8_concrete_repair_mude34f9`, requested Claude Fable 5 / High as policy, not observed telemetry. The executor built the candidate but is not an independent reviewer; two nonbuilder reviews and result review remain separate.

## Activation and exact inputs

QUEUED, NOT ACTIVE. Launch only after a subsequent explicit parent ACTIVATE message accepting S5 X6 retained-holder recovery and slot closure. No overlapping runtime, install, test, browser or database activity. This grant authorizes one five-set sequence only; no retry or automatic budget extension.

- **Candidate:** `execution/e8d546f9/s2-v61/SHA256SUMS.outer` = `ed2413420bd1ae917649cff6924683c8279f45fb31505e46ff10051d513d7b7a`, 20/20.
- **Driver:** `controls-proposed/run-controls-v61.sh` = `42d9362b8234141bf5f68a997a5c113ced8154f068fdb87384674b7dd875ddc1`.
- **Frozen request:** `CONTROL_REQUEST_20.md` = `0e8ab7ec594948179252b0bffcd9603f93df677b8a600d1fb0fbac40ef6a68ef`, unchanged.
- **Runner:** unchanged V57 runner `efa273c7de7d4bcc34b6f5be0fae74e412d73a5e82fc9e504a0e2a4c10367e1c`; four stubs, stub manifest and K1 mechanism remain byte-identical to reviewed V59.
- **Independent A:** `audits/s2-v61-a/MANIFEST.sha256` = `4f90e2067d52e5491b0c45d9805faf5c329f5cca893f9b885fb0b857e37c1868`; caller-budget addendum `18b7b9de0120fd330fc70ab404f7dd11700f6d14e8856903c41ef030890063be`.
- **Independent B:** `audits/s2-v61-b/MANIFEST.sha256` = `3e2b7744d553edeabdfe798f166a44817ac4c01b08bf2a91cd98eee2e5adf858`; budget addendum manifest `f565c4585dcc4410aeffa4eb74f67175355099ee5c729ad670c01059a986a0f8`, note `2b9574c7d2bfd5a8e364e49aa68dae6999252b51c8afa9604619e070e262daac`.

Verify all pins and the request's environment prerequisites before launch. Preserve V59 failed result `d749a4b1a3c2671a73e7672e1d86a0c064860a5931904a3c4bc710c2308d24f0`, its two result reviews and the V60 disclosed edit/revert history unchanged. Current matching V60 bytes do not establish continuous immutability.

## One-value caller supersession

This grant supersedes exactly `[k]=60` with `[k]=120` in the request's caller. Request and driver bytes are not edited. Other continued budgets remain 60/60/90/150. Both independent addenda accept this use of the existing CTL_BUDGET input: declared maxima 98 + reserve 8 leave 14 seconds nominal headroom; k watchdog thresholds become 112/116/118 seconds. Per-control declared caps, authority, event placement, assertions, cleanup and first-failure stop are unchanged. The budget is a safety cap, not a completion guarantee.

From an unprivileged Bash caller with ambient errexit and job control OFF, run this exact block once, capturing complete output and each raw status:

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

Compare the executed block byte-for-byte to the frozen request after this single token substitution and retain the comparison. All five raw statuses must be 0. The retained standalone wdcancel=3 exception is not applicable to any of these five set invocations. The shell's final loop status is not a substitute for raw per-set exits. A failure stops the sequence and leaves every later set NOT RUN.

Retain V59 P1/W1/C1 evidence; neither review identified a changed executed path that invalidates it. K1/K2 repeat only because set k is inseparable under the frozen selector, not because their historical passes were invalidated. No new selector or blanket eight-set rerun.

## Prerequisites and complete write set

Verify exact clean `worktrees/s2-runner53` at `d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c`; predecessor packet 37/37 and V57 lane 15/15; requested tools and no conflicting existing processes. ENV01 is already applied: predecessor `runner-selftest-r531/` exists, writable and empty; its packet parent remains 0555. Do not chmod, reinstall, restore again or create alternative prerequisites silently.

Permitted runtime writes are only those in Request20:

- `execution/e8d546f9/s2-v61/controls-proposed/results/`
- `execution/op88/s2-v57/runtime/` and `execution/op88/s2-v57/runner-selftest-r57/`
- For new1 only, `execution/s2-setup-prep/runner-selftest-r531/` and `execution/e8d546f9/s2-v61/controls-proposed/stubs/test-validation.lock`
- Fresh executor evidence under `execution/e8d546f9/s2-v61-control-result/`

Timestamped outputs must be additive; refuse collisions rather than overwrite. Preserve all manifested candidate/predecessor files and earlier results. The unchanged runner keeps its reviewed V57 output paths; this dual-lane arrangement is deliberate.

## Authority, stop and return

Only the frozen driver's reviewed identity-bound signals, own controllers, watchdog and cleanup are authorized. The event controller sends one TERM to a current-enclosure-validated runner PID after the required step-40 evidence; timeout/mismatch sends nothing and fails. The caller's process group and foreign processes are never targets. No executor-added signal, timeout, lock operation, cleanup or recovery is permitted. A transport, if needed, may only preserve the exact block and raw evidence without adding an enclosure or changing budgets.

No canonical lock open/probe, real DB/fixture, node/prisma/psql, installation, network, product/client execution, destroy, source edit, hook, commit, public push or real-proof execution. PROOF_REQUEST_21 stays HELD.

On any nonzero, missing publication, retained holder, unknown census or other unexpected effect, STOP, preserve raw evidence and return exact facts; do not repair, retry, normalize a status or infer success. Freeze raw per-set ledger, caller, full logs, each result directory with its own manifest, runner/predecessor output directories, owned/controller/watchdog histories and exact grant/review/input pins. Return pre/post source and packet checks and final accounting. Independent result review is required before any real-proof decision.
