#!/bin/bash

set -eu
set -o pipefail

function main() {
  local project
  project="$(echo "${SERVICE_ACCOUNT_KEY}" | jq -r .project_id)"

  gcloud auth activate-service-account \
    --key-file <(echo "${SERVICE_ACCOUNT_KEY}")

  gcloud run deploy interrupt-bot \
    --image gcr.io/cf-buildpacks/slack-delegate-bot:latest \
    --max-instances 1 \
    --memory "128Mi" \
    --platform managed \
    --set-env-vars "SLACK_TOKEN=${SLACK_TOKEN},PAIRIST_PASSWORD=${PAIRIST_PASSWORD}" \
    --allow-unauthenticated \
    --project "${project}" \
    --region us-central1
}

main "${@}"
