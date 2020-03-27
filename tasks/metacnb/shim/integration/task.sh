#!/bin/bash

set -eu
set -o pipefail

readonly SPACE_DIR="${PWD}/space"
readonly BUILDPACK_ACCEPTANCE_TESTS_DIR="${PWD}/buildpack-acceptance-tests"
readonly SHIMMED_BUILDPACK_DIR="${PWD}/shimmed-buildpack"
readonly VERSION_DIR="${PWD}/version"

#shellcheck source=../../../../util/print.sh
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

  local buildpack version cached_flag
  buildpack="$(find "${SHIMMED_BUILDPACK_DIR}" -name "*.zip" | head -1)"
  version="$( cut -d '-' -f 1 "${VERSION_DIR}/version" )"
  cached_flag=""

  if [[ ${CACHED} == "true" ]]; then
    cached_flag="--cached"
  fi

  pushd "${BUILDPACK_ACCEPTANCE_TESTS_DIR}" > /dev/null || return
    ./scripts/integration.sh \
      --language "${LANGUAGE}" \
      --buildpack "${buildpack}" \
      --buildpack-version "${version}" \
      "${cached_flag}"
  popd > /dev/null || return
}

main "${@}"
