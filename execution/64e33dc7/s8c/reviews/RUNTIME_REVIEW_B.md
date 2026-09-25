# S8-C first PG proof — runtime failure disposition, independent reviewer B

Immutable, new file. Scope per parent mail (05:34Z/05:35Z) and `S8C_FAILED_PROOF_DISPOSITION.md`: runtime-only review of the single failed proof run of exact head `87018a421f5be1064767d2cdd32e75ca935f7cdb` (tree `cec7d05a…`) under v3 driver `9ddb52de66c306601080141c38867d25cd048c951e7c57086996ee4ef40eacd8`. Read-only: `s8c/binding/v3/run/*`, `PROOF_RUN_RECEIPT.md`, the frozen bootstrap (`git show 87018a42:test/utils/g2-s8c-bootstrap.sh`, blob `8aa86de8…`), the committed candidate schema, the generated client in the candidate root, and the accepted `runtime/RUNTIME_SETUP_RECEIPT.md` + `runtime/raw/rt-setup.log`. No regenerate, test, lock, DB probe, driver invocation, source/binding edit, peer read. `REVIEW_B.md` and `REVIEW_B_V3.md` untouched.

## 1. Actual reach (from `run/s8c-pg-proof.log`, `supervisor.stdout`, `LAUNCH.txt`, sentinel)

| Stage | Observed | Time (Z) |
|---|---|---|
| Launch | `timeout -k 30 3600 bash …/binding/v3/s8c-pg-proof.sh`, supervisor pid 29405, driver pid 29408, canonical lock inode 691716 held on fd 9 | 05:33:12 |
| PRECONDITIONS_OK | postgres 17.6 server, psql 18.6, node v20.20.1, jest 30.4.1, ts-node 10.9.2, prisma 6.19.3 | 05:33:14 |
| PREFLIGHT_OK | lane absent, port 55642 free, postgres procs 0, worktree porcelain sha `e3b0c442…` (empty), S7-L conf/control hashes recorded, never started | 05:33:16 |
| FIXTURE_INIT / START | rc 0 / rc 0, postmaster pid 29903, cluster `s8c-disposable-pg17` | 05:33:19 / 05:33:20 |
| BOOTSTRAP | `CANDIDATE_HEAD=87018a42…`; supabase shim (3 benign NOTICEs); `prisma migrate deploy`: 171 migrations found, all applied to `g2_s8c_disposable`, including `20270122000000_scout_native_provenance_expand`; then step 6 client verification refused: `candidate client schema is not the candidate prisma/schema.prisma (stale client; regenerate in the runtime slot, never here)` → **BOOTSTRAP rc=7** | 05:33:24 |
| STOP_FIRST_FAILURE | stage=bootstrap rc=7; natural exit — `SUPERVISOR_RC=7`, no timeout/kill, `supervisor.stderr` empty | 05:33:24 |
| Not reached | identity checks after bootstrap, Jest (`jest.log` absent), post-checks | — |

Reach: migrations of the candidate schema applied cleanly on PG 17.6; **zero** native-writer runtime behaviour was exercised. The run yields no acceptance evidence for `87018a42`.

## 2. Cleanup (observed)
- Driver: `S8C_FIXTURE_STOP_OK`; `CLEANUP_STOP rc=0 postgres_procs=0 port55642_listeners=0 survivor_pid=none`; `END rc=7 stage=bootstrap 05:33:24Z`; lock held to exit.
- Sentinel `run/s8c-pg-proof.sentinel`: `RC=7 STAGE=bootstrap END=2026-09-25T05:33:24Z HEAD=87018a42… LOCK_INODE=691716` — driver will refuse re-invocation; none attempted.
- My passive check (~05:40Z): no `postgres`/driver/`jest` processes; `execution/test-validation.lock` present, inode 691716, size 0; `clusters/s8-c/pg-data` retained (75 MB, no `postmaster.pid`); `recovery-reset/run/s8-c` socket dir exists but empty of listeners (receipt says "absent" — minor wording difference, not a survivor). S7-L lane untouched by this run per PREFLIGHT record.

## 3. Causal analysis — independently tested by reads/comparisons

**Failing check.** `g2-s8c-bootstrap.sh` L197-198 (blob `8aa86de8…`, unchanged since 527fe2bc):
`cmp -s "$ROOT/node_modules/.prisma/client/schema.prisma" "$ROOT/prisma/schema.prisma" || { echo "… stale client; regenerate …"; exit 7; }`
It is a byte-exact comparison. Checks before it passed (client present; engine sha equals pinned `@prisma/engines` copy; runtime resolves to pinned `library.js`). Checks after it (L199-202: `model ImportNativeProvenance` present; ledger `target_kind String?`) would pass — I verified both greps against the client copy.

**The two files.**
- `prisma/schema.prisma` in the worktree: sha256 `77f33bcd…`, blob `32e44110…` = `87018a42:prisma/schema.prisma` = accepted base `93389265:prisma/schema.prisma`. The candidate never changed the schema.
- `node_modules/.prisma/client/schema.prisma`: sha256 `ded50406…`, 336 210 bytes vs 336 058, both 7028 lines, mtime 2026-09-25 03:29:36Z. Byte-identical to the donor copy in `worktrees/64e33dc7-env/node_modules/.prisma/client/schema.prisma` (separate inode, same content and timestamp — a real copy per the runtime receipt's instruction 2). `index.d.ts` `b6716a86…` and engine `a2924eab…` in the candidate root equal the values recorded in `RUNTIME_SETUP_RECEIPT.md` (and S8-B `NM_CLIENT`). So the client under test **is the accepted donor client**, not a stale or foreign one.
- `diff`: 62 differing lines in three models — `ExtensionPairCode` (L6739-6757), `ImportIntent` (L6763-6771), `ScoutReconstructionLedger` (L6941-6954). `diff -w` leaves exactly one change: `@@unique([import_intent_id, coach_id])` moved from after to before the `@@index` lines in `ExtensionPairCode`. The sorted multiset of whitespace-delimited tokens is identical. I.e. column re-alignment plus one block-attribute reorder — the canonical `prisma format` normalisation of the committed file. Prisma block attributes are unordered; no model, field, type, attribute, relation or index differs. The builder receipt's "confined to `ExtensionPairCode`" is incomplete (two further models re-aligned) but its "no semantic difference" conclusion holds.
- The compiled client agrees with its schema copy: I decoded `config.inlineSchema` from `node_modules/.prisma/client/index.js`; it is byte-equal to the `ded50406…` copy (`inlineSchemaHash` `00bcf2e5…` is Prisma's own hash of that string). The client was therefore generated *from* the normalised text, not merely accompanied by it.

**Where the normalised text came from — the decisive fact.** The accepted runtime setup (`runtime/raw/rt-setup.log`) recorded, in the donor at HEAD `93389265`: L49 input `schema_sha256=77f33bcd…` (the committed bytes; the donor's `prisma/schema.prisma` mtime 03:23:16Z precedes generation and its status is clean), L53/L82 "Prisma schema loaded from prisma/schema.prisma", L90 `prisma_generate_exit=0 utc=03:29:37Z`, and L93 **`client_schema.prisma sha256=ded50406…`**. So Prisma 6.19.3 `generate`, fed the exact committed schema, emitted the normalised `ded50406…` copy. Corroboration: the S7-L worktree shows the same pattern (committed `0eb41f9a…` → client copy `b8439203…`, generated 04:06Z per `s7l/SOURCE_READY.md`). Regenerating the client in the runtime slot from the frozen schema would reproduce `ded50406…` and fail L197 again. The bootstrap's own remedy text ("regenerate in the runtime slot") is therefore wrong, and the premise in its comment L188-189 ("the schema is the base schema, so it is the accepted S8-B client" and hence byte-equal) is false for this toolchain whenever the committed schema is not already in `prisma format` canonical form. The accepted S8-B bootstrap (`g2-s8b-bootstrap.sh`, blob `55ab8972…`) never made a byte-exact comparison — it checks model/field presence only — so this assumption was first introduced by the S8-C bootstrap and had never been exercised against the donor before this run.

**Classification: proof/tool defect** in the committed S8-C proof helper `test/utils/g2-s8c-bootstrap.sh` L197-198 (an unsatisfiable environment assertion), not a product defect (native writers, schema and migrations untouched and the migrations applied), not a driver/binding defect (v3 driver executed its pinned stages exactly), and not an environment/runtime-slot defect (the client is the accepted, receipt-recorded donor client). Reviewer self-record: this blob was within my initial source review; I read the client-verification step as a conservative pin and did not test its satisfiability against the donor receipt. That was a miss on my side; it is recorded here, not excused.

## 4. Minimum closure (for parent decision; nothing granted or performed here)

Smallest change that closes the defect without loosening what the check intends (that the client under test is exactly the accepted client for the frozen base schema):

- **Option 1 (recommended, one proof file, 2 lines):** in `g2-s8c-bootstrap.sh` replace the L197-198 `cmp -s` with a pin of the client schema copy to the accepted runtime-setup value: `[[ "$(sha256sum "$ROOT/node_modules/.prisma/client/schema.prisma" | cut -c1-64)" == ded50406332707e4fd473a75e0a5407d54eb309085a99edcaaceaa05cb25b249 ]]` (the value recorded in `RUNTIME_SETUP_RECEIPT.md`; matching the existing style of the engine/runtime pins at L186-196), and correct the comment L188-189. Keep L199-202. Consequences: new bootstrap blob → `EXPECT_BOOTSTRAP_BLOB` (driver L34) and PINS change → binding v4 (3-4 line driver delta), new head, changed-question attestations, new single-proof grant. Stronger than the byte-exact `cmp` in intent (it also pins index.d.ts-equivalent provenance via the receipt) and honest about how Prisma writes the copy.
- Option 2: keep `cmp` but normalise both sides (whitespace + block-attribute order) — more logic in a shell helper, harder to review; not minimum.
- Option 3: commit `prisma format` output of `prisma/schema.prisma` — touches a base-pinned product file (`32e44110…`) purely for tooling, invalidates the base-file pin and S8-B identity; rejected as not minimum.
- Not a closure: regenerating the client in the runtime slot (reproduces `ded50406…`); rerunning the unchanged driver (sentinel refuses; and the failure is deterministic).

## 5. Receipt and hash qualifications
1. `run/RECEIPTS.sha256` records `s8c-pg-proof.log` = `7d9fa528…`, but the on-disk log is `a223addf…`; `sha256sum -c` FAILS. Cause is the driver's own `finish()` (L70-73): it writes the manifest and *then* appends the `END rc=… (receipts=…)` line. `sha256sum` of the log minus its final line is exactly `7d9fa528…`. So the manifest attests everything up to and including `CLEANUP_STOP`; the `END` line is attested only by `supervisor.stdout` (`79d2a41a…`, which contains the same line) and the sentinel. The builder receipt reports `7d9fa528…` as "log sha" — it is the manifest value, not the current file hash; readers must use `a223addf…` for the final file. Same design artefact as the RECEIPTS self-entry item recorded as C in REVIEW_B; a future driver version should hash after the last log line.
2. Builder receipt "difference confined to `ExtensionPairCode` (lines 6739–6757)": incomplete; `ImportIntent` L6763-6771 and `ScoutReconstructionLedger` L6941-6954 are also re-aligned (whitespace only). Conclusion unchanged.
3. Builder receipt "mtime 03:29:36Z (runtime-setup/donor-generated client, not produced by this lane)" — confirmed; and the receipt's implicit closure "regenerate the client from the exact committed schema" is refuted by the accepted setup log (§3).
4. Other receipt hashes recomputed and matching: sentinel `bb89d7b7…`, `LAUNCH.txt` `1843dd4d…`, `supervisor.stdout` `79d2a41a…`, `supervisor.stderr` empty. Receipt timestamps and stage record agree with the log.
5. Receipt says socket dir `recovery-reset/run/s8-c` "absent after stop"; the directory exists (empty of listeners). Immaterial.

## 6. Disposition
- The single granted proof run is terminal and **failed at bootstrap rc 7**; proof authority consumed; **no runtime acceptance** of `87018a42`, no evidence for or against native-writer behaviour, no landing/flag/reader authority.
- Cleanup verified: no survivors, lock intact and free, port free, data and sentinel retained as designed.
- Source and v3 binding remain frozen and unchanged; the source GO in `REVIEW_B_V3.md` referred to the source/binding review and is not converted into acceptance by this run.
- Cause is a deterministic proof-tool defect in the S8-C bootstrap's byte-exact client-schema comparison, unsatisfiable with the accepted Prisma 6.19.3 donor client; minimum closure is a two-line pin change in `test/utils/g2-s8c-bootstrap.sh` plus a v4 binding, each requiring its own grant and changed-question attestations. No rerun, regeneration or correction is requested or authorised by this review.
