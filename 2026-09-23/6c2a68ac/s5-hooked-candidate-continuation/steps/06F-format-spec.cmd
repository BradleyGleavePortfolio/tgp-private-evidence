source $P/steps/chk.sh
SPEC=test/rls-g2-pg17-etq0.spec.ts; BOOT=test/utils/g2-pg17-bootstrap.sh
# 1. reassert original staged tree / spec hash; save preimage and original parent diff
eq "staged tree before" 3d30aeb08c58d47b53837dfe22b60f8dbef37871 "$(git write-tree)"
eq "staged spec sha256 before" 01f3cfc09a700f1b3c76625774d08b37cdcc407453515e635cc0e7c2c7bac25d "$(git show :$SPEC | sha256sum | cut -c1-64)"
eq "worktree spec == staged" 01f3cfc09a700f1b3c76625774d08b37cdcc407453515e635cc0e7c2c7bac25d "$(sha256sum $SPEC | cut -c1-64)"
git show :$SPEC > $O/preimage/rls-g2-pg17-etq0.spec.ts.staged-01f3cfc0; git diff --cached HEAD > $O/preimage/original-two-file.patch
eq "saved original parent diff sha256" c36258b39d0c92f0b760f11982a61427c6e7cce963eecffe2554f447346c5491 "$(sha256sum $O/preimage/original-two-file.patch | cut -c1-64)"
[ "$FAIL" = 0 ] || { echo "preassertion failed; formatter NOT run"; exit 80; }
# 2. one formatting pass with the pinned CLI directly
node "$TOOL/node_modules/prettier/bin/prettier.cjs" --write $SPEC; w=$?; echo "prettier --write raw exit=$w"
eq "prettier --write raw" 0 "$w"
# 3. exact expected bytes
eq "formatted spec sha256" 338defe8c68834b8f6e23df58547a7b6830c673bcb540a7985823532ee66a430 "$(sha256sum $SPEC | cut -c1-64)"
[ "$FAIL" = 0 ] || { echo "unexpected formatter output; stopping, nothing staged"; exit 81; }
# 4. --check once, raw status preserved
node "$TOOL/node_modules/prettier/bin/prettier.cjs" --check $SPEC; c=$?; echo "prettier --check raw exit=$c"
eq "prettier --check raw" 0 "$c"
[ "$FAIL" = 0 ] || { echo "check failed after write; stopping, nothing staged"; exit 82; }
# 5. formatting-only delta vs preserved index 3d30; nothing else changed
git diff > $O/preimage/formatting-only-vs-index-3d30.patch; echo "formatting-only diff sha256=$(sha256sum $O/preimage/formatting-only-vs-index-3d30.patch | cut -c1-64) numstat=$(git diff --numstat | tr '\t' '/')"
eq "only the spec differs from index" "$SPEC" "$(git diff --name-only)"
eq "no untracked beyond ignored" 0 "$(git status --porcelain --untracked-files=all | grep -c '^??')"
eq "bootstrap blob/mode unchanged (index)" "100755 85a636ba75607604032cef7af1d285cb198ca263 0	$BOOT" "$(git ls-files -s $BOOT)"
eq "bootstrap worktree bytes == staged blob" 85a636ba75607604032cef7af1d285cb198ca263 "$(git hash-object $BOOT)"
eq "lock unchanged" b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55 "$(sha256sum package-lock.json | cut -c1-64)"
eq "original patch still archived (result492f)" c36258b39d0c92f0b760f11982a61427c6e7cce963eecffe2554f447346c5491 "$(sha256sum /home/user/workspace/tgp-private-evidence/2026-09-22/remediation/s5-r4/checkpoint-1/s5-r4-dirty-from-143d451e.patch | cut -c1-64)"
[ "$FAIL" = 0 ] || { echo "side-effect check failed; stopping, nothing staged"; exit 83; }
# 6. stage only the spec; record new exact tree / full parent diff / numstat
git add -- $SPEC; a=$?; echo "git add raw exit=$a"; eq "git add raw" 0 "$a"
echo "NEW_TREE=$(git write-tree)"
echo "NEW_SPEC_BLOB=$(git ls-files -s $SPEC)"
echo "NEW_PARENT_DIFF_SHA256=$(git diff --cached HEAD | sha256sum | cut -c1-64)"; git diff --cached HEAD > $O/preimage/new-two-file-parent.patch
echo "NEW_NUMSTAT_BEGIN"; git diff --cached --numstat HEAD; echo "NEW_NUMSTAT_END"
eq "two changed paths" $'test/rls-g2-pg17-etq0.spec.ts\ntest/utils/g2-pg17-bootstrap.sh' "$(git diff --cached --name-only HEAD)"
eq "bootstrap numstat unchanged" "34	4	$BOOT" "$(git diff --cached --numstat HEAD -- $BOOT)"
eq "status" $'M  test/rls-g2-pg17-etq0.spec.ts\nM  test/utils/g2-pg17-bootstrap.sh' "$(git status --porcelain)"
chk "worktree == index" git diff --quiet
eq "staged spec == formatted bytes" 338defe8c68834b8f6e23df58547a7b6830c673bcb540a7985823532ee66a430 "$(git show :$SPEC | sha256sum | cut -c1-64)"
eq "lock blob unchanged" 354de3dae19449970497da6e4d87f0a1225a8f43 "$(git ls-files -s package-lock.json | awk '{print $2}')"
eq "HEAD unchanged" 143d451ead6ccdbebd92ca3031ba7a89867d6cfc "$(git rev-parse HEAD)"
exit $FAIL
