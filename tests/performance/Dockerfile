FROM ubuntu:18.04

ENV Z_SCORE=0
ENV TARGET_TOTAL=250000

RUN apt-get update \
    && apt-get install -y \
        python3

COPY tests.py previous-builds.json* /

ENTRYPOINT [ "/tests.py" ]