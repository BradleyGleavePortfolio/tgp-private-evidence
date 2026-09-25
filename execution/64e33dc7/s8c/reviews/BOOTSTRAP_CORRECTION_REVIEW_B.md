# S8-C bootstrap correction — independent changed-question review B

Reviewer: independent nonbuilder T4 reviewer B (REV-2, `daceddc8/SCOPE.md`). Read-only; this file is the only write. No peer read (`BOOTSTRAP_CORRECTION_REVIEW_A.md` not opened), no lock, gate, test, generator, PG, driver/fixture/bootstrap invocation, or git write. Method: `git show/rev-parse/hash-object/diff-tree/log`, `sha256sum`, `cmp`, `diff`, `node` read-only decode of the compiled client, a glob-enumeration rehearsal in a scratch `/tmp` directory (deleted), and reads of the frozen scripts and logs. Scope: the changed bytes, lineage, gate receipts, and the exact v4 binding/fresh paths only — no accepted-source re-audit.

Status: **PHASE 1 complete** (design of the correction; §1–§3). **PHASE 2 complete** (§4, §4a): the parent's final pins (mail 16:5xZ) were re-verified against the live worktree and every artefact; the verdict in §6 is final.

---

## 1. (a) The bootstrap's verification chain after the change

Candidate bootstrap blob `7c3fba471f991e3750eb56fd29e271101652196e` (214 lines; prior `8aa86de8…`, 209 lines). I regenerated `git diff 87018a42` from the worktree before the commit and it is byte-identical to `s8c/bootstrap-correction/delta-from-87018a42.1file.patch` (sha `55f07d47…`); `git diff --numstat` = `7 2`; `bash -n` OK; `grep 'cmp -s'` → none.

Changed lines are exactly: two comment lines (L190–191) and the replacement of the old L197–198 `cmp -s … || exit 7` by L199–203:

```
ACCEPTED_CLIENT_SCHEMA_SHA=ded50406332707e4fd473a75e0a5407d54eb309085a99edcaaceaa05cb25b249
[[ -f "$ROOT/node_modules/.prisma/client/schema.prisma" ]] || { …; exit 7; }
[[ "$(sha256sum … | cut -c1-64)" == "$ACCEPTED_CLIENT_SCHEMA_SHA" ]] || { …; exit 7; }
```

Both refusals keep rc 7 (grant requirement). The grant permitted "`hash_required` or equivalent existing hash style"; `hash_required` exits 6 on a missing file, so the explicit `[[ -f ]] || exit 7` form is the correct way to keep rc 7 — not a deviation. The diagnostic no longer suggests regeneration (which would reproduce the same copy, see §2).

Every other identity check remains, in order, and is unchanged byte-for-byte (verified by the 7/2 numstat and by reading the full file):

| Step | Check (line in `7c3fba47`) | rc |
|---|---|---|
| Binding | `G2_S8C_CANDIDATE_HEAD` 40-hex, ≠ base, == `git rev-parse HEAD`, porcelain empty, base is ancestor (L42–47) | 2 |
| Deps present | `node_modules/prisma` present; `PRISMA_GENERATE_SKIP_AUTOINSTALL=1` (L50–52) | 2 |
| Server | version 170006, loopback, superuser, `cluster_name` marker, no hosted roles (L72–83) | 3 |
| Source | prisma tree == base `93389265`, no uncommitted prisma changes, package.json/lock == base, 171 migration dirs, S8-B migration present (L144–152) | 4 |
| History | `prisma migrate deploy` from candidate root; owners; 171 applied; S8-B applied; S8-B objects present (L157–175) | 5 |
| Engine | `.prisma/client/<engine>` sha == `@prisma/engines/<engine>` sha in the same tree (L184, L193–195) | 6 |
| Runtime | client resolves `@prisma/client/runtime/library.js` to the root's realpath (L185, L196–198) | 6 |
| Client present | `index.d.ts` exists (L192) | 7 |
| **Client schema copy** | **exists and sha256 == `ded50406…` (L199–203) — the changed check** | 7 |
| Client content | `model ImportNativeProvenance ` present; ledger `target_kind String?` (L204–207) | 7 |

The bootstrap does not itself pin `index.d.ts` or the hidden lock; those are pinned by the driver around it and are unchanged in v4: `EXPECT_NM_LOCK_SHA=05bc530a…` (v4 L114), `EXPECT_NM_CLIENT_SHA=b6716a86…` pre- and post-Jest (L116, L187), `EXPECT_SCHEMA_SHA=77f33bcd…` (L115), `EXPECT_PKG_LOCK_SHA` (L113). Together the chain binds: committed schema (`77f33bcd`) → dependency tree (`05bc530a`) → generated types (`b6716a86`) → generated client datamodel copy (`ded50406`) → engine in client == pinned engines package → runtime resolution. The new check is strictly stronger in intent than the old `cmp` (which could only ever have compared the copy to a file already pinned by the driver) and is satisfiable (§2). No weakening anywhere; nothing else moved.

## 2. (b) `ded50406…` is exactly what the pinned Prisma writes for schema `77f33bcd…` here

Independent facts gathered read-only in this sandbox:

1. **Generation record.** `daceddc8/runtime/raw/rt-setup.log`: L49 generate input `schema_sha256=77f33bcd…` (= S8-B record); L82 "Prisma schema loaded from prisma/schema.prisma"; L84 "Generated Prisma Client (v6.19.3)"; L90 `prisma_generate_exit=0 utc=2026-09-25T16:29:06Z`; L91 `client_index_d_ts=b6716a86… equal_to_postinstall=yes … match=yes`; L92 `client_index.js sha256=dc2c4916…`; **L93 `client_schema.prisma sha256=ded50406…`**; L95 engine `a2924eab…`. Toolchain per L81: prisma 6.19.3, @prisma/client 6.19.3, PSL wasm `7.1.1-3.c2990dca…`, engines `c2990dca…`, Node v20.20.1.
2. **Donor tree today.** `worktrees/64e33dc7-env` is at `93389265`, `prisma/schema.prisma` sha `77f33bcd…` (336 058 B); `node_modules/.prisma/client/schema.prisma` sha `ded50406…` (336 210 B, mtime 16:29:04.609Z, inode 796930); `index.d.ts` `b6716a86…`.
3. **S8-C lane copy.** `worktrees/64e33dc7-s8c/node_modules/.prisma/client/schema.prisma` sha `ded50406…`, same size and mtime, **different inode (975210)** — a real `cp -a` copy per `lane-provision.log` L10/L21 (`client_index_d_ts=b6716a86… schema=77f33bcd…`, "donor copy, no generate"). `index.js` `dc2c4916…`, `package.json` `c91d7b4f…`, client engine `a2924eab…` == `@prisma/engines` engine — all equal to rt-setup L92–95.
4. **The copy is the compiled client's own datamodel.** I decoded `"inlineSchema"` from `.prisma/client/index.js` (JSON string literal): length 331 808 chars, byte-equal to the on-disk `schema.prisma` copy, sha256 `ded50406…`; `inlineSchemaHash` `00bcf2e5…`. So the client was compiled from the normalised text; the copy is not a stray file.
5. **Content of the normalisation.** `diff` committed vs copy: 62 changed lines in 8 hunks at L6739–6757, 6763–6771, 6941–6954 (models `ExtensionPairCode`, `ImportIntent`, `ScoutReconstructionLedger`). `diff -w`: exactly one move — `@@unique([import_intent_id, coach_id])` before instead of after the `@@index` lines. Sorted whitespace-token multiset: identical. Column re-alignment plus one unordered block-attribute reorder; no model/field/type/attribute/relation/index differs.
6. **Reproducibility across environments.** The previous sandbox's accepted `64e33dc7/runtime/RUNTIME_SETUP_RECEIPT.md` L40/46/48 and `64e33dc7/runtime/raw/rt-setup.log` L79/91/93 record the same triple (`77f33bcd` → `b6716a86`, `ded50406`) at 03:29Z; this sandbox reproduced it at 16:29Z through both `npm ci` postinstall and the explicit `npx prisma generate`. The same normalisation pattern holds for S7-L (`0eb41f9a` → client copy `b8439203`, worktree `64e33dc7-s7l` read today).

Conclusion: `ded50406…` is the deterministic output of the pinned Prisma 6.19.3 generator for input `77f33bcd…` in this environment, is what the driver-pinned client (`b6716a86…`) actually embeds, and is present in the S8-C candidate root now. The new check will pass against the provisioned lane and would refuse any client generated from a different schema or by a different generator build (different normaliser output). The pin is exact and correct.

## 3. (c) The v4 other-lane loop enumeration is safe with or without a sibling S7-L `proof-v4` lane

Derived script `prepare-binding-v4-daceddc8.sh` (sha `7c21f142…`) differs from the frozen `prepare-binding-v4.sh` (`2c6f01c3…`) exactly as recorded in `prepare-binding-v4-daceddc8.diff` (I re-diffed; identical): header comment, the loop-comment string, the loop rewrite string (adds `"$RUNTIME_ROOT"/proof-v4/clusters/*/`), the README appendix text, and the matching count assertion. Nothing else — refusals (existing v4, wrong HEAD/parent, dirty tree, non-one-file delta, broken v3 manifest), the pin derivations and the unchanged-pin assertions are byte-identical.

New loop (both preflight L138 and post L182 in the v4 driver):

```
for d in "$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-v3/clusters/*/ "$RUNTIME_ROOT"/proof-v4/clusters/*/; do
  [ -d "$d" ] || continue; [ "${d%/}" != "$LANE" ] || continue; n=${d#$RUNTIME_ROOT/}; n=${n%/}
```

Analysis:
- The driver runs `set -uo pipefail` with no `set -f`/`nullglob`; an unmatched glob stays a literal string and `[ -d ]` skips it. `RUNTIME_ROOT` is asserted to be its own realpath (v4 L127) and contains no glob metacharacters, so `${d#$RUNTIME_ROOT/}` and the `${d%/}` == `$LANE` comparison are exact.
- Own-lane exclusion is by full path against `LANE=$RUNTIME_ROOT/proof-v4/clusters/s8-c`. At preflight the own lane must be absent (L131) so exclusion is moot; at post the own lane exists and is correctly excluded, so `OTHER0 == OTHER1` is unaffected by the run's own cluster.
- Sibling S7-L v4 lane: S7-L's v3 fixture uses `LANE=$RUNTIME_ROOT/proof-v3/clusters/s7l`, `DATA=$LANE/pg-data` and its v4 is specified as `proof-v4/clusters/s7l`; so a sibling at `proof-v4/clusters/s7l/pg-data/` is enumerated, named `proof-v4/clusters/s7l`, refused if `postmaster.pid` is present (71/74) and otherwise hashed (`postgresql.conf`, `global/pg_control`) pre and post — exactly the protection intended. S7-L's `proof-v4/s7l/old-root` is not under `clusters/` and is correctly not enumerated (it is a git checkout, not a cluster). Only the S7-L *driver* creates the lane, and it holds the same canonical flock, so the lane cannot appear or change between S8-C's preflight and post; a false `POST_FAIL 74` is therefore not reachable under the invariants. Independently, `pgrep -cx postgres = 0` (L136) already refuses any live server anywhere.
- Rehearsal in a scratch directory (not the runtime root) with the exact loop body: fresh sandbox with no `clusters/`, `proof-v3/`, `proof-v4/` → enumerates nothing; sibling `proof-v4/clusters/s7l` present → `[proof-v4/clusters/s7l pid=none]`; own lane created → still only the sibling; previous-sandbox layout (`clusters/s7l`, `clusters/s8-c`, `proof-v3/clusters/s7l`) → all four enumerated, own lane excluded; sibling with `postmaster.pid` → flagged `PRESENT`.
- Current runtime root `/home/user/workspace/execution/64e33dc7/recovery-reset` holds only `npm-cache pg17 s7l s8c tools xdg-cache`; none of the three globs currently matches, so in this sandbox the loops log nothing and the `[ -e "$CLUSTERS" ] || log "clusters_dir=ABSENT"` line fires. Record-only: `SOURCE_EDIT_READY.md`'s "dry path enumeration today yields clusters/s7l, clusters/s8-c, proof-v3/clusters/s7l" described the previous sandbox and is not the state here; no impact on correctness.

Verdict (c): the three-glob enumeration is safe whether or not the sibling exists, adds protection for a sibling S7-L v4 lane, and cannot produce a false failure under the single-lock invariant.

## 4. PHASE 2 — committed head, gate receipts, v6, v4 (preliminary; observed on disk before the parent's final pins)

Observed at ~16:45Z. To be confirmed against the parent's final-pin message; if the pins match the values below, these findings stand.

**Gate run** (`s8c/bootstrap-correction/run/`): `LAUNCH.txt` gate sha `b589713b…` = the frozen `s8c-bootstrap-gate.sh` sha I computed; `S8C_BOOTSTRAP_RELAY=1`; lock inode 674373, holders 0 before. `s8c-bootstrap-gate.log` (== `supervisor.stdout`, `supervisor.stderr` empty): ACQUIRED 16:37:30Z fd9 inode 674373 lslocks=1 postgres=0 → DELTA `55f07d47…` blob `7c3fba47…` → BASH_N rc=0 → STAGED_TREE `b249efb6…` → COMMIT rc=0 hook_lines=6 (16:38:19Z) → HEAD/tree/parent/blob/author/committer/porcelain=0/files=one → RELEASED 16:38:20Z. Single attempt; no retry. `run/delta-from-87018a42.1file.patch` == prepared patch.

**Genuine hooks** (`run/commit.raw.log`, sha `fcaeb8d4…`): lefthook v2.1.9 `pre-commit` — eslint/prettier skipped ("no files for inspection": `.sh` is outside their globs, as the grant anticipated), `prod-readiness-quick` ✔️, `banned-cast-tokens` ✔️ ("no positive token change"), `tsc` ✔️ 48.27 s; `commit-msg` — `no-ai-tokens` ✔️. Hook scripts in the shared `.git` are the pinned `pre-commit 3b741de3…` and `commit-msg 71029ce8…`. No `--no-verify`, no amend.

**Committed head** (worktree `64e33dc7-s8c`, porcelain 0): `e0cee7e04bef88811310f6dde1fd921f45d103ad`, parent `87018a42…` (== `af9f7f54` lineage below unchanged), tree `b249efb66e22f4c13529f255f3510d4a81314a99`, author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, date 2026-09-25T16:37:31Z. `git diff-tree --name-only 87018a42 HEAD` = `test/utils/g2-s8c-bootstrap.sh` only; `git diff 87018a42 HEAD` byte-equal to the prepared patch; `HEAD:test/utils/g2-s8c-bootstrap.sh` = `7c3fba47…`, mode 100755. Message = `commit-message.txt` (sha `43511173…`) verbatim, 8 lines, no trailer-shaped lines (`^[A-Za-z-]+: ` none), no AI/co-author tokens.

**checkpoints/v6**: `MANIFEST.sha256` verifies (5/5 OK); `bundle-verify.log` "is okay", contains `e0cee7e0 refs/heads/exec64/s8c-replacement`, requires base `93389265`; `HEAD.txt` values equal the live worktree (HEAD, TREE, parent/tree, author/committer, blob, PORCELAIN=0, prisma/src/docs-contracts unchanged from parent); `CHANGED_PATHS_from_87018a42.txt` = the one file; `CHANGED_PATHS_from_base.txt` = the accepted 25-path S8-C set. Record-only: `HEAD.txt` says `EXPORTED_BY=execution/daceddc8 parent operator` though SCOPE hands the export script to the builder — a labelling nit, no evidentiary effect.

**binding/v4**: `BINDING.sha256` verifies (10/10 OK, manifest sha `c2cfd0a3…`); `prepare-binding-v4.log` records `V4_FILLED head=e0cee7e0… tree=b249efb6… bootstrap_blob=7c3fba47… fixture=c59326b5… driver=73b291db…` and is byte-equal to `run/prepare-binding-v4.log`. `.v3` copies are byte-identical to `binding/v3/*`; v3 manifest still verifies (frozen bytes untouched). Recorded `s8c-pg-proof.sh.diff-v3-to-v4` equals my fresh `diff -u v3 v4`. The driver delta is exactly: `D=…/binding/v4`; `EXPECT_HEAD=e0cee7e0…`; `EXPECT_TREE=b249efb6…`; `EXPECT_BOOTSTRAP_BLOB=7c3fba47…`; `EXPECT_FIXTURE_SHA=c59326b5…`; `LANE=$RUNTIME_ROOT/proof-v4/clusters/s8-c; SOCK=$RUNTIME_ROOT/proof-v4/run/s8-c` + one comment line; the two loop lines of §3. `CLUSTERS=$RUNTIME_ROOT/clusters` kept; no `basename`, no `__FILL`. Fixture delta: `LANE`/`DATA…SOCK` constants and the two header-comment lines only; the fixture's own refusals (`pg17/dist` data root, historical `/home/user/pg17`, existing `$DATA`, marker checks) are unchanged and accept the new path; `mkdir -p "$SOCK" "$LANE"` creates the fresh `proof-v4/` tree. PINS delta: path header, HEAD/TREE/BOOTSTRAP_BLOB/FIXTURE, receipts path → v4. README: appendix only. I re-derived all six `EXPECT_*_BLOB` from `e0cee7e0` — all match (five unchanged from v3, bootstrap new); the nine tool pins, `EXPECT_NM_LOCK/NM_CLIENT/SCHEMA/PKG_LOCK`, `BASE_HEAD/TREE` are byte-identical to v3. `bash -n` OK on both v4 scripts. The harness (`g2-s8c-pg-harness.ts`) compares `data_directory` to `G2_S8C_DATA_DIRECTORY` by equality with no path pattern, so the fresh `proof-v4/…/pg-data` path needs no helper change (as the grant stated).

### 4a. PHASE 2 final — parent's pins re-verified (16:5xZ)

Every pinned value in the parent's mail was recomputed by me and matches: worktree HEAD `e0cee7e04bef88811310f6dde1fd921f45d103ad`, `HEAD^` `87018a42…`, tree `b249efb66e22f4c13529f255f3510d4a81314a99`, `HEAD:test/utils/g2-s8c-bootstrap.sh` `7c3fba47…`, author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, porcelain 0. `CORRECTION_RECEIPT.md` sha256 `d57509aa…`; v6 bundle `97c14d06…`; v4 driver `73b291db…`, fixture `c59326b5…`, `BINDING.sha256` `c2cfd0a3…`. `run/RUN_MANIFEST.sha256` verifies 9/9 (LAUNCH, gate log == supervisor.stdout `0f189e3e…`, commit.raw.log `fcaeb8d4…`, empty bash-n/stderr, patch `55f07d47…`, export-v6.log, prepare-binding-v4.log); v4 manifest 10/10, v6 manifest 5/5, v3 manifest still intact.

`CORRECTION_RECEIPT.md` read in full: its preconditions table, event timeline (ACQUIRED 16:37:30Z → RELEASED 16:38:20Z), hook results, commit fields, v6 and v4 sections and the `BINDING.sha256` listing agree with the raw logs and with my own recomputations in §4 above; its "scripts run unchanged" claims hold (gate `b589713b…`, `export-v6-daceddc8.sh` `b8f65f72…`, `prepare-binding-v4-daceddc8.sh` `7c21f142…` are the shas I computed from the files on disk). Its §4 flags the same two items the parent asked me to classify; my classification is in §5 (C2, C4).

All of §4's conditions are satisfied; nothing was found that the receipt omits or misstates beyond the record-only items below.

## 5. Findings (Safety-ROI form)

No class A or B finding: I found no concrete harm in the changed bytes, lineage, gate receipts, or v4 binding.

- **C1 (record-only).** `SOURCE_EDIT_READY.md` "dry path enumeration today yields clusters/s7l, clusters/s8-c, proof-v3/clusters/s7l" is a previous-sandbox observation; here the runtime root has none of those and the loops enumerate nothing until a sibling lane exists. Concrete harm: none (behaviour verified in §3). Decision blocked: none. Closure: none required; note in receipt if desired.
- **C2 (record-only).** `checkpoints/v6/HEAD.txt` `EXPORTED_BY=execution/daceddc8 parent operator` while SCOPE (16:32Z orchestrator-only mode) says the builder runs the handed script. Harm: none; the exported values are independently verified against the live worktree. Closure: none required.
- **C3 (record-only, design note for a future driver, not this grant).** The bootstrap pins the client schema copy while the driver pins `index.d.ts` and the hidden lock; `index.js` (`dc2c4916…`) is bound only transitively (it embeds the pinned `inlineSchema`). This is the accepted S8-B/S7-L construct and outside the changed question. No action.
- **C4 (record-only) — parent-flagged item 2: `binding/v4/PINS.txt` L57 documentary line** `DIST=$RUNTIME_ROOT/pg17/dist  DATA=$RUNTIME_ROOT/clusters/s8-c/pg-data  SOCK=$RUNTIME_ROOT/run/s8-c` still names the v3 lane. Class C: `PINS.txt` is documentary; the v4 driver and fixture (the only executed artefacts) carry `proof-v4/clusters/s8-c` and `proof-v4/run/s8-c`, the driver never reads `PINS.txt` (its sole mention is a comment at L21), the fixture derives `DATA` from its own `LANE` constant, and the driver's preflight refuses an existing `$LANE` regardless. Concrete harm: none to the proof; a reader relying on PINS.txt alone for the data path would be misdirected to a lane that does not exist in this sandbox. Decision blocked: none. Origin: the frozen `prepare-binding-v4.sh` `2c6f01c3…` rewrote PINS only for header/HEAD/TREE/BOOTSTRAP/FIXTURE/receipts; the daceddc8 derivation did not introduce it. Minimum closure: none required for PG-4 (bindings are derived, v4 is frozen and hashed; do not hand-edit); record in the receipt (done) and, for any future binding version, add one `sed` line for the DATA/SOCK documentary line to the fill script. Execution unlocked: yes.
- **Parent-flagged item 1** is C2 above: `HEAD.txt` `EXPORTED_BY=… parent operator` while the builder executed the handed script. The receipt corrects it; hashed into the manifest so left as emitted. No harm, no closure required.
- **C5 (record-only).** `checkpoints/v6/bundle-verify.log` is present but not listed in `MANIFEST.sha256` (same shape as v5); `binding/v4/prepare-binding-v4.log` is likewise outside `BINDING.sha256` (same as v3) but is byte-equal to the copy inside `run/RUN_MANIFEST.sha256`. No harm.

## 6. Verdict

**PHASE 1: GO-so-far.** (a) The correction is the minimum closure both runtime reviews described; every other identity check is byte-unchanged and the chain (schema → lock → types → client datamodel copy → engine → runtime) is intact and strictly not weakened. (b) `ded50406…` is exactly the pinned Prisma 6.19.3 output for `77f33bcd…` in this environment, reproduced in two sandboxes and embedded in the driver-pinned client; the check is satisfiable against the provisioned lane and exact against any other client. (c) The three-glob enumeration with full-path own-lane exclusion is safe with or without a sibling S7-L v4 lane and cannot false-fail under the single-lock invariant.

**PHASE 2 FINAL: GO.** Committed head `e0cee7e04bef88811310f6dde1fd921f45d103ad` (tree `b249efb6…`) is an ordinary genuine-hook commit on exact parent `87018a42…` with a one-path delta byte-equal to the prepared patch, Bradley author and committer, no trailers, porcelain 0; the gate ran once, unchanged, under the canonical lock and released; `checkpoints/v6` and `binding/v4` verify and are derived from that head with only the permitted changes (paths/head/tree/bootstrap blob/fixture pin/loop enumeration); all other pins are byte-identical to v3; `CORRECTION_RECEIPT.md` (`d57509aa…`) is accurate. Findings are all class C (record-only); none blocks execution.

This attestation covers the bootstrap closure, one-file lineage, gate receipt and the exact v4 binding/fresh paths only. It is not runtime acceptance of `e0cee7e0`, does not retroactively accept the failed `87018a42`/v3 run, and grants nothing — a PG-4 single invocation `timeout -k 30 3900 bash s8c/binding/v4/s8c-pg-proof.sh` remains the parent's separate decision after dual GO, with the heavy slot free.
