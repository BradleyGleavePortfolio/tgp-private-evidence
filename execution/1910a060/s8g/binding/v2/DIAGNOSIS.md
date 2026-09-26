# S8G-DIAG-1 diagnosis — 820ce85b real-PG spec: 5 failed / 14 passed / 19 (fresh diagnostic, 2026-09-26T00:44:30Z–00:46:16Z)
Receipts: run/jest.log, run/s8g-pg-proof.log, run/RECEIPTS.sha256 (attempt 0 = precondition refusal, preserved separately).
Note: the handoff said "5 of 19 passed"; this fresh run shows 5 FAILED, 14 passed. The predecessor receipt is lost, so no claim is made about it.

| test | class | concrete harm | exact thing blocked | minimum fix |
|---|---|---|---|---|
| P03, P05, P07 (gate counts +1) | B | none to customers: `isGate = q.includes('last_observed_at')` also matched Prisma's plain SELECT of the ScoutImport row (the column list contains last_observed_at) | S8-G proof/acceptance only | match only the gate UPDATE: `/SET last_observed_at\s*=/` |
| P01 (evidence label) | B | none: product correctly labels rt-c from its own payload title; the test ingested rt-c with the rt-1 payload ('Push Day') but expected 'Client Push' (the value in the unused stagePlanned helper) | S8-G proof/acceptance only | give rt-c its own title 'Client Push' in the P01 ingest (label must come from its own row — stricter) |
| P11 (ImportNativeProvenance read) | B | none: landed migration 20270122000000 REVOKEs ALL from anon/authenticated, so the read is refused with permission denied (stricter than 0 rows under RLS) | S8-G proof/acceptance only | assert refusal `refused(..., 'permission denied')` |

No class A. Product bytes unchanged. Closure: candidate 1279b419ee60b25163c7e6d2809b749dd723fee9 (tree 44ece797, parent 820ce85b, spec only, hooked Bradley commit;
bundle landing/bundles/s8g-1279b419ee60.bundle). Unblocks: dual review of the changed question → binding v3 grant → one real-PG proof → acceptance → compose/land.
