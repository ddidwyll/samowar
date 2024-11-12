defmodule Bus.Consumer do
  use Bus.Stage, :consumer

  def handle_event(%{type: :app_request} = event) do
    [event.from, event.name]
    |> App.change(event.payload)
  end

  # def handle_event(%{type: :change_notice} = event) do
    # [event.from, event.type]
    # |> Log.row({event.name, event.payload}, "###")
  # end

  def handle_event(_), do: :noop
end
