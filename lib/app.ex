defmodule App do
  use State

  def state do
    %{mqtt: %{}}
  end

  def change(path, val_fun) do
    with path <- List.wrap(path),
         {:changed, value} <- App.change?(path, val_fun) do
      change_hook(path, value.new)
      log(path, value)
    else
      _ -> :noop
    end
  end

  def change_hook([:mqtt, :connection], :up) do
    Bus.push!(:app, :mqtt_request, :subscribe)
  end

  def change_hook(_, _), do: :noop

  defp log(path, %{old: old} = value) do
    path = Enum.join(path, ".")

    if(old, do: :change, else: :new)
    |> Log.row({path, value}, "APP")
  end
end
