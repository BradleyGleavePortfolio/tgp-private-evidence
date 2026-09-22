# Runner readiness defects (parent inspection 2026-09-22 ~00:00Z) — fixed, offline-proven, no product source touched

## Defects in v1 (bytes preserved: failed-readiness/run-composition-when-granted.v1-defective.sh sha256 23e7b74f…a479)
1. A global text replace of `exit $rc` produced `[ $rc -eq 0 ] || [ $rc -eq 0 ] && [ "$DISC_RC" = 0 ] || exit ${rc/#0/1}; exit 0`
   after step 10 and after step 31 → runner exited 0 unconditionally before the proof; DISC_RC unset under set -u.
2. Fixture init re-opened fd 9 on the canonical lock while the runner held it → fresh init would exit 75.
3. SHA256SUMS/exit record were not guaranteed after the last stamp; fixture stop not guaranteed on failure paths.

## Fixes
- run-composition-when-granted.sh v2 sha256 ca089210d318923b0d2b0d744cac3a6d3016af584a198926b6061d757f076b68: explicit FINAL exit = first failing step (75 lock busy, 70 refused,
  guard/fixture/harness/discriminator codes), EXIT-trap cleanup (fixture stop → exit-codes.txt → final stamp → SHA256SUMS last),
  one lock (fd 9) held by the runner from before fixture init through preflight, all mutations and the discriminator; fd 9 is
  passed ONLY to fixture init (which verifies inheritance via /proc/$$/fd/9, not env) and CLOSED (9>&-) for every other child
  (guard spec, refusal controls, fixture start/stop/status, harness, discriminator, git/node/prisma calls) so no daemon can keep the lease.
- infra/s2-fixture.sh sha256 08987e4cd566e0ee7ee8ef76ac4c39bc327ffd92fb85dfaf52fac8058d8df44c (v1 preserved as failed-readiness/s2-fixture.v1.sh): init/destroy use the inherited fd 9 when
  it is open on the lock file, else acquire nonblocking; new `lockcheck` subcommand exercises only that logic.

## Offline controls (all on private temp locks / stubs; canonical lock untouched; no initdb/server/DB)
Fixture lockcheck (temp lock): standalone → acquired, exit 0 · caller holds fd9 → "inherited fd9", exit 0 · other holder, fd not passed → 75 · caller's fd9 on a different file → not mistaken, acquired.
Runner stub mode (S2_RUNNER_STUBS, results under runner-selftest/<utc>/, stubs copied to runner-selftest/stubs-used/):
A guard-spec exit 3 → final 3, fixture/composition/discriminator notrun · B fixture init 75 → final 75, composition notrun ·
C success → steps 10,20,21,30(inherited fd9),31,40,45,50 all reached, final 0, harness+discriminator saw fd9 closed, lock still held after each ·
D discriminator exit 5 → final 5 · E harness exit 1 → final 1, discriminator notrun · F lock busy → 75 before any step.
Real refusal steps 20/21 (actual harness, offline guard) exited 64 in every stub run.

## v3 (cleanup evidence; v2 preserved as failed-readiness/run-composition-when-granted.v2.sh) sha256 2d09fd68a5cf530a423887c28b4726b1ae9266d4d8bb16bd6e913df90f7a0f0c
Fixture stop is attempted whenever start was attempted; stop exit and post-stop status are stamped; survivors (fixture postgres,
harness/discriminator/psql children, any 127.0.0.1:54321 listener) are scanned; a stop failure or survivor downgrades a passing
result to exit 71 and stamps "LOCK: NOT safely handed off". Stub controls (runner-selftest/): H stop fails → 71 · I partial start → stop
attempted, final 1 · J clean → 0 · K harness fail → 1 · L surviving daemon → 71 with survivor listed and lock not declared handed off.
