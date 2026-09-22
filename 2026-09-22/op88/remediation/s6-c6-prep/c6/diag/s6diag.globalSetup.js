'use strict';
/**
 * S6 C5 — Jest globalSetup (runs in the Jest PARENT process, before any test
 * environment is created; with --runInBand the tests run in this same process).
 * Installs the async-resource inventory hook. Observation only.
 * Invoked via CLI: --globalSetup /home/user/workspace/execution/s6-diagnostic/diag/s6diag.globalSetup.js
 */
const path = require('path');
module.exports = async function s6diagGlobalSetup(globalConfig) {
  const main = require(path.join(__dirname, 's6diag.main.js'));
  const g = main.install();
  main.write({
    ev: 'globalSetup',
    runInBand: Boolean(globalConfig && globalConfig.runInBand),
    maxWorkers: globalConfig && globalConfig.maxWorkers,
    detectOpenHandles: Boolean(globalConfig && globalConfig.detectOpenHandles),
    forceExit: Boolean(globalConfig && globalConfig.forceExit),
    trackedSoFar: g.live.size,
  });
  if (globalConfig && globalConfig.runInBand === false) {
    // Not fatal for Jest, but the inventory would then observe the parent only.
    main.write({ ev: 'WARNING', msg: 'runInBand is false: tests would run in a worker; inventory would not see them' });
  }
};
