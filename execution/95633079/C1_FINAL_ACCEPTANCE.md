# C1 final local acceptance

Parent EXEC-95633079 records **C1 ACCEPTED** after both independent same-review final attestations. All frozen criteria passed on the exact committed and executed candidate; no new validation cycle is authorized by this acceptance.

## Exact boundary

| Item | Accepted value |
|---|---|
| Commit | `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` |
| Tree | `87798e742c7b48f56b05e9b5c30efa877180a9b3` |
| Ordered parent 1 | `5c760b774598532e90d5d217e15adc9285c3c3f4` |
| Ordered parent 2 | `881c4c791727adef8d423931e1cca83a0ffbb9c9` |
| Scope | Exact preserved 18-file C1 candidate; no reconstruction or completed source-review repeat |
| Author and committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` |
| Raw approved and committed message SHA-256 | `288048d7b7e908f8803d3d70e57465f52cfc9f102bb4bc4b1dba30143ce7cb83` |
| Genuine hooks | Ordinary local commit ran configured Lefthook jobs; no bypass |
| Targeted validation | 11/11 suites, 190/190 tests passed, raw RC 0; terminal `2026-09-24T06:05:23Z` |
| PostgreSQL proof | Existing 1 suite, 22/22 cases passed, raw RC 0; terminal `2026-09-24T06:30:27Z` |
| PostgreSQL identity | 17.6, `server_version_num=170006`, permitted disposable C1 data directory |
| PG spec blob | `cc3b0e4da17add10aade720c1b7e10a9f78db937` |
| Fixture SHA-256 | `27b816afb53ebaa5afbad73b6075eddd366d611799a44a44fa549b5f43ca5040` |
| One-run proof binding SHA-256 | `505061752aa09d4b6cfbd60bbc45835ee3613932dbcca1816130bed975c4eef2` |
| Portable committed bundle SHA-256 | `b5126ab5336dacfe6b7d56ea18d449eb65a764059bd77ce77b022f51e246f128` |

## Independent acceptance and terminal evidence

Independent nonbuilder A completed `audits/c1-a/FINAL_ATTESTATION.md` and `FINAL_MANIFEST.sha256`: ACCEPTED, A0/B0. Independent nonbuilder B completed `audits/c1-b/PART4_ACTUAL_PG_PROOF_ATTESTATION.md` (SHA-256 `74d538c413b32a688c7ec4eb076c015eca408fef4beef02a7064f5f2cfef35f1`), `FINDINGS_PART4.md` and the cumulative manifest: ACCEPTED, A0/B0 across all four phases.

These conclude the existing reviews, not replacement source audits. B disclosed reading an executor addendum that quoted A's earlier one-line verdict after B's fixture verdict was frozen; B did not read A's audit files and independently derived the raw-result and checksum conclusions.

The full committed-candidate packet remains in `c1-execution/`. The one-run PG evidence remains in `c1-pg/`, including compact actual receipt `ce422b42195974ca66258dda55e1a9944bda160bbe5d39adbec8d22eec3c0b49` and final `MANIFEST.v3.sha256` (`4aec32daebaddd9c6a581fd86b8f71e7a192712895a353aa57b008181add6baa`).

Raw fixture init, start, database creation and stop returned 0. The exact acknowledged database was used, all 22 cases executed without guard refusal or skipped cases, and the run ended normally within its existing bounds. Attributed cleanup and B's read-only observations establish stopped PostgreSQL, free port 55439, no postmaster PID, retained C1 data, no C1 survivors or quarantine and released runtime lock. S5 remained absent and was never reconstructed.

## Preserved nonblocking qualifications

All earlier A and B Class C findings remain applicable. In particular:

- The original frozen launcher's install child returned 0 and its literal hook-path detector returned RC 71. Those failed receipts remain intact; the separately reviewed remainder reused genuine native hooks without reinstalling or retrying the whole launcher.
- The raw committed message equals the approved bytes exactly. The extra newline arose only in Git's `%B` display; the display file's “raw” name does not change that evidence.
- The inherited optional readiness-script conditional is not production-readiness proof.
- Running-log `RECEIPTS.sha256` files are pre-final snapshots, not final seals. Their expected final-log mismatch does not invalidate the final logs, sentinels or manifest.
- The passing collision-exhaustion case intentionally emitted a Nest error diagnostic. Jest's CLI banner says 30.4.1 while the pinned package metadata says 30.4.2; the receipt's “empty launcher.out” description is inaccurate but the hashed contents are consistent. None changes test selection, actual outcomes or acceptance.
- Cleanup is an identity-bound actual receipt, not a promise that every hypothetical interruption cleans itself up. Later workers' processes or locks are not C1 survivors.

Class C creates no fixer, rerun, harness change, further audit or execution delay.

## Scope limits and immediate continuation

This is acceptance of local C1 durable setup/recovery, not all S7, consumer-contract freeze, full-history migration proof, Start/cancel authority, native migration, packaged/customer acceptance, product landing or deployment. Contract `2.0.0-c1-s1.1` remains unfrozen for consumers.

Accepted S1–S6, S7 foundation and S5's E/T-Q0 proof remain unchanged and must be reused. The next actual product slice is canonical S7-3′ B/drain on this accepted C1 lineage: bounded resumable unambiguous backfill and obsolete-writer fence/drain, preserving E/T semantics and both narrow indexes as a separately promotable artifact. Continue R → N/Q1 → C and remaining S7, then S8–S12; eligible UX work stays parallel.

**BRADLEY DECISION REQUIRED: NO** for these routine local next actions. Product remote landing, deployment, live-account access and other reserved boundaries remain unauthorized.
