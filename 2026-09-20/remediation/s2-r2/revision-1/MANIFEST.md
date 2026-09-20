# S2 delivery — R2 publication manifest (2026-09-20)

Generated 2026-09-20T17:56:51Z. All paths relative to /home/user/workspace unless absolute. Nothing pushed, deployed or changed on hosted settings by S2.

## Commits (branch execute/20260920-s2-delivery, base main c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7)

```
0b05fcf5352287109ac88ed2ba3682e441e3a076 fba0a9f06127979005b70ca3da80584a1e2ce10c Bradley Gleave <bradley@bradleytgpcoaching.com> | Bradley Gleave <bradley@bradleytgpcoaching.com> | ci(delivery): compose dependency-audit as required input; run catalog verifiers in release_command
477633808270cf4a084e5ab0cf2ed5b7ddc5d24a 17fbb37eed81fc29559d9bdd155b13d8f8698918 Bradley Gleave <bradley@bradleytgpcoaching.com> | Bradley Gleave <bradley@bradleytgpcoaching.com> | ci(delivery): R1 audit remediation — pinned refs, migration/recovery evidence, SBOM proof in gate
cb0bc91094fcad322b54a72c4ff317313e052c18 8222bdd70c5680095cc19a524cb1f21ef359d31f Bradley Gleave <bradley@bradleytgpcoaching.com> | Bradley Gleave <bradley@bradleytgpcoaching.com> | ci(sbom): also run the production-closure proof on pull requests to main
4a63b8ae297442131f2994c206be531045fc51e4 4a655ec11919d3423ead5a719e6b6c3500c5a02d Bradley Gleave <bradley@bradleytgpcoaching.com> | Bradley Gleave <bradley@bradleytgpcoaching.com> | ci(delivery): gate refuses deploy when the production environment is unprotected
b801a776558d18acea2d03f19029f0ea85ffca39 f24e871b82d00a3bb6b78488b495d67c631793ae Bradley Gleave <bradley@bradleytgpcoaching.com> | Bradley Gleave <bradley@bradleytgpcoaching.com> | ci(delivery): fail-closed release evidence gate, CodeQL/SBOM hard-fail, prod-only image
```

Other refs: tag s2-r1-frozen=b801a776558d18acea2d03f19029f0ea85ffca39 (frozen R1, untouched); branch s2-post-r1-held=cb0bc91094fcad322b54a72c4ff317313e052c18 (held commits, reused unchanged); local branch s2-compose-preview=6b85395fd60a3a6fc91314f32f91a7cd2985b96c (S2 0b05fcf5 + S3 5c7b42b3 + S1 90a66475 composition preview — NOT the audit candidate).

## Files in execution/s2-delivery (sha256; MANIFEST.md itself excluded)

```
30e27bdbe42edc268966d484b7fb00903a3021030c90b5cb656d307aae8ea87f  CROSS_LANE_DISPOSITION.md
250007d2133480369001d9eba06037222e6059083069d940f2dfce7f7b6341af  LANDING_PROPOSAL.md
909969e72820ba94cb23cd71f25d83be1dc60629c12ea9180af8ca8b02929c53  MILESTONE.md
f5a3186e36d10ed1a0f4883f653b3b5e2d8c742f068c50f54fcc73b51d1056c3  MILESTONE_R2.md
e1c122a1a1bb595acac5518b77b0c85eca085671e7eaafb73566a74c9021a248  REPORT.md
cbeb053e65a491d3a237c3cf9d7d754026820f19917356940500ede4955f0b00  REPORT_R1_frozen_b801a776.md
87c451dcea8ac84b4b23e15de57624a15f159d07cfca0508176bf35cdc0a2635  action-pin-verification.log
7a83155bab03d98002164805608f5082bf74aad08caec8d4497352192b49355a  local-omit-dev-npm-ci.log
f044ef01ebb877a477cb91557ba119ca71af20d05cca9eeeace83c8aaf5c0edf  local-omit-dev-sbom.cdx.json
204ed81d4e05e705aa95d8c71b42998470039b2aa40c0fbf5cd807637115907e  local-runtime-stage-replay.log
9800b7e6a61e87393602b3a298de875965a8d35420ce5237a706d12eb4523cc1  local-runtime-stage-replay.sh
a14d2c35a22784e2e85f0dc0f25a691cfb144e3216ce7a4a6bac88611e892571  s2-compose-preview-test.log
a8bea775d0d723070db3bab2816214765963e5546d8ba7682b996237a5995a6b  s2-compose-preview.bundle
a27e476a10bc5fd576a750b7bbbe7f3c123f95a0f514b64524bdc42146675bf5  s2-delivery-r1.2.bundle
42b1d238806a5d8f65e2107ca0c2b31f21531c6b0b38a13d8439ec238d627ad6  s2-delivery-r1.bundle
1769a3903354de0be8aaa4166eb44b28119d7158e40a326fa6f8d904185279ed  s2-delivery-r2-checkpoint.bundle
6043baf58d6ba1c85846fdac7b43c3388754b30966e03f8aca222da95304831e  s2-delivery-r2-final.bundle
d5d2cbd1622d0ab5983cf1459c62fbd3fed452d7c464ed4d2a158f66a0c7bdd1  s2-post-r1-held.bundle
e710626e2762f47bc87067789762b3fa7ac0f943c150f3123a929353a19eb575  s2-r2-test.log
49b344dbed86449c6864d5c5cdb8ba812488bf70366eba6c3e27e4d2c9e071b1  s2-s3-mergetree-conflict.txt
```

## Logs and scripts outside this directory (sha256)

```
123221c0e2b8eb85fa281807cf4974b846c22405b3fe54a6150e2ced168cf67d  /tmp/s2-npm-ci.log
a4e589b7fe2dbbd653c954565d56acec15b004e45e06cd07efb918175710326e  /tmp/s2-gate-test.log
af1dcfdd2aadd329dea1e006a91e7991d94919d9bbd441d089ea9908383b6757  /tmp/s2-delivery-test.log
e710626e2762f47bc87067789762b3fa7ac0f943c150f3123a929353a19eb575  /tmp/s2-r2-test.log
2733515252024dd517603c1d7d220200dd9364ec87442606b7470e1044c10469  /tmp/s2-r2-gate-test.log
7a83155bab03d98002164805608f5082bf74aad08caec8d4497352192b49355a  /tmp/s2-omit-ci.log
204ed81d4e05e705aa95d8c71b42998470039b2aa40c0fbf5cd807637115907e  /tmp/s2-runtime-proof.log
c34b4150658ccde5f927cd5e3ae4c98cda5fd8c1ff2d3b382b5866ba795efe17  /tmp/s2-omit-proof.sh
9800b7e6a61e87393602b3a298de875965a8d35420ce5237a706d12eb4523cc1  /tmp/s2-runtime-proof.sh
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855  /tmp/sbom-gen.err
a14d2c35a22784e2e85f0dc0f25a691cfb144e3216ce7a4a6bac88611e892571  /tmp/s2-compose-preview-test.log
49b344dbed86449c6864d5c5cdb8ba812488bf70366eba6c3e27e4d2c9e071b1  /tmp/s2-s3-mergetree.txt
5512e9ec50be003834978ea4c5cc70b22e20443f279bb0340a6f7c03849b2eb7  /tmp/r100-s3.yml
```

Copies of the /tmp items that matter are in this directory: local-runtime-stage-replay.{log,sh} (= /tmp/s2-runtime-proof.*), s2-r2-test.log, s2-compose-preview-test.log, s2-s3-mergetree-conflict.txt.
