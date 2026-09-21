# L1-S4-PROBES — light-grant result (offline predecessor controls)

Grant: parent mail 2026-09-21 16:48 PDT, "LIGHT L1-S4-PROBES", explicit exception, not a heavy-slot transfer. Canonical lock NOT taken (stamped in every meta as `NOT taken — parent light grant L1-S4-PROBES`). No network, install, browser, package, broad suite, source edits, or shared/tmp writes. All writes inside `execution/s4-r4/`.

## Targets

| target | identity | how loaded |
|---|---|---|
| candidate | head `2bcf1563d85bc2109e99805e4ce1b06fce4dcdb3`, tree `3e23f91824689d1f179a116af948eae0ed5ae170`, `git status --porcelain` empty before and after | lane worktree `/home/user/workspace/worktrees/s4-r4` |
| predecessor (base) | commit `84471e99b278e964f7cb3f6bf9c78491064c41b7`, tree `f31a978034d0aa8a2c39615ade5ec0255a19b1d0` | `git archive 84471e99 \| tar -x` into `execution/s4-r4/artifacts/base-84471e99-export/` (no new worktree, no /tmp). Exported `shared/session.js`, `background.js`, `shared/replay/engine.js`, `test/helpers/background-mock.js` verified byte-identical to `git show 84471e99:<path>` (sha256 match). The export has no `.git`, so the probe JSON `head` field carries `PROBE_HEAD=84471e99…` and says so. In the base runs the wrapper meta `head/tree/worktree` fields describe the lane worktree (stamp context), while the probe JSON `root`/`head` identify the actual base target. |

Probe bytes (identical for candidate and base runs, stamped in each meta `probe_sha256`):
- `scripts/coalescer-admission-probe.mjs` sha256 `4f65b3fde38111af1e604a058084ddd5d5da4f7eab967b30ac5020c9e139ea30` (adapted from audit A `coalescer-transition-probe.mjs`; adds `headOf()` fallback only)
- `scripts/stale-caller-probe.mjs` sha256 `b39d2181822ad21e138100ad815b15afe66fb2b48efaaf0255da1be770bf1b02` (adapted from audit A `stale-caller-probe.mjs`; waits for terminal `ingest_failed` snapshot OR `auth_required`; adds `headOf()` fallback)
- wrapper `scripts/run-slot.sh` sha256 `fb04321ef42ba6bb0847e83ff97a6f7357c115f61f31c059052e04941436246c`

## Disclosed harness error first (L1-01..L1-04)

The first four invocations (23:49:35–41Z) did NOT run any probe: `run-slot.sh` `cd`s into the target worktree and I passed the probe paths relative to `execution/s4-r4`, so node reported `MODULE_NOT_FOUND` (exit 1 ×4, ~8 s). No candidate or base code was loaded, so this is a worker harness-invocation error, not a candidate failure and not a probe outcome. Logs/meta retained unchanged; note in `logs/L1-01..04-HARNESS-INVOCATION-ERROR.md`. The four probes were then invoked once more with absolute paths (L1-05..L1-08). This was not a rerun of a failed probe — the probes had not executed.

## Results (L1-05..L1-08, 23:50:07–10Z, ~2 s combined; total grant wall time ≈ 10 s incl. the failed invocations)

| label | target | probe | exit | expected | key recorded facts |
|---|---|---|---|---|---|
| L1-05 | candidate 2bcf1563 | coalescer-admission | **0** | 0 | 1 refresh fetch presenting `NEW_SYNTHETIC_REFRESH`; both callers got `MINTED_SYNTHETIC_ACCESS`; stored refresh `ROTATED_SYNTHETIC_REFRESH`; `pass:true` |
| L1-06 | base 84471e99 | coalescer-admission | **1** | non-zero | 2 refresh fetches, both presenting `NEW_SYNTHETIC_REFRESH` (duplicate presentation = S4-R3-A-01/B-01); second caller got `null`; `pass:false` |
| L1-07 | candidate 2bcf1563 | stale-caller (mode success) | **0** | 0 | replacement acknowledged `{ok:true}`; after the stale caller settled `tgp_refresh_token = NEW_SYNTHETIC_REFRESH`; `request_session_state → hasSession:true`; `auth_required` count 0; last snapshot `ingest_failed` with lastError "import stopped — your TGP session changed during the import. Start the import again."; no request carried `Bearer NEW_SYNTHETIC_ACCESS`; no `/ingest/complete` call; exactly 1 refresh call; `pass:true` |
| L1-08 | base 84471e99 | stale-caller (mode success) | **1** | non-zero | replacement acknowledged `{ok:true}`; after the stale caller settled session storage EMPTY; `hasSession:false`; `auth_required` count 1; lastError "session expired — please sign in again" (= S4-R3-A-02: obsolete run wiped the acknowledged replacement); `pass:false` |

Discrimination: same probe bytes FAIL on the frozen predecessor for exactly the defect each finding describes and PASS on the candidate. Not covered by L1 (still queued for the heavy slot): stale-reject and stale-timeout modes, the vitest specs, Prettier/ESLint/tsc, gates, package, browser proof.

## Evidence files
`logs/L1-0[1-8]-*.log`, `logs/L1-0[1-8]-*.meta.json` (head/tree/dirty/diff-sha/toolchain node v20.20.1 npm 10.8.2/lock note/command/probe hashes/start/end/exit), `logs/L1-01..04-HARNESS-INVOCATION-ERROR.md`, `logs/L1-SHA256SUMS` (17 entries), `artifacts/base-84471e99-export/` (read-only base tree export).

Candidate source untouched throughout: head `2bcf1563`, working tree clean.
