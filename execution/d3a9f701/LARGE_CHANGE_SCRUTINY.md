# LARGE CHANGE SCRUTINY (>1,000 hand-written production LOC) — prospective
Rule (owner, 2026-09-26): measured once at candidate freeze for active/unlanded work; if >1,000, record PROCEED / SPLIT / SIMPLIFY FIRST + one sentence, then continue. Not a retroactive gate, not an audit program.

| Slice | Prod LOC at freeze | Disposition | Rationale |
|---|---|---|---|
| S10-B (a2c74e90) | 908 src + 429 SQL/schema = 1,337 | PROCEED | Insert-only declaration/observation storage and its two routes share one table/RLS/challenge invariant and must land atomically; additive and reversible via down.sql. |

RETRO NOTE — S10-A (landed 92b96715): would trigger scrutiny under current rule (1,202 src); no reopening absent a concrete defect.
