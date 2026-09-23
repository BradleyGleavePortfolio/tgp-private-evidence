# CONTROL REQUEST — OP88-OWNED-LAUNCH-V10.1 fake-child diagnostic (smallest exact control; NOT granted by this document)

Requester: S5-V101-BUILD sole builder. Grantor: parent (e8d546f9). Preconditions: two independent exact reviews of `SHA256SUMS.s5-v101` have closed with no material blocker on the primitive, fixture and driver; no inherited clearance from V10 A or from the frozen V10 diagnostic.

## Exact invocation (relative paths only; packet root is wherever the parent publishes these exact bytes)

```
cd <packet root>   # e.g. /home/user/workspace/execution/op88/s5-v101-t0 once published; manifest must verify 24/24 first: sha256sum -c --quiet SHA256SUMS.s5-v101
S5_CTL_GRANT=granted-by-parent timeout --foreground -k 10 230 bash controls-v101-t0/ctl-own-launch.v101.sh; rc=$?; echo "ctl-own-launch.v101 rc=$rc"; exit $rc
```

Caller rule: capture the actual status immediately, report it, return that same status. No retry, no unconditional success echo, no relabeling.

## What it touches

- Sources only `own-block-v101.sh`; launches `sup-under-test.v101.sh` fake supervisors (sleep-based synthetic children) under the v10.1 primitive; hashes and greps (read-only) the T0/setup successors.
- Writes only under `${S5_V10_OUT:-<packet root>/control-results}/<UTC ts>/` (private, fresh per run). Sets no lock, opens nothing at `/home/user/workspace/execution/test-validation.lock` (stat only, logged), installs nothing, no network, no DB, no Jest, no npm, no worktree, no product path.
- Bounds: aggregate admission 190 s + cleanup reserve; external `230 -k 10` is a nominal allowance, not a completion attestation. Driver refuses a case that cannot fit.

## Expected outcome (static, not evidence)

25 PASS / 0 FAIL, final rc 0. If any earlier check fails the driver stops at that check with rc 1 and its EXIT trap reaps/censuses the enclosure (rc 90 on cleanup failure; rc 74 if primary 0 but a required EXIT record failed — the A03 latch).

## Acceptance for this diagnostic only

- Retain the whole `control-results/<ts>/` tree, including `sup.out`, `trap.out`, `sup.stdout`, attempts (`IDENTITY`, `ADOPT`, `EXIT`) and the log; preserve raw child statuses (`fixture-exit primary_rc= cleanup_rc=`, `observed 0/75/143`), never rewrite.
- A PASS here proves only the primitive/fixture/driver behaviour on synthetic children on this host. It does **not** transfer clearance to T0, setup, the setup-exclusion boundary, S6, install, database, native or product acceptance.
- Any unexpected failure stops the affected scope; return the exact log to the parent, no rerun without a new grant.

## Not requested

T0 (`ctl-t0-only.v101.sh`), setup (`run-s5-setup-npm-ci.v101.sh`), any install, lock, network, S6 consumer, or a second fake-child run.
