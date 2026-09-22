/**
 * S6-P1 hazard-control ADAPTER — composes "the shipped provider wiring" for
 * whichever tree is under test, so the SAME hazard assertions run before and
 * after the fix and flip behaviourally (not via import/module-load failure).
 *
 *   mode 'd51-singleton': d51a1910 wiring — PersistQueryClientProvider with the
 *     import-time `asyncStoragePersister` singleton and App.tsx's exact props.
 *     The identity prop is ignored, exactly as the shipped composition ignores it.
 *   mode 'postfix-gate': QueryClientProvider + PersistedQueryCacheGate, fed the
 *     identity RootNavigator would commit for the same inputs (token present AND
 *     user cache readable AND no needs_role_selection).
 *
 * Detection is by capability, never by throwing at import: the singleton's
 * presence selects d51; otherwise the gate module is required lazily.
 */
import React from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { QueryClientProvider } from '@tanstack/react-query';
import { PersistQueryClientProvider } from '@tanstack/react-query-persist-client';
import * as qc from '../queryClient';
import { readUserCache } from '../../lib/userCache';
import { secureStorage } from '../secureStorage';

export type HazardMode = 'd51-singleton' | 'postfix-gate';
export const BUSTER = 'tgp-rq-v2-samples';

type GateModule = {
  PersistedQueryCacheGate: React.ComponentType<{ userId: string | null; children: React.ReactNode }>;
};

const singleton = (qc as unknown as { asyncStoragePersister?: unknown }).asyncStoragePersister;
let gateModule: GateModule | null = null;
if (!singleton) {
  try {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    gateModule = require('../PersistedQueryCacheGate') as GateModule;
  } catch {
    gateModule = null;
  }
}
export const mode: HazardMode = singleton ? 'd51-singleton' : 'postfix-gate';
export const adapterAvailable = Boolean(singleton || gateModule);

/** RootNavigator.bootstrapAuth's authorization rule, mirrored for the harness. */
export async function bootstrapIdentity(): Promise<string | null> {
  const token = await secureStorage.getItem('supabase_token');
  const user = await readUserCache();
  const needsRole = await AsyncStorage.getItem('needs_role_selection');
  if (!token || !user || needsRole === 'true') return null;
  return user.id;
}

export function Composition({ identity, children }: { identity: string | null; children: React.ReactNode }) {
  if (mode === 'd51-singleton') {
    return (
      <PersistQueryClientProvider
        client={qc.queryClient}
        persistOptions={{
          persister: singleton as never,
          maxAge: qc.QUERY_CACHE_MAX_AGE,
          buster: BUSTER,
          dehydrateOptions: { shouldDehydrateQuery: (q) => q.meta?.persist !== false },
        }}
      >
        {children}
      </PersistQueryClientProvider>
    );
  }
  if (!gateModule) throw new Error('S6-P1 adapter: neither composition is available in this tree');
  const Gate = gateModule.PersistedQueryCacheGate;
  return (
    <QueryClientProvider client={qc.queryClient}>
      <Gate userId={identity}>{children}</Gate>
    </QueryClientProvider>
  );
}

/** Every persisted-cache key currently on disk with the queries it holds. */
export async function allPersistedQueries(): Promise<Array<{ storageKey: string; queryKey: unknown; data: unknown }>> {
  const keys = (await AsyncStorage.getAllKeys()).filter(
    (k) => k === qc.QUERY_CACHE_KEY_PREFIX || k.startsWith(`${qc.QUERY_CACHE_KEY_PREFIX}:`),
  );
  const out: Array<{ storageKey: string; queryKey: unknown; data: unknown }> = [];
  for (const storageKey of keys) {
    const raw = await AsyncStorage.getItem(storageKey);
    if (!raw) continue;
    const parsed = JSON.parse(raw) as {
      clientState?: { queries?: Array<{ queryKey: unknown; state: { data: unknown } }> };
    };
    for (const q of parsed.clientState?.queries ?? []) out.push({ storageKey, queryKey: q.queryKey, data: q.state.data });
  }
  return out;
}
