FROM cfbuildpacks/feature-eng-ci:go

RUN echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list \
  && curl --silent https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add - \
  && apt-get -qqy update \
  && apt-get -qqy install \
    cf-cli \
    unzip \
  && apt-get clean

RUN apt-get -qqy update \
  && apt-get -qqy install \
    apt-transport-https \
    ca-certificates \
    gnupg-agent \
    software-properties-common \
    btrfs-progs \
  && apt-get -qqy clean \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
  && add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  && apt-get -qqy install \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    iproute2 \
  && apt-get -qqy clean
