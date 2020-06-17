#!/usr/bin/env bash

set -eux
set -o pipefail

function main() {
  dispatch::send
}

function dispatch::send() {
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
