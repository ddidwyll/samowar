import Config

config :samowar, env: config_env()
config :samowar, client_id: :samowar_server
config :samowar, brocker_host: '192.168.111.217'
config :samowar, brocker_port: 1989
config :samowar, subscriptions: [{"/samowar/#", 0}]
