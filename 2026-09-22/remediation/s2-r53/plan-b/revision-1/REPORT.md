# S2-R53-INDEPENDENT-PLAN-B — independent frozen-packet review (reviewer B), revision-1

Reviewer: `s1_r4_independent_audit_b_muc6muwk` (independent reviewer B; not a builder). Model: requested Claude Fable 5 — requested identity only; not exposed at runtime; not asserted. Frozen 2026-09-22 ~05:15 UTC.
Scope: safety/applicability review of the frozen `execution/s2-setup-prep` packet (runner v5.3.1 `fb0d7ce4…2925`, reimplemented fixture `9fcc3696…4b881`, setup S10/S20/S30, launcher, proposed controls) against the d5cd source consumers. Read-only: no tests, controls, install, network, DB, source or packet change. Peer A's directory (`execution/audits/s2-r53/a`) was not read. Writes: this directory only.

## 1. Bottom line (bounded)

| Question | Verdict | Evidence class |
|---|---|---|
| Packet integrity (37-file `SHA256SUMS.outer`, `originals/SHA256SUMS.originals`, `stubs/SHA256SUMS.stubs-copied`) | all pass; runner = `fb0d7ce4…2925`, fixture = `9fcc3696…4b881`; v5.3 original `fbc8b9af…` and fixture 08987e4c preserved byte-exact | source (verified by `sha256sum -c`) |
| Runner v5.3.1 delta vs frozen v5.3 | 48 changed lines (my `diff` count = builder's); every hunk is lane path / `$PORT` derivation / fixture pin + literal check / toolchain stamp / output dir; no change to lock, run_step, halt, cleanup, exit registers | source |
| Fixture r53 delta vs 08987e4c (D1–D7) | confirmed line-by-line (§3.2); D4/D6 correct real inherited unsafe behaviours (adoption at orig L59, `stop || true; rm -rf` at orig L64) | source |
| Lock / `/proc` identity, fd-9 discipline | sound (§3.1); `/home/user/workspace` is not a symlink, so fixture L34 `readlink /proc/$$/fd/9` equals the runner's literal `LOCK` | source + read-only host probe |
| Fresh namespace / port / DB / confirm guards | consistent end to end: runner `NS=s2comp-r53 PORT=54353 DB=s1_rls_s2comp_r53` (L42–44) ⇄ fixture L21–22 (literal check L193 matches) ⇄ guard `S1_PG_PORT`-pinned (guard L63/87/149), DB regex L49, marker L51, data root L52, realpath L167–168 | source |
| Inherited S1 discriminator prerequisites, 164+1 replay | satisfied at d5cd: 165 migration dirs (164 parents + candidate), `b7d7fe59` is an ancestor and `git show b7d7fe59:…/verify.sql` reproduces the pinned `2bbce0d7…323e`; env exports L231–232/239 match the discriminator's contract; harness leaves `$DB` protected after C5r (harness L209) and uses `${DB}_lock` for C7/C8 | source |
| Setup S10/S20/S30 applicability | scripts fail-closed and pinned to d5cd; observed at review time (not a frozen input): S10 exit 0 (psql 18.6), S20 exit 0 (four S1 hashes matched), S30 exit 0 at 05:11:51Z with stamp `lock=62b05b90…`, `prisma_cli_sha256=c2a77456…e1a0` | observed logs (read-only) |
| K1–K6 applicability to v5.3.1 | **none inherited** — v5.3 results (`s2-runner53/controls/…/20260922T043943Z`, strike=0, 30.85 s) are for `fbc8b9af…`; 06a re-run on v5.3.1 bytes is required before 06b | stub evidence (historical) |
| Material findings | one inherited runner defect in the step-timeout path (B-01, medium, not introduced by v5.3.1); one acknowledged evidence gap (B-02); rest INFO | — |
| Real proof | **PENDING** — nothing dynamic about composition, discriminator or fixture lifecycle has been executed; success of 06a/06b does not prove S1 membership semantics, hosted/release/customer safety | — |

**Bounded source verdict:** the frozen packet is safe to run as request 06a now, and as 06b after 06a passes on v5.3.1 bytes, provided the parent (i) adopts the B-01 residual rule or the B-01 minimal patch (which re-hashes the runner and reopens 06a), and (ii) records F6–F9 / fixture D3–D6 refusal paths as not executed rather than implying coverage.

## 2. Identity

- Brief: `execution/S2_R53_ALLOCATION_AND_REVIEW.md`; dispatch rows in `execution/DISPATCHES.md`.
- Packet: `execution/s2-setup-prep/` — `sha256sum -c SHA256SUMS.outer` 37/37 OK; `originals/SHA256SUMS.originals` 9/9 OK (run from `originals/`); `controls-proposed/stubs/SHA256SUMS.stubs-copied` OK. Stubs and `k1-predecessor-mechanism.sh` are byte-identical (`cmp`) to `execution/s2-runner53/controls/`; v5.3 driver `run-controls.sh` = `4d4bc661…`, v5.3 runner = `fbc8b9af…` (both recomputed).
- Source: `initialization/recovered/s2-r3-d5cd-readonly` HEAD `d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c`, tree `c0ab87d4dc584b2a7ccad53db16fa551b93fe359`, 0 porcelain lines; `worktrees/s2-runner53` HEAD d5cd, 0 porcelain lines, `node_modules` git-ignored. `git diff --quiet 9742037b HEAD -- package-lock.json package.json prisma/schema.prisma` exit 0 (runner L180 admissibility will pass).
- S1 files at d5cd (recomputed, equal to my S1 revision-1 values): verify.sql `266e62e9…9448`, discriminator `82da49b2…9921`, guard `6f66e436…8ec`, bootstrap `e8c42d2e…a60`, package-lock `62b05b90…1390`; harness `c766a8d9…b867`, release.sh `8831f8f7…f073`, guard spec `1356eb0d…09ac`.

## 3. Source assessment (line-bound)

### 3.1 Runner v5.3.1 (`run-composition-r53-v5.3.1-when-granted.sh`)
- Lock first: `exec 9>"$LOCK"; flock -n 9 || finish 75` (L164–165) before any identity check; `lock_probe` (L66) uses a separate open and therefore reports HELD while the runner holds — intended.
- fd 9 closed for every step except fixture init (`run_step` L117 `9>&-` vs `--inherit-fd9`); fixture stop/status also `9>&-` (L141, L143); git/sha/node invocations close it (L169, L184). The only inheriting child (init) closes fd 9 for every pg binary via `pgbin` (fixture L20). No long-lived holder can survive the runner.
- Process isolation: `setsid timeout --foreground` per step (L117), group-leader wait ≤2 s with 70-refusal on anomaly (L119–122); `halt_owned_work` signals only the recorded group (L84–90), bounded 10+5 s; REAP FAILED ⇒ `CLEANUP_EXIT=72`, stop REFUSED, nothing erased (L136–138). Cleanup arithmetic L47–48: worst 48 s, margin 12 s under `-k 60` — verified.
- Real-mode prechecks L182–196: node_modules/prisma, install stamp `^lock=<sha>$` (matches setup-30 stamp line format L100 of setup-30), psql, PG17 dist, fixture hash, fixture `^PORT=54353;` / `^NS=s2comp-r53$` literals (fixture L21–22 match). Fresh-only prechecks L213–219: NS dir, `$PORT` listener, any pg17 postgres, release.sh `/tmp` scratch (same five paths as harness L74 and release.sh L147/207/248/257/284).
- Refusals 20/21 use the REAL harness under `env -i` and exit at `s1_guard_offline` (harness L49) before `mkdir -p "$OUT"` (L52) — no `/tmp` residue.
- Discriminator step L237–244: exports S1_PRISMA_CLI (absolute), S1_PROOF_LOG under `$OUT/s1-r4` (created L238), `S1_R4_LOCK_HOLDER` (asserted holder, discriminator L44–45); SUPER_URL/PORT/CONFIRM remain exported from L231–232.

### 3.2 Fixture r53 (`infra/s2-fixture-r53.sh`) vs 08987e4c
| Item | r53 lines | 08987e4c lines | Assessment |
|---|---|---|---|
| D1/D2 NS `s2comp-r53`, PORT 54353 | L21–23 | L14–15 (`s2comp`, 54321) | lane-unique; no env override anywhere |
| D3 init refusals (exists / listener / serving / initdb) | L44–47 | L36 only | fail-closed, no adopt/delete |
| D4 start refuses running server or listener | L72–73 | L59 `echo "already running"` then continued | closes an inherited adoption defect |
| D5 stop `-m fast -w -t 15` | L77 | L62 (default `-w` 60 s) | fits runner `-k 3 20`; nonzero propagates (last command of script under `set -e`) |
| D6 destroy requires not-running + no referencing postgres + literal confirm | L81–85 | L64 `-m immediate … || true; rm -rf` | closes destructive-after-failed-stop defect; runner never calls destroy |
| D7 mkdir inside init after refusals | L48 | L33 (every subcommand) | correct |
| kept: fd-9 `/proc` guard, marker, root, loopback, `9>&-` | L20, L24, L33–39, L56 | L13, L26–32, L42–44 | unchanged in intent |

### 3.3 Setup / launcher
- `_common.sh` L15–17: lock on fd 9 then `exec > >(tee …)` — `tee` inherits fd 9 (see INFO B-06). `setup-20` L25–30: accept only with matching provenance, else refuse 70 without deletion (C1/C2 verified). `setup-30` L70 fixed head, L72/97/99 outside-root guard, L83–84 stamp acceptance requires matching prisma CLI hash, L108 dirty-after refusal.
- `launch-detached.sh`: `setsid -f` wrapper, PID from the wrapper's own log line (L60–61), atomic exit sentinel (L56), `DEAD-NO-SENTINEL` treated as failure (L69). Suitable for 05/06b as written.

### 3.4 Proposed controls
- `run-runner-controls-v531.sh` differs from the frozen v5.3 driver by 11 lines (paths/runner/output dir only; expectations K1–K6 unchanged). `run-fixture-lockcheck-controls.sh` F1–F5 exercise only `lockcheck`/`url` on a temp lock (fixture L32 honours `S2_FIXTURE_LOCK` for lockcheck alone) — no PG, no canonical lock. Both are stub/offline evidence, never proof.

## 4. Findings (stable IDs; smallest closure)

**S2-R53B-01 — DEFECT (recovery + evidence semantics), MEDIUM, inherited from v5.3 (identical lines in `fbc8b9af…`), not introduced by v5.3.1.**
Step-timeout orphan path. `run_step` clears `STEP_PID`/`STEP_PGID` immediately after `wait` (L125), before any halt. When a step's own `timeout --foreground <bound>` expires (rc 124), `--foreground` signals only the direct child (`bash test/release/s1s2-composition.sh`); its descendants — `timeout --foreground 600 bash scripts/release.sh` (harness L104), `node …prisma/build/index.js`, `psql` — survive in the now-leaderless group. Cleanup (L135) then calls `halt_owned_work`, which skips signalling because `STEP_PID` is empty (L82) and `owned_scan` (L77) degrades to the pattern scan only. `OWNED_PAT` (L60) has no entry for `bash scripts/release.sh` / its `timeout` wrapper, so an orphaned release.sh between prisma/psql invocations is invisible: `REAP ok` can be stamped while owned work is alive, the fixture is stopped under it, and release.sh then fails against a stopped server and can leave `/tmp/prisma_*.log` (the harness's L107 move/delete is never reached). `exit-codes.txt` would show `reap=ok survivors=none` incorrectly. Downstream the next run is refused by L217–218 (fail-closed), but the run's own evidence line would be wrong. Not covered by K1–K6 (no step-timeout control; K3/K4 signal the whole group via the runner's trap). Likelihood low: step-40 bound 1500 s vs. historical minutes; step-45 bound 300 s.
Smallest closure (parent's choice):
(a) *No byte change for B3-R53:* adopt the rule "if any step register or `first_exit` is 124, `reap`/`survivors`/`fixture_stop` are non-authoritative; parent inspects `pgrep -af 'release.sh|prisma/build/index.js|psql'`, `/tmp/prisma_*`, and fixture status manually before any further slot" and write it into the 06b request/packet.
(b) *v5.3.2 (re-hashes runner; 06a must be re-run, add K7):* in `run_step` do not clear `STEP_PGID` when `rc=124`; in `halt_owned_work` gate on `[ -n "$STEP_PGID" ] && pgrep -g "$STEP_PGID" >/dev/null` instead of `kill -0 "$STEP_PID"` (L82); extend `OWNED_PAT` (L60) with `|^timeout --foreground 600 bash scripts/release.sh|^bash scripts/release.sh`; K7 = stub harness spawning a same-group grandchild that outlives a 2 s step bound → expect `REAP FAILED`/72 or a TERM'd group, never `survivors=none`.
I recommend (a) for B3-R53 and (b) queued; either is acceptable, neither is optional.

**S2-R53B-02 — EVIDENCE-GAP, MEDIUM (acknowledged by the builder, REPORT §5/§6.3).**
Never exercised on any bytes: runner real-mode prechecks (L182–196, L212–220), lock-busy 75 path (L165), literal check (L193); fixture D3–D6 refusals (L44–47, L71–73, L81–85) and the bounded stop (L77). K1–K6 are stub-mode; F1–F5 cover only lockcheck/url. F6–F9 cannot run on the pinned fixture without consuming the proof namespace (fixture has no NS override by design); a scratch copy with another NS would be different bytes and would not evidence `9fcc3696…`.
Smallest closure: run 06a (F1–F5, K1–K6) on v5.3.1 bytes before 06b; record D3–D6 as "observed on the positive path only (one init on a fresh NS, one start)" and F6–F9 as NOT EXECUTED in the proof packet; do not run F6–F9 on `s2comp-r53`. No architecture change.

**S2-R53B-03 — PACKET/INFO, LOW.** `run-runner-controls-v531.sh` L26 pre-snapshot still greps `:54321` (lane port is 54353); stub mode opens no port, so it is a stale diagnostic literal only. Fixture L34 message `caller pid=$PPID` names the `timeout` wrapper, not the runner (runner stamp L166 is authoritative). Closure: none required for 06a; fix only if the driver is re-hashed for another reason.

**S2-R53B-04 — INFO (semantics).** Stamp text `LOCK: … NOT safely handed off` (L152): the flock is in fact released at runner exit (fd 9 closes; no step holds it), also after quarantine. The effective re-entry guard is procedural (parent inspects `QUARANTINE.txt`) plus the fresh-only prechecks L213–215, which refuse any re-run while the retained cluster/listener exists. Wording, not behaviour; no change.

**S2-R53B-05 — INFO (budget).** Sum of inner step bounds 120+120+120+120+120+30+1500+300 = 2430 s exceeds the outer 2100 s; the outer TERM → `on_signal` path is the effective bound and its cleanup worst case (48 s) fits the 60 s grace. Runner prechecks L183–184 (`node … --version`, `psql --version`) are unbounded except by the outer timeout. Historical durations are far below; no change.

**S2-R53B-06 — INFO (setup/launcher).** `_common.sh` L15–17: `tee` inherits fd 9, so the canonical lock stays held until `tee` exits (momentarily after the step) — a `check-lock.sh` probe immediately after the `.exit` sentinel may show HELD once; re-probe before reading it as a defect. `setup-20` L31 deletes a stale `PROVENANCE.txt` when `dist` is absent (acceptable, records nothing of value). Request 05 lists only apt/Maven/npm egress; `prisma generate` also fetches engines into `$WT/node_modules/@prisma/engines` and Prisma's checkpoint telemetry is not disabled (`CHECKPOINT_DISABLE=1` optional, no safety impact).

**S2-R53B-07 — INHERITED S1 LIMITATION (unchanged).** Bootstrap L20/L23 create `anon`/`authenticated` NOINHERIT and the guard pins `ffff` (guard L181), while the live catalog shows inherit=true; B3-R53 therefore evidences the fixture shape only (my S1-R4B-01 remains open). The discriminator has never executed against a database (B1/B2 `notrun`); 06b would be its first execution and S1 interprets the result.

## 5. Dynamic attestation PENDING (not signed here)
06a results on v5.3.1 bytes; fixture init/start/stop on a real PG 17.6 cluster; 68-check composition on `s1_rls_s2comp_r53`/`_lock`; discriminator execution and interpretation; fixture D3–D6 refusal behaviour; cleanup/quarantine on real processes; anything hosted, release, customer or native.

## 6. What this review is not
Not a builder output, not a majority vote with peer A (not read), not a CLEAN. It signs only the source-level statements in §1–§4 at the hashes in §2.
