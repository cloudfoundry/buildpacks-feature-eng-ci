FROM alpine:latest

RUN apk add --no-progress --no-cache \
  tzdata \
  curl

ARG DELEGATEBOT_VERSION=0.9.0
RUN curl \
  https://github.com/dpb587/slack-delegate-bot/releases/download/v$DELEGATEBOT_VERSION/delegatebot-$DELEGATEBOT_VERSION-linux-amd64 \
    --silent \
    --location \
    --output /bin/delegatebot \
  && chmod +x /bin/delegatebot

COPY config.yml /etc/config.yml

CMD delegatebot --config /etc/config.yml run
