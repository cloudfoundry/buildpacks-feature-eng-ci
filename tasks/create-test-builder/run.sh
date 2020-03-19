#!/bin/bash

set -eu
set -o pipefail

readonly PACK_DIR="${PWD}/pack"
readonly IMAGE_DIR="${PWD}/image"

#shellcheck source=../../scripts/start-docker
source "${PWD}/ci/scripts/start-docker"

function main() {
  util::docker::start

  pack::install
  builder::create
  builder::export
}

function pack::install() {
  tar -xzf "${PACK_DIR}/pack-"*"-linux.tgz" -C /usr/local/bin
}

function builder::create() {
  cat <<TOML > "/tmp/builder.toml"
description = "empty cflinuxfs3 test builder"

[stack]
  build-image = "cloudfoundry/build:full-cnb"
  id = "org.cloudfoundry.stacks.cflinuxfs3"
  run-image = "cloudfoundry/run:full-cnb"
TOML

  pack create-builder test-builder -b "/tmp/builder.toml"
}

function builder::export() {
  docker save test-builder -o "${IMAGE_DIR}/image.tgz"
}

function trap::handle() {
  util::docker::stop
}

trap "trap::handle" EXIT

main
