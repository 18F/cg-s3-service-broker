#!/bin/bash

set -e

cf login -a $CF_API_URL -u $CF_DEPLOY_USERNAME -p $CF_DEPLOY_PASSWORD -o $CF_ORGANIZATION -s $CF_SPACE

cf create-service s3 $SERVICE_PLAN s3-smoke-tests-$SERVICE_PLAN

cf push -f s3-broker-app/ci/smoke-tests/manifest.yml -p s3-broker-app/ci/smoke-tests

cf delete -f s3-smoke-tests
cf delete-service -f s3-smoke-tests-$SERVICE_PLAN
