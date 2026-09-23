mkdir -p $O/bundle && B=$O/bundle/s5-r4-hooked-$(git rev-parse --short=8 HEAD)-from-public-c23b9d9f.bundle
git bundle create "$B" c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7..HEAD && git bundle verify "$B" && git bundle list-heads "$B" && sha256sum "$B"
