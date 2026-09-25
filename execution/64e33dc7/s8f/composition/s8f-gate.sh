#!/usr/bin/env bash
# S8F-COMP-1 phase 2 gate (parent mail 2026-09-25 18:06Z). Runs ONLY under the canonical heavy slot, taken
# nonblocking in this process (fd 9, append-open, never deleted). Stops at the first failure; nothing is retried.
# Steps: preflight -> cp -a donor node_modules -> contract regen + cold-process determinism -> scoped prettier 3.9.9
# (offline prefix) -> scoped eslint -> tsc (heap 4096) -> affected Jest (import closure U fs-pinned specs, L2-2) ->
# one genuine hooked Bradley commit (lefthook pre-commit + commit-msg). No push. No PG. No proof.
set -uo pipefail
W=/home/user/workspace/worktrees/daceddc8-s8f
E=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/s8f/composition
R=$E/gates
LOCK=/home/user/workspace/execution/test-validation.lock
LOCK_INODE=674373
PARENT=1c10e2a19b35bbb4fb17fe7c5aab6fa613e74c47
BRANCH=exec-dace/s8f
DONOR=/home/user/workspace/worktrees/daceddc8-land-s8-c/node_modules
NM_LOCK_SHA256=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44
CLIENT_SHA256=9042e713ba5678c99959a345b7b18a60dfc186b2c7d890b8d9c3ed5c8f4edcc6
CLIENT_SCHEMA_SHA256=b84392033ab86776533007505c31f57930307a210844067a7407ed20d25abf3e
PFX=/home/user/workspace/execution/64e33dc7/recovery-reset/s8c/tools/prettier-3.9.9
PFX_MANIFEST=/home/user/workspace/tgp-private-evidence/execution/64e33dc7/runtime/formatter/raw/prefix-files.sha256
CONTRACT=docs/contracts/importer-openapi.json
FS_RE="prisma/migrations|['\"/]migrations['\"]|docs/contracts|importer-openapi|EXPECTED_MIGRATIONS|BASE_HEAD"
S8F_PATHS=(
  src/scout/scout-entities.controller.ts
  src/scout/scout-entities.dto.ts
  src/scout/scout-entities.service.ts
  src/scout/scout-roster.controller.ts
  src/scout/scout-roster.dto.ts
  src/scout/scout-roster.service.ts
  test/scout/entities/scout-entities.contract.spec.ts
  test/scout/entities/scout-entities.service.spec.ts
  test/scout/roster/scout-roster.controller.spec.ts
  test/scout/roster/scout-roster.service.spec.ts
  test/rls-g2-s8f.spec.ts
  test/scout/g2-s8f-db-guard.spec.ts
  test/utils/g2-s8f-bootstrap.sh
  test/utils/g2-s8f-db.ts
  test/utils/g2-s8f-pg-harness.ts
  test/contracts/importer-contract.spec.ts
)
COMMIT_PATHS=("${S8F_PATHS[@]}" "$CONTRACT")
TS_PATHS=(); for p in "${S8F_PATHS[@]}"; do case "$p" in *.ts) TS_PATHS+=("$p");; esac; done
PRETTIER_PATHS=("${TS_PATHS[@]}" "$CONTRACT")

mkdir -p "$R"; LOG=$R/s8f-gate.log
ts(){ date -u +%FT%TZ; }; log(){ echo "$(ts) $*" | tee -a "$LOG"; }
die(){ log "STOP rc=$1 stage=$2 $3"; log "RELEASING (fd9 closes at exit; lock file preserved)"; echo "RC=$1 STAGE=$2 END=$(ts)" >"$R/s8f-gate.sentinel"; exit "$1"; }
[ "${S8F_GATE_RELAY:-}" = 1 ] || { echo "REFUSED: relay flag" >&2; exit 70; }
[ -e "$R/s8f-gate.sentinel" ] && { echo "REFUSED: sentinel exists (once-only)" >&2; exit 70; }
[ -e "$LOCK" ] || { echo "REFUSED: lock file absent" >&2; exit 75; }
[ "$(stat -c %i "$LOCK")" = "$LOCK_INODE" ] || { echo "REFUSED: lock inode $(stat -c %i "$LOCK") != $LOCK_INODE" >&2; exit 75; }
exec 9>>"$LOCK"; flock -n 9 || { echo "REFUSED: lock busy (live holder); yielding" >&2; exit 75; }
log "ACQUIRED pid=$$ fd9 inode=$(stat -c %i "$LOCK") postgres=$(pgrep -c -x postgres || true) heavy=$(pgrep -af 'jest|tsc|prisma|prettier|lefthook' | grep -v -e "$$" -e s8f-gate | wc -l)"

# ---------- 0. preflight ----------
cd "$W" || die 71 pre "cd"
[ "$(git rev-parse HEAD)" = "$PARENT" ] || die 71 pre "HEAD is not $PARENT"
[ "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH" ] || die 71 pre "branch is not $BRANCH"
[ ! -e node_modules ] || die 71 pre "node_modules already present"
CHANGED=$( (git diff --name-only; git diff --cached --name-only; git ls-files --others --exclude-standard) | sort -u)
EXPECT=$(printf '%s\n' "${S8F_PATHS[@]}" | sort -u)
[ "$CHANGED" = "$EXPECT" ] || die 71 pre "delta is not exactly the 16 prepared paths: [$(echo "$CHANGED" | tr '\n' ' ')]"
[ -z "$(git diff --cached --name-only)" ] || die 71 pre "index not empty"
for p in "${S8F_PATHS[@]}"; do sha256sum "$p"; done >"$R/pre-gate-source.sha256"
CONTRACT_BEFORE=$(sha256sum "$CONTRACT" | cut -c1-64); log "PRE contract_before=$CONTRACT_BEFORE blob=$(git rev-parse HEAD:$CONTRACT)"
( cd "$PFX" && sha256sum -c --quiet "$PFX_MANIFEST" ) >"$R/prefix-verify.log" 2>&1 || die 71 pre "prettier prefix manifest check failed"
[ "$(wc -l <"$PFX_MANIFEST")" = 56 ] || die 71 pre "prefix manifest not 56"
[ "$(readlink "$PFX/bin/prettier")" = ../lib/node_modules/prettier/bin/prettier.cjs ] || die 71 pre "prettier bin link"
[ "$(sha256sum /usr/local/bin/node | cut -c1-64)" = a03953a7b16bff002b94d6fb58ada900b68241cbcaee6efc400b20dadd36dddc ] || die 71 pre "node binary sha"
log "PREFLIGHT ok head=$PARENT branch=$BRANCH node=$(node -v) delta=16 paths"

# ---------- 1. runtime: cp -a donor node_modules ----------
[ -d "$DONOR" ] && [ ! -L "$DONOR" ] || die 72 runtime "donor missing"
[ "$(sha256sum "$DONOR/.package-lock.json" | cut -c1-64)" = "$NM_LOCK_SHA256" ] || die 72 runtime "donor hidden lock"
[ "$(sha256sum "$DONOR/.prisma/client/index.d.ts" | cut -c1-64)" = "$CLIENT_SHA256" ] || die 72 runtime "donor client"
[ "$(sha256sum "$DONOR/.prisma/client/schema.prisma" | cut -c1-64)" = "$CLIENT_SCHEMA_SHA256" ] || die 72 runtime "donor client schema"
timeout -k 30 900 cp -a "$DONOR" "$W/node_modules" || die 72 runtime "cp -a"
[ "$(sha256sum node_modules/.package-lock.json | cut -c1-64)" = "$NM_LOCK_SHA256" ] || die 72 runtime "copied hidden lock"
[ "$(sha256sum node_modules/.prisma/client/index.d.ts | cut -c1-64)" = "$CLIENT_SHA256" ] || die 72 runtime "copied client"
[ "$(sha256sum node_modules/.prisma/client/schema.prisma | cut -c1-64)" = "$CLIENT_SCHEMA_SHA256" ] || die 72 runtime "copied client schema"
export NODE_OPTIONS=--max-old-space-size=4096 npm_config_prefix="$PFX" npm_config_offline=true \
       npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false PRISMA_HIDE_UPDATE_MESSAGE=1
export GIT_AUTHOR_NAME='Bradley Gleave' GIT_AUTHOR_EMAIL='bradley@bradleytgpcoaching.com' \
       GIT_COMMITTER_NAME='Bradley Gleave' GIT_COMMITTER_EMAIL='bradley@bradleytgpcoaching.com'
V=$(npx --no-install prettier --version 2>>"$LOG"); [ "$V" = 3.9.9 ] || die 72 runtime "npx prettier is '$V'"
log "RUNTIME node_modules=$NM_LOCK_SHA256 client=$CLIENT_SHA256 prettier=$V heap=4096 entries=$(ls node_modules | wc -l)"

# ---------- 2. contract regeneration (unchanged generator) + cold-process determinism ----------
timeout -k 10 900 npm run -s contract:importer >"$R/contract-regen-1.log" 2>&1; rc=$?
CONTRACT_AFTER=$(sha256sum "$CONTRACT" | cut -c1-64)
log "CONTRACT_REGEN_1 rc=$rc before=$CONTRACT_BEFORE after=$CONTRACT_AFTER stat=$(git diff --numstat -- "$CONTRACT" | cut -f1,2 | tr '\t' /)"
[ $rc = 0 ] || die 73 contract "generator failed (see contract-regen-1.log)"
git diff -- "$CONTRACT" >"$R/contract-delta.patch"
git show "HEAD:$CONTRACT" >"$R/contract-before.json"
SCRATCH=$R/contract-scratch.json
IMPORTER_CONTRACT_OUT=$SCRATCH timeout -k 10 900 npm run -s contract:importer >"$R/contract-regen-2.log" 2>&1; rc=$?
[ $rc = 0 ] && cmp -s "$SCRATCH" "$CONTRACT" || die 73 contract "second cold-process regeneration differs rc=$rc"
node -e '
const fs=require("fs"); const a=JSON.parse(fs.readFileSync(process.argv[1],"utf8")), b=JSON.parse(fs.readFileSync(process.argv[2],"utf8"));
const s=x=>x.components.schemas, keys=o=>Object.keys(o.properties||{}).sort();
const out={version:[a.info.version,b.info.version], paths:[Object.keys(a.paths).length,Object.keys(b.paths).length],
 schemas:[Object.keys(s(a)).length,Object.keys(s(b)).length],
 entity_before:keys(s(a).ReconstructedEntityDto), entity_after:keys(s(b).ReconstructedEntityDto),
 roster_before:keys(s(a).ScoutRosterResult), roster_after:keys(s(b).ScoutRosterResult),
 family_enum:b.paths["/api/scout/reconstruct/entities"].get.parameters.find(p=>p.name==="family").schema.enum,
 target_kind:s(b).ReconstructedEntityDto.properties.target_kind, native_id:s(b).ReconstructedEntityDto.properties.native_id,
 bridge:s(b).ScoutRosterResult.properties.roster_bridge_pending};
console.log(JSON.stringify(out,null,1));
const same=(x,y)=>JSON.stringify(x)===JSON.stringify(y);
const ok = out.version[0]===out.version[1] && out.paths[0]===out.paths[1] && out.schemas[0]===out.schemas[1]
 && same(out.entity_after,[...out.entity_before,"native_id","target_kind"].sort())
 && same(out.roster_after,[...out.roster_before,"roster_bridge_pending"].sort())
 && same(out.target_kind.enum,["scout_entity","workout_program","workout_plan"]) && out.native_id.nullable===true && out.bridge.type==="boolean";
process.exit(ok?0:1);' "$R/contract-before.json" "$CONTRACT" >"$R/contract-semantic-check.json" 2>&1; rc=$?
log "CONTRACT_SEMANTIC rc=$rc (see contract-semantic-check.json)"; [ $rc = 0 ] || die 73 contract "artifact delta is not the expected additive S8-F delta"
# only the expected file set changed
CHANGED=$( (git diff --name-only; git ls-files --others --exclude-standard) | sort -u)
[ "$CHANGED" = "$(printf '%s\n' "${COMMIT_PATHS[@]}" | sort -u)" ] || die 73 contract "generator touched unexpected paths: [$(echo "$CHANGED" | tr '\n' ' ')]"
log "CONTRACT deterministic; artifact sha=$CONTRACT_AFTER"

# ---------- 3. scoped prettier 3.9.9 ----------
npx --no-install prettier --check "${PRETTIER_PATHS[@]}" >"$R/prettier-check-1.log" 2>&1; rc=$?; log "PRETTIER_CHECK_1 rc=$rc"
if [ $rc != 0 ]; then
  for p in "${PRETTIER_PATHS[@]}"; do cp -p "$p" "$R/.pre-prettier.$(echo "$p" | tr / _)"; done
  npx --no-install prettier --write "${PRETTIER_PATHS[@]}" >"$R/prettier-write.log" 2>&1; rc=$?; log "PRETTIER_WRITE rc=$rc"; [ $rc = 0 ] || die 74 prettier "write failed"
  : >"$R/prettier-format-delta.patch"
  for p in "${PRETTIER_PATHS[@]}"; do diff -u "$R/.pre-prettier.$(echo "$p" | tr / _)" "$p" >>"$R/prettier-format-delta.patch"; done
  rm -f "$R"/.pre-prettier.*
  npx --no-install prettier --check "${PRETTIER_PATHS[@]}" >"$R/prettier-check-2.log" 2>&1; rc=$?; log "PRETTIER_CHECK_2 rc=$rc delta_lines=$(wc -l <"$R/prettier-format-delta.patch")"
  [ $rc = 0 ] || die 74 prettier "still unformatted after write"
  [ "$(sha256sum "$CONTRACT" | cut -c1-64)" = "$CONTRACT_AFTER" ] || die 74 prettier "prettier rewrote the generated artifact"
fi

# ---------- 4. scoped eslint ----------
timeout -k 30 900 ./node_modules/.bin/eslint --no-warn-ignored --max-warnings 0 "${TS_PATHS[@]}" >"$R/eslint.log" 2>&1; rc=$?; log "ESLINT rc=$rc"
[ $rc = 0 ] || die 75 eslint "see eslint.log"

# ---------- 5. tsc ----------
timeout -k 30 1500 ./node_modules/.bin/tsc --noEmit >"$R/tsc.log" 2>&1; rc=$?; log "TSC rc=$rc lines=$(wc -l <"$R/tsc.log")"
[ $rc = 0 ] || die 76 tsc "see tsc.log"

# ---------- 6. affected Jest: import closure U fs-pinned default-config specs (L2-2) ----------
./node_modules/.bin/jest --listTests 2>>"$LOG" | sed "s|^$PWD/||" | sort -u >"$R/default-config-specs.txt" || die 79 jest "listTests"
[ -s "$R/default-config-specs.txt" ] || die 79 jest "listTests empty"
sort -u "$E/import-closure-specs.txt" | comm -12 - "$R/default-config-specs.txt" >"$R/closure-default.txt"
rg -l -e "$FS_RE" --glob '*.spec.ts' src test | sort -u | comm -12 - "$R/default-config-specs.txt" >"$R/fs-pinned-specs.txt"
sort -u "$R/closure-default.txt" "$R/fs-pinned-specs.txt" >"$R/affected-suites.txt"
mapfile -t SUITES <"$R/affected-suites.txt"
for s in "${SUITES[@]}"; do [ -f "$s" ] || die 79 jest "suite missing: $s"; done
log "AFFECTED closure=$(wc -l <"$R/closure-default.txt") fs-pinned=$(wc -l <"$R/fs-pinned-specs.txt") union=${#SUITES[@]}"
timeout -k 30 2400 ./node_modules/.bin/jest --ci --runTestsByPath "${SUITES[@]}" >"$R/jest-affected.raw.log" 2>&1; rc=$?
log "JEST rc=$rc $(grep -E '^(Test Suites|Tests):' "$R/jest-affected.raw.log" | tr '\n' ' ')"
[ $rc = 0 ] || die 79 jest "affected Jest failed (raw log preserved)"
grep -E '^Tests:.*skipped' "$R/jest-affected.raw.log" && log "NOTE skipped tests present (see raw log)"
CHANGED=$( (git diff --name-only; git ls-files --others --exclude-standard) | sort -u)
[ "$CHANGED" = "$(printf '%s\n' "${COMMIT_PATHS[@]}" | sort -u)" ] || die 79 jest "a gate modified unexpected paths: [$(echo "$CHANGED" | tr '\n' ' ')]"
for p in "${COMMIT_PATHS[@]}"; do sha256sum "$p"; done >"$R/pre-commit-source.sha256"

# ---------- 7. one genuine hooked commit ----------
git add -- "${COMMIT_PATHS[@]}" || die 80 commit "git add"; log "STAGED_TREE=$(git write-tree)"
[ "$(git diff --cached --name-only | sort)" = "$(printf '%s\n' "${COMMIT_PATHS[@]}" | sort)" ] || die 80 commit "staged set differs"
timeout -k 30 1800 git commit -F "$E/commit-message.txt" >"$R/commit.raw.log" 2>&1; rc=$?
log "COMMIT rc=$rc hook_lines=$(grep -cE '✔️|🥊|❌' "$R/commit.raw.log")"; [ $rc = 0 ] || die 80 commit "hooked commit failed; see commit.raw.log (no --no-verify, no rerun)"
HEAD=$(git rev-parse HEAD); [ "$(git rev-parse HEAD^)" = "$PARENT" ] || die 80 commit "parent is not $PARENT"
[ "$(git log -1 --format='%an <%ae>|%cn <%ce>')" = 'Bradley Gleave <bradley@bradleytgpcoaching.com>|Bradley Gleave <bradley@bradleytgpcoaching.com>' ] || die 80 commit "identity"
[ -z "$(git status --porcelain --untracked-files=all)" ] || die 80 commit "porcelain not clean after commit"
{ echo "HEAD=$HEAD"; echo "TREE=$(git rev-parse 'HEAD^{tree}')"; echo "PARENT=$PARENT"; echo "BRANCH=$BRANCH";
  git log -1 --format='AUTHOR=%an <%ae>%nCOMMITTER=%cn <%ce>%nDATE=%cI%nSUBJECT=%s' HEAD;
  echo "FILES=$(git diff-tree --no-commit-id -r --name-only "$PARENT" "$HEAD" | wc -l)";
  for p in "${COMMIT_PATHS[@]}"; do echo "BLOB $(git rev-parse "HEAD:$p") $(git ls-tree HEAD "$p" | cut -c1-6) $p"; done;
  echo "CONTRACT_SHA256=$(sha256sum "$CONTRACT" | cut -c1-64)"; echo "SCHEMA_BLOB=$(git rev-parse HEAD:prisma/schema.prisma)";
  echo "MIGRATIONS_TRACKED=$(find prisma/migrations -mindepth 1 -maxdepth 1 -type d | wc -l)"; } >"$R/HEAD.txt"
log "HEAD=$HEAD tree=$(git rev-parse 'HEAD^{tree}') parent=$PARENT files=$(git diff-tree --no-commit-id -r --name-only "$PARENT" "$HEAD" | wc -l)"
echo "RC=0 STAGE=done END=$(ts) HEAD=$HEAD LOCK_INODE=$(stat -c %i "$LOCK")" >"$R/s8f-gate.sentinel"
log "RELEASED $(ts) (fd9 closes at exit; lock file preserved)"
