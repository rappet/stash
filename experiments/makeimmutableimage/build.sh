#!/usr/bin/env bash
set -x

docker build -t makeimmutableimage:local .
docker run --privileged -it --rm makeimmutableimage:local /build-image.sh