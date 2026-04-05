#! /usr/bin/env bash

set -e

pnpm --dir src/towork-ui install --frozen-lockfile
pnpm --dir src/towork-ui run build

start-db

cleanup() {
    end-db
}

trap cleanup EXIT

dotnet ef database update --project src/ToworkMVC
TOWORK_UI_ROOT="$(pwd)/src/towork-ui/dist" dotnet watch run --project src/ToworkMVC -lp https
