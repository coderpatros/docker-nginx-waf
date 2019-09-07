#!/usr/bin/env bash
docker-compose --file docker-compose.test.yml up --build --abort-on-container-exit
exit $?