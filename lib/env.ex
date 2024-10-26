defmodule Env do
  def get(key, default \\ nil) do
    :samowar
    |> Application.get_env(key, default)
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
