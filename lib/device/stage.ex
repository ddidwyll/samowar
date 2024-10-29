defmodule Device.Stage do
  use Bus.Stage, :producer_consumer

  def state do
    %{}
  end

  def handle_event(%{type: :device_message} = event) do
    log(event)

    event.name
    |> Device.change(event.payload)
  end

  def handle_event(_), do: :noop
end
