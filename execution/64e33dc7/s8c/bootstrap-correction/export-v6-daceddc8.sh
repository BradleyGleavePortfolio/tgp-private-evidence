#!/usr/bin/env bash
# EXEC-DACEDDC8 S8C-BC-2: export the committed bootstrap-correction head as checkpoint v6 (same shape as v5).
# Git reads, bundle creation and hashes only. Refuses an existing v6, a dirty tree, or a wrong parent/delta.
# Usage: export-v6-daceddc8.sh <committed-head-sha>
set -euo pipefail
S=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c; V6=$S/checkpoints/v6
W=/home/user/workspace/worktrees/64e33dc7-s8c; BASE=93389265a846095b846fa8f1fb0dad782fb6ee9f
PARENT=87018a421f5be1064767d2cdd32e75ca935f7cdb; H=${1:?committed head}; FILE=test/utils/g2-s8c-bootstrap.sh
[ -e "$V6" ] && { echo "REFUSED: $V6 exists" >&2; exit 1; }
cd "$W"; [ "$(git rev-parse HEAD)" = "$H" ] && [ "$(git rev-parse HEAD^)" = "$PARENT" ] || { echo "REFUSED: head/parent" >&2; exit 1; }
[ -z "$(git status --porcelain --untracked-files=all)" ] || { echo "REFUSED: dirty" >&2; exit 1; }
[ "$(git diff-tree --no-commit-id -r --name-only "$PARENT" "$H")" = "$FILE" ] || { echo "REFUSED: delta" >&2; exit 1; }
mkdir -p "$V6"; S7=$(git rev-parse --short=8 "$H")
git bundle create "$V6/s8c-$S7.bundle" "$BASE..exec64/s8c-replacement" 2>"$V6/bundle-create.log"
git bundle verify "$V6/s8c-$S7.bundle" >"$V6/bundle-verify.log" 2>&1
git diff --name-status "$PARENT" "$H" > "$V6/CHANGED_PATHS_from_87018a42.txt"
git diff --name-status "$BASE" "$H" > "$V6/CHANGED_PATHS_from_base.txt"
git format-patch -1 --stdout "$H" > "$V6/HEAD.patch"
{ echo "BASE=$BASE"; echo "PARENT=$PARENT (tree $(git rev-parse "$PARENT^{tree}"))"; echo "HEAD=$H"; echo "TREE=$(git rev-parse 'HEAD^{tree}')"
  echo "AUTHOR=$(git log -1 --format='%an <%ae>')"; echo "COMMITTER=$(git log -1 --format='%cn <%ce>')"; echo "DATE=$(git log -1 --format=%cI)"
  echo "SUBJECT=$(git log -1 --format=%s)"; echo "PORCELAIN=$(git status --porcelain --untracked-files=all | wc -l)"
  echo "BOOTSTRAP_BLOB=$(git rev-parse HEAD:$FILE) BOOTSTRAP_MODE=$(git ls-tree HEAD $FILE | cut -d' ' -f1)"
  echo "PRISMA_TREE_UNCHANGED_FROM_PARENT=$([ "$(git rev-parse HEAD:prisma)" = "$(git rev-parse $PARENT:prisma)" ] && echo yes || echo NO)"
  echo "SRC_TREE_UNCHANGED_FROM_PARENT=$([ "$(git rev-parse HEAD:src)" = "$(git rev-parse $PARENT:src)" ] && echo yes || echo NO)"
  echo "DOCS_CONTRACTS_UNCHANGED_FROM_PARENT=$([ "$(git rev-parse HEAD:docs/contracts)" = "$(git rev-parse $PARENT:docs/contracts)" ] && echo yes || echo NO)"
  echo "EXPORTED_BY=execution/daceddc8 parent operator $(date -u +%FT%TZ)"; } > "$V6/HEAD.txt"
(cd "$V6" && sha256sum CHANGED_PATHS_from_87018a42.txt CHANGED_PATHS_from_base.txt HEAD.patch HEAD.txt "s8c-$S7.bundle" > MANIFEST.sha256)
cat "$V6/HEAD.txt" "$V6/bundle-verify.log" "$V6/MANIFEST.sha256"
