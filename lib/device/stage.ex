defmodule Device.Stage do
  use Bus.Stage, :producer_consumer

  def state do
    %{}
  end

  def handle_event(event) do
    IO.puts(">>> Device: #{event}")
  end
end
