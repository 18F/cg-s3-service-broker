#!/bin/bash

set -e -x

curl -O https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
unzip awscli-bundle.zip
./awscli-bundle/install ./aws
AWS=.local/lib/aws/bin/aws

curl -O -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
JQ=./jq-linux64
chmod +x $JQ

export BUCKET=`echo $VCAP_SERVICES | $JQ -c -r '.s3 | .[0].credentials.bucket'`
export AWS_ACCESS_KEY_ID=`echo $VCAP_SERVICES | $JQ -c -r '.s3 | .[0].credentials.access_key_id'`
export AWS_SECRET_ACCESS_KEY=`echo $VCAP_SERVICES | $JQ -c -r '.s3 | .[0].credentials.secret_access_key'`

$AWS s3 cp smoke-tests.sh s3://$BUCKET/smoke-tests.sh
$AWS s3 ls s3://$BUCKET/smoke-tests.sh
$AWS s3 rm s3://$BUCKET/smoke-tests.sh

python -m SimpleHTTPServer $PORT
