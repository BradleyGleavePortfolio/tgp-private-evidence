# Why this checkpoint is a dirty patch, not a commit

`lefthook.yml` pre-commit runs `node scripts/check-r75.js --mode=staged`, `npx tsc --noEmit`, `npx eslint … {staged_files}`, `npx prettier --check {staged_files}`, `scripts/prod-readiness-precheck.sh --quick`; commit-msg runs the R3 banned-token scan. In this fresh sandbox: `lefthook` binary absent, `.git/hooks/pre-commit` absent (`prepare: lefthook install` never ran), `node_modules` absent → tsc/eslint/prettier cannot run natively. Committing now would silently bypass every hook (nothing installed to run), which the brief forbids as much as `--no-verify`.

Precise dependency to produce the frozen commit: one granted `execution/s5-r4/npm-ci.sh` under the canonical lock (network `npm ci --ignore-scripts`, lock blob 354de3da), then `./node_modules/.bin/lefthook install` in the worktree, then `git add test/rls-g2-pg17-etq0.spec.ts test/utils/g2-pg17-bootstrap.sh && git commit` with the message below; verify `git log -1 --format='%an <%ae> | %cn <%ce>'` and no trailers. Expected hook cost: tsc full project (~1–3 min), eslint/prettier on 2 files, R75 staged check (test-only files; no cast tokens added), prod-readiness quick precheck.

Proposed commit message (no banned tokens):
`test(g2-pg17): gate fixture teardown behind accepted setup and enforce generated-client provenance`

Body: teardown authority flag set after the last read-only gate and before the first GRANT (refused setup issues no DDL/DML; partial authorized setup still cleans up); bootstrap hashes the runtime each generated client actually loads, enforces engine equality for both clients and fails on any missing provenance file.
