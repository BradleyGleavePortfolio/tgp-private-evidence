# S8-D1 independent T4 review — 2026-09-26

**Verdict: NO-GO as committed; conditional GO for the D1 implementation after B1 closure and parent-owned live proof.** Reviewed `/home/user/workspace/worktrees/fa72-s8d1`, HEAD `42c8ed30d4c846740211959e189e448d4f72cb3d`, tree `650a32e4cf40ede417533928686aa68c58395902`, parent `38d0d366730331e4edf19a14cda8247435b89431`. Working tree clean. No PostgreSQL, jest, heavy slot, lock, or edits to that worktree.

## A/B findings

**A: none found in the D1 production change under static review.**

**B1 — mandatory journey-full honesty update is not in the candidate.**

1. **CLASS:** B, proof/acceptance gap (not an observed production identity flaw).
2. **CONCRETE HARM:** `test/scout/s11/journey-full.pg.spec.ts:4-25,330-385,513-535` still explicitly claims a roster-bearing leg *must* be `partial/unresolved_identities` and asserts that result, while the new typed writer and S9 join make those clients verifiable. Its J20 check walks `3db615c0^..HEAD`, so this D1 `src/` commit is necessarily an unlisted S11 slice. On an enabled live lane the file now has two independent reasons to fail and conveys a false product claim.
3. **EXACT DECISION BLOCKED:** landing this exact HEAD as a fully proof-ready S8-D1 integration and claiming the mandatory S11 full-journey/J20 sweep green.
4. **MINIMUM CLOSURE:** parent applies and reviews `execution/fa72efb2/s8d1/journey-full_leg-b_j20_required-changes.patch` on the actual landed S11-D revision, adjusts the pinned `S11_RANGE_END` if that revision adds a later S11 `src/` commit, confirms the patch's new leg-B `complete`, no-conditions, verified-clients assertions and still-present qualifier, then runs parent-owned live J19/J20. `git apply --check` succeeds against this r2-based D1 tree, **not** evidence that the patch applies unchanged to the parent's r3 bytes.
5. **EXECUTION UNLOCKED:** honest full-journey proof, with J20 retaining per-pinned-commit slug and core-diff checks and a complete walk of the actual S11 range; parent can then assess landing.

The deferred patch is substantially correct and focused: it flips only leg B's now-obsolete verdict/client cell, preserves the two-source chain, roster, `InvitePending` and `roster_bridge_pending`, and stops J20's *S11-only* coverage walk at a pinned, ancestor-checked S11 endpoint rather than exempting arbitrary commits from individual slug/gate checks. Its endpoint `38d0d366...` is valid on the reviewed r2 parent; the r3 landing relationship remains unverified here.

## C findings / qualifications

- **C1 — production contract:** `person-writer.ts:82-132` uses staged raw `(coach, platform, clients, source_id)` for provenance and the mapper-trimmed external ref only for pre-D1 adoption. Resolved provenance checks kind/id and Person ownership/state before return; Deleted or missing resolves to `unresolved:native_target_removed`, wrong kind/foreign coach to `unresolved:identity_conflict`; replay does not update `display_name`. Adoption creates/promotes one `already_present` provenance row; creation writes Person before provenance inside the engine's per-row transaction, then the typed ledger outcome. The schema's coach-scoped external-ref and provenance unique keys, and existing P2002/P2034 retry-once, support same-ref convergence. No `User` write or email/name key was introduced. This is static reasoning, not a real concurrent-transaction proof.
- **C2 — reconciliation honesty:** `facts.service.ts:1003-1021` maps `PersonState.Deleted` to the non-null removal marker consumed by `checkNative`; `reconcile.ts:136-169` retains NULL-kind historical rows in bucket f even if provenance exists, and recognizes verified `person` in bucket j. The run verdict cases at `reconcile.spec.ts:797-844` keep another unresolved family partial and allow `complete` only with all families/basis clean. `FAMILY_QUALIFIERS.clients` and the roster bridge are unchanged.
- **C3 — specs:** writer specs distinguish creation, coach-edited replay, missing/Deleted/foreign/wrong-kind targets, pre-D1 adoption, five repeated writer invocations, unresolved promotion and fake rollback. Engine specs exercise typed ledger, replay precedence, adoption and simulated P2002. Facts specs distinguish bucket i and historical bucket f. `s10-unseen.pg.spec.ts:429-469` flips (h) on an actual roster-plus-native-clean staged shape with signed coverage; this is code-justified, not merely a fabricated `complete` fixture. The changed fakes implement `findUnique/create/provenance` instead of silently preserving upsert semantics. Inventory searches located the other obsolete live claim only in journey-full (B1); `journey-induction` correctly changes its explanatory comment but not its native-clean assertions. No tests-of-tests added to this commit.
- **C4 — limits:** The engine-unit fake's `$transaction` simply invokes the callback; the separate `FakeNativeTx` snapshots/rolls back. The synthetic P2002 case supplies an already-committed winner and does not prove database isolation or a losing provenance-update race. Parent must perform the granted PG lanes. The accepted §5.1 decision document at fa72-s8d commit `7a7d18de` is not present as an object in this review clone (`git show` RC 128); comparison used the binding grant, owner decision, builder-described contract and the implementation, not a direct reading of that document. This limits the claim of verbatim document fidelity.
- **C5 — scope:** No migration or schema change in the commit. Touched production TS has no `s10_unseen`/`s11_second` slug. Existing source JSON data can of course name a source. Production diff +197/−32 (net +165), test diff +936/−104 (net +832); 14 changed files, five production/nine test.

## Reviewed path inventory (line count at HEAD; SHA-256)

All paths below are relative to `/home/user/workspace/worktrees/fa72-s8d1/`.

| Path | LOC | SHA-256 |
|---|---:|---|
| `src/scout/reconciliation/facts.service.ts` | 1068 | `803cb385e2406be490d6ac93a6ec874145d8153419c3a10db64fea4a91a7beeb` |
| `src/scout/reconstruct/families.ts` | 175 | `304c0b95bf07b48d41fbe31f32efacfd394bd05b23dee7fc390df8b865076f31` |
| `src/scout/reconstruct/native/native-contract.ts` | 142 | `eb22c4e6fce34a86f3e25cc3c6c69c970cbdb7b3cd9ae61eb428651ebff02e7b` |
| `src/scout/reconstruct/native/native-provenance.ts` | 154 | `6def365fd937a10a9e7805cb8a25ed5d52bddef5d76dabb43cb485715251cbd4` |
| `src/scout/reconstruct/native/person-writer.ts` | 132 | `6651f87637b6141ea749e7290edb8b215aa683df1ab81b24366f3216729a2037` |
| `test/scout/reconciliation/facts.service.spec.ts` | 1006 | `eb5528293c6e0343aea67efa912ffdcd4136b961bfd7b3241b029cc4ad10b4b4` |
| `test/scout/reconciliation/reconcile.spec.ts` | 1774 | `c53e00b3534de0bbb3a12e9f0013c4a02954407c94adea27c789ba502fd12901` |
| `test/scout/reconstruct/conformance-alpha.e2e.spec.ts` | 610 | `909cc204f91ab77cb57970c9f86d444a8d03b2af71812205f5db7b98f8bfa381` |
| `test/scout/reconstruct/mapping-spec.third-source.spec.ts` | 431 | `7c97adf803da43ce9e474c1a93b75e68c67a67f008f50878b17bf0a05de8bdc4` |
| `test/scout/reconstruct/native/fake-native-tx.ts` | 294 | `83a7a1ff91a982390a95ea4ada2d1ed06e1d53abebbe3022dccaa65de101f276` |
| `test/scout/reconstruct/native/person-writer.spec.ts` | 246 | `c0ffed2b2be76bca3524d3051dfe79dee2ec955237ef1251507c53cfcc213f5d` |
| `test/scout/reconstruct/scout-reconstruct.service.spec.ts` | 1152 | `6aebb2148806d2bc1520216f63d5221f9b383ce1d6ef994f7b782771863bb5b7` |
| `test/scout/s10/s10-unseen.pg.spec.ts` | 473 | `364bac5d6ac13ab6b72f265855ce6415454dc9fcfd3e1c76a5df32346e890136` |
| `test/scout/s11/journey-induction.pg.spec.ts` | 528 | `95cbc6943a5db21bbdda3b1b1907a43025c88d70f656644a2cec704b5465017d` |

Deferred patch (not committed): `/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2/s8d1/journey-full_leg-b_j20_required-changes.patch`, 192 lines, SHA-256 `e7f0629f1ad033248a9ea44ac0d611f7cfe69a027d1073cdd9a1ecf02e2045cb`.

## Commands run / RC

Read-only shell commands only. Repository below abbreviated `R=/home/user/workspace/worktrees/fa72-s8d1`, evidence namespace `E=/home/user/workspace/repos/tgp-private-evidence/execution/fa72efb2`; paths in actual invocations were absolute.

| Commands (including piped/batched reads) | RC |
|---|---|
| `sed -n` on `E/WORKER_RULES.md`, `E/s8d1/S8D1_REVIEW_GRANT.md`, `E/s8d1/S8D1_BUILD_GRANT.md`, builder report, owner decision and deferred patch (bounded ranges) | 0 for existing files |
| `git -C R status --short/--porcelain`, `show --stat --oneline HEAD`, `show --format=fuller --no-patch HEAD`, `diff --name-status HEAD^ HEAD`, `rev-parse HEAD HEAD^{tree} HEAD^`, `rev-list --count HEAD^..HEAD`, `ls-tree -r HEAD --name-only` | 0 |
| `git -C R diff HEAD^ HEAD --` changed production files, reconciliation specs, S10/S11 specs; `git -C R diff --numstat HEAD^ HEAD -- src test` (also `awk` aggregate); `git -C R diff --name-only HEAD^ HEAD` | 0 |
| `sed -n` on relevant production writer, provenance, family, mapper, contract, ledger engine, facts, reconcile, roster, Prisma schema and relevant spec/fake bounded ranges | 0; initial mistaken `src/scout/reconstruct/scout-reconstruct.service.ts` read RC 2 (actual file `src/scout/scout-reconstruct.service.ts`, subsequently read) |
| `rg --files` on review tree/evidence; `rg -n` inventory for legacy person upsert, target kind, client partial claims, qualifier, S10 and S11 fixture shapes, retry and schema keys; `rg` results piped to `head` | 0 for result-bearing searches; no-match queries RC 1, initial `rg` on nonexistent `apps/` and `packages/` printed path errors |
| `git -C R show 7a7d18de:docs/decisions/2026-09-26-s8d-person-link.md` | 128 (object absent; no fidelity claim based on direct doc read) |
| Initial attempted `sed -n` for decision document inside `R` and owner decision mistakenly at `E/s8d1/` | 2 (both relocated/qualified; owner decision then read at `E/`) |
| `git -C R diff --check HEAD^ HEAD`; `git -C R apply --check E/s8d1/journey-full_leg-b_j20_required-changes.patch` | 0, 0 (checked again explicitly) |
| `rg -n 's10_unseen\|s11_second'` on the three principal touched production TS files | 1 (no match, expected) |
| `wc -l`, `sha256sum` on all 14 changed paths and deferred patch; `sha256sum` on rules/grant; `git diff --name-only | while read ...` | 0 |

Open risk after B1: only parent-owned live PG proof can establish actual database rollback, contention, S9 settled basis, and J19/J20 behavior. Nothing in this read-only review represents a passing test run.
