#!/bin/bash

set -eu
set -o pipefail

readonly APP_PATH="${PWD}/source/tasks/slack-invitations/app"

function main() {
  cf api api.run.pivotal.io
  cf auth "${CLIENT_ID}" "${CLIENT_SECRET}" --client-credentials
  cf target -o "${ORG}" -s "${SPACE}"
  cf push "${APP}" -p "${APP_PATH}" --no-start -d "${DOMAIN}" --hostname "${SUBDOMAIN}"
  cf set-env "${APP}" INVITE_URL "${INVITE_URL}"
  cf start "${APP}"
}

main "${@}"
