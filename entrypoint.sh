#!/bin/sh

set -eux

if [ -z "${CMD_PATH+x}" ]; then
  echo "::warning file=entrypoint.sh,line=6,col=1::CMD_PATH not set"
  export CMD_PATH=""
fi

FILE_LIST=`/build.sh`

#echo "::warning file=/build.sh,line=1,col=5::${FILE_LIST}"

EVENT_DATA=$(cat $GITHUB_EVENT_PATH)
echo $EVENT_DATA | jq .
UPLOAD_URL=$(echo $EVENT_DATA | jq -r .release.upload_url)
UPLOAD_URL=${UPLOAD_URL/\{?name,label\}/}
RELEASE_NAME=$(echo $EVENT_DATA | jq -r .release.tag_name)
PROJECT_NAME=$(basename $GITHUB_REPOSITORY)
NAME="${PROJECT_NAME}_${RELEASE_NAME}_${GOOS}_${GOARCH}"

if [ -z "${EXTRA_FILES+x}" ]; then
echo "::warning file=entrypoint.sh,line=22,col=1::EXTRA_FILES not set"
fi

FILE_LIST="${FILE_LIST} ${EXTRA_FILES}"

FILE_LIST=`echo "${FILE_LIST}" | awk '{$1=$1};1'`

tar cvfz tmp.tgz ${FILE_LIST}
CHECKSUM=$(md5sum tmp.tgz | cut -d ' ' -f 1)

curl \
  -X POST \
  --data-binary @tmp.tgz \
  -H 'Content-Type: application/gzip' \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "${UPLOAD_URL}?name=${NAME}.tar.gz"

curl \
  -X POST \
  --data $CHECKSUM \
  -H 'Content-Type: text/plain' \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "${UPLOAD_URL}?name=${NAME}_checksum.txt"
