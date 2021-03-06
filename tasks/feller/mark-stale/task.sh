#!/bin/bash

set -eu
set -o pipefail

#shellcheck source=../../../util/print.sh
source "${PWD}/ci/util/print.sh"

function main() {
  util::print::title "[task] executing"

  feller::mark::stale
}

function feller::mark::stale() {
  util::print::info "[task] * running feller mark-stale"

  feller mark-stale \
    --tracker-project "${TRACKER_PROJECT}" \
    --tracker-token "${TRACKER_TOKEN}" \
    --github-token "${GITHUB_TOKEN}"
}

main "${@}"
