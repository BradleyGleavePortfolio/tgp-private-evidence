# S4 R5 — validation request 1 (single applicable bundle; not process volume)

Exact source: `/home/user/workspace/worktrees/s4-r5`, HEAD `88287cff47240aa58b5f0fea5da08670f1e87df6`,
tree `a2879859882770f45b88f1651438436fd96376f9`, parent `2bcf1563…`, bundle
`execution/s4-r5/artifacts/s4-r5-88287cff.bundle` (sha256 `f8de3d63…1fcf97`, requires `0111be66…`).
Predecessor control: frozen `worktrees/s4-r4` @ `2bcf1563…` (clean, untouched).

Shipping bytes changed (`background.js`, `shared/session.js`) → fresh package + positive/negative browser proof; **no
inheritance of zip 6fe9a7be evidence**.

Precondition: dual independent follow-up audits of 88287cff closing S4-R4-A-01 and S4-R4-A-02 by exact head.

Requested slot (named, one holder, `flock -n` on `execution/test-validation.lock`, every step stamped, fail-closed
runner per parent correction: unexpected positive-step/discriminator outcomes fail the run, whole allocation bounded,
known predecessor head required, no stale dist after package failure, DEAD/no-sentinel = unknown). Budget ~25 min.

1. `npm ci` in s4-r5 (package-lock sha256 `262d4b69…cdae8`, unchanged) — record `prepare`/lefthook install.
2. Focused: `vitest run test/refresh-admission-epoch.spec.js test/session-ownership-preflight.spec.js test/session-ownership.spec.js test/refresh-coalesce.spec.js test/ingest-auth.spec.js test/session-refresh-path.spec.js test/auth-body-deadline.spec.js test/session-establishment.spec.js test/start-import-hardening.spec.js test/session-lifecycle.spec.js` (expect all pass; count reported).
3. Full suite `npm test` (R4 baseline 1714 on 2bcf; expect ≥ 1714 + 25 new).
4. `npm run gates`; `gitleaks detect` (8.30.0, repo policy `.gitleaks.toml`).
5. Discriminators, candidate then predecessor, in-slot for the record: `a01-preflight-barrier-discriminator.mjs s4-r5 --expect fixed`, `… s4-r4 --expect defect`, `a02-queued-refresh-discriminator.mjs s4-r5 --expect fixed`, `… s4-r4 --expect defect`; R4 builder probes on s4-r5; reviewer B's unmodified probe on s4-r5 (expected exit 1 by design — record as expected-divergence, not pass).
6. Package: build zip from 88287cff, sha256 + MANIFEST; abort remaining steps on package failure (no stale dist).
7. Browser (A3 harness root cause still open): FIRST the Chrome-alone `--remote-debugging-pipe` discriminator (cold then warm, 15 s bound, bytes-on-fd4 recorded). If pipe dead → stop, report harness-blocked, do not label flake, do not retry blindly. If alive → loader positive proof on the new zip (service worker up, `request_session_state` round trip, pairing untouched) AND negative/control proof (base zip or deliberately broken manifest must FAIL), per mail 8.
8. Final exit record: head/tree/dirty, per-step exit codes, durations, lock holder, sentinel.

Not requested: DB setup, multi-process probes, remote push, any change to `initialization/recovered/*`.
