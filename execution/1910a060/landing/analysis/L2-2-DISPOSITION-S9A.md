# L2-2 disposition: S9-A (be88909f) composed onto M (62471b11)

Tier T3, nonproduction. Prepared 2026-09-25 for LAND-PREP-S9A. The analysis is source-only: no lock, no Jest, no push.

## Inputs (real bytes)
- M = `62471b116267fdec6746073c4b4c80a154d09834`, tree `23614f0b7dc33dc37b90cf4f27fcb8331912e60f`. This is the landed S8-F merge; its parents are 1c5fbb04 and e1ec2fec.
- S9-A = `be88909f4bf6a727a3bd376385aba91f209f989a`, tree `54349476c9f92296f4595bda45d64a48534c4553`, parent 1c5fbb04. It was accepted per `s9a/S9A_ACCEPTANCE.md`.
- merge-base(M, S9-A) = `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9`.
- Predicted tree T = `737c34a3b50cb823c9317d13e1b23797127338b9`:
  - `git merge-tree --write-tree` returned rc 0 in both orders.
  - `diff --raw M T` == `diff --raw 1c5fbb04 be88909f`. These are the 4 S9-A adds, byte-identical.
  - `diff --raw be88909f T` == `diff --raw 1c5fbb04 M`. These are the 17 S8-F paths.
  - No path overlaps between the two sides.
- S9-A blobs:

  | Path | Blob |
  |---|---|
  | `src/scout/reconciliation/coverage.ts` | f50d9401 |
  | `src/scout/reconciliation/reconcile.ts` | bcc85e49 |
  | `src/scout/reconciliation/types.ts` | b7599427 |
  | `test/scout/reconciliation/reconcile.spec.ts` | 11f2a524 |

  All 4 equal `git hash-object` of `s9a/gate/postformat-*.ts`.
- Side X (tip side) is `s9a-side-m-paths.txt`, 17 paths. It is identical to `side-s8f-paths.txt`. Side Y is `s9a-side-s9a-paths.txt`, 4 paths.

## Mechanical selection
`select_suites.py <T> X Y` was run on the extracted real tree T, and then again with X and Y reversed. Outputs:
- `s9a-selection-onto-M-real.txt`
- `s9a-selection-onto-M-real-reversed.txt`

Both directions select the same 41 default-config specs. That set is also identical to the earlier pre-format prediction `selection-s8f-onto-s9a-preformat.txt`.

The selector is deliberately over-inclusive: it treats any `'src'`/`'test'` string literal, or any directory read, as reading the whole root. Each hit therefore gets a manual disposition below.

## Import-closure check (both directions)
- **S9-A's module graph:** `reconcile.spec.ts` and `src/scout/reconciliation/*` import only:
  - `./coverage` and `./types`
  - `../lifecycle/arbiter` and `../lifecycle/reason-codes`
  
  `arbiter` imports only `../scout.dto`, `./reason-codes` and `@nestjs/common`. None of these files is an S8-F path, because S8-F changes `scout-entities.*` and `scout-roster.*`, not `scout.dto.ts`.
- **Reverse direction:** nothing in T imports `src/scout/reconciliation/*` outside that directory and its own spec. Matches for `'./types'` in the wearables and team-mode code are their own local modules. S9-A wires nothing into any Nest module. The importer contract generator (`importer-contract.spec`) and the S8-F entity and roster specs therefore do not see S9-A bytes.
- **Result:** the import closures of the two sides are disjoint. The only way S8-F bytes and S9-A bytes meet is through suites that read the file system.

## Manual disposition of the 41 hits

### MUST-RUN: real-repo walkers whose inputs include bytes from both sides
Each of these reads the real `src/` tree of the composed checkout. That means they read the new `src/scout/reconciliation/*.ts` together with the S8-F-changed `src/scout/scout-{entities,roster}.*`.

| Spec | Why its input set changes |
|---|---|
| `test/deploy-readiness.spec.ts` | `scanAllStubRoots(REPO_ROOT)` walks `src/` (stub scan) and runs the provider import scan. |
| `test/prod-readiness/env-discovery.spec.ts` | Contains the test "round-trips the REAL src/ tree" (`discoverEnvVars` on the repo). |
| `test/prod-readiness/operator-keys-artifact.spec.ts` | `assembleOperatorKeysInput({repoRoot: REPO_ROOT})`, which calls `scanProvidersFromProcess` (walks `src` imports), plus the drift check against `OPERATOR_KEYS_NEEDED.md`. |
| `test/route-doc-drift.spec.ts` | Walks `src` and `scripts`, reading every `.ts` file. |
| `test/scout/reconstruct/mapping-spec.third-source.spec.ts` | Walks all of `src`, reading every `.ts` file for the platform literal. |

### CONSERVATIVE ADDS: cheap, and run in the same Jest invocation
| Spec | Reason |
|---|---|
| `test/scout/reconciliation/reconcile.spec.ts` | This is S9-A's own suite. Its closure is disjoint from S8-F, but running it on the composed tree costs about a second. |
| `test/dunning-v2-lockout-allowlist-route-table.spec.ts` | Walks `src` but reads only `*.controller.ts`. S9-A adds no controller, so strictly its inputs are M's. The earlier S8-F disposition kept it, and it is kept here for continuity. |

### EXCLUDED: inputs are unchanged by the composition
The selector matched these specs only because of a `'src'`/`'test'` literal or through a helper. They read fixed named files, temp directories, or fixtures, so their input bytes are the same in M and T.

- **Fixed named files:**
  - `ai-credits-stream1` reads `src/ai-credits/*` and one named controller.
  - `cors-config` and `feature-flag-not-found.bootstrap` read `src/main.ts`.
  - `federation-inbound-constant-time` reads `federation-inbound.service.ts`.
  - `first-win.controller` reads `first-win.controller.ts`.
  - `lost-webhook-reconcile.service` reads one named service.
  - `diagnostic-prompt-doctrine` reads one prompt file.
  - `drop-coach-direct-enabled` reads `schema.prisma` and named files.
  - `voice-policy-lint-contract` reads its snapshot.
- **Temp repos, fixtures, or mocks:**
  - `test/ci/r75-boundaries`, `r75-gate`, `r75-wiring` and `r100-pathspec` use mkdtemp git repos plus fixed policy and fixture files.
  - `test/ci/delivery-artifact` runs `scripts/ci/*.sh` against mkdtemp fixtures and repos.
  - `prod-readiness/stub-scanner` uses `scanForStubs({repoRoot: tmp})`.
  - `provider-wiring-stripe-mux-sendgrid` uses `scanProvidersWith` over synthetic sets.
  - `provider-wiring-twilio-…` uses mkdtemp roots.
  - `operator-keys-generator` renders from synthetic input and uses mkdtemp.
  - `auto-flipper` mocks `execFileSync`.
  - `redactor` is pure: its "walk" is over JSON structure.
- **Named directories that neither side touches:**
  - `scout/reconstruct/mapping-spec` reads `SOURCE_SPECS_DIR` json and `src/scout/reconstruct/*.ts`.
  - `scout/reconstruct/native/native-families` reads `src/scout/reconstruct/native`.
- **PG/live helpers, which read one migration SQL file:** these are the specs that use `community-db.ts`:
  - `community-*.e2e`
  - `community-challenges-progress.live`
  - `community-rls`
  - `community-v1-emoji-roundtrip`
  - `community-schema`

  `scout-entities.rls.live` falls in the same group, reading its `MIGRATION_SQL_PATH`. Neither side changes any migration. These are also PG suites, which are out of scope.

## Changes from the pre-format prediction (L2-2-DISPOSITION.md Case B, 10 suites)
Reading the real bytes narrowed the list. These specs were dropped:
- `stub-scanner.spec`, `provider-wiring-stripe-mux-sendgrid.spec`, `provider-wiring-twilio-….spec` and `operator-keys-generator.spec` only exercise walkers against temp roots or synthetic input. The real-repo walk is covered by `deploy-readiness`, `env-discovery` and `operator-keys-artifact`.

These were added:
- `reconcile.spec.ts`, as a conservative add.

## Prior evidence
The S9-A gate (`s9a/gate/jest.raw.log`) passed 10 suites on 1c5fbb04+S9-A: 418 passed, 1 skipped. Those included `deploy-readiness` and `reconcile.spec`. What has not been observed is the must-run set against the S8-F bytes. That is exactly what compose runs once.

## Must-run list
The list is `s9a-must-run-suites.txt`, 7 files. It is identical to `SUITES` in `../land-s9a-1910.sh`. Compose runs it once, under the lock, with this command:

```
./node_modules/.bin/jest --ci --runInBand --runTestsByPath <7 files>
```

This runs after the merge is staged (tree == T) and before the hooked commit. It uses the default config, no PG, and no retry.
