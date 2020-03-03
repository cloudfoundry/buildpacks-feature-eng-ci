#!/bin/bash

set -eu
set -o pipefail

function main() {
  gcloud info
}

main "${@}"
