#!/bin/bash

set -e
set -x

# Generate a config file
ruby /config/parser.rb /config/config.yml > runtime-config.exs

# Recompile if needed
if [[ ! -z "$RECOMPILE" ]]; then
    mix deps.get
    mix compile
fi

# Migrate db
mix ecto.create
mix ecto.migrate

# Off we go!
exec mix phx.server
