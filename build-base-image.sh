#!/bin/bash

source ./dsminfo 2> /dev/null

docker build -f Dockerfile.base -t matthiaslohr/dsmpkg-env:"$dsm_version_default"-base --build-arg dsm_version="$dsm_version_default" .

