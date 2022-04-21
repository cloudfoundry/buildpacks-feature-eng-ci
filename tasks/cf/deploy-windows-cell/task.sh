#!/bin/bash

set -eu
set -o pipefail

#shellcheck source=../../../util/print.sh
source "${PWD}/ci/util/print.sh"

function main() {
	util::print::title "[task] executing"

	cfd::checkout
	director::login
	stemcell::upload
	releases::upload
	cf::deploy
}

function cfd::checkout() {
  local version
  version="$(jq -r '.["cf-deployment_version"]' < ${PWD}/lock/metadata)"
  echo "Toolsmith env is on cf-deployment version ${version}"

	pushd "${PWD}/cf-deployment" > /dev/null
		echo "Checking out cf-deployment version ${version}"
		git checkout "${version}"
	popd > /dev/null
}

function director::login() {
	util::print::info "[task] * logging into bosh director"

	eval "$(bbl print-env --metadata-file ${PWD}/lock/metadata)"
}

function stemcell::upload() {
	util::print::info "[task] * uploading windows stemcell"

	bosh upload-stemcell https://bosh.io/d/stemcells/bosh-google-kvm-windows2019-go_agent
}

function releases::upload() {
	util::print::info "[task] * uploading uncompiled releases for windows vms"

	cat ${PWD}/cf-deployment/operations/experimental/use-compiled-releases-windows.yml | grep url | xargs -I{} echo {} | cut -d" " -f2 | xargs -I{} bosh upload-release {} --fix
}

function cf::deploy() {
	util::print::info "[task] * deploying a windows cell"

	local name
	name="$(cat ${PWD}/lock/name)"

	pushd "${PWD}/cf-deployment" > /dev/null
		bosh -n -d cf deploy "${PWD}/cf-deployment.yml" \
			-v system_domain="${name}.cf-app.com" \
			-o "${PWD}/operations/experimental/fast-deploy-with-downtime-and-danger.yml" \
			-o "${PWD}/operations/use-compiled-releases.yml" \
			-o "${PWD}/operations/scale-to-one-az.yml" \
			-o "${PWD}/operations/windows2019-cell.yml" \
			-o "${PWD}/operations/use-latest-windows2019-stemcell.yml" \
			-o "${PWD}/operations/use-online-windows2019fs.yml" \
			-o "${PWD}/operations/experimental/use-compiled-releases-windows.yml"
	popd > /dev/null
}

main "${@}"
