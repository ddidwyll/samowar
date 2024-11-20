defmodule Mqtt.Connection do
  def start_link do
    Tortoise.Connection.start_link(
      subscriptions: Mqtt.subscriptions(),
      client_id: Mqtt.client_id(),
      handler: {Mqtt.Handler, []},
      server: build_server()
    )
  end

  defp build_server do
    {
      Tortoise.Transport.Tcp,
      host: Mqtt.broker_host(), port: Mqtt.broker_port()
    }
  end
end
