defmodule Bus do
  def push!(event_data) do
    event = Bus.Event.cast!(event_data)

    GenStage.cast(Bus.Producer, {:push, event})
  end

  def push!(payload, from, type, meta \\ %{}) do
    push!(%{
      payload: payload,
      from: from,
      type: type,
      meta: meta
    })
  end
end
