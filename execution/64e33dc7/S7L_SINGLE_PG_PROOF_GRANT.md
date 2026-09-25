# S7-L replacement single real-Postgres proof grant

Parent activation, 2026-09-25 05:06Z. Sole executor and canonical heavy-slot grantee: `s7_l_replacement_builder_muge72rg`. This is the first real-PG proof of the new owner-reset S7-L lineage, not a rerun of accepted history or a predecessor candidate.

## Exact authorized bytes

- Accepted base: `93389265a846095b846fa8f1fb0dad782fb6ee9f`.
- Preserved initial replacement parent: `839b54c53ccb252f95b4ec63df0b08595bbe7698`.
- Candidate head: `54970cd937afc8dea689b33243961abfef8b9dd6`.
- Candidate tree: `513c71d7c1390787e1521ccbfa46b30bb52b5462`.
- Worktree: `/home/user/workspace/worktrees/64e33dc7-s7l`.
- Filled driver: `execution/64e33dc7/s7l/binding/v2/s7l-pg-proof.sh`, SHA-256 `0287a941655b0ff9ec19a306af943fd93c357c00b6187f6ad31dfc90c1de2705`.
- Fixture: `s7l-fixture.sh`, SHA-256 `dc77a7c9b52a439914fe0fdb0903bd6a55b1f47a692a5cda0a22c3a6522b3dd2`.
- `binding/v2/BINDING.sha256` file SHA-256: `01985b8561fda734e8f4d9821dd9e2e231fd819d2ba63bae5f28735575531be2`.

The original binding is superseded for execution and must not run. Do not edit any source, pin, driver, fixture, assertion or tool to pass a precondition.

## Evidence and slot prerequisite

Both independent nonbuilder changed-question attestations are GO for these exact bytes and binding: `s7l/reviews/REVIEW_A_V2.md` (SHA-256 `54137d5ae8356d8b11df8d239b1a551c5bfe7ea72dd68c717771073d530c1c34`) and `REVIEW_B_V2.md` (`04dff3bd7742e76afcb5fdb5e0091a8223a3ee5b0a176f48f981e9368f16055a`). F1 A and F2 B are closed for the execution decision; original failures and reviews remain unchanged. Runtime is not yet proved.

S8-C's actual correction driver completed and released the canonical lock at05:02:44Z. Parent read the terminal record, and at05:05:01Z observed no holder, zero postgres processes, free55641/55642, and absent S7-L lane, old-root and proof-run directory. S8-C source-gate authority is ended; its remaining review/binding work is read-only. The S7-L runner must still acquire the existing canonical lock nonblocking in its own process and refuse any live holder. Never delete or steal the lock.

## Execute once

Run exactly once, with a durable bounded launcher that survives the tool-call lifetime:

```sh
timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v2/s7l-pg-proof.sh
```

No exploratory database invocation, pre-proof probe, separate bootstrap or retry is granted. The unchanged driver owns the sequence: read-only preconditions, accepted-base old-root preparation, fresh synthetic fixture initialization and start, committed bootstrap, identity checks, the single committed `test/rls-g2-s7l.spec.ts` invocation, bounded stop, retained data, postchecks and receipts. All heavy work remains inside the actual driver's canonical flock.

Authorized lane only: runtime root `execution/64e33dc7/recovery-reset`, data `clusters/s7l/pg-data`, socket `run/s7l`, port55641, database `g2_s7l_disposable`, synthetic admin `s7l_super`, cluster marker `s7l-disposable-pg17`. Old-root is `recovery-reset/s7l/old-root` at the accepted base. The disposable proof alone exercises171→172 migrations and down/up coverage. No production or other lane database is addressed.

Record the launcher, actual runner PID, start, terminal exit, stage, test counts, cleanup status, surviving processes/listeners if any, lock release and exact head/tree. Preserve every output verbatim, including any refusal or failure. First failure stops as bound; only the already-bound cleanup may run. Retain the data directory. No automatic retry, fixture destruction, source remediation or broad test run.

## After the run

Return the observed result promptly. A passing command is not self-issued acceptance: the two original independent reviewers disposition the new runtime receipts against their exact-head attestations without repeating unchanged source review. The parent then accepts and lands dependency-valid non-production work under standing authority.

Backend production main, activation, live source accounts, principal/roster policy, G3-AUTH, branch protection, spending and external commitments remain reserved. This grant changes none of them.
