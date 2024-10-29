defmodule App do
  use State

  def state do
    %{mqtt: %{}}
  end

  def change(path, val_fun) do
    with path <- List.wrap(path),
         {:new, new} <- App.change?(path, val_fun) do
      change_hook(path, new)
      log(path, new)
    else
      _ -> :noop
    end
  end

  def change_hook([:mqtt, :connection], :up) do
    Bus.push!(:app, :mqtt_request, :subscribe)
  end

  def change_hook(_, _), do: :noop

  defp log(path, value) do
    path = Enum.join(path, ".")
    value = if is_binary(value), do: value, else: inspect(value)

    IO.puts("### App change:\t\t#{path} = #{value}")
  end
end
