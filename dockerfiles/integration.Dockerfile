FROM cfbuildpacks/feature-eng-ci:docker

RUN apt-get -qqy update \
  && apt-get -qqy install \
    btrfs-progs \
    unzip \
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

# download and install chromedriver
 RUN curl 'https://chromedriver.storage.googleapis.com/2.34/chromedriver_linux64.zip' \
    --silent \
    --location \
    --output "chromedriver.zip" \
   && [ e42a55f9e28c3b545ef7c7727a2b4218c37489b4282e88903e4470e92bc1d967 = $(shasum -a 256 chromedriver.zip | cut -d' ' -f1) ] \
   && unzip chromedriver.zip -d /usr/local/bin/ \
   && rm chromedriver.zip

RUN curl -q https://dl-ssl.google.com/linux/linux_signing_key.pub > tmp.pub && cat tmp.pub | apt-key add - && rm tmp.pub
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list
RUN apt-get -qqy update \
  && apt-get -qqy install \
    google-chrome-stable \
  && apt-get clean

ENV PATH="/usr/local/go/bin:${PATH}"
