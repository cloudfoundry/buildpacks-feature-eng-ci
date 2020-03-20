#!/bin/bash

set -eu
set -o pipefail

readonly PACK_DIR="${PWD}/pack"
readonly IMAGE_DIR="${PWD}/image"

#shellcheck source=../../util/docker.sh
source "${PWD}/ci/util/docker.sh"

#shellcheck source=../../util/print.sh
source "${PWD}/ci/util/print.sh"

function main() {
  util::docker::start

  util::print::title "[task] executing"

  pack::install
  builder::create
  builder::export
}

function pack::install() {
  util::print::info "[task] * installing pack"

  tar -xzf "${PACK_DIR}/pack-"*"-linux.tgz" -C /usr/local/bin
}

function builder::create() {
  util::print::info "[task] * generating builder.toml"

  cat <<TOML > "/tmp/builder.toml"
description = "empty cflinuxfs3 test builder"

[stack]
  build-image = "cloudfoundry/build:full-cnb"
  id = "org.cloudfoundry.stacks.cflinuxfs3"
  run-image = "cloudfoundry/run:full-cnb"
TOML

  util::print::info "[task] * creating builder image"
  pack create-builder test-builder -b "/tmp/builder.toml"
}

function builder::export() {
  util::print::info "[task] * exporting builder image"

  docker save test-builder -o "${IMAGE_DIR}/image.tar"
}

function trap::handle() {
  util::docker::stop
}

trap "trap::handle" EXIT

main
