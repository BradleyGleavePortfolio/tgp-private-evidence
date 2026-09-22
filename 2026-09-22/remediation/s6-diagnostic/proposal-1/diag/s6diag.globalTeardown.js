'use strict';
/**
 * S6 C5 — Jest globalTeardown (Jest PARENT process, after all test files, their
 * afterAll hooks and the environment teardown have completed; before jest-cli
 * returns and waits for the event loop to drain).
 * Takes the post-completion snapshot and arms UNREF'D follow-up ticks so a
 * self-re-arming chain shows as a sequence of fresh asyncIds. Observation only.
 * Invoked via CLI: --globalTeardown /home/user/workspace/execution/s6-diagnostic/diag/s6diag.globalTeardown.js
 */
const path = require('path');
module.exports = async function s6diagGlobalTeardown() {
  const main = require(path.join(__dirname, 's6diag.main.js'));
  const snap = main.snapshot('globalTeardown');
  main.scheduleTicks([1000, 3000, 6000, 10000, 20000, 40000, 70000]);
  try {
    process.stderr.write(
      `[s6diag] globalTeardown: liveRefed=${snap.liveRefedCount} byOwner=${JSON.stringify(snap.byOwner)} byDelay=${JSON.stringify(snap.byDelay)} activeResourcesInfo=${JSON.stringify(snap.activeResourcesInfo)}\n`,
    );
  } catch {
    /* ignore */
  }
};
