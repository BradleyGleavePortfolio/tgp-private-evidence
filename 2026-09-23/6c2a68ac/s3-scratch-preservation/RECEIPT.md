# S3 fixed-scratch reversible preservation — receipt (file-only, no runtime)

Executor `restore_s3_candidate_mue9wspd`, parent EXEC-6c2a68ac, 2026-09-23T17:34:53–17:35:20Z. Grant `S3_SCRATCH_PRESERVATION_GRANT.md` sha256 `aff88ae5a3be2b85cd45a86773ef07dff5612f083181fcbdb661b9f047d9c801` (untracked in private checkout at HEAD `943dcbb2`; not written). Stopped packet `s3-composed-proof-result/MANIFEST.sha256` `e04842cc…` 5/5 OK, read-only.

## Action
Exactly five paths, no wildcards, no deletion, no content/mode change: `/tmp/prisma_migrate.log`, `/tmp/prisma_status.log`, `/tmp/prisma_verify.log`, `/tmp/prisma_verifier.log`, `/tmp/release_verifiers_discovered.txt` → `files/<basename>` via `mv -n` on the same filesystem (dev 65024, rename(2)): inodes 84069/84067/84080/84086/84066, mode 644, uid/gid 2000, sizes 0/31/31/20/70 and mtimes 17:07:17.67–.69Z all preserved; only ctime updated by rename. Destination directory was empty before; each destination absent before its move.

## Preflight (00-preflight.txt) — all PASS, no stop
Regular non-symlink, uid 2000, nlink 1; sha256 and size of each file identical to the stopped `01-scratch-collision.txt` snapshot (`e3b0c442…`, `cf6904c8…`, `cf6904c8…`, `69fc75c6…`, `3313072d…`); zero open fds to the exact paths across `/proc/*/fd`; canonical lock not touched; no signals; no process census.

## Verification (01-move.txt, files.sha256 vs expected.sha256)
After-move sha256 of all five == snapshot hashes: IDENTICAL. All five original `/tmp` paths absent. `INVERSE_MAP.txt` holds the five exact `mv -n` restore lines (not executed; originals not recreated).

## Attribution (not proven, not invented)
mtimes 17:07:17Z fall inside this lane's step-14 Jest run (17:07:04–17:11:55Z, `s3-integration-validation/logs/14`), and `release_verifiers_discovered.txt` names a Prisma verify.sql — consistent with a targeted release/readiness test writing fixed scratch, but no test log line ties these exact paths to that run. Recorded as plausible only.

## Not done
No worktree/index/module/source/private-checkout write, tests, install, DB, network, lock, signal, new audit, other `/tmp` entries. The unchanged S3 composed one-shot still needs its own explicit activation on a free slot with fresh root `s3-composed-proof-result-02`; this lane cannot and did not activate it.

## Correction (17:36Z, disclosed, not relabelled)
The packet seal step ran `chmod -R a-w .`, which briefly set the five preserved files to mode 444 (bytes, inode, owner, mtime untouched). Mode was restored to the original 644 on those five files immediately; their ctime reflects this. `sha256sum -c files.sha256` re-verified identical bytes. Receipt/manifest files remain read-only.
