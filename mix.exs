defmodule Samowar.MixProject do
  use Mix.Project

  def project do
    [
      app: :samowar,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Samowar.Application, []}
    ]
  end

  defp deps do
    [
      {:ok, "~> 2.3"},
      {:json, "~> 1.4"},
      {:decimal, "~> 2.2"},
      {:gen_stage, "~> 1.2"},
      {:tortoise, "~> 0.10.0"}
    ]
  end
end
