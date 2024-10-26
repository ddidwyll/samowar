defmodule Device.Subscriber do
  use Bus.Subscriber, device: 1

  def init(_) do
    {:ok, %{}}
  end

  def handle_call(_event, _, state) do
    {:reply, {:ok, :ok}, state}
  end
end
