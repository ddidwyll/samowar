defmodule App do
  use State

  def state do
    %{mqtt: %{}}
  end

  def change(path, value) do
    path = List.wrap(path)

    if is_function(value) do
      App.update(path, value)
    else
      App.put(path, value)
    end

    change_hook(path, value)
  end

  def change_hook([:mqtt, :connection], :up) do
    Bus.push!(:app, :mqtt_request, :subscribe)
  end

  def change_hook(_, _), do: :noop
end
