# Serving-role verification packet — rev 2 (prepared by S1; NOT executed anywhere live)

Revision 2 applies the parent's corrections: one command only; Node + the app's own `@prisma/client`
(the deployed app is `PrismaService extends PrismaClient` with **no constructor options**, so the datasource
URL comes only from `DATABASE_URL` via `prisma/schema.prisma`); a read-only transaction with finite
connect/statement/transaction timeouts and `finally $disconnect()`; sanitized fixed failure output; no
`--url`/secret argv; no `DIRECT_URL` repetition; no `inet_server_port` (server port is not proof of the
client endpoint); `prisma db execute` is not used because it reports execution, not rows.

## Why Supabase admin metadata cannot substitute
The Supabase management API / `supabase_admin` catalog show which roles *exist* (`postgres` and
`service_role` BYPASSRLS, `anon`/`authenticated` not) and an aggregate of *current* sessions, but not which
role the Fly process authenticates as. `pg_stat_activity` is ambiguous here: Prisma sets no
`application_name`, Supavisor multiplexes/re-labels client sessions, and `postgres`-role idle sessions may be
dashboards, exporters or the app. Source comments ("app runs as service_role", `postgres.<ref>` URL example)
are **source assumptions**. Only the deployed process's own connection context answers the question.

## The command (run inside the deployed machine, from the app working directory `/app`)
Fly machine 860311cee0d008, image `sha256:5eed9e51…c69`, GH_SHA 5076a07a (per execution/FLY_RUNTIME_METADATA.md).
The image contains `node_modules/@prisma/client` and the generated client (`RUN npx prisma generate`).

```
cd /app && node -e "$(cat <<'JS'
<contents of execution/s1-database/whoami-db-role.js>
JS
)"
```
(The parent packet should inline the file verbatim; it is 45 lines. No environment variable is read or
printed by the script itself — `@prisma/client` resolves `DATABASE_URL` internally, exactly as `dist/main.js` does.)

What it does, in order: `new PrismaClient({log: []})` → `$transaction(..., {maxWait: 5000, timeout: 10000})`
→ `SET LOCAL statement_timeout = 5000` → `SET TRANSACTION READ ONLY` → one catalog SELECT → JSON to stdout →
`finally prisma.$disconnect()`; a 15 s hard stop exits 2 if the engine never answers. Nothing is written;
`SET LOCAL` and `SET TRANSACTION` are transaction-scoped.

Returned fields (only these): `connected_as` (current_user), `session_role` (session_user), `db`,
`bypassrls`, `superuser`, `member_of_service_role` (MEMBER), `inherits_service_role` (USAGE),
`api_roles_present` (count of anon/authenticated/service_role roles, 0–3), `server_version`.
No URL, host, password, env value, row data or stack trace can appear in either success or failure output.

## Local validation on the synthetic PG 17.6 fixture (2026-09-20 17:07 UTC, worktree node_modules, Prisma 6.19.3)
| DATABASE_URL points at | stdout / stderr | exit |
|---|---|---|
| role `postgres` (LOGIN, NOSUPERUSER, BYPASSRLS — Supabase-like) | `{"probe":"db-role","connected_as":"postgres","session_role":"postgres","db":"s1_replay","bypassrls":true,"superuser":false,"member_of_service_role":true,"inherits_service_role":true,"api_roles_present":3,"server_version":"17.6"}` | 0 |
| role `authenticator` (NOINHERIT, no bypass) | `{"probe":"db-role","connected_as":"authenticator","session_role":"authenticator","db":"s1_replay","bypassrls":false,"superuser":false,"member_of_service_role":true,"inherits_service_role":false,"api_roles_present":3,"server_version":"17.6"}` | 0 |
| wrong password | `{"probe":"db-role","error":"PrismaClientInitializationError"}` | 2 |
| unreachable host/port | `{"probe":"db-role","error":"PrismaClientInitializationError"}` | 2 |

Note the `authenticator` row: `member_of_service_role=true` with `inherits_service_role=false` is exactly the
PostgREST shape (membership without inheritance), which is why both fields are reported.

## How to read the result (narrow, caller-neutral)
- `bypassrls=true` (or `superuser=true`): the candidate's RLS policies are **not evaluated** for this role, so
  the new deny policies cannot change what the app reads or writes. This does **not** by itself prove that the
  candidate's REVOKEs, function EXECUTE changes or search_path pinning are compatible with every code path — that
  compatibility rests on the S1 caller mapping (Prisma-only access to the 14 tables; no app caller of
  `community_messages_create_month_partition`; helper signatures unchanged) and on the local behavioural
  harness, which must still pass.
- `bypassrls=false`: **not** a contradiction of production behaviour that has not been observed; it means the
  serving role is subject to RLS and every table it touches must be mapped to an explicit permissive policy
  before any live change. The candidate as frozen is *not* safe to apply in that case for the 14 tables
  (it grants only `service_role`), and the parent-path community policies would already be governing this role today.
- `connected_as != session_role` would indicate a pooler-side `SET ROLE`; report both, do not infer.
- `api_roles_present < 3` would mean the assumed Supabase role model does not exist on the serving database.

## Boundaries
S1 has not executed this against any Supabase project or Fly machine, has not fetched secrets, and requests
nothing beyond a single read-only invocation by an authorised operator with the output pasted back verbatim.
