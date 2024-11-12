defmodule Mqtt do
  def build_topic(topic),
    do: Env.get!(:mqtt_topic_prefix) <> topic

  def subscriptions, do: [{build_topic("#"), 0}]

  def client_id, do: Env.get!(:mqtt_client_id)
  def broker_host, do: Env.get!(:mqtt_broker_host)
  def broker_port, do: Env.get!(:mqtt_broker_port)
end
