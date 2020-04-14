#!/bin/bash

set -eu
set -o pipefail

readonly BUILDPACK_DIR="${PWD}/buildpack"
readonly BUILD_DIR=/tmp/build
readonly CNB2CF_DIR="${PWD}/cnb2cf"
readonly SHIMMED_BUILDPACK_DIR="${PWD}/shimmed-buildpack"
readonly VERSION_DIR="${PWD}/version"

#shellcheck source=../../../util/print.sh
source "${PWD}/ci/util/print.sh"

function main() {
  util::print::title "[task] executing"

  cnb2cf::build
  build::setup
  buildpack::package
}

function cnb2cf::build() {
  util::print::info "[task] * building cnb2cf"

  pushd "${CNB2CF_DIR}" > /dev/null || return
    ./scripts/build.sh
  popd > /dev/null || return
}

function build::setup() {
  util::print::info "[task] * setting up build directory"

  mkdir -p "${BUILD_DIR}"
  cp "${BUILDPACK_DIR}/compat/buildpack.toml" "${BUILD_DIR}"
}

function buildpack::package() {
  util::print::info "[task] * packaging buildpack"

  local rc_version final_version cached_flag
  rc_version="$(cat "${VERSION_DIR}/version")"
  final_version="$(echo "${rc_version}" | cut -d'-' -f1)"
  cached_flag=""

  if [[ -n "${CACHED}" ]]; then
    cached_flag="--cached"
  fi

  pushd "${BUILD_DIR}" > /dev/null || return
    "${CNB2CF_DIR}/build/cnb2cf" package \
      --version "${final_version}" \
      --stack "cflinuxfs3" \
      "${cached_flag}"
  popd > /dev/null || return

  mv "${BUILD_DIR}/"*"-v${final_version}.zip" "${SHIMMED_BUILDPACK_DIR}/${LANGUAGE}-buildpack-v${rc_version}.zip"
}

main "${@}"
