defmodule Bus.Logger do
  use Bus.Subscriber, logger: 10

  require Logger

  @state nil

  def init(_), do: {:ok, @state}

  def handle_call(event, _, _) do
    "EVENT:[#{event}]" |> Logger.info()

    {:reply, {:ok, :ok}, @state}
  end
end
