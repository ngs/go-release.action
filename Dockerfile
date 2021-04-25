FROM golang:1.16-alpine

LABEL "com.github.actions.name"="Go Release Binary"
LABEL "com.github.actions.description"="Automate publishing Go build artifacts for GitHub releases"
LABEL "com.github.actions.icon"="cpu"
LABEL "com.github.actions.color"="orange"

LABEL name="Automate publishing Go build artifacts for GitHub releases through GitHub Actions"
LABEL version="1.0.3"
LABEL repository="http://github.com/ngs/go-release.action"
LABEL homepage="http://ngs.io/t/actions/"

LABEL maintainer="Atsushi Nagase <a@ngs.io> (https://ngs.io)"

RUN apk update
RUN apk add --no-cache curl jq git build-base bash tar zip sed

ADD entrypoint.sh /entrypoint.sh
ADD build.sh /build.sh
ENTRYPOINT ["/entrypoint.sh"]
