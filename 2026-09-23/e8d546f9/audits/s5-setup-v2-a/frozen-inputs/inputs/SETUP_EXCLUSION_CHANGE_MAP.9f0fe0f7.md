# Proposed T4 setup-exclusion successor — smallest change map (PROPOSAL ONLY; nothing implemented, no directory assigned)

Author: S5-V101-BUILD builder, at parent request (mail 01:00 UTC). Not an audit. Written after the V10.1 freeze; this file is outside `SHA256SUMS.s5-v101` and does not alter the frozen V10.1 candidate.

## Inputs read (exact, verified)

| Input | Digest |
|---|---|
| Frozen setup-exclusion packet `tgp-private-evidence/2026-09-22/op88/remediation/s5-setup-exclusion` (9 files) | manifest `0a69011150799ecdb31f46452ff92cede7075190906b851e39d6b5ebcb0758a7`, `sha256sum -c` 9/9 OK |
| — launcher `launch-s5-setup-exclusion.v1.sh` | `1773ac7d2b37670c2dd711347a3cc1515fb5fbb68adcc680381a26434f30e033` |
| — runner `run-s5-setup-npm-ci.v10x.sh` | `3a7b57d132fccbf16f4ad3ee0b56a314a2bccf7cfc48b6765a4305cbc2627c1c` |
| — controls `controls-exclusion/ctl-exclusion.v1.sh` / `fake-runner.sh` | `2de9500f…` / `230ff6c5…` |
| — observer `observe-s5-setup-exclusion.v1.sh` | `157bf1f4…` |
| Review A `execution/e8d546f9/audits/setup-exclusion-a/REPORT.json` | manifest `c7958e2bb0133ad63e5c7cae094270b02a733aa3da911a824a42fc97ef8b5679` (verifies) — S5X-A-01..A-07 |
| Review B `execution/e8d546f9/audits/setup-exclusion-b/{FINDINGS_B.json,SETUP_EXCLUSION_REVIEW_B.md}` | manifest `cb976bbd8a62c2f9805ef72c5664c7660eb5c8a2380068c7b5ab3e4b3f8b7626` (verifies) — SEB-B-01/02/03/06 |
| Parent disposition (mail 01:00 UTC) | delete live/unknown handoff; retain original holder until exact workload positively empty; cover the actual inner npm session; A X1 path and B mv-into-directory/rmdir both bind; no `rm -rf` general cleanup; V10.1 A02 primitive needs explicit consumer applicability, not assumed clearance |

Correspondence: A-01 ≡ B-01 (inner session uncovered); A-02 (registry emptiness after `own_collect`/foreign); A-03 ≡ B-03 (normal release-publication failure falls out of the script); A-04 (handoff) → deleted by parent disposition; A-05 (observer/stale release); A-06 (X1 wrong IDENTITY path + weak X2/X3/X4 assertions) and B-02 (X4 `rmdir` after `mv`-into-directory) → harness; A-07 (RAW lost on signal path; publication overwrites); B-06 (fakes do not model the setsid sub-session / exit 90; vacuous `pgrep -f`).

## Change map (files → exact deltas). Everything not listed stays byte-identical.

### 1. Launcher `launch-s5-setup-exclusion.v1.sh` → `v2` (new hash; new dual exact review)

| # | Closes | Lines (v1) | Smallest change |
|---|---|---|---|
| L1 | A-01/B-01 | after 171 (`RUNNER_RAW`), before 172; also `exceptional` 149–153 and `self_hold` 143 | **Inner-session coverage by the runner's own published identity.** New `inner_sids()` reads only `$EX/logs/setup-v1/attempts/*/IDENTITY` records whose `self_sid=$SESSION` (the runner's IDENTITY already carries `self_sid`, so the binding to THIS launcher attempt is exact) and extracts `pid=<npm gate pid>` = inner sid(s). New `session_state()` replaces `census_state` (see L2): for each sid in `"$SESSION" $(inner_sids)` call `own_group_current`, typed: all rc1 ⇒ `empty`; any rc0 ⇒ `live`; any rc2 ⇒ `foreign`; any rc3 ⇒ `unknown`. Release paths (174, 153, 145–146) require `session_state = empty`. Inner sids are **censused only, never signalled** (not added to `OWN_PGIDS`; `own_group_signal` keeps refusing them): the holder simply retains fd 9 until the npm session is positively empty (the runner's own reap/quarantine remains the only signaller of npm). Additionally read `$EX/logs/setup-v1/setup.EXIT_RECORD`: if it contains `npm-ci IDENTITY … state=released` and `inner_sids` is empty (IDENTITY unreadable) ⇒ `unknown` (hold); `FINAL rc=90`, `EXCLUSION_UNPRESERVED` or `CLEANUP_FAILURES=[1-9]` ⇒ never `empty` until the inner census itself is empty (they add no release path, only a recorded reason). No runner edit is required for this. |
| L2 | A-02 | 134 (`census_state`), 143 (`own_collect` before heartbeat census), 151 (`own_collect` in `exceptional`) | Delete `census_state` (registry-emptiness test; treated FOREIGN as empty). Decide only on `session_state` over the explicit `SESSION`/inner sids; `foreign` and `unknown` stay unresolved (SELF-HOLD, consistent with v1 L176–L177). `own_collect` calls stay (leader collection for evidence) but no decision reads `own_census` rc. With the **v10.1 block** (see §3) `own_collect` additionally cannot erase the session and cannot double-`wait`; with the v10 block the explicit-sid design is still correct because nothing decides on the registry. |
| L3 | A-04 (parent: DELETE) | 6–7 header text, 135–136 (`handoff_accepted`), 141 tail text (`parent handoff: write … RECOVERY_ACCEPT …`), 144 (handoff branch) | Delete the handoff capability entirely: no `RECOVERY_ACCEPT` read, no `release "handoff"`, `RECOVERY` field becomes constant `none` (keep the field so record shapes stay stable). SELF-HOLD ends **only** by `session_state = empty` plus successful RELEASE publication. Header: “retained until exact owned + inner sessions positively empty; parent recovery = out-of-band, holder is never released on assertion.” |
| L4 | A-03/B-03 | 174 (`release "normal"` last statement), 156–157 (`release "nothing-launched" 74` falls through into launch) | 174: `… release "normal" "${RAW_RC:-70}"; self_hold "release publication failed (normal, session empty)"` — `release` only returns on failure. 156–157: `release "nothing-launched" 74; say "RELEASE_RECORD_FAILED nothing launched"; exit 74` — nothing owned exists, so exiting is truthful; the fall-through into the spawn is removed. |
| L5 | A-07 | 148–153 (`on_signal`/`exceptional`), 138–139 (`release`), 129/132–133 (`PUBLICATION=` scalar) | In `exceptional`, after `own_reap_all` and before `own_collect`: `[ "$RAW" = none ] && [ -n "${PID:-}" ] && { own_finish "$PID"; RAW=$OWN_FIN; RAW_RC=$OWN_FIN_RC; }` (in-shell latch of the raw status before collection). `PUBLICATION` becomes accumulating (`pub_add <cause>` appends `+cause`, never replaces `ok`→ later values silently). `release`: write LEASE_RELEASE, then `publish_state "RELEASED(how)"`; on its failure re-write LEASE_RELEASE once with the accumulated publication (atomic replace) and log `HOLDER_UPDATE_FAILED` before `exit`. |
| L6 | A-05 (launcher side) | 121–127 (before HELD) | Preserve records **by attempt**: if `$EX/LEASE_RELEASE` or `$EX/SELF_HOLD` already exists at start, move it to `$LOGS/prior/<old token>.<name>` (mechanical `mv`, token parsed from the record) before publishing the new holder; refuse (exit 75, nothing launched) if a prior `LEASE_HOLDER` names a live holder pid/start_time. Release record already carries `token/holder_pid/start_time`. |
| L7 | B retention note (optional, parent decision) | new, after 154 | `trap … EXIT` that appends `LAUNCHER_EXIT rc=$? state=$STATE` to `$LOG` and, when `STATE` is not `RELEASED*`, publishes `LEASE_HOLDER state=EXITED-UNRESOLVED` via `own_record`. Adds no release path; makes unexpected exits recorded rather than silent. Recommended but not required by A/B. |

### 2. Controls `controls-exclusion/ctl-exclusion.v1.sh` → `v2`, `fake-runner.sh` → `v2`

| # | Closes | Lines (v1) | Smallest change |
|---|---|---|---|
| C1 | A-06 | 22 | X1 IDENTITY path → `"$EXD/logs/setup-exclusion/attempts"/*/IDENTITY` (the launcher's actual `OWN_ROOT`, L156). |
| C2 | B-02 + parent “no rm -rf” | 28, 34 | X4 obstacle repair limited to the exact fresh private path and known contents: `rm -f "$EXD/LEASE_RELEASE/LEASE_RELEASE.tmp.$LPID" && rmdir "$EXD/LEASE_RELEASE"`, same for `"$EXD/SELF_HOLD/SELF_HOLD.tmp.$LPID"` and `"$EXD/logs/setup-exclusion/SELF_HOLD/SELF_HOLD.tmp.$LPID"` (own_record's tmp name is `<path>.tmp.<launcher pid>`; `$LPID` is the launcher's `$$` because `setsid bash … &` under `set +m` does not fork). Each removal is checked; failure ⇒ FAIL (stop), never a broader delete. |
| C3 | A-04 deleted | 31–35 | Replace the wrong-token/handoff checks with `X4.self_hold_until_empty_and_publishable`: after C2's repair the launcher's next heartbeat must publish `SELF_HOLD` retry and `LEASE_RELEASE how=self-hold-then-empty publication=…SELF_HOLD-failed…` and exit 90; lock free. Optional negative: write a well-formed `RECOVERY_ACCEPT` before the repair and assert the holder ignores it (`kill -0` live, lock busy). |
| C4 | A-06 evidence limits | 24, 26, 28–30 | X2 asserts `raw=observed 0` in LEASE_RELEASE; X3 asserts `final_rc=$RC` in LEASE_RELEASE equals the actual launcher exit; X4 installs the marker fault only after `state=RUNNING` appears in `LEASE_HOLDER` (acknowledged point, not `sleep 1`) and asserts the SELF_HOLD stderr reason names `census=live` or `publication` (not merely presence). |
| C5 | B-06 vacuous asserts + parent “no pattern kills” | 24, 36 | Fake runner writes the descendant's pid into `DESC_READY`; X2 reads it and requires typed state gone/zombie (`/proc/<pid>` absent or `stat` Z), never `pgrep -f`. Delete `pkill -KILL -f` (L36): a surviving fixture child is reported `UNRESOLVED pid=` (fail-closed), not pattern-killed. |
| C6 | A-01/B-01 control gap, B-06 | fake-runner new scenario; new case X5 | `subsession-90`: fake runner writes `$S5X_EX/logs/setup-v1/setup.EXIT_RECORD` (`npm-ci IDENTITY attempt=fake state=released`, `FINAL rc=90`, `EXCLUSION_UNPRESERVED`) and `$S5X_EX/logs/setup-v1/attempts/attempt-fake/IDENTITY` (`pid=<sid> attempt=attempt-fake … self_sid=<runner sid>`), launches `( exec setsid sleep 8 ) 9>&- &`, waits until `/proc/<sid>` exists, `exit 90`. Expected against launcher v2: `SELF_HOLD reason census=live`, lock busy while `sleep` lives, then `LEASE_RELEASE how=self-hold-then-empty raw=observed 90 final_rc=90` after the inner sid is positively empty; against v1 (not to be run) it would release immediately with `cleanup=verified-empty` (B's demonstration). Bounded by the 8 s sleep; no npm. |
| C7 | A-03/B-03 control gap | new case X6 | `normal-release-fail`: `normal` scenario with `$EXD/LEASE_RELEASE` made a directory after `state=RUNNING`; assert live holder, busy lock, `state=SELF-HOLD`; repair exactly as C2; assert `how=self-hold-then-empty`, exit 90. |
| C8 | A-07 | new case X7 | `signal-running`: `overrun` scenario, ctl sends TERM to `$LPID` after `state=RUNNING`; assert LEASE_RELEASE `raw=observed (143|124|137)` (not `none`) and `cleanup=escalated(rc=0)`. |

Driver pins (`PIN_L`) and headers updated to the v2 hashes; expected count becomes 9 checks (static expectation). Boundedness statement must keep A's point: the driver is bounded; a retained private holder is an accounted exceptional outcome reported as `UNRESOLVED`, never killed to satisfy a duration.

### 3. Primitive block inside launcher and runner (parent: explicit applicability, not assumed)

Recommendation: embed **OWN-BLOCK v10.1** (`own-block-v101.sh` `4aebf96f…`) in launcher v2 and in a runner `v10.1x` (v10.1 setup consumer `5f94783b…` + the v10x inherited-lease hunk, which is the only v10→v10x delta, `setup-v10-to-v10x.diff` +11/−1). Applicability to justify explicitly in the dual review: the launcher uses `own_finish`/`own_collect`/`own_retire`/`own_group_current`/`own_reap_all`/`own_census`; v10.1 changes only `own_finish` (collects leader; refuses second wait), `own_collect` (reports SESSION_RETIRED/KEPT), `own_retire` (rc2 keeps live/unknown session) — each strictly narrows a release-enabling behaviour A-02 relies on. Fallback if the parent prefers unchanged v10 bytes: §1 L1–L2 remain correct because no decision reads the registry; only the `COLLECTED rc=127` double-wait wart persists in logs. Either way the launcher is a **new consumer** whose applicability is reviewed on its own head; V10.1 fake-child results do not transfer.

### 4. Observer `observe-s5-setup-exclusion.v1.sh` → `v2` (A-05)

Line 6–9: `CUR` empty with `/proc/$P` present ⇒ `HOLDER_UNKNOWN` (exit 3), not gone. Non-live branch accepts `LEASE_RELEASE` only if it contains `token=$TOK holder_pid=$P start_time=$ST` parsed from the same `LEASE_HOLDER` snapshot; otherwise `HOLDER_GONE_RELEASE_MISMATCH` (exit 2, unresolved). Read-only fixture with two tokens and a stale release suffices for review; no execution needed to specify.

### 5. Not changed / explicitly out

- Canonical paths, `npm ci` argv/env/pins/lock fd 9, provenance gates, HOLD_BOUND branch of the runner (kept; redundant under option (a) but harmless), S2 setup scripts, S6, product source.
- No recovery-transfer framework, no generic supervisor, no new dependency, no `rm -rf`, no pattern kills, no sleeps-as-proof.
- No claim that a 9-PASS private run proves canonical installation exclusion: it proves launcher v2 behaviour on synthetic children including one setsid sub-session; canonical use still needs dual exact final-head review, fresh source/dependency/resource prerequisites and a separate grant.

## Smallest execution order once a directory is assigned

1. Launcher v2 (L1–L6, optional L7) + observer v2 + fake-runner v2 + ctl v2 + runner v10.1x (or keep v10x if parent declines §3); exact diffs vs the 9 frozen files; `bash -n` only; pins; non-self-including manifest.
2. Dual exact review of that packet (A-01..A-07, B-01/02/03/06 closure map; §3 applicability explicit).
3. Private fake control grant: X1–X7 on a fresh resolved noncanonical `S5X_OUT`, actual driver exit captured, all records retained, any retained holder reported to the parent by pid/token (not killed).
4. Only then: canonical setup grant discussion (fresh setup prerequisites unchanged).

## Estimated size (for parent budgeting, not a claim)

Launcher: ~25 changed/added lines, ~6 deleted. Ctl: ~20 changed/added, ~5 deleted. Fake runner: +6. Observer: ~4 changed. Runner: header + block re-embed only (if §3 accepted).
