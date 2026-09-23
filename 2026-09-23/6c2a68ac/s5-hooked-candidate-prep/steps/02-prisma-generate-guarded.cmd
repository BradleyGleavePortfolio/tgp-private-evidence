echo "PRISMA_ENGINES_MIRROR=${PRISMA_ENGINES_MIRROR-unset}; engines expected from local cache /home/user/.cache/prisma/master/c2990dca…/debian-openssl-3.0.x (S3 16:44Z); if absent there, fetched from binaries.prisma.sh — disclosed network event"
E0=$(ls /home/user/.cache/prisma/master/c2990dca591cba766e3b7ef5d9e8a84796e47ab7/debian-openssl-3.0.x/ 2>/dev/null | wc -l); echo "engine_cache_entries_before=$E0"
CHECKPOINT_DISABLE=1 PRISMA_GENERATE_SKIP_AUTOINSTALL=true PRISMA_HIDE_UPDATE_MESSAGE=1 node node_modules/prisma/build/index.js generate
