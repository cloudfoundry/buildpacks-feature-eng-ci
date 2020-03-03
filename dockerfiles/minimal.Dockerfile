FROM ubuntu:bionic

RUN \
  apt-get update && \
  apt-get -qqy install --fix-missing \
    vim \
  && \
  apt-get clean
