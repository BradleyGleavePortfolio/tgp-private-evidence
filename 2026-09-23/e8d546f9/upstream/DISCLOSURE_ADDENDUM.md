# UPSTREAM-RESTORE — disclosure addendum (additive; REPORT.md revision 1 and logs stay frozen and unchanged)

Correction requested by parent 2026-09-23 ~00:58Z. REPORT.md §3/§4 say "file existence only" and "no runtime/probe/process action". That statement is exact for the product/candidate/control surface but under-describes the read-only tool-metadata and process-observation commands that P5 (and P1–P4 footers) actually ran. Exact list:

| When (UTC) | Command(s) that ran | Scope | Class |
|---|---|---|---|
| 00:51–00:53 (P1, P4 footer) | `git` read/verify commands on the new standalone repo and the baseline: `rev-parse`, `status --porcelain`, `ls-files`, `cat-file --batch-check`, `fsck --connectivity-only`, `diff --quiet`, `merge-base`, `for-each-ref`, `count-objects`, `worktree list`; plus `checkout --force --detach` inside the NEW restoration repo only | worktrees/s2-runner53; source/backend read-only | Git metadata read; one repo-local checkout write in the restoration target |
| 00:53:20–22 (P4) | `git init --bare`, `read-tree`, `apply --cached`, `write-tree`, `update-ref`, `diff-tree`, `ls-tree`, `cat-file -p` in the isolated odb | execution/e8d546f9/upstream/odb-prep2-verify (alternates → baseline objects, read-only) | Git object reproduction; no product checkout |
| 00:54:08 (P5) | `[ -e path ]` existence tests for every pinned path | workspace + /home/user/pg17 + /usr/bin/psql | file existence only |
| 00:54:08 (P5) | `timeout --version`, `flock --version`, `setsid --version`, `pgrep --version`, `git --version`, `command -v node && node --version`, `command -v npm && npm --version`, `sha256sum --version`, `getconf CLK_TCK`, `$BASH_VERSION` | system tools only | read-only tool-version metadata (node/npm executed with `--version` only; no package, script or product code run) |
| 00:54:08 and 00:54:2x (P5 + follow-up) | `pgrep -fc/-fa 'run-composition|s2r5|stub|s2-fixture|postgres|psql|prisma|jest'` (the 4 matches were the census shell itself; excluding `pgrep` → 0); `df -h`, `free -m`, `nproc` | process table / resource observation | read-only process observation; nothing signalled |

Not run at any point in the restoration lane: any product source, runner, driver, stub, fixture, harness, discriminator, psql/postgres/prisma/npm install or script, network access, DB, hook, commit, lock open/creation, or process signal. The canonical lock file was still absent at the end of the restoration lane (00:54Z); it was later created by the granted `check-lock.sh` probe at 00:56:17Z under the separate setup grant, reported in `execution/e8d546f9/s2-setup-result/`.

Effect on conclusions: none. The restored identities in REPORT.md §1–§2 rest solely on the Git and sha256 verifications listed above; the tool-version/census lines were observations for the grant receipt, exactly as upstream-prereqs-2 §1 item 3–4 did, and were time-bound (re-observed at setup preflight 00:55:59Z).

Setup grant outcomes are reported separately and are NOT part of this restoration lane's claims: see `execution/e8d546f9/s2-setup-result/` (S10 raw 0, S20 raw 0 at time of writing; S30 running).
