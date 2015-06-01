#!/bin/bash

die() {
  echo "[FATAL] $*"
  exit 1
}

REPO="quay.io/letsencrypt"
LABEL=$(cd ~/letsencrypt/boulder ; git rev-parse --short HEAD)
DEST_LABEL=stable

TAG=${REPO}/boulder:${LABEL}

# TODO: Check if git is out of date

echo "Building ${TAG} ..."
sudo docker build -t ${TAG} .

if [ "$1" == "push" ] ; then
  docker push ${TAG}
  docker push ${REPO}/boulder:${DEST_LABEL}
fi

echo "Built ${TAG}"

