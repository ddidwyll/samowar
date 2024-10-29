defmodule Bus.Consumer do
  use Bus.Stage, :consumer

  def handle_event(%{type: :app_change} = event) do
    log(event)

    [event.from, event.name]
    |> App.change(event.payload)
  end

  def handle_event(_), do: :noop
end
