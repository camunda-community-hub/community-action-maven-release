#!/bin/bash

[ $# != 2 ] && echo "::error::Not enough arguments for prepare-next-development-version" && exit 1

RELEASE_VERSION=$1
DEFAULT_BRANCH=$2

test -z "${RELEASE_VERSION}" && echo "::debug::Skipping Release because release-version is unset" && exit 0

git fetch --no-tags
git checkout "${DEFAULT_BRANCH}"

[ "$(git rev-list -n1 "${RELEASE_VERSION}")" != "$(git rev-list -n1 "${DEFAULT_BRANCH}")" ] && echo "${RELEASE_VERSION} not pointing to tip of ${DEFAULT_BRANCH}" && exit 0
git add ./**pom.xml
git commit -am "release(v${RELEASE_VERSION})"

mvn -B org.apache.maven.plugins:maven-release-plugin:update-versions -DgenerateBackupPoms=false

git add ./**pom.xml
git commit -am "release(v${RELEASE_VERSION}): prepare for next development iteration"
git push
