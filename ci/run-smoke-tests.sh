#!/bin/sh

set -e -u

cf login -a $CF_API_URL -u $CF_DEPLOY_USERNAME -p $CF_DEPLOY_PASSWORD -o $CF_ORGANIZATION -s $CF_SPACE

cf delete -f s3-smoke-tests

# Clean up existing app and service if present
for SERVICE_PLAN in ${SERVICE_PLANS}; do
	cf delete-service -f s3-smoke-tests-$SERVICE_PLAN
	cf create-service s3 $SERVICE_PLAN s3-smoke-tests-$SERVICE_PLAN
done

# Push test app
cf push -f s3-broker-app/ci/smoke-tests/manifest.yml -p s3-broker-app/ci/smoke-tests

for SERVICE_PLAN in ${SERVICE_PLANS}; do
	# Clean up app and service
	cf delete -f s3-smoke-tests
	cf delete-service -f s3-smoke-tests-$SERVICE_PLAN
done