#! /usr/bin/env bash

set -e

start-db

cleanup() {
    end-db
}

trap cleanup EXIT

dotnet ef database update --project src/ToworkMVC
dotnet watch run --project src/ToworkMVC -lp https
