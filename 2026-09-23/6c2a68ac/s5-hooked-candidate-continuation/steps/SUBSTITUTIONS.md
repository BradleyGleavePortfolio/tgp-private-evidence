# Mechanical substitutions frozen before step 07 (grant 2686f427 §Remaining 07–10)
Derived from logs/06F-format-spec.log (raw 0): NEW_TREE=756a0d7966c9125749339abbcfd681eb7e713ede; NEW_PARENT_DIFF_SHA256=2c92a96464238d88bfe4acb9dbe5e17400f5e51d154e1c1b99c8612b373746df (preimage/new-two-file-parent.patch); spec numstat 971/356; bootstrap numstat 34/4 unchanged.
| file | original (prep e9f4a5d5) | substitution |
|---|---|---|
| 07-identity-and-hooked-commit.cmd | expected staged tree 3d30aeb0… (guard exit 92) | 756a0d79… |
| 08-post-commit-identity.cmd | `%T` 3d30aeb0…; `diff --quiet 3d30aeb0 HEAD^{tree}` (+label) | 756a0d79… |
| 08-post-commit-identity.cmd | parent-diff sha256 c36258b3… (label "frozen patch bytes") | 2c92a964… (label "06F-recorded full two-file diff") |
| 08-post-commit-identity.cmd | numstat `16\t0` spec | `971\t356` spec |
Unchanged: parent 143d451e, bootstrap numstat 34/4, two paths, author/committer, message file `$P/steps/07-commit-message.txt` (1da44908…), quoted `%(trailers)`, `%B` handling, porcelain/untracked 0, banned tokens, detached, refs, gpgsig. 09/10 run the ORIGINAL prep command files byte-for-byte through the new step.sh (O exported to the continuation root). Reproducible diffs: *.cmd.diff-vs-original, step.sh.diff-vs-original.
