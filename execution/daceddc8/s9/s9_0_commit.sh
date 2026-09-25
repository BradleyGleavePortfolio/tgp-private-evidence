#!/usr/bin/env bash
# S9-0 docs-only hooked commit under the canonical slot (inode 674373). Polls at 60 s, never steals.
set -u
LOCK=/home/user/workspace/execution/test-validation.lock
W=/home/user/workspace/worktrees/daceddc8-land-s8-c
REL=docs/decisions/2026-09-25-s9-reconciliation.md
WANT=cda68d826be08e5bf5cd1152ecbb092b10dfc373c7234bd73943815d0d07bab1
OUT=/home/user/workspace/tgp-private-evidence/execution/daceddc8/s9/s9_0_commit
mkdir -p "$OUT"
LOG="$OUT/hook.log"
exec 9>>"$LOCK"
[ "$(stat -c %i "$LOCK")" = "674373" ] || { echo "lock inode mismatch" > "$OUT/RESULT"; exit 70; }
n=0
until flock -n 9; do
  n=$((n+1)); echo "$(date -u +%FT%TZ) busy (attempt $n); yielding 60s" >> "$OUT/poll.log"; sleep 60
done
echo "$(date -u +%FT%TZ) acquired after $n busy polls" >> "$OUT/poll.log"
cd "$W" || exit 71
fail() { echo "$1" > "$OUT/RESULT"; echo "$(date -u +%FT%TZ) released (fail: $1)" >> "$OUT/poll.log"; exit "${2:-1}"; }
[ "$(git rev-parse HEAD)" = "1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47" ] || fail "HEAD moved" 72
[ "$(git branch --show-current)" = "exec-dace/s9-0b" ] || fail "branch mismatch" 73
[ "$(git status --porcelain --untracked-files=all)" = "?? $REL" ] || fail "tree not as expected" 74
PRE=$(sha256sum "$REL" | cut -d' ' -f1); echo "pre-stage sha256 $PRE" > "$OUT/shas.txt"
[ "$PRE" = "$WANT" ] || fail "pre-stage sha mismatch" 75
git add -- "$REL"
STAGED=$(git show ":$REL" | sha256sum | cut -d' ' -f1); echo "staged sha256 $STAGED" >> "$OUT/shas.txt"
[ "$STAGED" = "$WANT" ] || fail "staged sha mismatch" 76
[ "$(git diff --cached --name-only)" = "$REL" ] || fail "index not docs-only" 77
MSG='docs(scout): S9-0 reconciliation decision (verdict predicate, report v1, reason codes)

Records the S9 native reconciliation contract: the family-complete verdict
predicate with required families and a recorded completeness basis, report
and coverage manifest v1 recomputed on read with no table, the verified
union only for native counts, the ceiling case as partial with blocked
reserved for revoked, additive low-cardinality reason codes, the S9-A/B/C
seam and paths, and acceptance cases R01-R19.'
LEFTHOOK_VERBOSE=0 git commit -q -F - <<<"$MSG" > "$LOG" 2>&1
RC=$?
echo "commit rc=$RC" >> "$OUT/shas.txt"
if [ $RC -ne 0 ]; then
  WT=$(sha256sum "$REL" | cut -d' ' -f1); echo "worktree sha256 after failed commit $WT" >> "$OUT/shas.txt"
  fail "commit failed rc=$RC" 78
fi
POST=$(sha256sum "$REL" | cut -d' ' -f1); echo "post-commit worktree sha256 $POST" >> "$OUT/shas.txt"
BLOB=$(git show "HEAD:$REL" | sha256sum | cut -d' ' -f1); echo "committed blob sha256 $BLOB" >> "$OUT/shas.txt"
[ "$POST" = "$WANT" ] && [ "$BLOB" = "$WANT" ] || fail "post-commit sha mismatch (committed at $(git rev-parse HEAD))" 79
git log -1 --format='head %H%ntree %T%nparent %P%nauthor %an <%ae> %aI%ncommitter %cn <%ce> %cI%n' > "$OUT/commit.txt"
git ls-tree HEAD -- "$REL" >> "$OUT/commit.txt"
git show --stat --format= HEAD >> "$OUT/commit.txt"
git log -1 --format=%B >> "$OUT/message.txt"
git status --porcelain --untracked-files=all > "$OUT/status_after.txt"
echo "OK $(git rev-parse HEAD)" > "$OUT/RESULT"
echo "$(date -u +%FT%TZ) released (ok)" >> "$OUT/poll.log"
