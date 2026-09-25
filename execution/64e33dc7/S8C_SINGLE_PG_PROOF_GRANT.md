# S8-C single new PostgreSQL proof grant

Parent grant, 2026-09-25 05:29Z. Executor: `s8_c_replacement_builder_muge72rc`, sole heavy-slot grantee for this execution only. This grants one first S8-C real-PG run of the frozen candidate below, not product acceptance, activation or landing. It does not authorize a retry of any failure or source correction.

## Exact accepted-for-proof identity

| Item | Pin |
|---|---|
| Candidate head | `87018a421f5be1064767d2cdd32e75ca935f7cdb` |
| Candidate tree | `cec7d05a91876ec3f6badb1020bb97aacdb9331d` |
| Exact parent | `af9f7f5438fa545394b6d28792411439ded66caf` |
| Accepted ancestor | `93389265a846095b846fa8f1fb0dad782fb6ee9f` |
| Worktree | `/home/user/workspace/worktrees/64e33dc7-s8c`, clean |
| Filled driver | `s8c/binding/v3/s8c-pg-proof.sh` |
| Driver SHA256 | `9ddb52de66c306601080141c38867d25cd048c951e7c57086996ee4ef40eacd8` |
| Fixture SHA256 | `1a7faa5ff4a4937216c329fa8ce810f559085c7ca8f9295c15f9e7a57c0a07b3` |
| BINDING.sha256 file SHA256 | `ede987a6536f35103f978d97690e45ed84d58c196615560561fbef3d9f7514ec` |
| Proof spec blob | `dc804fdef00757732a7e75eeb13dcd30d1920cb4` |
| Independent REVIEW_A_V3.md SHA256 | `f9a05280ea40b155f5ddba46c062134f46c011fcd291bf7b734a7325f2cc212c` |
| Independent REVIEW_B_V3.md SHA256 | `6b7e1357a24db49bc1e2a359f0fc0af899130daac465cfec0f03abefc5a5c6fd` |

Both independent reviewers recomputed the candidate and filled binding and returned GO. All four source/proof findings are closed. Parent read both complete reports, the committed seven-path delta, the filled driver and its exact four-line v2-to-v3 delta, and verified the manifest. The unauthorized source-gate retry remains recorded under `S8C_GATE_SEQUENCE_DISPOSITION.md`, not retrospectively authorized; this is new, explicit authority for the first PG invocation only.

## Relay and preconditions observed

S7-L's narrow correction source gates completed at new heada68cdac7, released05:25:39Z. At05:29:07Z parent observed no canonical lock holder; lock inode691716 intact; no postgres, psql, test, compiler, npm, Prisma, formatter, hook or Git process; only the two platform Node daemons415/454. Ports55641/55642 had no listener.

S8-C's data lane, socket directory and v3 sentinel were absent. The retained failed S7-L v2 lane had no postmaster.pid. Its stopped conf/control SHA256s were:

- `postgresql.conf`: `ae1fc878604dae6681f71580187d6da7e440268930c44cadaf45d83304358bdd`
- `global/pg_control`: `c2d8ebd859f64bd69e044b1e8e3ac21b6802b16d8a3d584528b96c8854153c15`

Those are observations, not permission to ignore the driver's live preflight. If a holder, process, occupied port, existing lane, pin mismatch or other refusal appears, stop and report. Never remove a lock, reset a sentinel, change a pin or adopt an existing cluster.

## One authorized invocation

```sh
timeout -k 30 3600 bash /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c/binding/v3/s8c-pg-proof.sh
```

Recheck the granted head/tree and binding hashes read-only immediately before launch. Use one durable detached supervisor with stdin and output explicitly redirected to new launch receipts under `s8c/binding/v3/run/`; do not invoke a second driver when a launcher/tool call returns or times out. Record the exact command, timestamp and supervisor/driver identity. The unchanged driver itself, not a separate holder, takes the canonical nonblocking flock on fd9 and retains it through bounded cleanup, post checks, receipt hashing and sentinel.

The only runtime scope is the driver's bound sequence: fresh PG17.6 fixture on loopback55642 at `recovery-reset/clusters/s8-c/pg-data`, socket `recovery-reset/run/s8-c`, database `g2_s8c_disposable`, existing synthetic roles/markers; committed bootstrap of171 migrations; identity checks; exactly one `jest --config jest.rls.config.js test/rls-g2-s8c.spec.ts --runInBand --ci`; bounded stop with data retained; existing post checks and receipts. No accepted suite, S7-L proof, generator, install, client regeneration, source edit, commit or push.

First failure ends the run through the existing bound cleanup. Preserve every output verbatim, report stage/rc and actual stop/lock/process state. There is no automatic remediation, retest, fixture destroy, sentinel removal, broad process kill or invocation of an old binding. Any survivor or non-exiting stage must be reported for narrow parent disposition; do not infer cleanup succeeded from design alone.

## Evidence and disposition

Write the final run receipt under `s8c/binding/v3/run/PROOF_RUN_RECEIPT.md` only after a terminal result, recording raw Jest totals, natural versus forced exit, sentinel/manifest qualification, stopped/retained state and exact candidate identity. Freeze the candidate throughout.

Existing independent reviewers will assess the observed new runtime receipts without repeating the unchanged source audit. Passing output alone is not this grant's product acceptance. After reviewed acceptance and dependency validation, parent may land automatically to authorized non-production integration under the standing owner amendment. Production, flags/readers, principal policy, S8-D/E and real accounts remain reserved or prerequisite-gated.

S7-L is limited to source-only binding completion and independent review meanwhile. It has no PG grant and must not reacquire the heavy slot.
