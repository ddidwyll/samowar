defmodule Param do
  defstruct [:id, :name, :key, :type, :unit, :write]

  def cast(%{} = param), do: struct(Param, param)

  def cast(some), do: some |> Error.log(:broken_param)

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
