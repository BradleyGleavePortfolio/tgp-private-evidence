# OP88-S5-SETUP-EXCLUSION v2 — findings map, implemented/tested/unrun truth, bounded request

Builder: S5-V101-BUILD (sole writer of this directory, per parent approval of proposal 9f0fe0f7). Static build only: edits, `bash -n`, `diff`, `sha256sum`, `grep`. **Nothing was executed**: no launcher/runner/control/fake/observer invocation, no lock, no process, no network, no install, no commit. All PASS expectations below are static traces, not evidence.

## Exact inputs (all copies under `inputs/`, verified before use)

| Input | sha256 |
|---|---|
| Frozen setup-exclusion packet manifest `SHA256SUMS.s5-setup-exclusion` (9/9 verified) | `0a69011150799ecdb31f46452ff92cede7075190906b851e39d6b5ebcb0758a7` |
| `launch-s5-setup-exclusion.v1.sh` | `1773ac7d2b37670c2dd711347a3cc1515fb5fbb68adcc680381a26434f30e033` |
| `run-s5-setup-npm-ci.v10x.sh` / `setup-v10-to-v10x.diff` | `3a7b57d1…` / `62161144…` |
| `controls-exclusion/ctl-exclusion.v1.sh` / `fake-runner.sh` / `observe-s5-setup-exclusion.v1.sh` | `2de9500f…` / `230ff6c5…` / `157bf1f4…` |
| V10.1 `own-block-v101.sh` (from frozen packet manifest `45accac9…`) | `4aebf96f6b7c8962b7a4b10dfc25acb7a793a24744bc0e79de77675031b1c6c5` |
| V10.1 `run-s5-setup-npm-ci.v101.sh` | `5f94783b44850cce3a16fc9ba68b75b572aa4b8125bc6a2e63fd650b8af98087` |
| Review A `setup-exclusion-a/REPORT.json` (manifest `c7958e2b…`) ; Review B `FINDINGS_B.json` (manifest `cb976bbd…`) | copied as `inputs/setup-exclusion-a.REPORT.json`, `inputs/setup-exclusion-b.FINDINGS_B.json` |
| Approved change map | `inputs/SETUP_EXCLUSION_CHANGE_MAP.9f0fe0f7.md` |

## Outputs (new hashes; see `SHA256SUMS.s5-setup-exclusion-v2`)

- `launch-s5-setup-exclusion.v2.sh` (223 lines; OWN-BLOCK v10.1 embedded L25–L133, byte-identical to `inputs/own-block-v101.sh`; pins runner v101x)
- `run-s5-setup-npm-ci.v101x.sh` (V10.1 setup + the exact v10x inherited-lease hunk: +5 header comment lines, +6/−1 body lines, hunk body byte-identical to `setup-v10-to-v10x.diff`; no other change)
- `observe-s5-setup-exclusion.v2.sh`, `controls-exclusion/ctl-exclusion.v2.sh` (11 checks, pins launcher v2), `controls-exclusion/fake-runner.v2.sh`
- `diffs/*.diff` (launcher v1→v2 full and consumer-only; runner v101→v101x and v10x→v101x; observer, ctl, fake), `verify-embedded-block.sh`, `SYNTAX_CHECKS.txt`

## Findings → exact change (line numbers are v2 unless stated)

| Finding | Change | Where | Tested? |
|---|---|---|---|
| **S5X-A-01 / SEB-B-01** inner npm session invisible to the outer census | `inner_sids()` reads only `$EX/logs/setup-v1/attempts/*/IDENTITY` records with ` self_sid=$SESSION ` (the runner's own published record; `pid=` is the inner sid). `session_state()` runs `own_group_current` over `$SESSION` **and** every inner sid; typed result `CENSUS=empty|live|foreign|unknown` (+ `CENSUS_DETAIL`, `INNER`). `runner_truth()` records the runner's `released/FINAL/EXCLUSION_UNPRESERVED/CLEANUP_FAILURES` truth; `released=1` with no readable bound IDENTITY ⇒ `unknown`. Inner sids are censused only — never added to `OWN_PGIDS`, never signalled. Every release path requires `CENSUS=empty`. | launcher L161–L179; normal path L217–L223; `exceptional` L195–L198; `self_hold` L188–L193 | unrun; control X5 (static expectation) |
| **S5X-A-02** registry emptiness used as proof; FOREIGN treated as empty | `census_state` deleted; no consumer decision reads `own_census` rc; foreign and unknown stay unresolved (SELF-HOLD). v10.1 block additionally keeps session authority on leader exit and refuses a second `wait`. | launcher L172–L179, L217–L223 | unrun; static greps in `SYNTAX_CHECKS.txt` |
| **S5X-A-03 / SEB-B-03** normal release failure fell out of the script; nothing-launched failure fell into the spawn | `release` returns only on publication failure; normal caller now continues into `self_hold "release publication failed (normal; session empty)"`; nothing-launched callers `say` + `exit 74` (no owned work exists) instead of continuing to launch | launcher L219 (normal caller), L201–L202 (nothing-launched) | unrun; control X6 |
| **S5X-A-04** handoff acceptance ≠ continuing exclusion | **Capability deleted** (parent disposition): `handoff_accepted`, `RECOVERY_ACCEPT` read and `release "handoff"` removed; `RECOVERY=none` constant; SELF-HOLD ends only on `CENSUS=empty` + publishable RELEASE | launcher header, L188–L193 | control X4.hold_persists_no_handoff (static grep + runtime persistence) |
| **S5X-A-05** observer accepts a stale release / calls unreadable identity gone | Observer v2: single `LEASE_HOLDER` snapshot; `/proc` present but unreadable ⇒ `HOLDER_UNKNOWN` (rc3); release accepted only when it names the same `token holder_pid start_time` else `HOLDER_GONE_RELEASE_MISMATCH` (rc2); unreadable release ⇒ unresolved. Launcher `preserve_prior()` moves a prior attempt's `LEASE_RELEASE`/`SELF_HOLD` to `$LOGS/prior/<token>.<name>.<ts>` before publishing the new holder (mv only; nothing deleted). | observer v2 whole file; launcher L145–L149 | unrun; no control added (read-only fixture suffices for review, per A) |
| **S5X-A-06** X1 wrong IDENTITY path; weak X2/X3/X4 assertions | X1 asserts `$EXD/logs/setup-exclusion/attempts/*/IDENTITY` (launcher `OWN_ROOT`); X2 asserts `raw=observed 0` and `cleanup=escalated(rc=0)`; X3 asserts `final_rc=$RC` equals the actual launcher exit and `RC∈{124,137,143}`; X4 installs the fixture at the acknowledged `state=RUNNING` point and asserts the `RELEASE_RECORD_FAILED` reason | ctl L41, L44, L47, L49–L52 (X4 fixture at `wait_state RUNNING`) | unrun |
| **SEB-B-02** `rmdir` fails after `own_record` moved its tmp into the directory; orphan holder | `repair_marker_dir <dir> <name>` removes exactly `<dir>/<name>.tmp.<launcher pid>` (the only file `own_record` can deposit: `local tmp="$1.tmp.$$"`) then `rmdir`; up to 5 bounded retries against heartbeat redeposits; any other content ⇒ `REPAIR_FAILED`, nothing else removed. No `rm -rf`, no `pkill`, no `pgrep -f` anywhere in harness or fakes; a surviving fixture child or holder is reported `UNRESOLVED pid=` and never killed. | ctl L30–L36 (`pid_gone`, `repair_marker_dir`), L55, L67 | unrun |
| **SEB-B-06** fakes do not model the sub-session; vacuous `pgrep -f` | fake v2: descendant publishes its pid (typed `pid_gone` check via `/proc/<pid>` state); new `subsession-90` creates `( exec setsid sleep 10 ) 9>&- &`, waits until it is its own session leader, publishes IDENTITY (`pid=<sid> … self_sid=<runner sid>`) and EXIT_RECORD (`state=released`, `EXCLUSION_UNPRESERVED`, `CLEANUP_FAILURES=1`, `FINAL rc=90`), exits 90; new `normal-slow` (sleep 4) opens the X6 window | fake v2 L8–L18; ctl X2 (L42–L44), X5 (L59–L62) | unrun |
| **S5X-A-07** RAW lost on signal path; publication scalar overwritten; RELEASED announced before final write | `latch_raw()` performs the in-shell `own_finish` as soon as absence is verified (in `exceptional` after escalation and on every heartbeat; v10.1 refuses a second wait, so no fabricated 127); `pub_add` accumulates causes (`a+b`), never replaces; `release` re-writes `LEASE_RELEASE` once if the final holder update fails | launcher L154 (`pub_add`), L180–L187 (`latch_raw`, `release`); ctl X7 (L70–L71) | unrun |

## V10.1 primitive applicability (explicit, not inherited)

Launcher v2 and runner v101x embed OWN-BLOCK v10.1 `4aebf96f` byte-identically (`verify-embedded-block.sh`, static). Consumer use in the launcher: `own_precondition, own_stamp, own_attempt, own_spawn_begin, own_register, own_confirm, own_identity, own_record, own_adopt, own_signal, own_wait_gone, own_finish, own_collect, own_retire, own_group_current, own_reap_all, own_alive, own_pending`. The v10.1-changed functions matter here as follows: `own_finish` collects the leader once (enables `latch_raw` without a fabricated 127); `own_collect` in heartbeats/escalation no longer removes the outer session authority on leader exit (`SESSION_KEPT` on live/unknown), so `own_reap_all` and `own_census` still cover the outer session; `own_retire` in the normal-empty path removes authority only after `own_group_current` rc1/rc2. Launcher v2 correctness does **not** depend on registry emptiness (decisions use `session_state` over explicit sids), so it would also be correct with the v10 block; the v10.1 block removes the double-wait wart and authority erasure. This composition (v2 launcher + v101x runner + v10.1 block) is a **new consumer** requiring its own dual exact review; V10.1 T0 control results and any V10 results do not transfer.

## Disclosed residuals (not new findings; carried or design decisions)

- **Foreign inner sid ⇒ indefinite SELF-HOLD** until the number is free: `own_group_current` returns `foreign` (rc2) before listing session members, and the launcher keeps v1's policy (foreign = unresolved). A positive `own_session_members`-empty check could resolve some foreign cases, but that would be a new invariant claim; not made here. The holder is observable (LEASE_HOLDER state, SELF_HOLD record, heartbeats) for out-of-band parent decision.
- Inner sessions are never signalled by the holder; a hung npm session means an indefinite, observable hold (parent disposition: retain until positively empty).
- `SELF_HOLD` primary record is overwritten by the `retry` line before release (B retention note, Low; entry reason remains in `launcher.EXIT_RECORD`).
- No EXIT trap (parent declined L7): an unexpected bash abort still leaves no RELEASE record; observer reports `HOLDER_GONE_NO_RELEASE`.
- `preserve_prior` runs after `flock` (lease held) and before the holder record; a prior record that is a directory is moved as-is.
- `exceptional` runs `own_reap_all` in `$(...)` as v1 did (output capture); it signals only, so the subshell does not affect registry state.
- `own_record` onto a directory still deposits `<name>.tmp.<pid>` inside it (primitive behaviour, V10.1 C5b residual); the harness repair is scoped to exactly that file.
- Static trace only for timing (X4 ≈ 35 s escalation + repair; X5 ≈ 12–15 s; total ≈ 110–130 s).

## Not changed

Canonical paths, `npm ci` argv/env/pins/lock fd 9, provenance gates, HOLD_BOUND branch, V10/V10.1/9-file packets (immutable), S2 setup, S6, product source. No new runner logic or pins beyond the launcher's `PIN_RUNNER` and the driver's `PIN_L` reflecting the new bytes. No generic supervisor, no recovery-transfer framework.

## Bounded request (see `CONTROL_REQUEST_V2.md`)

Private fake-only control run of `controls-exclusion/ctl-exclusion.v2.sh` (X1–X7, 11 checks) on a fresh resolved noncanonical `S5X_OUT`, after two independent exact reviews of this packet. No canonical setup request is made.
