#!/usr/bin/env bash
docker-compose --file docker-compose.performancetest.yml up --build --abort-on-container-exit
exit $?