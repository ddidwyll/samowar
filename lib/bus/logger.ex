defmodule Bus.Logger do
  use Bus.Subscriber, logger: 10

  require Logger

  @state nil

  def init, do: {:ok, @state}

  def handle_call(event, _, _) do
    Logger.warn(event)
    {:reply, {:ok, :ok}, @state}
  end
end
