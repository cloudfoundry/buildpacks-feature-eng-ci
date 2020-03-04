#!/bin/bash

set -eu
set -o pipefail

function main() {
  local project
  project="$(echo "${SERVICE_ACCOUNT_KEY}" | jq -r .project_id)"

  gcloud auth activate-service-account \
    --key-file <(echo "${SERVICE_ACCOUNT_KEY}")

  gcloud run deploy slack-invitations \
    --image gcr.io/cf-buildpacks/slack-invitations:latest \
    --max-instances 1 \
    --memory "128Mi" \
    --platform managed \
    --set-env-vars "INVITE_URL=${INVITE_URL}" \
    --allow-unauthenticated \
    --project "${project}" \
    --region us-central1
}

main "${@}"
