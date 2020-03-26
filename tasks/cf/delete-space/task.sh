#!/bin/bash

set -eu
set -o pipefail

readonly SPACE_DIR="${PWD}/space"

#shellcheck source=../../../util/print.sh
source "${PWD}/ci/util/print.sh"

function main() {
  util::print::title "[task] executing"

  space::login
  space::delete
}

function space::login() {
  util::print::info "[task] * targetting CF environment"

  "${SPACE_DIR}/login"
}

function space::delete() {
  util::print::info "[task] * deleting CF space"

  local space
  space="$(cat "${SPACE_DIR}/name")"

  cf delete-space -f "${space}" || true
}

main "${@}"
