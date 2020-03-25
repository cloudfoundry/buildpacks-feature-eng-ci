FROM cfbuildpacks/feature-eng-ci:minimal

RUN curl "https://api.github.com/repos/pivotal/feller/releases/latest" \
      --silent \
      --header "Authorization: token ${GITHUB_TOKEN}" \
    | jq -r '.assets[] | .browser_download_url | select(contains("linux"))' \
    | xargs curl --silent --location --output /usr/local/bin/feller
