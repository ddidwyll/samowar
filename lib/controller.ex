defmodule App do
  use Bus.Subscriber, app: 0

  def state, do: GenServer.call(@sub_name, :get_state)
  def get(key), do: state()[key]

  def init(_) do
    %{
      mqtt: :down
    }
    |> OK.wrap()
  end

  def handle_call(:get_state, _, state),
    do: {:reply, state, state}

  def handle_call(%{from: :mqtt, type: :connection, payload: payload}, _, state)
      when payload in [:up, :down] do
    # request_mqtt({:connection, payload}, state)
    {:reply, {:ok, payload}, %{state | mqtt: payload}}
  end

  def handle_call(_, _, state),
    do: {:reply, {:ok, :skip}, state}

  # defp request_mqtt({:connection, :up}, state) do
  #   %{subscribe: state[:subscriptions] || []}
  #   |> Bus.push!(:app, :mqtt_request)
  # end
end
