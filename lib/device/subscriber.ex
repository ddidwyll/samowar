defmodule Device.Subscriber do
  use Bus.Subscriber, device: 1

  def init do
    De.bug(__MODULE__, :init)
    {:ok, %{}}
  end

  def handle_call(event, _, state) do
    De.bug(event, __MODULE__)

    {:reply, {:ok, :ok}, state}
  end
end
