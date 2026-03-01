#!/bin/bash

set -e

ACCOUNT_ID=097600221977
REGION=ap-northeast-2
REPO=python-app
TAG=$(date +%m%d%H%M)
IMAGE=${REPO}:${TAG}
ECR_IMAGE=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${IMAGE}

aws ecr get-login-password --region ${REGION} --profile lsj6445z | \
  docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

docker build --platform linux/amd64 --build-arg ECR_IMAGE=${IMAGE} -t ${IMAGE} .
docker tag ${IMAGE} ${ECR_IMAGE}
docker push ${ECR_IMAGE}

echo "Pushed: ${ECR_IMAGE}"
