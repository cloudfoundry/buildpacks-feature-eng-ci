#!/bin/bash

set -eu
set -o pipefail

readonly FELLER_DIR="${PWD}/feller"
readonly VERSION_DIR="${PWD}/version"
readonly ARTIFACTS_DIR="${PWD}/artifacts"

#shellcheck source=../../../util/print.sh
source "${PWD}/ci/util/print.sh"

function main() {
  util::print::title "[task] executing"

  feller::package
  release::prepare
}

function feller::package() {
  util::print::info "[task] * building feller"

  pushd "${FELLER_DIR}" > /dev/null || return
    for os in darwin linux; do
      util::print::info "[task] * building feller on ${os}"
      GOOS="${os}" GOARCH="amd64" go build -o "${ARTIFACTS_DIR}/feller-${os}" ./cargo/jam/main.go
      chmod +x "${ARTIFACTS_DIR}/feller-${os}"
    done
  popd > /dev/null || return
}

function release::prepare() {
  util::print::info "[task] * preparing release"

  local version
  version="$(cat "${VERSION_DIR}/version")"

  printf "v%s" "${version}" > "${ARTIFACTS_DIR}/name"
  printf "v%s" "${version}" > "${ARTIFACTS_DIR}/tag"

  pushd "${FELLER_DIR}" > /dev/null || return
    git rev-parse HEAD > "${ARTIFACTS_DIR}/commitish"
  popd > /dev/null || return
}

main "${@}"
