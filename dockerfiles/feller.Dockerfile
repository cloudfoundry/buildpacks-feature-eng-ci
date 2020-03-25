FROM cfbuildpacks/feature-eng-ci:minimal

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
