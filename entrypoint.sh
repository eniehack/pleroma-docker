#!/bin/ash
# shellcheck shell=dash

set -e

log() {
    echo -e "\n#> $@\n" 1>&2
}

if [ -n "$BUILDTIME" ]; then
    log "Getting rebar..."
    mix local.rebar --force

    log "Getting hex..."
    mix local.hex --force

    log "Getting dependencies..."
    mix deps.get

    log "Precompiling..."
    mix compile
    exit 0
fi

log "Syncing changes and patches..."
rsync -av /custom.d/ /home/pleroma/pleroma/

log "Recompiling..."
mix compile

log "Waiting for postgres..."
while ! pg_isready -U pleroma -d postgres://db:5432/pleroma -t 1; do
    sleep 1s
done

log "Migrating database..."
mix ecto.migrate

log "Liftoff o/"
exec mix phx.server
