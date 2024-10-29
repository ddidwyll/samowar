defmodule Device do
  use State

  @doc "Яр-самовар"
  @write_suffix "_new"

  @work_enum %{
    "0" => "стоп",
    "1" => "старт",
    "4" => "разгон",
    "5" => "выключение разгона",
    "6" => "отбор выключен",
    "7" => "отбор голов периодикой",
    "8" => "отбор тела",
    "9" => "отбор голов покапельно",
    "10" => "отбор подголовников"
  }

  @kontaktor %{"0" => "выкл", "1" => "вкл"}

  @params [
    %{id: "term_d", name: "Верх", type: :float, unit: "°C"},
    %{id: "term_c", name: "Низ", type: :float, unit: "°C"},
    %{id: "term_k", name: "Куб", type: :float, unit: "°C"},
    %{id: "power", name: "Нагрев факт", type: :int, unit: "Вт"},
    %{id: "press_a", name: "Давление", type: :float, unit: "мм"},
    %{id: "flag_otb", name: "Режим работы", type: :string},
    %{id: "term_d_m", name: "Верх макc", type: :float, write: :suffix, unit: "°C"},
    %{id: "press_c_m", name: "Макс давление", type: :float, write: :suffix, unit: "мм"},
    %{id: "term_c_max", name: "Царга макc", type: :float, write: :suffix, unit: "°C"},
    %{id: "term_c_min", name: "Царга мин", type: :float, write: :suffix, unit: "°C"},
    %{id: "term_k_max", name: "Куб макc", type: :float, write: :suffix, unit: "°C"},
    %{id: "term_nasos", name: "Включение воды", type: :float, write: :suffix, unit: "°C"},
    %{id: "power_m", name: "Нагрев", type: :int, write: :suffix, unit: "Вт"},
    %{id: "otbor", name: "Отбор", type: :int, write: :suffix, unit: "?"},
    %{id: "time_stop", name: "Макс время СС", type: :int, write: :suffix, unit: "?"},
    %{id: "otbor_minus", name: "Декремент", type: :int, write: :suffix, unit: "?"},
    %{id: "min_otb", name: "Период голов", type: :int, write: :suffix, unit: "мин"},
    %{id: "sek_otb", name: "Время голов", type: :int, write: :suffix, unit: "сек"},
    %{id: "otbor_g_1", name: "ШИМ голов", type: :int, write: :suffix, unit: "?"},
    %{id: "otbor_g_2", name: "ШИМ подголов", type: :int, write: :suffix, unit: "?"},
    %{id: "otbor_t", name: "ШИМ тела", type: :int, write: :suffix, unit: "?"},
    %{id: "delta_t", name: "Дельта старта", type: :float, write: :suffix, unit: "°C"},
    %{id: "term_k_m", name: "Разгон до", type: :float, write: "term_k_r", unit: "°C"},
    %{id: "work", name: "Работа", type: @work_enum, write: true},
    %{id: "kontaktor", name: "Контактор", type: @kontaktor, write: true}
  ]

  def state do
    acc = %{params: %{}, state: %{}}

    @params
    |> Enum.reduce(acc, fn %{id: id} = param, acc ->
      atom = String.to_atom(id)

      acc[:params][id]
      |> put_in(%{param | id: atom})
      |> put_in([:state, atom], nil)
    end)
  end

  def change(param_id, value) do
    with true <- is_binary(value) || is_number(value),
         {:ok, param_id} <- check_id(param_id),
         %{id: param_id} = param <- Device.get([:params, param_id]),
         {:ok, value} <- cast_value(value, param),
         {:new, new} <- Device.change?([:state, param_id], value) do
      change_hook(param_id, new)
      log(param_id, new)
    else
      error -> De.bug({param_id, value, error}, "Device wrong param_id")
    end
  end

  def change_hook(_, _), do: :noop

  defp log(param_id, value) do
    value = if is_binary(value), do: value, else: inspect(value)

    IO.puts("### Device change:\t#{param_id} = #{value}")
  end

  defp check_id(param_id) when is_binary(param_id) do
    param_id |> String.trim() |> String.downcase() |> OK.wrap()
  end

  defp check_id(_), do: :error

  defp cast_value(value, %{type: type})
       when is_binary(value) and type in [:int, :float] do
    %{float: Float, int: Integer}[type]
    |> apply(:parse, [String.trim(value)])
    |> case do
      {float, ""} -> {:ok, float}
      _ -> :error
    end
  end

  defp cast_value(value, %{type: type})
       when is_number(value) and type in [:float, :int],
       do: {:ok, value}

  defp cast_value(key, %{type: opts}) when is_map(opts) do
    with key <- to_string(key) |> String.trim(),
         {:ok, _name} <- Map.fetch(opts, key) do
      {:ok, key}
    else
      _ -> :error
    end
  end
end
