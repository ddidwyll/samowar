defmodule Device.Mapper do
  @as_is %{
    term_d: :temp_top_raw,
    term_c: :temp_bottom_raw,
    term_k: :temp_cube,
    press_a: :press_atm,
    power: :power_raw
  }

  def handle(param_key, %{new: value})
      when is_map_key(@as_is, param_key) do
    value |> Bus.push(:mapper, :device_change, @as_is[param_key])
  end

  def handle(_param_key, _value) do
    # De.bug(value, param_key)
  end
end
