defmodule Device.Stage do
  use Bus.Stage, :producer_consumer

  def handle_event(%{type: :raw_change} = event) do
    event.name |> Device.Raw.change(event.payload, :current)
  end

  def handle_event(%{type: :raw_request} = event) do
    event.name |> Device.Raw.change(event.payload, :desired)
  end

  def handle_event(%{type: :device_request} = event) do
    event.name |> Device.change(event.payload, :desired)
  end

  def handle_event(%{type: :device_change} = event) do
    event.name |> Device.change(event.payload, :current)
  end

  def handle_event(%{type: :change_notice, from: :raw_current} = event) do
    Device.Mapper.handle(event.name, event.payload)
  end

  def handle_event(%{type: :change_notice, from: :device_current} = event) do
    Device.Calc.handle(event.name, event.payload)
  end

  def handle_event(_), do: :noop
end
