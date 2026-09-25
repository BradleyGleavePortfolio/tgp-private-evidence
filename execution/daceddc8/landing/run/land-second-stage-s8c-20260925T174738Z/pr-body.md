Composition of the accepted S8-C native reconstruct writers candidate `f428db9ab65f638da1651b8cd792c6f93b4983c1` onto the landed `integration/importer` head `df713fd9217df524915348ef8a42c797f288dde1`. It is one ordinary merge commit, `2542af44ab5b4d296f84e9f5f311632f7f5aeb25` (tree `36e44e2d4c0acaa5131087973043638909a3e20c`), made by Bradley Gleave with the genuine hooks.

- The textual merge is conflict-free. The only path both candidates touch is `docs/contracts/importer-openapi.json`. It was regenerated from the combined DTOs with the unchanged S7-L generator and is byte-identical to the textual merge (blob `f9109c068a54`). A cold-process regeneration also matched.
- Local composition gates: the hooks ran R75, tsc (heap 4096), eslint and prettier 3.9.9, and the 27 Jest suites whose import closure spans both candidates passed. Receipt: `compose-second-s8c-20260925T174224Z`.
- Landing: an ordinary fast-forward push of this exact merge after green CI. The GitHub merge button is not used. Non-production. `main` is untouched (#530 stays owner-reserved).
- Danger, CodeQL, R75, SBOM and Infra Lint trigger only for PRs whose base is `main`, so they do not run here (see #539).
