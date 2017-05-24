FROM ruby:2.4.0-alpine
MAINTAINER Daisuke Fujita <dtanshi45@gmail.com> (@dtan4)

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION

RUN apk add --no-cache git

RUN git clone https://github.com/dtan4/terraforming.git  /app/

WORKDIR /app

RUN apk add --no-cache --update bash g++ make \
    && bash /app/script/setup && apk del g++ make

ADD export.sh /app/export.sh

CMD ["terraforming", "help"]
