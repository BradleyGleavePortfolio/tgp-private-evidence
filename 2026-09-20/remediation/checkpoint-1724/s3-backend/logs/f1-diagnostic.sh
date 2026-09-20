#!/bin/bash
# F1 single diagnostic: identical child probe once, timed; then the single spec once. No retry loop, no timeout change.
cd /home/user/workspace/worktrees/s3-backend
echo "load before: $(cat /proc/loadavg)"
cat > /tmp/f1-probe.js <<'JS'
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
JS
echo "--- child probe standalone (same code path as spec line 133, timeout in spec = 20000 ms)"
/usr/bin/time -v node /tmp/f1-probe.js 2>&1 | rg -v "^\s+(Average|Socket|Signals|Swaps|File system|Page size|Exit|Minor|Major|Voluntary|Involuntary|Percent)"
echo "--- single spec once"
npx jest --ci --maxWorkers=1 test/dependency-compatibility.spec.ts 2>&1 | rg -v "^\s*$"
echo "load after: $(cat /proc/loadavg)"
