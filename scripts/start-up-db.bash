#! /usr/bin/env bash

podman run \
    --name towork-webapp-db \
    -e POSTGRES_PASSWORD="caue1951" \
    -e POSTGRES_USER="podman" \
    -e POSTGRES_DB="towork" \
    -p 5432:5432 \
    -d --rm postgres
