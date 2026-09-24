#!/bin/bash
cd /home/user/workspace/worktrees/ux03b-correlation
R=/home/user/workspace/execution/cf8ff737/ux03b/receipts
exec 9>/home/user/workspace/execution/test-validation.lock
if ! flock -n 9; then echo "LOCK BUSY" > $R/10-lock.txt; exit 99; fi
echo "LOCK ACQUIRED $(date -u +%FT%TZ) write-tree $(git write-tree)" > $R/10-lock.txt
npx tsc --noEmit > $R/11-tsc.log 2>&1; rc=$?; echo "tsc exit=$rc" >> $R/11-tsc.log
if [ $rc -ne 0 ]; then echo "STOP tsc rc=$rc" >> $R/10-lock.txt; exit $rc; fi
npx eslint src/types/extensionImport.ts src/types/__tests__/extensionImport.contract.test.ts src/api/extensionPairApi.ts src/api/__tests__/extensionPairApi.test.ts src/storage/importPairingMirror.ts src/storage/__tests__/importPairingMirror.test.ts src/hooks/useExtensionPairing.ts src/hooks/__tests__/useExtensionPairing.test.tsx --max-warnings=99999 > $R/12-lint.log 2>&1; rc=$?; echo "eslint exit=$rc" >> $R/12-lint.log
if [ $rc -ne 0 ]; then echo "STOP lint rc=$rc" >> $R/10-lock.txt; exit $rc; fi
CI=true npx jest src/types/__tests__/extensionImport.contract.test.ts src/api/__tests__/extensionPairApi.test.ts src/storage/__tests__/importPairingMirror.test.ts src/hooks/__tests__/useExtensionPairing.test.tsx src/hooks/__tests__/useExtensionPairing.identityWait.test.tsx src/components/coach/__tests__/ExtensionPairingPanel src/screens/coach/__tests__/ImportDataScreen > $R/13-jest.log 2>&1; rc=$?; echo "jest exit=$rc" >> $R/13-jest.log
echo "jest rc=$rc; gates done $(date -u +%FT%TZ)" >> $R/10-lock.txt
exit $rc
