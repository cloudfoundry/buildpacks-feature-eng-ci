#!/bin/bash

set -eu
set -o pipefail

readonly CNB2CF_DIR="${PWD}/cnb2cf"
readonly SPACE_DIR="${PWD}/space"

#shellcheck source=../../../util/print.sh
source "${PWD}/ci/util/print.sh"

function main() {
  util::print::title "[task] executing"

  space::login
  tests::run
}

function space::login() {
  util::print::info "[task] * targetting CF environment"

  "${SPACE_DIR}/login"
}

function tests::run() {
  util::print::info "[task] * running tests"

  pushd "${CNB2CF_DIR}" > /dev/null || return
    ./scripts/integration.sh
  popd > /dev/null || return
}

main "${@}"
