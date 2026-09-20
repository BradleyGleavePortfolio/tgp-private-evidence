#!/usr/bin/env bash
# Offline probe of scripts/release.sh verifier discovery/contract behaviour.
# Uses a fake `npx` (records prisma argv; configurable verifier outcome) and synthetic
# prisma/migrations trees in a temp dir. No database, no network. Serial, seconds.
# Usage: p03-release-verifiers.sh <worktree-root>
set -u
ROOT=$(cd "${1:-.}" && pwd)
TD=$(mktemp -d); trap 'rm -rf "$TD"' EXIT
mkdir -p "$TD/bin"
cat >"$TD/bin/npx" <<'NPX'
#!/usr/bin/env bash
# fake npx: log argv; emulate prisma migrate status / deploy / db execute
echo "$*" >>"${FAKE_NPX_LOG}"
case "$*" in
  *"migrate status"*) echo "Database schema is up to date!"; exit 0;;
  *"migrate deploy"*) echo "deploy-ran" >>"${FAKE_NPX_LOG}"; echo "No pending migrations to apply."; exit 0;;
  *"db execute --stdin"*) echo " count"; echo " 3"; exit 0;;
  *"db execute --url"*)
      all="$*"; f="${all##*--file }"
      if grep -q "RAISE_FAIL" "$f"; then echo "Error: P1010 S1-DB-01 VERIFY FAILED (drift)"; exit 1; fi
      echo "Script executed successfully."; exit 0;;
  *) exit 0;;
esac
NPX
chmod +x "$TD/bin/npx"
cat >"$TD/bin/node" <<'N'
#!/usr/bin/env bash
echo v20.20.1
N
chmod +x "$TD/bin/node"
pass=0; fail=0
run_case() { # name expected_exit expect_deploy(yes|no) setup-fn
  local name=$1 want=$2 want_deploy=$3 setup=$4
  local W="$TD/case-$name"; rm -rf "$W"; mkdir -p "$W/scripts" "$W/prisma/migrations"
  cp "$ROOT/scripts/release.sh" "$W/scripts/release.sh"
  cp "$ROOT/scripts/release-required-verifiers.txt" "$W/scripts/release-required-verifiers.txt" 2>/dev/null || echo "  (no contract file at root — predecessor)"
  export FAKE_NPX_LOG="$W/npx.log"; : >"$FAKE_NPX_LOG"
  ( cd "$W" && $setup )
  ( cd "$W" && PATH="$TD/bin:$PATH" DATABASE_URL=postgres://fake DIRECT_URL=postgres://fake-direct HOME="$TD" \
      bash scripts/release.sh >"$W/out.log" 2>&1 ); local got=$?
  local deployed=no; grep -q '^deploy-ran$' "$FAKE_NPX_LOG" && deployed=yes
  local verdict=PASS
  [[ "$got" == "$want" ]] || verdict=FAIL
  [[ "$deployed" == "$want_deploy" ]] || verdict=FAIL
  printf '%-44s exit=%s (want %s) migrate-deploy-ran=%s (want %s) => %s\n' "$name" "$got" "$want" "$deployed" "$want_deploy" "$verdict"
  if [[ $verdict == PASS ]]; then pass=$((pass+1)); else fail=$((fail+1)); fi
  echo "  ---- tail of release output:"; grep -E '\[release\] (step|  verif|REQUIRED|required|catalog|Refusing|verifier|✔|❌|prisma/migrations|Deploy ABORTED)' "$W/out.log" | sed 's/^/  | /' | tail -n 8
}
S1=20261224000000_rls_close_public_exposure
setup_happy() { mkdir -p "prisma/migrations/$S1"; echo "-- ok verifier" >"prisma/migrations/$S1/verify.sql"; mkdir -p prisma/migrations/20260101000000_other; echo "-- ok" >prisma/migrations/20260101000000_other/verify.sql; }
setup_required_missing() { mkdir -p prisma/migrations/20260101000000_other; echo "-- ok" >prisma/migrations/20260101000000_other/verify.sql; }
setup_zero_verifiers() { mkdir -p prisma/migrations/20260101000000_other; echo "-- migration only" >prisma/migrations/20260101000000_other/migration.sql; }
setup_no_migrations_dir() { rm -rf prisma/migrations; }
setup_migrations_is_file() { rm -rf prisma/migrations; echo x >prisma/migrations; }
setup_unreadable_subdir() { setup_happy; mkdir -p prisma/migrations/zz_locked/inner; chmod 000 prisma/migrations/zz_locked; }
setup_contract_missing() { setup_happy; rm scripts/release-required-verifiers.txt; }
setup_contract_empty() { setup_happy; printf '# only comments\n\n' >scripts/release-required-verifiers.txt; }
setup_contract_traversal() { setup_happy; printf '../../etc\n' >scripts/release-required-verifiers.txt; mkdir -p etc; echo "-- x" >etc/verify.sql; }
setup_contract_slash() { setup_happy; printf '%s/verify.sql\n' "$S1" >scripts/release-required-verifiers.txt; }
setup_contract_duplicate() { setup_happy; printf '%s\n%s\n' "$S1" "$S1" >scripts/release-required-verifiers.txt; }
setup_contract_glob() { setup_happy; printf '*\n' >scripts/release-required-verifiers.txt; }
setup_verifier_raises() { setup_happy; echo "RAISE_FAIL" >"prisma/migrations/$S1/verify.sql"; }
setup_second_verifier_raises() { setup_happy; echo "RAISE_FAIL" >prisma/migrations/20260101000000_other/verify.sql; }
setup_verifier_dir_not_file() { setup_happy; rm "prisma/migrations/$S1/verify.sql"; mkdir "prisma/migrations/$S1/verify.sql"; }
setup_crlf_contract() { setup_happy; printf '%s\r\n' "$S1" >scripts/release-required-verifiers.txt; }

echo "release.sh probe at $(git -C "$ROOT" rev-parse HEAD 2>/dev/null) ($(date -u +%FT%TZ)) root=$ROOT"
run_case happy-path-required-present            0 yes setup_happy
run_case required-verifier-missing              1 no  setup_required_missing
run_case zero-verifiers-in-tree                 1 no  setup_zero_verifiers
run_case migrations-dir-absent                  1 no  setup_no_migrations_dir
run_case migrations-is-a-file                   1 no  setup_migrations_is_file
run_case discovery-error-unreadable-subdir      1 no  setup_unreadable_subdir
run_case contract-file-missing                  1 no  setup_contract_missing
run_case contract-file-empty                    1 no  setup_contract_empty
run_case contract-entry-traversal               1 no  setup_contract_traversal
run_case contract-entry-with-slash              1 no  setup_contract_slash
run_case contract-entry-duplicate               1 no  setup_contract_duplicate
run_case contract-entry-glob                    1 no  setup_contract_glob
run_case contract-entry-crlf                    1 no  setup_crlf_contract
run_case required-verifier-is-a-directory       1 no  setup_verifier_dir_not_file
run_case required-verifier-RAISEs               1 yes setup_verifier_raises
run_case other-discovered-verifier-RAISEs       1 yes setup_second_verifier_raises
chmod -R u+rwx "$TD" 2>/dev/null
echo "pass=$pass fail=$fail"
[[ $fail -eq 0 ]]
