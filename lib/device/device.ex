defmodule Device do
  use State.WithDesired

  def defaults do
    current = %{
      power_loss: 50
    }

    %{current: current}
  end

  def params do
    [
      %{id: :temp_top, name: "Верх", type: :float, unit: "°C"},
      %{id: :temp_bottom, name: "Низ", type: :float, unit: "°C"},
      %{id: :temp_cube, name: "Куб", type: :float, unit: "°C"},
      %{id: :temp_top_raw, name: "Верх факт", type: :float, unit: "°C"},
      %{id: :temp_bottom_raw, name: "Низ факт", type: :float, unit: "°C"},
      %{id: :temp_diff, name: "Разница", type: :float, unit: "°C"},
      %{id: :press_atm, name: "Атм давление", type: :float, unit: "мм"},
      %{id: :power_raw, name: "Нагрев факт", type: :int, unit: "Вт"},
      %{id: :power_loss, name: "Потери", type: :int, unit: "%"},
      %{id: :power, name: "Нагрев", type: :int, unit: "Вт", write: true}
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
