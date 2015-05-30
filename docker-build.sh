#!/bin/bash

die() {
  echo "[FATAL] $*"
  exit 1
}

REPO="quay.io/letsencrypt"
LABEL=$(date +%Y%m%d%H%M)

if [ $# -gt 0 ] ; then
  LABEL=$1
  shift
fi

TAG=${REPO}/boulder:${LABEL}

pushd ~/letsencrypt/boulder/
make -j4 || die
popd

echo "Building ${TAG} ..."
sudo docker build -t ${TAG} .

if [ "$1" == "push" ] ; then
  docker push ${TAG}
fi

echo "Built ${TAG}"

