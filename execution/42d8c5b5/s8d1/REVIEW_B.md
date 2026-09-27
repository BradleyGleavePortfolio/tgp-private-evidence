# S8-D1 independent T4 review — lens B (adversarial) — EXEC-42D8C5B5

**Verdict: GO** for candidate `cand/x42/s8d1`, subject to the parent-owned conditions that were already on record: the PG lanes BUILD.md lists, and the fa72efb2 B1 journey-full r3 patch (parent-owned, not re-raised here). I found no A or B findings. C items are listed below.

## Heads (verified in my own read-only clone `/tmp/revb-s8d1`)

| what | value |
|---|---|
| candidate HEAD | `68cfe342248dc61de660a570eb4e565f8bdc0128` (fetched from `/home/user/workspace/repos/backend` `refs/remotes/origin/cand/x42/s8d1`) |
| tree | `3bd29f97419b0eff3e4b43228d5384101e0fdd0d` |
| parent | `aed23289024898cceca7385d3778cd7373b7424d` (single commit; `merge-base --is-ancestor` RC 0) |
| author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` on both |
| LOC | src +202/−31 (5 files); test +1003/−130 (9 files). These match BUILD.md |
| contract | `origin/land/s8d-doc:docs/decisions/2026-09-26-s8d-person-link.md` §5.1. I read it directly this time; the predecessor review's C4 gap is closed |

## Fidelity to §5.1 and adversarial audit

- **Step 1 (provenance is the identity).** `person-writer.ts` `persistPerson` → `findProvenance(coach, row.source_platform, 'clients', raw source_id)`. A resolved row goes to `verifyProvenanceTarget`. The outcomes are:
  - wrong kind or null id → `identity_conflict`
  - missing or `Deleted` → `native_target_removed`
  - other coach → `identity_conflict`
  - otherwise `ok`, with zero writes.

  This matches the S8-C `native-writers.ts` `verifyTarget` shape, line for line.
- **Step 2 (adoption).** This is an ext-ref `findUnique` on the schema's `@@unique([coach_id, source_platform, source_person_id])`. It includes the coach, so another coach can never match. A `Deleted` match is not adopted (`native_target_removed`, nothing written). A live match gets `recordAlreadyPresent`, which creates the row or promotes the unresolved row in place. `display_name` is untouched.
- **Step 3 (create).** `person.create`, then `recordCreated` or `promoteToCreated`. The state takes the schema default `InvitePending`. No `User` write, and no email or name is used as a key. `rg 'person\.upsert|\.user\.create'` finds 0 hits in the writer and in families.
- **Step 4.** `readPersons` maps `Deleted` to `archived_at = updated_at` (non-null, since `updated_at` is `@default(now()) @updatedAt`). `checkNative` then returns `removed`, which is bucket (i).
- **Deleted replay, end to end.** The ledger precedence `updateMany` refuses to overwrite `reconstructed` with `skipped`. After a coach deletion, the ledger row therefore keeps `reconstructed/person/P`. The Deleted→removed mapping is what makes S9 honest here: bucket (i), run `partial`. There is no resurrection: a create would hit the ext-ref unique anyway, and step 2 stops before it.
- **Tenant scope.** Every key includes `coach_id`. Person RLS is service_role only (migration `20261223000200`), so a foreign row is visible to the writer and yields `identity_conflict`, not a false `removed`.
- **Concurrency (static).** Case: same identity, different transactions.
  1. The loser's `person.create` raises P2002 on the ext-ref unique.
  2. `retryContention` retries once.
  3. The retry takes step 1 (winner's provenance is committed) or step 2 (adopt).

  A P2002 that survives the retry becomes `ProvenanceConflict`, which is the existing engine behaviour. I found no deterministic double-P2002 path in this writer. Proof on real DB isolation is still parent-owned (PG lanes).
- **S9 truth.** `reconcile.ts` is unchanged. A NULL-kind historical ledger row stays bucket (f). `kind_mismatch`/`provenance_mismatch` → `identity_conflict`. `complete` is reachable only when every family is clean. The `reconcile.spec` C6 negative and positive cases cover this. `FAMILY_QUALIFIERS.clients`/`roster_bridge_pending` is still carried.
- **No silent zero.** Every non-ok path returns a typed `unresolved:*` reason.
- **NEW SOURCE → CORE DIFF = 0.** `rg 's10_unseen|s11_second' src --glob '*.ts'` finds 0 hits. There is no migration and no schema diff.
- **Roster.** `scout-roster.service.ts` already accepts `target_kind ∈ {NULL, person}`, so the typed kind does not drop rows from the roster.
- **Tests.**
  - The named §5.1 specs are all present:
    - edited name survives replay
    - Deleted → removed, no new Person
    - foreign coach → conflict
    - adopt-once → verify
    - five runs → one row
    - NULL-kind stays (f)
    - C6
  - s10-unseen (h) flips on the real roster-plus-native-clean shape. It adds provenance, InvitePending and typed-ledger counts, and leaves (a)–(g) untouched.
  - The fakes offer `findUnique/create` only. There is no upsert that could hide an overwrite.

## Findings

- **A:** none.
- **B:** none.
- **C1 — raw-id variants share one Person.** Two staged ids that differ only by whitespace (for example `" c-1 "` and `"c-1"`; ingest does not trim) both map to the same trimmed ext ref. The second one enters step 2 and adopts the Person that D1 created for the first. The result is two provenance rows pointing at one Person, and S9 counts 2 verified. This matches the pre-D1 upsert's merge semantics and is identity-correct (same source person). The gaps: the §5.1 step 2 parenthetical says "rows created before D1", and no spec pins this case. Record it; D2/merge work may revisit.
- **C2 — comment points at unlanded state.** The new `journey-induction.pg.spec.ts` header says the roster path is "pinned live by … the S11 full journey's leg B". On this candidate that stays untrue until the parent applies the r3 journey-full patch.
- **C3 — suspended Persons read as present.** `readPersons` treats `Suspended` (and every non-Deleted state) as present. This follows the contract, which only names Deleted.
- **C4 — engine fake does not roll back.** In the engine-unit fake, `$transaction` does not roll back, and P2002 is simulated with a pre-committed winner. Atomicity and isolation rest on the parent PG lanes. This is the same limit the predecessor review recorded.

## Commands / RC (all in `/tmp/revb-s8d1`, read-only; nothing committed or pushed)

| command | RC |
|---|---|
| `git clone --no-hardlinks /home/user/workspace/repos/backend /tmp/revb-s8d1`; `git remote set-url --push origin no_push://disabled` | 0 |
| `git checkout origin/cand/x42/s8d1` on the first try | 1 (a plain clone does not copy remote-tracking refs). Fixed with `git fetch <backend> refs/remotes/origin/{cand/x42/s8d1,land/s8d-doc}`, RC 0 |
| `git log/diff --stat/--numstat/--check aed23289 HEAD`, `git show origin/land/s8d-doc:<doc>`, `merge-base --is-ancestor` | 0 |
| `rg`/`sed`/`awk` reads of the writer, provenance, families, mapping-spec, engine, facts.service, reconcile, roster, schema, migrations and specs | 0, or 1 where no match was expected |
| `cp -al x42-donor/node_modules` (the sentinel said RC=0), then `flock -w 3600 …/test-validation.lock bash -c 'NODE_OPTIONS=--max-old-space-size=3072 npx jest --runInBand` over 6 suites: person-writer, facts.service, reconcile, scout-reconstruct.service, conformance-alpha, mapping-spec.third-source | 0: **6 suites, 250 tests passed** (lock acquired 18:09:40Z) |

Not run: tsc, eslint, prettier (builder gates), and any PG or `rls-g2-*` lane (parent-only).

---

## Round 2 — delta attestation (`68cfe342` → `57d160b0`)

**Verdict: GO.** No A findings and no B findings. I wrote this verdict before reading REVIEW_A.md; I have still not read it.

### Heads
| what | value |
|---|---|
| HEAD | `57d160b060083d2af18af1982e389499e49ac699`, tree `cfec4d824f298339e64746ddff4c96a4119f3568`, parent `68cfe342` |
| author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` (both) |
| pushed | `git ls-remote https://github.com/BradleyGleavePortfolio/growth-project-backend.git refs/heads/cand/x42/s8d1` → `57d160b0` (read-only ls-remote) |
| object source | fetched read-only from `/home/user/workspace/worktrees/x42-s8d1`, because `repos/backend` origin/cand/x42/s8d1 still reads `68cfe342` |
| patch fidelity | `git diff 68cfe342 57d160b0 \| sha256sum` = `82b8a70b…c125535`, which equals `round2.patch` |
| delta | 6 files, +425/−13. Production is only `person-writer.ts` and `native-provenance.ts`. No file under `prisma/` changed from `aed23289` to HEAD, so there is no migration and no schema change |

### Delta audit
- **Correctness of the claim check (the A1 closure).**
  - `findOtherClaim` filters on coach, namespace, family, `native_kind=person`, `native_id`, `outcome ≠ unresolved` and `source_id ≠ raw id`. All of these are the claimant's own key fields, so tenant scope holds: other coaches, namespaces and families never block (a spec pins this).
  - The check runs only in step 2. Step 1 (the identity's own resolved row) still verifies with no extra read.
  - Step 3 creates a new Person, which cannot yet be claimed.
  - Unresolved rows do not count as claims.
- **Lock safety and ordering.**
  - `lockPerson` is a parameterised `$queryRaw` (tagged template, no interpolation). It runs `SELECT id, coach_id, state FROM "Person" WHERE id=$1 FOR UPDATE`.
  - Table and column names match the unmapped `model Person`.
  - The lock is taken after the coach-scoped external-ref lookup and before verify and the claim check. The verify uses the locked row, not the earlier read.
  - It is the only `FOR UPDATE` on Person in `src`. Each per-row engine transaction locks at most one Person, after the gate and before the provenance and ledger writes. No other path takes Person first and then a run or ledger lock, so there is no lock cycle.
  - The engine `$transaction` passes no isolation option, and `src` sets no global `default_transaction_isolation`. It therefore runs at READ COMMITTED, where the post-lock `findFirst` is a fresh snapshot and sees the first adopter's committed claim. Under REPEATABLE READ this would not hold, but that is not the configured mode.
- **Creator vs adopter race.** This works, though not by the mechanism BUILD.md describes.
  1. Under READ COMMITTED the creator's uncommitted Person is invisible to the adopter's `findUnique`, so the adopter goes to step 3.
  2. It blocks on the external-ref unique index and gets P2002.
  3. `retryContention` retries once. The retry locates and locks the Person, finds the creator's claim, and returns `identity_conflict` (ledger `skipped`).
- **Ownership before Deleted.** The writer now returns `identity_conflict` for a foreign Deleted Person. On the external-ref path the key includes the coach, so the swap only matters for step 1. That path is only reachable with corrupt provenance.
  - The S9 `checkNative` order (removed first) is unchanged. It only matters for `reconstructed` ledger rows, and the writer never produces one here, so the two cannot disagree in the verdict.
- **No false complete.**
  - The refused alias row becomes ledger `skipped:unresolved:identity_conflict`. That is bucket unresolved, which gives C-ID and a `partial / unresolved_identities` run.
  - The s10-unseen (i) spec pins this on the PG lane: staged 3, verified 2, unresolved 1. It relies on source_id ordering (`x` < `x `).
  - Case (h) is unchanged.
- **Tests.**
  - The fake's lock model enforces only the `FOR UPDATE` statement shape. It holds the lock until the transaction ends and releases it in `finally`, and waiters loop.
  - The concurrent pair yields exactly `[ok, identity_conflict]` with one provenance row.
  - Existing call-order expectations were updated for the two new calls.
  - There is also an engine-level `'1'` / `'1 '` pass.

### Findings
- **A:** none.
- **B:** none.
- **C1:** BUILD.md says an adopter racing the creator "blocks on the uncommitted insert's row lock". It actually converges through the unique-index wait, P2002 and one retry (see above). The outcome is correct. The docs are inaccurate, and no live two-transaction PG race exists, which the builder also notes.
- **C2:** A pinned alias refusal is permanent. If a later intent stages only the padded alias and not the original id, that run stays `partial / identity_conflict` until the source fixes the id. This is honest, not a false complete.
- **C3:** Step 1 does not re-check for a pre-existing double claim, meaning two resolved rows on one Person. No such rows can exist: pre-D1 upserts wrote no provenance, and the round-1 bytes never landed.

### Commands / RC (in `/tmp/revb-s8d1`, read-only)
| command | RC |
|---|---|
| `git fetch <repos/backend> …cand/x42/s8d1` (still at 68cfe342), then `git fetch /home/user/workspace/worktrees/x42-s8d1 57d160b0…`; `git log/diff/--stat`, patch sha256, `git checkout 57d160b0` | 0 |
| `git ls-remote <preserve> refs/heads/cand/x42/s8d1` | 0 (`57d160b0`) |
| `rg` for isolation level, `FOR UPDATE`/Person writers, gate; `sed` of the engine transaction | 0 |
| `flock -w 3600 …/test-validation.lock` (acquired 19:37:56Z), `npx tsc --noEmit -p tsconfig.json` | **0** |
| same lock, `npx jest --runInBand test/scout/reconstruct/native test/scout/reconstruct/scout-reconstruct.service.spec.ts test/scout/reconciliation conformance-alpha mapping-spec.third-source` | **0**: 12 suites, 332 tests passed |

Not run: eslint, prettier, and any PG lane (s10-unseen (i) is parent-only).

---

## Round 3 — rebase onto S11-DE r2 + journey-full leg-B flip (`cand/x42/s8d1-r3` = `245940c0`)

**Verdict: GO.** No A findings and no B findings. I wrote this verdict before reading REVIEW_A.md; I have still not read it.

### Heads
| what | value |
|---|---|
| remote refs (read-only `ls-remote`) | `cand/x42/s8d1-r3` = `245940c0ece836bfab65061b56b137a37d82cc5d`; `cand/x42/s11de` = `1ee239c0…`; `cand/x42/s8d1` = `57d160b0` (unchanged) |
| chain | `1ee239c0` → `77445a0d` (tree `dcd25240`) → `f8464c2d` (tree `ae7e6961`) → `245940c0` (tree `a3a025e5`) |
| author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` on all three commits |
| objects | fetched read-only from `/home/user/workspace/worktrees/x42-s8d1` |

### Rebase fidelity
- `git diff … | git patch-id --stable`:
  - `aed23289..68cfe342` = `1ee239c0..77445a0d` = `a6a13e57baec…`
  - `68cfe342..57d160b0` = `77445a0d..f8464c2d` = `ca29cd5b1c80…`

  Both reviewed commits are byte-identical after the rebase.
- The file sets of S11-DE (`aed23289..1ee239c0`, 17 files) and D1 (`1ee239c0..f8464c2d`) do not intersect (`comm -12` is empty). `245940c0` touches only `test/scout/s11/journey-full.pg.spec.ts` (+52/−31). No `prisma/` change anywhere in the chain.

### Semantic interaction with S11-DE
- **Roster reader (`scout-roster.service.ts`).**
  - It selects ledger rows by the new family scope, which classifies source tokens through the engine's own registry (`resolveFamily`). The D1 ledger rows therefore stay under the staged token (for example `u10-members`), as before, and are found.
  - `materialize` keeps `target_kind ∈ {NULL, person}`. It reads Person with `coach_id = coachId` and `state ≠ Deleted`, so tenant scope holds and a Deleted Person never shows.
  - The A1 alias row is `skipped` with a null target, so it never materializes.
  - The roster reads only. It neither calls nor bypasses `persistPerson`.
- **Entities reader.** `effectiveKind('person')` is `null`, so it does not serve rows. Clients rows are never served as evidence, either before D1 (NULL kind with no evidence row, dropped) or after it.
- **Cursor and family scope.** These are ledger-anchored paging and are unaffected by the writer.
- **S9.** The provenance family key (`clients`) and the ledger token join are unchanged by S11-DE.

### Leg-B flip: is it true and non-vacuous?
- **Chain unchanged.** The same declare, transfer, observe and complete chain runs, with `firstRowsWithRoster = [...ROSTER_ROWS, ...first.nativeClean]`, the D2 case (h) shape. `ROSTER_ROWS.length > 0` is asserted in `beforeAll`, and `rosterIds.size === ROSTER_ROWS.length`.
- **Verdict assertions.**
  - `terminal_status 'complete'`, `reason_code null`, `conditions []`.
  - An empty condition list rules out `coverage_basis_unknown`, `unresolved_family`, `unresolved_identities` and `relationship_unverified` on every family, so all families are known.
- **Clients cell.** `staged_unique = native_present_verified = observed_unique = rosterIds.size`, `unresolved 0`, `reasons []`, `completeness_basis source_signed_enumeration`.
- **Qualifiers.** `qualifiers ['roster_bridge_pending']` is still asserted. It is descriptive, not a verdict input, and remains honest until S8-D2 retires it.
- **Roster.**
  - Step 11's roster read still asserts `accounting.staged === rosterIds.size` and that the ids are exactly the staged ones.
  - Every Person is `InvitePending`, so no User is minted.
  - J17 readiness still `not.toContain('partial'|'unresolved_identities')`.
- **Traced to code.** Fresh `COACH_B`, two distinct trimmed ids → `persistPerson` step 3 ×2 (the A1 claim check is never reached) → `person/created` provenance plus ledger `person` → `readPersons` live → bucket j.

The flip is therefore verification through Person, not a relaxed assertion. Live truth is the parent's S11 lane.

### J20
- `S11_RANGE_END = 'ce37c6eeb49be1d65ee7c38f86068bd92af824b0'` (L556). The J20 block is not in the `245940c0` diff.
- `git merge-base --is-ancestor ce37c6ee 245940c0` returns RC 0.
- The superseded J20 half of the r3 patch is correctly not applied.

### Findings
- **A:** none.
- **B:** none. The fa72efb2 B1 is closed by `245940c0`.
- **C1:** Leg-B `complete` is proven here only statically and by unit tests. The live proof is the parent's S11 `journey-full` lane (6 expected) and the S10-B lane.
- **C2:** The D1 src commits sit after `S11_RANGE_END`, so J20's per-commit slug check does not cover them. My independent `rg 's10_unseen|s11_second' src` from round 1 still holds: the src bytes are unchanged by patch-id, with 0 hits. S12+ should pin its own range, as the file says.

### Commands / RC (in `/tmp/revb-s8d1`, read-only)
| command | RC |
|---|---|
| `git fetch /home/user/workspace/worktrees/x42-s8d1 245940c0 1ee239c0`; `git log`; `git diff \| git patch-id --stable` ×4; `git diff --stat/--name-only`; `comm -12`; `merge-base --is-ancestor ce37c6ee 245940c0`; `git checkout 245940c0` | 0 |
| `git ls-remote <preserve> cand/x42/{s8d1-r3,s11de,s8d1}` | 0 |
| `rg`/`sed` of the roster, entities and family-scope readers and of journey-full (header, leg B, J20 pins) | 0 |
| `flock -w 3600 …/test-validation.lock` (queued 20:10:26Z, acquired 20:29:25Z): `npx tsc --noEmit -p tsconfig.json` | **0** |
| same lock: `npx jest --runInBand test/scout/reconstruct test/scout/reconciliation test/scout/roster test/scout/entities test/scout/s11 test/scout/s10/s10-unseen.pg.spec.ts test/utils/g2-s11-db-guard.spec.ts` | **0**: 32 suites passed, 782 passed, 47 skipped (6 PG suites skipped without a lane) |

Not run: eslint, prettier, and any PG lane (parent-only).
