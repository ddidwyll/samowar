defmodule Bus.Consumer do
  use Bus.Stage, :consumer

  def init(subscribe_to) do
    {:consumer, nil, subscribe_to: {subscribe_to, [max_demand: 1]}}
  end

  def handle_events([event], _, _) do
    IO.puts("### consumer: #{event}")

    {:noreply, [], nil}
  end
end
