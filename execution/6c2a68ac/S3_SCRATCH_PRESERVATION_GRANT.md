# S3 fixed scratch collision: reversible preservation grant

Parent EXEC-6c2a68ac, 2026-09-23. ACTIVE file-only disposition by original S3 validation executor `restore_s3_candidate_mue9wspd`. No product execution or runtime slot assigned. S3 composed proof has NOT launched; stopped result `s3-composed-proof-result` seale04842cc/5 records a preflight collision, not a consumed proof attempt.

## Concrete boundary and minimum action

The unchanged release harness refuses pre-existing fixed scratch. Five ordinary files exist and must not be overwritten or discarded. Their contents/timestamps suggest prior local negative-test activity, but ownership provenance is not proven and must not be invented. The narrow action is reversible relocation with preserved bytes/metadata, not destruction, an attribution investigation, or a runner change.

Exact paths only:

- `/tmp/prisma_migrate.log`
- `/tmp/prisma_status.log`
- `/tmp/prisma_verify.log`
- `/tmp/prisma_verifier.log`
- `/tmp/release_verifiers_discovered.txt`

Sole new destination `/home/user/workspace/execution/6c2a68ac/s3-scratch-preservation/**`, initially absent. Read the stopped packet `00-preflight.txt` and snapshot identities therein. Before moving, confirm each is an ordinary non-symlink uid2000 file with matching captured identity/hash if available, and no open fd to those exact files. Do not signal or acquire the canonical lock. If any identity changed, file is open, symlink/special/unreadable, or unexpected owner is found, stop and report rather than touch it.

Record exact lstat/size/timestamps/hash and move those five files only into a `files/` subdirectory, retaining basename and metadata. Verify byte hashes afterward and absence of the five original paths. Preserve an inverse mapping and concise receipt with a non-self-including seal. No deletion, content rewrite, chmod of original bytes, wildcard cleanup or moving other `/tmp` directories/files. Do not recreate originals automatically.

The latest S3 preflight observed no DB/node/npm/Jest/flock workload or holder; S6 C6 may run concurrently but uses disjoint owned paths and no release/DB scratch. Check exact-file fd use, not a new global process census. No worktree/index/module/private-checkout changes, installs/tests/DB/network/lock action, remote operation or additional audit.

This resolves only the path-collision precondition while retaining all prior evidence. The unchanged composed one-shot must still receive a new explicit activation on a free slot with fresh result root `execution/6c2a68ac/s3-composed-proof-result-02`; original stopped result remains immutable. Bradley decision required: NO for this bounded reversible local move.
