defmodule Mqtt.Handler do
  use Tortoise.Handler

  def connection(status, state) do
    De.bug(status, :connection_status)
    {:ok, state}
  end

  def init(args) do
    De.bug(args, :init_args)
    {:ok, %{}}
  end

  def subscription(status, topic_filter, state) do
    De.bug({status, topic_filter}, :subscription_topic_filter)
    {:ok, state}
  end

  def terminate(reason, state) do
    De.bug(reason, :terminate_reason)
    {:ok, state}
  end

  def handle_message(topic_levels, payload, state) do
    De.bug_full({topic_levels, payload}, :handle_message_payload)
    {:ok, state}
  end
end
