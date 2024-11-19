# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :samowar,
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configures the endpoint
config :samowar, SamowarWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: SamowarWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Samowar.PubSub,
  live_view: [signing_salt: "ILxGlXfi"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :samowar, Samowar.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

config :samowar, env: config_env()
config :samowar, mqtt_client_id: :samowar_server
config :samowar, mqtt_broker_host: ~c"192.168.111.1"
config :samowar, mqtt_broker_port: 1989
config :samowar, mqtt_topic_prefix: "/samowar/"
