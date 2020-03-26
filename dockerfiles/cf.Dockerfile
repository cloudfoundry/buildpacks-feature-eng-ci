FROM cfbuildpacks/feature-eng-ci:minimal

RUN echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list \
  && curl --silent https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add - \
  && apt-get -qqy update \
  && apt-get -qqy install \
    cf-cli \
  && apt-get clean
