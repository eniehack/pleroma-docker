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

# Listening to 0.0.0.0 is required in a container since the IP is not known in advance
# You should not change the options below this.
# Instead, go change the mapping to your host ports in "docker-compose.yml"

config :pleroma, Pleroma.Web.Endpoint,
    http: [
      ip: {0, 0, 0, 0},
      port: 4000
    ]

config :pleroma, :gopher,
  ip: {0, 0, 0, 0},
  port: 9999

config :esshd,
  port: 2222

# vvv Your awesome config options go here vvv

###
# Here are some example values.
# Uncomment what you need or delete it all.
#
# Want to use pleroma's config generator instead?
# Try `./pleroma mix pleroma.instance gen` and then `./pleroma cp /home/pleroma/pleroma/config/generated_config.exs config.exs`.
#
# Need some inspiration?
# Take a look at https://git.pleroma.social/pleroma/pleroma/tree/develop/config
###

# config :pleroma, Pleroma.Web.Endpoint,
#   url: [host: "example.com", scheme: "https", port: 443],
#   secret_key_base: "<key>"

# config :pleroma, :instance,
#   name: "example instance",
#   email: "example@example.com",
#   limit: 5000,
#   registrations_open: true,
#   dedupe_media: false

# config :pleroma, :media_proxy,
#  enabled: false,
#  redirect_on_failure: true
#  base_url: "https://cache.example.com"

# Configure web push notifications
# config :web_push_encryption, :vapid_details,
#   subject: "mailto:example@example.com",
#   public_key: "<key>",
#   private_key: "<key>"

# Enable Strict-Transport-Security once SSL is working:
# config :pleroma, :http_security,
#   sts: true

# Configure S3 support if desired.
# The public S3 endpoint is different depending on region and provider,
# consult your S3 provider's documentation for details on what to use.
#
# config :pleroma, Pleroma.Uploaders.S3,
#   bucket: "some-bucket",
#   public_endpoint: "https://s3.amazonaws.com"
#
# Configure S3 credentials:
# config :ex_aws, :s3,
#   access_key_id: "xxxxxxxxxxxxx",
#   secret_access_key: "yyyyyyyyyyyy",
#   region: "us-east-1",
#   scheme: "https://"
#
# For using third-party S3 clones like wasabi, also do:
# config :ex_aws, :s3,
#   host: "s3.wasabisys.com"

# Configure Openstack Swift support if desired.
#
# Many openstack deployments are different, so config is left very open with
# no assumptions made on which provider you're using. This should allow very
# wide support without needing separate handlers for OVH, Rackspace, etc.
#
# config :pleroma, Pleroma.Uploaders.Swift,
#  container: "some-container",
#  username: "api-username-yyyy",
#  password: "api-key-xxxx",
#  tenant_id: "<openstack-project/tenant-id>",
#  auth_url: "https://keystone-endpoint.provider.com",
#  storage_url: "https://swift-endpoint.prodider.com/v1/AUTH_<tenant>/<container>",
#  object_url: "https://cdn-endpoint.provider.com/<container>"
#
