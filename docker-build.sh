#!/bin/bash

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

REPO=~/letsencrypt/boulder
SOURCE=~/
DOCKER_REPO="quay.io/letsencrypt/boulder"

BRANCH=$(cd ${REPO}; git symbolic-ref --short HEAD)
LABEL=$(cd ${REPO}; git rev-parse --short HEAD)
TAG=${DOCKER_REPO}:${LABEL}


upgrade() {
	cd ${REPO}

	r=$(git pull) 
	if [ "Already up-to-date." == "$r" ] ; then die "$r" ; fi

	BRANCH=$(cd ${REPO}; git symbolic-ref --short HEAD)
	LABEL=$(cd ${REPO}; git rev-parse --short HEAD)
	TAG=${DOCKER_REPO}:${LABEL}

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
	cp ./gocode/src/github.com/letsencrypt/boulder/test/test-ca.pem ${DEST}/etc
	cp ./gocode/src/github.com/letsencrypt/boulder/test/test-ca.key ${DEST}/etc
	cp ~/letsencrypt/boulder/bin/* ${DEST}/bin

	cd ${DEST}

	# TODO: Check if git is out of date

	echo "Building ${TAG} ..."
	run docker build -t ${TAG} .
	echo "Built ${TAG}"

	echo "Cleaning up..."
	run rm -rf ${DEST}
}

send() {
  run docker tag -f ${TAG} ${DOCKER_REPO}:latest
  run docker tag -f ${TAG} ${DOCKER_REPO}:${BRANCH}

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

