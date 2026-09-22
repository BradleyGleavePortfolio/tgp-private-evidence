# S2-V5.4-INDEPENDENT-CLOSURE — Reviewer B report (revision-1, frozen)

Role: independent reviewer B (`s1_r4_independent_audit_b_muc6muwk`), read-only. Scope: narrow actual-delta closure review of the `execution/s2-runner54` packet (v5.4 runner + v54 control driver + stubs + CONTROL_REQUEST_07), not a full product audit. Nothing was executed: no scripts, no `bash -n`, no probes, no install, no DB, no network, no source or fixture change. Peer A's *current* r54 output was not read; only the frozen r53 A/B reports were used as prior input.

Model: requested Claude Fable 5 only; runtime identity is not exposed and is not asserted.

## 0. Bottom line

| Item | Verdict on the actual bytes | Evidence state |
|---|---|---|
| A01/B01 (ownership discarded before quiescence; step-timeout orphan) | **Closed at source** in runner `3f404479`: post-exit quiescence per step L149–L162; group-based halt L100–L118; groups retained L149 | source only; K7/K8 NOTRUN |
| A02 (48 s arithmetic unenforced; unconditional wait) | **Closed at source**: single 50 s deadline L61/L124/L168, clipped polls L98, non-blocking wait L111–L114, bounded anomaly L142–L147, clipped stop L178–L182, status skip L183, forced 71 L190 | source only; K10 NOTRUN; see S2-R54B-03/-04 for bookkeeping caveats |
| A03 (driver kills pre-existing matches on refusal) | **Closed at source** in driver `6638ec06`: refusal L68→`abort` L49 sends no signal; kill list = recorded pids/groups only L29–L43 | source only; N1 NOTRUN; group-record reuse caveat S2-R54B-02 |
| A04 (driver exits 0 on failure; no outer deadline) | **Closed at source**: `finish` L44–L48, `need` L50–L53, `clip` L54, outer `timeout` per runner L61 | source only; N2/N3 NOTRUN |
| A05 (fixture destroy semantics) | Unchanged by design; fixture `9fcc3696…` unchanged; v5.4 never invokes `destroy` (only the L13 comment) | verified by hash + grep |
| K9 "unnamed setsid escape" | **Reachable through the real client graph today** — Prisma CLI 6.19.3 forks a *detached* telemetry child on every `migrate`/`db` command. Smallest boundary: export `CHECKPOINT_DISABLE=1` in the runner (one line). No containment framework required. | source (bundle) analysis; see §3 |
| Control request 07 (sets k/new1/new2/neg) | **Grantable as no-DB controls** with the caveats in §5; recommend fixing S2-R54B-01/-02/-03 first so controls run once against the final bytes | — |
| Real proof (06b) | **HOLD** until S2-R54B-01 (env pin) and S2-R54B-03 (manifest self-invalidation) are closed and the controls have actually run | — |

DYNAMIC ATTESTATION PENDING: every K/N control is NOTRUN; v5.3 control results do not transfer to `3f404479`.

## 1. Identity and inputs (all verified with `sha256sum` / `sha256sum -c`)

- `execution/s2-runner54/SHA256SUMS.outer` — 14 files, all OK; manifest sha256 `f38d9216ff03ff7aba8cfcc2d23a0921309af280abe4956b2170f0e336b411a8`.
- Runner `run-composition-r54-v5.4-when-granted.sh` `3f404479476c5b6a662c946268fd8ed59e3d69c867176431d921aca743604327`; delta vs v5.3.1 `fb0d7ce4803fa0d414c703cb0362b2e66626b8d6cf63dfa9054ed8e3eb2dc925` = 108 changed lines (`diff | grep -c '^[<>]'`).
- Driver `controls-proposed/run-controls-v54.sh` `6638ec06fd517a390546cfd28ae3d2a23398e56a5ee6e98c27872e348889c6a4` (198 lines).
- Stubs: `harness.sh` `867b7695…c002`, `fixture.sh` `f4fa2543…12b0`; `guard-spec.sh`, `discriminator.sh`, `k1-predecessor-mechanism.sh` byte-identical to the s2-setup-prep copies (`cmp`); `SHA256SUMS.stubs` OK.
- Frozen v5.3.1 lane `execution/s2-setup-prep/SHA256SUMS.outer` — 0 failures (37 files intact at review time).
- Fixture `execution/s2-setup-prep/infra/s2-fixture-r53.sh` `9fcc3696a48627b4ed10544cc6c8911e9f13d95fc7acf7ff324770363c24b881` (unchanged).
- Prior frozen reports: A r53 `REPORT.md` `8556de4e834c86e4457ef1a3a03c6df13929d9a86016d5ed3a62e7cab4d97607`; B r53 `REPORT.md` `00cf283e2555069346a0aedc32c0287d6c3e3358ef6d7a086b1c6a06d5f6aa9d`.
- Contract: `execution/EXECUTION_REPAIR_WAVE_2.md` `bff0162d8e4675137868db603cd33e43e37d08623a3fd5f7461584f45197510b` (§S2-V5.4-INDEPENDENT-CLOSURE A/B).
- Client graph read read-only from `worktrees/s2-runner53` (HEAD d5cd9b8b): `node_modules/prisma/build/index.js` `c2a77456b70e8ba1e640e122824ed694433828a7c0d76ff3db7fc376b4b0e1a0` (matches the setup-30 stamp), `node_modules/prisma/build/child.js` `237ba8edc4bc636f9045ca89a7b349faf845c235c03bcefcbb6c67a297da021d`; `initialization/recovered/s2-r3-d5cd-readonly` for `scripts/release.sh`, `test/release/s1s2-composition.sh`, `test/db/s1-r4-truncate-discriminator.sh`.
- Host fact used in §4.2: `/proc/sys/kernel/pid_max` = 32768.

## 2. Line-bound assessment of the v5.4 runner delta

### 2.1 Ownership (A01/B01)
- L86 `OWNED_PGIDS`, L90 `live_groups()` = recorded groups with members (`pgrep -g`), L95 `owned_scan()` = group members ∪ `OWNED_PAT` matches. Ownership is by *group membership first*, names second — this is the right direction; name-matching is no longer the only basis.
- L100–L118 `halt_owned_work`: TERM every live group → poll (≤10 s, clipped) → KILL live groups → poll (≤5 s, clipped) → `left=$(owned_scan)` → `REAP ok|FAILED`. Kill targets are group ids only (L108/L110); `OWNED_PAT` drives detection/quarantine, not kills. Good.
- L111–L114: `wait "$STEP_PID"` only when `kill -0` fails; a still-alive pid is logged, not waited. Bash reaps children asynchronously, so a dead leader is waited instantly. A02's unconditional wait is gone.
- L149 records `STEP_PGID` into `OWNED_PGIDS` for the run; L154–L155 post-exit quiescence (QUIESCE_WAIT=2 s) on the *group*; L156–L160 members remaining → `HALT` → `first_exit = rc (≠0) or 70` → `finish` (stage not accepted, next step never starts). L161 `PASS(quiescent)`.
- Anomaly branch L142–L147 (pid alive after `timeout` returned): bounded 3 s + 1 s, records the group. See S2-R54B-05 for the own-pgid corner.
- Step 31 real-mode consequence: the quiescence check passes only because `pg_ctl start` places the postmaster in its own session (pg_ctl `start_postmaster()` calls `setsid()` on Unix in PostgreSQL ≥ 10). Not exercised by the stub fixture (its `start` spawns nothing). If that assumption were wrong the runner would refuse step 31 with 70 and TERM/KILL the postmaster as an "owned group" — fail-closed against a disposable fixture, not unsafe, but it must be visible in the first real run's stamp.
- Harness C7 blocker: `test/release/s1s2-composition.sh` L212 spawns a same-group background `psql`; L224–L225 terminate and `wait` it before exit. No legitimate same-group survivor is expected from the real harness; Prisma schema-engine children are non-detached and die with the CLI (and would be caught by the group anyway).

### 2.2 Deadline (A02) — "single 50 s cleanup deadline including bookkeeping"
- Constants L60–L61 (`CLEANUP_BUDGET=50`, `QUIESCE_WAIT=2`, `ANOMALY_WAIT=3`); the header L35 still says "48 s worst case" — stale text only (`WORST=48` is informational).
- Deadline anchor: signal time L124 (`on_signal`) or cleanup start L168 (`cleanup`) — whichever comes first; a second anchor is never taken (L168 keeps an existing value). Single deadline confirmed.
- Clipped consumers: `poll_until_quiet` L98 (`lim=min(end,deadline)`), fixture-stop bound L178 (`sb=min(20, rem−3−5−2−3)`, skipped as `SKIPPED(deadline)` when `<3 s`, L180–L182), status budget skipped when `rem<7` L183, `deadline_check` L190 forces class 71 (`deadline_exceeded=yes`).
- Not clipped (small, bounded by their own nature): `lock_probe` (flock -n), `pgrep`/`ss` scans L187, `sha256sum` of `$OUT` L198, stamp writes. Under the outer `timeout -k 60`, the 10 s between the 50 s budget and the KILL grace covers these in stub and real mode (real `$OUT/harness` is a few MB).
- Pre-cleanup halt at L158 (quiescence failure during a normal run) runs with `CLEANUP_DEADLINE` unset (`remaining()` returns 999 L88); it is bounded only by the poll constants (≤15 s + scans), and cleanup then starts a *fresh* 50 s budget. Total worst case in that path is ≈65 s, but no outer TERM pressure exists there; if a TERM arrives mid-halt, `on_signal` L124 anchors the deadline and the nested halt is clipped. Acceptable; record it (S2-R54B-04).
- Final registers: `SURVIVORS` L187, `DEADLINE` check L190, `CLEANUP_EXIT` class L190–L191, `FINAL` L192, `cleanup_seconds` L195 — all computed *before* `exit-codes.txt` L197 and the manifest L198. Good. But see S2-R54B-03: two files are appended *after* the manifest is written.

### 2.3 First/cleanup truth
- `FINAL = first_exit if ≠0 else cleanup_exit` (L192) unchanged. Quiescence refusal sets `first_exit=70` when the leader exited 0 (L159) — the stage is not accepted even when cleanup is clean; a non-zero leader rc is preserved as the first exit (K8 expects 124). Correct.
- Step-timeout orphan (B01): `timeout --foreground` TERM/KILLs only the leader; a same-group grandchild now keeps the group non-empty at L154 → halt by group → 124 kept. Closed at source.

## 3. K9 — independent reachability analysis on the actual client command graph

**Claim under test (builder):** an unnamed `setsid` escapee is not reachable from the real steps, so K9 is a documented boundary rather than a live gap.

**Finding: it is reachable, concretely and on every real run.** Evidence (read-only greps of the bundled Prisma CLI `prisma/build/index.js`, sha `c2a77456…e1a0`, version 6.19.3):
- Command dispatch: for every command in `this.cmds[l]` the CLI calls `V1e({schemaPathFromConfig})` (the bundled `runCheckpointClientCheck`), awaits the command, then `H1e(await f)`. The only gate inside `V1e` is `if(process.env.CHECKPOINT_DISABLE) return …disabled…`.
- `V1e` → `G1e.check(v)` → checkpoint `check()`: `if((process.env.CHECKPOINT_DISABLE||a.disable)&&!a.force) return {status:"disabled"}` (no `disable` is passed), then unconditionally `let c=spawn(a); if(a.unref&&(c.unref(),c.disconnect()) …` with `unref` defaulting to `true`.
- `spawn(e){return child_process.fork(childPath,[JSON.stringify(e)],getForkOpts(e))}` and `getForkOpts(e){return e.unref===!0?{detached:!0,stdio:…"ignore",env:process.env}:…}`; `childPath=path.join(__dirname,"child")`; endpoint `TELEMETRY_ENDPOINT_URL_PRODUCTION="https://checkpoint.prisma.io"`; default timeout 5000 ms (`CHECKPOINT_TIMEOUT`).
- Node `detached:true` = `setsid()` in the child → **own session and process group**, command line `node …/node_modules/prisma/build/child {json}` — outside every retained group and not matched by `OWNED_PAT` (`^node .*prisma/build/index.js`). `detached:!0` occurs exactly once in the bundle (this path); `@prisma/client`/`@prisma/engines` contain no detached spawns.
- Real invocations that dispatch through `this.cmds` per proof run: `scripts/release.sh` L210 `npx prisma migrate status`, L249 `migrate deploy`, L258 `migrate status`, L290 `db execute` (× up to 8 release calls in the harness); harness L147 `migrate deploy` (×2), L230 `migrate resolve`; discriminator L69 `db execute` (verify, several times). Dozens of detached children per run; the last ones are spawned by the final discriminator/harness commands and can outlive step 40/45 by up to ~5 s (network round trip or timeout).

**What this means for the claimed scope.** Without a boundary, v5.4's `reap=ok survivors=none` is not literally true for the real graph: processes spawned by owned work (own session, unmatched name, stdio `ignore`, fd 9 closed) can be alive at classification time. They touch no DB, fixture, lock or `$OUT` file, so this is not a data-safety hole; it is (a) an ownership-claim gap exactly of the K9 shape and (b) an **unlisted outbound HTTPS egress** (`checkpoint.prisma.io`) plus a cache write under `$HOME/.cache` on every real run — neither is in any slot request. The same egress already happened during setup-30's `prisma generate` and in the historical B1/B2 runs.

**Smallest necessary boundary:** `export CHECKPOINT_DISABLE=1` in the runner environment before steps 40/45 (next to the existing exports at L274–L275; steps 20/21 use `env -i` and refuse before any Prisma call). One line; it removes the only identified real setsid escape and the unsanctioned egress, with no behavioural effect on migrations. After that, no other setsid producer exists in the graph as read: `pg_ctl start` (fixture step, intended and excluded), `npx`/`node`/`psql`/`git rev-parse|archive` (no detach, no auto-gc triggers), `timeout --foreground` (no setpgid). The K9 stub remains a labelled residual for *future* consumers only. The builder's `unshare -Urpf --kill-child --mount-proc` design is **not** the smallest boundary here and is already known to be blocked for PG steps (root refusal); I do not endorse it and no authority to implement it is requested. The disclosed `unshare … true` capability probe was process execution outside the syntax-only preparation — harmless, but it is a contract deviation and is not validation evidence.

Any adoption of the env pin changes runner bytes → new hash → CONTROL_REQUEST_07 must be re-issued against the successor; controls run on `3f404479` would not transfer.

## 4. Findings (stable ids S2-R54B-NN; DEFECT / EVIDENCE-GAP / INFO)

### S2-R54B-01 — DEFECT (scope/ownership), MEDIUM — Prisma checkpoint detached child is a live K9 instance
Evidence and closure: §3. Closure = one exported env var in the runner; label the remaining K9 residual as "future consumers only".

### S2-R54B-02 — DEFECT (unrelated-process safety), MEDIUM — dead process-group ids are retained and later signalled; pid_max is 32768
- Runner: L149 appends every step's `STEP_PGID` to `OWNED_PGIDS` for the whole run; L90/L95 expand *all* of them with `pgrep -g`; L108/L110 `kill -TERM/-KILL -- -$g` for any that shows members. A group observed empty at L154–L155 is dead; no process can ever join it again (`setpgid` to a non-existent group fails). The only way it "regains" members is **pid reuse**: an unrelated new session/group leader receiving the same id. With `pid_max=32768` and a busy shared sandbox (other lanes launching via `setsid -f`), this is low-probability but real, and the consequence is TERM/KILL of a foreign lane's entire group. Retaining dead ids has zero ownership value (an empty group cannot hide owned work) and non-zero hazard.
- Driver: L32/L35 record `g<pgid>` from stamps/logs for every run of the set; L38 expands them with `pgrep -g` at each `owned_cleanup` (L41–L42) through the end of the set; the pre-snapshot exclusion L38 only covers pids alive at driver start.
- Smallest closure: (runner) at L161, when the quiescence scan is empty, remove `STEP_PGID` from `OWNED_PGIDS` (ownership stays intact for the *current* and any non-empty group; A01 remains closed because the check and the halt precede the prune); additionally skip `g == $(ps -o pgid= -p $$)` in `live_groups`/halt (see -05). (driver) drop a `g<pgid>` record once `pgrep -g` returns empty, or expand group records only for the control just run.

### S2-R54B-03 — EVIDENCE DEFECT, MEDIUM for real proof / LOW for controls — the run manifest is invalidated by construction
- L197 writes `exit-codes.txt`; L198 writes `SHA256SUMS` over every file including `exit-codes.txt` and `stamp.txt`; L200 then appends `cleanup_seconds_total=…` to `exit-codes.txt` **and** calls `stamp` (which appends to `stamp.txt`). `sha256sum -c SHA256SUMS` inside `$OUT` therefore reports two FAILED lines on every run, stub or real. The L199 comment ("not covered") understates this: the two most important evidence files fail their own manifest.
- Driver L105 expects `cleanup_seconds_total` in `exit-codes.txt`, so the driver depends on the defect.
- Smallest closure: write the total to a separate file (e.g. `cleanup-total.txt`) excluded from the `find` at L198, and `echo` rather than `stamp`; adjust driver L105. Alternative: compute the total before L197 (slightly under-counts hashing time) — either is one to two lines.

### S2-R54B-04 — INFO — deadline verification notes
Single 50 s anchor confirmed (L124/L168); clipping verified at L98/L178–L183/L190; unclipped remainder is scans/hashing (small, within the 10 s outer grace); pre-cleanup halt L158 runs without a deadline (≤15 s by constants, then a fresh 50 s at L168) — document as "≈65 s worst case when a stage is refused after quiescence failure without an outer signal". Header L35 "48 s" and L40 ":54321" are stale text only.

### S2-R54B-05 — LOW — anomaly branch can record the runner's own process group
L142–L147: if `setsid` had not taken effect and the pid outlived the 3 s wait, `STEP_PGID` equals the runner's own pgid and `halt_owned_work` would `kill -TERM -- -<own group>` — including the outer `timeout`/launcher wrapper, producing a DEAD-NO-SENTINEL run. Extremely unlikely; closure is the own-pgid exclusion already named in -02.

### S2-R54B-06 — INFO — control-driver observations (no unsafe cleanup found)
- Refusal path L66–L68 → `abort` L49: no `owned_cleanup`, exit 2 — the N1 decoy (launched and *recorded* by the outer driver, L177) survives the child's refusal and is killed only by the outer driver's own cleanup L183. Semantics correct.
- Aggregate exit L44–L48/L50–L54: 0 only if `RUN==PLANNED` and no strike; 1 on strike (one-strike stop before the next `need`); 2 precondition; 3 budget. Declared k-set maxima sum to 85 s > 60 s budget: the set relies on the live `need` gate and may legitimately end in exit 3 — that is honest, not a defect.
- K9 (L157–L162) "BOUNDARY CONFIRMED" is a *non-strike* outcome whose success condition is the escapee surviving — clearly labelled; it must never be summarised as an ownership pass.
- K10 (L166): the stub `stop` is run by the runner at L181 directly (not via `run_step`), so its `sleep 60` orphan lands in the runner's own group, is not stamped as an owned group and is not recorded by the driver; it lingers ≈35 s after the set ends. Harmless and unnamed (does not trip the next set's pre-snapshot), but it is an unowned residue produced by a control. Closure: `STUB_STOP_HANG=25` (residue expires inside the control) or record the runner's pgid.
- K7pre/K8pre (L130/L146) execute the *frozen* v5.3.1 bytes read-only and write additively under `s2-setup-prep/runner-selftest-r531/`; the 37-file frozen manifest must be re-verified after the set (it verifies clean now).
- Driver `PAT` L26 includes `^bash $RUNNER|^bash $PRE_RUNNER`: a concurrent real proof would make the driver refuse — a useful protective property.
- No canonical lock is opened (lane-private `$STUBS/test-validation.lock`, L14/L47); no DB, no network in any set.

### S2-R54B-07 — INFO — real-mode assumptions not covered by stubs
pg_ctl postmaster detachment (§2.1), harness blocker termination (§2.1), Prisma engine children non-detached (§3). All fail-closed if wrong; none is unsafe to foreign processes or data.

## 5. Control grantability vs real proof (kept separate)

**CONTROL_REQUEST_07 (sets k, new1, new2, neg; `CTL_BUDGET=60`, no DB):** grantable as written — signals go only to recorded pids/groups, refusal is signal-free, no canonical lock, no DB, no network. Caveats the grantor should accept explicitly: (i) S2-R54B-02 group-id reuse hazard exists inside each ≤60 s set (low probability, shared sandbox); (ii) S2-R54B-03 means every produced `$OUT/SHA256SUMS` will fail for two files — results remain readable but not self-verifying; (iii) K7pre/K8pre write additively into the frozen v5.3.1 lane directory. Because closing -01/-02/-03 changes runner bytes and forces a re-run anyway, the smallest total path is: apply the three one-to-two-line closures → re-hash → re-issue the request → run once.

**Real proof (06b):** HOLD. Required before grant: S2-R54B-01 env pin (also removes unsanctioned egress from the proof), S2-R54B-03 (evidence must self-verify), and the actual execution of the control sets against the final bytes. S2-R54B-02 should be closed at the same time given `pid_max=32768`. Fixture `9fcc3696` unchanged; destroy never invoked by the runner; pre-destroy hold (A05) remains a separate, human-gated decision.

## 6. Non-goals honoured
No execution, no syntax check, no probes, no install, no DB, no network, no source/fixture/runner edits, no reads of `execution/audits/s2-r54/a`. All prior frozen reports unchanged. Output limited to `execution/audits/s2-r54/b/revision-1/`.
