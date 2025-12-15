#!/bin/bash

GDAL_VERSION=$1
GDAL_VERSION_TAG=${GDAL_VERSION%.*}
RUNTIME=$2
RUNTIME_VERSION=$3
BASE_OS=${4:-al2}  # Optional: al2 (default) or al2023

# Select Dockerfile and package installer based on base OS
if [ "$BASE_OS" = "al2023" ]; then
    DOCKERFILE="dockerfiles/Dockerfile.al2023"
    TAG_SUFFIX="-al2023"
    PKG_INSTALLER="dnf"
    NUMPY_VERSION="2.3.5"
else
    DOCKERFILE="dockerfiles/Dockerfile"
    TAG_SUFFIX=""
    PKG_INSTALLER="yum"
    NUMPY_VERSION="1.25"
fi

echo "Building image for AWS Lambda | GDAL: ${GDAL_VERSION} | Runtime: ${RUNTIME}:${RUNTIME_VERSION} | Base: ${BASE_OS}"

docker buildx build \
    --platform=linux/amd64 \
    --build-arg GDAL_VERSION=${GDAL_VERSION} \
    -f ${DOCKERFILE} \
    -t ghcr.io/lambgeo/lambda-gdal:${GDAL_VERSION_TAG}${TAG_SUFFIX} .

docker buildx build \
    --platform=linux/amd64 \
    --build-arg GDAL_VERSION_TAG=${GDAL_VERSION_TAG}${TAG_SUFFIX} \
    --build-arg RUNTIME_VERSION=${RUNTIME_VERSION} \
    --build-arg PKG_INSTALLER=${PKG_INSTALLER} \
    --build-arg NUMPY_VERSION=${NUMPY_VERSION} \
    -f dockerfiles/runtimes/${RUNTIME} \
    -t ghcr.io/lambgeo/lambda-gdal:${GDAL_VERSION_TAG}${TAG_SUFFIX}-${RUNTIME}${RUNTIME_VERSION} .
