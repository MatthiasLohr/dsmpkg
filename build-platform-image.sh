#!/bin/bash

dsm_platform="$1"

source ./dsminfo 2> /dev/null
docker build -f Dockerfile.platform -t matthiaslohr/dsmpkg-env-"$dsm_platform" --build-arg dsm_version="$dsm_version_default" --build-arg dsm_platform="$dsm_platform" .

