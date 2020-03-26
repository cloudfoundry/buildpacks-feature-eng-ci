FROM cfbuildpacks/feature-eng-ci:minimal

RUN echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list \
  && curl --silent https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add - \
  && apt-get -qqy update \
  && apt-get -qqy install \
    cf-cli \
  && apt-get clean

ARG BBL_VERSION=7.6.0
RUN curl "https://github.com/cloudfoundry/bosh-bootloader/releases/download/v${BBL_VERSION}/bbl-v${BBL_VERSION}_linux_x86-64" \
  --silent \
  --location \
  --output /usr/local/bin/bbl \
  && [ 2e81f0560310791d604145b39f0b0c21cfd50d2c314fcd58059ff7a006cf12ca = "$(shasum -a 256 /usr/local/bin/bbl | cut -d' ' -f1)" ] \
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
