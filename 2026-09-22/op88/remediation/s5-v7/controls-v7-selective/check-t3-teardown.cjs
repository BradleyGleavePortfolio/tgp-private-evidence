#!/usr/bin/env node
'use strict';
// OP88-S5-V7 — JSON-aware READ-ONLY checker for the preserved Tier-2 T3 (authorized-partial) evidence.
// Closes the wave-6 control-check defect S5-TIER2-GATE-V6-01: v6 driver L80 grepped the literal
//   DELETE FROM "ScoutImport"
// against a JSON-lines file whose stmt field stores the statement JSON-escaped (DELETE FROM \"ScoutImport\"),
// so the check failed although the record proves the teardown ran. This checker PARSES each JSONL record and
// evaluates the same T3 predicates on decoded field values; it never layers escaping onto grep.
//
// Usage: node check-t3-teardown.cjs <gate-…-T3.jsonl> <gate-…-T3.jest.log> [--json <out.json>]
// Exit: 0 all required predicates PASS; 1 at least one FAIL; 2 usage/read error.
// Reads two files, writes nothing except the optional --json summary and stdout. No child process, no network, no DB.
//
// Predicates (ids kept identical to the v6 driver where they carry the same meaning):
//   T3.record_parse   every line is one JSON object {fn:string, phase:string, mutating:boolean, stmt:string, t:number}; >=1 record
//   T3.setup_partial  (v6 L79 equivalent) a mutating sql record whose stmt contains 'GRANT USAGE', and a record whose stmt contains
//                     'ADD CONSTRAINT g2p_target_refusal' (authorized setup began, ALTER issued)
//   T3.teardown_ran   (v6 L80 equivalent, decoded) three mutating records exist:
//                       teardown.drop      fn=sql,       stmt contains 'DROP CONSTRAINT IF EXISTS g2p_target_refusal'
//                       teardown.resetData fn=resetData
//                       teardown.delete    fn=sql,       stmt === 'DELETE FROM "ScoutImport"' (decoded, exact)
//   T3.teardown_after_failed_alter  (V7 additional discriminator, separately named) the three teardown records all occur AFTER the
//                     ADD CONSTRAINT record and in the order drop < resetData < delete
//   T3.log_bound      Jest log is nonempty and is the authorized-partial run: contains the fake's throw text
//                     'fake: ALTER TABLE failed after authorized GRANT (partial setup)', 'Ran all test suites matching test/candidate.spec.ts'
//                     and a 'Test Suites:' summary line
//   T3.no_skip        (v6 L81 equivalent) Jest log does not contain 'PG17_TEARDOWN_SKIPPED'
// Observations (not predicates): sha256 of both inputs, record count, and whether the v6 L80 unescaped literal matches the raw bytes.

const fs = require('fs');
const crypto = require('crypto');

function usage(msg) { process.stderr.write(`usage: ${msg}\nnode check-t3-teardown.cjs <T3.jsonl> <T3.jest.log> [--json <out.json>]\n`); process.exit(2); }
const argv = process.argv.slice(2);
if (argv.length < 2) usage('two input paths required');
const jsonlPath = argv[0], logPath = argv[1];
let jsonOut = null;
for (let i = 2; i < argv.length; i++) { if (argv[i] === '--json' && argv[i + 1]) { jsonOut = argv[++i]; } else usage(`unknown argument ${argv[i]}`); }

function readBytes(p) { try { return fs.readFileSync(p); } catch (e) { process.stderr.write(`read error ${p}: ${e.message}\n`); process.exit(2); } }
const sha256 = (b) => crypto.createHash('sha256').update(b).digest('hex');
const jsonlBytes = readBytes(jsonlPath), logBytes = readBytes(logPath);
const jsonlText = jsonlBytes.toString('utf8'), logText = logBytes.toString('utf8');

const results = []; let pass = 0, fail = 0;
const out = (line) => process.stdout.write(line + '\n');
function check(id, ok, detail) { results.push({ id, result: ok ? 'PASS' : 'FAIL', detail }); if (ok) pass++; else fail++; out(`${ok ? 'PASS' : 'FAIL'} ${id} ${detail}`); return ok; }
function observe(key, value) { results.push({ observation: key, value }); out(`OBSERVE ${key} ${value}`); }

observe('input.jsonl', `${jsonlPath} sha256=${sha256(jsonlBytes)} bytes=${jsonlBytes.length}`);
observe('input.jest_log', `${logPath} sha256=${sha256(logBytes)} bytes=${logBytes.length}`);

// ---- T3.record_parse
const rawLines = jsonlText.split('\n'); if (rawLines.length && rawLines[rawLines.length - 1] === '') rawLines.pop();
const records = []; const parseErrors = [];
rawLines.forEach((line, i) => {
  let o; try { o = JSON.parse(line); } catch (e) { parseErrors.push(`line ${i + 1}: ${e.message}`); return; }
  const shape = o && typeof o === 'object' && !Array.isArray(o) && typeof o.fn === 'string' && typeof o.phase === 'string' && typeof o.mutating === 'boolean' && typeof o.stmt === 'string' && typeof o.t === 'number';
  if (!shape) { parseErrors.push(`line ${i + 1}: unexpected record shape ${JSON.stringify(Object.keys(o || {}))}`); return; }
  records.push({ line: i + 1, ...o });
});
observe('record.count', String(rawLines.length));
observe('record.mutating_count', String(records.filter(r => r.mutating === true).length));
check('T3.record_parse', parseErrors.length === 0 && records.length >= 1, parseErrors.length ? `${parseErrors.length} unparsable/ill-shaped line(s): ${parseErrors.slice(0, 3).join('; ')}` : `${records.length} JSON records parsed, all with fn/phase/mutating/stmt/t`);

// ---- T3.setup_partial (v6 L79 equivalent, decoded)
const grant = records.find(r => r.fn === 'sql' && r.mutating === true && r.stmt.includes('GRANT USAGE'));
const addConstraint = records.find(r => r.stmt.includes('ADD CONSTRAINT g2p_target_refusal'));
check('T3.setup_partial', !!grant && !!addConstraint, `GRANT USAGE mutating record ${grant ? `line ${grant.line}` : 'ABSENT'}; ADD CONSTRAINT g2p_target_refusal record ${addConstraint ? `line ${addConstraint.line} mutating=${addConstraint.mutating}` : 'ABSENT'}`);

// ---- T3.teardown_ran (v6 L80 equivalent on DECODED stmt values)
const drop = records.find(r => r.fn === 'sql' && r.mutating === true && r.stmt.includes('DROP CONSTRAINT IF EXISTS g2p_target_refusal'));
const reset = records.find(r => r.fn === 'resetData' && r.mutating === true);
const del = records.find(r => r.fn === 'sql' && r.mutating === true && r.stmt === 'DELETE FROM "ScoutImport"');
const part = (name, r) => `${name}=${r ? `line ${r.line}` : 'MISSING'}`;
check('T3.teardown_ran', !!drop && !!reset && !!del, `${part('teardown.drop', drop)} ${part('teardown.resetData', reset)} ${part('teardown.delete', del)} (all three required; decoded stmt compared, no escaping layered)`);

// ---- T3.teardown_after_failed_alter (V7 additional, separately named)
const ordered = !!addConstraint && !!drop && !!reset && !!del && addConstraint.line < drop.line && drop.line < reset.line && reset.line < del.line;
check('T3.teardown_after_failed_alter', ordered, addConstraint && drop && reset && del ? `ADD CONSTRAINT line ${addConstraint.line} < drop ${drop.line} < resetData ${reset.line} < delete ${del.line}` : 'not evaluable: a required record is missing');

// ---- T3.log_bound + T3.no_skip
const throwText = 'fake: ALTER TABLE failed after authorized GRANT (partial setup)';
const ranLine = 'Ran all test suites matching test/candidate.spec.ts';
const bound = logBytes.length > 0 && logText.includes(throwText) && logText.includes(ranLine) && /^Test Suites: /m.test(logText);
check('T3.log_bound', bound, `nonempty=${logBytes.length > 0} has_partial_setup_throw=${logText.includes(throwText)} has_candidate_ran_line=${logText.includes(ranLine)} has_test_suites_summary=${/^Test Suites: /m.test(logText)}`);
const skipCount = (logText.match(/PG17_TEARDOWN_SKIPPED/g) || []).length;
check('T3.no_skip', skipCount === 0, `PG17_TEARDOWN_SKIPPED occurrences=${skipCount} (expected 0 for an authorized setup)`);

// ---- Observations documenting the closed v6 defect (raw-bytes view, informational only)
observe('v6_L80.unescaped_literal_in_raw', String(jsonlText.includes('DELETE FROM "ScoutImport"')));
observe('v6_L80.escaped_literal_in_raw', String(jsonlText.includes('DELETE FROM \\"ScoutImport\\"')));

out(`SUMMARY pass=${pass} fail=${fail} checker=check-t3-teardown.cjs`);
if (jsonOut) { try { fs.writeFileSync(jsonOut, JSON.stringify({ checker: 'check-t3-teardown.cjs', inputs: { jsonl: { path: jsonlPath, sha256: sha256(jsonlBytes) }, jest_log: { path: logPath, sha256: sha256(logBytes) } }, results, pass, fail }, null, 1) + '\n'); } catch (e) { process.stderr.write(`json write error: ${e.message}\n`); process.exit(2); } }
process.exit(fail === 0 ? 0 : 1);
