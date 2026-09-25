#!/usr/bin/env bash
# EXEC-DACEDDC8 S8C-BC-5: export the committed harness+spec-correction head as checkpoint v7 (same shape as v6).
# Git reads, bundle creation and hashes only. Refuses an existing v7, a dirty tree, or a wrong lineage/delta.
# Lineage: 87018a42 (v5 candidate) -> e0cee7e0 (bootstrap fix, v6) -> 9cc76401 (harness) -> 4d7d4b4e (spec 3 sites) -> HEAD (spec baseline)
# Usage: export-v7-daceddc8.sh <committed-head-sha>
set -euo pipefail
S=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8c; V7=$S/checkpoints/v7
W=/home/user/workspace/worktrees/64e33dc7-s8c; BASE=93389265a846095b846fa8f1fb0dad782fb6ee9f
P0=87018a421f5be1064767d2cdd32e75ca935f7cdb; P1=e0cee7e04bef88811310f6dde1fd921f45d103ad; P2=9cc764013fd1d726dad082eebfa7def50800a6b2; P3=4d7d4b4ebdb7df2af593bbd809f7df23775fdf29
H=${1:?committed head}; BOOT=test/utils/g2-s8c-bootstrap.sh; HARN=test/utils/g2-s8c-harness.ts; SPEC=test/rls-g2-s8c.spec.ts
[ -e "$V7" ] && { echo "REFUSED: $V7 exists" >&2; exit 1; }
cd "$W"; [ "$(git rev-parse HEAD)" = "$H" ] && [ "$(git rev-parse HEAD^)" = "$P3" ] && [ "$(git rev-parse HEAD~2)" = "$P2" ] && [ "$(git rev-parse HEAD~3)" = "$P1" ] && [ "$(git rev-parse HEAD~4)" = "$P0" ] || { echo "REFUSED: lineage" >&2; exit 1; }
[ -z "$(git status --porcelain --untracked-files=all)" ] || { echo "REFUSED: dirty" >&2; exit 1; }
[ "$(git diff-tree --no-commit-id -r --name-only "$P1" "$H" | sort | tr '\n' ' ')" = "$SPEC $HARN " ] || { echo "REFUSED: delta from e0cee7e0 is not exactly harness+spec" >&2; exit 1; }
[ "$(git diff-tree --no-commit-id -r --name-only "$P0" "$H" | sort | tr '\n' ' ')" = "$SPEC $BOOT $HARN " ] || { echo "REFUSED: delta from 87018a42 is not exactly bootstrap+harness+spec" >&2; exit 1; }
mkdir -p "$V7"; S7=$(git rev-parse --short=8 "$H")
git bundle create "$V7/s8c-$S7.bundle" "$BASE..exec64/s8c-replacement" 2>"$V7/bundle-create.log"
git bundle verify "$V7/s8c-$S7.bundle" >"$V7/bundle-verify.log" 2>&1
git diff --name-status "$P1" "$H" > "$V7/CHANGED_PATHS_from_e0cee7e0.txt"
git diff --name-status "$P0" "$H" > "$V7/CHANGED_PATHS_from_87018a42.txt"
git diff --name-status "$BASE" "$H" > "$V7/CHANGED_PATHS_from_base.txt"
git format-patch --stdout "$P1..$H" > "$V7/e0cee7e0..HEAD.patch"
{ echo "BASE=$BASE"; echo "LINEAGE=$P0 -> $P1 -> $P2 -> $P3 -> $H"; echo "HEAD=$H"; echo "TREE=$(git rev-parse 'HEAD^{tree}')"
  for c in "$P2" "$P3" "$H"; do echo "COMMIT $c author=$(git log -1 --format='%an <%ae>' "$c") committer=$(git log -1 --format='%cn <%ce>' "$c") date=$(git log -1 --format=%cI "$c") subject=$(git log -1 --format=%s "$c")"; done
  echo "PORCELAIN=$(git status --porcelain --untracked-files=all | wc -l)"
  echo "BOOTSTRAP_BLOB=$(git rev-parse HEAD:$BOOT) BOOTSTRAP_MODE=$(git ls-tree HEAD $BOOT | cut -d' ' -f1) (unchanged since e0cee7e0: $([ "$(git rev-parse HEAD:$BOOT)" = "$(git rev-parse $P1:$BOOT)" ] && echo yes || echo NO))"
  echo "HARNESS_BLOB=$(git rev-parse HEAD:$HARN) (was $(git rev-parse $P1:$HARN) at e0cee7e0)"
  echo "SPEC_BLOB=$(git rev-parse HEAD:$SPEC) (was $(git rev-parse $P1:$SPEC) at e0cee7e0)"
  echo "PRISMA_TREE_UNCHANGED_FROM_87018a42=$([ "$(git rev-parse HEAD:prisma)" = "$(git rev-parse $P0:prisma)" ] && echo yes || echo NO)"
  echo "SRC_TREE_UNCHANGED_FROM_87018a42=$([ "$(git rev-parse HEAD:src)" = "$(git rev-parse $P0:src)" ] && echo yes || echo NO)"
  echo "DOCS_CONTRACTS_UNCHANGED_FROM_87018a42=$([ "$(git rev-parse HEAD:docs/contracts)" = "$(git rev-parse $P0:docs/contracts)" ] && echo yes || echo NO)"
  echo "EXPORTED_BY=execution/daceddc8 T4 builder s8c_bootstrap_completion $(date -u +%FT%TZ)"; } > "$V7/HEAD.txt"
(cd "$V7" && sha256sum CHANGED_PATHS_from_e0cee7e0.txt CHANGED_PATHS_from_87018a42.txt CHANGED_PATHS_from_base.txt e0cee7e0..HEAD.patch HEAD.txt "s8c-$S7.bundle" > MANIFEST.sha256)
cat "$V7/HEAD.txt" "$V7/bundle-verify.log" "$V7/MANIFEST.sha256"
