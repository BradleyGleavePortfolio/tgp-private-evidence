/**
 * S5 R4 FAKE recording harness for the Jest-level teardown-gate control (A-01). Substitutes
 * test/utils/g2-pg17-harness.ts INSIDE THE CONTROL ROOT ONLY (never in the worktree). Every sql()/
 * sqlAdmin()/resetData() call is appended to the JSON-lines file $G2_CTL_RECORD with a phase tag and a
 * mutating/read classification. Constructs no connection, spawns no process, executes no psql.
 * Scenarios ($G2_CTL_SCENARIO): refused-identity | refused-prestate | authorized-partial
 */
import { appendFileSync } from 'fs';
import { resolve } from 'path';
const scenario = process.env.G2_CTL_SCENARIO || 'refused-identity';
const record = process.env.G2_CTL_RECORD!;
const fakeRoot = process.env.G2_CTL_FAKEROOT!;
export const root = fakeRoot;
export const oldRoot = resolve(fakeRoot, 'oldroot');
export const oldClient = resolve(fakeRoot, 'oldclient');
export const directory = '/ctl/pg17/clusters/s5';
export const expectedVersion = 170006;
export const OLD_HEAD = '925780e0a1906593e5383c618311b6b17364b8dc';
export const target = { port: 54325 } as any;
let phase = 'setup';
export const setPhase = (p: string) => { phase = p; };
const mutating = (s: string) => /^(\s*)(GRANT|ALTER|DELETE|INSERT|UPDATE|DROP|CREATE|TRUNCATE|COMMENT)\b/i.test(s) || /;\s*(GRANT|ALTER|DELETE|INSERT|UPDATE|DROP|CREATE|TRUNCATE)\b/i.test(s);
const log = (fn: string, stmt: string) => appendFileSync(record, JSON.stringify({ fn, phase, mutating: mutating(stmt), stmt: stmt.replace(/\s+/g, ' ').slice(0, 120), t: Date.now() }) + '\n');
const identity = () => ({
  database: scenario === 'refused-identity' ? 'not_the_disposable_db' : 'g2_s5_etq0_disposable',
  address: '127.0.0.1', port: 54325, directory, version: '170006', user: 'postgres', super: false, bypassrls: true, owner: 'postgres',
});
export const sql = (text: string): string => {
  log('sql', text);
  if (mutating(text)) {
    if (scenario === 'authorized-partial' && /ADD CONSTRAINT g2p_target_refusal/.test(text)) throw new Error('fake: ALTER TABLE failed after authorized GRANT (partial setup)');
    return '';
  }
  if (/pg_tables WHERE schemaname='public' AND tableowner<>'postgres'/.test(text)) return '0';
  if (/current_setting\('cluster_name'\)/.test(text)) return 's5-disposable-pg17';
  if (/shobj_description/.test(text)) return 's5-g2-etq0-synthetic-disposable-fixture-safe-to-drop';
  if (/_prisma_migrations.*finished_at IS NOT NULL/.test(text)) return scenario === 'refused-prestate' ? '165' : '164';
  if (/_prisma_migrations.*migration_name=/.test(text)) return scenario === 'refused-prestate' ? '1' : '0';
  if (/attname='source_platform'/.test(text)) return '0';
  if (/rolname='service_role'/.test(text)) return 'true:true';
  if (/rolname IN \('anon','authenticated'\)/.test(text)) return 'false:false,false:false';
  if (/role_table_grants/.test(text)) return '';
  return '';
};
export const sqlAdmin = (text: string): string => { log('sqlAdmin', text); return directory; };
export const json = (text: string) => { log('sql', text); return identity(); };
export const quote = (s: string) => `'${s.replace(/'/g, "''")}'`;
export const hasColumn = () => sql(`SELECT count(*) FROM pg_attribute WHERE attname='source_platform'`);
export const appliedMigrations = () => sql(`SELECT count(*) FROM "_prisma_migrations" WHERE finished_at IS NOT NULL AND rolled_back_at IS NULL`);
export function resetData() { log('resetData', 'DELETE FROM "ScoutReconstructionLedger"; DELETE ... (resetData)'); }
export const gitShow = (_spec: string) => 'fake O service source\n';
export type Result = { result?: any; failure?: any; queries: string[]; events: any[]; pid: number };
// Everything below is only reachable from test bodies, which never run in these scenarios (beforeAll throws).
const never = (name: string) => (..._a: any[]): any => { throw new Error(`fake harness: ${name} must not be reached in a hook control`); };
export const allLedger = never('allLedger'); export const blocked = never('blocked'); export const catalog = never('catalog');
export const down = 'fake-down'; export const encoded = never('encoded'); export const holdAdvisory = never('holdAdvisory');
export const holdTransaction = never('holdTransaction'); export const legacy = never('legacy'); export const legacyEntityCursor = never('legacyEntityCursor');
export const prisma = never('prisma'); export const prismaMigrateDeploy = never('prismaMigrateDeploy'); export const records = never('records');
export const refused = never('refused'); export const run = never('run'); export const settle = never('settle'); export const sqlFile = never('sqlFile');
export const stage = never('stage'); export const stageMany = never('stageMany'); export const targets = never('targets'); export const up = 'fake-up';
export const upFile = '/ctl/up.sql'; export const v2 = never('v2'); export const worker = never('worker');
