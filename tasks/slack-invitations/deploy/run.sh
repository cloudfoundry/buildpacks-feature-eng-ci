#!/bin/bash

set -eu
set -o pipefail

readonly APP_PATH="${PWD}/source/tasks/slack-invitations/app"

function main() {
  cf api api.run.pivotal.io
  cf auth "${CLIENT_ID}" "${CLIENT_SECRET}" --client-credentials
  cf target -o "${ORG}" -s "${SPACE}"

  cf push "${APP}" -p "${APP_PATH}" --no-start -b nodejs_buildpack
  cf set-env "${APP}" APP_TOKEN "${APP_TOKEN}"
  cf map-route "${APP}" "${DOMAIN}" --hostname "${SUBDOMAIN}"
  cf start "${APP}"
}

main "${@}"
