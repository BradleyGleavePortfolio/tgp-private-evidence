// Jest config for the teardown-gate control root ($CR). Transpile-only ts-jest (no type diagnostics:
// the fake harness is deliberately loosely typed), runInBand, no setup files, rootDir = control root.
module.exports = {
  rootDir: process.env.G2_CTL_ROOT,
  roots: ['<rootDir>/test'],
  testEnvironment: 'node',
  transform: { '^.+\\.ts$': ['ts-jest', { isolatedModules: true, diagnostics: false, tsconfig: { module: 'commonjs', target: 'es2020', esModuleInterop: true } }] },
  testMatch: ['<rootDir>/test/*.spec.ts'],
  testTimeout: 30000,
};
