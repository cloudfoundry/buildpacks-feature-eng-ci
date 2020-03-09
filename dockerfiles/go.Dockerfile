FROM cfbuildpacks/feature-eng-ci:minimal

ARG GO_VERSION=1.14
RUN curl https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz \
    --silent \
    --location \
    --output /usr/local/go${GO_VERSION}.tar.gz


RUN tar xzf /usr/local/go${GO_VERSION}.tar.gz -C /usr/local
RUN rm /usr/local/go${GO_VERSION}.tar.gz 

ENV PATH="/usr/local/go/bin:${PATH}"
