defmodule Helpers.MassCalc do
  # Плотность этанола в кг/л при 20°C
  @base_density 0.789
  # Коэффициент изменения плотности на 1°C
  @density_coefficient 0.0013

  @doc """
  Рассчитывает массу спирта (этанола) при заданных температуре (°C) и объеме (л).

  ## Параметры
    - `temperature` - температура в градусах Цельсия
    - `volume` - объем спирта в литрах

  ## Пример
      iex> AlcoholMassCalculator.calculate_mass(25, 2)
      1.56
  """
  def calculate_mass(temperature, volume) do
    # Рассчитываем плотность спирта при заданной температуре
    density = @base_density - @density_coefficient * (temperature - 20)

    # Рассчитываем массу спирта
    (density * volume)
    |> Value.to_default_precision(%{type: :float})
  end
end
