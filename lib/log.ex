defmodule Log do
  @pad " "
  @joiner "/"
  @prefix_col_width 3
  @key_col_width 25
  @val_col_width 75
  @val_name_width 25
  @val_val_width 25

  def row(key, val, prefix \\ nil),
    do: build_row(key, val, prefix) |> IO.puts()

  def build_row(key, val, prefix \\ nil)

  def build_row(key, {name, %{old: nil, new: new}}, prefix),
    do: build_row(key, {name, new}, prefix)

  def build_row(key, {name, %{old: old, new: new}}, prefix) do
    build_row(key, {name, %{old: nil, new: new}}, prefix)
    |> Kernel.<>(" (#{trunc(old, @val_val_width)})")
  end

  def build_row(key, {name, val}, prefix) do
    name = to_len(name, @val_name_width)
    val = to_len(val, @val_val_width)

    build_row(key, "#{name} #{val}", prefix)
  end

  def build_row([_ | _] = keys, val, prefix) do
    keys
    |> Enum.reject(&is_nil/1)
    |> Enum.join(@joiner)
    |> build_row(val, prefix)
  end

  def build_row(key, val, prefix) do
    [
      {val, :trunc, @val_col_width},
      {key, :to_len, @key_col_width},
      {prefix, :trunc, @prefix_col_width}
    ]
    |> Enum.reduce([], fn
      {nil, _, _}, acc -> acc
      {string, :trunc, len}, acc -> [trunc(string, len) | acc]
      {string, :to_len, len}, acc -> [to_len(string, len) | acc]
    end)
    |> Enum.join(@pad)
  end

  def trunc(val, len)
      when is_atom(val)
      when is_number(val),
      do: to_string(val) |> trunc(len)

  def trunc(string, len)
      when is_binary(string) and is_integer(len),
      do: String.slice(string, 0, len)

  def trunc(a, b), do: raise(inspect({a, b}))

  def to_len(string, len) do
    trunc(string, len)
    |> String.pad_trailing(len, @pad)
  end
end
