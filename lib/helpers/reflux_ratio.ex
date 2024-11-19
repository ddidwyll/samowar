defmodule Helpers.RefluxRatio do
  # Константа: теплота испарения этанола в Дж/кг
  # в Дж/кг (850 кДж/кг)
  @vaporization_heat 850_000

  @doc """
  Рассчитывает флегмовое число, зная мощность нагрева (Вт), процент теплопотерь
  и скорость отбора продукта (кг/ч).

  ## Параметры
    - `power` - мощность нагрева в Вт
    - `power_loss` - процент теплопотерь
    - `collect_kg_h` - скорость отбора продукта в кг/ч

  ## Пример
      iex> RefluxCalculator.calculate_reflux_ratio(2000, 10, 0.5)
      3.24
  """
  def calc(power, collect_kg_h) do
    # переводим Дж/ч в Вт
    collect_q = collect_kg_h * @vaporization_heat / 3600

    # 3. Рассчитываем тепловой поток, возвращаемый флегмой
    reflux_q = power - collect_q

    # 4. Рассчитываем флегмовое число
    (reflux_q / collect_q)
    |> Value.to_default_precision(%{type: :float})
  end
end
