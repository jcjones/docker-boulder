#!/bin/bash
die() {
  echo $*
  exit 1
}

cd letsencrypt/boulder

r=$(git pull)
if [ "Already up-to-date." == "$r" ] ; then die "$r" ; fi

echo "Updated."
make -j 9 || die "Failed"
