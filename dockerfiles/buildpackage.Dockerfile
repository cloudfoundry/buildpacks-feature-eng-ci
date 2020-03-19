FROM cfbuildpacks/feature-eng-ci:docker

ARG PACK_VERSION=0.9.0
RUN curl -L -o /tmp/pack.tgz "https://github.com/buildpacks/pack/releases/download/v${PACK_VERSION}/pack-v${PACK_VERSION}-linux.tgz" \
  && tar -xzvf /tmp/pack.tgz -C /usr/local/bin \
  && rm /tmp/pack.tgz

ARG YJ_VERSION=4.0.0
RUN curl -L -o /usr/local/bin/yj "https://github.com/sclevine/yj/releases/download/v${YJ_VERSION}/yj-linux" \
  && chmod +x /usr/local/bin/yj

RUN . /etc/os-release \
  && echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/x${NAME}_${VERSION_ID}/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list \
  && curl -L "https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/x${NAME}_${VERSION_ID}/Release.key" | apt-key add - \
  && apt-get -qqy update \
  && apt-get -qqy install \
    skopeo \
  && apt-get -qqy clean

