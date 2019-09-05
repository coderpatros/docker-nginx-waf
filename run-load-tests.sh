#!/usr/bin/env bash
docker-compose --file docker-compose.loadtest.yml up --build --abort-on-container-exit
exit $?