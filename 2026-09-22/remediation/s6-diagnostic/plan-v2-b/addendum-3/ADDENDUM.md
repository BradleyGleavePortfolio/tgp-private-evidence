# S6-V3.1-NARROW-CLOSURE-B — addendum 3: line-bound verdict on diagnostic runner V3.1 `b7b328a5`

Reviewer B (`s4_r6_independent_audit_b_muc70jfl`; API-hosted AI subagent, model not exposed). Read-only: `sha256sum`, `diff`, file reads only; no execution, probes or syntax checks. Prior outputs in this directory unchanged. Scope: M-1/M-2 closure and claim "everything else unchanged"; not a re-audit. Source review, not a grant.

## Inputs (re-hashed)
| File | SHA256 |
|---|---|
| `v3/run-c5-resource-inventory.v3.1.sh` (target) | `b7b328a5acfe72ea4f180006ffed4c8b30b31ccd8dbf98e0b39389ea99e70776` |
| `v3/run-c5-resource-inventory.v3.sh` (predecessor) | `1664fd4776d95c83353bba869def899660099d6be811f311c75e0c352c35f69f` |
| `v3/MANIFEST.v3.1.sha256` (10 entries; verifies 10/10 from `v3/`) | `1be2a1761fe77e1637b3cde987644493558fe8e10d271f29178cf86ba1643a4e` |
| `v3/DIFF_v3_to_v3.1.patch` | `3b828b755316bd96bb4f4f5f658075aacf46322808ea252069e06856c2ab6c1b` |
| `v3/diag/s6diag.main.js` (positive instrument, unchanged) | `cf4701010365cb87326c17c901c4f6c941b84ea5d3dceb3f4c5e38c21e51c1d0` |
| `v3/C5_V3.1_REQUEST.md` | read in full |

## Scope check
`diff v3.sh v3.1.sh` reproduced by me is **byte-identical to the declared patch** `3b828b75`. Non-comment changes are exactly: `LOGS=$EX/logs/v3.1` (L39); `cleanup_copies` rm branch (L89–91) and porcelain gate (L93–95); `run_owned` stop (L155–158); manifest name in step 1 (L194). Header/invocation comments (L2–7, L28–30) are the only other lines. No change to supervision core, budgets, lock/`9>&-`, module list, C checks, `finish`, instrument, hooks, specs or inputs — the "everything else byte-identical" claim holds. Binding: step 1 verifies `MANIFEST.v3.1.sha256`, which pins the unchanged `cf470101` instrument, hooks, specs and the V3.1 runner itself is *not* self-included (correct). The setup runner `91fe0f1b` and V3 runner remain pinned by `MANIFEST.v3.sha256` `50f65b9d` (unchanged).

## M-1 — CLOSED (L155–158)
After `reap_group … post:$step` records `cleanup_exit=$ce`, `CUR_PID/CUR_PGID/CUR_STEP` are cleared (so a later `on_signal` cannot re-reap), then `[ "$ce" -eq 0 ] || { CLEANUP_FAILURES++; FIRST_EXIT ||= "$step rc=$RUN_RC how=$RUN_HOW"; die "$step-cleanup-survivors" 90 … }`. `run_owned` is invoked only from the main shell (L166 via `jest_step`, L219 selftest; prefix-assignment calls run in the current shell), so `die` → `STOP_FIRST_FAILURE` → `finish 90` → `final_accounting` (ancestor gate, hash-guarded copy cleanup, survivor census) → `FINAL rc=90`, `exit 90` terminates the runner before any further child is spawned. Primary/cleanup distinction preserved: step's real first exit in `FIRST_EXIT`, failure attributed to `<step>-cleanup-survivors`. Matches my addendum-2 closure exactly.

## M-2 — CLOSED (L89–95)
`if rm -f "$dst"; then … removed … else … rm FAILED — retained; counted; CLEANUP_FAILURES++`. Then `n=$(cd "$WT" && git status --porcelain | wc -l)` is logged and gated: `[ "$n" = 0 ] || { porcelain GATE FAILED; CLEANUP_FAILURES++ }`. A retained copy (hash mismatch or rm failure) or any unexpected worktree write therefore forces `CLEANUP_FAILURES>0` → FINAL 90 when primary was 0. Double-counting (rm FAILED + porcelain) is a count, not a code — harmless.

## D-1 — unchanged disclosure
C's expected primary 143/137 is kept by `finish`; rc alone cannot encode cleanup failure. Acceptance must key on record lines: every `cleanup_exit=0`, `CLEANUP_FAILURES=0`, five `copy … removed`, `porcelain after cleanup: 0`, ancestor `UNCHANGED`, and a present `FINAL rc=` line (no FINAL ⇒ not success). `C5_V3.1_REQUEST.md` states these criteria.

## Verdict
Diagnostic runner V3.1 `b7b328a5`: **no remaining blockers from my root report, addendum 1 or addendum 2**; source-grantable, to be executed only after a positive setup `91fe0f1b` receipt and a separate parent runtime grant, under the stated invocation (`timeout -k 30 420`, `logs/v3.1/`). A positive run would not prove Jest causal closure of P1, product-vs-harness ownership (the run's question), clean baseline or release readiness.
