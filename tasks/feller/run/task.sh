#!/bin/bash

set -eu
set -o pipefail

readonly FELLER_DIR="${PWD}/feller"

#shellcheck source=../../../util/print.sh
source "${PWD}/ci/util/print.sh"

function main() {
  util::print::title "[task] executing"

  feller::mark::stale
}

function feller::mark::stale() {
  util::print::title "[task] * running feller mark-stale"

  pushd "${FELLER_DIR}" > /dev/null || return
    go run main.go mark-stale \
      --tracker-project "${TRACKER_PROJECT}" \
      --tracker-token "${TRACKER_TOKEN}" \
      --github-token "${GITHUB_TOKEN}"
  popd > /dev/null || return
}

main "${@}"
