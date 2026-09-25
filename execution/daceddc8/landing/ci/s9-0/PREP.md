# LAND-3 prep: S9-0 docs fast-forward (standing by for the relayed sha)

**Grant:** LAND-3, pre-granted in the parent mail at 18:14Z.

1. Push the S9-0 sha as `land/s9-0`.
2. Open a PR to `integration/importer`.
3. Wait for green CI.
4. Fast-forward `integration/importer` from `1c10e2a1` to the sha, only if the remote is still `1c10e2a1`.
5. Verify, and record `ci/s9-0/LANDED.md`.

**Tool:** `scripts/land-ff.sh`, a generic fast-forward lander. It was syntax-checked and has not been run yet.

**Stage command:**

```
SLUG=s9-0 HEAD_SHA=<relayed> EXPECTED_TIP=1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47 \
  TITLE="Land S9-0: <decision doc title> (<short>)" ALLOWED_PATH_RE='^docs/' bash scripts/land-ff.sh stage
```

`stage` refuses unless all of these hold:
- the sha descends from `1c10e2a1`;
- there are no merges in the range;
- every commit has Bradley as author and committer, with no trailers and no banned tokens;
- every path is under `docs/`;
- the remote tip is `1c10e2a1`;
- `land/s9-0` is absent.

**Land command:** `SLUG=s9-0 bash scripts/land-ff.sh ff`. It reads only `state/ff-s9-0.env`, then:
- checks CI with `check_pr_ci`;
- re-checks the remote tip;
- makes one ordinary push;
- verifies with ls-remote and `gh api`;
- confirms `main` is untouched.

**Expected CI**, since docs-only changes trigger no Migration Dry-Run: the 9-check set seen on #540. That is CI ×4, npm audit, H4 ×3 (deploy-readiness-gate skips) and size-label.

**State at 18:15Z:**
- remote `integration/importer` is `1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47`;
- `land/s9-0` does not exist;
- worktree `daceddc8-land-s8-c` has been handed off and is not used here.
