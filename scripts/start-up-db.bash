#! /usr/bin/env bash

podman run \
    --name towork-webapp-db \
    -e POSTGRES_PASSWORD="caue1951[]" \
    -d --rm postgres
