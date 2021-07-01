#!/bin/bash

set -eu
set -o pipefail

readonly LOCK_DIR="${PWD}/lock"
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

  cat <<LOGIN > "${SPACE_DIR}/login"
#!/bin/bash
set +x
LOGIN
  chmod 755 "${SPACE_DIR}/login"
}

function cf::authenticate() {
  util::print::info "[task] * authenticating with CF environment"

  local lock name target environment_type
  lock="$(cat "${LOCK_DIR}/name")"
  name="${lock//[[:digit:]]/}"

  environment_type="cf"
  if [[ "$(jq -r .ops_manager "${LOCK_DIR}/metadata")" != "null" ]]; then
    environment_type="pcf"
  fi

  if [[ "${environment_type}" == "pcf" ]]; then
    target="api.sys.${name}.${DOMAIN}"
  else
    target="api.${name}.${DOMAIN}"
  fi

  cf api "${target}" --skip-ssl-validation

  echo "cf api \"${target}\" --skip-ssl-validation" >> "${SPACE_DIR}/login"

  local password
  if [[ "${environment_type}" == "pcf" ]]; then
    password="$(
      om \
        --target "https://pcf.${name}.cf-app.com" \
        --username pivotalcf \
        --password "$(jq -r .ops_manager.password "${LOCK_DIR}/metadata")" \
        --skip-ssl-validation \
        credentials \
        --product-name cf \
        --credential-reference .uaa.admin_credentials \
        --format json \
      | jq -r .password
    )"

  else
    eval "$(bbl print-env --metadata-file "${LOCK_DIR}/metadata")"
    password="$(credhub get --name "/bosh-${name}/cf/cf_admin_password" --output-json | jq -r .value)"
  fi

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

function util::exit() {
  echo "Will exit..."
  sleep 300
}

trap util::exit EXIT

main "${@}"
