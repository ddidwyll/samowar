defmodule Samowar.Application do
  use Application

  def start(_type, _args) do
    children = [{Samowar.Supervisor, []}]
    opts = [strategy: :one_for_one, name: Samowar]

    Supervisor.start_link(children, opts)
  end
end
