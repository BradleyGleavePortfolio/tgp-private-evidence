# S8-C replacement — source-gate receipt (S8C_SOURCE_GATES_GRANT, relay 2026-09-25 04:31Z)

## Result

- **Head** `527fe2bc24f954b26c0485c90345f237ce39a09d`, **tree** `d87a96267c2ec4f4d79d83d26e6b2928a56c8a85`, parent = base `93389265a846095b846fa8f1fb0dad782fb6ee9f` (base tree `a315dd65…`). Branch `exec64/s8c-replacement`, worktree `/home/user/workspace/worktrees/64e33dc7-s8c`, porcelain 0 after commit.
- Author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`; message has no trailers (`gates/commit-message.txt`). Genuine lefthook pre-commit ran fully and passed: prod-readiness-quick, banned-cast-tokens (R75), prettier, eslint, tsc (48 s at heap 4096); commit-msg hook ran. Raw: `gates/run/commit.raw.log`. No `--no-verify` at any point.
- **Lock**: every heavy step ran inside a driver holding `execution/test-validation.lock` via `flock -n` on fd 9 (inode 691716), released at each driver exit; never deleted. Final release 04:52:24Z (`gates/run/s8c-gates-resume.log`). No PG, initdb, bootstrap, migration, rls Jest, push or production action.
- `prisma/` tree and `src/scout/reconstruct/sources/` tree byte-identical to base (`checkpoints/v3/HEAD.txt`). `schema.prisma` blob `32e44110…` unchanged.

## Runtime used (per RUNTIME_SETUP_RECEIPT / FORMATTER_TOOLING_RECEIPT)

- Donor `cp -a /home/user/workspace/worktrees/64e33dc7-env/node_modules → worktree/node_modules` (649 entries, 717M, no top-level symlinks); `.package-lock.json` `05bc530a…`, `package-lock.json` `b7fed5ed…`, generated client `index.d.ts` `b6716a86…` — all verified; donor not mutated; no generate.
- Prettier prefix `cp -a` → `/home/user/workspace/execution/64e33dc7/recovery-reset/s8c/tools/prettier-3.9.9`; 56/56 manifest files OK, `bin/prettier → ../lib/node_modules/prettier/bin/prettier.cjs`, launcher `6e922134…`; `npx --no-install prettier --version` = 3.9.9 inside the worktree with `npm_config_prefix`/`npm_config_offline` (unset after commit). No dependency/hook/workflow/platform edits, no downloads.

## Narrow generator transfer (executed once, attempt 1; later attempts re-ran the unchanged script idempotently before the parent's "no replay" note — same hash both times)

`npm run -s contract:importer` (unchanged accepted script) in the S8-C worktree: `docs/contracts/importer-openapi.json` `68dfd959…` → `727eb523…` (blob `493234f1…`), 6 changed lines, exactly two `"programs"` additions: `ScoutReconstructDto.entity_type` enum and the entities `family` query enum — matching the expected semantic delta. No manual JSON, script, version or contract-spec edit. Delta: `checkpoints/v3/contract-delta.patch`. `test/contracts/importer-contract.spec.ts` PASS against the generated artifact. S7-L's lifecycle artifact is a separate candidate; composition must regenerate from combined DTOs under a parent grant.

## Gate history (all raw failures preserved under `gates/run/attempt-*/`; `gates/run/RECEIPTS.sha256` covers 58 files)

| attempt | driver | outcome | in-scope remediation |
|---|---|---|---|
| 1 | `s8c-source-slot.sh` | donor copy, prefix, prettier --write 22 owned files, regen OK; **R75 FAIL** (`as unknown as` +5, `as never` +2 in new native files) | replaced all 7 casts: typed `Prisma.InputJsonObject` mapper return, dropped redundant `InputJsonValue` casts, `payload: Prisma.JsonValue` in spec helpers, intersection assertions, `Object.assign` for the test registry injection |
| 2 | rerun | R75 OK; **tsc FAIL** TS2352 on `this as FakeNativeTx & TransactionClient` (polymorphic `this`) | assert from a concrete `FakeNativeTx` value |
| 3 | rerun | tsc OK; **eslint FAIL** `no-this-alias` | helper `asTransactionClient(fake: FakeNativeTx)` |
| 4 | rerun | R75/tsc/eslint OK; **Jest affected 7 suites / 9 tests FAIL** (26 suites, 472 pass) | see below |
| 5 | `s8c-gates-resume.sh` (changed bytes + 15 affected suites only) | 13 pass; **native-rules.spec FAIL** (owned expectation `7:` vs correct length prefix `8:`); mapping-spec.spec FAIL (unowned, below) | fixed owned expectation |
| 6 | resume (2 suites) | native-rules PASS; mapping-spec.spec known FAIL preserved; **hook tsc OOM** at default heap after R75/prettier/eslint passed | none — heap 4096 exported for the hook per grant |
| 7 | resume commit-only (staged tree verified unchanged `d87a9626…`) | **commit rc 0**, hooks all ✔ | — |

Attempt-4 Jest failures and closure (all in the native adapter or owned specs; no accepted assertion weakened, no accepted source mapping changed):
- `mapping-spec.equivalence`, `source-mapper-registry`, `conformance-alpha.mapper`, `mapping-spec.third-source` (shape): the native `workouts.map()` had wrapped the accepted value as `{mode:'evidence', entity, recordNoNativePrincipal:false}`. Closed in `native-families.ts`: when the source declares no native workout rules, `map()` returns the bare accepted `MappedEntity` (byte-identical to the legacy family); only sources declaring native rules see a `mode`-tagged disposition; `persist` discriminates with `isTagged`. Owned spec updated to the bare shape.
- `mapping-spec.third-source` ("no src TypeScript mentions the new source"): a doc comment in `native-families.ts` named `conformance_alpha`/`conformance_beta`; reworded generically.
- `native-families.spec` registry case: legacy `client_history` uses the repository mapper registry (injection seam covers native families only) — owned spec now maps an accepted-source row; seam documented in `families.ts`.
- `native-rules.spec`: owned fixture used `groupKey.kind: text` where the grammar allows `identifier` only; fixture corrected. Owned length-prefix expectation corrected (`8:` for an 8-char parent id).
- After closure: 15 affected suites → 14 pass (293/295 tests, then 51/52 on the final two-suite rerun); the single remaining failure is the unowned item below.

## Unowned expectation amendment needed (B — decision blocked; reported, not changed)

`test/scout/reconstruct/mapping-spec.spec.ts` lines 266–268 (inside `repository specs — the live sources › TrueCoach notes … explicitly unresolved`):
```ts
for (const family of Object.values(RECONSTRUCT_FAMILY)) {
  expect(resolveStagedFamily(registry, 'truecoach', family)).toEqual({ ok: true, family });
}
```
Reason: the grant requires `programs` in the canonical DTO family list, and the accepted `truecoach.json` (unchanged, blob tree `a1a296ee…`) declares only `clients`, `workouts`, `client_history`. The loop encodes the old assumption "every canonical family is resolvable for TrueCoach"; with `programs` canonical, `resolveStagedFamily(registry,'truecoach','programs')` correctly returns `{ ok:false, reason:'unresolved_family:programs' }` (fail-closed, as the guard is designed). Minimal candidate amendments for the owner: iterate the families the TrueCoach spec declares (e.g. `Object.keys(spec.families)`), or assert `programs` is explicitly unresolved for TrueCoach alongside `notes`. I did not touch the file; no accepted source mapping was changed to claim `programs` support. This failure is preserved in `gates/run/attempt-5-resume1/jest-resume.log` and `gates/run/jest-resume.log`.

## Exports and binding

- `checkpoints/v3/`: `s8c-527fe2bc.bundle` (verified OK; head ref `refs/heads/exec64/s8c-replacement`; prerequisite = accepted base `93389265` present in the shared repo), `HEAD.patch`, `HEAD.txt` (base/head/tree, identities, blob ids, prisma/sources unchanged), `CHANGED_PATHS.txt` (25 paths: 3 M src + 1 M artifact + 21 A), `contract-delta.patch`, `MANIFEST.sha256`. Earlier exports untouched.
- Binding filled from the committed clean head by `binding/fill-pins.sh` (rc 0, log `binding/fill-pins.log`): all nine tool pins re-verified OK, no mismatch; head/tree/six blob pins + fixture sha filled. `binding/BINDING.sha256`: filled runner `66a838ab…`, template `s8c-pg-proof.sh.unfilled` `377c3922…`, diff `d5b88181…`, fixture `1a7faa5f…`, PINS `b9df2be5…`. Nothing executed.

## Carried C items
Generator re-ran idempotently in attempts 2–4 before the "no replay" instruction (same output hash; recorded). Earlier C items from DRAFT_READY stand. `test/utils/g2-s8c-*` files are committed but unproven until the separate one-run PG grant.

Status: heavy slot released 04:52:24Z; idle. Ready for two independent non-builder reviews of head `527fe2bc` + filled binding; PG only under a separate exact grant.
