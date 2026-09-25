# S8-C bootstrap minimum correction grant

## Revoked for owner handoff, 2026-09-25 05:56Z

`HANDOFF_FREEZE.md` supersedes this entire grant, including its written 05:43 relay. That relay was never delivered to the builder; source gates, hooked commit, v4 binding and v6 checkpoint never began. The exact one-file WIP and prepared scripts are preserved in `s8c/handoff-freeze/`; a new operator must explicitly regrant any future work. All content below is historical scope, not current authority.

Parent disposition, 2026-09-25. Sole writer remains `s8_c_replacement_builder_muge72rc`. This authorizes source preparation only until an explicit later source-gate relay. S7-L retains sole heavy authority for its currently granted a68cdac7/v3 proof; no S8-C lock, gate, commit, generation, database action or retry is authorized now.

## Causal disposition

Parent read both independent `s8c/reviews/RUNTIME_REVIEW_A.md` and `RUNTIME_REVIEW_B.md` completely, and independently compared the two schema files. The first run remains failed with natural bootstrap rc7, before any Jest test. It does not evidence a native-writer product failure or confer acceptance.

The accepted runtime setup records input schema SHA256 `77f33bcdc36802f8e1d52553d011f546f56f757cacb391f23436ab266a148589` and generated client schema-copy SHA256 `ded50406332707e4fd473a75e0a5407d54eb309085a99edcaaceaa05cb25b249`. Those exact files remain present. The donor client is the expected one, including index.d.ts SHA256 `b6716a865a705ffc0efab30ed88cd163b461e5344ad64e5926a0dff078b49f44`. Prisma normalizes the emitted schema text; regenerating would not close the raw-byte comparison failure.

Parent adopts the common classification: proof/tool B in `test/utils/g2-s8c-bootstrap.sh`, not a product, provisioning or driver defect. Record-only qualifications: the whitespace realignment spans ExtensionPairCode, ImportIntent and ScoutReconstructionLedger, not only the first model; the sole whitespace-insensitive residual is ExtensionPairCode's moved block-unique attribute. Reviewer A and the builder receipt understate that formatting scope. The driver log manifest covers the log before END (`7d9fa528…`), while the complete log is `a223addf…`; old receipts and reports remain immutable, with no C-fixer work.

## Sole product-file correction

Start from exact frozen HEAD `87018a421f5be1064767d2cdd32e75ca935f7cdb`, tree `cec7d05a91876ec3f6badb1020bb97aacdb9331d`. Change only `test/utils/g2-s8c-bootstrap.sh`:

- Replace the two-line raw `cmp -s` refusal at lines197-198 with an exact SHA256 check of the generated client `node_modules/.prisma/client/schema.prisma` against `ded50406332707e4fd473a75e0a5407d54eb309085a99edcaaceaa05cb25b249`, using the existing `hash_required` helper or equivalent existing hash style. Missing file or mismatch must still refuse with rc7.
- Correct only the directly related comment/diagnostic to explain that the accepted generated copy is normalized and identity-pinned; do not suggest regeneration as this failure's remedy.
- Retain candidate-head/clean-tree/base ancestry checks, engine/runtime resolution and hashes, model and target_kind presence checks, migration count and all other bootstrap behavior. The existing driver already pins index.d.ts and the candidate schema; do not weaken those pins.

No change to src, prisma, contract artifacts, proof spec, other helpers/tests, dependency files, generated client, hooks or workflows. Do not normalize/format the accepted schema, remove identity verification, add a schema parser, compare sorted token multisets at runtime or regenerate anything.

## Preparation and gated commit

Prepare the one-file delta and a new versioned checkpoint now; `bash -n`, Git reads and hashes are allowed, not bootstrap execution or `verify-only`. Report SOURCE_EDIT_READY and wait for explicit relay. No formatting tool or test execution while S7-L holds heavy authority.

After relay only: take the existing canonical nonblocking lock in the working process, verify exact parent and one-file delta, run `bash -n` and one ordinary genuine-hook commit with heap4096, isolated pinned formatter/offline npm. Shell files are outside the formatter/eslint path globs; do not force unsupported formatter parsing or add gratuitous gates. The genuine hooks provide their existing applicable checks. No default Jest or PG test is affected or authorized; no generator/install/client regeneration. First failure stops and reports with raw evidence; no automatic correction or rerun.

Commit author and committer Bradley Gleave <bradley@bradleytgpcoaching.com>, no trailers, bypass, amend or push. Exact parent must be87018a42. Release promptly, export to fresh `s8c/checkpoints/v6/`, and write `s8c/bootstrap-correction/CORRECTION_RECEIPT.md`.

## New private binding with fresh paths

Create only `s8c/binding/v4/`; preserve v1-v3 bytes, failed v3 run/sentinel and its data lane. No destruction, adoption or restart of retained clusters.

Use fresh data `recovery-reset/proof-v4/clusters/s8-c/pg-data`, lane `proof-v4/clusters/s8-c`, and socket `proof-v4/run/s8-c`. Port55642, synthetic roles/markers, PG/tool paths, time bounds, one Jest invocation, first-failure cleanup and sentinel behavior remain unchanged. Existing committed guards accept an explicit environment-supplied data path, so no helper/spec path change is granted.

The private fixture changes only the lane/socket path constants and directly associated comments. Driver changes only v4 receipt paths/comments, candidate HEAD/TREE/BOOTSTRAP_BLOB and derived fixture hash, and fresh lane/socket paths. Keep `CLUSTERS=$RUNTIME_ROOT/clusters`; in both existing other-lane loops replace basename-only own-lane exclusion with actual `$LANE` path comparison so the failed `clusters/s8-c` is included. Add the existing `recovery-reset/proof-v3/clusters/*/` glob to those same loops so the new S7-L lane is also protected by unchanged conf/control pre/post hashing. No new behavior beyond this necessary enumeration of retained lanes.

All other five proof-object pins, accepted-base/schema/migration pins, nine tool pins, dependency/client hashes stay unchanged. Freeze from the clean committed head, derive pins rather than hand-adjusting mismatches, and record exact filled v3-to-v4 driver/fixture diffs, PINS, README and manifest. A versioned preparation/fill script may perform only these source-side derivations and checks, never the driver. The filled diff must be included in the frozen manifest rather than a placeholder-only view.

## Separate review and execution

On the new head and complete frozen v4 binding, the same two independent reviewers examine only this bootstrap closure, one-file lineage, applicable gate receipt and the exact private-binding/fresh-path delta. New immutable outputs: `s8c/reviews/BOOTSTRAP_CORRECTION_REVIEW_A.md` and `BOOTSTRAP_CORRECTION_REVIEW_B.md`; no peer reads or unchanged source audit.

No new S8-C PostgreSQL grant exists until both changed-question attestations are GO and parent separately binds a single invocation to the new head and v4 driver after the heavy slot is free. Neither this correction nor any later pass retroactively accepts the failed87018a42/v3 run.

## Explicit source-gate relay, 2026-09-25 05:43Z

S7-L's v3 proof terminated naturally with Jest rc1 at05:41:42Z,23 passed/1 failed; bounded cleanup reported stop0/postgres0/listeners0/survivor none. Parent verified no canonical holder, relevant heavy process or55641/55642 listener at05:43:14Z, inode691716 intact. S7-L's execution authority has ended and its candidate/data/receipts are frozen for runtime-only review.

Parent read the prepared S8-C one-file delta at05:43:20Z: only `test/utils/g2-s8c-bootstrap.sh` is modified, with exact generated-schema hash check, missing-file/mismatch rc7 and related comments/diagnostic; no other path changed. S8-C is now the sole heavy source-gate grantee. Finish the checkpoint and perform only the source gates and ordinary hooked commit specified above, then release/export/freeze and stop. First failure must be preserved and reported without automatic remediation or retry. This relay grants no S8-C PostgreSQL invocation.
