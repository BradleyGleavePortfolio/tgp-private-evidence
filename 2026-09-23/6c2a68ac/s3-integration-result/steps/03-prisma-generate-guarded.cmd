echo "PRISMA_ENGINES_MIRROR=${PRISMA_ENGINES_MIRROR-unset} (engine binaries, if fetched, come from binaries.prisma.sh — disclosed network event)"
CHECKPOINT_DISABLE=1 PRISMA_GENERATE_SKIP_AUTOINSTALL=true PRISMA_HIDE_UPDATE_MESSAGE=1 node node_modules/prisma/build/index.js generate
