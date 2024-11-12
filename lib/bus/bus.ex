defmodule Bus do
  def push(event_data) do
    event = Bus.Event.cast!(event_data)

    # IO.puts("<<< Push:\t\t#{event}")
    GenStage.cast(Bus.Producer, {:push, event})
  end

  def push(payload \\ nil, from, type, name) do
    push(%{
      payload: payload,
      from: from,
      type: type,
      name: name
    })
  end
end
