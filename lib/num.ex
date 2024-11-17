defmodule Number do
  def sub(a, b), do: perform(:sub, a, b)
  def add(a, b), do: perform(:add, a, b)
  def div(a, b), do: perform(:div, a, b)
  def mult(a, b), do: perform(:mult, a, b)

  defp perform(fun, a, b) when is_float(a),
    do: perform(fun, Decimal.from_float(a), b)

  defp perform(fun, a, b) when is_float(b),
    do: perform(fun, a, Decimal.from_float(b))

  defp perform(fun, a, b) do
    apply(Decimal, fun, [a, b])
    |> Decimal.normalize()
    |> prepare()
  end

  defp prepare(%{exp: exp} = decimal) when exp < 0 do
    Decimal.to_float(decimal)
    |> Value.to_default_precision(%{type: :float})
  end

  defp prepare(decimal) do
    Decimal.to_integer(decimal)
    |> Value.to_default_precision(%{type: :int})
  end
end
