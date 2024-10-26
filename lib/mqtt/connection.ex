defmodule Mqtt.Connection do
  def start_link do
    Tortoise.Connection.start_link(
      client_id: client_id(),
      server: tortoise_server(),
      handler: {Mqtt.Handler, []},
      subsriptions: subscriptions()
    )
  end

  defp client_id, do: Env.get!(:client_id)

  defp subscriptions, do: Env.get(:subsriptions, [])

  defp tortoise_server do
    {
      Tortoise.Transport.Tcp,
      host: Env.get!(:brocker_host), port: Env.get!(:brocker_port)
    }
  end
end
