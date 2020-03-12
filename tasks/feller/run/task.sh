#!/bin/bash -eu

readonly FELLER_DIR="${PWD}/feller"

function main() {
  pushd "${FELLER_DIR}" > /dev/null || return
    go run main.go mark-stale \
      --tracker-project "${TRACKER_PROJECT}" \
      --tracker-token "${TRACKER_TOKEN}" \
      --github-token "${GITHUB_TOKEN}"
  popd > /dev/null || return
}

main "${@}"
