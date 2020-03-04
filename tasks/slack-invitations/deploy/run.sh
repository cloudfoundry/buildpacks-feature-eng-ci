#!/bin/bash

set -eu
set -o pipefail

function main() {
  local project service
  project="$(echo "${SERVICE_ACCOUNT_KEY}" | jq -r .project_id)"
  service="slack-invitations"

  gcloud auth activate-service-account \
    --key-file <(echo "${SERVICE_ACCOUNT_KEY}")

  gcloud run deploy "${service}" \
    --image gcr.io/cf-buildpacks/slack-invitations:latest \
    --max-instances 1 \
    --memory "128Mi" \
    --platform managed \
    --set-env-vars "INVITE_URL=${INVITE_URL}" \
    --allow-unauthenticated \
    --project "${project}" \
    --region us-central1

  gcloud beta run domain-mappings create \
    --service "${service}" \
    --domain "${DOMAIN}"
}

main "${@}"
