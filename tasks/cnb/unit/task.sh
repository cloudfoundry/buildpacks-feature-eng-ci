#!/bin/bash

set -eu
set -o pipefail

readonly BUILDPACK_DIR="${PWD}/buildpack"

#shellcheck source=../../../util/print.sh
source "${PWD}/ci/util/print.sh"

function main() {
  util::print::title "[task] executing"

  testuser::setup
  tests::run
}

function testuser::setup() {
  util::print::info "[task] * setting up testuser"

  export GOCACHE=/home/testuser/.cache/go-build
  export GOPATH=/home/testuser/.go-path

  mkdir -p "${GOCACHE}"
  chown -R testuser:testuser /home/testuser
}

function tests::run() {
  util::print::info "[task] * running tests"

  pushd "${BUILDPACK_DIR}" > /dev/null || return
    chpst -u testuser:testuser \
      ./scripts/unit.sh
  popd > /dev/null || return
}

main "${@}"
