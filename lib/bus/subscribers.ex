defmodule Bus.Subscribers do
  @registry __MODULE__
  @all_specs [{{:"$1", :"$2", :_}, [], [{{:"$1", :"$2"}}]}]

  def lookup(name) do
    @registry
    |> Registry.lookup(name)
    |> case do
      [{pid, _}] -> {:ok, pid}
      _ -> {:error, :not_found}
    end
  end

  def set_order(name, order) do
    @registry |> Registry.put_meta(name, order)
  end

  def get_order(name) do
    case @registry |> Registry.meta(name) do
      {:ok, order} -> order
      _ -> 999
    end
  end

  def all do
    @registry
    |> Registry.select(@all_specs)
    |> Enum.sort_by(fn {name, _} ->
      get_order(name)
    end)
  end
end
