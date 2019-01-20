#!/bin/ash
# shellcheck shell=dash

set -e

if [ -n "$BUILDTIME" ]; then
    echo "#> Preparing compilation..."

    mix local.rebar --force
    mix local.hex --force

    echo "#> Compiling..."
    mix deps.get
    mix compile
    exit 0
fi

echo "#> Applying customizations and patches.."
rsync -av /custom.d/ /home/pleroma/pleroma/

echo "#> Recompiling..."
mix compile

echo "#> Waiting until database is ready..."
while ! pg_isready -U pleroma -d postgres://db:5432/pleroma -t 1; do
    sleep 1s
done

echo "#> Upgrading database..."
mix ecto.migrate

echo "#> Liftoff!"
exec mix phx.server
