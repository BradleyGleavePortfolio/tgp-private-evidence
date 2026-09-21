# S4 R4 checkpoint-1 recovery verification

Parent collection, 2026-09-21 approximately 23:45 UTC. This is source preservation verification, not product testing or an independent audit.

Cloned only the extension's full public main history into a separate no-checkout repository at `initialization/recovered/s4-r4-2bcf1563-import-check`. Confirmed public main `0111be661922234d670bbf23e23d270eec1b4a4e`, verified the checkpoint manifest, ran `git bundle verify`, fetched the bundle's exact head into a new local ref, and ran `git fsck --full`; all exited 0. No existing source checkout was changed.

Restored head: `2bcf1563d85bc2109e99805e4ce1b06fce4dcdb3`. Restored tree: `3e23f91824689d1f179a116af948eae0ed5ae170`, equal to the builder's frozen checkpoint. Author and committer both `Bradley Gleave <bradley@bradleytgpcoaching.com>`.

Bundle SHA256: `dbaa346cf498a9aa8967e01a69190599768500eda3fb491e7047d08b00e4c3b2`. The builder's fresh-import limitation is closed for preservation only. No install, behavioral test, package/browser proof, product push or deployment occurred.
