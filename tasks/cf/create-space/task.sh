#!/bin/bash

set -eu
set -o pipefail

readonly LOCK_DIR="${PWD}/lock"
readonly ENVIRONMENTS_DIR="${PWD}/environments"
readonly SPACE_DIR="${PWD}/space"

#shellcheck source=../../../util/print.sh
source "${PWD}/ci/util/print.sh"

function main() {
  util::print::title "[task] executing"

  space::setup
  cf::authenticate
  cf::space::create
}

function space::setup() {
  util::print::info "[task] * creating space login script"

  cat <<-LOGIN > "${SPACE_DIR}/login"
    #!/usr/bin/env sh
    set +x
LOGIN
  chmod 755 "${SPACE_DIR}/login"
}

function cf::authenticate() {
  util::print::info "[task] * authenticating with CF environment"

  local lock name target
  lock="$(cat "${LOCK_DIR}/name")"
  name="${lock//[[:digit:]]/}"
  target="api.${name}.${DOMAIN}"

  cf api "${target}" --skip-ssl-validation

  echo "cf api \"${target}\"" >> "${SPACE_DIR}/login"

  local password
  eval "$(bbl --state-dir "${ENVIRONMENTS_DIR}/${name}" print-env)"
  password="$(credhub get --name "/bosh-${name}/cf/cf_admin_password" --output-json | jq -r .value)"

  cf auth admin "${password}"

  echo "echo \"Logging in to ${target}\"" >> "${SPACE_DIR}/login"
  echo "cf auth admin \"${password}\"" >> "${SPACE_DIR}/login"
}

function cf::space::create() {
  util::print::info "[task] * creating CF space"

  local space
  space="$(openssl rand -base64 32 | base64 | head -c 8 | awk '{print tolower($0)}')"

  cf create-org "${ORG}"
  cf create-space "${space}" -o "${ORG}"

  echo "echo \"Targetting ${ORG} org and ${space} space\"" >> "${SPACE_DIR}/login"
  echo "cf target -o \"${ORG}\" -s \"${space}\"" >> "${SPACE_DIR}/login"

  echo "${space}" > "${SPACE_DIR}/name"
  echo "export SPACE=${space}" > "${SPACE_DIR}/variables"
}

main "${@}"
