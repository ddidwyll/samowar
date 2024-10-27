defmodule Bus.Consumer do
  use Bus.Stage, :consumer

  def handle_event(%{type: :state_change} = event) do
    [event.from, event.name]
    |> App.change(event.payload)
  end

  def handle_event(event) do
    IO.puts("### Consumer: #{event}")
  end
end
