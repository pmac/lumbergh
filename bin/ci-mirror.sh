#!/bin/bash -e

# Build an image that renders and copies static content to an S3 bucket
# Ping DMS when complete

export IMAGE=mozmeao/lumbergh-deploy:`git rev-parse --short HEAD`
DOCKERFILE=$(mktemp)
cat Dockerfile >> ${DOCKERFILE}

echo "\
USER root
RUN pip install awscli
USER webdev
CMD ./bin/mirror.sh && ./bin/sync.sh && curl ${DMS} \
" >> ${DOCKERFILE}

docker build --pull -f ${DOCKERFILE} . -t ${IMAGE}
docker run \
      -e AWS_ACCESS_KEY_ID \
      -e AWS_SECRET_ACCESS_KEY \
      -e BUCKET_PATH \
      -e ESCAPED_SITE_URL \
      -e DMS \
      -e DMS_BLOG_FETCH \
      -e CI_COMMIT_SHA \
      -e CI_COMMIT_REF_NAME \
      -e GLOBAL_SET_METADATA \
      ${IMAGE}
