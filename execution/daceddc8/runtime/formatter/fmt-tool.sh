#!/usr/bin/env bash
# EXEC-64E33DC7 FORMATTER_TOOLING_GRANT: restore exactly prettier@3.9.9 as an isolated npm-global-layout tool prefix.
# The canonical lock is taken with flock -n on fd9 IN THIS PROCESS and held until exit (no separate holder).
# Only commands: registry metadata read, tarball fetch + integrity verify, offline install of the verified local tarball
# into the prefix, `prettier --version` (direct and via `npx --no-install` resolution). No formatting/test/compile/PG.
# No donor, builder worktree, platform node_modules or project/lockfile writes.
# Usage: timeout -k 30 600 bash fmt-tool.sh
set -uo pipefail
EVD=/home/user/workspace/tgp-private-evidence/execution/daceddc8/runtime/formatter; R=$EVD/raw
LOG=$R/fmt-tool.log; SENT=$R/fmt-tool.sentinel
ROOT=/home/user/workspace/execution/64e33dc7/recovery-reset
LOCK=/home/user/workspace/execution/test-validation.lock
PFX=$ROOT/tools/prettier-3.9.9
DL=$ROOT/tools/download/prettier-3.9.9; CACHE=$ROOT/tools/npm-cache-prettier-3.9.9
DONOR=/home/user/workspace/worktrees/64e33dc7-env
VER=3.9.9; EXPECT_TARBALL=https://registry.npmjs.org/prettier/-/prettier-3.9.9.tgz
REC_LAUNCHER=6e922134a3c76fd4de202959bb6aef50bde0c994148075003a15569b7197906e   # recorded bin/prettier.cjs (compare only)
mkdir -p "$R"
[ -e "$SENT" ] && { echo "REFUSED: $SENT exists (do not loop)" >&2; exit 76; }
ts(){ date -u +%FT%TZ; }; log(){ echo "$*" | tee -a "$LOG"; }; sha(){ sha256sum "$1" | cut -c1-64; }
procs(){ ps -eo pid,comm,args --no-headers | awk '$2 ~ /^(postgres|postmaster|pg_ctl|initdb|jest|tsc|npm|npx|prisma|prettier|lefthook)$/ || $0 ~ /(jest|tsc|prisma|pg_ctl|postgres|prettier)/' | grep -v -e awk -e fmt-tool -e 'ps -eo' || true; }
nmsig(){ find /home/user/node_modules -maxdepth 2 -printf '%p %s %T@\n' 2>/dev/null | sort | sha256sum | cut -c1-64; }
donorsig(){ echo "hidden_lock=$(sha "$DONOR/node_modules/.package-lock.json") nm_top=$(ls -1 "$DONOR/node_modules" | wc -l) bin_prettier=$([ -e "$DONOR/node_modules/.bin/prettier" ] && echo PRESENT || echo absent) status=[$(git -C "$DONOR" status --porcelain --untracked-files=all)] head=$(git -C "$DONOR" rev-parse HEAD)"; }
STAGE=preflight
log "PRE $(ts) lock_file=$([ -e "$LOCK" ] && echo present || echo absent)"
P=$(procs); log "PRE relevant_processes=[${P:-none}]"
[ -z "$P" ] || { log "REFUSED: relevant live process"; echo "RC=74 STAGE=preflight END=$(ts)" >"$SENT"; exit 74; }
exec 9>>"$LOCK"; flock -n 9 || { log "REFUSED: canonical lock busy ($LOCK)"; exit 75; }
finish(){ echo "RC=$1 STAGE=$STAGE END=$(ts)" >"$SENT"; log "END rc=$1 stage=$STAGE $(ts) (fd9 released on exit)"; exit "$1"; }
log "START $(ts) pid=$$ lock=$LOCK held nonblocking by this driver process on fd9 (inode $(stat -c %i "$LOCK")); holders: $(lslocks -n -o PID,PATH 2>/dev/null | grep test-validation | tr -s ' ' || echo n/a)"
[ -e "$PFX" ] && { log "REFUSED: $PFX exists; not deleting"; finish 70; }
NM_BEFORE=$(nmsig); DONOR_BEFORE=$(donorsig)
log "platform_nm_before entries=$(ls -1 /home/user/node_modules | wc -l) sig=$NM_BEFORE"; log "donor_before $DONOR_BEFORE"
log "node=$(node --version) npm=$(npm --version)"
export npm_config_cache=$CACHE npm_config_update_notifier=false npm_config_fund=false npm_config_audit=false
mkdir -p "$DL" "$CACHE"
# ---- registry metadata (exact version document)
STAGE=metadata
timeout --foreground 60 curl -fsS -H 'Accept: application/json' -o "$R/registry-prettier-3.9.9.json" "https://registry.npmjs.org/prettier/$VER"; rc=$?
log "curl_metadata_exit=$rc url=https://registry.npmjs.org/prettier/$VER sha256=$([ -f "$R/registry-prettier-3.9.9.json" ] && sha "$R/registry-prettier-3.9.9.json")"; [ $rc = 0 ] || finish $rc
M=$(node -e 'const d=require(process.argv[1]);console.log([d.name,d.version,d.dist.tarball,d.dist.integrity,d.dist.shasum,Object.keys(d.dependencies||{}).length,JSON.stringify((d.scripts||{}))].join("\t"))' "$R/registry-prettier-3.9.9.json") || finish 70
IFS=$'\t' read -r M_NAME M_VER M_TAR M_INT M_SHA1 M_DEPS M_SCRIPTS <<<"$M"
log "meta name=$M_NAME version=$M_VER tarball=$M_TAR integrity=$M_INT shasum=$M_SHA1 dependencies=$M_DEPS scripts=$M_SCRIPTS"
[ "$M_NAME" = prettier ] && [ "$M_VER" = "$VER" ] && [ "$M_TAR" = "$EXPECT_TARBALL" ] || { log "BLOCKER: metadata name/version/tarball disagree"; finish 70; }
case "$M_INT" in sha512-*) ;; *) log "BLOCKER: no sha512 integrity in metadata"; finish 70;; esac
timeout --foreground 60 npm view "prettier@$VER" version dist.tarball dist.integrity dist.shasum --json >"$R/npm-view-prettier-3.9.9.json" 2>&1; rc=$?
log "npm_view_exit=$rc $(tr -d '\n ' <"$R/npm-view-prettier-3.9.9.json")"; [ $rc = 0 ] || finish $rc
node -e 'const v=require(process.argv[1]);process.exit(v.version===process.argv[2]&&v["dist.integrity"]===process.argv[3]&&v["dist.tarball"]===process.argv[4]&&v["dist.shasum"]===process.argv[5]?0:1)' "$R/npm-view-prettier-3.9.9.json" "$VER" "$M_INT" "$M_TAR" "$M_SHA1" || { log "BLOCKER: npm view disagrees with registry document"; finish 70; }
log "npm_view_agrees=yes"
# ---- tarball fetch + integrity
STAGE=tarball
TGZ=$DL/prettier-$VER.tgz
timeout --foreground 120 curl -fsSL -o "$TGZ" "$M_TAR"; rc=$?; log "curl_tarball_exit=$rc bytes=$(stat -c %s "$TGZ" 2>/dev/null)"; [ $rc = 0 ] || finish $rc
GOT_INT="sha512-$(openssl dgst -sha512 -binary "$TGZ" | base64 -w0)"; GOT_SHA1=$(sha1sum "$TGZ" | cut -c1-40)
log "tarball_integrity=$GOT_INT match=$([ "$GOT_INT" = "$M_INT" ] && echo yes || echo NO) sha1=$GOT_SHA1 match=$([ "$GOT_SHA1" = "$M_SHA1" ] && echo yes || echo NO) sha256=$(sha "$TGZ")"
[ "$GOT_INT" = "$M_INT" ] && [ "$GOT_SHA1" = "$M_SHA1" ] || { log "BLOCKER: tarball integrity disagrees with registry metadata"; finish 70; }
mkdir -p "$DL/extract" && tar -xzf "$TGZ" -C "$DL/extract" || finish 70
log "tarball_package_json_version=$(node -p "require('$DL/extract/package/package.json').version")"
# ---- offline install of the verified tarball into the isolated npm-global-layout prefix
STAGE=install
timeout --foreground 300 npm install --global --prefix "$PFX" --offline --no-audit --no-fund --foreground-scripts "$TGZ" >"$R/npm-install.out" 2>&1; rc=$?
cat "$R/npm-install.out" >>"$LOG"; log "npm_install_exit=$rc"; [ $rc = 0 ] || finish $rc
PK=$PFX/lib/node_modules/prettier
log "installed_version=$(node -p "require('$PK/package.json').version") bin_link=$(readlink "$PFX/bin/prettier") -> $(readlink -f "$PFX/bin/prettier")"
[ "$(node -p "require('$PK/package.json').version")" = "$VER" ] || { log "BLOCKER: installed version != $VER"; finish 70; }
diff -r "$DL/extract/package" "$PK" >"$R/diff-tarball-vs-installed.txt" 2>&1; rc=$?
log "installed_tree_vs_verified_tarball diff_exit=$rc (0 = byte-identical; raw/diff-tarball-vs-installed.txt)"; [ $rc = 0 ] || { log "BLOCKER: installed files differ from verified tarball"; finish 70; }
L=$(sha "$PK/bin/prettier.cjs"); log "bin/prettier.cjs sha256=$L recorded=$REC_LAUNCHER match=$([ "$L" = "$REC_LAUNCHER" ] && echo yes || echo NO) package.json sha256=$(sha "$PK/package.json")"
( cd "$PFX" && find . \( -type f -o -type l \) -printf '%y %p %l\n' | sort ) >"$R/prefix-entries.txt"
( cd "$PFX" && find . -type f -print0 | sort -z | xargs -0 sha256sum ) >"$R/prefix-files.sha256"
log "prefix_files=$(wc -l <"$R/prefix-files.sha256") prefix_manifest_sha256=$(sha "$R/prefix-files.sha256") prefix_entries_sha256=$(sha "$R/prefix-entries.txt")"
# ---- version command only (direct, then genuine npx resolution via npm_config_prefix, offline, from neutral dir)
STAGE=version
V1=$("$PFX/bin/prettier" --version 2>&1); rc=$?; log "direct: $PFX/bin/prettier --version -> '$V1' exit=$rc"; [ $rc = 0 ] && [ "$V1" = "$VER" ] || finish 70
cd "$ROOT/tools" || finish 70
V2=$(env npm_config_prefix="$PFX" npm_config_offline=true npx --no-install prettier --version 2>&1); rc=$?
log "npx: (cwd=$ROOT/tools npm_config_prefix=$PFX npm_config_offline=true) npx --no-install prettier --version -> '$V2' exit=$rc"; [ $rc = 0 ] && [ "$V2" = "$VER" ] || finish 70
# ---- unchanged checks
STAGE=verify
NM_AFTER=$(nmsig); DONOR_AFTER=$(donorsig)
log "platform_nm_after sig=$NM_AFTER unchanged=$([ "$NM_BEFORE" = "$NM_AFTER" ] && echo yes || echo NO)"
log "donor_after $DONOR_AFTER unchanged=$([ "$DONOR_BEFORE" = "$DONOR_AFTER" ] && echo yes || echo NO)"
P=$(procs); log "post_relevant_processes=[${P:-none}]"
STAGE=done; finish 0
