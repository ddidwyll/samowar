defmodule Device.Calc do
  @terms %{
    term_top_raw: :term_top,
    term_bottom_raw: :term_bottom,
    term_cube_raw: :term_cube
  }

  def handle(param_key, %{new: value})
      when is_map_key(@terms, param_key) do
    Device.get([:state, :current, :press_atm_raw])
    |> Helpers.TempNormalizer.calc(value)
    |> IO.inspect()
    |> Bus.push(:calc, :calc_result, @terms[param_key])
  end

  def handle(:press_atm_raw, %{new: new_press}) do
    Enum.each(@terms, fn {param_key, _} ->
      term_value = Device.get([:state, :current, param_key])

      Helpers.TempNormalizer.calc(new_press, term_value)
      |> IO.inspect()
      |> Bus.push(:calc, :calc_result, @terms[param_key])
    end)
  end

  def handle(param_key, _)
      when param_key in [:term_bottom_raw, :term_top_raw] do
    IO.puts("TODO")
  end

  def handle(_param_key, _value) do
    # De.bug(value, param_key)
  end
end
