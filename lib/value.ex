defmodule Value do
  def parse(value, %{type: type})
      when is_binary(value) and type in [:int, :float] do
    %{float: Float, int: Integer}[type]
    |> apply(:parse, [String.trim(value)])
    |> case do
      {float, _} -> {:ok, float}
      _ -> :error
    end
  end

  def parse(value, %{type: type})
      when is_number(value) and type in [:float, :int],
      do: {:ok, value}

  def parse(value, %{type: :string})
      when is_binary(value),
      do: {:ok, value}

  def parse(key, %{type: opts}) when is_map(opts) do
    with key <- to_string(key) |> String.trim(),
         {:ok, _name} <- Map.fetch(opts, key) do
      {:ok, key}
    else
      _ -> :error
    end
  end

  def parse(value, param) do
    {param, value}
    |> Error.log(:broken_value_or_param)

    :error
  end

  def equal?(value_a, value_b, param) do
    parse(value_a, param) == parse(value_b, param)
  end
end
