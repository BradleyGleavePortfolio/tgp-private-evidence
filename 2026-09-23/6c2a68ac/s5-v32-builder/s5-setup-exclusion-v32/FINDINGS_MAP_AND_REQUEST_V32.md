# S5 setup-exclusion V32 — findings map and source request (T4 builder packet; NOT EXECUTED)

Builder: `repair_s5_binding_mue9vjso` (sole T4 builder, S5-V32). Tier: **T4 static candidate**. Nothing here was run; `bash -n`, `diff`, `patch` (on mktemp copies), `sed`/`grep`/`sha256sum` only, as authorized by parent mail 1.

## Candidate (two-file delta)

| file | sha256 | predecessor |
|---|---|---|
| `launch-s5-setup-exclusion.v32.sh` (launcher v3.2) | `55acc00fe9b04d0e015f37bbdac90e582925c4b4564f7aaaa55c21a13304cf0a` | v3.1 `d5d9b2b8552a6b3f26fcb89a33892135f4954f4c898b985c021378ccc501c630` |
| `run-s5-setup-npm-ci.v101y.sh` (runner v101y) | `61b565e48fa4c14f765fe223bfc3a8baac27ca2867763c91e6a57135fc4ea1b3` | v101x `81ff20b0f62ab91d81b0af00d7688910bf8b223d7463aecd43a1595a66c3742a` |
| `verify-embedded-block.v32.sh` | see `SHA256SUMS.s5-setup-exclusion-v32` | v31 verifier (file names / version text only) |

Embedded OWN-BLOCK v10.1 in both files: sed-extract sha256 `4aebf96f6b7c8962b7a4b10dfc25acb7a793a24744bc0e79de77675031b1c6c5` == `inputs/own-block-v101.sh` (unchanged primitive bytes).

## Finding -> change map

### S5-V31-A-01 (binding, `audits/s5-v31-a/REPORT.md`, current independent finding; binding despite V31-B's lower severity, no vote waiver)
Finding: v3.1 `runner_bound` fallback (b) bound the shared `setup.EXIT_RECORD` by `pgid=$SESSION` **plus** a one-second UTC stamp floor (`SPAWN_TS`). A stale record of an earlier attempt that (i) reuses the session number and (ii) carries an equal-second or future stamp satisfies both, so the launcher would import that record's facts (`released=1 ...`) as this attempt's; number/time correlation is not exact identity.

Closure (exact current-attempt identity in the earliest checked publication, using the inherited unguessable lease token as the parent preferred):

* **Runner v101y L210** (`START`, the runner's first and truncating write): publishes `token=${S5_LEASE_INHERITED:-none}` after `ppid=`. The token is the launcher's `TOKEN` (v3.x L149 `date-pid-RANDOM`), passed only to this attempt's runner via `env S5_LEASE_INHERITED="$TOKEN"` on the spawn line (L232 in v3.2). Standalone runs (no launcher) publish `token=none`. Diff: `diffs/runner-v101x-to-v101y.diff` (+6/-2: 4 header lines, retained-header prefix, L210 line + its comment).
* **Launcher v3.2 `runner_bound`** (L185–189): form (a) unchanged (INHERITED fixed-string line with `path=$LOCK token=$TOKEN`); form (b) now `grep -q "^<UTC stamp>Z START pid=[0-9]* pgid=$SESSION ppid=[0-9]* token=$TOKEN "` — accepted only when the START line carries **both** the outer session we created **and** our token. No stamp is read; `SPAWN_TS` (state line L170 initialisation and the pre-spawn L227 assignment) is removed, restoring the primitive contract shape `publish_state LAUNCHING` -> `own_spawn_begin` -> spawn line. `runner_truth` comment (L193) updated; RUNNER path/pin (L38, L41) point to v101y. Diff: `diffs/launcher-v31-to-v32.diff` (+14/-11); cumulative from v3: `diffs/launcher-v3-to-v32.cumulative.diff` (informational).

Why `pgid=$SESSION` is retained alongside the token: it is structural (record must come from the session this launcher created) and is what P3b proves on the actual platform (parent mail 3). It is no longer load-bearing for identity; the token is.

Why SPAWN_TS is removed rather than kept as a redundant floor: the finding's affected lines are exactly the SPAWN_TS lines; with an exact token match the floor adds no identity, while a wall-clock step-back between HELD and the runner's START would turn it into a false-negative (`not-this-attempt` -> unrecoverable unknown hold on a genuinely bound runner). **Alternative for the parent** (not chosen, one-line): keep the floor as `&& stamp >= SPAWN_TS` after the token match — strictly more conservative against a record that carries our token yet predates our spawn (impossible unless the token leaked), at the cost of the clock-step-back false negative. Static: pattern verified against synthesized lines (ours / fake / stale equal-stamp / stale future-stamp / `token=none` / v101x-shape no-token / other pgid / token-prefix / pgid-prefix / unanchored): only the first two match (`../REPORT.md` §static evidence).

Stale equal/future timestamp negatives: v3.2 reads no stamp, so equal-second, future and past stale records take the identical code path (token mismatch -> `not-this-attempt`). One negative control (P3c, controls packet) exercises the equal/not-before-spawn class with the exact session number; the future class needs no separate case (same path, no stamp operand).

### Preserved (acceptance)
* Early-death liveness (V3-B-01 closure): a runner that dies before its INHERITED line is still bound by its START line (now token-bearing) — P3b unchanged.
* Raw-status truth, no-handoff / last-owner behaviour, release/hold predicates, census, RSTATE logic: untouched (diff confined to header, L38, L41, L170, L185–189, L193, L227 removal).
* OWN-BLOCK v10.1 bytes identical in both files (`verify-embedded-block.v32.sh`, `SYNTAX_CHECKS.txt`).
* Occurrence counts (`kill`/`trap`/`rm`/`flock`/`own_signal`/`exit`/`setsid`) unchanged in launcher and runner.

### Carried, not addressed here (out of scope / non-blocking per parent)
* V31-B-02 (ctl-v31 predecessor hash mislabel) — corrected in the v32 controls header only.
* V31-B-03 / V31-B-04 — informational, carried in `../REPORT.md`.

## Source request
No execution of this packet is requested. The canonical launcher run remains gated on: (1) two independent reviews of these exact bytes, (2) the private controls proof `../s5-setup-v32-controls/REQUEST_V32_CONTROLS.md` passing 11/11, (3) parent grant. Canonical paths (`/home/user/workspace/execution/test-validation.lock`, `/home/user/workspace/execution/s5-r4`) are untouched by the builder; `PIN_RUNNER` is enforced in canonical mode only (private mode uses `S5X_RUNNER`, as before).

## Nonclaims
Nothing executed; no runtime identity asserted; runtime identity of the builder is unasserted telemetry. `TOKEN` entropy is `date -u +%Y%m%dT%H%M%SZ`-`$$`-`$RANDOM` — "unguessable" is the reviewer's/parent's designation, not a cryptographic claim; the closure's property is *exact identity* (a stale record cannot carry a token it never received), not secrecy against an adversary with `/proc` access. No claim about the actual platform's pgid behaviour (P3b proves it if granted).
