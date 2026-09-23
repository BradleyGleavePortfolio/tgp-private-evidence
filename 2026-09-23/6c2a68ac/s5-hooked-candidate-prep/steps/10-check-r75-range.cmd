node scripts/check-r75.js --mode=range --base=143d451ead6ccdbebd92ca3031ba7a89867d6cfc --head=HEAD; a=$?; echo "range 143d..HEAD exit=$a"
node scripts/check-r75.js --mode=range --base=c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7 --head=HEAD; b=$?; echo "range c23b..HEAD exit=$b"
[ "$a" = 0 ] && [ "$b" = 0 ]
