# S5 V2 X6 retained-holder recovery grant

Parent EXEC-e8d546f9, 2026-09-23. Effective on explicit delivery to executor `restore_upstream_proof_inputs_muddwjad`. This is a one-time private fixture recovery, not a control rerun, result acceptance, source repair or canonical setup grant.

## Exact identity and evidence

Failed execution remains driver raw 1, SUMMARY pass=8 fail=1, stopped at X6.normal_release_failure_holds. X6.release_after_exact_repair and X7 remain NOT RUN. Initial result manifest `3c3fc4e2340c445d958a82c4472cc458dc5cd4acc898f046d56e0d805637eb06` is a point-in-time inventory, not a claim that live heartbeat files stopped changing. Preserve it unchanged and retain the immutable pre-recovery copies separately.

The sole recoverable holder is PID 26214, starttime 519891, SID/PGID 26214, EUID 2000, token `20260923T020634Z-26214-18852`, exact launcher `b32cc20d0dbfa2490fad1d642f1044791f73c9f377ec8a9958d8471699df1c09`. Its fd 9 is the private lock:

`/home/user/workspace/execution/e8d546f9/s5-setup-v2-control-result/data/20260923T020459Z/X6/private.lock`

Executor observation at 02:09:56 UTC and parent read-only observation at 02:12:50 UTC agree on PID/start/SID/fd9 and token. Workload session 26278 is empty, its leader absent; the holder session contains the launcher and its heartbeat sleep only. The launcher records `session=26278 inner=[none] census=[26278:empty]`. No claim of a globally free canonical lock follows from a partial readable-process census.

## Authorized one-time operation

Revalidate exact PID/start/SID/EUID/token/fd9 and explicit workload-session emptiness immediately before repair. If any identity is stale, unavailable or mismatched, or work is live/unknown, STOP without mutation. Preserve another timestamped read-only snapshot if needed; do not overwrite the earlier snapshot.

Use the existing reviewed fixture repair shape, restricted to:

- Directory: `/home/user/workspace/execution/e8d546f9/s5-setup-v2-control-result/data/20260923T020459Z/X6/LEASE_RELEASE`
- Sole removable deposit: that directory's `LEASE_RELEASE.tmp.26214`

Before each attempt, require a real, non-symlink directory and no entry except this exact regular, non-symlink deposit, or an empty directory. Refuse unexpected contents before deleting anything. Remove only that known deposit, then `rmdir` the empty directory. At most five attempts separated by 0.3 seconds, accommodating the existing heartbeat. No recursive deletion, wildcard deletion, renamed obstacle, synthetic RELEASE, source edit or permission change is authorized. If frozen directory permissions prevent this operation, report the exact path/mode before any chmod.

After repair, allow the existing holder's retry to publish its own RELEASE and terminate naturally. Observe for at most 30 seconds using read-only identity/session/fd checks. If it remains alive or evidence becomes unknown, STOP and return the unresolved facts without escalation.

## Truth and closure

Keep driver raw 1 and 8 PASS / 1 FAIL unchanged. Expected release is `how=self-hold-then-empty`, original raw `observed 0`, accumulated `publication=release-record-failed`, `recovery=none`; the source branch exits 90. Since the original driver's parent has exited, do not report an actually reaped 90 unless an existing attributable exit receipt proves it. Distinguish recorded intended final status, process disappearance and a wait-observed status.

Preserve repair command/output/status, before/after identities, holder and workload-session accounting, final LEASE_RELEASE/LEASE_HOLDER/SELF_HOLD/EXIT_RECORD, and an additive post-recovery manifest. Do not rewrite the original failed-result manifest to pretend a stable pre-recovery freeze. An immutable copied final snapshot may be separately frozen.

No signal of any kind to the holder or its children, no handoff, private or canonical lock open/probe/deletion, npm, installation, network, source/worktree mutation, resumed check, rerun or later lane activation. All other runtime remains paused until the parent accepts accountable slot closure.
