# OP88-S5-SETUP-EXCLUSION — frozen checkpoint (parent option (a)); PREPARATION ONLY, nothing executed
Justification: the concrete V10 A-04 defect only (setup HOLD_BOUND 60 → FINAL 90 `exclusion=unpreserved` = delayed release of unresolved ownership). V10 (`fdc99771…`) and the shared primitive are unchanged; the OWN-BLOCK v10 bytes are embedded byte-identically in the launcher (diff-verified) — no new primitive applicability.

| File | SHA256 | Role |
|---|---|---|
| `launch-s5-setup-exclusion.v1.sh` | `1773ac7d2b37670c2dd711347a3cc1515fb5fbb68adcc680381a26434f30e033` | outer explicitly owned lease holder |
| `run-s5-setup-npm-ci.v10x.sh` | `3a7b57d132fccbf16f4ad3ee0b56a314a2bccf7cfc48b6765a4305cbc2627c1c` | V10 setup + lease inheritance only (`setup-v10-to-v10x.diff` +11/−1: verify fd 9 on $LOCK, LEASE_HOLDER token + live holder, no flock; else V10 behaviour) |
| `observe-s5-setup-exclusion.v1.sh` | `157bf1f45a51c3db4f960dcd72d4ac33ff2d27323e6b747c8ec065388fd6911e` | read-only bounded observer (records + /proc pid/start-time; never opens the lock) |
| `controls-exclusion/ctl-exclusion.v1.sh`, `fake-runner.sh` | `2de9500ff134334a7939959ed45c941ddfda4cb3b9c65ddb14c407887c85d088`, `230ff6c571f00bde8c45578cd655657c91ba8ee155cdfb286e1ca31998023cac` | private fault controls (unrun) |

## Exact correction
1. Lease acquired ONCE by the launcher (`flock -n` on fd 9) and `LEASE_HOLDER` (token, holder pid/sid/pgid, /proc start time, launcher+runner hashes, state) published atomically BEFORE any child exists; publication failure ⇒ nothing launched, exit 74.
2. Runner launched through the unchanged primitive: setsid gate child, register, confirm, IDENTITY record, then ADOPT; fd 9 inherited (runner verifies, never re-acquires; npm still gets `9>&-`); inner `timeout -k 30 1290` bounds the runner, NORMAL_BOUND 1380 s bounds the launcher's normal wait. The launcher itself runs WITHOUT an outer timeout (invocation in header).
3. RAW runner result via in-shell `own_finish` (`raw=observed <rc>|unobserved`), kept separate from `cleanup`, `publication`, `recovery` in every record.
4. Release ONLY when `own_group_current SESSION` is observed-empty AND `LEASE_RELEASE` is published; final rc = runner rc on the normal path, 90 on any exceptional-then-empty path.
5. Exceptional (session live after runner exit, launcher signal, runner not released): ONE escalation inside the exact owned session (`own_reap_all 30`: TERM → KILL; never the holder), then re-verify; empty ⇒ release(90).
6. SELF-HOLD (distinct recorded state) on: live/unknown census after escalation, foreign session number, census error, or failed RELEASE/SELF_HOLD publication: holder record state=SELF-HOLD, `SELF_HOLD` record (primary $EX → fallback $LOGS → stderr), heartbeat every 30 s with current census; no self-imposed bound, no self-kill; exits only via observed-empty (when the record can be published) or a CHECKED HANDOFF: parent writes `$EX/RECOVERY_ACCEPT` = `accept token=<token> holder_pid=<pid> start_time=<start> acceptor=<id>`; mismatch ignored.
7. Observer: `HOLDER_LIVE` / `HOLDER_GONE_RELEASE_RECORDED` / `HOLDER_GONE_NO_RELEASE (unresolved)` / `NO_HOLDER_RECORD`; never claims termination or cleanup.

## Private fault controls (request, not run): `cd execution/op88/s5-setup-exclusion && S5_CTL_GRANT=granted-by-parent timeout --foreground -k 10 200 bash controls-exclusion/ctl-exclusion.v1.sh`
X1 normal (raw 0, verified empty, RELEASE, lock free); X2 TERM-ignoring same-session descendant left by the runner → one escalation → release rc 90 with raw 0 preserved; X3 overrunning runner ended by the inner timeout (raw 124/137/143 recorded) → release; X4 RELEASE/SELF_HOLD paths made unpublishable → launcher holds the private lock alive with state=SELF-HOLD and stderr truth, wrong-token handoff ignored, exact handoff releases with the publication-failure truth in RELEASE. Private lock/EX only (refused on canonical paths); fake children only; ≤ ~150 s. Expected 6 PASS (static expectation).

## Truth / limits
Implemented + `bash -n` (5) + block identity; tested nothing. Census-error and foreign-number SELF-HOLD triggers are not constructible with fake children (disclosed). Canonical use additionally needs: dual exact review of this packet, the private control run, fresh setup prerequisites (worktree fingerprint `6850b32e`, no node_modules), and the V10 primitive/T0 verdicts. Success proves exclusion behaviour of the launcher only — not installation, T0, S6 or product.
Next: dual independent review of this checkpoint alongside the V10 reviews; no grant requested beyond the private control slot after review.
