#!/bin/bash
# vim: tw=120 ts=2:

# Tell Pipes to die early
set -o pipefail

die() {
  echo "[FATAL] $*"
  exit 1
}

run() {
  echo $*
  $*
}

REPO=${GOPATH}/src/github.com/letsencrypt/boulder
SOURCE=$(cd $(dirname $0); pwd)
DOCKER_REPO="quay.io/letsencrypt/boulder"

BRANCH=${BRANCH:-master}
LABEL=$(cd ${REPO}; git rev-parse --short HEAD)
TAG=${DOCKER_REPO}:${LABEL}


upgrade() {
  cd ${REPO}

  git fetch
  git checkout ${BRANCH}  || die "Could not switch"
  git reset --hard origin/${BRANCH} || die "Could not reset"

  BRANCH=$(cd ${REPO}; git symbolic-ref --short HEAD)
  LABEL=$(cd ${REPO}; git rev-parse --short HEAD)
  TAG=${DOCKER_REPO}:${LABEL}

  imageList=$(docker images | grep ${LABEL})
  if [ "x${imageList}" != "x" ]; then
    die "Already built: ${imageList}"
  fi

  echo "Updated to ${LABEL}."
}

compile() {
  cd ${REPO}
  make -j 9 || die "Failed"
}

build() {
  cd ${SOURCE}

  DEST=$(mktemp -d /tmp/build-dockerXXXX)
  mkdir -p ${DEST}/etc ${DEST}/bin
  cp Dockerfile ${DEST}
  cp default-boulder-config.json ${DEST}/etc
  cp ${REPO}/test/test-ca.pem ${DEST}/etc
  cp ${REPO}/test/test-ca.key ${DEST}/etc
  cp ${REPO}/bin/* ${DEST}/bin

  cd ${DEST}

  # TODO: Check if git is out of date

  echo "Building ${TAG} ..."
  run docker build -t ${TAG} . || die "Couldn't build"
  echo "Built ${TAG}"

  echo "Cleaning up..."
  run rm -rf ${DEST}
}

send() {
  run docker tag -f ${TAG} ${DOCKER_REPO}:latest || die "Couldn't tag latest"
  run docker tag -f ${TAG} ${DOCKER_REPO}:${BRANCH} || die "Couldn't tag branch"

  run docker push ${TAG}
  run docker push ${DOCKER_REPO}:${BRANCH}
  run docker push ${DOCKER_REPO}:latest
}

stats() {
  echo "Currently at ${TAG}"
}

case $1 in
"upgrade") upgrade;;
"compile") compile;;
"build") build;;
"send") send;;
"rebuild") compile && build && send;;
"all") upgrade && compile && build && send;;
"status") stats;;
*) echo "$0 {upgrade, compile; build, send, rebuild, all}";;
esac

