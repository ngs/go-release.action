#!/bin/sh

set -eux

PROJECT_ROOT="/go/src/github.com/${GITHUB_REPOSITORY}"

mkdir -p $PROJECT_ROOT
rmdir $PROJECT_ROOT
ln -s $GITHUB_WORKSPACE $PROJECT_ROOT
cd $PROJECT_ROOT
go get -v ./...

if [ -x "./build.sh" ]; then
  OUTPUT=`./build.sh "${CMD_PATH}"`
else
  go build ${BUILD_FLAGS} "${CMD_PATH}"
  OUTPUT="${BIN_NAME:=$PROJECT_NAME}"

  if [ $GOOS == 'windows' ]; then
    EXT="$OUTPUT.exe"
    mv $OUTPUT $EXT
    OUTPUT=$EXT
  fi
fi

echo ${OUTPUT}
