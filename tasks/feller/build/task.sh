#!/bin/bash

set -eu
set -o pipefail

readonly FELLER_DIR="${PWD}/feller"

#shellcheck source=../../../util/print.sh
source "${PWD}/ci/util/print.sh"

function main() {
  util::print::title "[task] executing"

  feller::build
}

function feller::build() {
  util::print::info "[task] * building feller"

  pushd "${FELLER_DIR}" > /dev/null || return
    go build -o feller main.go
  popd > /dev/null || return
}

main "${@}"
