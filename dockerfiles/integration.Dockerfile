FROM cfbuildpacks/feature-eng-ci:docker

ARG PACK_VERSION=0.9.0
RUN curl "https://github.com/buildpacks/pack/releases/download/v${PACK_VERSION}/pack-v${PACK_VERSION}-linux.tgz" \
    --silent \
    --location \
    --output /tmp/pack.tgz  \
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
