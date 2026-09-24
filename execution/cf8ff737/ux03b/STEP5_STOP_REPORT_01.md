# UX-03b step 5 — STOP at gate 1 (tsc)

Time: 2026-09-24T16:05Z. Lock taken with `flock -n` (receipt `receipts/00-lock.txt`), re-verified
write-tree `4b92827dde7ce72a0ed8c470b71c2e1fe4898bee` on frozen source before running.

## Result
- `npx tsc --noEmit` → **exit 2**, exactly ONE error (`receipts/01-tsc.log`):
  ```
  src/types/__tests__/extensionImport.contract.test.ts(496,51): error TS2339:
    Property 'import_intent_id' does not exist on type '{ status: string; }'.
  ```
- Stopped per "first nonzero stops". No lint, no Jest run. No source edit made. No retry.
- Lock released (flock held only for the gate process; verified free afterwards).
- Source still frozen: write-tree unchanged `4b92827d…`, 9 staged paths, HEAD `9ff749c`.

## Analysis (static)
Test-only typing error, product code untouched. In
```ts
const example = { ...exampleOf(successSchema('/api/extension/pair/current')), status: 'bound' };
const decoded = decodePairCurrentResponse(example);
expect(decoded.importIntentId).toBe(example.import_intent_id);   // line 496
```
TS drops the `Record<string, unknown>` index signature when spreading into an object literal with an
explicit `status` key, so `example` is typed `{ status: string }` and `.import_intent_id` is an
error. Runtime behaviour is correct; only the type is wrong.

Classification: **B (proof-invalidating), blocks only this gate.** Concrete harm: none to product;
tsc is red for the owned test file. Decision blocked: gate 2/3 cannot start.

## Minimum closure (one line, owned test file only)
Annotate the literal so the index signature is kept, e.g.
```ts
const example: Record<string, unknown> = { ...exampleOf(successSchema('/api/extension/pair/current')), status: 'bound' };
```
(`decodePairCurrentResponse(raw: unknown)` accepts it unchanged.) No other tsc errors were reported
(tsc reports all diagnostics in one pass), so this is the complete tsc closure.

## Masked-assertion scan (UX-03a lesson)
tsc blocks the whole Jest run, so nothing in Jest has been observed. Static re-read of the same test
body finds no further type issue after the fix; the sibling test above it (`decodes a schema-derived
example for every enum member`) already casts via `as unknown as PairCurrentResponse` and is fine.

## Awaiting parent
Authorise the one-line closure (re-freeze: new write-tree + patch sha recorded), then re-run step 5
from gate 1 under the slot. Not self-accepted.
