import Config

config :samowar, env: config_env()
config :samowar, mqtt_client_id: :samowar_server
config :samowar, mqtt_broker_host: ~c"192.168.111.1"
config :samowar, mqtt_broker_port: 1989
config :samowar, mqtt_topic_prefix: "/samowar/"
