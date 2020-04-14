#!/bin/bash

set -eu
set -o pipefail

readonly BUILDPACK_DIR="${PWD}/buildpack"
readonly VERSION_DIR="${PWD}/version"
readonly ARTIFACTS_DIR="${PWD}/artifacts"

#shellcheck source=../../../util/print.sh
source "${PWD}/ci/util/print.sh"

function main() {
  util::print::title "[task] executing"
  release::prepare
}

function release::prepare() {
  util::print::info "[task] * preparing release"

  local version
  version="$(cat "${VERSION_DIR}/version")"

  printf "v%s" "${version}" > "${ARTIFACTS_DIR}/name"
  printf "v%s" "${version}" > "${ARTIFACTS_DIR}/tag"

  pushd "${BUILDPACK_DIR}" > /dev/null || return
    git rev-parse HEAD > "${ARTIFACTS_DIR}/commitish"
  popd > /dev/null || return
}

main "${@}"
