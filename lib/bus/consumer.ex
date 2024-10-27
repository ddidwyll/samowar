defmodule Bus.Consumer do
  use Bus.Stage, :consumer

  def handle_event(%{from: :mqtt, type: :connection, payload: payload})
      when payload in [:up, :down] do
    request_mqtt({:connection, payload})
  end

  def handle_event(event) do
    IO.puts("### Consumer: #{event}")
  end

  defp request_mqtt({:connection, :up}) do
    :subscribe |> Bus.push!(:consumer, :mqtt_request)
  end

  defp request_mqtt(_), do: :ok
end
