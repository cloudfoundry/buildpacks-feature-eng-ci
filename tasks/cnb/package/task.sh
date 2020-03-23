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

  buildpack::package
  release::prepare
}

function buildpack::package() {
  util::print::info "[task] * packaging buildpack"

  local version package_dir
  version="$(cat "${VERSION_DIR}/version")"
  package_dir="${ARTIFACTS_DIR}/${LANGUAGE}-cnb-${version}"

  pushd "${BUILDPACK_DIR}" > /dev/null || return
    PACKAGE_DIR="${package_dir}" ./scripts/package.sh \
      --archive \
      --version "${version}"
  popd > /dev/null || return
}

function release::prepare() {
  util::print::info "[task] * preparing release"

  local version
  version="$(cat "${VERSION_DIR}/version")"

  printf "v%s" "${version}" > "${ARTIFACTS_DIR}/name"
  printf "v%s" "${version}" > "${ARTIFACTS_DIR}/tag"
}

main "${@}"
