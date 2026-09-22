# Tooling provenance (NOT product-lock provenance)

- Purpose: let the product repo's existing `lefthook.yml` pre-commit `prettier --check {staged_files}` resolve a pinned binary locally, offline, without adding `prettier` to the product `package.json`/`package-lock.json` (which stay at blobs 656d11a2… / 354de3da…).
- Source of pin: preserved `worktrees/s4-r6/package-lock.json` (git blob 4455f53a6e0118ea2c4dd58f948da6e34fa920d9, head 91990ae9aec72f47a67591892ac09fa1f59d2f16), entry `node_modules/prettier`:
  version 3.9.6, resolved https://registry.npmjs.org/prettier/-/prettier-3.9.6.tgz,
  integrity sha512-OpN0zzVdiaiAhxpuuj5efpIS4sY9j7bY6uR5mnj5yPzGkdkjNKSJeUThPb60Jw29QuAZgA4o+/iB49kFiaBX6g==
  (hex sha512 3a9374cf355d89a880871a6eba3e5e7e9212e2c63d8fb6d8eae4799a78f9c8fcc691d92334a4897944e13dbeb4270dbd42e019800e28fbf881e3d90589a057ea),
  bin prettier -> bin/prettier.cjs, no dependencies, no peerDependencies, engines node >=14.
- Tarball is NOT in the sandbox npm cache (checked 2026-09-22 05:1x UTC: no index entry for prettier-3.9.6.tgz). Setup therefore requires exactly one registry read of that tarball, integrity-verified by npm, during the SETUP step only; the COMMIT step runs with registry access disabled (`npm_config_offline=true`).
- This directory contains only manifests and this note; nothing is installed here yet.
