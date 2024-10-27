defmodule Mqtt.Handler do
  use Tortoise.Handler

  def connection(status, state) do
    Bus.push!(status, :mqtt, :connection)

    {:ok, state}
  end

  def init(args) do
    {:ok, %{}}
  end

  def subscription(status, topic_filter, state) do
    %{status: status, topic_filter: topic_filter}
    |> Bus.push!(:mqtt, :connection)

    {:ok, state}
  end

  def terminate(reason, state) do
    De.bug(reason, :terminate_reason)
    {:ok, state}
  end

  def handle_message(topic_levels, payload, state) do
    %{payload: payload, topic_levels: topic_levels}
    |> Bus.push!(:mqtt, :connection)

    {:ok, state}
  end
end
