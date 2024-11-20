defmodule Mqtt.Stage do
  use Bus.Stage, :producer_consumer

  def handle_event(%{type: :mqtt_request} = event),
    do: mqtt_request(event)

  def handle_event(_), do: :noop

  defp mqtt_request(%{name: :subscribe}), do: Mqtt.Client.subscribe()

  defp mqtt_request(%{name: topic, payload: value})
       when is_binary(topic) and is_binary(value) do
    Mqtt.Client.publish(topic, value)
  end

  defp mqtt_request(_), do: :noop

  def handle_info(_msg, state) do
    # De.bug_full({info, state}, @this)

    {:noreply, [], state}
  end
end
