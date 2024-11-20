defmodule Device.Handler do
  @as_is %{}

  def inconsistent(%{key: param_key}, desired) when is_map_key(@as_is, param_key) do
    desired |> Bus.push(:device_handler, :raw_request, @as_is[param_key])
  end

  def inconsistent(%{key: :power}, desired) do
    with {:ok, loss} <- Device.fetch_current(:power_loss) do
      loss_coef = Number.sub(1, Number.div(loss, 100))

      Number.div(desired, loss_coef)
      |> Bus.push(:device_handler, :raw_request, "power_m")
    end
  end

  def inconsistent(_, _), do: :noop
  def inconsistent(_, _, _), do: :noop

  def change(_, _, _), do: :noop
end
