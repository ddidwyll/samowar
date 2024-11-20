defmodule Helpers.TempNormalizer do
  # Константы
  # Универсальная газовая постоянная в Дж/(моль·K)
  @r 8.314
  # Теплота испарения этанола в Дж/моль (38,56 кДж/моль)
  @delta_h_vap 38560
  # Стандартное атмосферное давление в мм рт. ст.
  @standard_press 760

  @doc """
  Рассчитывает температуру спиртовых паров при стандартном давлении (760 мм рт. ст.)
  зная текущее давление (мм рт. ст.) и температуру спирта в градусах Цельсия.

  ## Пример
      iex> AlcoholVaporTemperature.calculate(750, 78.0)
      78.35
  """
  def calc(press_atm, temp_c) when is_number(press_atm) and is_number(temp_c) do
    t1 = temp_c + 273.15
    p1 = press_atm
    p2 = @standard_press

    # Применяем уравнение Клапейрона-Клаузиуса для нахождения T2
    t2 = 1 / (1 / t1 - :math.log(p2 / p1) * @r / @delta_h_vap)

    (t2 - 273.15)
    |> Value.to_default_precision(%{type: :float})
  end
end
