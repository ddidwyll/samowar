defmodule Mqtt.Handler do
  use Tortoise.Handler

  def connection(status, state) do
    status |> Bus.push(:mqtt, :app_request, :connection)

    {:ok, state}
  end

  def init(_args) do
    {:ok, %{}}
  end

  def subscription(status, topic_filter, state) do
    topic_filter |> Bus.push(:mqtt, :app_request, :topic_filter)
    status |> Bus.push(:mqtt, :app_request, :subscription_status)

    {:ok, state}
  end

  def terminate(reason, state) do
    De.bug(reason, :terminate_reason)
    {:ok, state}
  end

  def handle_message(topic_levels, payload, state) do
    payload |> Bus.push(:mqtt, :mqtt_message, List.last(topic_levels))

    {:ok, state}
  end
end
