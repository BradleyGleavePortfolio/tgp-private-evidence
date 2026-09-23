# OP88-S5-SETUP-EXCLUSION v3.1 — minimal V3→V3.1 launcher delta closing V3-B-01 (source-only; NOT LAUNCHED)

Builder: `s4_v6_1_narrow_repair_muddwjaa`, sole builder (requested Claude Fable 5 / High; runtime model/settings not observable, not asserted). Sole writes: `execution/e8d546f9/s5-setup-exclusion-v31/`. Static only: `edit`, `bash -n`, `diff`, `patch`/`cmp` on `mktemp` copies, `sha256sum`, `grep`. **Nothing executed.** V3 (`8b128b4d…`) is immutable; V2 (`b96dc732…`) immutable. V3-A (`d9104403…`, 23/23) and V3-B (`3bb45135…`, 3/3) read after parent freeze confirmation. Primitive `4aebf96f…` untouched (embedded block identical); runner v101x `81ff20b0…` unchanged (byte-identical copy included for staging).

## 1. The finding (binding material per parent, not waived by A's clear)

**V3-B-01:** v3 L179 binds the shared `setup.EXIT_RECORD` to this attempt only through the runner's INHERITED line (v101x L212). A runner that was adopted (`RSTATE=released`) but exits between L206 (START written, record truncated) and L212 — STAMP_WRITE_FAILED 74, precondition 2, lease-fd/holder-mismatch/holder-gone 75 — leaves a current but unbound record → `not-this-attempt` → v3 L188 → `unknown` → SELF-HOLD that no legitimate file change can release (only fabricated runner evidence or a parent kill). No npm can exist in that branch (npm launch is L241, after L212), so exclusion is never lost; the defect is a dead-end hold.

## 2. Exact delta — `diffs/launcher-v3-to-v31.diff` (+14 −3; `patch` of v3 reproduces v3.1 byte-for-byte; v3 236 → v3.1 247 lines). One file; **no runner change** (the existing START line already carries everything needed).

| v3.1 lines | change |
|---|---|
| 2–6 | header: v3.1 identity; v3 header retained |
| 165 | `SPAWN_TS=""` added to the state line (initialised before any census; `set -u`) |
| 180–185 `runner_bound` (new) | rc0 iff (a) the record contains ` lease INHERITED fd=9 path=$LOCK token=$TOKEN ` (v3 rule, unchanged), **or (b)** its first line matching `^<YYYY-MM-DDTHH:MM:SSZ> START pid=<n> pgid=$SESSION ` (v101x L206 format, `ts()`=`date -u +%FT%TZ`) has a stamp **not before `SPAWN_TS`**. Requires `SESSION` and `SPAWN_TS` non-empty (pre-spawn callers → rc1). Pure reads; no facts imported by the binding itself |
| 189 `runner_truth` | calls `runner_bound "$r"` instead of the inline token grep; `not-this-attempt` otherwise (unchanged wording) |
| 227 | `SPAWN_TS=$(date -u +%Y%m%dT%H%M%SZ)` immediately before `own_spawn_begin`; `own_spawn_begin` stays the command immediately before the `&` line (primitive contract) |

Nothing else changed: no primitive/runner/observer/control edits; no new signal, trap, or `rm` command (`SYNTAX_CHECKS.txt`).

## 3. Why (b) is current-attempt provenance, not generic START acceptance

- `pgid=$SESSION`: the runner runs inside the session created by the primitive's `setsid` gate whose leader pid is `SESSION`; with job control off (which the runner's own `own_precondition` requires) its pgid equals `SESSION` (B's analysis; if a platform ever differed, (b) simply fails to bind and v3 behaviour — `unknown` hold — remains: safe direction).
- `stamp ≥ SPAWN_TS` (second granularity, UTC, same clock): a stale record from any earlier attempt was written before this holder acquired the lock, therefore before `SPAWN_TS`; pid-number reuse alone (a stale `pgid=` equal to our `SESSION` number) cannot bind it. Residual: a stale START written in the very same UTC second as our spawn **and** carrying our exact session number — requires the previous attempt's runner to start after our `flock -n` succeeded, which the exclusive lock forbids for a lock-holding runner; a lock-less foreign writer of this exact file is outside the model (already true for v3's token line). Clock stepping backwards between attempts is not defended (stated).
- Bound START without `npm-ci IDENTITY … state=released` positively means: this attempt's runner started and did not reach adoption of an npm child; any adopted npm has a self_sid-bound IDENTITY written before ADOPT (runner L245) and is censused independently (v3 A-01 rules unchanged). EXIT_RECORD facts can still only add `unknown`, never `empty`.
- Why not `ppid=$PID`: depends on the gate→env→timeout exec/fork chain (B); not used. Why not a runner-side token in START (2-file delta): unnecessary — the existing record path suffices; reported here as the alternative the parent asked to be named, **not implemented**.

## 4. Preserved / applicability

All v3 closures (A-01, A-02, V2-B-01 stale-token, V2-B-02 preservation) unchanged; V10.1 consumer applicability unchanged (no new primitive call or context; new code is `grep -F`, `sed -n`, string compare, one `date`). Record formats, tokens, `RUNNER_NOTE` forms unchanged. **All v2 fakes remain incompatible with v3/v3.1 in every scenario** (V3-B-02): a fake that writes no EXIT_RECORD → `absent-after-launch` → `unknown`; a fake writing an unbound record → `not-this-attempt` → `unknown`. A v3.1 fake must write either the INHERITED token line or a v101x-format START line with `pgid=$(ps -o pgid= $$)` stamped by `date -u +%FT%TZ` (the early-death case relies on exactly that).

## 5. Request (narrow)

Two independent exact-delta reviews of `diffs/launcher-v3-to-v31.diff` against frozen v3: (a) does (b) bind only this attempt's record (session number + spawn-time floor) with no generic START acceptance and no stale import; (b) does the early-adopted-death branch now yield `released=0 final=<rc|none>` → census → recorded release (raw rc preserved) instead of a dead-end hold; (c) confinement to the §2 lines with primitive/runner byte-identical. Controls prep (`s5-setup-v3-controls/`) is pinned to this candidate's hash and frozen separately; both this source closure and two exact control reviews precede any single private grant. No canonical/runtime requested.
