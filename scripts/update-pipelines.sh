#!/bin/bash

set -e
set -u
set -o pipefail

readonly ROOT_DIR="$(cd "$(dirname "$0")" && cd .. && pwd)"

function main() {
  local include
  include=""

  while [[ "${#}" != 0 ]]; do
    case "${1}" in
      --help|-h)
        usage
        exit 0
        ;;

      --include|-i)
        include="${2}"
        shift 2
        ;;

      "")
        shift 1
        ;;

      *)
        usage
        util::print::error "unknown argument \"${1}\""
    esac
  done

  team::check
  pipelines::update "${include}"
}

function usage() {
  cat <<-USAGE
update-pipelines.sh [OPTIONS]

OPTIONS
  --help, -h                prints the command usage
  --include, -i <pipeline>  specifies a fragment of a pipeline to match

USAGE
}

function team::check() {
  if ! string::contains "$(yq r ~/.flyrc targets.buildpacks.team)" "feature-eng" ; then
    echo "Refusing to update pipelines. Please log in as the 'feature-eng' team using:"
    echo -e "\n  fly -t buildpacks login -n feature-eng\n"
    exit 1
  fi
  return
}

function pipelines::update() {
  local include
  include="${1}"

  local basic_pipelines cloudfoundry_cnb_pipelines paketo_cnb_pipelines metacnb_pipelines
  basic_pipelines=(
    builder-images
    ci-images
    cnb2cf
    feller
    interrupt-bot
    occam
    packit
    slack-invitations
  )
  cloudfoundry_cnb_pipelines=(
    bundler-cnb
    conda-cnb
    dep-cnb
    dotnet-core-aspnet-cnb
    dotnet-core-build-cnb
    dotnet-core-conf-cnb
    dotnet-core-runtime-cnb
    dotnet-core-sdk-cnb
    go-compiler-cnb
    go-mod-cnb
    httpd-cnb
    icu-cnb
    nginx-cnb
    nodejs-compat-cnb
    php-compat-cnb
    php-composer-cnb
    php-dist-cnb
    php-web-cnb
    pip-cnb
    pipenv-cnb
    python-compat-cnb
    python-runtime-cnb
    ruby-cnb
    yarn-install-cnb
  )
  paketo_cnb_pipelines=(
    node-engine
    npm
  )
  metacnb_pipelines=(
    go-cnb
    nodejs-cnb
    php-cnb
    python-cnb
  )

  for name in "${basic_pipelines[@]}"; do
    pipeline::update::basic "${name}" "${include}"
  done

  for name in "${cloudfoundry_cnb_pipelines[@]}"; do
    pipeline::update::cnb::legacy "${name}" "${include}"
  done

  for name in "${paketo_cnb_pipelines[@]}"; do
    pipeline::update::cnb "${name}" "${include}"
  done

  for name in "${metacnb_pipelines[@]}"; do
    pipeline::update::metacnb "${name}" "${include}"
  done
}

function string::contains() {
  local string substring
  string="${1}"
  substring="${2}"

  grep -qi "${substring}" <(echo "${string}")
}

function pipeline::update::basic() {
  local name include
  name="${1}"
  include="${2}"

  if string::contains "${name}" "${include}"; then
    echo "=== UPDATING ${name} ==="
    fly --target buildpacks \
      set-pipeline \
        --pipeline "${name}" \
        --config "${ROOT_DIR}/pipelines/${name}.yml"
    echo
  fi
}

function pipeline::update::cnb() {
  local name include
  name="${1}"
  include="${2}"

  if string::contains "${name}" "${include}"; then
    echo "=== UPDATING ${name} ==="
    fly --target buildpacks \
      set-pipeline \
        --pipeline "${name}" \
        --config <(
          ytt \
            --file "${ROOT_DIR}/pipelines/cnb/template.yml" \
            --file "${ROOT_DIR}/pipelines/cnb/config.yml" \
            --data-value buildpack="${name}" \
            --data-value github_token_name="paketo-buildpacks-github-token" \
            --data-value github_org="paketo-buildpacks"
        )
    echo
  fi
}

function pipeline::update::cnb::legacy() {
  local name include
  name="${1}"
  include="${2}"

  if string::contains "${name}" "${include}"; then
    echo "=== UPDATING ${name} ==="
    fly --target buildpacks \
      set-pipeline \
        --pipeline "${name}" \
        --config <(
          ytt \
            --file "${ROOT_DIR}/pipelines/cnb/template.yml" \
            --file "${ROOT_DIR}/pipelines/cnb/config.yml" \
            --data-value buildpack="${name%-cnb}" \
            --data-value suffix="-cnb"
        )
    echo
  fi
}

function pipeline::update::metacnb() {
  local name include
  name="${1}"
  include="${2}"

  if string::contains "${name}" "${include}"; then
    echo "=== UPDATING ${name} ==="
    fly --target buildpacks \
      set-pipeline \
        --pipeline "${name}" \
        --config <(
          ytt \
            --file "${ROOT_DIR}/pipelines/metacnb/template.yml" \
            --file "${ROOT_DIR}/pipelines/metacnb/config.yml" \
            --data-value buildpack="${name}"
        )
    echo
  fi
}

main "$@"
