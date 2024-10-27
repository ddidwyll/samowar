defmodule Mqtt.Client do
  # use Bus.Subscriber, mqtt_client: 20

  def subscribe(topic_filter) do
    Env.get(:client_id)
    |> Tortoise.Connection.subscribe_sync(topic_filter)
  end
end
