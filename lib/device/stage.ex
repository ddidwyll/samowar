defmodule Device.Stage do
  use Bus.Stage, :producer_consumer

  def init(_) do
    {:ok, %{}}
  end

  def handle_event([event], _state) do
    IO.puts(">>> Device: #{event}")
  end
end
