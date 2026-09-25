# S8-C bootstrap correction — independent changed-question review (reviewer A)

Reviewer: independent nonbuilder T4 reviewer A (grant REV-2, `daceddc8/SCOPE.md`). Read-only; this file is the only output. Method: `cat`, `sha256sum`, `cmp`, `diff`, `git show/rev-parse/cat-file/diff-tree/hash-object`, `stat`, and a Python token/JSON comparison on preserved bytes. No lock, gate, test, generator, PG, driver invocation, git write, evidence-repo commit, or peer-report read (`BOOTSTRAP_CORRECTION_REVIEW_B.md` not opened). Changed question only: the one-file bootstrap delta from `87018a42`, its lineage and gate receipts, and the v4 binding. No accepted-source re-audit.

Status: **PHASE 1 complete (2026-09-25 ~16:45Z). PHASE 2 pending the parent's final pins.** Section 5 records pre-pin observations of the commit that already exists in the worktree; they are re-verified in Phase 2 against the parent's pins before a final verdict.

---

## PHASE 1 — is the delta causally sufficient, and does it weaken identity?

### 1.1 The delta under review (bytes)

- Frozen patch `s8c/handoff-freeze/scripts-and-previews/delta-from-87018a42.1file.patch` sha256 `55f07d4730e3eb066d3401c1655f461789580ecc85f12158248b9ec2a3127fc6`; byte-identical to `s8c/bootstrap-correction/delta-from-87018a42.1file.patch` and to the gate's captured `s8c/bootstrap-correction/run/delta-from-87018a42.1file.patch` (gate log `DELTA 55f07d47… blob=7c3fba47…`).
- Every file in `s8c/bootstrap-correction/` that also exists under `handoff-freeze/scripts-and-previews/` is byte-identical to the frozen copy (SOURCE_EDIT_READY.md, commit-message.txt `43511173…`, delta patch, prepare-binding-v4.sh `2c6f01c3…`, both previews, preview-driver.diff, s8c-bootstrap-gate.sh `b589713b…`). New files: `prepare-binding-v4-daceddc8.sh` `7c21f142…`, its `.diff` `3e455ab9…`, `export-v6-daceddc8.sh` `b8f65f72…`.
- `git diff 87018a42 HEAD` in `worktrees/64e33dc7-s8c` is byte-identical to the frozen patch; one path, `test/utils/g2-s8c-bootstrap.sh`, +7/−2, blob `8aa86de8…` → `7c3fba471f991e3750eb56fd29e271101652196e`, mode 100755. `bash -n` OK. `rg 'cmp '` on the new blob: no match.
- Content: two comment lines added at step 6 (L190–191); L197–198 (`cmp -s <client copy> <prisma/schema.prisma> || exit 7`) replaced by `ACCEPTED_CLIENT_SCHEMA_SHA=ded50406…`, an explicit `[[ -f … ]] || exit 7` for a missing copy, and `[[ "$(sha256sum … | cut -c1-64)" == "$ACCEPTED_CLIENT_SCHEMA_SHA" ]] || exit 7` for a mismatch. Both refusal paths keep rc 7. The new diagnostic no longer suggests regeneration. L204–207 (ImportNativeProvenance / `target_kind` greps) and everything else unchanged.

### 1.2 Is `ded50406…` provably the schema copy Prisma emits from committed schema `77f33bcd…`? — YES, by three independent chains

**Chain A — the accepted runtime setup (this sandbox, RT-2).** `daceddc8/runtime/rt-setup.sh` (sha `ab723822…`, identical to consumed `64e33dc7/runtime/rt-setup.sh` `f6801d30…` except the one EVD line; `rt-setup.diff-from-64e33dc7` confirms) does, in order, inside a fresh detached worktree: `git worktree add --detach $WT 93389265` → refuse unless HEAD/tree match and `git status --porcelain --untracked-files=all` is empty → log `schema_sha256=$(sha prisma/schema.prisma)` → genuine `npm ci --foreground-scripts` (postinstall `prisma generate`) → `npx --no-install prisma generate` → log `client_schema.prisma sha256=…`. `daceddc8/runtime/raw/rt-setup.log` records: L48 `head=93389265… tree=a315dd65…`; L49 `schema_sha256=77f33bcd…`; L81 `prisma : 6.19.3 @prisma/client : 6.19.3`; L90 `prisma_generate_exit=0 utc=2026-09-25T16:29:06Z`; L91 `client_index_d_ts=b6716a86… match=yes`; L92 `client_index.js sha256=dc2c4916…`; L93 `client_schema.prisma sha256=ded50406…`; L95 engine `a2924eab…`; L96 hidden lock `05bc530a…`. No file can be edited between L49 and L93 by anything in the script except `npm ci`/`prisma generate` themselves.

**Chain B — the consumed 03:29Z setup (independent machine state).** `64e33dc7/runtime/raw/rt-setup.log` L49/L90/L91/L93 record the same `77f33bcd…` input, generate exit 0 at `03:29:37Z`, `b6716a86…`, and `ded50406…`. `64e33dc7/runtime/RUNTIME_SETUP_RECEIPT.md` L40/46/48 state the same. Two independent `prisma generate` runs of the same pinned toolchain from the same input produced the same normalized copy; the emission is deterministic.

**Chain C — the preserved client bytes themselves.** In `worktrees/64e33dc7-s8c` (HEAD now `e0cee7e0`; client copied by `lane-provision.sh` via real `cp -a` from the donor, `lane-provision.log`: `copy_ok hidden_lock=05bc530a… client_index_d_ts=b6716a86… schema=77f33bcd…`, `s8c_client_index_d_ts=b6716a86… (donor copy, no generate)`):
- `node_modules/.prisma/client/schema.prisma` = `ded50406…` (336 210 bytes, mtime 16:29:04Z = the RT-2 generate window; donor copy `worktrees/64e33dc7-env/node_modules/.prisma/client/schema.prisma` also `ded50406…`).
- `prisma/schema.prisma` = `77f33bcd…` (336 058 bytes); `index.d.ts` = `b6716a86…`; `index.js` = `dc2c4916…`; engine = `a2924eab…`; `node_modules/@prisma/engines/libquery_engine-…so.node` = `a2924eab…`; hidden lock `05bc530a…`. All equal the RT-2 log values, so the client in the S8-C root is the client generated in Chain A.
- Decoded `config.inlineSchema` from `index.js` (JSON string at L3401) is byte-equal to the `ded50406…` copy; `inlineSchemaHash` `00bcf2e5…` is present. The compiled client was generated **from** this normalized text.
- Committed vs copy: identical whitespace-delimited token multisets; 7028 lines each; whitespace-insensitive diff is exactly one moved line, `@@unique([import_intent_id, coach_id])` (block attribute order in `ExtensionPairCode`). No model, field, type, attribute or argument differs. This is the Prisma formatter normalization (re-alignment plus block-attribute reordering), consistent with both runtime reviews.
- Corroboration on a second schema: S7-L committed `0eb41f9a…` → in-lane generated copy `b8439203…` (`lane-provision.log`), i.e. the same not-byte-equal emission pattern.

Conclusion: `ded50406…` is the exact and reproducible `schema.prisma` copy Prisma 6.19.3 (engines `c2990dca…`) emits when generating from committed schema `77f33bcd…` at base `93389265`. The pin binds the client to precisely that provenance.

### 1.3 Causal sufficiency

The failed v3 run reached L197 (all earlier step-6 checks passed; the only stderr line is the L198 message) and would have passed L199–203 (both greps verified against the preserved copy: `model ImportNativeProvenance ` present once; `target_kind String?` present in the ledger block). With the delta, L202 compares `sha256(copy)` = `ded50406…` (Chain C) with the pinned literal `ded50406…`: equal. Nothing else in the bootstrap was changed and nothing else touched the client. The delta closes exactly the observed refusal; the "regenerate" remedy the old diagnostic suggested would not have (regeneration reproduces `ded50406…`, Chains A/B).

### 1.4 Does anything else in the bootstrap still raw-compare? — NO

Full read of blob `7c3fba47…` (214 lines). Remaining comparisons: step 4 `git diff --name-only $BASE_HEAD HEAD -- prisma` empty, `git diff --quiet HEAD -- prisma`, `git diff --quiet $BASE_HEAD HEAD -- package.json package-lock.json` (git tree comparisons — the intended, satisfiable "prisma tree identical to base" rule; they passed in the v3 run since it reached step 6); step 6 engine sha equality against `node_modules/@prisma/engines` and `realpath` equality of the resolved runtime; migration counts; SQL catalog assertions. No `cmp`, `diff`, or byte comparison of a generated artefact against a source file remains.

### 1.5 Could a stale or wrong client now pass? — NO for every realistic class; the check is not weaker than the one it replaces

| Client under test | Old L197 (`cmp` vs `77f33bcd…`) | New L200–203 (`== ded50406…`) | Also caught by |
|---|---|---|---|
| Correct donor client (generated from `77f33bcd…`) | refuses (defect) | passes | — |
| Pre-S8-B / other-schema client | refuses | refuses (copy differs) | driver `EXPECT_NM_CLIENT_SHA` (index.d.ts `b6716a86…`) at driver L116/L187; L204–207 greps |
| Same schema, different Prisma version | refuses | refuses (different normalization/engine) | L193–195 engine sha vs pinned engines; driver `EXPECT_NM_LOCK_SHA` |
| Client generated from a modified candidate schema | never reached | never reached | step 4 exit 4 (prisma tree ≠ base) |
| Client dir missing `schema.prisma` | `cmp` fails → rc 7 | explicit `-f` → rc 7 | — |
| Hand-assembled dir: `ded50406…` copy + foreign `index.js` | old check equally blind (it only read the copy) | passes this line only | driver pins `index.d.ts` pre/post; `index.js` (`dc2c4916…`) is recorded in rt-setup but not pinned anywhere — pre-existing residual, unchanged by this delta |

Because step 4 guarantees the candidate schema equals the base schema, "copy == emission-for-base-schema" is the satisfiable statement of the old intent "copy == emission-for-candidate-schema". The accepting set is a single byte-exact value either way; the new value is the one that actually exists. Identity is not weakened. Additional, unchanged layers: the v3/v4 driver pins `EXPECT_SCHEMA_SHA=77f33bcd…`, `EXPECT_NM_CLIENT_SHA=b6716a86…`, `EXPECT_NM_LOCK_SHA=05bc530a…`, `EXPECT_PKG_LOCK_SHA`, and re-checks the client after Jest (POST L187).

### 1.6 Phase 1 findings (Safety-ROI form)

- **C-1 (note, no harm):** the pin `ded50406…` is a literal that must be re-derived whenever a future slice changes `prisma/schema.prisma`; step 4's base-tree rule already forces such a slice to change the bootstrap, and the new comment states the reason. No decision blocked.
- **C-2 (note, no harm):** the bootstrap does not pin `index.js`/`index.d.ts`; the driver does (`b6716a86…`). Pre-existing layering; the delta neither adds nor removes it. No decision blocked.
- No A or B findings in Phase 1.

**Phase 1 verdict-so-far: GO on the delta.** It is causally sufficient for the observed rc 7, changes nothing else, removes every raw byte comparison, and binds the client to a provenance proven by two independent generate logs and the preserved bytes.

---

## PHASE 2 — committed head, receipts, checkpoints/v6, binding/v4 (pending final pins)

### 5. Pre-pin observations (recorded during Phase 1; to be re-verified against the parent's pins)

Gate run `s8c/bootstrap-correction/run/` (LAUNCH 16:37:30Z, gate sha `b589713b…` = frozen, `S8C_BOOTSTRAP_RELAY=1`, lock inode 674373, `holders 0` before, `lslocks=1` while held, `postgres=0`):
- `DELTA 55f07d47… blob=7c3fba47…` (captured while unstaged → equals frozen patch), `BASH_N rc=0`, `STAGED_TREE=b249efb6…`, `COMMIT rc=0 hook_lines=6`, `HEAD=e0cee7e04bef88811310f6dde1fd921f45d103ad tree=b249efb66e22f4c13529f255f3510d4a81314a99 parent=87018a42… bootstrap_blob=7c3fba47…`, author = committer = `Bradley Gleave <bradley@bradleytgpcoaching.com>`, `porcelain=0`, `files=test/utils/g2-s8c-bootstrap.sh`, `RELEASED` 16:38:20Z.
- `commit.raw.log`: lefthook v2.1.9 pre-commit ran `prod-readiness-quick`, `banned-cast-tokens` (R75 `--cached`, "no positive token change"), `tsc` (48.27 s) — all ✔️; eslint/prettier skipped ("no files for inspection": shell file outside their globs, expected); commit-msg `no-ai-tokens` ✔️; `[exec64/s8c-replacement e0cee7e0] … 1 file changed, 7 insertions(+), 2 deletions(-)`. No `--no-verify`, no rerun, no amend.
- `git cat-file -p e0cee7e0`: tree `b249efb6…`, single parent `87018a42…`, author/committer Bradley, timestamps 1790354251 (16:37:31Z); message equals `commit-message.txt` (modulo `%B`'s trailing newline); no trailer-like lines (`^[A-Za-z-]+: ` grep empty; the `S8-C:` subject prefix contains a digit and is the repository's convention). `git diff-tree` parent→head: exactly `M test/utils/g2-s8c-bootstrap.sh`; `git diff 87018a42 e0cee7e0` byte-equal to the frozen patch.
- `run/export-v6.log`: `HEAD=e0cee7e0 TREE=b249efb6… BOOTSTRAP_BLOB=7c3fba47… mode 100755`, `PRISMA_TREE_UNCHANGED_FROM_PARENT=yes`, `SRC_TREE_UNCHANGED_FROM_PARENT=yes`, `DOCS_CONTRACTS_UNCHANGED_FROM_PARENT=yes`, bundle `s8c/checkpoints/v6/s8c-e0cee7e0.bundle` "is okay", contains `refs/heads/exec64/s8c-replacement` = `e0cee7e0`, requires `93389265`. Manifest lines for CHANGED_PATHS/HEAD.patch/HEAD.txt/bundle recorded. Note the literal `EXPORTED_BY=execution/daceddc8 parent operator` in a builder-owned export — wording only, checked in Phase 2 against who actually ran it.

`prepare-binding-v4-daceddc8.sh` (`7c21f142…`) vs frozen `prepare-binding-v4.sh` (`2c6f01c3…`): my `diff` reproduces the recorded `prepare-binding-v4-daceddc8.diff` byte-for-byte. The only differences are (i) header comment, (ii) the added `"$RUNTIME_ROOT"/proof-v4/clusters/*/` glob in both other-lane loop rewrites and in the count-2 assertion, (iii) the matching comment/README wording. Own-lane exclusion is by actual path (`[ "${d%/}" != "$LANE" ]`), `LANE=$RUNTIME_ROOT/proof-v4/clusters/s8-c`, so the S8-C v4 lane skips itself while a sibling `proof-v4/clusters/s7l` is hashed pre/post and never started; nonexistent globs are skipped by `[ -d "$d" ]`. All v3 non-head pins are asserted unchanged (line 56–57), `CLUSTERS` constant unchanged, no `basename` exclusion may remain, six blob pins must equal `git rev-parse HEAD:<path>`, `BINDING.sha256` includes the three v3→v4 diffs. Not yet run at the time of this section; `s8c/binding/v4/` did not exist.

### 6. Phase 2 checks to perform once pins arrive
Committed head equals pinned HEAD/TREE/blob; one-path delta; Bradley identity; no trailers; hook receipts as above; `checkpoints/v6` manifest verifies (`sha256sum -c`) and bundle head/prerequisite match; `CORRECTION_RECEIPT.md` values agree with the logs; `binding/v4`: `BINDING.sha256 -c` passes, `s8c-pg-proof.sh.diff-v3-to-v4` limited to `D=` path, `EXPECT_HEAD/TREE/BOOTSTRAP_BLOB/FIXTURE_SHA`, the LANE/SOCK constant + comment, and the two loops; fixture diff limited to LANE/SOCK + header comments; PINS diff limited to the same; all other pins byte-equal to v3; the fresh `proof-v4/clusters/s8-c` and `proof-v4/run/s8-c` paths do not exist yet; v3 `run/`, sentinel and `clusters/s8-c` untouched.

**Final verdict: pending Phase 2.**
