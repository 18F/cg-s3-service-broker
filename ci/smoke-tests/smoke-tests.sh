#!/bin/bash

set -e -x

curl -O https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
unzip awscli-bundle.zip
./awscli-bundle/install ./aws
AWS=.local/lib/aws/bin/aws

curl -O -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
JQ=./jq-linux64
chmod +x $JQ

echo $VCAP_SERVICES;

# test non-public plan
export BUCKET=`echo $VCAP_SERVICES | $JQ -c -r '.s3[] | select(.plan == "basic") | .credentials.bucket'`
export AWS_ACCESS_KEY_ID=`echo $VCAP_SERVICES | $JQ -c -r '.s3[] | select(.plan == "basic") | .credentials.access_key_id'`
export AWS_SECRET_ACCESS_KEY=`echo $VCAP_SERVICES | $JQ -c -r '.s3[] | select(.plan == "basic") | .credentials.secret_access_key'`
export AWS_DEFAULT_REGION=`echo $VCAP_SERVICES | $JQ -c -r '.s3[] | select(.plan == "basic") | .credentials.region'`

$AWS s3 cp smoke-tests.sh s3://$BUCKET/smoke-tests.sh
$AWS s3 ls s3://$BUCKET/smoke-tests.sh

export URL=http://s3-${AWS_DEFAULT_REGION}.amazonaws.com/$BUCKET/smoke-tests.sh

if [ "$(curl -s -w '%{http_code}' $URL -o /dev/null)" == "200" ]; then
	echo "Expected file to be private but it was public!"
	exit 1;
fi
$AWS s3 rm s3://$BUCKET/smoke-tests.sh


# clean up
unset BUCKET AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION URL

# test public plan
export BUCKET=`echo $VCAP_SERVICES | $JQ -c -r '.s3[] | select(.plan == "basic-public") | .credentials.bucket'`
export AWS_ACCESS_KEY_ID=`echo $VCAP_SERVICES | $JQ -c -r '.s3[] | select(.plan == "basic-public") | .credentials.access_key_id'`
export AWS_SECRET_ACCESS_KEY=`echo $VCAP_SERVICES | $JQ -c -r '.s3[] | select(.plan == "basic-public") | .credentials.secret_access_key'`
export AWS_DEFAULT_REGION=`echo $VCAP_SERVICES | $JQ -c -r '.s3[] | select(.plan == "basic-public") | .credentials.region'`

$AWS s3 cp smoke-tests.sh s3://$BUCKET/smoke-tests.sh
$AWS s3 ls s3://$BUCKET/smoke-tests.sh

export URL=http://s3-${AWS_DEFAULT_REGION}.amazonaws.com/$BUCKET/smoke-tests.sh

if [ "$(curl -s -w '%{http_code}' $URL -o /dev/null)" != "200" ]; then
	echo "Expected file to be public but it was not!"
	exit 1;
fi

$AWS s3 rm s3://$BUCKET/smoke-tests.sh

python -m SimpleHTTPServer $PORT
