# S4 R6 native caller V2 — smallest additive successor to V1 (closes S4-NATIVE-V1-A01)

Builder: `s4_v6_1_narrow_repair_muddwjaa` (requested Claude Fable 5 / High; runtime telemetry not observable, not asserted). T4 source-only. Sole writes: `execution/e8d546f9/s4-native-caller-v2/`. **Nothing executed** (`bash -n`, Python `compile()`, `patch`/`cmp` on copies in a temp dir — `SYNTAX_CHECKS.txt`). V1 (`f5e621b1…`) is frozen and untouched; V6.1 (`671d08c3…`, re-verified 12/12), product and the Stage 1 result (`9c84eab2…`) are unchanged; no re-run. Current V1-B not read.

## 1. Exact delta (V1 → V2) — `V1_TO_V2.diff` (13 −/13 + lines; reproduces V2 byte-for-byte from V1)

| lines (V2) | change | why |
|---|---|---|
| 2, 17 | header comment: "V2 (V1 + S4-NATIVE-V1-A01 …)"; invocation path `native-caller-v2/s4-r6-native-caller-v2.sh` | file/packet identity only |
| 143 | `{` → `{  # V2 (S4-NATIVE-V1-A01): every required write is AND-chained …` | comment |
| 144–153 | each of the ten non-final `printf` commands in the receipt group gains a trailing ` &&` | **A01**: the group's status is now the conjunction of **all eleven** writes (the final `printf` on 154 closes the chain), so any failed required write makes the group fail, `mv` on 155 is skipped, and the existing failure branch runs (`OBSERVER` 0 → 90, diagnostic on stderr; nonzero observers unchanged; the `.tmp` is left as evidence) |

Everything else — lines 1, 3–16, 18–142, 154–160 — is byte-identical to V1 (checked in `SYNTAX_CHECKS.txt`). No new function, constant, branch, exit code, signal, lock touch, cleanup, recovery, seam or control. Caller-line delta against the V6 §5 native caller: `CALLER_LINE_V6_TO_V2.diff` (one line → `native-caller-v2.cmd`).

## 2. Finding → change → discriminator (`FINDINGS_MAP_V2.json`)

**S4-NATIVE-V1-A01** (receipt group checked only its last `printf`; a partial receipt could be published with observer 0). Closure: lines 144–153 end in ` &&`; line 155 `mv` is reached only when the whole chain succeeded. Discriminator for reviewers: `awk 'NR>=144&&NR<=153' … | grep -vc ' &&$'` must print `0`; line 154 must not end in `&&`; line 155 unchanged from V1. A's stated closure form ("AND-chaining the printf calls and allowing mv only when all succeed") is followed literally; the raw launcher status stays separate (`launcher exit=N` line 158 is outside the group and unaffected).

## 3. Preserved semantics (unchanged from V1; A's `accepted_caller_properties` remain applicable)

Actual launcher exit → `launcher exit=N`, observer N; retained/unresolved launcher → observer 97 after exactly one TERM and one 127 s allowance, no `wait`, no KILL; `SELF_HOLD_RETAINED` label only on liveness + spawn/current starttime equality + canonical fd 9 + `…-SELF` token shape; raw 0 contradicted by facts → 94; receipt failure → 0 becomes 90, never the reverse; read-only census/holder identity; no `flock`, no reaping, no recovery. V2 changes none of these paths.

## 4. Additive qualifications carried into the request (per A; **not** code changes)

1. **Bound tail.** V1's "≈ 3559 s" understated the declared read tail. After observation (3422 s) and one cancel allowance (127 s) the caller may run up to four sequential `SCAN_S=5` bounded reads (record read, `holder_identity` fallback, `holder_alive`'s repeated identity read, census) = 20 s, and the pre-spawn manifest check (`timeout 20`) precedes `T0`. Grant wording: **observer nominal allowance ≥ 3569 s post-spawn (3422 + 127 + 20), 3589 s including the manifest allowance**, with the existing qualification that polling, `mv`, log and `/proc` reads are not timeout-enclosed. Neither figure is a hard completion guarantee and **no KILL deadline may be attached to it**; a launcher alive past it is reported (97) and escalated, never terminated.
2. **Actual exit 12 causality.** The note at line 141 ("SELF-HOLD exec failed …") is a diagnostic prompt, not causal proof: the unchanged launcher forwards an arbitrary nonzero runner status (launcher lines 344–348), so a runner exiting 12 also yields actual launcher exit 12. Readers must take the cause from `SUPERVISOR_RECORD.json` (`overall`, `runner.exit`, `lease.self_hold`) — the receipt prints exactly those fields on the `record(…)` line. The caller's truthful property is unchanged: 12 is reported only as a reaped exit and never synthesised for a live SELF-HOLD (which is 97). If the parent wants the line-141 wording softened, it is a one-string change for a later successor; not done here (no code expansion beyond A01).
3. **Identity limits (A, non-blocking).** `RUN_IDENTITY=BOUND` is the pid-bound glob association; the `SELF_HOLD_RETAINED` token test is a shape match, not a literal comparison with the bound run's token. Both are receipt facts for the parent's §6 decision, not authority to signal; the first native proof must use a fresh run context, and any later recovery must independently match the exact recorded run/token/starttime/fd 9 and verify owned work EMPTY.

## 5. Transport and grant (unchanged from V1 §4–5)

Detached transport identical to Stage 1 (`s4-control-prep/TRANSPORT.md` T1/T2/T3 with `native-caller-v2.cmd`, sha256 in `SHA256SUMS`); three separate artefacts: transport exit receipt (observer), caller receipt (actual launcher exit + identity, now all-or-nothing), launcher `SUPERVISOR_RECORD.json`. Native success requires actual launcher 0 **and** observer 0 with a complete receipt and consistent evidence — never 97, a would-be 12, a missing/partial receipt, or UNKNOWN census. Restore target after dual closure: `execution/s4-r6-validation/native-caller-v2/` (outside the frozen `v6`). Canonical-lock/native grant remains separate and HELD.

## 6. Exact request

Dual independent exact-delta closure of `V1_TO_V2.diff` against frozen V1 (`f5e621b1…`): (a) does the delta close A01 — any failed required `printf` prevents `mv` and cannot leave observer 0; (b) is the delta limited to lines 2, 17, 143–153; (c) are all V1 accepted properties preserved. If current V1-B reports a further concrete material item after its freeze, it will be reconciled in a further additive successor; V2 does not anticipate it.
