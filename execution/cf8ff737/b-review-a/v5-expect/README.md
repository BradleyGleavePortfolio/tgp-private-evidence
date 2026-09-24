# Reviewer A — expected v5 identities (precomputed, read-only; not a candidate)
Derived by applying the exact granted substitution (`t.tgattr::int2[] = '{}'::int2[]` → `cardinality(t.tgattr::int2[]) = 0`)
to the HEAD 75a2863b blobs. Used only to bind the builder's v5 delta; the builder's tree is authoritative if it differs, in which
case the difference is the finding.
- src/scout/scout-ledger-backfill.ts : blob 11d0a3fed8c1937b579ace267d7d90e71a2b5623 (line 257 only; inside a template literal, prettier-neutral)
- prisma/migrations/20270119000000_scout_ledger_obsolete_writer_fence/down.sql : blob 7deaf7009ced136df6c7f06e1989060b15568dfa (line 64 only)
- all other 9 v4 paths + tracked base: unchanged from tree f4922ca0…
Semantics note: cardinality() of an int2vector cast to int2[] returns 0 for the ndim=1/dim=0 empty vector, so the new predicate is
true for the shipped column-less trigger and false for any column-list trigger — identity preserved.
Unit fake (scout-ledger-backfill.spec.ts:102) keys on 'pg_trigger' text only, so the 42-test unit gate is unaffected by the change.
