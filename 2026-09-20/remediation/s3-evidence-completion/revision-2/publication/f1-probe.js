const assert = require('node:assert/strict');
(async () => {
  const t0 = Date.now();
  const fs = require('node:fs'); const path = require('node:path');
  const dir = fs.mkdtempSync(path.join(require('node:os').tmpdir(), 'prisma-dependency-'));
  fs.writeFileSync(path.join(dir, 'prisma.config.ts'),
    'export default { schema: "./schema.prisma", migrations: { path: "./migrations" } };');
  const { loadConfigFromFile } = require('@prisma/config');
  console.error('require(@prisma/config) ms=' + (Date.now() - t0));
  const loaded = await loadConfigFromFile({ configRoot: dir });
  console.error('loadConfigFromFile ms=' + (Date.now() - t0));
  assert.equal(loaded.error, undefined);
  assert.equal(loaded.config.schema, path.join(dir, 'schema.prisma'));
  const missing = await loadConfigFromFile({ configRoot: dir, configFile: 'absent.ts' });
  assert.equal(missing.error._tag, 'ConfigFileNotFound');
  fs.rmSync(dir, { recursive: true, force: true });
  console.error('total ms=' + (Date.now() - t0));
})().then(() => process.stdout.write('dependency-probe-ok\n'), e => { console.error(e); process.exitCode = 1; });
