// S1 runtime-role probe — read-only, bounded, sanitized. Prepared for the parent
// authority packet; S1 has NOT executed this against production.
//
// Uses the deployed app's OWN connection context: the same @prisma/client and
// generated client that dist/main.js loads, resolving DATABASE_URL exactly as
// the app does (schema.prisma datasource url = env("DATABASE_URL")). No URL,
// password, env value, row data or stack trace is ever printed.
//
// Run from the app working directory inside the running machine:
//   node -e "$(cat whoami-db-role.js)"        (or paste as node -e '...')
// Exit 0 with one JSON line on success; exit 2 with a fixed one-line failure
// class on any error.
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient({ log: [] });
const hardStop = setTimeout(() => { console.error('{"probe":"db-role","error":"timeout"}'); process.exit(2); }, 15000);
(async () => {
  try {
    const rows = await prisma.$transaction(async (tx) => {
      await tx.$executeRawUnsafe('SET LOCAL statement_timeout = 5000');
      await tx.$executeRawUnsafe('SET TRANSACTION READ ONLY');
      return tx.$queryRawUnsafe(
        `SELECT current_user::text AS connected_as,
                session_user::text AS session_role,
                current_database()::text AS db,
                (SELECT r.rolbypassrls FROM pg_roles r WHERE r.rolname = current_user) AS bypassrls,
                (SELECT r.rolsuper     FROM pg_roles r WHERE r.rolname = current_user) AS superuser,
                pg_has_role(current_user, 'service_role', 'MEMBER') AS member_of_service_role,
                pg_has_role(current_user, 'service_role', 'USAGE')  AS inherits_service_role,
                (SELECT count(*)::int FROM pg_roles r WHERE r.rolname IN ('anon','authenticated','service_role')) AS api_roles_present,
                current_setting('server_version') AS server_version`);
    }, { timeout: 10000, maxWait: 5000 });
    const r = rows[0];
    console.log(JSON.stringify({ probe: 'db-role', connected_as: r.connected_as, session_role: r.session_role,
      db: r.db, bypassrls: r.bypassrls, superuser: r.superuser, member_of_service_role: r.member_of_service_role, inherits_service_role: r.inherits_service_role,
      api_roles_present: r.api_roles_present, server_version: r.server_version }));
  } catch (e) {
    const cls = e && e.code ? String(e.code) : (e && e.name ? String(e.name) : 'error');
    console.error(JSON.stringify({ probe: 'db-role', error: cls })); // Prisma error code only (e.g. P1001), never message/URL
    process.exitCode = 2;
  } finally {
    clearTimeout(hardStop);
    await prisma.$disconnect().catch(() => {});
  }
})();
