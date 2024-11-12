defmodule Device.Stage do
  use Bus.Stage, :producer_consumer

  def handle_event(%{type: :mqtt_message} = event) do
    event.name
    |> Device.Raw.change(event.payload, :current)
  end

  def handle_event(%{type: :device_request} = event) do
    event.name
    |> Device.Raw.change(event.payload, :desired)
  end

  def handle_event(_), do: :noop
end
