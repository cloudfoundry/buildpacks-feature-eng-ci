FROM cfbuildpacks/feature-eng-ci:go

RUN curl "https://api.github.com/repos/pivotal/feller/releases/latest" \
      --silent \
      --header "Authorization: token ${GITHUB_TOKEN}" \
    | jq -r '.assets[] | .browser_download_url | select(contains("linux"))' \
    | xargs curl --silent --location --output /usr/local/bin/feller

RUN curl "https://api.github.com/repos/cloudfoundry/packit/releases/latest" \
      --silent \
      --header "Authorization: token ${GITHUB_TOKEN}" \
    | jq -r '.assets[] | .browser_download_url | select(contains("linux"))' \
    | xargs curl --silent --location --output /usr/local/bin/jam