# S11-A1 real-PG proof run-1 — RC=1 (7/8), preserved, not rerun
- Run: binding/v1/run (sentinel RC=1 STAGE=jest-journey; rls 6/6 passed; journey J01-J06, J08 passed; J07 failed at journey-core.pg.spec.ts:620).
- Finding (class B, proof defect): J07 asserted B's legacy status for A's intent string carries execution_epoch null. The landed status contract (src/scout/scout.dto.ts, S7-L note) projects legacy rows as mode='legacy', phase=null, null clocks, execution_epoch=1. mode!='server' and entity_counts=[] passed, so the row read was B's own legacy row, not A's server run: no cross-tenant read.
- Concrete harm: none (no product/data/security consequence).
- Blocked: S11-A1 acceptance only.
- Minimum fix: J07 asserts mode='legacy', null phase/clocks, empty counts, execution_epoch=1 (J07-fix.diff, 23 lines; test-only).
- Unblocks: S11-A1 proof v2 (new binding version and run dir; run-1 stays preserved).
