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

mix compile

# Migrate db
mix ecto.create
mix ecto.migrate

# Off we go!
exec mix phx.server
