FROM ubuntu:18.04

RUN apt-get update \
    && apt-get install -y \
        python3

COPY tests.py /tests.py

ENTRYPOINT [ "/tests.py" ]