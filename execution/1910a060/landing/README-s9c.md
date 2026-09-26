# LAND-PREP-S9C — land-s9c-d3a9.sh (source only, NOT RUN; `bash -n` OK)

Derived from `land-s9b-d3a9.sh` (sha256 f167237e…b0) with every invariant and refusal kept. Full diff: `land-s9c-d3a9.delta.diff`.

## Fixed identities
- TIP = a4af8e330bd4d6f882f0aebd411200b76d651aba (integration/importer, PR #546); TIP_TREE = 82111726a41fb114aecc4095aaa3b6c08b6f6a64
  (read from the read-only d3a9-land-s10-0 clone; ls-remote at 03:2xZ confirmed tip a4af8e33, main 1c10e2a1).
- MB = 5407efae (S9-C sole parent). Tip side = 2 Bradley commits (ba6c740a, a4af8e33), 1 path `docs/decisions/2026-09-26-s10-induction.md`
  (hygiene pre-checked read-only: identities OK, no trailers, no banned tokens).
- Candidate: CAND_REF refs/heads/exec-d3a9/s9c-r2, CAND_NPATHS 22 (21 gate OWNED_PINS + the S9 doc).
- W = worktrees/d3a9-land-s9c, BR = land-d3a9/s9c, refs land/s9-c-accepted + land/s9-c, state compose-s9c.env / stage-s9c.env,
  run dirs run/s9c-*, scratch /tmp/land-d3a9-s9c-*.

## Deltas vs S9-B landing
- `pins_filled` guard: predict/classify/compose/stage/ff refuse 70 while any `__FILL_*__` remains; new `fill-help` mode prints commands.
- `cand_scope` (predict rc 74, compose rc 70) replaces "touches pinned files" + "docs delta": prisma/package.json/package-lock.json
  unchanged; `git diff --name-only MB H -- docs` == {importer-openapi.json, 2026-09-25-s9-reconciliation.md}; `-- src/scout/reconstruct`
  == native-rules.ts only; S9 doc has 0 deleted lines and its MB bytes are an exact prefix at H.
- Tip-side hygiene + commit count (2) checked in predict and compose, in addition to candidate hygiene.
- SUITES = 16 gate SUITES ∪ 53 S9-B landing SUITES, dedup = 59 (all exist at 5407efae except catalogue-parity.spec.ts and
  g2-s9c-db-guard.spec.ts, both S9-C owned). Parent appends any classify selector output.
- Compose checks disk headroom (node_modules size + 1 GiB) before the single `cp -a` of node_modules; nothing else large is written.
- Commit message / PR title / body texts rewritten for S9-C (banned-token grep clean); PR body notes the regenerated contract blob
  and append-only Addendum B.

## __FILL__ items (parent, after gate-2 receipt `d3a9f701/s9c/gate/HEAD-<12>.txt`)
H, H_TREE, CAND_BUNDLE, CAND_BUNDLE_SHA, CAND_RECEIPT, CAND_RECEIPT_SHA, CAND_RAW_SHA, PRED_TREE, CONTRACT_BLOB.
(CAND_REF and CAND_NPATHS=22 are already literal.)

## Commands (also printed by `bash land-s9c-d3a9.sh fill-help`; run only after gate-2 released the lock)
```
R=/home/user/workspace/worktrees/d3a9-s9c-r2; L=/home/user/workspace/tgp-private-evidence/execution/1910a060/landing
G=/home/user/workspace/tgp-private-evidence/execution/d3a9f701/s9c/gate; MB=5407efae319fd913e973c87f3be0d49786c4a3e0; TIP=a4af8e330bd4d6f882f0aebd411200b76d651aba
H=$(git -C $R rev-parse refs/heads/exec-d3a9/s9c-r2); git -C $R rev-parse "$H^@"       # only $MB
H_TREE=$(git -C $R rev-parse "$H^{tree}")
CAND_RECEIPT=$G/HEAD-${H:0:12}.txt; CAND_RECEIPT_SHA=$(sha256sum $CAND_RECEIPT | cut -c1-64); grep -c '^blob ' $CAND_RECEIPT   # 22
CAND_RAW_SHA=$(git -C $R diff --raw --no-abbrev $MB $H | sha256sum | cut -c1-64); git -C $R diff --name-only $MB $H | wc -l   # 22
CONTRACT_BLOB=$(git -C $R rev-parse "$H:docs/contracts/importer-openapi.json")
git -C $R bundle create $L/bundles/s9c-${H:0:12}.bundle $MB..refs/heads/exec-d3a9/s9c-r2 && git -C $R bundle verify $L/bundles/s9c-${H:0:12}.bundle
CAND_BUNDLE=$L/bundles/s9c-${H:0:12}.bundle; CAND_BUNDLE_SHA=$(sha256sum $CAND_BUNDLE | cut -c1-64)
SX=$(mktemp -d /tmp/land-d3a9-s9c-fill-XXXXXX)/r.git; git init -q --bare $SX
git -C $SX fetch -q --no-tags https://github.com/BradleyGleavePortfolio/growth-project-backend.git refs/heads/integration/importer:refs/remotes/origin/integration/importer
git -C $SX fetch -q --no-tags $CAND_BUNDLE refs/heads/exec-d3a9/s9c-r2:refs/heads/cand
PRED_TREE=$(git -C $SX merge-tree --write-tree $TIP $H); git -C $SX merge-tree --write-tree $H $TIP   # same tree
```
Then: `bash land-s9c-d3a9.sh predict` (read-only; expects PREDICT_OK).

## Parent to verify
- CONTRACT_BLOB must equal the receipt's `blob docs/contracts/importer-openapi.json` line (fetch_cand re-checks every receipt blob).
- Bundle is ~small (22 paths); it's the only write the fill step makes besides /tmp scratch.
- `land-s9c-d3a9.sh` is 644 like the S9-B script (invoke via `bash`). SHA256SUMS in this dir was not updated.
