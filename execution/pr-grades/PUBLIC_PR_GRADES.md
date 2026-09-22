# TGP public PR consequence grades

Observed 2026-09-22T04:35:12.299Z. This covers every open PR in the four preserved TGP repositories, not only the active cumulative S-lanes. Per-PR head and GitHub-reported base are recorded separately from current repository main; a historical reported base is not asserted to be today's main.

## Interpretation

- **Scoped:** consequence assessed from current change surfaces and retained applicable authority/evidence. This is a grade, not an audit clearance.
- **Provisional:** explicit conservative grade under G06, using the higher plausible consequence while retained work remains inactive. No implied review, new dispatch, downgrade or permission to land; the scope must be confirmed before activation. This avoids reopening broad historical reconnaissance.
- **Roman #293:** retains its previously established T1 private leaf-view scope; not a downgrade of the T4 operational mobile foundation. #294 is separately T2 for terminal/result semantics. Integration into real lifecycle/identity authority must be regraded independently.
- **Other retained work:** preserve unchanged; do not start unrelated scope while importer blockers remain. A title or small diff never determines grade by itself.

## Builder and review routing

| Tier | Required route |
|---|---|
| T0 | GPT-5.6 Luna / Low; deterministic checks, no mandatory AI audit |
| T1 | GPT-5.6 Terra / Medium; targeted AI code review |
| T2 | Claude Sonnet 5 / High; one independent adversarial audit |
| T3 | Claude Opus 5 / XHigh; architecture + independent audit, second lens for G06 triggers |
| T4 | Claude Fable 5 / High; two independent final-head adversarial attestations |

## growth-project-backend

| PR | Exact current head | Grade | Basis | Consequence rationale |
|---|---|---|---|---|
| [#529](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/529) | `d7404cd49578647cf72bb633819d8e86ffc3da3a` | **T4** | scoped | Persistent platform identity, tenant-scoped writers, replay/cursors and generated contract; G2 T/Q0. |
| [#528](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/528) | `8644715c429e7dde1dfeb71f7ad42b1bd9121eaf` | **T4** | scoped | Persistent provenance migration and RLS/data-preserving recovery boundary; G2 E. |
| [#527](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/527) | `92777d94d41c9d70150854e0180b90eba26357e8` | **T4** | scoped | Changes trusted CI/governance enforcement; documentation/config size does not reduce tier. |
| [#526](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/526) | `881c4c791727adef8d423931e1cca83a0ffbb9c9` | **T4** | scoped | Durable authenticated pairing/intent ownership, RLS migration and rollback safety. |
| [#525](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/525) | `925780e0a1906593e5383c618311b6b17364b8dc` | **T4** | scoped | Credential/PII diagnostics redaction plus trusted enforcement and release configuration. |
| [#524](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/524) | `238f0f1f152ebbb1b4691f555e98c888473d8ee7` | **T4** | scoped | Vulnerable dependency graph consumed by credential/tenant-sensitive backend; cumulative compatibility safety. |
| [#522](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/522) | `e045cfc5e70124061b13e5dc4f4f4efb6132cceb` | **T4** | scoped | Identity uniqueness migration can silently lose or conflate imported records; compatibility/recovery consequence. |
| [#491](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/491) | `f81f0227cfcfe3557407f2c4051727d981bff332` | **T4** | provisional | Preserved data-capture/CI-recovery backlog has not been consequence-scoped in this continuation; privacy/recovery is the higher plausible boundary. No execution. |
| [#485](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/485) | `6ef3f846a8c1461ecfb446abe761500a1874d387` | **T4** | provisional | S3 SDK participates in credentialed storage and private-data transfer; exact consumers require pre-dispatch confirmation. |
| [#484](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/484) | `ece31e8cbb9767c0f18797e9d97afa5529853a91` | **T4** | provisional | HTTP framework adapter can alter request/security-boundary behavior; consumer applicability unrefreshed. |
| [#483](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/483) | `f667f10f853dd1a502943dddc777cf647dc9e9b7` | **T3** | provisional | Shared backend compiler/build CLI and artifact-generation architecture; regrade T4 if trusted enforcement changes. |
| [#482](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/482) | `47370ced0d09b56ac05dd23bd6250e9e1a029c37` | **T3** | provisional | Shared Node type/toolchain contract with cross-backend compile implications; not isolated runtime code. |
| [#481](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/481) | `b2f0a3519a159b502058613f528d21cea5bc1343` | **T3** | provisional | Shared test-transformer/toolchain behavior and broad test applicability; no assertion-enforcement change established. |
| [#480](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/480) | `ab1dd973bea754161a9376d4053d18dd5854cca1` | **T4** | provisional | Telemetry SDK processes diagnostics and potentially sensitive data; privacy boundary requires review. |
| [#479](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/479) | `02b4a2965082c2364c3b5fcbbc6bb9a7bf38672b` | **T4** | provisional | WebSocket transport on authenticated service boundary; security/resource behavior not yet scoped. |
| [#478](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/478) | `1ca3b5da96149f7e41053fa17f23262b63b3ec6c` | **T4** | provisional | Core framework participates in guards, validation and authenticated request handling. |
| [#477](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/477) | `ebf9b23495d67171c60d70c4129ad7bb8b2b1323` | **T4** | provisional | Parser upgrade may affect trusted configuration/policy interpretation; use higher plausible tier until consumers bounded. |
| [#476](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/476) | `85ce2a36d37880632d344e4e6b6f660de5052461` | **T4** | provisional | Supabase authentication, credential and database/tenant boundary dependency. |
| [#475](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/475) | `5505569e55ce52255256bf2ef21f5557c85912bb` | **T4** | provisional | CI artifact upload changes evidence/artifact provenance and release trust. |
| [#474](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/474) | `78f8a546808ef2dbb6400cbc14d88db632722417` | **T4** | provisional | GitHub-script execution with repository credentials and trusted automation authority. |
| [#473](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/473) | `e2082c2596dfaf500239d4dfeb6c7b042c1980c1` | **T4** | provisional | Policy-linked size-label automation and repository write privileges; enforcement applicability unrefreshed. |
| [#472](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/472) | `2b1b55076621dd36f3fe89ddfc3d75b3d1b0dd16` | **T4** | provisional | Trusted CI checkout/source identity and credential handling. |
| [#471](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/471) | `be525ea8327b2aa8851a42f3125074a3d844ae2f` | **T4** | provisional | Automated release publication/identity boundary. |
| [#428](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/428) | `988517ad9004c80b50d249c4e15fd93600c595f0` | **T4** | provisional | Coach-owned exercise API, authorization and sensitive native data/media; stacked on RLS storage. |
| [#427](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/427) | `592f2f8b4bf44d265f4353165bd1cf8f60e5df5c` | **T4** | scoped | Explicit RLS/schema migration and credentialed media-presign boundary. |

## growth-project-mobile

| PR | Exact current head | Grade | Basis | Consequence rationale |
|---|---|---|---|---|
| [#294](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/294) | `5cbf0de3f3d1d7f279ac72e43638f9e45acf9cf5` | **T2** | scoped | Private controlled status/result presentation changes meaningful completion/error semantics, with no operational authority, API, persistence or production wiring; stronger than T1 until full boundedness is established. |
| [#293](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/293) | `003a9774083812a465fbc78a99aaba5ca16ccfa5` | **T1** | scoped | Retain established bounded leaf-view grade: fixed props/callbacks, private isolated surface, no API/storage/auth/analytics/native action or production registration; ten boundedness criteria satisfied within this presentation-only scope. |
| [#292](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/292) | `340886776e3af0c22b97aae666b1b0f331820f5f` | **T4** | scoped | Pairing credential display/copy and recovery UI, plus required T4 pairing ancestry; clipboard is not merely cosmetic. |
| [#291](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/291) | `d2f0d31c6898f8642153df7a53644c1f38f26114` | **T4** | scoped | Persisted user-scoped pairing credentials, account switching, sign-out purge and auth-header handling. |
| [#290](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/290) | `ed0342e976bfd2992755d85afb1678bd135c327a` | **T4** | scoped | Independent sensitive-data review kill switch and default-off enforcement; retained dependency on trusted-install foundation. |
| [#289](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/289) | `22354984d9e3af0deb2d32271ce9ab5e5accb92a` | **T4** | scoped | CI deterministic-install/dependency guard and policy-template enforcement, not just a manifest declaration. |
| [#286](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/286) | `7dfd8c6dd8fc3f84f6c03c57872574f7f7ad9410` | **T4** | provisional | Trusted CI runtime/setup dependency changes actual validation and release inputs. |
| [#283](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/283) | `5437e31c460d5f93c11a9c30b14fcfc1c889cb23` | **T4** | provisional | User-scoped invitation credential ownership and persistence. |
| [#282](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/282) | `95c84b0347927d92888b7edcf2a2899100b98cf5` | **T4** | provisional | Mixed dev-dependency group not freshly bounded; could alter trusted build/security/test enforcement. No execution until specific scope reviewed. |
| [#281](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/281) | `2b5631c72e0dd7aa870943b6547b42f6b2f971a5` | **T4** | provisional | Customer-support SDK can process identity and private conversation data. |
| [#280](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/280) | `9a670483e8cf7281b22f8ec2f0d3e117213fd52e` | **T3** | provisional | Shared native worklet/runtime primitive with cross-application concurrency/build consequences; promote if account/security boundary affected. |
| [#279](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/279) | `a9169bff0f6b3b3da3fbbdce5c8dee10cb3a8c8c` | **T4** | provisional | Sentry native diagnostics and potentially sensitive-data capture/redaction boundary. |
| [#278](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/278) | `9668dcba11271f4368f5725bce273f2612a17e58` | **T4** | provisional | Shared navigation may affect authenticated/account-specific surface isolation; higher plausible tier pending consumer scope. |
| [#276](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/276) | `e871efba885b11b2f7caad191989b11f8bd83058` | **T4** | provisional | Trusted CI checkout/source identity and credential handling. |
| [#265](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/265) | `3b62ab0b31471c045e875d4fa3d98a1e035f33fe` | **T4** | provisional | Native coach exercise authoring and health/business-data writes; cumulative API/data-layer dependency. |
| [#264](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/264) | `77f29c6782e80f38d520f2f725eeb03353ff7a78` | **T4** | provisional | Authenticated coach data/media API and ownership-sensitive persistent records. |
| [#262](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/262) | `f6f1478e248fa2260cb2f4acc392ced9cafff140` | **T4** | provisional | Delete-set/undo/autosave recovery of sensitive workout records; data integrity and destructive action boundary. |

## tgp-importer-extension

| PR | Exact current head | Grade | Basis | Consequence rationale |
|---|---|---|---|---|
| [#26](https://github.com/BradleyGleavePortfolio/tgp-importer-extension/pull/26) | `d595092c50ffdf891ebec11f27e29436fa27af89` | **T4** | scoped | Trusted enforcement/governance policy changes; content incorporated in #25, do not reapply. |
| [#25](https://github.com/BradleyGleavePortfolio/tgp-importer-extension/pull/25) | `49c1aa96fa2d6df9a09f22c97952b45d10271952` | **T4** | scoped | Contains T4 policy-enforcement donor plus cumulative credential/transfer boundary; local outcome UI alone does not lower the PR. |
| [#24](https://github.com/BradleyGleavePortfolio/tgp-importer-extension/pull/24) | `c0824cbb2f95595933d0273dc90eeb61d9ca5edd` | **T4** | scoped | Authenticated ingest receipts, transfer settlement, credential-safe diagnostics and cumulative security ancestry. |
| [#23](https://github.com/BradleyGleavePortfolio/tgp-importer-extension/pull/23) | `15636ff2cc32ef68b2a3efd7dbd1e9f766bcafad` | **T4** | scoped | Pinned secrets-scanner policy, hooks, workflow and fail-closed enforcement. |
| [#21](https://github.com/BradleyGleavePortfolio/tgp-importer-extension/pull/21) | `fc7fdf6e50df08cccad86da37c8b0f15f4b72e81` | **T4** | scoped | Actual cumulative diff includes source-fetch/replay trust boundary, worker/network behavior and manifest; not only a pagination function. |
| [#20](https://github.com/BradleyGleavePortfolio/tgp-importer-extension/pull/20) | `93a678a4e4c6b1703f95c313ea342deb59f33a72` | **T4** | provisional | Role inference/privacy guards and unresolved observation-membership trust dependency; conservative grade until resumed boundary is proven. |
| [#19](https://github.com/BradleyGleavePortfolio/tgp-importer-extension/pull/19) | `69d35e52ad9e83795c5092b6f9ae3876aeed60f1` | **T4** | scoped | Binding acceptance/governance amendment defines native-complete and zero-false-completion release conditions; not cosmetic prose. |

## tgp-agent-context

| PR | Exact current head | Grade | Basis | Consequence rationale |
|---|---|---|---|---|
| [#34](https://github.com/BradleyGleavePortfolio/tgp-agent-context/pull/34) | `076fdd5b7bab860c9e41ca487a826bc06fc5a4ee` | **T4** | provisional | Execution/presentation authorization and cross-device importer acceptance plan; scope of governing permissions must be preserved. |
| [#33](https://github.com/BradleyGleavePortfolio/tgp-agent-context/pull/33) | `54749b99427b91f4dd0c0026893bd6333a70d7d0` | **T4** | provisional | Public execution evidence/recovery checkpoint with privacy, provenance and acceptance consequences. |
| [#31](https://github.com/BradleyGleavePortfolio/tgp-agent-context/pull/31) | `3300d31539df4428c9b8f5f85215a4842c30728c` | **T4** | provisional | Importer identity/reconstruction/recovery and Roman journey authority contracts. |
| [#30](https://github.com/BradleyGleavePortfolio/tgp-agent-context/pull/30) | `e786369c65289a5de908e3ce40c065998aab068a` | **T4** | provisional | Operational permission/state reconciliation affects which critical work is considered authorized. |
| [#29](https://github.com/BradleyGleavePortfolio/tgp-agent-context/pull/29) | `11da3905dbe456f8c58858eaae4339c09c5ef42f` | **T4** | scoped | Governing product/operator decision doctrine change; G01 governance tier. |
| [#11](https://github.com/BradleyGleavePortfolio/tgp-agent-context/pull/11) | `41c61866c139076fc9d714df701d53ef6e386140` | **T3** | provisional | Cross-platform Android parity integration plan; no critical-boundary change established, regrade before consequential implementation. |
| [#10](https://github.com/BradleyGleavePortfolio/tgp-agent-context/pull/10) | `a9a730ff369c33a891a59f6889be0fe1fa3b2e14` | **T3** | provisional | Shared multi-domain architecture/dependency build-order plan; not isolated cosmetic documentation. |
| [#9](https://github.com/BradleyGleavePortfolio/tgp-agent-context/pull/9) | `708f80b34d4f466ecc863480bb52469fb0441893` | **T2** | provisional | Customer-facing Roman voice behavior policy; no security/authority or shared runtime change established. |
| [#8](https://github.com/BradleyGleavePortfolio/tgp-agent-context/pull/8) | `4e93fdf37f40645d596b8591534cf7143e455e2d` | **T3** | provisional | Shared avatar implementation/integration specification; cross-surface architecture dependency. |
| [#7](https://github.com/BradleyGleavePortfolio/tgp-agent-context/pull/7) | `847d6c8b59f8ca773424cc0c74a20ff6be0a75cd` | **T4** | provisional | Preserved public audit/acceptance evidence publication not freshly privacy/provenance scoped; higher plausible tier pending review. |
| [#6](https://github.com/BradleyGleavePortfolio/tgp-agent-context/pull/6) | `d194405bcf833a28d2c90c4e2231095edfcfe5a2` | **T4** | scoped | Dunning/money behavior and customer financial action requirements. |
| [#5](https://github.com/BradleyGleavePortfolio/tgp-agent-context/pull/5) | `c9b3bfd795870953ce7b7c4f21009616782325f6` | **T4** | scoped | Undo/autosave/delete recovery requirements for persistent workout/health data. |
| [#4](https://github.com/BradleyGleavePortfolio/tgp-agent-context/pull/4) | `672de4c221e02b0290e282ccbe757134c41a8c03` | **T4** | scoped | Bank-account payouts and first-payment money/credential boundaries. |
| [#3](https://github.com/BradleyGleavePortfolio/tgp-agent-context/pull/3) | `8244144b4b6c2c0393e4e7726a8da1ddd8183a6b` | **T4** | provisional | Voice capture/logging of sensitive fitness/health information. |
| [#2](https://github.com/BradleyGleavePortfolio/tgp-agent-context/pull/2) | `1f3a68122d12d1b0c6a6c0e06f8ad11cb9ca9908` | **T4** | provisional | Digital contracts/e-signatures involve personal information and trusted consequential authorization. |

## Coverage and authority

64 distinct open PRs have explicit grades and full head identities. Exact reported bases, titles, routing and observation timestamps are retained in `PUBLIC_PR_GRADES.json`. No remote PR descriptions, source, protection settings or merge state were changed by this register. Authoritative active writer/slot state is `execution/DISPATCHES.md`; slice contracts remain separate from this preserved-PR inventory.
