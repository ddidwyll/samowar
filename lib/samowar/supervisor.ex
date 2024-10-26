defmodule Samowar.Supervisor do
  use Supervisor

  def init(_ \\ :-) do
    :ok
  end

  def start_link(_ \\ :-) do
    childs()
    |> Supervisor.start_link(
      strategy: :one_for_one,
      name: __MODULE__
    )
  end

  defp childs do
    [
      registry(),
      mqtt_connection(),
      device(),
      logger(),
      app()
    ]
  end

  defp registry do
    {
      Registry,
      keys: :unique, name: Bus.Subscribers
    }
  end

  defp mqtt_connection do
    %{
      id: Mqtt.Connection,
      start: {Mqtt.Connection, :start_link, []}
    }
  end

  defp app, do: {App, []}
  defp logger, do: {Bus.Logger, []}
  defp device, do: {Device.Subscriber, []}
end
