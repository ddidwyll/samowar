defmodule Value do
  def cast(value, %{type: type})
      when is_binary(value) and type in [:int, :float] do
    %{float: Float, int: Integer}[type]
    |> apply(:parse, [String.trim(value)])
    |> case do
      {float, _} -> {:ok, float}
      _ -> :error
    end
  end

  def cast(value, %{type: type})
      when is_number(value) and type in [:float, :int],
      do: {:ok, value}

  def cast(value, %{type: :string})
      when is_binary(value),
      do: {:ok, value}

  def cast(key, %{type: opts}) when is_map(opts) do
    with key <- to_string(key) |> String.trim(),
         {:ok, _name} <- Map.fetch(opts, key) do
      {:ok, key}
    else
      _ -> :error
    end
  end

  def cast(value, %{type: type}) do
    {:error, "Broken [#{inspect(type)}]: #{inspect(value)}"}
  end

  def equal?(value_a, value_b, param) do
    cast(value_a, param) === cast(value_b, param)
  end
end
