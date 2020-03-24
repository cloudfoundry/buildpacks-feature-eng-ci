#!/bin/bash

set -eu
set -o pipefail

readonly PACKIT_DIR="${PWD}/packit"
readonly VERSION_DIR="${PWD}/version"
readonly ARTIFACTS_DIR="${PWD}/artifacts"

#shellcheck source=../../../util/print.sh
source "${PWD}/ci/util/print.sh"

function main() {
  util::print::title "[task] executing"

  packit::package
  release::prepare
}

function packit::package() {
  util::print::info "[task] * packaging packit"

  pushd "${PACKIT_DIR}" > /dev/null || return
    for os in darwin linux; do
      util::print::info "[task] * building jam on ${os}"
      GOOS="${os}" GOARCH="amd64" go build -o "${ARTIFACTS_DIR}/jam-${os}" ./cargo/jam/main.go
      chmod +x "${ARTIFACTS_DIR}/jam-${os}"
    done
  popd > /dev/null || return
}

function release::prepare() {
  util::print::info "[task] * preparing release"

  local version
  version="$(cat "${VERSION_DIR}/version")"

  printf "v%s" "${version}" > "${ARTIFACTS_DIR}/name"
  printf "v%s" "${version}" > "${ARTIFACTS_DIR}/tag"

  pushd "${PACKIT_DIR}" > /dev/null || return
    git rev-parse HEAD > "${ARTIFACTS_DIR}/commitish"
  popd > /dev/null || return
}

main "${@}"
