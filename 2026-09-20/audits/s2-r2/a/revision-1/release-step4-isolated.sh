set -Eeuo pipefail
echo "[release] step 4: running catalog verifiers (prisma/migrations/*/verify.sql)..."
VERIFIER_COUNT=0
VERIFIER_LOG=/home/user/workspace/execution/audits/s2-r2/a/prisma_verifier.log
: >"${VERIFIER_LOG}"
while IFS= read -r verifier; do
  [[ -n "${verifier}" ]] || continue
  VERIFIER_COUNT=$((VERIFIER_COUNT + 1))
  echo "[release]   verifier: ${verifier}"
  if ! npx prisma db execute --url "${DIRECT_URL}" --file "${verifier}" >>"${VERIFIER_LOG}" 2>&1; then
    echo "[release] catalog verifier FAILED: ${verifier}"
    sed 's/^/[release]   /' "${VERIFIER_LOG}" | tail -n 40
    echo "[release] Refusing to mark this release green (schema drift or incomplete migration)."
    exit 1
  fi
done < <(find prisma/migrations -mindepth 2 -maxdepth 2 -name verify.sql -type f | LC_ALL=C sort)
echo "[release]   verifiers_passed = ${VERIFIER_COUNT}"

