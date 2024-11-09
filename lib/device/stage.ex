defmodule Device.Stage do
  use Bus.Stage, :producer_consumer

  def state do
    %{}
  end

  def handle_event(%{type: :device_message} = event) do
    # log(event)

    event.name
    |> Device.Raw.change(event.payload, :current)
  end

  def handle_event(%{type: :device_request} = event) do
    # log(event)

    event.name
    |> Device.Raw.change(event.payload, :desired)
  end

  def handle_event(_), do: :noop
end
