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
      registry()
    ]

    [
      app(),
      device(),
      bus_stage(Bus.Producer),
      bus_stage(Mqtt.Client, Bus.Producer),
      bus_stage(Device.Stage, Mqtt.Client),
      bus_stage(Bus.Consumer, Device.Stage),
      mqtt_connection()
    ]
  end

  defp bus_stage(module, subscribe_to \\ []),
    do: {module, subscribe_to}

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

  defp device, do: {Device, []}
end
