# OP88-S6 — smallest reuse of the S5 outer-exclusion pattern for the two S6 consumers (SCOPING ONLY; nothing implemented)

Builder: sole T4 Fable builder (requested Claude Fable 5 / High — policy, not observable). Sole writes: `/home/user/workspace/execution/e8d546f9/s6-exclusion-scope/`. Read-only work: `cat`/`sed`/`grep`/`sha256sum` on frozen inputs; no runtime, process, network, lock, install, worktree edit, commit. No file in this packet is executable or is a candidate; every "proposed hunk" below is text for the parent's later exact-successor assignment.

Parent direction bound here: no live handoff; the original outer holder keeps the lease until the exact owned outer session AND every established inner session are positively empty; no outer `timeout` may be the last owner; no bypass that ignores a quarantine marker; marker presence alone is never treated as safety (flock + holder record + typed census remain the authority).

## 0. Inputs (hashes verified at scoping time; see `INPUTS.json`)
| Input | SHA256 | Status |
|---|---|---|
| S5 launcher **v3** `s5-setup-exclusion-v3/launch-s5-setup-exclusion.v3.sh` (236 lines) | `a10c615f…f451a17` | **proposal under dual review — NOT accepted**; read as the pattern source only. Manifest `8b128b4d` verifies (13/13) |
| S5 runner variant `run-s5-setup-npm-ci.v101x.sh` (inherited-fd9 branch, v101 L203 → v101x L207–L212) | `81ff20b0…6a3742a` | same (v2-frozen bytes reused by v3) |
| S5 launcher v2 `b32cc20d…`, observer v2 `b70b04ea…`, controls/fake v2 | frozen `b96dc732` (33/33) | v2 frozen; A `fa876aa6` residuals S5SV2-A-01/A-02; B V2-B-01/B-02 |
| S6 consumers (my frozen packet `6b2be238`): `run-c5-setup-npm-ci.v101.sh` `8b1ae8c0…`, `run-c6-hazard-v5-conly.v101.sh` `2c9748a4…` | — | source-only, ungrantable as-is (HOLD_BOUND residual acknowledged) |
| C6 observer `execution/op88/s6-c6-prep/c6/launch-c6-observer.sh` | `f140787a…8fe1` | frozen; not edited |
| OWN-BLOCK v10.1 `4aebf96f…` | — | primitive; not edited, not re-audited |

## 1. What the S5 pattern consists of, and which parts are consumer-bound
The pattern is three roles, of which only two would be reused:
1. **Outer holder (launcher)** — acquires the canonical `flock` ONCE on fd 9, publishes `LEASE_HOLDER` (token, pid, sid, pgid, /proc start_time) BEFORE any child, launches the pinned runner through the OWN-BLOCK gate as an owned confirmed session (`SESSION=$PID`), waits in-shell for RAW, then releases ONLY on `CENSUS=empty` over the explicit outer sid + every retained inner sid (v3 `INNER_KNOWN`), else enters observable SELF-HOLD with heartbeats and no self-termination (v3 L143–236).
2. **Runner inherited-lease branch** — the runner does not `flock` when `<X>_LEASE_INHERITED=<token>` is set; it verifies fd 9 is open on `$LOCK` (`readlink /proc/$$/fd/9`), that `$EX/LEASE_HOLDER` names the token and a live holder pid, and writes the binding line ` lease INHERITED fd=9 path=$LOCK token=$TOKEN holder_pid=… ` into its EXIT_RECORD (v101x L207–L212). Children still get `9>&-`.
3. **Read-only observer** (S5 `observe-…v2.sh`) — reports holder state from records + `/proc`; never opens the lock. Optional; NOT the C6 observer envelope.
Controls/fake (`controls-exclusion/`) are a harness — **not reused** (parent: no new harness/control suite).

Consumer-bound constants inside the v3 launcher (everything else is pattern): L25 `CANON_EX`; L29 `RUNNER` path, `INNER_BOUND/INNER_KILL/NORMAL_BOUND/HEARTBEAT`; L30 `LOGS`; L32 `PIN_RUNNER`; L169 `INNER_LOGS`; L177 record name `setup.EXIT_RECORD`; L180 grep `npm-ci IDENTITY .* state=released`; L218 env var names `S5_LEASE_INHERITED`/`S5_SETUP_GRANT`; L24 grant variable; header L21 invoke line. The v3 findings-closure lines (L152–155, L161, L170–175, L178–179, L185–188, L199) are pattern and would be inherited verbatim **subject to the v3 dual-review outcome**.

## 2. Smallest changed-file set (proposal; per consumer; nothing generic)
Two additive launcher copies derived from v3 by exact delta (each pinned to ONE runner), two one-hunk/two-hunk runner variants, no observer edit (Option O-A) or one additive observer copy (Option O-B). No product/Jest/classifier/hazard/instrument/primitive change.

| # | New file (additive; originals untouched) | Derived from | Hunks (exact) |
|---|---|---|---|
| F1 | `run-c5-setup-npm-ci.v101x.sh` (S6 setup) | `run-c5-setup-npm-ci.v101.sh` 8b1ae8c0 | **H-S1** L202 → the 6-line inherited branch (§3.1); header note |
| F2 | `run-c6-hazard-v5-conly.v101x.sh` (C6 runner) | `run-c6-hazard-v5-conly.v101.sh` 2c9748a4 | **H-R1** L342–344 → inherited branch (§3.1); **H-R2** L298 IDENTITY field order `pid=` first (§4.2); header note |
| F3 | `launch-s6-setup-exclusion.v1.sh` | S5 launcher v3 a10c615f (or its accepted successor) | **H-L1** constants (§3.2); **H-L2** quarantine precondition gate (§6); **H-L3** env var/grant names; header/invoke |
| F4 | `launch-s6-c6-exclusion.v1.sh` | same | H-L1 (C6 values), H-L2, H-L3, **H-L4** `runner_truth` multi-step greps (§4.1) |
| F5 | (Option O-B only) `launch-c6-observer.v101x.sh` | C6 observer f140787a | **H-O1** L12 RUNNER→launcher path; **H-O2** L27 drop `timeout -k 30 240` (§7) — two hunks, not one |
| F6 | packet docs: pins/manifest/INPUTS/FREEZE, diffs, review request | — | — |
Not changed: `own-block-v101.sh`; `c6/MANIFEST.c6.sha256` (still verifies the frozen c6 packet incl. the ORIGINAL runner; the runner checks it unchanged); hazard/adapter/instrument/classifier; Jest argv/selection/budgets; worktree; product.

## 3. Inherited-fd9 hunk, per consumer (exact)
### 3.1 Runner side
Setup **H-S1** — current L202:
```
exec 9>"$LOCK"; flock -n 9 || die lock-busy 75; echo "$(ts) lock acquired fd=9 path=$LOCK" >> "$EXIT_RECORD"
```
→ proposed (v101x L207–L212 with `S6_LEASE_INHERITED`, `$EX`=`/home/user/workspace/execution/s6-diagnostic`):
```
if [ -n "${S6_LEASE_INHERITED:-}" ]; then   # lease owned by the outer launcher; verify, never re-acquire, never release here
  [ "$(readlink /proc/$$/fd/9 2>/dev/null)" = "$LOCK" ] || die lease-fd-not-inherited 75 "S6_LEASE_INHERITED set but fd 9 is not open on $LOCK"
  grep -q "^token=$S6_LEASE_INHERITED " "$EX/LEASE_HOLDER" 2>/dev/null || die lease-holder-record-mismatch 75 "$EX/LEASE_HOLDER does not name token=$S6_LEASE_INHERITED"
  HP=$(sed -n "s/^token=[^ ]* holder_pid=\([0-9]*\) .*/\1/p" "$EX/LEASE_HOLDER" 2>/dev/null); [ -n "$HP" ] && [ -d "/proc/$HP" ] || die lease-holder-gone 75 "holder pid=[$HP] not present"
  echo "$(ts) lease INHERITED fd=9 path=$LOCK token=$S6_LEASE_INHERITED holder_pid=$HP (outer launcher retains exclusion after this runner exits)" >> "$EXIT_RECORD"
else exec 9>"$LOCK"; flock -n 9 || die lock-busy 75; echo "$(ts) lock acquired fd=9 path=$LOCK" >> "$EXIT_RECORD"; fi
```
C6 **H-R1** — current L342–344 (`exec 9>"$LOCK"` / `flock -n 9 || die lock-busy 75 "canonical lock held by another owner; …"` / `echo … lock acquired …`) → the same 6 lines with the C6 `die lock-busy` text kept in the `else` branch and `$EX`=`/home/user/workspace/execution/op88/s6-c6-prep` (already defined at L112). L345 `OWN_ROOT=…` unchanged.
Consequences identical to S5: the runner's `die`/`finish` paths still close fd 9 at exit, but the open-file description is the launcher's, so the lease survives the runner; the runner's own HOLD_BOUND→`EXCLUSION_UNPRESERVED` branch becomes **non-final** (it no longer releases the lease; the launcher's census does). The branch bytes stay (no consumer logic change), and `runner_truth` reads `EXCLUSION_UNPRESERVED` as evidence (`unpreserved=1`).

### 3.2 Launcher constants (H-L1) — per copy
| Constant | S5 v3 value | F3 setup | F4 C6 |
|---|---|---|---|
| `CANON_EX` / `EX` | `execution/s5-r4` | `execution/s6-diagnostic` | `execution/op88/s6-c6-prep` |
| `RUNNER` | `$HERE/run-s5-setup-npm-ci.v101x.sh` | `$HERE/run-c5-setup-npm-ci.v101x.sh` | `$HERE/run-c6-hazard-v5-conly.v101x.sh` |
| `PIN_RUNNER` | `81ff20b0…` | hash of F1 (fixed at freeze) | hash of F2 |
| `LOGS` (launcher records) | `$EX/logs/setup-exclusion` | `$EX/logs/s6-setup-exclusion` | `$EX/logs/c6-exclusion` |
| `INNER_LOGS` (runner records + `attempts/`) | `$EX/logs/setup-v1` | `$EX/logs/setup-v3` (runner LOGS, unchanged) | `$EX/logs/c6` (runner LOGS, unchanged) |
| runner EXIT_RECORD name (L177) | `setup.EXIT_RECORD` | `setup.EXIT_RECORD` | `c6.EXIT_RECORD` |
| `INNER_BOUND` / `INNER_KILL` (inner `timeout` around the runner, L218) | 1290 / 30 | 1290 / 30 (= frozen invoke) | 240 / 30 (= frozen invoke) |
| `NORMAL_BOUND` (launcher wait for the runner leader; NOT a kill) | 1380 | 1380 | 300 (240 + 30 + 30 margin) |
| `HEARTBEAT` | 30 | 30 | 30 |
| grant var (L24) / lease var (L218) | `S5_SETUP_GRANT` / `S5_LEASE_INHERITED` | `S6_SETUP_GRANT` / `S6_LEASE_INHERITED` | `S6_C6_GRANT` / `S6_LEASE_INHERITED` |
| runner stdout | `$LOGS/runner.out` | `$LOGS/runner.out` (replaces frozen `run-setup.out`) | `$LOGS/runner.out` (replaces `run-c6.out`) |
Private-mode lines (L27–L28, `S5X_*`) exist for the S5 controls; with no S6 harness they can stay (unused, refuse canonical paths) or be dropped — dropping is a larger delta; recommend keep verbatim (renamed `S6X_*` only if the parent wants no `S5X` token in S6 files).

## 4. Runner-truth / IDENTITY / token-binding differences for multi-step C6
### 4.1 `runner_truth` (v3 L176–182) applied to `c6.EXIT_RECORD` — H-L4
| Fact | S5 grep | C6 record reality (my runner 2c9748a4) | Needed change |
|---|---|---|---|
| binding line (L179) | `" lease INHERITED fd=9 path=$LOCK token=$TOKEN "` | identical text from H-R1 | none |
| `released=` (L180) | `npm-ci IDENTITY .* state=released` | per step: `step=selftest IDENTITY … state=released`, `step=C IDENTITY … state=released` (0, 1 or 2 lines) | `grep -q 'step=[^ ]* IDENTITY .* state=released'`; optionally `released=<count>` (0–2) so `released-but-no-IDENTITY` (L187) compares count vs bound inner sids |
| `EXCLUSION_UNPRESERVED`, `FINAL rc=`, `CLEANUP_FAILURES=` | as-is | present in the same forms (`CLEANUP_FAILURES=N lock held until exit …`) | none |
| additional C6-only evidence (not used for release) | — | `cleanup_exit=<n> session=<typed>`, `C6-OUTCOME=`, `step=C first_exit` | evidence only; `RUNNER_NOTE` may append `c6_outcome=` (optional, not required) |
Rule 188 (evidence absent/unreadable/not-this-attempt after adoption ⇒ unknown) applies unchanged: a C6 runner that `die`s BEFORE writing its binding line (precondition L340, STAMP exit 74) leaves an unbound record ⇒ `not-this-attempt` ⇒ SELF-HOLD until the parent resolves — the same documented v3/B-01 consequence; the parent's possible ppid-binding alternative would apply to both S6 copies equally.

### 4.2 `inner_sids` (v3 L170–175) applied to `$INNER_LOGS/attempts/*/IDENTITY` — H-R2
- Binding: grep `" self_sid=$SESSION "` — both S6 consumers write ` self_sid=$OWN_SELF_SID ` (setup L230, runner L298). Under the launcher the runner's sid == outer `SESSION` (the launcher's gate child execs `timeout → bash runner` in the same session; `setsid` in the gate creates it). OK.
- Pid extraction: `sed -n 's/^pid=\([0-9][0-9]*\) .*/\1/p'` is **anchored at line start**. Setup IDENTITY starts `pid=…` (OK). **C6 IDENTITY starts `step=<s> pid=…` ⇒ no match ⇒ rc 2 ⇒ `inner:evidence-unavailable` ⇒ `unknown` ⇒ permanent SELF-HOLD on every C6 run.** Smallest fix = **H-R2**: reorder L298 to `"pid=$CUR_PID step=$step attempt=…"` (field order only; content unchanged). Alternative (launcher-side unanchored sed) changes pattern bytes — not preferred.
- Multi-step: up to TWO inner sids per run (selftest, then C), each retained in `INNER_KNOWN` until its own positive `empty`. After selftest exits and its session is positively empty, its number stays retained and re-censused each cycle; a later foreign reuse of that number would yield `foreign` ⇒ SELF-HOLD (stricter, safe direction; residual: needs parent resolution out of band). Setup has ONE inner sid.
- Attempts of the launcher itself live under `$LOGS/attempts` (launcher LOGS) — disjoint from the runner's `$INNER_LOGS/attempts`; no collision.

### 4.3 Token binding chain (both consumers)
`TOKEN` (launcher) → `LEASE_HOLDER` line `token=… holder_pid=…` → env `S6_LEASE_INHERITED=$TOKEN` → runner verifies holder record + `/proc/$HP` + fd 9 target → binding line in runner EXIT_RECORD → `runner_truth` accepts facts only from a record carrying THIS token. Setup: identical to S5. C6: identical; the runner's `runner_sha256=` START field additionally lets the launcher's `PIN_RUNNER` be cross-checked in evidence (no new logic required).

## 5. Explicit inner SIDs, unknown retention, never-last-owner topology
```
launcher (holder; fd 9 flock; NO outer timeout; sid=L)                      ← last owner; exits only via release() after CENSUS=empty
 └─ gate child (setsid; sid=SESSION=P) : timeout -k K B bash RUNNER  9 inherited (verified), children get 9>&-
     └─ runner (same session P)  ── setsid gate ── inner workload session(s):
            setup: npm ci (sid=I1)            C6: selftest node (sid=I1), then Jest (sid=I2)
```
- Sessions censused for release: `P` (explicit) + `{I1[,I2]}` from bound IDENTITY records, retained (v3 `INNER_KNOWN`) until each is positively `empty` (`own_group_current` rc1). `live` ⇒ one escalation inside the OUTER session only (inner sessions never signalled by the holder; the runner's own reap is the only inner signaller), then re-census; `foreign`/`unknown` ⇒ SELF-HOLD, heartbeat, no bound, no handoff, no self-kill.
- `timeout` sits INSIDE session P and can only end the runner leader; it can never end the holder ⇒ no `timeout` is the last owner. The frozen invocations (`setsid nohup timeout -k 30 1290|240 bash <runner>`) are therefore replaced by `setsid nohup bash <launcher> > $LOGS/launcher.out 2>&1 < /dev/null &` with the grant env — as S5 v2/v3 L21.
- The runner's HOLD_BOUND branch remains but is no longer a release path (fd 9 is the launcher's description); its 60 s adds to the runner's inner life, within INNER_BOUND slack? Setup: 1290 − (1200+30+2+13+60) ≈ −15 s ⇒ **the inner `timeout` could TERM the runner during a hold** ⇒ raw 124/137 latched by the launcher, census continues (holder unaffected). C6: 240 − (5+15+5+3+13+3 + 5+90+20+3+13+3 + 60 + preflight) < 0 in the worst case ⇒ same. Acceptable under the pattern (the holder, not the timeout, decides), but the parent should note that `EXCLUSION_UNPRESERVED` + inner-timeout raw is a possible, non-fatal evidence combination. No budget change proposed.

## 6. Two quarantine roots + precondition gate (H-L2)
- Roots today: setup writes `execution/s6-diagnostic/QUARANTINE` (fallback `…/logs/setup-v3/QUARANTINE`); C6 writes `execution/op88/s6-c6-prep/QUARANTINE` (fallback `…/logs/c6/QUARANTINE`). The launcher records (`LEASE_HOLDER/LEASE_RELEASE/SELF_HOLD`) must live in the SAME `$EX` the runner verifies (H-S1/H-R1 read `$EX/LEASE_HOLDER`), so two holder roots follow the two consumer roots. Exclusion itself is still single (one `$LOCK`).
- **Choice A (recommended, smallest): keep two roots; add a precondition gate in BOTH launcher copies that refuses when ANY of the four marker paths exists**, before `flock` (new lines after v3 L144 / before L147):
  `for q in /home/user/workspace/execution/s6-diagnostic/QUARANTINE /home/user/workspace/execution/s6-diagnostic/logs/setup-v3/QUARANTINE /home/user/workspace/execution/op88/s6-c6-prep/QUARANTINE /home/user/workspace/execution/op88/s6-c6-prep/logs/c6/QUARANTINE; do [ -e "$q" ] && { say "REFUSE quarantine marker present $q (parent must clear; no run)"; exit 71; }; done`
  Marker presence ⇒ refusal (no bypass); marker ABSENCE is never sufficiency: `flock -n` (live holder), `preserve_prior` (prior LEASE_HOLDER/SELF_HOLD retained by token), and the typed census still bind. Note the S5 v3 launcher has NO such gate (S5 setup controls checked the marker elsewhere); the gate is S6-new and must be reviewed as such.
- Choice B: unify roots by changing the setup consumer's `EX` for the marker only — a consumer logic change beyond H-S1; not recommended.
- Prior-live refusal (a live holder named in a stale `LEASE_HOLDER`): parent-accepted omission for S5 v3 (flock is the authority) — inherited unchanged.

## 7. Observer one-path repoint (additive copy) — honest mapping
The frozen C6 observer (f140787a) does two things: pre-launch topology/lock/porcelain notes (L16–22) and `setsid nohup timeout -k 30 240 bash "$RUNNER"` with `outer.exit` capture (L27–29).
- **A one-path repoint alone (L12 `RUNNER=` → launcher path) is NOT compatible with the pattern**: L27 would then wrap the LAUNCHER in `timeout -k 30 240`, making `timeout` the last owner (KILLs the holder ⇒ lease released with inner work possibly alive) — exactly what the parent forbids. Also L14–15 refusal names `outer.exit`/`c6.EXIT_RECORD` only.
- **Option O-A (recommended, 0 observer hunks):** do not use the observer for the exclusion topology; invoke the launcher as S5 does (`setsid nohup bash launch-s6-c6-exclusion.v1.sh …&`). Equivalent facts exist in launcher records: `RUNNER_RAW rc=` (= the wait status of the inner `timeout`, replacing `outer.exit`), `LAUNCHER_START stamp=[…]` (R3 stamp incl. setsid/timeout versions), `LEASE_BUSY` (lock probe). Lost vs observer: `foreign_node_npm_count` and porcelain/HEAD pre-notes — the runner records HEAD/porcelain itself; a `pgrep -c` note could be added to the launcher header line (optional). The frozen observer stays frozen/unused.
- **Option O-B (additive copy `launch-c6-observer.v101x.sh`, exactly TWO hunks):** H-O1 L12 `RUNNER=` → `LAUNCHER=<F4 path>` (and L17 text); H-O2 L27 → `setsid nohup env S6_C6_GRANT=granted-by-parent bash "$LAUNCHER" > "$LOGS/launcher.out" 2>&1 < /dev/null` (no `timeout`), so `outer.exit` records the LAUNCHER's exit status (= release final_rc, 90 on self-hold-then-empty). Refusal L14–15 would also need `LEASE_HOLDER`/`launcher.EXIT_RECORD` — a third hunk if one-run-only is to be preserved. Not "one path"; report as three.
- The parent's decision O-A vs O-B is a grant precondition; the map recommends O-A.

## 8. Grant preconditions (all must hold before an exact successor is assigned, and again before any run)
1. **S5 v3 dual review closes** (or a successor is accepted); its accepted bytes become the base for F3/F4 by exact delta. Until then F3/F4 cannot be frozen (base not stable).
2. Parent accepts the S6-new items as reviewable deltas: H-L2 quarantine gate (§6), H-L4 multi-step `runner_truth` (§4.1), H-R2 IDENTITY field order (§4.2), C6 bounds 240/30/300 (§3.2), Option O-A/O-B (§7), two holder roots (§6).
3. Consumer variants F1/F2 are byte-identical to 8b1ae8c0/2c9748a4 except H-S1 / H-R1+H-R2 + header (verifier + diff); embedded block 4aebf96f byte-identical; `bash -n`.
4. ONE dual review of the NEW composition per consumer (launcher copy + runner variant), per the parent's plan, instead of reviewing the known-unsafe standalone consumers.
5. A-01 boundary inherited and stated: deleted IDENTITY + deleted/rewritten EXIT_RECORD is indistinguishable from never-written evidence for any reader; read/list failure, absent/unbound-after-adoption and loss-after-first-observation are covered by v3 rules (hold), if accepted.
6. Runtime preconditions unchanged from the frozen requests: node_modules absent (setup) / present + 20/20 (C6); worktree HEAD d51a1910 clean; lock free; no foreign node/npm; no QUARANTINE marker at any of the four paths; no prior `LEASE_HOLDER` naming a live holder (flock refuses); fresh `INNER_LOGS` without an `EXIT_RECORD`.
7. No S6 controls/fake are built; any private proof of the S6 composition is a separate parent decision (the S5 v2 fake proves v2 bytes only; a v3/S6 fake would need the binding line and, for C6, two inner IDENTITY records).

## 9. Truth / non-claims
Scoping only; no bytes of F1–F6 exist. Nothing executed. The S5 v3 launcher is a proposal under review, not an accepted pattern; every "inherit unchanged" above is conditional on that review. The S6 consumers 8b1ae8c0/2c9748a4 remain ungrantable as-is (HOLD_BOUND residual). Frozen packets untouched (hashes re-verified in `INPUTS.json`). Requested model is policy, not observable. Stopping before implementation, as instructed.
