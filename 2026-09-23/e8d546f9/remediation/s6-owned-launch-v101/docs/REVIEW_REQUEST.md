# Review request — two INDEPENDENT T4 reviews (source-only; no grant, no runtime claim)

Packet: `/home/user/workspace/execution/e8d546f9/s6-owned-launch-v101/` — manifest `MANIFEST.s6-owned-launch-v101` (non-self-including; run `sha256sum -c` from the packet root). Requested reviewer model: Claude Fable 5 / High (policy request; not observable). Reviewers read only; no execution of either consumer, no probe, no lock, no worktree edit.

## Review 1 — S6-C6-RUNNER-ADAPT (`run-c6-hazard-v5-conly.v101.sh`, `2c9748a4…`)
Inputs: `inputs/run-c6-hazard-v5-conly.sh` (746e244d), `inputs/own-block-v101.sh` (4aebf96f), `inputs/REF_ctl-t0-only.v101.sh` (run_gate reference), `inputs/C6_SETUP_CORRECTION_REQUEST.md` §3–4, `inputs/S6_C6_REVIEW_B.md` Part B, `diffs/DIFF_c6_runner_746e244d_to_v101.patch`, `docs/FINDINGS_AND_APPLICABILITY.md` §2.2/§3/§4/§5.
Questions:
1. Is the embedded block byte-identical (re-run `verify-embedded-block.sh` mentally or via diff) and is NOTHING outside the declared hunks changed (paths, gates, Jest argv/selection, budgets, classifier, fingerprints, manifest check, cleanup_copies, selftest+C only)?
2. Does the new `run_owned` (L286–326) preserve the original contract (`RUN_RC`/`RUN_HOW` set in every path that returns; budget-refusal unchanged; M-1 `die 90` on cleanup survivors before the next step) while adopting the S5 sequence (register → confirm → IDENTITY → adopt → START latch → refused ⇒ die 2 with no workload → own_alive poll → own_signal/own_wait_gone → own_finish in-shell → typed session census → EXIT record → conditional own_retire)?
3. Do `on_signal` (L266–275) and `die` (L279–280) reap through `own_reap_all` in every phase (pre-spawn, spawning/pending, registered, released) with no dependence on `CUR_PGID`, and does `final_accounting` (L245–253) count live/unknown sessions as failures (FINAL ≠ 0)?
4. R1/R2/R3 and Part B (a)–(d) closure per `FINDINGS §3` — accurate for THIS consumer? Is the `jest_step` env-prefix call + gate `exec` chain (`bash -c gate → exec taskset → node jest`) identity-preserving (same pid, pgid==sid==pid)?
5. Bound arithmetic (FINDINGS §4): does the unchanged inner `BUDGET=180` admission still admit C after a worst-case selftest under the added confirm/gate/escalation costs, and is the external 240+30 still a nominal allowance?
6. Boundary (FINDINGS §5): the copied HOLD_BOUND → `EXCLUSION_UNPRESERVED` branch is declared NOT safe. Is the mapping complete and honest? Any consumer-internal alternative the reviewer considers mandatory before a grant (state it; do not assume the setup-exclusion wrapper class).
7. Record consequences (FINDINGS §6.1): are the changed cleanup-truth lines sufficient for the parent to read cleanup truth without `final owned pgid=` lines?

## Review 2 — S6-SETUP-ADAPT (`run-c5-setup-npm-ci.v101.sh`, `8b1ae8c0…`)
Inputs: `inputs/run-c5-setup-npm-ci.v3.sh` (91fe0f1b), `inputs/own-block-v101.sh`, `inputs/REF_run-s5-setup-npm-ci.v101.sh` (5f94783b, reviewed S5 consumer), `diffs/DIFF_setup_v3_91fe0f1b_to_v101.patch`, `diffs/DIFF_s5setup_v101_REF_to_s6setup_v101.patch`, `inputs/C6_SETUP_CORRECTION_REQUEST.md`, `docs/FINDINGS_AND_APPLICABILITY.md` §2.1/§3/§4/§5.
Questions:
1. Block identity and no undeclared change (npm ci argv byte-identical to v3 L86 — no `--ignore-scripts`; pins/gates/after-checks/strict list/env/lock fd/budgets unchanged)?
2. Is the S5→S6 diff limited to S6 pins/paths/argv/gates/after-checks/comment wording (+ the two `EXCLUSION_UNPRESERVED` label/stderr lines)? Any mechanics drift?
3. Same R1/R2/R3/Part B and trap-phase questions as Review 1 Q3–Q4 for the single `npm ci` step (setup L223–248).
4. Boundary (FINDINGS §5) — same as Review 1 Q6; additionally: the setup writes its marker under `execution/s6-diagnostic/QUARANTINE` while the runner writes under `execution/op88/s6-c6-prep/QUARANTINE` — acceptable for the parent's manual gate, or must one root be chosen (a consumer edit I did not make)?
5. Is `HOLD_BOUND=60` plus the external `timeout -k 30 1290` arithmetic (1200 + 30 + 2 confirm + ≤13 reap + ≤60 hold) honest as "nominal allowance", given the hold branch can add 60 s?

## Both reviews — non-claims to confirm
- No execution, control, probe, lock, network, install, worktree edit or commit occurred (SYNTAX_CHECKS.txt; FINDINGS §7).
- V10.1 private diagnostic acceptance (8e16701b) is NOT inherited by these consumers; setup-exclusion v2 (frozen; A residuals) is NOT used or inherited.
- Frozen files untouched: S6 setup v3, C6 runner/observer/classifier/manifests, hazard v5, adapter, instrument, V3.1 runner, product d51a1910/base a5933fd6.
- The observer still launches the ORIGINAL runner; a grant of the adapted runner needs a one-path re-point by its owner (not done here).
- Output of each review: verdict on grantability of SOURCE (not runtime), list of blocking vs non-blocking items, and an explicit statement on the §5 boundary.
