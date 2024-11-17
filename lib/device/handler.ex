defmodule Device.Handler do
  @as_is %{
    power: :power
  }

  def inconsistent(param_key, desired) when is_map_key(@as_is, param_key) do
    desired |> Bus.push(:device_handler, :raw_request, @as_is[param_key])
  end

  def inconsistent(_, _), do: :noop
  def inconsistent(_, _, _), do: :noop

  def change(_, _, _), do: :noop
end
