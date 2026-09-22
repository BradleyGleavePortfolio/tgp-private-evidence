/**
 * S6-P1 DISCRIMINATING CONTROLS — persisted React Query cache identity (v3).
 *
 * v4 = v3 + blobWith temp-client teardown (C2 residual open handle).
 * v3 = v2 with HARNESS-ONLY corrections from the C1 baseline (00:24Z run):
 *   (a) RNTL 14 `rerender`/`unmount` are async — v2 did not await them, producing
 *       React "overlapping act()" (6x in the log) which leaves actScopeDepth stuck
 *       and stops later renders committing (T4 missing `me`). Now awaited.
 *   (b) T3 requires an IDLE asyncThrottle at the late update (hazard-map H3
 *       precondition): mount `added` executes at t0, warm write at t0+1s, next
 *       window t0+2s. v2 waited 1.2s (throttle busy → late write coalesced with
 *       clear()). Now waits until the window is provably open (2.2s).
 *   (c) Scoped teardown: queryClient gcTime is 10 min; un-destroyed queries hold a
 *       10-minute timer and keep Jest alive. afterEach/afterAll destroy them
 *       (`queryClient.clear()` clears gc timeouts) instead of --forceExit.
 * Hazard assertions and inputs are unchanged from v2.
 *
 * Same inputs, same hazard assertions in both trees; only the composition
 * adapter differs (persistedQueryCache.hazardAdapter.tsx, capability-detected).
 *
 *   d51a1910 ('d51-singleton'):  T1, T2, T3 PASS  = hazards reproduced; T4 PASS.
 *   post-fix  ('postfix-gate'):  T1, T2, T3 FAIL  = behavioural flip;   T4 PASS.
 *
 * T-WIRING and T0 are informational fingerprints of the composition under
 * test; neither can prevent T1-T4 from executing.
 *
 * Real: queryClient, lib/userCache + storage/mmkv shim, authActions.signOut,
 * pinned @tanstack persist primitives, AsyncStorage jest mock. Mocked: network,
 * native notifications, SecureStore, Sentry, analytics, SQLite sync/fasting.
 */
import React from 'react';
import { readFileSync } from 'fs';
import { join } from 'path';
import { act, render, cleanup } from '@testing-library/react-native';
import { Text } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { QueryClient, dehydrate, useQuery } from '@tanstack/react-query';

jest.mock('../api', () => ({
  __esModule: true,
  default: { get: jest.fn(async () => ({ data: {} })), post: jest.fn(async () => ({ data: {} })) },
  usersApi: { updatePushToken: jest.fn(async () => ({ data: {} })) },
  profileApi: { get: jest.fn(async () => ({ data: {} })) },
}));
jest.mock('../sentry', () => ({ setSentryUser: jest.fn() }));
jest.mock('../../lib/analytics', () => ({ reset: jest.fn() }));
jest.mock('../../offline/sync/sync-engine', () => ({ deleteWorkoutLogsForUser: jest.fn(async () => 0) }));
jest.mock('../../db/fastingDb', () => ({
  getActiveFast: jest.fn(async () => null),
  getFastingHistory: jest.fn(async () => []),
  startFast: jest.fn(async () => undefined),
  endFast: jest.fn(async () => undefined),
}));
jest.mock('expo-notifications', () => ({
  cancelScheduledNotificationAsync: jest.fn(async () => undefined),
  getAllScheduledNotificationsAsync: jest.fn(async () => []),
}));
const mockSecure: Record<string, string | null> = {};
jest.mock('../secureStorage', () => ({
  secureStorage: {
    getItem: jest.fn(async (k: string) => mockSecure[k] ?? null),
    setItem: jest.fn(async (k: string, v: string) => {
      mockSecure[k] = v;
    }),
    removeItem: jest.fn(async (k: string) => {
      delete mockSecure[k];
    }),
  },
}));

import * as qc from '../queryClient';
import { setUserCache } from '../../lib/userCache';
import { signOut } from '../authActions';
import {
  mode,
  adapterAvailable,
  Composition,
  bootstrapIdentity,
  allPersistedQueries,
  BUSTER,
} from './persistedQueryCache.hazardAdapter';

const ROOT = join(__dirname, '../../..');
const APP_TSX = readFileSync(join(ROOT, 'App.tsx'), 'utf8');
const ROOT_NAV = readFileSync(join(ROOT, 'src/navigation/RootNavigator.tsx'), 'utf8');
const ANON_KEY = `${qc.QUERY_CACHE_KEY_PREFIX}:anonymous`;
const ME = ['me'] as const;
const USER_B = { id: 'user-B', email: 'b@example.com', phone: '+1 555 0100' };
const USER_C = { id: 'user-C', email: 'c@example.com' };

function blobWith(key: readonly unknown[], data: unknown): string {
  const tmp = new QueryClient();
  tmp.setQueryData(key, data);
  const blob = JSON.stringify({ buster: BUSTER, timestamp: Date.now(), clientState: dehydrate(tmp) });
  tmp.clear(); // v4: destroy the temp query → cancels its default 5-min gc timer (C2 open handle)
  return blob;
}
const onDisk = async (needle: string) => JSON.stringify(await allPersistedQueries()).includes(needle);

function MeProbe() {
  const { data } = useQuery({ queryKey: ME, queryFn: () => new Promise<never>(() => {}), staleTime: Infinity });
  return <Text testID="me">{data ? JSON.stringify(data) : 'none'}</Text>;
}

/** Mount the composition with the identity bootstrap would commit for the current inputs. */
async function mountForCurrentInputs() {
  const identity = await bootstrapIdentity();
  const r = await render(
    <Composition identity={identity}>
      <MeProbe />
    </Composition>,
  );
  await act(async () => {
    await new Promise((res) => setTimeout(res, 30)); // let restore (one storage read) settle
  });
  const recommit = async () => {
    const next = await bootstrapIdentity();
    await r.rerender(
      <Composition identity={next}>
        <MeProbe />
      </Composition>,
    );
    await act(async () => {
      await new Promise((res) => setTimeout(res, 30));
    });
    return next;
  };
  return { ...r, recommit };
}

beforeEach(async () => {
  jest.useRealTimers();
  await AsyncStorage.clear();
  qc.queryClient.clear();
  for (const k of Object.keys(mockSecure)) delete mockSecure[k];
});
afterEach(async () => {
  await cleanup(); // unmount providers → persist subscriptions end
  jest.restoreAllMocks();
  await qc.queryClient.cancelQueries(); // v5 (C6 discriminator): settle in-flight fetches while their Query is still cached, so fetch()'s finally→scheduleGc re-arms on a Query that clear() will destroy
  qc.queryClient.clear(); // destroys queries → clears 10-min gc timers (hang owner)
});
afterAll(async () => {
  await qc.queryClient.cancelQueries(); // v5 (C6 discriminator): same ordering as afterEach, for symmetry
  qc.queryClient.clear();
  qc.queryClient.unmount();
});

/** Wait until the singleton persister's throttle window is provably open again. */
const THROTTLE_IDLE_MS = 2200; // mount write t0 → warm write executes t0+1000 → window opens t0+2000

describe(`S6-P1 hazard controls [mode=${mode}]`, () => {
  it('T-WIRING: the adapter mirrors the shipped composition of this tree', () => {
    expect(adapterAvailable).toBe(true);
    if (mode === 'd51-singleton') {
      expect(APP_TSX).toMatch(/<PersistQueryClientProvider\s+client=\{queryClient\}/);
      expect(APP_TSX).toContain('persister: asyncStoragePersister,');
      expect(APP_TSX).toContain(`buster: '${BUSTER}',`);
    } else {
      expect(APP_TSX).toMatch(/<QueryClientProvider\s+client=\{queryClient\}/);
      expect(APP_TSX).not.toContain('asyncStoragePersister');
      expect(ROOT_NAV).toContain('<PersistedQueryCacheGate');
      expect(qc.QUERY_CACHE_BUSTER).toBe(BUSTER);
    }
  });

  it('T0 (fingerprint): where does an authenticated write land on this composition?', async () => {
    mockSecure['supabase_token'] = 'jwt-B';
    await setUserCache(USER_B);
    await mountForCurrentInputs();
    await act(async () => {
      qc.queryClient.setQueryData(ME, USER_B);
      await new Promise((res) => setTimeout(res, THROTTLE_IDLE_MS));
    });
    const keys = (await allPersistedQueries()).map((q) => q.storageKey);
    // Informational: printed into the log, asserted only for internal consistency.
    // eslint-disable-next-line no-console
    console.info(`[S6-P1 T0] mode=${mode} authenticated write landed on: ${JSON.stringify([...new Set(keys)])}`);
    expect(keys.length).toBeGreaterThan(0);
  });

  it('T1 (H1): authenticated cold start restores B\'s queries from the SHARED anonymous key', async () => {
    mockSecure['supabase_token'] = 'jwt-B';
    await setUserCache(USER_B);
    await AsyncStorage.setItem(ANON_KEY, blobWith(ME, USER_B)); // what a prior session left behind
    const r = await mountForCurrentInputs();
    // HAZARD ASSERTION (expected true on d51, false post-fix): the anonymous blob is what the session sees.
    expect(qc.queryClient.getQueryData(ME)).toEqual(USER_B);
    expect(r.getByTestId('me').props.children).toContain('user-B');
  });

  it('T2 (H2): after a NON-signOut logout, sign-in as C keeps B in memory and re-persists B for C', async () => {
    // Precondition: B's blob on disk, B's user cache present, token gone (bootstrap → unauthenticated).
    await setUserCache(USER_B);
    await AsyncStorage.setItem(ANON_KEY, blobWith(ME, USER_B));
    const r = await mountForCurrentInputs();

    // LoginScreen sign-in sequence (LoginScreen.tsx L85-92), verbatim order, then bootstrap recommits.
    await act(async () => {
      mockSecure['supabase_token'] = 'jwt-C';
      await setUserCache(USER_C);
      await qc.purgePersistedQueryCacheForAllUsers();
    });
    const committed = await r.recommit();
    expect(committed).toBe('user-C');

    // HAZARD ASSERTIONS (expected true on d51, false post-fix)
    expect(qc.queryClient.getQueryData(ME)).toEqual(USER_B); // C's session reads B
    await act(async () => {
      qc.queryClient.setQueryData(['c-only'], { ok: true }); // first cache event of C's session
      await new Promise((res) => setTimeout(res, THROTTLE_IDLE_MS));
    });
    expect(await onDisk('+1 555 0100')).toBe(true); // B's PII persisted again, under C's session
  });

  it('T3 (H3): a cache update landing during signOut survives on disk after the purge (process killed within ~1 s)', async () => {
    mockSecure['supabase_token'] = 'jwt-B';
    await setUserCache(USER_B);
    const r = await mountForCurrentInputs();
    await act(async () => {
      qc.queryClient.setQueryData(ME, USER_B); // warm write executes at the t0+1s window
      await new Promise((res) => setTimeout(res, THROTTLE_IDLE_MS)); // window now open: next write is immediate
    });
    expect(await onDisk('user-B')).toBe(true);

    // Late fetch response lands right AFTER the disk purge and BEFORE queryClient.clear().
    const realPurge = qc.purgePersistedQueryCacheForAllUsers;
    jest.spyOn(qc, 'purgePersistedQueryCacheForAllUsers').mockImplementation(async () => {
      await realPurge();
      qc.queryClient.setQueryData(ME, { ...USER_B, late: true });
      await new Promise((res) => setTimeout(res, 20));
    });
    await act(async () => {
      await signOut('user-B');
    });
    jest.restoreAllMocks();
    await r.recommit(); // bootstrap → unauthenticated (post-fix gate retires; d51 has nothing to retire)

    // "Process killed" here: no further timers. HAZARD ASSERTION (true on d51, false post-fix):
    expect(await onDisk('user-B')).toBe(true);
  });

  it('T4 (H6 positive control — must PASS before AND after): normal signOut leaves nothing to restore', async () => {
    mockSecure['supabase_token'] = 'jwt-B';
    await setUserCache(USER_B);
    const r = await mountForCurrentInputs();
    await act(async () => {
      qc.queryClient.setQueryData(ME, USER_B);
      await new Promise((res) => setTimeout(res, THROTTLE_IDLE_MS));
    });
    expect(await onDisk('user-B')).toBe(true);
    await act(async () => {
      await signOut('user-B');
    });
    await r.recommit();
    await act(async () => {
      await new Promise((res) => setTimeout(res, 1500)); // let any throttled repair write settle
    });
    expect(await onDisk('user-B')).toBe(false);
    expect(qc.queryClient.getQueryData(ME)).toBeUndefined();
    // A cold remount for the next (unauthenticated) session restores nothing.
    await r.unmount();
    const again = await mountForCurrentInputs();
    expect(again.getByTestId('me').props.children).toBe('none');
  });
});
