/**
 * D2 diagnosis repro (no DB): feed the pure S9-A reconciler the facts the S9-B facts service
 * would collect for SET.base after the S8-G pass — every row ledgered `reconstructed`, the two
 * `u10-members` (clients) rows through the LEGACY clientsFamily.persist (string id → ledger
 * target_kind NULL, no provenance), the two workouts rows through persistWorkoutTemplate
 * (workout_plan + provenance created, present_owned), full source-signed coverage, claim success.
 */
const ROOT = '/home/user/workspace/worktrees/fa72-d2/src/scout/reconciliation';
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { reconcile } = require(`${ROOT}/reconcile`);

const P = 's10_unseen';
const KNOWN = (n: number) => ({
  known: true,
  covers_staged_identities: true,
  basis_kind: 'source_signed_enumeration',
  observed_unique: n,
});
const workout = (token: string, id: string) => ({
  token,
  identity: `${P}\u001f${id}`,
  client_linked: false,
  ledger: {
    status: 'reconstructed',
    target_kind: 'workout_plan',
    provenance: { outcome: 'created', native: 'present_owned', reason: null, unresolved_children: {} },
  },
});
const client = (id: string, legacy: boolean) => ({
  token: 'u10-members',
  identity: `${P}\u001f${id}`,
  client_linked: false,
  ledger: legacy
    ? { status: 'reconstructed', target_kind: null, provenance: null }
    : {
        status: 'reconstructed',
        target_kind: 'person',
        provenance: { outcome: 'created', native: 'present_owned', reason: null, unresolved_children: {} },
      },
});
const facts = (withClients: 'legacy' | 'typed' | 'none') => ({
  claim: 'success',
  spec_families: ['clients', 'programs', 'workouts'],
  ledger_without_staged: 0,
  relationships: [],
  coverage: { clients: KNOWN(withClients === 'none' ? 0 : 2), programs: KNOWN(0), workouts: KNOWN(2) },
  families: [
    ...(withClients === 'none'
      ? []
      : [
          {
            family: 'clients',
            mapped: true,
            resolution_reason: null,
            client_owned: false,
            ceiling_exceeded: false,
            identities: [client('u10-m-1', withClients === 'legacy'), client('u10-m-2', withClients === 'legacy')],
            ledger_without_staged: 0,
            qualifiers: ['roster_bridge_pending'],
          },
        ]),
    {
      family: 'workouts',
      mapped: true,
      resolution_reason: null,
      client_owned: false,
      ceiling_exceeded: false,
      identities: [workout('u10-routines', 'u10-w-1'), workout('u10-sessions', 'u10-w-2')],
      ledger_without_staged: 0,
      qualifiers: [],
    },
  ],
});

for (const mode of ['legacy', 'typed', 'none'] as const) {
  const { verdict, report } = reconcile(facts(mode));
  const clients = report.families.find((f: any) => f.family === 'clients');
  console.log(
    JSON.stringify({
      clients_rows: mode,
      verdict,
      conditions: report.conditions,
      required_families: report.required_families,
      clients: clients && {
        staged_unique: clients.staged_unique,
        native_present_verified: clients.native_present_verified,
        unresolved: clients.unresolved,
        reasons: clients.reasons,
        qualifiers: clients.qualifiers,
        completeness_basis: clients.completeness_basis,
        observed_unique: clients.observed_unique,
      },
    }),
  );
}
