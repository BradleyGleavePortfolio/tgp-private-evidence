# S3 FINAL-HEAD-B — findings added by the final revision (interim FHB-01..04 unchanged and still applicable)

| ID | Class | Finding | Evidence | Disposition |
|---|---|---|---|---|
| CF-01 | C | The first composed activation stopped pre-launch because the targeted-validation Jest step (14, ~17:07:17Z) left release.sh's five fixed-path `/tmp` scratch files, which the unchanged harness refuses (exit 70). Fixed `/tmp` paths in `scripts/release.sh` are S1S2-preserved behaviour, not an S3 change; the collision is lane sequencing. Preservation `69a1da31…` moved exactly those five files with identical hashes; the run then found and left `/tmp` clean. | `s3-composed-proof-result/01-scratch-collision.txt`, `s3-scratch-preservation/{01-move.txt,files.sha256}`, `00-preflight-02.txt`, `90-postclosure.txt`, `git grep` in a584 | Record. Future lanes that execute release.sh specs and the composed harness must be serialised (already true under the single canonical slot). No source change. |
| CF-02 | C | "Re-confirmed 17:47:20Z" appears only in the parent's status lines of the grant/reactivation documents; the frozen packet's own last receipted read is 17:44:38Z. | grep of packet (no match) vs `S3_COMPOSED_PROOF_RUNTIME_GRANT.md:3` | Record as unverified parent statement; the run's evidence closes at 17:44:38Z and is sufficient. |
| CF-03 | C | psql client 18.6 against server 17.6, `timeout` from uutils 0.8.0 — same toolchain as the accepted S2 run (stamp lines identical); noted only because it is environment, not source, and would need re-observation on any other host. | `stamp.txt` line 6/9 in both runs | Record. |

No A-class or B-class finding in the composed-proof result portion. Verdict in REPORT_FINAL.md §5.
