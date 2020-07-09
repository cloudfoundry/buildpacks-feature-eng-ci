#!/usr/bin/env bash

set -eu
set -o pipefail

#shellcheck source=../../../util/print.sh
source "${PWD}/ci/util/print.sh"

function main() {
  util::print::title "[task] executing"

  dispatch::send
}

function dispatch::send() {
  util::print::info "[task] * sending dispatch to tanzu-${BUILDPACK}"

  local version
  version=$(cat release/version)

  curl "https://api.github.com/repos/pivotal-cf/tanzu-${BUILDPACK}/dispatches" \
    -H "Authorization: token ${GIT_TOKEN}" \
    -X POST \
    --fail \
    --show-error \
    --data '{
      "event_type": "oss-update",
      "client_payload": {
        "oss": {
          "version": "'"${version}"'"
        }
    }'
}

main "${@}"
