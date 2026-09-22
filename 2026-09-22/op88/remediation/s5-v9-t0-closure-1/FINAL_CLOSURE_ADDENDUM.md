# V9 FINAL CLOSURE ADDENDUM — reviewer B (owned-launch-v8-b, frozen 2026-09-22T21:32:34Z) mapped onto the frozen V9 candidate; NO byte change
Worker s5_selective_v7_fixer_mud58q6n, 2026-09-22T21:3xZ. Additive only; V9 packet `execution/op88/s5-v9-t0` re-verified 18/18 against
`SHA256SUMS.s5-v9-t0` = `36f04f84a08192f7d9e7ad4358dcb453a0243b4ee8f8ae0aab989e94f3e188c3` and left byte-for-byte. Nothing executed.
Both independent V8 conclusions (A: manifest 9f54e9d7, findings A-01..A-06; B: V8B-01..05, O-01..O-04) are now folded; A was already
mapped in `s5-v9-t0/V9_OWNED_LAUNCH_REQUEST.md`. Result: every material B finding is already source-closed in the frozen V9 bytes, so
per parent instruction this is an exact-hash addendum, not a new revision.

Line references are into `s5-v9-t0/own-block-v9.sh` (`9d713d2cc50dcb33d…`, 66 lines), `controls-v9-t0/ctl-t0-only.v9.sh` (`38f8ec0169f223f53…`),
`controls-v9-t0/run-s5-setup-npm-ci.v9.sh` (`da5228c20347b164c…`), `controls-v9-t0/ctl-own-launch.v9.sh` (`f1f8182cd37f7985b…`), `controls-v9-t0/sup-under-test.v9.sh` (`b9d3383367d2f4324…`).

| B finding | V9 mechanism (frozen bytes) | Control discriminator | Disposition |
|---|---|---|---|
| V8B-01 HIGH retired pids remain targets; shape test not ownership; no retire | `own_is_child` (ppid==$$) L21 precedes `own_alive` L23, `own_confirm` L29, `own_signal` L39; `own_retire` L55 removes pid+group after `own_finish` (actual wait) and verified-empty session — T0 run_gate retire line, setup post-reap retire; `own_pending`/`own_reap_all` skip `OWN_RETIRED`. Start-time binding not added: a reused pid can only pass ppid==$$ if it is a child *we* spawned, which is then itself registered — ownership follows the registry, not the number. | C13 (retired pid → `notchild`, non-child pid → `notchild`, retired group → `refused`), C10 (stale `$!` == retired pid never signalled) | SOURCE-CLOSED; start-time binding declined as unnecessary under direct-child binding (disclosed) |
| V8B-02 MED unconditional wait on identity-refused KILL-survivor path | `own_finish` L52 returns `unobserved` and never `wait`s a live child; T0 uses it on every branch (refused, budget, normal) → synthetic 137; setup identical (`FIN=$(own_finish …)`), quarantine on unobserved | C3/C4/C5/C6 refusal paths record `raw=observed 75` / signal outcome; unobserved path is not deterministically producible without an unkillable process — asserted by construction (no other `wait` call sites: `grep -n 'wait "' ` shows only inside `own_finish` and the enclosure) | SOURCE-CLOSED |
| V8B-03 MED leaderless confirmed-group survivors never signalled | session-based `own_session_members` L41, `own_group_signal` L46–50 signals every pgid of our session whose members all belong to it; `own_reap_all` group loop L62–65 TERM → bounded → KILL → bounded, independent of leader liveness | C11 leader-first-exit with TERM-ignoring same-session grandchild → `GROUP_REAPED … +KILL`, `reap_rc=0`, `group_current_rc=1` | SOURCE-CLOSED + control added |
| V8B-04 MED zombies counted as GROUP_SURVIVORS; no reap_rc assertion | zombies excluded in `own_session_members` (awk `substr($3,1,1)!="Z"`) and `own_group_current` L43; consumers call `own_finish` (wait) before group census | `reap_rc=0` asserted in C1, C7, C8, C9, C10, C11, C12, C14 (driver lines 46,59,61,63,65,67,69,73) | SOURCE-CLOSED + assertion added |
| V8B-05 LOW `&`→register window | `own_spawn_begin` L20 / `own_pending` L24–26: `$!` used only in phase `spawning`, not registered/retired, verified live direct child (parent's bound; not bare `$!`) | C8 TERM inside spawn before `$!` is read → `phase=spawning registered=[] REAPED pid=…` | SOURCE-CLOSED |
| O-01 mktemp before TERM trap (T0 L137 vs trap later) | inherited ordering unchanged; a TERM in that gap leaves one empty `/tmp/s5-r4-gate-*` dir and no process | — | ACCEPTED RESIDUAL (no process/evidence impact) |
| O-02 no publication-failure control | `own_adopt` L35–38 names all outcomes | C5 write-fail → `adoption=publication-write-failed`, no workload | CLOSED |
| O-03 consumer lines uncontrolled | fixture `cycle` reproduces the exact consumer sequence (attempt → spawn_begin → setsid gate → register → confirm → adopt → finish → group → retire) and the exact spawn shape; the consumer scripts themselves need jest/npm and stay unrun | — | ACCEPTED RESIDUAL until R2'/T0 grants |
| O-04 thin T0 margin | v9 adds ≤ 2 s confirm + adoption; worst case ≈ 90+10+3 (+2+1 group) + EXIT reap ≤ 13 → ≈ 120–125 s vs outer 140 -k 20; still labelled allowance, not attestation | — | UNCHANGED, DISCLOSED |
| B verdict "R4 grantable on V8 bytes" | parent HOLD stands (A-06 cancellation/publication findings); V8 controls not requested | — | NO V8 EXECUTION REQUESTED |
| B prior status S5-V7-A-03 PARTIALLY_CLOSED | v9 `own_finish` + admission budget + bounded group escalation; end-to-end still an allowance | — | as O-04 |

## FINAL reviewable manifest (exact bytes for the two independent reviews)
`execution/op88/s5-v9-t0/SHA256SUMS.s5-v9-t0` = `36f04f84a08192f7d9e7ad4358dcb453a0243b4ee8f8ae0aab989e94f3e188c3` (18 files) — reviewers should read this addendum
and `s5-v9-t0/V9_OWNED_LAUNCH_REQUEST.md` (A mapping) together; the candidate is no longer moving.

## Next-review request
R5: two independent exact primitive+consumer applicability reviews of `own-block-v9.sh` + both consumer diffs + control driver/fixture against
OWNED_LAUNCH_SCOPE acceptance, A-01..A-06, V8B-01..05, S6-B Part B. On dual closure: R6 deterministic controls slot
(`cd execution/op88/s5-v9-t0 && S5_CTL_GRANT=granted-by-parent timeout --foreground -k 10 200 bash controls-v9-t0/ctl-own-launch.v9.sh`,
guarded raw-status capture as in the R1 grant; fake children only). S6 adaptations (746e244d, 91fe0f1b) only after primitive exact-byte acceptance.
Truth: implemented+`bash -n` only; tested nothing; success of R6 would prove primitive behaviour with fake children, not jest/npm/DB/T0/S6 outcomes.
