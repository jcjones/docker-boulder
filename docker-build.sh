#!/bin/bash

# Tell Pipes to die early
set -o pipefail

die() {
  echo "[FATAL] $*"
  exit 1
}

REPO="quay.io/letsencrypt"
BRANCH=$(cd ~/letsencrypt/boulder; git symbolic-ref --short HEAD)
LABEL=$(cd ~/letsencrypt/boulder ; git rev-parse --short HEAD)
TAG=${REPO}/boulder:${LABEL}

upgrade() {
	cd letsencrypt/boulder

	r=$(git pull) 
	if [ "Already up-to-date." == "$r" ] ; then die "$r" ; fi

	echo "Updated."
}

compile() {
	cd letsencrypt/boulder
	make -j 9 || die "Failed"
}

build() {
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
	docker build -t ${TAG} .
	echo "Built ${TAG}"
}

send() {
  docker tag -f ${TAG} ${REPO}/boulder:latest
  docker tag -f ${TAG} ${REPO}/boulder:${BRANCH}

  docker push ${TAG}
  docker push ${REPO}/boulder:${BRANCH}
  docker push ${REPO}/boulder:latest
}

case $1 in
"upgrade") upgrade;;
"compile") compile;;
"build") build;;
"send") send;;
"all") upgrade && compile && build && send;;
*) echo "$0 {upgrade, compile; build, send, all}";;
esac

