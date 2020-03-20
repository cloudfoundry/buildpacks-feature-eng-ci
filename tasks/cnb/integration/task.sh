#!/bin/bash

set -eu
set -o pipefail

readonly BUILDPACK_DIR="${PWD}/buildpack"

#shellcheck source=../../../util/docker.sh
source "${PWD}/ci/util/docker.sh"

#shellcheck source=../../../util/print.sh
source "${PWD}/ci/util/print.sh"

function main() {
  util::docker::start

  util::print::title "[task] executing"
  tests::run
}

function tests::run() {
  util::print::info "[task] * running tests"

  pushd "${BUILDPACK_DIR}" > /dev/null || return
    ./scripts/integration.sh
  popd > /dev/null || return
}

function trap::handle() {
  util::docker::stop
}

trap "trap::handle" EXIT

main "${@}"
