#!/usr/bin/env bash
# Copied from the S1 R3 evidence packet (infra/setup-10-clients.sh); unchanged except this note.
# Step 10: PostgreSQL client tools (psql/pg_dump) from Ubuntu apt. No server here.
. "$(dirname "$0")/_common.sh"; step_begin setup-10-clients
if command -v psql >/dev/null && psql --version | grep -qE ' (1[7-9])\.'; then
  echo "already present: $(psql --version) / $(pg_dump --version)"; step_end; exit 0; fi
set +e; timeout --foreground 600 sudo -n apt-get update -qq; rc=$?; set -e; echo "apt_update_exit=$rc"; [ $rc -eq 0 ] || exit $rc
if apt-cache show postgresql-client-18 >/dev/null 2>&1; then PKG=postgresql-client-18
elif apt-cache show postgresql-client-17 >/dev/null 2>&1; then PKG=postgresql-client-17
else PKG=postgresql-client; fi
echo "package=$PKG candidate=$(apt-cache policy "$PKG" | awk '/Candidate/{print $2}')"
set +e; DEBIAN_FRONTEND=noninteractive timeout --foreground 900 sudo -n apt-get install -y -qq --no-install-recommends "$PKG"; rc=$?; set -e; echo "apt_install_exit=$rc"; [ $rc -eq 0 ] || exit $rc
# Ubuntu's postgresql-common wrapper needs the versioned binaries on PATH; resolve them explicitly
echo "psql=$(command -v psql) -> $(psql --version)"
echo "pg_dump=$(command -v pg_dump) -> $(pg_dump --version)"
psql --version | grep -qE ' (1[7-9])\.' || { echo "client major < 17; refusing"; exit 70; }
echo "dpkg=$(dpkg-query -W -f='${Package} ${Version} ${Status}\n' "$PKG")"
step_end
