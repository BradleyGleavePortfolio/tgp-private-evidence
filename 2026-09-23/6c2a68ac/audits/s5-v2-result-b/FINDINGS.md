# S5-V2-RESULT-B findings register

Scope: archived `2026-09-23/e8d546f9/s5-setup-v2-control-result` packet, `S5_SETUP_V2_CONTROL_GRANT.md` (a30e1602…), `S5_V2_X6_RECOVERY_GRANT.md` (1c54c032…), frozen V2 packet b96dc732… (33/33). Independent lens B; no peer or parent disposition read.

## Acceptance criteria (SCOPE.md) — disposition

| Criterion | Result | Evidence |
|---|---|---|
| Exact source/grant/result/recovery binding | MET | All 12 hash bindings recomputed and matched (REPORT.md §1) |
| raw1 and 8PASS1FAIL preserved | MET | ctl.log/ctl.exit; no relabel anywhere in recovery packet |
| Later checks NOT RUN | MET | checks 10–11 absent from log; driver L67–71 unreachable after L66 exit |
| No invented failed operand | MET | RESULT.md states operand unrecorded; driver logs conjunction only |
| Distinguish intended final90 from wait-observed exit | MET | RECOVERY_REPORT/LOG "EXIT STATUS TRUTH" section; wait()er exited 02:06:39Z |
| Original immutable copies and disclosed live drift verified | MET (with F-B-01) | manifest 3c3fc4e2 byte-identical; 63/66 OK; 3 drift entries = disclosed; snapshot/pre/post prefix-consistent |
| Scoped slot closure only | MET | holder gone, sessions empty, canonical lock links 0, packet 33/33; no broader clearance claimed |

## Material blocking findings

None against this evidence packet.

## Material open item (not a packet defect)

**O-B-01 — X6 check truth at 02:06:39Z is unrecoverable.** Driver L66 logs only the conjunction result. Later observations (02:07:07Z, 02:09:56Z, 02:16:20Z) show all four properties holding, consistent with a driver-side ordering race (wait trigger = first `RELEASE_RECORD_FAILED`, which the launcher emits before `publish_state SELF-HOLD` L189 and `record_or_fallback SELF_HOLD` L189). Not proven. Consequence: V2 stays FAILED; correction is a driver change for the V3 lineage with its own applicability review; no V2 rerun under this grant. Owner: parent (routing), future harness builder (fix). Closure evidence needed: corrected driver that logs per-operand results and waits on the SELF_HOLD reason / LEASE_HOLDER state, reviewed by two independent lenses.

## Nonblocking qualifications

**F-B-01 (low, accuracy) — RESULT.md drift statement understated.** Freeze note claims only `X6/LEASE_HOLDER` and `launcher.EXIT_RECORD` diverge and "everything else is static"; the deposit `X6/LEASE_RELEASE/LEASE_RELEASE.tmp.26214` was also rewritten every 2 s (three distinct hashes: 97977e2a… @≈02:08Z manifest, d45ed84c… @02:09:55Z, 9866e629… @02:16:19Z). Disclosed correctly in REPAIR_PAYLOAD.md ("re-written every 2 s heartbeat") and RECOVERY_REPORT.md (three-entry list). Packet as a whole truthful. Closure: note in parent disposition; no rewrite of frozen RESULT.md.

**F-B-02 (low, evidence completeness) — executed repair script text not preserved verbatim.** Grant asked to preserve "repair command/output/status". RECOVERY_LOG preserves output and status and shows a contents pre-check; REPAIR_PAYLOAD.md is the earlier proposal without that pre-check. Effects are fully bounded by the log (one `rm -f` of the named deposit, one `rmdir`, attempts=1). Closure: executor may add the exact script as an additive file if still available; otherwise accept as-is.

**F-B-03 (informational) — STOP_STATE sequencing summary incomplete.** Omits launcher L189 `publish_state SELF-HOLD` (LEASE_HOLDER is first rewritten there, before `SELF_HOLD published`). Does not alter O-B-01. No action.

**F-B-04 (cosmetic) — RECOVERY_LOG sub-second timestamps unpadded.** `02:16:21.99491905Z` precedes `02:16:21.103499737Z` textually; it is `.099491905` with the leading zero dropped. Order rm → rmdir → holder gone (`.609`) is consistent. No action.

**F-B-05 (disclosed boundary) — unreadable process census.** 63–64 other-user `/proc/*/fd` entries were unreadable at each census; "no other fd link to the private lock" is bounded to readable processes. The private lock was created by EUID 2000 in a fresh tree at 02:06:34Z; a foreign holder is implausible and irrelevant to canonical state. No action.

**F-B-06 (disclosed provenance) — recovery grant untracked at read time.** Executor read `S5_V2_X6_RECOVERY_GRANT.md` sha 1c54c032… while untracked in the private repo (HEAD 9e317831…). The now-archived tracked copy has the same hash, so the executed text is the archived text. Parent's ACTIVATE mail is not in the packet; accepted as parent-side record. No action beyond parent confirming the file is now committed.

## What this review does not clear

V2 control result (remains FAILED at X6); canonical A01/A02/B01/B02; V3/V31 source or controls; canonical setup/T0; S6; product acceptance; any runtime activation. Prior V2 source reviews A (fa876aa6…) and B (8b1b53a7…) were verified only as PREFLIGHT hash lines, not re-read.

## Smallest next action

Parent: accept scoped closure of the private V2 slot on this evidence; record V2 as FAILED-at-X6, cause unestablished (O-B-01); carry O-B-01 as a harness requirement into the V3-lineage driver review. No V2 rerun, no new framework.
