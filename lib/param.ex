defmodule Param do
  def prepare_id(id) when is_binary(id) do
    String.downcase(id)
    |> String.replace(~r/[^\w]/, "")
  end

  def prepare_id(some), do: some

  def build_key(atom)
       when is_atom(atom),
       do: atom

  def build_key(string)
       when is_binary(string),
       do: String.to_atom(string)
end
