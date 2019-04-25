#!/usr/bin/env bash

set -e

# LOGFILE="build.log"
# >> $LOGFILE
# date >> $LOGFILE

# One day, this will be hash.
VERSION=$(date +%y%m%d%H%M%S)
WORKING_DIR=$(pwd)

# any pre-build stuff needed? e.g. sbt?

pushd $WORKING_DIR/docker
bash ./prepare.sh
docker build -t todo:$VERSION . # >> $WORKING_DIR/$LOGFILE

## This pushes to our repo specifically, would not necessarily be in a partner build script.
#docker tag hello-node:$VERSION 867655429380.dkr.ecr.us-west-1.amazonaws.com/hello-node:$VERSION >> $LOGFILE
#docker push 867655429380.dkr.ecr.us-west-1.amazonaws.com/hello-node:$VERSION >> $LOGFILE
#
#
## Echo out the image in repo for use with kubectl deployment.
#echo "867655429380.dkr.ecr.us-west-1.amazonaws.com/hello-node:$VERSION"

popd

echo $VERSION > version.tag
