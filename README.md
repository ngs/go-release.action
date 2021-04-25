# Go Release Binary GitHub Action

Automate publishing Go build artifacts for GitHub releases through GitHub Actions.

Detects a build.sh in the go repo and will use that instead.  Expects a list of
file artifacts in a single, space delimited line as output for packaging.

Extra environment variables:
* CMD_PATH
  * Pass extra commands to go build
* EXTRA_FILES
  * Pass a list of extra files for packaging.
    * Example: EXTRA_FILES: "README.md LICENSE"
```yaml
# .github/workflows/release.yaml
defaults:
  run:
    shell: bash
on: 
  release:
    types: [published]
name: Build Release
jobs:
  release-linux-386:
    name: release linux/386
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: compile and release
      uses: ngs/go-release.action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        GOARCH: "386"
        GOOS: linux
        EXTRA_FILES: "LICENSE"
  release-linux-amd64:
    name: release linux/amd64
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: compile and release
      uses: ngs/go-release.action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        GOARCH: amd64
        GOOS: linux
        EXTRA_FILES: "LICENSE"
  release-linux-arm:
    name: release linux/386
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: compile and release
      uses: ngs/go-release.action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        GOARCH: "arm"
        GOOS: linux
        EXTRA_FILES: "LICENSE"
  release-linux-arm64:
    name: release linux/amd64
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: compile and release
      uses: ngs/go-release.action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        GOARCH: arm64
        GOOS: linux
        EXTRA_FILES: "LICENSE"
  release-darwin-amd64:
    name: release darwin/amd64
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: compile and release
      uses: ngs/go-release.action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        GOARCH: amd64
        GOOS: darwin
        EXTRA_FILES: "LICENSE"
  release-windows-386:
    name: release windows/386
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: compile and release
      uses: ngs/go-release.action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        GOARCH: "386"
        GOOS: windows
        EXTRA_FILES: "LICENSE"
  release-windows-amd64:
    name: release windows/amd64
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: compile and release
      uses: ngs/go-release.action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        GOARCH: amd64
        GOOS: windows
        EXTRA_FILES: "LICENSE"
```

Use build.sh to output a list of files for packaging.

```bash
#!/bin/bash
export GOPATH=$HOME/go
if [ "${GITHUB_ACTIONS}" == "true" ]; then
go test 1> debug.out
else
go test -v
fi

go get 1>> debug.out

BINARY="myGOprogram"

if [ $? == 0 ]; then
  if [ "${GOOS}" == "windows" ]; then
    if [ "${GITHUB_ACTIONS}" == "true" ]; then
go build -v -ldflags="-X main.gitver=$(git describe --always --long --dirty)" -o ${BINARY}.exe *.go 1>> debug.out
echo "${BINARY}.exe"
    else
go build -v -ldflags="-X main.gitver=$(git describe --always --long --dirty)" -o ${BINARY}.exe *.go
    fi
  else
    if [ "${GITHUB_ACTIONS}" == "true" ]; then
go build -v -ldflags="-X main.gitver=$(git describe --always --long --dirty)" -o ${BINARY} *.go 1>> debug.out
echo "${BINARY}"
    else
go build -v -ldflags="-X main.gitver=$(git describe --always --long --dirty)" -o ${BINARY} *.go
    fi
  fi
fi
```
