# S8-C first PG proof run — independent runtime disposition (reviewer A)

Reviewer: independent S8-C reviewer A. Assignment: runtime-only disposition of the single failed proof run of head `87018a421f5be1064767d2cdd32e75ca935f7cdb` (tree `cec7d05a…`) through v3 driver `9ddb52de66c306601080141c38867d25cd048c951e7c57086996ee4ef40eacd8`, per `S8C_FAILED_PROOF_DISPOSITION.md` (05:35Z). Method: reads and byte comparisons only (`cat`, `sha256sum`, `cmp`, `diff`, `git show/rev-parse/hash-object`, `ls`, `stat`). No regeneration, tests, lock, DB probe, driver invocation, source/binding edit, or peer-report read. This is not a source re-audit; `REVIEW_A.md` / `REVIEW_A_V3.md` unchanged. Written 2026-09-24 ~22:40 PDT (2026-09-25 ~05:40Z).

## 1. Observed run reach and result

Sources: `s8c/binding/v3/run/{LAUNCH.txt, supervisor.stdout, supervisor.stderr, s8c-pg-proof.log, s8c-pg-proof.sentinel, RECEIPTS.sha256, PROOF_RUN_RECEIPT.md}`.

| Marker | Time (Z) | Observed |
|---|---|---|
| Launch | 05:33:12 | `timeout -k 30 3600 bash …/binding/v3/s8c-pg-proof.sh`, supervisor pid 29405, driver pid 29408; lock inode 691716 held on fd9 |
| PRECONDITIONS_OK | 05:33:14 | postgres 17.6, psql 18.6, node v20.20.1, jest 30.4.1, ts-node 10.9.2, prisma 6.19.3 |
| PREFLIGHT / PREFLIGHT_OK | 05:33:16 | other lane `s7l` conf/control `ae1fc878…`/`c2d8ebd8…` (never started); lane absent, port 55642 free, postgres procs 0, porcelain sha = empty-string sha |
| FIXTURE_INIT rc=0 | 05:33:19 | cluster `s8c-disposable-pg17`, `recovery-reset/clusters/s8-c/pg-data`, superuser `s8c_super` |
| FIXTURE_START rc=0 | 05:33:20 | postmaster pid 29903 |
| BOOTSTRAP | 05:33:20–24 | `CANDIDATE_HEAD=87018a42…`; supabase shim applied (3 "already granted" NOTICEs); Prisma datasource `g2_s8c_disposable` @127.0.0.1:55642; **171 migrations found, all applied**; then `candidate client schema is not the candidate prisma/schema.prisma (stale client; regenerate in the runtime slot, never here)` |
| BOOTSTRAP rc=7 / STOP_FIRST_FAILURE | 05:33:24 | stage=bootstrap |
| Cleanup | 05:33:24 | `S8C_FIXTURE_STOP_OK`; `CLEANUP_STOP rc=0 postgres_procs=0 port55642_listeners=0 survivor_pid=none` |
| END | 05:33:24 | `END rc=7 stage=bootstrap`; `SUPERVISOR_RC=7` (natural exit; no timeout/signal) |

Reach: bootstrap `g2-s8c-bootstrap.sh` (blob `8aa86de8…`, 209 lines) failed at step 6, L197–198. Never reached: L199–203 (ImportNativeProvenance / `target_kind` client checks, `CANDIDATE_CLIENT_VERIFIED`), the applied-count query and `G2_S8C_BOOTSTRAP_OK` (L204–209), the Jest stage, all POST checks. No Jest process, no `jest.log`, zero test results. The proof was **not obtained**; this run confers no runtime acceptance of the native writers.

Post-state (read-only, ~05:40Z): `clusters/` holds `s7l` and `s8-c`; `s8-c/pg-data` retained (75 MB) with no `postmaster.pid`; socket dir `recovery-reset/run/s8-c` absent; sentinel present (`RC=7 STAGE=bootstrap END=2026-09-25T05:33:24Z HEAD=87018a42… LOCK_INODE=691716`), so the driver refuses re-invocation by design. Consistent with the builder receipt's post-state and the parent's 05:34:42Z observation; I did not probe the lock or processes.

## 2. Receipt-hash qualification

- `RECEIPTS.sha256` records `s8c-pg-proof.log` = `7d9fa528…`; `sha256sum -c` reports FAILED because the current log hashes to `a223addf33e7f5c9f822958f9cf263747c11b4cb00a99be791b3849d8ba47890`. Recomputed: the log **minus its final line** (`END rc=7 …`) hashes to exactly `7d9fa528…`. The driver writes the manifest before appending the END line; the mismatch is deterministic driver ordering (already present in the reviewed v1–v3 driver), not alteration. Qualification: cite `7d9fa528…` as "log before END line" and `a223addf…` as the complete log.
- Other artefacts (my recomputation = builder receipt): sentinel `bb89d7b7…`, `LAUNCH.txt` `1843dd4d…`, `supervisor.stdout` `79d2a41a…` (driver stderr merged: the stale-client line and the NOTICEs), `supervisor.stderr` empty, `PROOF_RUN_RECEIPT.md` `cf478668…`.

## 3. Causal mismatch — independently tested by reads/comparisons only

Failing check (frozen `87018a42:test/utils/g2-s8c-bootstrap.sh` L197–198):
`cmp -s "$ROOT/node_modules/.prisma/client/schema.prisma" "$ROOT/prisma/schema.prisma" || { echo "… (stale client; regenerate …)"; exit 7; }`
Its comment (L188–189) states the client is "generated once by the runtime setup (the schema is the base schema, so it is the accepted S8-B client) and only VERIFIED here; no `prisma generate`". The accepted S8-B bootstrap (`g2-s8b-bootstrap.sh`, pin `55ab8972…`) contains no such byte comparison of the client schema copy; this check is new in the S8-C bootstrap and has been in blob `8aa86de8…` since `527fe2bc`.

Facts established:
1. Candidate schema: worktree `prisma/schema.prisma` sha256 `77f33bcdc36802f8e1d52553d011f546f56f757cacb391f23436ab266a148589`, git blob `32e44110…` = `87018a42:prisma/schema.prisma` = accepted base `93389265` (driver pin L100–106 verified OK in REVIEW_A_V3 §1). The S8-C candidate never changed the schema.
2. Client copy: `node_modules/.prisma/client/schema.prisma` sha256 `ded50406332707e4fd473a75e0a5407d54eb309085a99edcaaceaa05cb25b249`, mtime 2026-09-25 03:29:36Z (all client files 03:29); `index.d.ts` `b6716a86…`.
3. Provenance of the client: `runtime/raw/rt-setup.log` L49 records the generate input `schema_sha256=77f33bcd…` (= S8-B record), L79/L91 `index.d.ts=b6716a86…` after both postinstall and the CI `npx prisma generate` (`match=yes` to S8-B PINS `NM_CLIENT`), and L93 `client_schema.prisma sha256=ded50406…`. `RUNTIME_SETUP_RECEIPT.md` L40/45–48 states the same. So the client in the worktree **was generated from exactly the schema the bootstrap compares against**, and Prisma 6.19.3 emitted `ded50406…` from input `77f33bcd…` — twice, identically.
4. Content of the difference: `cmp` first differs at byte 321937, line 6739 (model `ExtensionPairCode`, L6738–6758, one model). Plain `diff`: 62 changed lines, all inside that model. `diff -w` (whitespace-insensitive): only 2 lines — the block attribute `@@unique([import_intent_id, coach_id])` appears before the `@@index` lines in the client copy and after them in the committed file. Sorted-token multiset comparison of the two whole files: **0 differences**. Every model, field, type, attribute and argument is identical; only column alignment and the relative order of two block-attribute lines within one model differ. The committed file is not `prisma format`-normalised at that model (unaligned columns at L6739–6771 — from the pre-S8 `edd6dc6b`/`16cd67f4` schema commits), whereas the generator output is.
5. Generator behaviour (read of frozen `node_modules/@prisma/client/generator-build/index.js` L13441–13442): the client's `schema.prisma` is written as `writeFile(schemaTargetPath, datamodel)`, i.e. the CLI-supplied datamodel string, not a byte copy of the file; the CLI (`node_modules/prisma/build/index.js`) supplies the `mergeSchemas` (WASM) output, which is a re-emitted, formatted datamodel. This explains the observed normalisation and why the same input yielded the same non-identical output on both generate passes.

Conclusion: the client is **not stale**. The bootstrap's L197 assumption — that `prisma generate` produces a byte-identical schema copy — is false for the pinned Prisma 6.19.3 whenever the committed schema is not already in the generator's canonical format. The "regenerate in the runtime slot" remedy printed by the diagnostic would **not** close the failure: regenerating from `77f33bcd…` reproduces `ded50406…` (evidence: rt-setup L79/L91/L93), and `cmp -s` would fail again identically. The diagnostic label is therefore misleading and must not be relied on.

Classification: **proof-lane (tool) defect** in the frozen S8-C bootstrap, `test/utils/g2-s8c-bootstrap.sh` L197–198 — one of the six pinned proof files, outside the seven-path candidate delta. Not a product defect (product source, schema, migrations and generated client are consistent with each other and with the accepted S8-B client `b6716a86…`); not a runtime-slot provisioning defect (the slot generated from the correct schema); not a driver/binding defect (the driver ran the pinned bootstrap as designed and stopped at first failure with clean cleanup). Reviewer-side note for the record: this check was in the bootstrap blob reviewed in `REVIEW_A.md`; a read-only `cmp` of the two worktree files would have exposed the mismatch before any grant. Reviewer A did not perform it; recorded as a review miss (C), not attributable to the builder or the runtime.

## 4. Minimum closure (for parent decision; nothing granted or performed here)

Smallest closure that removes the false refusal without weakening the intent (verify, never regenerate): a one-file proof edit to `test/utils/g2-s8c-bootstrap.sh` replacing the byte `cmp` at L197–198 with a verification that binds the candidate client to the exact expected client identity — e.g. sha256 equality of `node_modules/.prisma/client/index.d.ts` to the accepted S8-B record `b6716a865a705ffc0efab30ed88cd163b461e5344ad64e5926a0dff078b49f44` (the same construct the S7-L v3 driver uses via `EXPECT_NM_CLIENT_SHA`), optionally plus sha256 of the client schema copy `ded50406…`, and/or a whitespace-/order-insensitive comparison. Keep L199–203 as they are. Consequences: new bootstrap blob → new head, new driver pin (v4 binding: bootstrap blob line plus HEAD/TREE) → changed-question attestations from both reviewers → new single PG grant → fresh lane (this run's sentinel and `s8-c/pg-data` must not be reset or reused). Alternatives judged inferior: regenerating the client (does not close the failure, §3); `prisma format`-ing the committed schema (touches accepted product bytes and the pinned schema blob `32e44110…` to fix a harness assumption); deleting the check (loses the client-identity verification).

## 5. Boundaries

Terminal failed run: single-run authority consumed; no rerun, repair, generation, lock, DB action or source/binding change requested or implied by this report. No runtime acceptance of `87018a42`, no landing, flags, readers, S8-D/E, S9 or production decision. S7-L lane untouched (preflight recorded it unchanged; I did not inspect it). Candidate `87018a42` and v3 binding remain frozen and unaccepted pending the parent's disposition of the closure above.
