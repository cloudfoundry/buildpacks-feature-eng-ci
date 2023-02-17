FROM cfbuildpacks/feature-eng-ci:minimal

RUN echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list \
  && curl --silent https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add - \
  && apt-get -qqy update \
  && apt-get -qqy install \
    cf-cli \
  && apt-get clean

ARG BBL_VERSION=8.4.0
RUN curl "https://github.com/cloudfoundry/bosh-bootloader/releases/download/v${BBL_VERSION}/bbl-v${BBL_VERSION}_linux_x86-64" \
  --silent \
  --location \
  --output /usr/local/bin/bbl \
  && [ f1b6529f9a6435b1c47eaaa09060a5cacd40b75b4fef957b771b4be0ff64c06e = "$(shasum -a 256 /usr/local/bin/bbl | cut -d' ' -f1)" ] \
  && chmod +x /usr/local/bin/bbl


ARG CREDHUB_VERSION=2.4.0
RUN curl "https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_VERSION}/credhub-linux-${CREDHUB_VERSION}.tgz" \
  --silent \
  --location \
  --output /tmp/credhub.tgz \
  && [ 73edaf1ee47323c4f0aa455bcc17303a73c0cf2a6d9156542f1f6b7b1b1aa3db = "$(shasum -a 256 /tmp/credhub.tgz | cut -d' ' -f1)" ] \
  && tar -xzf /tmp/credhub.tgz --to-stdout > /usr/local/bin/credhub \
  && chmod +x /usr/local/bin/credhub \
  && rm /tmp/credhub.tgz

ARG BOSH_VERSION=7.1.3
RUN curl "https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_VERSION}/bosh-cli-${BOSH_VERSION}-linux-amd64" \
  --silent \
  --location \
  --output /usr/local/bin/bosh \
  && [ 901f5fedf406c063be521660ae5f7ccd34e034d3f734e0522138bc5bf71f4e80 = "$(shasum -a 256 /usr/local/bin/bosh | cut -d' ' -f1)" ] \
  && chmod +x /usr/local/bin/bosh
