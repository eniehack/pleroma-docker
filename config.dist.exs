use Mix.Config

# pleroma/pleroma/pleroma are the default credentials for the
# managed database container. "db" is the default interlinked hostname.
# You shouldn't need to change this unless you modifed .env
config :pleroma, Pleroma.Repo,
    adapter: Ecto.Adapters.Postgres,
    username: "pleroma",
    password: "pleroma",
    database: "pleroma",
    hostname: "db",
    pool_size: 10

# vvv Your awesome config options go here vvv
