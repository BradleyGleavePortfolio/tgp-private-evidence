# Builder acknowledgement of audits/s2-r55/a/revision-1 (read 2026-09-22 ~06:1x UTC; manifest verified). No code written, no execution; v5.5 packet stays frozen (SHA256SUMS.outer `0d733299…88a4` re-verified). B's evolving output not accessed.

Confirmed against the frozen bytes (deterministic, not runtime mysteries):
- **A-01 (high)** runner L94 sets `IDDIR="$OUT/.pgid"`, then the register line L103 resets `IDDIR=` → every id file path becomes `/<label>.pgid` (root); `rm -f`/write outside the lane; child `exec`s regardless of publication success. My defect (introduced when the register line was extended). Confirmed by grep. Blocks 08 and 09 outright.
- **A-04 (medium)** driver L119 K2 predicate `(recorded groups [digits]` cannot match the v5.5 message `(owned groups […] retired […])`; `run_runner` L89 requires `RECEIPT.txt` from the frozen v5.3.1 predecessor (K7pre/K8pre) which never writes one → `new1` strikes before K7. Both deterministic stale predicates. Also the 37-file verification line in request 08 is cwd-relative and must run from `s2-setup-prep`.
- **A-02, A-03, A-05, A-06**: accepted as stated (startup/unknown acquisition not uniformly fail-closed across step/cleanup/enclosure paths; watchdog reads historical `.pgid` files instead of the current validated authority, its sleeper is unowned, plain pids never retired, no bounded driver cancellation/publication; receipt/outer-manifest write status unchecked and the evidence phase not fully owned/bounded; prisma CLI hash checked only after `--version` executed it).
- Kept as source-closed per A: CHECKPOINT_DISABLE export/env -i carry (environment correction only — not evidence of historical egress), post-hash mutation removal, deadline anchor, K1 exclusive enclosure normal path, refusal without signals.

Successor scope (to be prepared only after the parent consolidates A and B — no new code under this message):
1. Remove the `IDDIR=` reset; assert `IDDIR` is a non-empty subdirectory of the invocation's `$OUT` before any remove/write; child gates `exec` on a successful identity write (publication failure → exit before client work).
2. One startup contract for `run_step`, `owned_cleanup_cmd` and driver `enclose`: publication must succeed before work; on interruption consume the published identity if present; dead/unknown leader → nonzero/quarantine, never "empty"; bounded pid-only fallback; driver strikes on unconfirmed enclosure.
3. Driver: single current validated enclosure authority variable (cleared at retirement), watchdog owns/reaps its sleeper and appears in the census, plain-pid records retired when dead, bounded driver cancellation/escalation + reserved publication; totals classified after publication.
4. Predicates: K2 asserts `owned groups [none] retired [...]`; receipt requirement only for successors (predecessor format checked separately); verification from the manifest's own directory.
5. Receipt phase: own/bound the whole evidence operation (find/sort/xargs) with kill-after, check receipt and outer-manifest write status, classify actual exit after publication/deadline outcome; a failed final receipt never exits 0.
6. Move prisma CLI existence/hash refusal before the first `--version` invocation.
7. Prepare N4 (caller-group decoy through cleanup), N5 (declared synchronization seam / controlled publication failure — not a probabilistic sleep), N6 (lane lock held by a separately owned controller at the final gate → 4).

Awaiting the consolidated A+B disposition before writing any successor bytes.
