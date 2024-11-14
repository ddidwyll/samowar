defmodule Device.Mapper do
  @as_is %{
    term_d: :term_top_raw,
    term_c: :term_bottom_raw,
    term_k: :term_cube_raw,
    press_a: :press_atm_raw
  }

  def handle(param_key, %{new: value})
      when is_map_key(@as_is, param_key) do
    value |> Bus.push(:mapper, :mapper_result, @as_is[param_key])
  end

  def handle(_param_key, _value) do
    # De.bug(value, param_key)
  end
end
