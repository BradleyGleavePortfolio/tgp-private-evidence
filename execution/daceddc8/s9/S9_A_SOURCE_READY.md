# S9-A — SOURCE_READY (pure reconciler; source only, no gates run)

- Builder: `s9_a_reconciler` (T4, grant S9-A-1). Written 2026-09-25 17:39Z.
- Worktree: `/home/user/workspace/worktrees/daceddc8-s9a`, branch `exec-dace/s9-a`, HEAD
  `df713fd9217df524915348ef8a42c797f288dde1` (S7-L landed). `git status --short` shows exactly
  two untracked directories (`src/scout/reconciliation/`, `test/scout/reconciliation/`); no tracked
  file touched.
- Frozen to S9-0 at sha256 `cda68d826be08e5bf5cd1152ecbb092b10dfc373c7234bd73943815d0d07bab1`
  (`/home/user/workspace/worktrees/64e33dc7-s7l/docs/decisions/2026-09-25-s9-reconciliation.md`,
  verified by `sha256sum` at write time). Parent mail 10:29 (R-A1, R-B1, class C) and 10:36 (GO)
  both honoured.
- NOT done, by instruction: no lock taken, no `node_modules` copy, no prettier/eslint/tsc/jest, no
  `git add`/commit, no evidence-repo commit. The four files are therefore **unformatted and
  untype-checked**; the spec's long `it.each` rows exceed 100 columns and will be rewrapped by
  `prettier --write` in the gate phase (the hook runs `--check`).

## Files and sha256 (pre-prettier)

| Path (under worktree) | sha256 | lines |
| --- | --- | --- |
| `src/scout/reconciliation/types.ts` | `eff1479cd2b735aacadc42ee3e2280dcfaf2e4fcc27a1fb90fd2c2bf2db1dbfa` | 386 |
| `src/scout/reconciliation/coverage.ts` | `c6b224fa860261d6240c5bd62b07d419c6b9346c0b0de4eaac64dd9215926701` | 77 |
| `src/scout/reconciliation/reconcile.ts` | `83d7673b024513bbee938bf4a5467c4faa9306739f15ae53b69722936d7d9e1f` | 428 |
| `test/scout/reconciliation/reconcile.spec.ts` | `99068057b0b99d95c9601c02130e4eca2b3b07acd0e0088fae146cb2f54edb74` | 1236 |

Hashes will change after `prettier --write`; the gate log must record post-format hashes.

**Delta 2026-09-25 17:58Z (review `S9_A_REVIEW_A.md` B-1, closure (a), parent-mandated):**

- `reconcile.ts` `closeRelationships`: the bucket-j map is now a **union per family name**
  (`prev === undefined ? o.verified : new Set([...prev, ...o.verified])`) instead of last-writer
  overwrite, so two type-valid `mapped:true` entries sharing a `family` can no longer hide the first
  entry's bucket-j identities from an edge (previous sha `efb8f799…` → `83d7673b…`, +8 lines, one
  hunk at the top of `closeRelationships`; nothing else changed).
- `reconcile.spec.ts`: one new verdict-table row "R06 two mapped entries sharing a family name: a
  failing edge from the first is still counted → partial / relationship_unverified (review B-1)"
  (two `workouts` entries under different tokens, one `programs`, one `program_parent` edge from the
  first `workouts` identity with `consistent:false`, coverage known for all, claim `success`;
  asserts `conditions === ['relationship_unverified']` and `relationship_unverified === 1` on both
  `workouts` rows). Previous sha `5b015fae…` → `99068057…`; verdict table now 45 rows.
- B-2 carried to the S9-B grant (no S9-A change). Review C-2 (`filter(mapped)` for the synthesised
  `staged` set) deliberately not applied: parent said keep everything else; the union already removes
  the spurious `unverified` half of C-2, and the verdict was already correct.

## Design (as built)

**Imports.** `types.ts` imports only types from `../lifecycle/arbiter` (`ArbiterInput`,
`ReconciliationVerdict`) and `../lifecycle/reason-codes` (`RunReasonCode`, `ServerTerminalStatus`),
as D-S9-8 lists. The claim type is derived as `ClaimStatus = ArbiterInput['claim']` so no DTO is
imported. Nothing from `native/**` or the S8-C candidate is imported; the §3.7 grammar is a local
copy (`UNRESOLVED_CATALOGUE`, review C-9 drift note applies).

**Reason codes (D-S9-7).** `S9_REASON_CODE` is the single spelling site:
`unresolved_family | unresolved_identities | relationship_unverified | coverage_basis_unknown`;
`S9_REASON_CODES` is the D-S9-2 order. `ReconciliationVerdictV1 = {outcome: 'complete'|'partial';
reason_code: S9ReasonCode|null}`. S9-C's append proves `S9ReasonCode ⊆ RunReasonCode`; the spec
narrows through `isRunReasonCode` today so it does not flip when the enum grows.

**Facts (input, S9-B collects).** `ReconciliationFacts {claim, families, relationships,
spec_families: string[]|null, ledger_without_staged (run-wide), coverage|null}`. `FamilyFacts
{family, mapped, resolution_reason, client_owned, ceiling_exceeded, identities, ledger_without_staged
(attributed), qualifiers}`. `IdentityFacts {token, identity (opaque, never reported), ledger|null,
client_linked}`. `LedgerRowFacts` is a discriminated union `failed | skipped{reason} |
reconstructed{target_kind, provenance|null}`; `ProvenanceFacts {outcome, native, reason,
unresolved_children}`. `CoverageFact = {known:false} | {known:true; basis_kind; observed_unique;
covers_staged_identities}`.

**Classification (D-S9-2 a–k, first match wins).** `classifyIdentity` → `{bucket, code}`:
(a) unmapped → `unsupported_platform:<p>` rejected / `unresolved_family:<token>` unresolved;
(b) no ledger row → `pass_ceiling_exceeded` when `ceiling_exceeded` else `not_reconstructed`;
(c) `failed` → bucket failed, key `failed`; (d/e) `skipped` → `parseLedgerReason` (rejection keys
verbatim; §3.7 keys verbatim only when they parse in the catalogue with the right bare/qualified
shape and a `[A-Za-z0-9_.-]{1,64}` qualifier; else `unresolved:reason_unrecognised`); (f) evidence
row keyed **per row**: `no_native_client_principal` when `client_owned || client_linked ||
provenance.reason === that code`, else `evidence_only`; (g) native kind with no provenance or
provenance `unresolved` → `provenance_missing`; (h) `foreign_owner|kind_mismatch|provenance_mismatch`
→ `identity_conflict`; (i) `removed` → `native_target_removed`; (j) `present_owned` → verified;
(k) `switch` defaults on unknown `status`/`native` → `reason_unrecognised` (partition total without
DB CHECKs; spec drives it with `JSON.parse` data, no cast tokens).

**Per family.** Token sub-reports (`tokens[]`, sorted), `reasons`/`child_reasons` histograms sorted
by code point, `unresolved_children` from bucket-j parents only, partition invariant
`staged_unique = j + rejected + unresolved + failed` per entry and per token. Families sorted
(`mapped` desc, `family`). A required family with no staged entry is synthesised as a zero-row mapped
entry (D-S9-2 "gets a report entry with `staged_unique: 0`").

**Relationships.** Only edges whose `from_identity` is bucket j are checked; an edge passes iff the
target is bucket j in `to_family` and `consistent === true`, or `consistent === null` for
`client_link` only (E-R3 has no native attribute; E-R1/E-R2 must be compared, never assumed).
`relationship_unverified` counts identities (not edges). `relationship_closure`: `unverified` if any
fail, `verified` if at least one bucket-j edge was checked and none failed, else `not_applicable`.

**Conditions (`conditions()`, all evaluated, D-S9-2 order; `reason_code` = first; complete iff
empty).** C-FAM: any unmapped entry or any mapped family whose histogram has a key starting
`unresolved:no_native_destination:`. C-ID: run-wide `ledger_without_staged > 0` or any mapped
family with `unresolved+rejected+failed > 0`, `unresolved_children > 0` or attributed
`ledger_without_staged > 0`. C-REL: any `relationship_unverified > 0`. C-COV:
`coverageConditionHolds`.

**Coverage (`coverage.ts`, R-A1).** `requiredFamilies(facts)` = mapped staged families ∪ coverage
keys ∪ `spec_families`, sorted; `null` when total staged identities = 0 or `spec_families === null`.
C-COV holds when required is `null` or empty, or any required family lacks
`familyCoverage(...).known`, which needs `known:true && covers_staged_identities && claim==='success'`.
Report row: `completeness_basis = known ? basis_kind : 'none'`, `observed_unique = number | null`.
The report also carries `required_families` and run-wide `ledger_without_staged`.

**F2.** `CREATED_NATIVE_SPLIT: null` fills `created_native`/`already_present_verified`.

**Determinism.** Code-point comparators (no `localeCompare`), no `Date`, no mutation of input (the
spec asserts byte identity across permuted input and a no-mutation snapshot).

## Spec coverage (45 verdict-table rows + 21 unit `it`s, all pure)

R01a/b/c/d, R02, R02b, R03, R03b, R04 (removed; foreign_owner/kind_mismatch/provenance_mismatch),
R05 (equal counts, different sets; attributed-only), R06 (E-R1 false/null/parent-unresolved, E-R2,
E-R3 bucket-f not counted twice, E-R3 target not j, two failing edges count once, full closure →
complete), R07 (client-owned family; per-row client link in a coach-owned family), R08 (10 250-row
ceiling → partial, never blocked), R09 (arbiter steps 1–3 with the S9 verdict, `revoked → blocked`
from the fence only), R10 (byte identity, permutation, replay `already_present`), R12 (zero-row
family beside a staged one → complete with 0s), R14 (closed enum, catalogue check on every key,
sentinel identity never in report JSON, `failed` never echoes), R17 (all four conditions; C-ID+C-COV;
C-REL+C-COV), R18, R18b (`{}`; and spec+basis with zero rows), R19 (children under `already_present`
parent, `child_reasons`), R-A1 spec-undeterminable with staged rows, C-2 run-wide
`ledger_without_staged`, catch-all k, `parseLedgerReason` table (16 rows + catalogue round-trip),
`edgeVerified` table (12 rows), `requiredFamilies` table, `familyCoverage` table (7 rows),
never `blocked|failed|cancelled|timed_out`, `complete` only with non-null coverage and claim
`success`.

## Deviations from / proposed amendments to the frozen S9-0 text (record for the reviewer)

1. `family`/`spec_families` are typed `string`, not `CanonicalFamily`: `RECONSTRUCT_FAMILY` at
   df713fd9 is `clients|workouts|client_history` (no `programs`), yet R06/E-R1 needs `programs`.
   Widening to `string` keeps the reconciler total over tokens; S9-B narrows at collection.
2. `CoverageFact.known:true` carries `basis_kind: string`, and `completeness_basis` is `string`
   (`'none'` ⇔ not known, else the basis kind). D-S9-3 says the enum is `['none']` in v1 with
   `none ⇔ known:false`; a `known:true` row cannot then report `none` without contradicting the
   equivalence, so the kind must come from the fact. v1 behaviour is unchanged (S9-B passes `null`).
3. `observed_unique` is reported as a number whenever a `CoverageFact` carries one (even when the
   basis does not vouch or the claim is not `success`), `null` when there is no fact. D-S9-3
   "stays null until an observation contract exists" holds in v1 because coverage is `null`.
4. `provenance.outcome === 'unresolved'` on a native-kind ledger row is bucket g
   (`provenance_missing`), and `provenance_mismatch` is folded into bucket h. Both are in the doc's
   spirit; the doc does not name the `unresolved`-provenance case for native kinds.
5. Relationship edges from identities outside bucket j are ignored (not double-counted), and
   `not_applicable` is emitted when no bucket-j identity in the family had an edge, not only when
   "the contract declares no edge". Verdict is unaffected (the identity is already unresolved).
6. `ProvenanceFacts.reason` and `IdentityFacts.client_linked` are new fact fields (class C-4) that
   S9-B must supply; `ReconciliationReportV1.required_families` and `.ledger_without_staged` are
   new report fields not in the D-S9-5 sketch (additive; S9-C may omit them from the DTO).
7. R-B1: report fields are always present inside `ReconciliationReportV1`; optionality is a DTO
   property (S9-C). No S9-A type is optional.

## Base move (parent mail 10:59Z; supersedes steps 1–2 below where they differ)

- Landing chain: S8-C composition (2542af44 + one test-only fix, FF to `integration/importer`) →
  S9-0 doc commit (= head **H**) → S9-A commit. S9-A lands by fast-forward, no recomposition.
- On relay of H: `git -C /home/user/workspace/worktrees/daceddc8-s9a switch -c exec-dace/s9-a2 H`
  carrying the four untracked files unchanged (verify the four sha256s above after the switch).
- `node_modules` donor becomes `/home/user/workspace/worktrees/daceddc8-land-s8-c/node_modules`
  (composed schema's prisma client; the s7l donor would mismatch S8-C models). Still `cp -a`,
  still under the canonical slot (`flock -n`, yield if busy).
- Then the gate list (prettier prefix → scoped prettier → eslint → tsc → jest → one genuine hooked
  Bradley commit). **Do not push.**
- Step 1's HEAD precondition becomes `HEAD == H`; step 6's tsc runs against the composed tree, so
  an S8-C type mismatch (not S9-A's) is recorded, not fixed here.

## Gate list (to run only after the parent relays the slot; none run yet)

All under `W=/home/user/workspace/worktrees/daceddc8-s9a`, one process holding the canonical lock
`/home/user/workspace/execution/test-validation.lock` via `exec 9>>"$LOCK"; flock -n 9 || exit 75`
(never delete/steal; refuse a live holder; lock file preserved). Exports as in the S7-L gate:
`NODE_OPTIONS=--max-old-space-size=4096 npm_config_offline=true npm_config_update_notifier=false
npm_config_fund=false npm_config_audit=false PRISMA_HIDE_UPDATE_MESSAGE=1`, and
`GIT_AUTHOR_NAME="Bradley Gleave" GIT_AUTHOR_EMAIL=bradley@bradleytgpcoaching.com
GIT_COMMITTER_NAME="Bradley Gleave" GIT_COMMITTER_EMAIL=bradley@bradleytgpcoaching.com`.

1. Preconditions: `git -C $W rev-parse HEAD` = `df713fd9…`; `git status --short` = exactly the two
   untracked dirs; `[ ! -e $W/node_modules ]`; lock file `05bc530a…` hidden-lock check per SCOPE.
2. `cp -a /home/user/workspace/worktrees/64e33dc7-s7l/node_modules $W/node_modules` (donor: 649
   entries; has `.bin/{tsc,jest,eslint}`, no prettier). Record entry count and `.bin` listing.
3. Prettier prefix: `B=/home/user/workspace/execution/64e33dc7/recovery-reset/s7l/tools/prettier-3.9.9`;
   `(cd $B && sha256sum -c /home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256)`;
   `readlink $B/bin/prettier` = `../lib/node_modules/prettier/bin/prettier.cjs`;
   `export npm_config_prefix=$B`; `npx --no-install prettier --version` = 3.9.9;
   `[ ! -e $W/node_modules/.bin/prettier ]`.
4. Scoped format on exactly the 4 files: `npx --no-install prettier --check $FILES` → on warn,
   `--write` the listed files → `--check` again must be rc 0. Record post-format sha256s.
5. `npx --no-install eslint --no-warn-ignored --max-warnings 0 $FILES`.
6. `npx tsc --noEmit` (whole repo, heap 4096; test/ is type-checked because tsconfig has no
   `include`). Any error in the four files is fixed in source and the gate re-entered from step 4;
   failures are preserved in the log, never looped silently.
7. `./node_modules/.bin/jest --ci test/scout/reconciliation/reconcile.spec.ts` (ts-jest, roots
   include `<rootDir>/test`, `\.spec\.ts$`).
8. `git add src/scout/reconciliation test/scout/reconciliation`; `node scripts/check-r75.js
   --mode=staged` runs inside the hook; one genuine hooked commit `git commit -F <msgfile>` with
   lefthook pre-commit (R75, tsc, eslint, prettier --check, prod-readiness-quick) and commit-msg
   (no identity tokens). Suggested subject: `scout: add pure S9 reconciler (verdict, coverage
   predicate, report v1) with table-driven spec`. No amend, no bypass, no force push.
9. Unset `npm_config_prefix`; release fd 9 at exit; record HEAD, `git log -1 --format=%an <%ae>`,
   and post-commit sha256s in the gate log.

## Safety-ROI findings (A/B, source-phase)

- **A. Vacuous `complete` closed at the predicate, not the caller.** `requiredFamilies` returns
  `null` for zero staged identities regardless of `coverage` (`null`, `{}` or populated) and for
  `spec_families === null`, so R18/R18b hold even if S10 later returns `{}`; the only way to
  `complete` is a non-empty, determinable required set with a known basis on every member and
  claim `success`. Cost: one extra fact (`spec_families`) for S9-B to collect from the mapping spec.
- **A. `complete` is unreachable in v1 by construction** (S9-B passes `coverage: null`); the
  `known:true` branch is exercised only in the spec. Rollback of S9-A carries no behavioural risk
  to any run terminal because nothing calls it until S9-C.
- **B. Client-link keying moves a fact to S9-B.** `client_linked` must be read through the S8-A
  interpreter (S8-DOC L320-323) by the facts service; if S9-B passes `false` uniformly, the
  histogram under-reports `no_native_client_principal` for coach-owned families but the verdict is
  unchanged (bucket f is unresolved either way).
- **B. Catalogue drift (review C-9).** `UNRESOLVED_CATALOGUE` is a local copy of §3.7 plus the
  S8-C candidate list; an unknown code degrades to `reason_unrecognised` (safe). Recommend the
  S9-C spec asserting equality with the landed `UNRESOLVED_CODE`.
- **B. Ceiling handling is per-family, not per-row.** Bucket b keys `pass_ceiling_exceeded` for
  every ledger-less identity in a family marked `ceiling_exceeded`, including any that were
  ledger-less for other reasons. Safe direction (still unresolved), histogram-only imprecision.
- **Toolchain note.** Node in this sandbox is v20.20.1 (no `--experimental-strip-types`), so no
  syntax pre-check was possible without the gated toolchain; the four files were reviewed by eye
  for strict-TS correctness. Residual risk of a tsc/eslint finding in the gate phase is real and is
  handled by step 6's fix-and-re-enter rule.
