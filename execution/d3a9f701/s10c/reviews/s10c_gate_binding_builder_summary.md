# S10-C gate + real-PG binding v1 — builder summary (SOURCE ONLY; nothing run)

Root: `/home/user/workspace/private-evidence/execution/d3a9f701/s10c/` (the scripts reference it through the `tgp-private-evidence` symlink).
Only `bash -n` was run on the new scripts. No npm, jest, tsc, postgres or prettier; no lock taken; no commit or push; the clone was only read.

## Files (sha256)
gate/ (GATE.sha256)
- `s10c-gate-d3a9.sh` 80a7568209951df5405d474aec13a8a377a37cd6133e8ebfb3052e69f9ab92f5
- `PINS.env` 4bbe5ab9e6e0488f69f18d145ae0b6154d27c009df9d357d3d369d212a517ec0
- `FROZEN.sha256` e9c71f09462a25e36baafe0fa90ba012ef6b3f384f04b3951fb1c7bbf1f4be21
- `commit-message-contract-unchanged.txt` 2ce460c5fb8224c78abf7e251be748f5b0ab92602d953c9d0e6f4cafd8642e9e
- `commit-message-contract-changed.txt` a7e117f7b4f8f6c7bc2f06d96bf2a564e1c293ae6f9709fe5b22f5a56f3776c8
- `README.md` 71c1f149c5febf36c2a59a7666ad5c774fd6836b60f8a87943546d62924ff097
- `DELTA-from-s10b.diff` 5e456c25c402a69426c00e2800925a38c2b73d774d20e13ec479de93f3123e8c
- `DELTA-PINS-from-s10b.diff` 5ded37301b83b49ae5f9fa597d397443dfd9887682fcf6a2a40264e7bb9917b2

binding/v1/ (BINDING.sha256)
- `s10c-pg-proof.sh.template` 91ea28d0d2dd6e67aca95d85562dea2523558446b97c3922c7c78ed114db6553
- `s10c-fixture.sh` c1b57239c40df1353fc98561816353dcdfd8720a318436637f1315b1cb1992e7 (pinned as EXPECT_FIXTURE_SHA)
- `README.md` 4a11714a606864b95585013775aaa4337c9ef0ce2f28efd98f841bdd6a81e865
- `DELTA-from-s10b-v1.diff` 79f1fb53fdabd12678d463383b6958fb35884af5009777434c905d48a9c17263
- `DELTA-from-s10b-v1-fixture.diff` b5f0d2c3a1acb233184ad32e6e123deb47f76dd04ee76b3c5d684f8fd2c636c6

## Key deltas vs S10-B
Details are in the READMEs and diffs.

**Gate:**
- **BASE:** `__FILL__`, taken from `--fill-help <tip>`. S10B_HEAD a2c74e90 and HARNESS_BASE a4af8e33 must be ancestors (`merge-base --is-ancestor`). There is no parent-shape pin.
- **Owned paths:** 11, including `test/rls-g2-s9c.spec.ts` per the 22:34 mail. `observation.module.ts` counts as M. `OWNED_PINS` is `__FILL__`; `--fill-help` prints the block from the working tree and flags any extra status entries.
- **Frozen S10-A/S10-B paths:** 29, pinned by blob at BASE and by bytes in the tree, and forbidden in the delta.
- **No prisma change:** empty prisma status and delta; 173 dirs; migrations tree = BASE (expected 7b6fe0ed).
- **Client:** forced in-clone `prisma generate` from the pre-S10-B donor. `POSTGEN_MATCHES_S10B` is recorded.
- **Contract (`REGEN_COMMIT_IF_CHANGED`):**
  - The export goes to scratch first. If it differs from BASE, it is copied to canonical and staged (mode/blob checked) and the "changed" message is used; otherwise the canonical file is untouched and the "unchanged" message is used.
  - The contract spec runs after that decision.
  - The receipt records `contract_state=`.
- **Jest:** targeted run of 7 suites, then the full suite.
- **it() counts:** 24 / 8, enforced pre-lock and on the committed bytes. The receipt records `it_count … total=32` and a `delta=` line for the binding.
- **Commit:** `NODE_OPTIONS=--max-old-space-size=4096 git commit`, set explicitly.

**Binding:**
- **Lane:** new lane clusters/s10-c, socket run/s10-c, port 55649. It reuses the S10-B literals (marker, DB, role).
- **Refusals:** LANE = s10-b and ports 55646/55647 (also checked for zero listeners before and after). 55649 must not be in the harness REFUSED_PORTS, and 55646 must be.
- **Retained s10-b lane:** must exist, be stopped, and be fingerprinted unchanged.
- **Fixture:** requires `S10C_RUNNER_PID` = a live `s10c-pg-proof.sh`. Start/destroy require the marker **and** `port = 55649` in its own conf.
- **HEAD checks:** HEAD^ = BASE. The delta equals the receipt, which must equal the 11 paths (+ the contract iff changed). The 29 FROZEN blobs are present at HEAD. There is no prisma, package or test/utils change since S10-B, and the package files are unchanged since a4af8e33 (bootstrap L158). `scout.module.ts` must import ObservationModule.
- **Jest run:** only `test/rls-g2-s10b.spec.ts test/rls-g2-s10c.spec.ts`, requiring `Tests: 32 passed, 32 total`, `Test Suites: 2 passed, 2 total`, and exactly the two PASS lines. The per-spec it() counts (24 / 8) are pinned at HEAD.
- **Run-once guard:** added an O_EXCL `run/STARTED` right after the flock, alongside the sentinel.

**Carried:**
- symlink-aware hook, sentinel and STARTED checks;
- all pins checked before the sentinel;
- under-lock rechecks (the gate now also re-checks FROZEN and contract bytes);
- no `| grep -q` (grep returned no matches on the new scripts);
- in-clone generate;
- NODE_OPTIONS on the commit line.

## Relay
The fill steps are in the READMEs.

Gate:
```
S10C_GATE_RELAY=1 S10C_BASE=<tip> S10C_DONOR=/home/user/workspace/worktrees/1910a060-s8f/node_modules \
S10C_PRETTIER_PREFIX=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 \
timeout -k 30 7200 bash /home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10c/gate/s10c-gate-d3a9.sh
```

Binding, after filling the template into `s10c-pg-proof.sh` from the receipt:
```
timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10c/binding/v1/s10c-pg-proof.sh
```

## Parent must verify / do
1. **Clone is behind BASE.** It is at a2c74e90 only. Fetch integration/importer (711c1f8f, or c8ee9005 if S11-A1 lands), move `exec-d3a9/s10c` onto it while keeping the 11 working-tree changes, then run `--fill-help` and paste the output.
2. **`node_modules` is present in the clone.** It is a real 717 MB directory, and the gate refuses it. Set it aside under `runtime/set-aside/`; never delete it. Disk: `/` has about 1.9 GB free, and the donor copy needs about 0.72 GB.
3. **Manifests and prisma after S10-B.** D1, S11-0 and S11-A1 must not touch prisma or package.json/package-lock.json. The harness bootstrap pins both against a4af8e33.
4. **Contract will probably stay `unchanged`.** This was read, not run. `IMPORTER_BARE_PATHS` (`scripts/importer-contract.ts` L20-36) does not list `scout/runs/declaration` or `scout/runs/observation`. If D-S10-7 wants them in the contract, that is a generator-owner edit, and `scripts/importer-contract.ts` plus `test/contracts/importer-contract.spec.ts` must be added to OWNED_PINS (allowed only if listed).
5. **S9-C spec is committed but never run.** `test/rls-g2-s9c.spec.ts` is not run by the gate or the binding, so its live proof is not re-established.
6. **Reference shas (not pins).** Measured with fix-1 in place at about 22:45: facts 756cb44b, types d7815e06, lifecycle 55c8f24a, scout.module 682bc3af, observation.module 2998b71d, lifecycle.spec 4b3ae75e, facts.spec 681e0036, coverage.spec 681c9031, wiring.spec 63f3d3de, rls-g2-s10c 5eeb0fe6 (8 it()), rls-g2-s9c 078fcb1a.

## Review fix round (s10c_gate_binding_review.md, B1-B3), 22:50 PDT
- **B1 (binding).** The no-change-since-S10B pathspec is now `'test/utils/g2-s10b-*'`, so the S11-A1 `g2-s11-*` files are allowed.
- **B2 (binding).** Mirrors the S11 runner fix. Before the lock:
  - `core.hooksPath` must be unset;
  - the hooks dir must be the plain `$W/.git/hooks` directory, not a symlink;
  - both hook files must be regular files whose sha256 equals the new pins `EXPECT_HOOK_PRECOMMIT_SHA` / `EXPECT_HOOK_COMMITMSG_SHA`, taken from the receipt's `hooks raw` line. Both pins are placeholder-refused and must be 64-hex.

  The full set is repeated under the lock.
- **B3 (gate).** One guard line right before `git commit`. It re-asserts HP/HC, an empty hooksPath, the plain .git/hooks dir and regular hook files. On failure it exits rc 71 (HOOK_FAIL).

New shas:
- gate `s10c-gate-d3a9.sh` daf179fd42732020bfc97d0cacec06cda71f8e390e6cadf7ebea638aac02f3af
- gate `DELTA-review-fix.diff` f772a127574eba2430b8e68950bc90e3fb4d3f842807d8ea7e9034e81d517ddf
- gate `README.md` 4dea3c4ad679564e18b8ff6161f6a97ff94cf4e9785331a5c3948363015432b9
- gate `DELTA-from-s10b.diff` 545415718eed00c79b565cb3cebdf32fc8779ecf52804e8010d84659bbbc2ce0
- binding `s10c-pg-proof.sh.template` bf73d2585a8b1f202c5d48e385063057c96e47ca71031b83b869969c5cce9af8
- binding `DELTA-review-fix.diff` 192ec303a5d36ed865b3ca999a2b73305c004290726b692fef73608f82a9f19d
- binding `README.md` 1f9cba2ac64d768ca5083f129a1985deaafe9e3f2fa701cd1710933ecd86d10a
- binding `DELTA-from-s10b-v1.diff` 170a95e0a858618d53691056a7d8d29f132c858c77a078b1bc79e94e884f7bb9

Unchanged: fixture c1b57239, PINS.env 4bbe5ab9, FROZEN e9c71f09, both commit messages.

The pre-fix copies (`*.pre-review-fix`) are kept and hashed.
