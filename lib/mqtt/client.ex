defmodule Mqtt.Client do
  use Bus.Stage, :producer_consumer

  def handle_event(%{type: :mqtt_request} = event),
    do: mqtt_request(event)

  def handle_event(_), do: :noop

  defp mqtt_request(%{name: :subscribe}), do: subscribe()

  defp mqtt_request(_), do: :noop

  def subscribe do
    env = Env.get!([:client_id, :subscriptions])

    env.client_id
    |> Tortoise.Connection.subscribe(env.subscriptions)
  end

  def handle_info(_msg, state) do
    # De.bug_full({info, state}, @this)

    {:noreply, [], state}
  end
end
