FROM ubuntu:bionic

RUN \
  apt-get update && \
  apt-get -qqy install --fix-missing \
    curl \
    vim \
  && \
  apt-get clean
