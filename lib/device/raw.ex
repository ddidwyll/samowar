defmodule Device.Raw do
  use State.WithDesired

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

  def defaults do
    desired =
      %{
        # term_d_m: 78.0,
        # press_c_m:,
        # term_c_max:,
        # term_c_min:,
        # term_k_max:,
        # term_nasos:,
        # power_m: 110,
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

    %{desired: desired}
  end

  def params do
    [
      %{id: "term_d", name: "Верх", type: :float, unit: "°C"},
      %{id: "term_c", name: "Низ", type: :float, unit: "°C"},
      %{id: "term_k", name: "Куб", type: :float, unit: "°C"},
      %{id: "power", name: "Нагрев факт", type: :int, unit: "Вт", round: 5},
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
    |> Enum.map(fn
      %{write: :suffix, id: id} = param -> %{param | write: "#{id}#{@write_suffix}"}
      %{write: true, id: id} = param -> %{param | write: to_string(id)}
      %{write: <<_::binary>>} = param -> param
      param -> param[:write] |> put_in(nil)
    end)
  end

  def handle_change(param, type, value) do
    value |> Bus.push(:"raw_#{type}", :change_notice, param.key)

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
    |> Log.row_stop({name, value}, "RAW")
  end
end
