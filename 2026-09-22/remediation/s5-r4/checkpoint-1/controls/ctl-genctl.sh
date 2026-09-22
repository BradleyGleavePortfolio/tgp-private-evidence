#!/usr/bin/env bash
# S5 R4 control: genctl refusal-class discrimination (A-05, runner part). NOT EXECUTED by the builder.
# Requires S5_CTL_GRANT=granted-by-parent. Budget: <= 20 s wall. No DB, no network, no npm: the derived
# runner's genctl stage is driven with a FAKE prisma CLI whose exit code and stderr are scripted.
#   G1 intended refusal (rc 1 + "Could not resolve @prisma/client") -> negative accepted, positive
#      resolution checked against the fake pinned package -> GENCTL_OK, PROOF_EXIT=0.
#   G2 rc 1 with an unrelated message -> GENCTL_FAIL (not the intended refusal class), PROOF_EXIT=3.
#   G3 rc 2 (e.g. schema error) -> GENCTL_FAIL, PROOF_EXIT=3.
#   G4 rc 0 (generation "succeeded" without a resolvable client) -> GENCTL_FAIL, PROOF_EXIT=3.
#   Predecessor reference (static, not run): checkpoint-5 run-proof.sh:283-286 accepted any nonzero rc,
#   so G2 and G3 would have passed there; see REPORT.md.
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
control_preconditions
make_control_root
trap 'control_cleanup' EXIT
S="$CR/X/s5-r4"; LOGS="$S/logs"
# genctl's positive path resolves @prisma/client from $G2_PG17_OLD_CLIENT (= $S/old-root-925780e0/.g2-old-client)
# and compares it with the resolution from $W. Fake old root: node_modules symlink to the fake W tree.
mkdir -p "$S/old-root-925780e0/.g2-old-client"; ln -s "$CR/W/node_modules" "$S/old-root-925780e0/node_modules"

scenario() { # <id> <exit> <stderr> <expected_proof_exit> <expected_marker>
  sleep 1.1
  printf '%s %s\n' "$2" "$3" > "$CR/scenario/prisma"
  run_derived genctl; rc=$?
  local E R; E="$(latest exit-genctl-)"; R="$(latest run-genctl-)"
  check "$1.rc" "$( [ "$rc" = "$4" ] && [ "$(exit_field "$E" PROOF_EXIT)" = "$4" ]; echo $? )" "fake prisma rc=$2 '$3' -> runner rc=$rc (expected $4)"
  check "$1.marker" "$( grep -q "$5" "$R"; echo $? )" "run log carries $5"
  check "$1.no_install_artefacts" "$( [ ! -e /tmp/package.json ] && ! ls -d /tmp/s5-genctl-*/node_modules >/dev/null 2>&1; echo $? )" "no package.json/node_modules created under /tmp"
}
scenario G1 1 "Error: Could not resolve @prisma/client." 0 GENCTL_OK
scenario G2 1 "Error: something unrelated failed" 3 "GENCTL_FAIL negative control failed for a reason other than the intended missing-client refusal"
scenario G3 2 "Error: schema parsing error" 3 "GENCTL_FAIL negative control exited 2, not the intended refusal class"
scenario G4 0 "" 3 "GENCTL_FAIL negative control exited 0, not the intended refusal class"
# The runner leaves its mktemp scratch dirs (/tmp/s5-genctl-*) as evidence; the control removes only those it caused.
for d in /tmp/s5-genctl-*; do [ -d "$d" ] && [ "$(stat -c %Y "$d")" -ge "$(stat -c %Y "$CR")" ] && rm -rf "$d"; done
summary
