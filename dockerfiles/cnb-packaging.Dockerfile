FROM cfbuildpacks/feature-eng-ci:go

ARG GITHUB_TOKEN

RUN curl "https://api.github.com/repos/pivotal/feller/releases/latest" \
      --silent \
      --header "Authorization: token ${GITHUB_TOKEN}" \
    | jq -r '.assets[] | select(.name | contains("linux")) | .url' \
    | xargs curl \
      --silent \
      --location \
      --header "Accept: application/octet-stream" \
      --header "Authorization: token ${GITHUB_TOKEN}" \
      --output /usr/local/bin/feller \
    && chmod +x /usr/local/bin/feller

RUN curl --silent "https://api.github.com/repos/cloudfoundry/packit/releases/latest" \
    | jq -r '.assets[] | .browser_download_url | select(contains("linux"))' \
    | xargs curl --silent --location --output /usr/local/bin/jam \
    && chmod +x /usr/local/bin/jam
