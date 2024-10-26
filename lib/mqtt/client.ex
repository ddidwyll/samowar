defmodule Mqtt.Client do
  def subscribe(topic_filter) do
    Env.get(:client_id)
    |> Tortoise.Connection.subscribe_sync(topic_filter)
  end
end
