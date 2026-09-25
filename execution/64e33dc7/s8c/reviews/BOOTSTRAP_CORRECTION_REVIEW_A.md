# S8-C bootstrap correction — independent changed-question review (reviewer A)

Reviewer: independent nonbuilder T4 reviewer A (grant REV-2, `daceddc8/SCOPE.md`). Read-only; this file is the only output. Method: `cat`, `sha256sum`, `cmp`, `diff`, `git show/rev-parse/cat-file/diff-tree/hash-object`, `stat`, and a Python token/JSON comparison on preserved bytes. No lock, gate, test, generator, PG, driver invocation, git write, evidence-repo commit, or peer-report read (`BOOTSTRAP_CORRECTION_REVIEW_B.md` not opened). Changed question only: the one-file bootstrap delta from `87018a42`, its lineage and gate receipts, and the v4 binding. No accepted-source re-audit.

Status: **PHASE 1 complete 16:45Z; PHASE 2 complete ~16:58Z against the parent's final pins (mail 16:5xZ). Final verdict: GO (section 8).**

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

## PHASE 2 — committed head, gate receipts, checkpoints/v6, CORRECTION_RECEIPT, binding/v4

Parent's final pins (mail): HEAD `e0cee7e04bef88811310f6dde1fd921f45d103ad`, TREE `b249efb66e22f4c13529f255f3510d4a81314a99`, parent `87018a42`, bootstrap blob `7c3fba47`, Bradley author+committer, porcelain 0; receipt `d57509aa…`; bundle `97c14d06…`; v4 driver `73b291db…`, fixture `c59326b5…`, `BINDING.sha256` `c2cfd0a3…`. Every value below was recomputed by me, not copied.

### 5. Committed head (worktree `64e33dc7-s8c`, branch `exec64/s8c-replacement`)

| Check | Observed |
|---|---|
| `git cat-file -p e0cee7e0` | tree `b249efb66e22f4c13529f255f3510d4a81314a99`; single parent `87018a421f5be1064767d2cdd32e75ca935f7cdb`; author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, both 1790354251 (16:37:31Z) |
| One-path delta | `git diff-tree --no-commit-id -r --name-status 87018a42 e0cee7e0` = `M test/utils/g2-s8c-bootstrap.sh`; `git diff 87018a42 e0cee7e0` byte-identical to frozen `delta-from-87018a42.1file.patch` `55f07d47…`; `HEAD:test/utils/g2-s8c-bootstrap.sh` = `7c3fba471f991e3750eb56fd29e271101652196e` |
| Message | equals `commit-message.txt` (`43511173…`) modulo `%B`'s trailing newline; `grep -E '^[A-Za-z-]+: '` on the body: no match (no trailers; the `S8-C:` subject prefix contains a digit and is the branch convention, cf. `87018a42`, `af9f7f54`) |
| Genuine hooks | `run/commit.raw.log` (`fcaeb8d4…`): lefthook v2.1.9 pre-commit `prod-readiness-quick` ✔, `banned-cast-tokens` ✔ (R75 `--cached`, no positive token change), `tsc` ✔ 48.27 s; `eslint`/`prettier` skipped "no files for inspection" (shell file outside their globs); commit-msg `no-ai-tokens` ✔; `[exec64/s8c-replacement e0cee7e0] … 1 file changed, 7 insertions(+), 2 deletions(-)`. Gate log `COMMIT rc=0 hook_lines=6`. Gate script is the frozen `b589713b…` and contains no `--no-verify`, `--amend`, or `-n` |
| Lineage | reflog: `e0cee7e0 commit: …` directly over `87018a42`; one earlier `87018a42 reset: moving to HEAD` (a no-op mixed reset on the same commit during WIP preparation; not an amend, not a move) |
| Unsigned (`%G?` = N) | acceptable; no signing invariant in SCOPE |
| Not pushed | no `refs/remotes/*/exec64/s8c-replacement` |
| Porcelain | 0 now; gate logged `porcelain=0` after commit |
| Slot | gate `ACQUIRED` 16:37:30Z inode 674373 (`holders 0` in LAUNCH.txt before; `lslocks=1` while held), `RELEASED` 16:38:20Z; `postgres=0`; lock file preserved |

`run/RUN_MANIFEST.sha256`: 9/9 OK (`LAUNCH.txt` `13d0ba7d…`, gate log = `supervisor.stdout` `0f189e3e…`, `commit.raw.log` `fcaeb8d4…`, `bash-n.log` and `supervisor.stderr` empty, delta `55f07d47…`, `export-v6.log` `219c9148…`, `prepare-binding-v4.log` `38782293…`).

### 6. Checkpoint v6 and CORRECTION_RECEIPT

- `checkpoints/v6/MANIFEST.sha256`: 5/5 OK; bundle `s8c-e0cee7e0.bundle` = `97c14d06…` (matches pin). `git bundle verify` "is okay"; `list-heads` = exactly `e0cee7e0… refs/heads/exec64/s8c-replacement`; prerequisite `93389265`. `HEAD.patch` byte-equal to my own `git format-patch -1 --stdout e0cee7e0`. `CHANGED_PATHS_from_87018a42.txt` = `M test/utils/g2-s8c-bootstrap.sh`. `HEAD.txt` values equal §5 (HEAD/TREE/author/committer/date/blob/mode 100755, PRISMA/SRC/DOCS_CONTRACTS unchanged from parent = yes).
- `bootstrap-correction/CORRECTION_RECEIPT.md` = `d57509aa…` (matches pin). Every hash and timestamp it cites that I could recompute agrees (gate events, hook results, HEAD/TREE/blob, v6 manifest lines, v4 `BINDING.sha256` contents and file sha, v3 copies, driver/fixture shas). It correctly reports the two items in §7.

### 7. Binding v4 (`s8c/binding/v4/`)

- `BINDING.sha256` file sha `c2cfd0a3…` (pin); `sha256sum -c` 10/10 OK. Driver `73b291db…`, fixture `c59326b5…` (pins). `prepare-binding-v4.log` reports the same head/tree/blob/fixture/driver/manifest.
- `.v3` copies byte-identical to `binding/v3/` (driver `9ddb52de…`, fixture `1a7faa5f…`, PINS `316dd121…`); `binding/v3/BINDING.sha256` still verifies 7/7.
- All three recorded `*.diff-v3-to-v4` reproduce from my own `diff -u` (bodies identical; only the two header lines differ by relative vs absolute path, as expected).
- Driver v3→v4 diff is limited to: `D=…/binding/v4`; `EXPECT_HEAD=e0cee7e0…`; `EXPECT_TREE=b249efb6…`; `EXPECT_BOOTSTRAP_BLOB=7c3fba47…`; `EXPECT_FIXTURE_SHA=c59326b5…` (= actual v4 fixture sha); the `LANE=$RUNTIME_ROOT/proof-v4/clusters/s8-c; SOCK=$RUNTIME_ROOT/proof-v4/run/s8-c` constant line + one comment; the two other-lane loops (preflight L138, post L182) now enumerating `"$CLUSTERS"/*/ "$RUNTIME_ROOT"/proof-v3/clusters/*/ "$RUNTIME_ROOT"/proof-v4/clusters/*/` with own-lane exclusion by actual path `[ "${d%/}" != "$LANE" ]` and `n=${d#$RUNTIME_ROOT/}` labels. Nothing else changed: `BASE_HEAD/TREE`, the five other proof blobs, nine tool pins (`EXPECT_NM_CLIENT_SHA=b6716a86…`, `EXPECT_SCHEMA_SHA=77f33bcd…`, `EXPECT_NM_LOCK_SHA`, …), `CLUSTERS=$RUNTIME_ROOT/clusters`, PORT/DB/ADMIN, `FIX=$D/s8c-fixture.sh`, all stages. No `basename`, no `__FILL`. `bash -n` implied OK by the prepare script and confirmed by unchanged structure.
- Six blob pins independently equal `git rev-parse e0cee7e0:<path>`: SPEC `dc804fde…`, BOOTSTRAP `7c3fba47…`, DB `a7d67217…`, PGH `4059883d…`, HARNESS `d5cbf877…`, WORKER `48403063…`; tree `b249efb6…`.
- Fixture v3→v4 diff limited to `LANE=`/`DATA…SOCK=` constants (proof-v4 paths) and the associated header-comment lines. PINS.txt diff limited to header path, HEAD/TREE/BOOTSTRAP_BLOB/FIXTURE_SHA and the RECEIPTS path.
- Fresh paths: `recovery-reset/proof-v4`, `proof-v3` and `clusters` do not exist in this sandbox; the driver's `[ ! -e "$LANE" ]` preflight and `[ -d ]` loop guards handle that. The v3 run receipts are unchanged (sentinel `bb89d7b7…`, LAUNCH `1843dd4d…`, log `a223addf…`); `binding/v4/run/` does not exist.
- Loop semantics: an S7-L v4 lane at `proof-v4/clusters/s7l` would be enumerated, hashed pre/post and never started; the own lane is skipped by path, so it is correctly excluded from the "unchanged other lanes" comparison even though it is created by this run.

### 8. Findings (Safety-ROI form) and final verdict

- **C-3 — `checkpoints/v6/HEAD.txt` `EXPORTED_BY=execution/daceddc8 parent operator`** (builder item 1). Class C: documentary label hard-coded in the parent-prepared `export-v6-daceddc8.sh` L26, run unchanged by the builder as SCOPE directed. Concrete harm: none — no decision reads that line; the actor of record is fixed in `CORRECTION_RECEIPT.md` §4.2 and the gate/receipt manifests. Decision blocked: none. Minimum closure: none required; the receipt is the correction of record (a future export helper should take the actor from the grant). Execution unlocked.
- **C-4 — `binding/v4/PINS.txt` L57 shows v3 lane paths** (builder item 2). Class C: the line is identical in `binding/v3/PINS.txt` L57 and is a documentary lane-identity note the frozen prepare script never rewrote; the daceddc8 derivation did not introduce it. Concrete harm: none — neither driver nor fixture reads PINS.txt (grep: only a comment mention); the executed artefacts carry `proof-v4/clusters/s8-c` and `proof-v4/run/s8-c` and `EXPECT_FIXTURE_SHA` pins the fixture that does. A reader could look for v4 data under `clusters/s8-c`; `README.md` v4 appendix and the receipt state the correct paths. Decision blocked: none. Minimum closure: none before the proof; correct the PINS template in any future binding version, never edit frozen v4. Execution unlocked.
- **C-5 — reflog `reset: moving to HEAD` on `87018a42`** before the commit: a mixed reset to the same commit (unstaging during WIP preparation); no history rewrite, parent chain intact. No harm, no closure.
- C-1, C-2 from Phase 1 stand. No A or B findings.

**FINAL VERDICT: GO** for exactly candidate `e0cee7e04bef88811310f6dde1fd921f45d103ad` (tree `b249efb6…`) under binding `s8c/binding/v4/` (driver `73b291db…`, fixture `c59326b5…`, manifest `c2cfd0a3…`), one run of `timeout -k 30 3900 bash s8c/binding/v4/s8c-pg-proof.sh` under a separate PG-4 grant, serialized on the canonical lock. This attestation covers the changed question only: the one-file bootstrap delta and its provenance pin, the commit lineage and gate receipts, checkpoint v6, and the v4 binding derivation. It is not a re-audit of the accepted S8-C source, confers no runtime acceptance, and authorizes no landing, flag, reader, S8-D/E or production decision.
