B=$O/s3-into-s1s2-$(git rev-parse --short=8 HEAD)-from-public-c23b9d9.bundle
git bundle create "$B" c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7..HEAD && git bundle verify "$B" && sha256sum "$B" | tee $O/bundle.sha256
