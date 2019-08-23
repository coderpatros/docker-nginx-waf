FROM ubuntu:18.04

RUN apt-get update \
    && apt-get install -y \
        curl \
        wget

COPY tests.sh /tests.sh

ENTRYPOINT [ "/tests.sh" ]