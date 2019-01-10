#!/bin/ash
# shellcheck shell=dash

set -e
set -x

if [ -n "$BUILDTIME" ]; then
    mix local.rebar --force
    mix local.hex --force

    mix deps.get
    mix compile
    exit 0
fi

set +x
while ! pg_isready -U pleroma -d postgres://db:5432/pleroma -t 1; do
    echo "[X] Database is starting up..."
    sleep 1s
done
set -x

# Recompile
mix compile

# Migrate db
mix ecto.migrate

# Off we go!
exec mix phx.server
