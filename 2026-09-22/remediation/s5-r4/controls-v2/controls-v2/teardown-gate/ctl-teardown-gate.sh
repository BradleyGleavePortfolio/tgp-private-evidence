#!/usr/bin/env bash
# S5 R4 control: Jest-level teardown gate (A-01) under REAL installed jest-circus hook semantics with a
# FAKE recording harness. NOT EXECUTED by the builder. Dependency: the candidate worktree's node_modules
# (jest 29 + ts-jest + typescript) from a separately granted `npm-ci.sh` under the canonical lock; this
# control itself takes NO lock, opens NO connection, spawns NO psql, installs nothing (npx is never used).
# Requires S5_CTL_GRANT=granted-by-parent. Budget: <= 120 s wall (4 jest runs, each ~10-20 s cold).
#   T1 candidate, refused-identity  -> zero mutating calls in setup AND teardown; PG17_TEARDOWN_SKIPPED
#   T2 candidate, refused-prestate  -> zero mutating calls (164/E-absent gate fails after identity)
#   T3 candidate, authorized-partial-> GRANT then failing ALTER in setup; teardown STILL runs its
#                                      DROP CONSTRAINT / resetData / DELETE ScoutImport (cleanup preserved)
#   T0 PREDECESSOR spec (143d451e), refused-identity -> mutating teardown calls recorded (frozen defect)
# Jest's own exit is EXPECTED nonzero (beforeAll throws -> all cases error); it is recorded, never a pass.
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"
control_preconditions
W=$CANDIDATE_WORKTREE
[ -x "$W/node_modules/.bin/jest" ] && [ -d "$W/node_modules/ts-jest" ] || { log "REFUSE: $W/node_modules (jest, ts-jest) absent; this control needs the granted npm-ci first"; exit 2; }
CR="$(mktemp -d /tmp/s5-r4-gate-XXXXXX)"; export CR; trap '[ "${S5_CTL_KEEP:-}" = 1 ] || rm -rf "$CR"' EXIT
mkdir -p "$CR/test/utils" "$CR/fakeroot/node_modules/.prisma/client" "$CR/fakeroot/oldroot/src/scout" "$CR/fakeroot/oldclient"
cp "$W/test/rls-g2-pg17-etq0.spec.ts" "$CR/test/candidate.spec.ts"
git -C "$W" show 143d451ead6ccdbebd92ca3031ba7a89867d6cfc:test/rls-g2-pg17-etq0.spec.ts > "$CR/test/predecessor.spec.ts"
cp "$W/test/utils/g2-pg17-db.ts" "$CR/test/utils/g2-pg17-db.ts"          # real marker module (pure)
cp "$CTL_DIR/teardown-gate/fake-harness.ts" "$CR/test/utils/g2-pg17-harness.ts"
cp "$CTL_DIR/teardown-gate/jest.control.config.js" "$CR/jest.config.js"
ln -s "$W/node_modules" "$CR/node_modules"
printf 'model ScoutReconstructionLedger {\n  id String\n}\n' > "$CR/fakeroot/oldclient/schema.prisma"
printf 'model ScoutReconstructionLedger {\n  id String\n  source_platform String?\n}\n' > "$CR/fakeroot/node_modules/.prisma/client/schema.prisma"
for f in scout-reconstruct.service.ts scout-roster.service.ts scout-entities.service.ts; do printf 'fake O service source\n' > "$CR/fakeroot/oldroot/src/scout/$f"; done
log "GATE_CONTROL_ROOT $CR candidate_spec_sha256=$(sha256sum "$CR/test/candidate.spec.ts" | cut -c1-64) predecessor_spec_sha256=$(sha256sum "$CR/test/predecessor.spec.ts" | cut -c1-64) fake_harness_sha256=$(sha256sum "$CR/test/utils/g2-pg17-harness.ts" | cut -c1-64)"
run_gate() { # <id> <spec> <scenario>
  local rec="$OUT/gate-$CTL_TS-$1.jsonl" out="$OUT/gate-$CTL_TS-$1.jest.log"; : > "$rec"
  ( cd "$CR" && env -i PATH="/usr/local/bin:/usr/bin:/bin" HOME="$CR" G2_CTL_ROOT="$CR" G2_CTL_RECORD="$rec" G2_CTL_FAKEROOT="$CR/fakeroot" G2_CTL_SCENARIO="$3" NODE_OPTIONS=--max-old-space-size=2048 \
      "$W/node_modules/.bin/jest" --config "$CR/jest.config.js" --runInBand "test/$2" ) > "$out" 2>&1; local rc=$?
  log "$1 jest_rc=$rc (expected nonzero: beforeAll throws) record=$rec"
  GATE_RC=$rc
}
mut() { grep -c '"mutating":true' "$1"; }
run_gate T1 candidate.spec.ts refused-identity; r=$GATE_RC; R="$OUT/gate-$CTL_TS-T1.jsonl"
check T1.zero_mutation "$( [ "$(mut "$R")" = 0 ] && [ "$(wc -l < "$R")" -ge 1 ]; echo $? )" "candidate refused-identity: $(mut "$R") mutating calls of $(wc -l < "$R") recorded (expected 0)"
check T1.skipped_marker "$( grep -q PG17_TEARDOWN_SKIPPED "$OUT/gate-$CTL_TS-T1.jest.log"; echo $? )" "PG17_TEARDOWN_SKIPPED emitted by afterAll"
check T1.jest_failed "$( [ "$r" != 0 ]; echo $? )" "jest exit $r recorded (setup refusal must not look like a passing suite)"
run_gate T2 candidate.spec.ts refused-prestate; r=$GATE_RC; R="$OUT/gate-$CTL_TS-T2.jsonl"
check T2.zero_mutation "$( [ "$(mut "$R")" = 0 ] && grep -q '_prisma_migrations' "$R"; echo $? )" "candidate refused-prestate (165/E present): $(mut "$R") mutating calls (expected 0); identity gates were reached"
check T2.skipped_marker "$( grep -q PG17_TEARDOWN_SKIPPED "$OUT/gate-$CTL_TS-T2.jest.log"; echo $? )" "PG17_TEARDOWN_SKIPPED emitted"
run_gate T3 candidate.spec.ts authorized-partial; r=$GATE_RC; R="$OUT/gate-$CTL_TS-T3.jsonl"
check T3.setup_partial "$( grep -q '"mutating":true.*GRANT USAGE' "$R" && grep -q 'ADD CONSTRAINT g2p_target_refusal' "$R"; echo $? )" "authorized setup began (GRANT) and ALTER failed"
check T3.teardown_ran "$( grep -q 'DROP CONSTRAINT IF EXISTS g2p_target_refusal' "$R" && grep -q '"fn":"resetData"' "$R" && grep -q 'DELETE FROM "ScoutImport"' "$R"; echo $? )" "teardown still cleaned up after partial authorized setup"
check T3.no_skip "$( ! grep -q PG17_TEARDOWN_SKIPPED "$OUT/gate-$CTL_TS-T3.jest.log"; echo $? )" "no TEARDOWN_SKIPPED for an authorized setup"
run_gate T0 predecessor.spec.ts refused-identity; r=$GATE_RC; R="$OUT/gate-$CTL_TS-T0.jsonl"
check T0.defect "$( [ "$(mut "$R")" -ge 2 ] && grep -q 'DROP CONSTRAINT IF EXISTS g2p_target_refusal' "$R" && grep -q '"fn":"resetData"' "$R"; echo $? )" "PREDECESSOR refused-identity: $(mut "$R") mutating teardown calls recorded (frozen S5-R3-A-01 reproduced under real Jest hook semantics; FAILING behaviour)"
summary
