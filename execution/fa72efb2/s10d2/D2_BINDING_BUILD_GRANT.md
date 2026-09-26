# S10-D D2 real-PG proof binding build grant (EXEC-FA72EFB2)

Grade T3 (proof-bearing runner; derived by substitution from an accepted runner). Requested route: Claude Opus 5.5.
Source only: do NOT run the runner, PG, initdb, bootstrap or jest; do not take the lock.

Template (accepted, ran RC=0 32/32): execution/d3a9f701/s10c/binding/v6/{s10c-pg-proof.sh, s10c-fixture.sh or the
fixture it names} — it runs specs on the S10-B harness (g2-s10b-*) in its own lane. Derive
execution/fa72efb2/s10d2/binding/v1/{d2-pg-proof.sh, d2-fixture.sh, DELTA-from-s10c-v6.diff, DELTA-fixture.diff,
README.md} with the MINIMUM substitutions:
- runtime: RUNTIME_ROOT=/home/user/workspace/execution/fa72efb2/runtime (PG dist + PROVENANCE there), lock
  /home/user/workspace/execution/test-validation.lock EXPECT_LOCK_INODE=686480, psql /usr/lib/postgresql/18/bin/psql,
  node/psql/PG shas from execution/fa72efb2/runtime/raw/rt-setup.log; donor node_modules =
  /home/user/workspace/worktrees/fa72-s11a1/node_modules (hidden lock 05bc530a…, client 2c819c8a…/aca7a558…, prisma
  6.19.3; generated from the same S10-B schema as the D2 base, so donor client == expected clone client — if the
  template has a "differs from donor" guard, invert it and say so).
- evidence dir D=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s10d2/binding/v1; fresh clone
  W=/home/user/workspace/worktrees/fa72-d2-pg1; clone source SRC=/home/user/workspace/worktrees/fa72-d2.
- candidate: BASE_HEAD=6a33df9b2ea1fd246663a2287b92830f0d093abe (tree 454fd501b9353bac11a083036aa5340da354e37c);
  EXPECT_HEAD/TREE = the D2 gate commit on branch fa72/d2 (the gate worker is producing it now; leave those two and the
  blob pins for the 8 D2 paths as __FILL_*__ placeholders that the runner refuses to start with, and list them in the
  README fill table); EXPECT_DELTA = exactly the 8 D2 paths (sorted); no migration (migrations tree 7b6fe0ed…, 173).
  No LAND_REF check unless the parent pushes a land ref (make it a __FILL__ too: refs/remotes/origin/land/s10d2).
- lane: keep the template's S10-B harness identity literals; choose lane directory clusters/s10d2 + run/s10d2 and a
  port that the S10-B guard (test/utils/g2-s10b-db.ts REFUSED_PORTS) does not refuse — the template's 55649 is fine
  (no other lane exists in this runtime); keep the template's refusal of other lane ports.
- command: bootstrap exactly as the template (S10-B bootstrap), then ONLY
  `./node_modules/.bin/jest -c jest.config.js --runInBand --ci --runTestsByPath test/scout/s10/s10-unseen.pg.spec.ts`
  once; the expected count = number of it( cases in that spec at HEAD (compute and state; no skip/only/todo/each
  allowed except the file-level describe.skip env switch, which must be the pinned live form). Keep teardown, receipts,
  one-shot STARTED/sentinel, pre-lock refusals, pipefail rules exactly as the template.
Read-only helpers you may use: git in /home/user/workspace/worktrees/fa72-d2 and fa72-s11a1, sha256sum, bash -n.
Rules: execution/fa72efb2/WORKER_RULES.md. Report: execution/fa72efb2/s10d2/binding/v1/README.md (what changed and
why, fill table, expected counts, open risks) and return a summary.
