import Config

config :samowar, env: config_env()
config :samowar, client_id: :samowar_server
config :samowar, brocker_host: ~c"192.168.111.1"
config :samowar, brocker_port: 1989
config :samowar, subscriptions: [{"/samowar/#", 0}]
