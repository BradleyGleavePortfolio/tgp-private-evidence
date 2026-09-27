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
