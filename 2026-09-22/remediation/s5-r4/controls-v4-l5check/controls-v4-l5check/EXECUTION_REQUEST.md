# L5 checker v4 — separate <= 10 s pure-read execution request (NOT executed; Wave 2 NOT relabelled)

Inputs: `l5-check.sh` (bash, read-only, no processes beyond grep/cut), counterexamples derived from the PRESERVED
wave-2 raw log `run-resume-20260922T051924Z.log` (byte copy `00-wave2-preserved-raw.log`). Expected outcomes:
- `00-wave2-preserved-raw.log` → HOLDS rc 0 (P1–P4)   [positive: the real wave-2 L5 run]
- `P2-guard-unit-jest-present.log` → HOLDS rc 0        [positive: pre-start guard-unit jest CMD must not trip the checker]
- `N1-generate-only-after-refusal.log` → VIOLATED rc 1 (P2a, P3)
- `N2-live-spec-after-refusal.log` → VIOLATED rc 1 (P2b, P3)
- `N3-no-refusal-line.log` → VIOLATED rc 1 (P1, P3)
- `N4-stop-failed.log` → VIOLATED rc 1 (P4)
- `N5-generate-only-before-refusal.log` → VIOLATED rc 1 (P2a)
Command (once, sequential, <= 10 s total):
```
cd /home/user/workspace/execution/s5-r4 && mkdir -p control-results/wave4-l5check
for f in controls-v4-l5check/counterexamples/*.log; do timeout -k 2 2 bash controls-v4-l5check/l5-check.sh "$f"; echo "RC=$? $f"; done > control-results/wave4-l5check/l5-check.out 2>&1
```
Pass criterion: exactly the expected HOLDS/VIOLATED per file above; any deviation stops and is reported raw.
This does not change Wave 2's recorded FAIL; it only tests the corrected checker.
