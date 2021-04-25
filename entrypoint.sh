#!/bin/sh

set -eux


OS=`egrep '^ID=' /etc/os-release | cut -d= -f2`
if [ "${OS}" == "ubuntu" ]; then  # If we're not on Alpine we're probably using a Github runner.
# Upgrade Golang
echo "deb http://mirrors.kernel.org/ubuntu hirsute main" >> /etc/apt/sources.list
apt update && apt -fy --allow upgrade
apt -fy install golang-1.16
ln -s /usr/lib/go-1.16 /usr/lib/go
echo "export PATH=$PATH:/usr/lib/go/bin" > /etc/profile.d/02-golang-path.sh
source /etc/profile.d/02-golang-path.sh
fi

if [ -z "${CMD_PATH+x}" ]; then
  echo "::warning file=entrypoint.sh,line=6,col=1::CMD_PATH not set, creating empty."
  export CMD_PATH=""
fi

RUN=`/build.sh`
FILE_LIST="${RUN//[$'\t\r\n '}"

if [ -z "${FILE_LIST}" ]; then
echo "::error file=entrypoint.sh,line=10,col=1::FILE_LIST is empty"
exit 1
else
echo "::info file=/build.sh,line=10,col=1::${FILE_LIST}"
fi


EVENT_DATA=$(cat $GITHUB_EVENT_PATH)
echo $EVENT_DATA | jq .
UPLOAD_URL=$(echo $EVENT_DATA | jq -r .release.upload_url)
UPLOAD_URL=${UPLOAD_URL/\{?name,label\}/}
RELEASE_NAME=$(echo $EVENT_DATA | jq -r .release.tag_name)
PROJECT_NAME=$(basename $GITHUB_REPOSITORY)
NAME="${NAME:-${PROJECT_NAME}_${RELEASE_NAME}}_${GOOS}_${GOARCH}"

if [ -z "${EXTRA_FILES+x}" ]; then
echo "::warning file=entrypoint.sh,line=27,col=1::EXTRA_FILES not set"
fi

FILE_LIST=`echo "${FILE_LIST} ${EXTRA_FILES}" | awk '{$1=$1};1'`

if [ "${GOOS}" == 'windows' ]; then
ARCHIVE=tmp.zip
zip -9r $ARCHIVE ${FILE_LIST}
else
ARCHIVE=tmp.tgz
tar czvpf $ARCHIVE ${FILE_LIST}
fi

CHECKSUM=$(md5sum ${ARCHIVE} | cut -d ' ' -f 1)

curl \
  -X POST \
  --data-binary @${ARCHIVE} \
  -H 'Content-Type: application/octet-stream' \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "${UPLOAD_URL}?name=${NAME}.${ARCHIVE/tmp./}"

curl \
  -X POST \
  --data $CHECKSUM \
  -H 'Content-Type: text/plain' \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "${UPLOAD_URL}?name=${NAME}_checksum.txt"
