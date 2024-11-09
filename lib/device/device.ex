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

  @kontaktor %{"Power OFF" => "выкл", "Power ON" => "вкл"}

  @default_desired %{
    # term_d_m: 78.0,
    # press_c_m:,
    # term_c_max:,
    # term_c_min:,
    # term_k_max:,
    # term_nasos:,
    power_m: 100.0
    # otbor:,
    # time_stop:,
    # otbor_minus:,
    # min_otb:,
    # sek_otb:,
    # otbor_g_1:,
    # otbor_g_2:,
    # otbor_t:,
    # delta_t:,
    # term_k_m:,
    # work:,
    # kontaktor:
  }

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
    %{id: "kontaktor", name: "Контактор", type: @kontaktor, write: true},
    %{id: "num_error", name: "Ошибка", type: :int},
    %{id: "count_vent", name: "??? count_vent", type: :int},
    %{id: "term_vent", name: "??? term_vent", type: :float},
    %{id: "term_v", name: "??? term_v", type: :float}
  ]

  def state do
    acc = %{params: %{}, state: %{desired: %{}, current: %{}}}

    build_write = fn
      %{write: :suffix, id: id} = param -> %{param | write: "#{id}#{@write_suffix}"}
      %{write: true, id: id} = param -> %{param | write: to_string(id)}
      %{write: <<_::binary>>} = param -> param
      param -> param[:write] |> put_in(nil)
    end

    @params
    |> Enum.reduce(acc, fn %{id: id} = param, acc ->
      atom = String.to_atom(id)

      acc[:params][id]
      |> put_in(build_write.(%{param | id: atom}))
      |> put_in([:state, :current, atom], nil)
      |> put_in([:state, :desired, atom], @default_desired[atom])
    end)
  end

  def change(%{id: param_id, value: value}, type \\ :desired),
    do: change(param_id, value, type)

  def change(param_id, value, type) do
    with true <- (type in [:desired, :current] && is_binary(value)) || is_number(value),
         {:ok, param_id} <- check_id(param_id),
         %{id: param_id} = param <- Device.get([:params, param_id]),
         {:ok, value} <- cast_value(value, param),
         {:changed, value} <- Device.change?([:state, type, param_id], value) do
      check_desired(param)
      change_hook(param_id, value.new)
      log(param, type, value)
    else
      :not_changed -> :noop
      error -> De.bug({param_id, value, type, error}, "Device wrong param_id")
    end
  end

  def change_hook(_, _), do: :noop

  defp check_desired(%{id: param_id} = param) do
    with %{^param_id => desired} <- Device.get([:state, :desired]),
         %{^param_id => current} <- Device.get([:state, :current]),
         false <- is_nil(desired) || is_nil(current),
         false <- equal?(desired, current, param) do
      IO.puts("!?! Device Need Change")
    else
      _ -> :noop
    end
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

  defp cast_value(value, %{type: :string})
       when is_binary(value),
       do: {:ok, value}

  defp cast_value(key, %{type: opts}) when is_map(opts) do
    with key <- to_string(key) |> String.trim(),
         {:ok, _name} <- Map.fetch(opts, key) do
      {:ok, key}
    else
      _ -> :error
    end
  end

  defp cast_value(value, %{type: type}) do
    {:error, "Broken [#{inspect(type)}]: #{inspect(value)}"}
  end

  defp equal?(value_a, value_b, param) do
    cast_value(value_a, param) === cast_value(value_b, param)
  end

  defp log(%{name: param_name, id: param_id} = param, type, value) do
    name =
      if unit = param[:unit],
        do: "#{param_name} (#{unit})",
        else: param_name

    [type, param_id]
    |> Log.row({name, value}, "DEV")
  end
end
