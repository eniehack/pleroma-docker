#!/bin/bash

set -e
set -x

if [[ -z "$NO_CONFIG" ]]; then
    ruby /conf/parser.rb /conf/config.yml > config/runtime-config.exs
fi

if [[ -n "$COMPILE_ONLY" ]]; then
    mix deps.get
    mix compile
    exit 0
fi

# Assume that dependencies are compiled and ready to go.
# Remove this assumption when https://github.com/erlang/rebar3/issues/1627 is fixed.
mix compile

# Migrate db
mix ecto.create
mix ecto.migrate

# Off we go!
exec mix phx.server
