# OP88-OWNED-LAUNCH-V10.1 — cohesive additive successor of frozen V10 + finding map; PREPARATION ONLY

Slice S5-V101-BUILD (recon/EXECUTION_SCOPE.md), T4 under execution/op88/OWNED_LAUNCH_SCOPE.md and S5_V10_REVIEW_AND_SETUP_RULING.md. Sole writer: this builder (requested Claude Fable 5 / High per policy; actual runtime identity is not observable to the builder and is not asserted). Sole writes: `/home/user/workspace/execution/e8d546f9/s5-v101`. Frozen V10 packet (manifest `fdc9977191a6d311281fdbb239d6ba015f2ca3f7b1bc5024fe7b56d51a26f54a`, 20/20 re-verified with `sha256sum -c` from its own directory), V10 A audit, V9/V8/V7 packets, S6 packets, setup-exclusion packet, product source and worktrees: untouched. **Nothing executed**: `bash -n`, `diff`, `sha256sum`, read-only `grep`/`sed` only. No control, probe, lock, install, network, Jest, npm, DB, commit or hook.

## Inputs (exact)

| Input | SHA-256 |
|---|---|
| `inputs/own-block-v10.sh` (V10 primitive) | `df200b525b0cf2abb2b3ce97e92eb7e0de1abec901b517e221adb109e72d54e3` |
| `inputs/sup-under-test.v10.sh` (V10 fixture) | `5356387c256a082669cb593b91f9db41bd5778ffcc28cd78f09963fd522b7a09` |
| `inputs/ctl-own-launch.v10.sh` (V10 driver) | `4bf2ace23da59030f049335d7ad2a4c08dbdeab4417ac5ac35a381a894637b54` |
| `inputs/ctl-t0-only.v10.sh` (V10 T0 consumer) | `2797a72ac8e935d78cd5d1dbb5e0f0f1708ba4127c217365a1f9d5c4c88253e8` |
| `inputs/run-s5-setup-npm-ci.v10.sh` (V10 setup consumer) | `8fa808281fa1f3e720919a0154b0298e5ea489fb1934d1afb76dae334ff11eef` |
| `inputs/SHA256SUMS.s5-v10-t0` (V10 manifest, verified 20/20) | `fdc9977191a6d311281fdbb239d6ba015f2ca3f7b1bc5024fe7b56d51a26f54a` |
| `inputs/owned-launch-v10-a.AUDIT.json` (published A; FREEZE.json 17487d70 lists it) | `4db262d8ef9ab92f881c6af6355817fba1bd136cc5079918f714db137dd7d4dc` |

Not an input: the current-round V10 B review. Parent mail (00:55 UTC): B is provider-blocked twice and stopped with **no verdict**; nothing is inferred from it. Also read for authority only (no bytes copied): OWNED_LAUNCH_SCOPE.md, S5_V10_REVIEW_AND_SETUP_RULING.md, live AGENT_RULES.md G01–G22, EXECUTION_SCOPE.md, both frozen V9 reports (lineage of A02 only).

## Outputs

| File | SHA-256 | Delta vs V10 |
|---|---|---|
| `own-block-v101.sh` (109 lines) | `4aebf96f6b7c8962b7a4b10dfc25acb7a793a24744bc0e79de77675031b1c6c5` | +26/−10 (`diffs/own-block-v10-to-v101.diff`): header, `OWN_LAST_SESSION` init, `own_finish`, new `own_collect_leader`, `own_collect`, `own_retire` |
| `controls-v101-t0/sup-under-test.v101.sh` | `6b7088a8e0f5e19c56ce4ac254888b773d81674db965a44399fd2ce8b1787e65` | +9/−4 (`diffs/fixture-v10-to-v101.diff`): header, source path, the two non-trap exit lines |
| `controls-v101-t0/ctl-own-launch.v101.sh` | `a7b44cf806a0c746649207ac62394ebbc57d019e5eb5f4263ab844c6abba32da` | +27/−17 (`diffs/driver-v10-to-v101.diff`): header, pins/paths, `PUB_FAIL` latch, `finish_ctl` 74 branch, per-case `exit_record=` |
| `controls-v101-t0/ctl-t0-only.v101.sh` | `51fb43b724ce1571a94c75f232651dc473804af85d75f4cfd9b5ef7e1406d62c` | +38/−16 (`diffs/t0-v10-to-v101.diff`): header, embedded block, typed session lines (v10 L214–L217, L220) |
| `controls-v101-t0/run-s5-setup-npm-ci.v101.sh` | `5f94783b44850cce3a16fc9ba68b75b572aa4b8125bc6a2e63fd650b8af98087` | +30/−10 (`diffs/setup-v10-to-v101.diff`): header + embedded block ONLY |
| `verify-embedded-block.sh` | `2687fa62fe2578a266cac71f7e4f76160fb248d098f604c9b4bb14a09aca3294` | markers `v10.1`, filenames |

Embedded block byte-identical in both consumers (`verify-embedded-block.sh` → IDENTICAL ×2; recorded in `SYNTAX_CHECKS.txt`). Jest argv/env, `npm ci` argv/pins/lock fd 9, provenance gates, T0.defect/T0.refusal_reason assertions, all 25 driver check ids/predicates/expected statuses, bounds and the setup HOLD_BOUND exclusion branch are the V10 bytes.

## Finding map (only the three published A findings)

| Finding | Exact correction | Where | Discriminator (static; nothing run) |
|---|---|---|---|
| **OWN-V10-A01** fixture discards refusal status (`exit "$RRC"` ⇒ C3–C6 SUP_RC=0 ≠ 2) | Both non-trap exits preserve `cycle`'s PRIMARY rc (`rc=$?`) when cleanup succeeded and exit **91** only when cleanup/census failed (`RRC`, `c2`) — the fixture's existing `on_term` 91 convention. New last line `fixture-exit primary_rc=<rc> cleanup_rc=<0/1>` separates the statuses in `sup.out`. Expected 75 and `SUP_RC=2` predicates unchanged. | fixture v10 L68→L72–L75 (reuse-refusal: `cycle; rc=$?`, exit `(RRC||c2)?91:rc`), L71→L76 (`*)` branch) | C3/C4/C5/C5b/C5c/C6 require `SUP_RC=2`: refusal paths return 2 from `cycle` L54 with `RRC=0` ⇒ exit 2. C1/C2/C7/C11–C14 return 0 ⇒ exit 0. C8–C10 exit via `on_term` (143/91) unchanged. |
| **OWN-V10-A02** unknown/live session authority retired because the leader is gone (T0 rc3 → `m=""` → retire + `.owned`; `own_collect` retires the session after collecting an exited leader) | **Primitive:** leader collection is separated from session authority. `own_finish` collects the leader at the actual `wait` (`own_collect_leader`: pid leaves `OWN_PIDS`, enters `OWN_RETIRED` once); `OWN_PGIDS` untouched. `own_retire` removes SESSION authority **only** when `own_group_current` positively reports observed-empty (rc1) or foreign (rc2) → rc0 `OWN_LAST_SESSION=empty|foreign`; live (rc0) / census-error (rc3) → rc2, pgid KEPT (`OWN_LAST_SESSION=live|unknown`), still reaped (`GROUP_CENSUS_ERROR` rc1) and censused (`CENSUS_ERROR` rc1). `own_collect` reports `COLLECTED` then `SESSION_RETIRED (empty|foreign)` or `SESSION_KEPT (live|unknown …)`. `own_finish` also refuses to wait a pid not in `OWN_PIDS` (`not-registered`, rc3): a pid is waited exactly once, so no second `wait` can fabricate a non-child 127 into a `COLLECTED rc=` line (this double-wait was reachable in V10's refusal path L53→L54 and in every consumer whose leader was finished but not retired; it is the same `own_collect` state defect A02 names, corrected in the same function). **T0 consumer:** post-wait census is typed `sess=empty|live|foreign|unknown` from `own_group_current` rc1/0/2/3, re-read after any escalation; `session=$sess` written to the EXIT record and log; `own_retire` only on `observed && sess=empty`; `<id>.owned` requires `sess=empty` (census-error/live/foreign never count as empty). **Setup consumer:** embedded block only — its L230 already types rc3 as `CE=1` + quarantine; its retire calls are guarded (`CE=0` L231; refusal path L218 now re-checked inside `own_retire`). **Driver/fixture:** their explicit `own_retire` calls were already guarded by `gc=1`; the fixture's Q retire (v10 L69) is now internally guarded. | primitive `own_finish`/`own_collect_leader`/`own_collect`/`own_retire`; T0 v10 L197, L214–L217, L220 | T0: rc3 ⇒ `.owned` FAIL, session kept ⇒ EXIT trap `own_reap_all` → `GROUP_CENSUS_ERROR` rc1 and `own_census` → `CENSUS_ERROR` rc1 ⇒ FINAL 90 (never a successful empty-ownership result). Fixture C1/C2/C11–C14 still reach `retired pid=` via guarded L64 (`gc=1` ⇒ `own_retire` rc0). C10 `retired=\[ *$CHILD\]` holds: single entry (dedupe). C13 `retire-live-refused=yes` (alive ⇒ rc1), `census_rc=0` (Q session empty ⇒ retired). Unknown state remains not deterministically constructible with fake children (disclosed in V10; unchanged). |
| **OWN-V10-A03** driver ignores a failed required enclosure EXIT record | `PUB_FAIL` latch: `own_record "$att/EXIT"` failure logs `ENCLOSURE_EXIT_RECORD_FAILED <path>`, sets `exit_record=FAILED` in the per-case line and increments `PUB_FAIL`; `finish_ctl` SUMMARY adds `primary_rc= publication_failures=`; exit order: cleanup failure ⇒ 90 (unchanged, first) → `PUB_FAIL≠0 && primary=0` ⇒ **74** → else primary. Raw child (`sup_raw`), primary and cleanup statuses remain separate and unchanged. | driver v10 L19, L26–L27, L32, L43–L44 | Mirrors T0 `on_exit` L179 (existing technique). No check predicate changed; a failed EXIT record can no longer coexist with a final 0. |

## What is deliberately NOT in V10.1

- **Setup HOLD_BOUND / `exclusion=unpreserved` branch** (v10 setup L162–L168): untouched; belongs to OP88-S5-SETUP-EXCLUSION (separately reviewed A/B; a change map will be returned separately, no implementation here).
- **S6 consumers**: absent, paused (ruling).
- **V10 B**: no verdict exists; nothing incorporated, nothing inferred.
- **Frozen V10 diagnostic**: `execution/op88/s5-v10-t0/controls-v10-t0/ctl-own-launch.v10.sh` and its pins are unchanged and remain runnable exactly as A described (expected C3 assertion failure). V10.1 is additive.
- No new dependency, generic supervisor/framework, product/schema/assertion/lockfile change, kernel-immunity claim, or `set -m` case.

## Residuals disclosed (pre-existing, unchanged, not V10.1 scope)

- Fast numeric pid/pgid reuse between a collected leader and a later child of the same shell is guarded only by `own_is_child`/`own_group_current` identity checks (V10 class; not addressed).
- Actual outer-driver cancellation with an active fixture child remains not directly exercised (V10 A adequacy note).
- `own_record` onto a path that is a directory (C5b) leaves `IDENTITY.tmp.<pid>` inside that directory (cosmetic; V10 behaviour).

## Truth

Implemented + `bash -n` (6 scripts, `SYNTAX_CHECKS.txt`). Tested: **nothing**. Static expectation if the fake-child diagnostic is granted on these bytes: 25 PASS / 0 FAIL — an expectation, not evidence. Nothing here proves T0, setup, S6, install, product or release outcomes. Wave 6 remains FAIL. V10.1 inherits **no** clearance from V10 A: changed bytes require two independent exact successor reviews (G09/G10).

## Next (smallest)

1. Two independent exact reviews of this packet (`SHA256SUMS.s5-v101`) against OWNED_LAUNCH_SCOPE.md, the ruling and OWN-V10-A01..A03 (reviewers must not read each other; the builder may be asked for readback).
2. On dual closure: the exact bounded fake-child diagnostic in `CONTROL_REQUEST_V101.md` — private synthetic children only; no setup/T0/install/lock.
3. T0 and setup remain gated on attributable fresh setup and the separate setup-exclusion successor.
