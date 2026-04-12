#! /usr/bin/env bash

set -e

pnpm --dir src/client install --frozen-lockfile
pnpm --dir src/client run build

start-db

cleanup() {
    end-db
}

trap cleanup EXIT

dotnet ef database update --project src/towork
TOWORK_UI_ROOT="$(pwd)/src/client/dist" dotnet watch run --project src/towork -lp https
