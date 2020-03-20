#!/bin/bash

set -eu
set -o pipefail

readonly BP_RELEASE="${PWD}/buildpack"
readonly BUILDPACKAGE_DIR="${PWD}/buildpackage"
readonly BP_DIR=/tmp/buildpack
mkdir -p "${BP_DIR}"

#shellcheck source=../../../util/docker.sh
source "${PWD}/ci/util/docker.sh"

function main() {
  util::docker::start

  buildpack::expand
  buildpack::compress

  buildpackage::toml::write
  buildpackage::create
  buildpackage::export
}

function buildpack::expand() {
  tar -xzf "${BP_RELEASE}/source.tar.gz" -C "${BP_DIR}" --strip-components 1
}

function buildpack::compress() {
  tar -czf "${BP_RELEASE}/source.tar.gz" -C "${BP_DIR}" .
}

function buildpackage::toml::write() {
  yj -tj < "${BP_DIR}/buildpack.toml" \
    | jq -r '.metadata.dependencies[] | select(.id != "lifecycle") | {uri: .uri }' \
    | jq -s --arg uri "${BP_RELEASE}/source.tar.gz" '. | {buildpack: {uri: $uri}, dependencies: .}' \
    | yj -jt \
    > /tmp/package.toml
}

function buildpackage::create() {
  pack create-package buildpackage:latest --package-config /tmp/package.toml
}

function buildpackage::export() {
  skopeo --insecure-policy \
    copy \
      docker-daemon:buildpackage:latest \
      "oci-archive:${BUILDPACKAGE_DIR}/buildpackage.cnb"
}

function trap::handle() {
  util::docker::stop
}


trap "trap::handle" EXIT

main
