defmodule Device.Calc do
  @terms %{
    temp_top_raw: :temp_top,
    temp_bottom_raw: :temp_bottom
  }

  def handle(:temp_top_raw, %{new: value}) do
    calc_term({:term, :temp_top_raw, value})
    calc_temp_diff()
  end

  def handle(:temp_bottom_raw, %{new: value}) do
    calc_term({:term, :temp_bottom_raw, value})
    calc_temp_diff()
  end

  def handle(:press_atm, %{new: press}) do
    calc_term({:press, press})
  end

  def handle(:power_raw, %{new: power}) do
    calc_power(power)
  end

  def handle(_param_key, _value) do
    # De.bug(value, param_key)
  end

  defp calc_term({:term, param_key, temp}) do
    with {:ok, press} <- Device.fetch_current(:press_atm) do
      Helpers.TempNormalizer.calc(press, temp)
      |> Bus.push(:calc, :device_change, @terms[param_key])
    end
  end

  defp calc_term({:press, press}) do
    Enum.each(@terms, fn {param_key, _} ->
      with {:ok, term} = Device.fetch_current(param_key) do
        Helpers.TempNormalizer.calc(press, term)
        |> Bus.push(:calc, :device_change, @terms[param_key])
      end
    end)
  end

  defp calc_temp_diff do
    with {:ok, bottom} <- Device.fetch_current(:temp_bottom_raw),
         {:ok, top} <- Device.fetch_current(:temp_top_raw) do
      Number.sub(bottom, top)
      |> Bus.push(:calc, :device_change, :temp_diff)
    end
  end

  defp calc_power(power_raw) do
    with {:ok, loss_perc} <- Device.fetch_current(:power_loss) do
      loss_value = Number.mult(power_raw, loss_perc) |> Number.div(100)

      Number.sub(power_raw, loss_value)
      |> Bus.push(:calc, :device_change, :power)
    end
  end
end
