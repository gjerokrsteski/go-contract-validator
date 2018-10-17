#!/usr/bin/env bash
. ./ci-scripts/build-functions.sh

function build_static_binary() {
    local operatingSystem=$1
    local binaryPath=$2
    local VERSION=$(cat VERSION);

    print_info "build ${operatingSystem} binary..."

    GOOS=${operatingSystem} GOARCH=amd64 go build -a -v -ldflags '-extldflags "-static" -w -s -X main.Version='${VERSION} -o ${binaryPath} main.go 2>/dev/null

    assert_exit_code "${operatingSystem} binary not compiled!"
    assert_file_exists "${binaryPath}"
}


build_static_binary "linux" "./dist/contract-validator-amd64-linux"
build_static_binary "darwin" "./dist/contract-validator-amd64-darwin"
build_static_binary "windows" "./dist/contract-validator-amd64-windows.exe"
