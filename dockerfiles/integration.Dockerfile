FROM cfbuildpacks/feature-eng-ci:docker

RUN apt-get -qqy update \
  && apt-get -qqy install \
    btrfs-progs \
  && apt-get -qqy clean

RUN curl --silent "https://api.github.com/repos/buildpacks/pack/releases/latest" \
    | jq -r '.assets[] | .browser_download_url | select(contains("linux"))' \
    | xargs curl --silent --location --output /tmp/pack.tgz \
  && tar -xzvf /tmp/pack.tgz -C /usr/local/bin \
  && rm /tmp/pack.tgz

ARG GO_VERSION=1.14
RUN curl "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" \
    --silent \
    --location \
    --output "/usr/local/go${GO_VERSION}.tar.gz" \
  && tar xzf "/usr/local/go${GO_VERSION}.tar.gz" -C /usr/local \
  && rm "/usr/local/go${GO_VERSION}.tar.gz"

ENV PATH="/usr/local/go/bin:${PATH}"
