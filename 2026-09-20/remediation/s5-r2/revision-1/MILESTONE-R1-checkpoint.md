# S5 G2 — R1 checkpoint (2026-09-20 17:00 UTC), per user directive

Grade/model requested: T4 Claude Fable 5 High (requested setting; actual reasoning setting not claimed).

## Candidate (committed, untested-live)
- Worktree: /home/user/workspace/worktrees/s5-g2, branch execute/20260920-s5-g2
- Base (preserved G2 head): d7404cd4 (= origin/agent/operator-82/g2-t-q0), main base c23b9d9f
- HEAD: 65b1da27d9dab4f51f5fad6d8a05be8b64e53dde
- TREE: 9bbc0223e809e8e9b10b541bbde98b11903be362
- Author/committer (git var): Bradley Gleave <bradley@bradleytgpcoaching.com>, repo-local, no AI co-author.
- Changed (validation-only, 5 new files, +1125): test/utils/g2-pg17-db.ts, test/utils/g2-pg17-harness.ts,
  test/utils/g2-pg17-bootstrap.sh, test/scout/g2-pg17-db-guard.spec.ts, test/rls-g2-pg17-etq0.spec.ts.
  No schema/migration/generator/service change (S1 ownership respected). #522 and G2 commits untouched.
- Working tree clean after commit; parent may snapshot the index.

## State
Written: yes. Type-checked/compiled: NOT yet. Run live: NOT yet. Audited: no. Merged/deployed/enabled/customer-accepted: no.

## Pending proof (next, under execution/test-validation.lock)
1. `npx jest test/scout/g2-pg17-db-guard.spec.ts` (default lane unit spec)
2. `bash test/utils/g2-pg17-bootstrap.sh` (PG17.6 identity, shim, 164-migration O base from 925780e0, O client, candidate client)
3. `npx jest --config jest.rls.config.js test/rls-g2-pg17-etq0.spec.ts --runInBand --testTimeout=180000`
Runner: /home/user/workspace/execution/s5-g2/run-proof.sh [guard|bootstrap|live|all]; logs in execution/s5-g2/logs/.
npm ci + prisma generate for the S5 worktree completed 16:58:55Z (install-secondary.lock, parent exception), rc=0.

## Known unknowns
- Spec has not compiled yet; first live run may surface TypeScript/fixture errors (harness, not product) — will fix harness issues; any product-behaviour failure with unknown root cause will be escalated, not worked around.
- Timing-sensitive assertions (lock-timeout ≥5s window, 1,050-row writer volume within 90s worker cap) are untested on this box.
- Whether the old-client generation into a custom `output` dir behaves identically to Agent83's lost environment.
- Finding already identified from reading E: down.sql leaves the `_prisma_migrations` row for E applied, so after an operator down `prisma migrate deploy` will NOT re-apply E (spec asserts this as a characterization; S1 owns any fix).
- Historic donor 21-case/62-assertion proof (6b263c2f, fix/scout-ingest-integrity-r2) is stage-specific to a widened-key migration not adopted by E; cited, not claimed as E/T evidence.
