#!/bin/bash
#
set -x

[[ "$1" != "" ]] && BRANCH="$1" || BRANCH=main
[[ "$BRANCH" == "main" ]] && TAG="latest" || TAG="$BRANCH"
[[ "$ARCHS" == "" ]] && ARCHS="linux/armhf,linux/arm64,linux/amd64"

# rebuild the container
pushd ~/git/docker-planefence-notifier
git checkout $BRANCH || exit 2

#cp -P /etc/ssl/certs/*.crt ./root_certs/etc/ssl/certs
#cp -P /etc/ssl/certs/*.pem ./root_certs/etc/ssl/certs
#cp -P /usr/share/ca-certificates/mozilla/*.crt ./root_certs/usr/share/ca-certificates/mozilla

git pull -a
docker buildx build --progress=plain --compress --push $2 --platform $ARCHS --tag kx1t/radarvirtuel:$TAG .
#rm -rf ./root_certs
popd
