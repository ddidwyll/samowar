defmodule Device do
  use State.WithDesired

  def params do
    [
      %{id: :term_top, name: "Верх", type: :float, unit: "°C"},
      %{id: :term_bottom, name: "Низ", type: :float, unit: "°C"},
      %{id: :term_cube, name: "Куб", type: :float, unit: "°C"},
      %{id: :term_top_raw, name: "Верх факт", type: :float, unit: "°C"},
      %{id: :term_bottom_raw, name: "Низ факт", type: :float, unit: "°C"},
      %{id: :term_cube_raw, name: "Куб факт", type: :float, unit: "°C"},
      %{id: :term_diff, name: "Разница", type: :float, unit: "°C"},
      %{id: :press_atm_raw, name: "Атм давление", type: :float, unit: "мм"}
    ]
  end

  def handle_change(param, type, value) do
    value |> Bus.push(:"device_#{type}", :change_notice, param.key)

    log(param, type, value)

    @this.Handler.change(param, type, value)
  end

  def handle_inconsistent(param, desired, current) do
    log(param, :inconsistent, %{new: current, old: desired})

    @this.Handler.inconsistent(param, desired)
    @this.Handler.inconsistent(param, desired, current)
  end

  defp log(%{name: param_name, id: param_id} = param, type, value) do
    name =
      if unit = param.unit,
        do: "#{param_name} (#{unit})",
        else: param_name

    [type, param_id]
    |> Log.row({name, value}, "DEV")
  end
end
