#!/bin/bash

set -eu
set -o pipefail

TASKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TASKDIR
TMPDIR=$(mktemp -d)

#shellcheck source=../../../util/print.sh
source "${PWD}/ci/util/print.sh"

function main() {
  util::print::title "[task] executing"

  cfd::checkout
  director::login
  stemcell::windows::upload
  releases::windows::upload
  releases::cflinuxfs4::setup
  releases::capi::upload
  cf::deploy
}

function cfd::checkout() {
  local version
  version="$(jq -r '.["cf-deployment_version"]' < "${PWD}/lock/metadata")"
  echo "Toolsmith env is on cf-deployment version ${version}"

	pushd "${PWD}/cf-deployment" > /dev/null
		echo "Checking out cf-deployment version ${version}"
		git checkout "${version}"
	popd > /dev/null
}

function director::login() {
	util::print::info "[task] * logging into bosh director"

	eval "$(bbl print-env --metadata-file "${PWD}/lock/metadata")"
}

function stemcell::windows::upload() {
  if [[ -z "${DEPLOY_WINDOWS_CELL}" ]]; then
    return
  fi

	util::print::info "[task] * uploading windows stemcell"
	bosh upload-stemcell https://bosh.io/d/stemcells/bosh-google-kvm-windows2019-go_agent
}

function releases::windows::upload() {
  if [[ -z "${DEPLOY_WINDOWS_CELL}" ]]; then
    return
  fi

	util::print::info "[task] * uploading uncompiled releases for windows vms"
	grep url "${PWD}/cf-deployment/operations/experimental/use-compiled-releases-windows.yml" \
    | xargs -I{} echo {} \
    | cut -d" " -f2 \
    | xargs -I{} bosh upload-release {} --fix
}

function releases::cflinuxfs4::setup() {
  if [[ -z "${ADD_CFLINUXFS4_STACK}" ]]; then
    return
  fi

  util::print::info "[task] * creating & uploading cflinuxfs4 release"
  #TODO: upload directly from bosh.io when github.com/bosh-io/releases/pull/106 is merged
  latest="$(
      curl "https://api.github.com/repos/cloudfoundry/cflinuxfs4-release/releases/latest" \
        --location \
        --silent \
      | jq -r -S .tag_name
  )"
  bosh upload-release "https://github.com/cloudfoundry/cflinuxfs4-release/releases/download/${latest}/cflinuxfs4-${latest#"v"}.tgz"

  cat <<EOF > "${TMPDIR}"/add-cflinuxfs4.yml
---
- type: replace
  path: /releases/name=cflinuxfs4?
  value:
    name: cflinuxfs4
    version: ${latest}
- type: replace
  path: /instance_groups/name=api/jobs/name=cloud_controller_ng/properties/cc/stacks
  value:
    - name: cflinuxfs3
      description: Cloud Foundry Linux-based filesystem (Ubuntu 18.04)
    - name: cflinuxfs4
      description: Cloud Foundry Linux-based filesystem (Ubuntu 22.04)
- type: replace
  path: /instance_groups/name=diego-cell/jobs/name=rep/properties/diego/rep/preloaded_rootfses
  value:
    - cflinuxfs3:/var/vcap/packages/cflinuxfs3/rootfs.tar
    - cflinuxfs4:/var/vcap/packages/cflinuxfs4/rootfs.tar
EOF

}

function releases::capi::upload() {
  if [[ -z "${ADD_CFLINUXFS4_STACK}" ]]; then
    return
  fi

  util::print::info "[task] * creating & uploading capi release with cflinuxfs4 lifecycle bundle added"
  git clone https://github.com/cloudfoundry/capi-release
  STACK=cflinuxfs4 ci/tasks/cf/redeploy/modify_capi_spec.rb
  pushd capi-release
    git submodule update --init --recursive
    bosh create-release --force --tarball "dev_releases/capi/capi-9.9.9.tgz" --name capi --version "9.9.9"
    bosh upload-release "dev_releases/capi/capi-9.9.9.tgz"
  popd
}

function cf::deploy() {
	util::print::info "[task] * deploying"

	local name
	name="$(cat "${PWD}/lock/name")"

	pushd "${PWD}/cf-deployment" > /dev/null
    local operations arguments
    operations=(
      "${PWD}/operations/experimental/fast-deploy-with-downtime-and-danger.yml" \
      "${PWD}/operations/use-compiled-releases.yml" \
      "${PWD}/operations/scale-to-one-az.yml" \
      "${PWD}/operations/disable-dynamic-asgs.yml" \
    )

    if [[ -n "${DEPLOY_WINDOWS_CELL}" ]]; then
      operations+=(
        "${PWD}/operations/windows2019-cell.yml" \
        "${PWD}/operations/use-latest-windows2019-stemcell.yml" \
        "${PWD}/operations/use-online-windows2019fs.yml" \
        "${PWD}/operations/experimental/use-compiled-releases-windows.yml"
      )
    fi

    if [[ -n "${SCALE_DIEGO_CELLS}" ]]; then
      operations+=(
        "${TASKDIR}/operations/scale-api-and-diego-cells.yml"
      )
    fi

    if [[ -n "${ADD_CFLINUXFS4_STACK}" ]]; then
      operations+=(
        "${TASKDIR}/operations/use-dev-release-capi.yml" \
        "${TASKDIR}/operations/cflinuxfs4-rootfs-certs.yml" \
        "${TMPDIR}/add-cflinuxfs4.yml"
      )
    fi

    arguments=()
    for operation in "${operations[@]}"; do
      arguments+=(-o "${operation}")
    done

		bosh -n -d cf deploy "${PWD}/cf-deployment.yml" \
			-v system_domain="${name}.cf-app.com" \
      "${arguments[@]}"
	popd > /dev/null
}

main "${@}"
