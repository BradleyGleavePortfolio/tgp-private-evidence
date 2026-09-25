#!/usr/bin/env bash
cd /home/user/workspace/tgp-private-evidence/execution/1910a060/landing
P=run/s9a-lock-poll-3.txt
for i in $(seq 1 60); do
  sleep 60
  L=$(lslocks | grep test-validation | awk '{print $1":"$2}')
  echo "$(date -u +%FT%TZ) holder=${L:-none}" >> $P
  if [ -z "$L" ]; then
    echo "launch $(date -u +%FT%TZ) sha=$(sha256sum land-s9a-1910.sh | cut -c1-64) lslocks_holders=0" > run/s9a-compose-3-launch.txt
    COMPOSE_GRANT=1 DONOR_NM_LOCK_SHA=05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44 DONOR_CLIENT_DTS_SHA=9042e713ba5678c99959a345b7b18a60dfc186b2c7d890b8d9c3ed5c8f4edcc6 DONOR_CLIENT_SCHEMA_SHA=b84392033ab86776533007505c31f57930307a210844067a7407ed20d25abf3e timeout -k 30 3600 bash land-s9a-1910.sh compose > run/s9a-compose-3-console.out 2>&1 < /dev/null
    echo "RC=$? $(date -u +%FT%TZ)" > run/s9a-compose-3-terminal.txt
    exit 0
  fi
done
echo "POLL_TIMEOUT $(date -u +%FT%TZ)" >> $P
