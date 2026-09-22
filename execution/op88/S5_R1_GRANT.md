# OP88-S5-R1: read-only selective checker grant

Operator op 88 / v12vantage88, 2026-09-22. T4 child of OP88-S5-V7; repository/base/head/purpose/recovery/non-goals remain exactly in OP88_WAVE1.md. Sole executor: s5_selective_v7_fixer_mud58q6n (canonical Fable builder, not auditor).

Independent review execution/op88/audits/s5-v7-a/AUDIT.json source-closes checker, raw binding and fixtures. This grant closes only its R1 caller/budget conditions A01/A03, not the R2 startup/cleanup finding A02 or product acceptance. V7 packet manifest dd7f2eabccf875520301880fc064c7c7bc1e8f2956070e2a8e7490d943719eab remains unchanged.

Grant: exactly one unchanged `run-t3-checker.sh` invocation, consisting of P0 and N1-N4 once each. No canonical lock, source/worktree modification, network, install, Jest, PG or native execution. It can run alongside source-only/review lanes. Verify all 15 manifest entries first.

Budget terminology: internal120s is an admission allowance, NOT end-to-end completion. The outer command has140s initial timeout plus up to10s kill grace; reserve15s for receipts and cleanup observation. These are explicit operational allowances, not an assertion about hard real-time kernel completion. Any timeout/nonzero/missing receipt is NOT acceptance. No blind retry.

Exact caller, from a non-job-control shell:

```sh
cd /home/user/workspace/execution/op88/s5-v7 || exit 70
if S5_CTL_GRANT=granted-by-parent timeout --foreground -k 10 140 bash controls-v7-selective/run-t3-checker.sh > checker-results/op88-r1-outer.log 2>&1; then rc=0; else rc=$?; fi
printf 'RAW_OUTER_EXIT=%s\n' "$rc"
if ! printf '%s\n' "$rc" > checker-results/op88-r1-outer.exit; then exit 74; fi
exit "$rc"
```

Use a tool call that retains the actual enclosing exit; no trailing command masking it. Record start/end, actual raw outer status, wrapper11pass/0fail (if observed), P0rc0 and each negative rc1 with its named predicate, exact inputs and post-hash identity. Check there is no surviving process attributable to this exact invocation before closure, not a broad name-kill. Preserve any first failure. Freeze a separate result manifest; do not modify original V7 manifest/report.

Success closes only the read-only interpretation of preserved T3 evidence. Historical V6 remains failed; its12PASS total includes I0/partialT3 as well as T1/T2. R2 T0 driver remains HELD for A02/A03 correction and fresh isolated setup. No downstream permission is implied.
