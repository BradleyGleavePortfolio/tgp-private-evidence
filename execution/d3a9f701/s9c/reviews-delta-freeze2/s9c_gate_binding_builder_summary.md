# S9-C gate + PG-proof binding builder — summary (written only; nothing run except bash -n / read-only dry checks)

## Files (sha256)
Gate `/home/user/workspace/private-evidence/execution/d3a9f701/s9c/gate/`
- s9c-gate-d3a9.sh  a0f9e69188a222a58a2b7e6dbb4506c533a598eb05bf6d48a9c9371d73500bca
- PINS.env          18e8df4d2900ff776d98c5055460a44febbbb25f5f94dc1a04ae758897baa4a6
- commit-message.txt 93329bbb49b36a7a5da6f57911ebeebd4e474989371a0817c562ebffa7a999f5
- README.md         758be2cb5c89ae9ca5ea621114d043896ba2b8d7d828a4a9d11e675931c3c806

Binding `/home/user/workspace/private-evidence/execution/d3a9f701/s9c/binding/v1/`
- s9c-pg-proof.sh   ed99a115c80a7e7ada08b24797d01ee91d915769a17df98e9f8da8571ca655fb
- s9c-fixture.sh    ca1e563d9056169aacb60c8bf95d6a41d34ff0619eadc7a998972fe9d8dc1085 (= EXPECT_FIXTURE_SHA)
- DELTA-from-s9b-v3.diff 5c4ed48a0e5fb803392086742d59ce779bbf575ab37629e9f6d5a0ac8c7e477e
- README.md         4af731f7173ba90649d5082040bdac7f1b505fa255f4c6bb2b7dd680278092fd
- BINDING.sha256    185d0061102f38c62bed3ade492489d49a86d7c4dd7e9ec1b9ccdac403a28370

## Relay command
S9C_GATE_RELAY=1 S9C_BASE=5407efae319fd913e973c87f3be0d49786c4a3e0 S9C_DONOR=/home/user/workspace/worktrees/1910a060-s8f/node_modules S9C_PRETTIER_PREFIX=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 timeout -k 30 7200 bash /home/user/workspace/tgp-private-evidence/execution/d3a9f701/s9c/gate/s9c-gate-d3a9.sh

## Key deltas vs S9-B
Gate: W=d3a9-s9c-r2 / exec-d3a9/s9c-r2, BASE 5407efae; owned set is data-driven from PINS.env OWNED_PINS (`<sha> <mode> <M|N> <path>`)
+ the doc as ` M` append-only Addendum B (BASE bytes 55554 B as byte prefix, +N/-0, checked pre/post-prettier); preformat/ copies
before prettier --write, POSTFORMAT shas after; NEW contract step (`npm run -s contract:importer`, importer-openapi.json cmp-unchanged,
contract spec run); targeted jest via --runTestsByPath over 14 suites with count assertion; S9-A checks replaced by S9-B paths
tracked+clean at pinned bytes + S9-A still clean, prisma unchanged, 172 migrations + last pin matching g2-s9c-pg-harness.ts;
forbidden-delta list (prisma, package files, src/scout/reconstruct, reconciliation, scout-reconstruct.service.ts, run.controller.ts,
S9-A/S9-B files) with FORBIDDEN_EXCEPTIONS; staged mode check for every owned path; committed tree == staged tree.
Binding: see binding/v1/README.md (port 55646, g2_s9c_disposable, s9c_super, s9-c lane dirs, G2_S9C_* env only, committed-harness
literal cross-checks, accepted-path pins at 5407efae, EXPECT_RECONSTRUCT_DELTA, EXPECT_TESTS=10).

## Assumptions the parent must verify
1. r2 clone has two paths beyond freeze-1: ` M src/scout/reconstruct/native/native-rules.ts` (under forbidden src/scout/reconstruct;
   D-S9-8 not-owned) and `?? src/scout/lifecycle/reason-domains.ts`. Add them to OWNED_PINS if they're in the fix round. native-rules.ts
   also needs gate FORBIDDEN_EXCEPTIONS and binding EXPECT_RECONSTRUCT_DELTA plus a reviewer disposition. Otherwise gate refuses 78 and proof refuses 70.
2. The r2 harness now pins G2_S9C_BASE_HEAD = 5407efae (freeze-1 had 771db62a). The binding's HARNESS_BASE_HEAD = 5407efae and is checked against committed bytes.
3. Doc Addendum B isn't written in r2 yet. Fill DOC_ADDED_LINES / SHA_DOC_ADDENDUM once it is.
4. Owned sha pins, SHA_CONTRACT_JSON and binding EXPECT_HEAD/TREE/6 blobs stay `__FILL_*__`. Fill them from the post-fix freeze and then from the gate receipt.
5. The contract regen was stable at devloop-3. The gate re-requires this at the frozen bytes.
6. Lock inode 692282 (LOCK_ESTABLISHED.txt agrees). tgp-private-evidence is a symlink to private-evidence.
7. The binding was not dry-run, because it takes the lock before its checks. Only `bash -n` was run, plus a manual grep of its literal checks against the r2 files (all pass).
