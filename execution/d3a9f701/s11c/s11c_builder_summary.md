# S11-C builder summary: readiness block on the setup reads

**The candidate is uncommitted and source only.**
- No npm, jest, tsc or prisma was run. No lock or PostgreSQL was used, and nothing was committed.

**Where the work is:**
- Worktree: `/home/user/workspace/worktrees/d3a9-s11c`, branch `exec-d3a9/s11c`.
- Base: `711c1f8f8b42157bca97f2a721557be7ef006667`.
- Spec: D-S11-5 and the D-S11-8 row for S11-C in `docs/decisions/2026-09-26-s11-journey.md`, with the B3 wording.

## Files (owned paths only)

| Path | State | sha256 | Lines |
| --- | --- | --- | --- |
| `src/extension-pair/extension-pair.dto.ts` | modified | `abf5f5b7748c3db902176eaf1577a91de7033c390a0ea8aadf7fc3911f2fd435` | +37 / −0 |
| `src/extension-pair/extension-pair.service.ts` | modified | `cb30b1fe03c7c8bdfb7d0ff78d0beca943afc5a32638c6678e6e75668e5bd955` | +32 / −1 |
| `src/extension-pair/__tests__/readiness.spec.ts` | new (fix-0: +1 case) | `55e183879556d29debb20aa447f16b96a3965cef469c6d175f7a68a536dbc20d` | 190 |
| `test/contracts/importer-contract.spec.ts` | modified (fix-0; parent decision 1) | `5a3505e9f96b5e1f5f405a39c8e6139be258f2be897ccab41a22746b275db2d4` | +7 / −0 |
| `test/rls-c1-setup.spec.ts` | modified (fix-0; parent decision 2) | `308d81e2e7081f03ed3b8222fb43df3ef7eb4096e85ec53471aca97eeae82f96` | +12 / −2 |
| `test/scout/s11/readiness.pg.spec.ts` | new | `f997d0e2545e3e555cd88082671bacea414d7544226e23f01d15a419550a9318` | 186 |

- The product diff is in `/home/user/workspace/s11c_prod.diff` (sha256 `0faacd15…b305`).
- **Product lines: 69 added and 1 changed, including comments.** The cap was ≤ 120.

## Behaviour

**DTO.**
- `PairSessionResult` gains an optional `readiness?: PairReadiness`.
- `PairReadiness` has three fields:
  - `run`: `'none' | 'open' | 'terminal'` (`READINESS_RUN_STATES`).
  - `source_declared`: a boolean.
  - `declared_platforms`: a number or null.
- The descriptions carry the B3 wording:
  - `source_declared` is displayed only as "declaration received", never as source authorized,
    ready or connected;
  - the read does not verify source authorization;
  - an absent block means "not known", never "no";
  - `open` is "no terminal recorded yet; not a liveness claim";
  - terminal detail lives only on `GET /api/scout/import/status`.

**Service.**
- `readSetup` is the shared body of `session` and `current`. After the existing owner-filtered
  setup lookup (unchanged, including its 404), it calls `readReadiness(coachId, row.id)`.
- That is one `scoutImport.findFirst`:
  - where `{ coach_id, import_intent_id, mode: 'server' }`;
  - selecting `{ terminal_status, declarations: { source_platform } }`.
- It counts distinct platforms and returns counts only. No platform name, digest, challenge,
  terminal status or reason leaves the service.
- It never writes and never fences.
- If there is no run, it returns `{ run: 'none', source_declared: false, declared_platforms: null }`.
  `false` is a true fact here, because a declaration's foreign key requires a run.
- Any read failure logs a warning with no identifiers and **omits** the block, so an unknown
  stays unknown and setup recovery never fails because of readiness.
- `status`, `init` and `redeem` are unchanged.

## What the tests assert

**Unit tests, `src/extension-pair/__tests__/readiness.spec.ts`** (Prisma double; any write
surface present in the double is asserted uncalled):
1. No run gives `none/false/null`, with the exact run query (coach-scoped, `mode: 'server'`,
   selecting only `terminal_status` and `source_platform`). No `$executeRaw`, `$queryRaw`,
   `$transaction`, declaration read or write, or token mint happens.
2. An open run with no declarations gives `open/false/0`.
3. Three declaration rows over two platforms give `declared_platforms: 2`. The body contains no
   platform name, digest or challenge, and the keys are exactly the three fields.
4. A terminal run gives `terminal`, and the body never contains the terminal status.
5. `current()` carries the same block, with the unchanged owner filter on the setup row.
6. A foreign or unknown setup gets the existing 404 from both reads, and the run is never read.
7. A failed read omits the block (the key is absent) and the setup fields still answer.
8. Contract metadata:
   - the `source_declared` description contains "declaration received" and "never as source
     authorized, ready or connected";
   - `run` has the enum `none|open|terminal`;
   - `declared_platforms` is nullable;
   - `readiness` is `required: false`.

**Real-PG tests, `test/scout/s11/readiness.pg.spec.ts` (J17).**
- They use the S11-A1 harness through a lazy `require('../../utils/g2-s11-harness')` and
  `require('../../utils/g2-s11-pg-harness')` inside a `describe.skip` guard keyed on
  `G2_S11_DATABASE_URL`. No harness file is forked or edited.
- Harness sha256s as read from `worktrees/d3a9-s11a1`, untracked and under review:
  - `g2-s11-harness.ts`: `d86ae588…d514`;
  - `g2-s11-pg-harness.ts`: `5e28004c…38e6`;
  - `g2-s11-worker.cjs`: `95863467…ab64`.
- Pairing, Start, cancel, status, `pair-session` and `pair-current` are real services in worker
  processes P1/P2. Declaration rows are SQL fixtures, because A1 has no `declare` action until
  S11-A2. They satisfy the S10-B CHECKs and the one-challenge trigger, and the harness reset
  removes them through the ScoutImport cascade.
- Every readiness read is asserted to issue no INSERT, UPDATE, DELETE, MERGE or TRUNCATE (from
  the worker's query log).

The cases:
- **R1.** Paired with no Start: `pair-session` on P2 gives `none/false/null`, `pair-current` on
  P1 is identical, and no run row exists.
- **R2.** Start on P2, read on P1: `open/false/0`, and the run row is byte-identical before and
  after the read.
- **R3.** Three declaration rows over two platforms: `open/true/2` on both hosts, with no
  names, digests or challenge in either body.
- **R4.** Past the deadline, the read reports `open` and does **not** fence (`fenced_at` and
  `terminal_status` stay null). A status read on P2 then fences `timed_out`, and `pair-current`
  on P1 gives `terminal/false/0` without the string `timed_out`.
- **R5.** Cancel on P2: P1 gives `terminal/true/1` without the string `cancelled`.
- **R6.** Tenant isolation: coach B's `pair-session` on A's intent gets the uniform 404 with no
  writes. B's `pair-current` gives only B's own setup with `none/false/null` and never A's
  intent. A's run and setup rows are unchanged, and A's readiness is still `open/true/1`.

## Expected contract delta (for the generator owner; not hand-edited)

When `scripts/importer-contract.ts` regenerates after S10-C's regeneration:
- `components.schemas.PairSessionResult.properties` gains:
  `readiness: { allOf: [{ $ref: '#/components/schemas/PairReadiness' }], description: 'Advisory readiness … never "no".' }`.
  `required` is unchanged: `import_intent_id`, `status` and `chosen_platform`.
- A new `components.schemas.PairReadiness` is added:
  - `properties.run`: `{ type: string, enum: [none, open, terminal], description }`;
  - `properties.source_declared`: `{ type: boolean, description }`;
  - `properties.declared_platforms`: `{ type: number, nullable: true, description }`;
  - `required`: `[run, source_declared, declared_platforms]`.
- No path, operation, status code or security change.
  `/api/extension/pair/session` and `/current` already reference `PairSessionResult`.
- `CONTRACT_VERSION` is untouched and is the generator owner's call.

## Blockers and findings for the parent (outside owned paths; not edited)

1. **`test/contracts/importer-contract.spec.ts` L529-533 will fail after regeneration.** It
   asserts that the `PairSessionResult` property keys are exactly
   `chosen_platform|import_intent_id|status`. The generator owner needs to add `readiness` in
   the same Gen change. This file is on the Gen owner's list in the S11-C row.
2. **`test/rls-c1-setup.spec.ts` L254-258 and L271-275 (the accepted C1 real-PG proof) use exact
   `toEqual` on `current`/`session` results.**
   - On a lane that has the S7-L and S10-B tables, those results now carry
     `readiness: { run: 'none', … }` and would fail.
   - They would only pass on a C1 lane without those tables, where the read fails and the block
     is omitted.
   - This needs an owner-assigned edit (expect the block, or `toMatchObject`) before that proof
     is next run.
   - Unit specs `durable-session.spec.ts` and `durable-intent.spec.ts` stay green. Their doubles
     lack `scoutImport`, so readiness is omitted and `toEqual` ignores the absent key. A warning
     is logged.
3. **The D-S11-5 decision conflicts with an accepted C1 test title.**
   `durable-session.spec.ts` L35 is titled "reads the stored ID … without any credential or
   Start/completion state". The setup read now reads the run's state (counts only). Its
   assertions still hold, but a reviewer should confirm that D-S11-5 supersedes the C1 "setup
   only" boundary. The controller's `@ApiOperation` text "Setup only" in
   `extension-pair.controller.ts` is not owned and was left unchanged.
4. **Swallowing read failures is a design choice for review.** It keeps "unknown stays unknown"
   and never fails setup recovery. The alternative, propagating a 5xx, would break the C1 unit
   doubles above.

## Fix-0 (parent decisions 2026-09-25 22:30)

The fix-0 diff is `/home/user/workspace/s11c_fix0.diff` (sha256 `1b42cc5a…8cc2`, 88 lines). It
covers the three test files. The product files are unchanged: `abf5f5b7…` and `cb30b1fe…`, 69
lines.

- **Decision 1: `test/contracts/importer-contract.spec.ts`**, formerly L529-533.
  - The expected `PairSessionResult` property keys are now
    `chosen_platform|import_intent_id|readiness|status`.
  - It adds two assertions:
    - `readiness` is not in `required`;
    - `properties.readiness.allOf` equals `[{ $ref: '#/components/schemas/PairReadiness' }]`,
      the `@nestjs/swagger` shape for a described `$ref`, like `ledger` at `importer-openapi.json`
      L557.
  - `importer-openapi.json` is not edited. The drift spec stays red until the gate regenerates.
- **Decision 2: `test/rls-c1-setup.spec.ts`**, formerly L254 and L271.
  - Each result is now held in a variable and keeps the exact prior `toEqual` fields, plus
    `expect(result).not.toHaveProperty('readiness')`.
  - Absent is the exact expected value on this lane: its `beforeAll` builds only `User`,
    `ExtensionPairCode` and `ImportIntent` (L57-88) and no `ScoutImport`. The readiness read
    therefore fails and the block is omitted.
  - If that lane ever gains the run tables, this assertion fails loudly rather than passing
    loosely.
- **Decision 3:** no edit; accepted as class C.
- **Decision 4:** no change; omit-on-failure is accepted.
- **New unit case** in `readiness.spec.ts`, "double with NO run table: block absent, setup still
  answers". Its Prisma double has only `importIntent` and no `scoutImport` delegate. It asserts:
  - both `session` and `current` return the exact pending setup;
  - there is no `readiness` key;
  - neither read throws;
  - no mint happens.
