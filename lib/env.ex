defmodule Env do
  def all do
    :samowar
    |> Application.get_all_env()
  end

  def get(key, default \\ nil) do
    :samowar
    |> Application.get_env(key, default)
  end

  def get!([_ | _] = keys) do
    Enum.reduce(keys, %{}, fn key, acc ->
      acc[key] |> put_in(get!(key))
    end)
  end

  def get!(key) do
    :samowar
    |> Application.fetch_env(key)
    |> case do
      :error -> raise "Env #{key} not found"
      {:ok, value} -> value
    end
  end

  def is(env), do: env == get(:env)
end
