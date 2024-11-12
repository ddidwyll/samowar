defmodule Mqtt.Client do
  def subscribe do
    Mqtt.client_id()
    |> Tortoise.Connection.subscribe(Mqtt.subscriptions())
  end

  def publish(topic, value) do
    Mqtt.client_id()
    |> Tortoise.publish(Mqtt.build_topic(topic), value)
  end
end
