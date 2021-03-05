#!/bin/sh

set -e

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "AWS_ACCESS_KEY_ID is missing"
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_SECRET_ACCESS_KEY is missing"
  exit 1
fi

if [ -z "$AWS_REGION" ]; then
  echo "AWS_REGION is missing"
  exit 1
fi

if [ -z "$AWS_S3_BUCKET" ]; then
  echo "AWS_S3_BUCKET is missing"
  exit 1
fi

if [ -z "$AWS_CLOUDFRONT_DISTRIBUTION_ID" ]; then
  echo "AWS_CLOUDFRONT_DISTRIBUTION_ID is missing"
  exit 1
fi

aws configure --profile s3-deploy-action <<-EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF

if [ -n "$COMMAND" ]; then
  COMMAND="build"
fi

if [ -n "$DIST_DIR" ]; then
  DIST_DIR="dist"
fi

sh -c "npm install" \
&& sh -c "npm run ${COMMAND}" \
&& sh -c "aws s3 sync ${DIST_DIR} s3://${AWS_S3_BUCKET}/${AWS_S3_BUCKET_FOLDER} \
              --profile react-deploy-to-s3-action \
              --no-progress"
SUCCESS=$?

if [ $SUCCESS -eq 0 ]
then
  if [ -n "$AWS_CLOUDFRONT_DISTRIBUTION_ID" ]; then
    sh -c "aws cloudfront create-invalidation \
                          --distribution-id ${AWS_CLOUDFRONT_DISTRIBUTION_ID} \
                          --paths /\*"
  fi
fi

aws configure --profile s3-deploy-action <<-EOF > /dev/null 2>&1
null
null
null
text
EOF

if [ $SUCCESS -eq 0 ]
then
  echo "s3-deploy-action successful."
else
  echo "s3-deploy-action failed."
  exit 1
fi