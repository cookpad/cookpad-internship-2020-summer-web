#!/bin/bash -xe

cd "$(dirname $0)"

HAKO_DEFINITION=${HAKO_DEFINITION:-$1}
IMAGE_TAG=${CODEBUILD_RESOLVED_SOURCE_VERSION:-$(git rev-parse HEAD)}

if ! test -f ../hako/hako.env.template; then
  echo "hako/hako.env.template not found"
  exit 1
fi

cat ../hako/hako.env.template | sed "s/<%account_id%>/${ACCOUNT_ID}/" > ../hako/hako.env

cd ../hako

if ! test -f ${HAKO_DEFINITION} ; then
  echo "${HAKO_DEFINITION} not found"
  exit 1;
fi

bundle check || bundle install
bundle exec hako rollback ${HAKO_DEFINITION}
