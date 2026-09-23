# S5-V2-RESULT-B — independent nonbuilder review of the failed S5 setup-exclusion V2 fake diagnostic and its X6 recovery

Reviewer: independent lens B (nonbuilder, non-executor; requested Claude Fable 5 / High is a routing setting, not observed runtime identity). Parent owner EXEC-6c2a68ac. Assignment: `tgp-private-evidence/execution/6c2a68ac/SCOPE.md` §"S5-V2-RESULT-A and S5-V2-RESULT-B". Rules: `tgp-startup/live/AGENT_RULES.md` G01–G22 (G04, G05, G07, G09, G10, G11, G20 applied).

Method: read/hash/diff only. No code, probe, signal, lock operation, recovery or rerun was performed. No peer result output, no `audits/s5-v31-a`, and no `S5_V2_RESULT_AND_RECOVERY_DISPOSITION.md` was read. All hashes below were recomputed by this reviewer from the archived bytes on 2026-09-23 (PDT morning).

## 1. Exact binding (all verified by recomputation)

| Item | Expected (grant / report) | Observed | Status |
|---|---|---|---|
| V2 control grant `execution/e8d546f9/S5_SETUP_V2_CONTROL_GRANT.md` | `a30e1602…83b7` (RESULT.md, PREFLIGHT) | `a30e160288632c1521073a98650676ef0e2a2fdea2507088bb9c93d71fac83b7` | MATCH |
| X6 recovery grant `execution/e8d546f9/S5_V2_X6_RECOVERY_GRANT.md` | `1c54c032…8de6` (RECOVERY_REPORT) | `1c54c032204b428bc8c3f4f8fc774a51aa85afcfb8dd2fc53546256f8b880de6` | MATCH |
| Frozen V2 packet `remediation/s5-setup-exclusion-v2/SHA256SUMS.s5-setup-exclusion-v2` | `b96dc732…` 33/33 | `b96dc732fcc63544fe7db05c753793403fd47ae8f43d51d7d91c0297fd02c06c`; 33/33 OK | MATCH |
| Driver `controls-exclusion/ctl-exclusion.v2.sh` | `62a7233f…` (CTL_START) | `62a7233fc1c3405b0ed6874c0ebdc8ff64eaa210691db59b6190f2d16df1fd3c` | MATCH |
| Launcher `launch-s5-setup-exclusion.v2.sh` | `b32cc20d…` (grant, LEASE_HOLDER) | `b32cc20d0dbfa2490fad1d642f1044791f73c9f377ec8a9958d8471699df1c09` | MATCH |
| Fake runner `controls-exclusion/fake-runner.v2.sh` | `5c18e3b3…` | `5c18e3b320f6be15053a0a6667009cf14cbfe29f337090ae5a966962ffdbee0f` | MATCH |
| `exact-command.sh` vs grant ```sh block | byte-identical | both `ee49b886036663f0bc06c9b639c35400e035d8efc11907a2ef1e9189819b1abb`; `diff` empty | MATCH |
| S4 addendum seal precondition (`T1-activate-utc.txt`, PREFLIGHT) | `699a554a…` | `s4-native-npm-log-addendum/MANIFEST.sha256` = `699a554aa7247c…` | MATCH |
| Original result manifest `SHA256SUMS.s5-setup-v2-control-result` | `3c3fc4e2…` (recovery grant) byte-identical, not rewritten | `3c3fc4e2340c445d958a82c4472cc458dc5cd4acc898f046d56e0d805637eb06`; 66 entries; non-self-including | MATCH |
| `pre-recovery-snapshot/SNAPSHOT.sha256` | copies at 02:09:57Z | 6/6 OK | MATCH |
| `x6-recovery/POST_RECOVERY_MANIFEST.sha256` | additive, non-self-including | 20/20 OK from packet root; does not list itself | MATCH |
| `ARCHIVE_POST_RECOVERY.sha256` (archive-time, 86 entries) | whole packet post-recovery | 86/86 OK; does not list itself | MATCH |

Preflight 17/17 (`PREFLIGHT.txt`), post-accounting packet 33/33 unchanged (`POST_ACCOUNTING.txt`), EUID 2000, fresh `data/` absent before launch, canonical `execution/s5-r4` absent and canonical lock fd links 0 before/after — all present in the packet and internally consistent.

## 2. Raw result: raw 1, 8 PASS / 1 FAIL, stopped at X6 — preserved and truthful

- `ctl.log` (both the wrapper copy and `data/20260923T020459Z/ctl.log`) ends `FAIL X6.normal_release_failure_holds` → `STOP_ON_FIRST_FAILURE` → `UNRESOLVED launcher pid=26214 … still holding` → `SUMMARY pass=8 fail=1`; wrapper line `ctl-exclusion.v2 rc=1`; `ctl.exit` = `1`. The exit is the driver's own `check()` exit 1 (driver source L18), not the outer `timeout` (driver ended 02:06:39Z, 100 s into the 230 s bound). The grant's expected `pass=11 fail=0` with no UNRESOLVED line was not met.
- Checks 1–8 PASS lines are backed by the per-case `LEASE_RELEASE` / `launcher.EXIT_RECORD` raw facts enumerated in `POST_ACCOUNTING.txt` (X1 exit 0; X2 rc 90 escalated; X3 raw 124; X4 self-hold-then-empty rc 90 after driver's own exact repair; X5 raw 90 released after inner sid empty). Raw child statuses are reported without normalization, as the grant required.
- Checks 10 (`X6.release_after_exact_repair`) and 11 (`X7.signal_raw_latched`) are correctly reported NOT RUN. The driver source confirms L67–71 never executed after the L66 exit. No later check result is claimed anywhere in the packet.

Assessment: the failed result is preserved exactly and stays FAILED. Nothing in the recovery packet re-labels it.

## 3. The X6 failure and the failed-operand uncertainty

Driver L66 evaluates a four-operand conjunction immediately after `wait_text … 'RELEASE_RECORD_FAILED' 30` returns on the first such line: (a) `kill -0 $LPID`, (b) `! lock_free private.lock`, (c) `grep 'state=SELF-HOLD' LEASE_HOLDER`, (d) `grep 'reason=\[release publication failed (normal' SELF_HOLD`. Only the conjunction's exit status is logged. FAIL was logged at 02:06:39Z, the same second as the first `RELEASE_RECORD_FAILED` line in the X6 `launcher.EXIT_RECORD`.

Launcher source (L184–193): `release()` fails `own_record` → logs `RELEASE_RECORD_FAILED` → returns 1; caller enters `self_hold()`, which first calls `publish_state SELF-HOLD` (L189, rewrites `LEASE_HOLDER`), then `record_or_fallback SELF_HOLD …` (writes the reason), then loops. Both (c) and (d) become true only *after* the line the driver waited for. (a) and (b) have no evident reason to be false (the holder was alive with fd 9 on the private lock at 02:07:07Z, 02:09:56Z and 02:16:20Z).

Conclusions I can bind to evidence:
- The driver does **not** record which operand was false. The executor's RESULT.md states this explicitly and does not invent one. Correct.
- Every later read-only observation (STOP_STATE 02:07:07Z, RETAINED_OWNER_FACTS 02:09:56Z, RECOVERY_LOG 02:16:20Z) shows all four checked properties holding (alive, fd 9 → private lock, `state=SELF-HOLD`, SELF_HOLD reason present). The property the check describes — "v1 exited here; v2 holds" — was exhibited by the launcher for ~9 min 42 s. This is consistent with a driver-side ordering race (wait trigger precedes the writes of (c)/(d)) and inconsistent with the v1 regression (exit on publication failure).
- That consistency is **not proof**. The FAIL stands as the attributable result of this execution; the cause is an unverified hypothesis until a corrected harness records per-operand results or a positive observation at check time exists. No V2 rerun is warranted or requested; any correction is a driver change requiring its own applicability review (V3 lineage), which is outside this assignment.
- Minor accuracy note: STOP_STATE's sequencing summary ("RELEASE_RECORD_FAILED → SELF_HOLD published → first HEARTBEAT → publish_state SELF-HOLD (L193)") omits the earlier `publish_state SELF-HOLD` at L189. It does not change the conclusion (both writes post-date the wait trigger) but the summary is incomplete. Nonmaterial.

## 4. Immutable pre-recovery copies vs point-in-time drift

- Original manifest `3c3fc4e2…` (≈02:08Z) verifies 63/66 against the archive today. Exactly three entries fail: `X6/LEASE_HOLDER` (heartbeat-rewritten, then RELEASED), `X6/logs/setup-exclusion/launcher.EXIT_RECORD` (appended 202 → 578 → 579 lines), and `X6/LEASE_RELEASE/LEASE_RELEASE.tmp.26214` (removed; `LEASE_RELEASE` is now a regular file). This equals the drift disclosed in RECOVERY_REPORT.md. The manifest was not rewritten.
- Immutable copies exist at two instants and are prefix-consistent: `pre-recovery-snapshot/X6.launcher.EXIT_RECORD.snapshot` (202 lines, `54b28968…`) == `head -202` of `x6-recovery/pre/launcher.EXIT_RECORD` (578 lines, `d79522ea…`) == `head -578` of `x6-recovery/post/launcher.EXIT_RECORD` (579 lines, `ecf74d7b…`), whose last line is the single `LEASE_RELEASED … final_rc=90`. The only non-heartbeat lines in the whole X6 record are LAUNCHER_START, LEASE_HELD, RUNNER_LAUNCH, RUNNER_RAW rc=0, SESSION_CENSUS empty, SELF_HOLD published/reason, and the final LEASE_RELEASED — no signal, escalation, handoff or recovery line. `SELF_HOLD` is byte-identical (`2a94dcd4…`) in manifest, snapshot, pre, post and live.
- Finding (low): RESULT.md's freeze note says "those two files will diverge … Everything else is static." A third file also mutated: the deposit `LEASE_RELEASE.tmp.26214` was rewritten every heartbeat with a fresh `released_at=` (manifest `97977e2a…` @≈02:08Z, `d45ed84c…` @02:09:55Z per RETAINED_OWNER_FACTS, `9866e629…` @02:16:19Z in `x6-recovery/pre/`). REPAIR_PAYLOAD.md and the three-entry list in RECOVERY_REPORT.md disclose this correctly, so the packet as a whole is truthful; RESULT.md's sentence alone is inaccurate. Nonblocking.

## 5. Recovery: exactly the permitted operation, nothing else

Grant `S5_V2_X6_RECOVERY_GRANT.md` vs `x6-recovery/RECOVERY_LOG.txt`:
- Revalidation immediately before repair: PID 26214, starttime 519891, SID/PGID 26214, EUID 2000, exact launcher cmdline and sha, fd 9 → `X6/private.lock`, token `20260923T020634Z-26214-18852` in LEASE_HOLDER and SELF_HOLD, workload session 26278 zero members and leader absent, holder session = bash + one sleep — 17/17 OK, all matching the grant's stated identity. Required by grant: met.
- Obstacle pre-check: real non-symlink directory mode 755, parent 755, sole entry `LEASE_RELEASE.tmp.26214` regular non-symlink. No chmod needed or performed. Required by grant ("refuse unexpected contents before deleting anything"): met.
- Repair: `rm -f` of that one deposit, then `rmdir` of the empty directory, attempt 1 of 5, `REPAIR_STATUS=0`. No recursion, wildcard, rename, synthetic RELEASE, signal, lock probe or source change appears anywhere in the log. Matches the driver's own `repair_marker_dir` shape (L32–36) and the grant's restriction.
- Observation: `/proc/26214` absent ≈0.5 s later, well inside the 30 s read-only budget; holder and workload sessions 0 members; readable fd links to the private lock none; canonical lock links 0. No signal was sent.
- Original manifest not rewritten; earlier snapshot not overwritten (SNAPSHOT.sha256 6/6 OK); additive POST_RECOVERY_MANIFEST 20/20 OK.
- Disclosed deviation: recovery grant file was untracked in the private repo at read time (HEAD `9e317831…`). The hash of the tracked copy I reviewed equals the hash the executor read, so the executed grant text is the one now archived. This closes the provenance gap for content; the parent's ACTIVATE mail itself is not in the packet (accepted as parent-side record).
- Qualification: the grant asked to "preserve repair command/output/status". Output and status are preserved verbatim; the exact executed script text is not (REPAIR_PAYLOAD.md is the pre-grant proposal and lacks the pre-check that RECOVERY_LOG shows was executed). The log's effect record is sufficient to bound what happened; the command text gap is a documentation shortfall, nonblocking.
- Cosmetic: RECOVERY_LOG timestamps `02:16:21.99491905Z` (rm) then `02:16:21.103499737Z` (rmdir) read out of order; this is unpadded nanoseconds (`.099491905`). Ordering rm → rmdir → holder gone at `.609` is otherwise consistent. Nonmaterial.

## 6. final90: recorded intent, not wait-observed

The launcher's own records (`LEASE_RELEASE` regular file, EXIT_RECORD line 579, `LEASE_HOLDER state=RELEASED(self-hold-then-empty)`) state `final_rc=90`, and launcher source L191 shows the `self-hold-then-empty` branch calls `release … 90` → `exit 90`. The process's wait()er was the driver, which exited at 02:06:39Z; 26214 ran with ppid 1. No wait-observed exit status and no attributable exit receipt exist. RECOVERY_REPORT.md and RECOVERY_LOG.txt state exactly this and do not report a reaped 90. Correct; anyone citing "exit 90" for X6 must say "recorded intended final status corroborated by process disappearance", not "observed exit 90".

## 7. Scoped slot closure

Evidence supports closure of the **private V2 fake-diagnostic runtime slot only**: driver exited; X1–X5 launchers gone (STOP_STATE); X6 holder gone with sessions empty and no readable fd link to the private lock; frozen packet 33/33 intact before and after; canonical lock never opened (fd links 0 throughout); `execution/s5-r4` absent; no npm/network/source/worktree mutation. Residual unknown, disclosed by the executor: 63–64 `/proc/*/fd` entries of other users were unreadable at each census; a foreign holder of a freshly created EUID-2000 private lock file is implausible but was not positively excluded. This does not affect canonical state because no canonical lock was involved.

Closure does not clear anything else: not the V2 control result (FAILED), not canonical A01/A02/B01/B02, V3, setup/T0, S6 or product acceptance, and not the corrected-harness question in §3.

## 8. Verdict (bounded)

ACCEPT, with qualifications, the following as accurately evidenced:
1. Exact source/grant/command/result/recovery binding (§1).
2. Raw 1, `SUMMARY pass=8 fail=1`, STOP at check 9 (`X6.normal_release_failure_holds`), checks 10–11 NOT RUN; the V2 diagnostic remains FAILED (§2).
3. No failed operand was invented; cause remains unestablished; a driver-side ordering race is the plausible but unproven explanation (§3).
4. Original manifest preserved byte-identical; drift limited to the three disclosed X6 entries; immutable copies at 02:09:57Z and 02:16:20Z are prefix-consistent with the final record (§4).
5. Recovery was exactly the granted one-time fixture repair with full identity revalidation, no signal, no lock touch, one attempt (§5).
6. X6 final status is recorded intent (90) plus process disappearance, not a wait-observed exit (§6).
7. Private V2 slot accountably closed; nothing beyond it is cleared (§7).

Qualifications (nonblocking): F-B-01 RESULT.md "everything else is static" understated drift (deposit also mutated); F-B-02 executed repair script text not preserved verbatim; F-B-03 STOP_STATE sequencing omits launcher L189 `publish_state`; F-B-04 unpadded-nanosecond timestamps in RECOVERY_LOG; F-B-05 unreadable-process boundary (disclosed). Details in `FINDINGS.md`.

Material blocking findings against this evidence packet: **none**. Material open item (not a defect in the packet): the X6 check's per-operand truth at 02:06:39Z is unrecoverable from this run; V2 cannot be declared passing and must not be rerun under this grant.

## 9. Smallest next action

Parent accepts scoped closure of the private V2 slot on this evidence and records the V2 diagnostic as FAILED-at-X6 with cause unestablished. The only substantive follow-up is outside this assignment: when a corrected driver is next reviewed (V3 lineage), require that a failed conjunction log each operand's result and that the X6 wait trigger be the launcher's `SELF_HOLD reason=` line (or LEASE_HOLDER `state=SELF-HOLD`) rather than the first `RELEASE_RECORD_FAILED` line. No V2 rerun, no new framework.

## Sources read (all local, read-only)

- `tgp-private-evidence/execution/6c2a68ac/SCOPE.md`; `tgp-startup/live/AGENT_RULES.md`
- `tgp-private-evidence/execution/e8d546f9/S5_SETUP_V2_CONTROL_GRANT.md`, `S5_V2_X6_RECOVERY_GRANT.md`
- `tgp-private-evidence/2026-09-23/e8d546f9/s5-setup-v2-control-result/**` (RESULT.md, STOP_STATE.txt, PREFLIGHT.txt, POST_ACCOUNTING.txt, ctl.log, ctl.exit, ctl.pid, T1-activate-utc.txt, exact-command.sh, SHA256SUMS.s5-setup-v2-control-result, ARCHIVE_POST_RECOVERY.sha256, pre-recovery-snapshot/*, x6-recovery/*, data/20260923T020459Z/**)
- `tgp-private-evidence/2026-09-23/e8d546f9/remediation/s5-setup-exclusion-v2/` (SHA256SUMS, `controls-exclusion/ctl-exclusion.v2.sh`, `launch-s5-setup-exclusion.v2.sh` L115–200, `controls-exclusion/fake-runner.v2.sh` hash only)
- `tgp-private-evidence/2026-09-23/e8d546f9/s4-native-npm-log-addendum/MANIFEST.sha256` (hash only)
- Not read: any `audits/s5-v31-*`, any `s5-v2-result-a`, `S5_V2_RESULT_AND_RECOVERY_DISPOSITION.md`, prior V2 source reviews A/B (hashes verified via PREFLIGHT only).
