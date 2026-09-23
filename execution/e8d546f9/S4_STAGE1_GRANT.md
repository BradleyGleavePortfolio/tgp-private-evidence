# S4 V6.1 Stage 1 single-run grant

Issued 2026-09-23 01:12 UTC by EXEC-e8d546f9. Grade T4. Sole executor `s4_v6_1_narrow_repair_muddwjaa`, requested Claude Fable 5 / High, not observed runtime telemetry. This grants execution, not independent audit or product acceptance.

## Authority and closed prerequisites

Both nonbuilder exact-delta attestations are frozen independently: A `32c35647060a13c78a435ff6731d9aa669e13d65810c678e4884767b75427817`; B `94c5921eeba8ee900cad522fc621364f02ef326fc7793e3768dc5ec267bac3b9`. All four named source defects closed for this proof, no introduced material defect reported. Native caller and environment remain separate.

S2 setup slot is CLOSED: frozen result manifest `9c1143633c4d5c97eb22ea8c2bb72ba5679db0b1ae486561b8c44897b18b76b6`, verified 27/27; each stage raw 0, final no survivors and canonical lock FREE at 01:04:17 UTC. No other runtime slot is granted while this single control run is active.

## Exact bytes and preparation

Candidate manifest `671d08c3633378ef392a4aee6bbb70b78319994727d74e439b75830a6d63d8ee`, 12 entries. Source packet `execution/e8d546f9/s4-v61`; mechanically restored whole to `/home/user/workspace/execution/s4-r6-validation/v6/`. Before execution, verify the manifest's exact hash AND all entries, not merely self-consistency. Candidate/predecessor/audit bytes stay unchanged. Require fresh absent `control-runs/`; do not overwrite or adopt a prior run or retained owner.

## One authorized action

Run exactly once in a non-job-control caller:

```sh
bash -c 'cd /home/user/workspace/execution/s4-r6-validation/v6 || exit 70; if bash controls/run-controls-v6.sh; then rc=0; else rc=$?; fi; printf "driver exit=%s\n" "$rc"; exit "$rc"'
```

This is the existing eleven-control sequence plus direct-runner refusal. Retain the existing 1500-second allowance, once-budgeted cancellation and retained-owner rules. No added `--kill-after`, no blanket cleanup and no automatic retry. The allowance is not a claim that every retained owner terminates.

Tool transport may detach/redirection-capture this unchanged caller to survive a short tool observation window, recording its attributable raw exit and fresh identity under `execution/e8d546f9/s4-stage1-result/`. Do not replace caller semantics, add a new control framework or treat the observer's exit as the driver's exit. Report the exact transport used. If the platform cannot preserve those distinctions, STOP with the concrete transport limitation rather than modify the candidate.

## Writes, signals and boundaries

- Candidate's authorized runtime writes: only `execution/s4-r6-validation/v6/control-runs/`, including its private lease and control evidence.
- Executor evidence writes: `execution/e8d546f9/s4-control-prep/` and fresh `execution/e8d546f9/s4-stage1-result/`.
- Signals: only the exact reviewed driver's current-run ownership/cancellation/private-holder recovery mechanisms. No parent or ad hoc worker signalling.
- No canonical lock, DB, package install, network, browser, native validation, source/worktree edit, commit, product action or external release.
- No independently launched heavy process while this slot is active. Read-only review and disjoint source-only work continue.

## Pass, stop and return

PASS requires raw driver exit 0, every expected `PREDICATES.txt` present with no MISS, and checked `DRIVER-TERMINAL` showing `EXIT code=0`, `identity=BOUND`, `leftovers_first=''` with state EMPTY, `private_lease_free=true`, `live_quarantine_holder=''`.

Every other outcome is STOP. Preserve all failed/partial outputs and retained ownership; no inferred pass, no unowned cleanup, no retry. Report exact start/end, command and raw status, predicates, terminal receipt, remaining owner/lease facts and manifest checks. Freeze evidence with a non-self-including manifest. Slot closes only on attributable final outcome plus cleanup/retention accounting.

Stage 2/native remains HELD. A Stage 1 pass is wrapper/private-control evidence only, not package/browser/product/customer acceptance. Parent activation message after private publication starts this grant.
