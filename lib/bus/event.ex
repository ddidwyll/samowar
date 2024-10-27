defmodule Bus.Event do
  alias Bus.Event

  defstruct from: nil,
            type: nil,
            meta: %{},
            payload: nil,
            timestamp: nil

  def cast!(%{from: from, type: type} = data)
      when not is_nil(from) and not is_nil(type) do
    %Event{
      from: from,
      type: type,
      payload: data[:payload],
      meta: data[:meta] || %{},
      timestamp: System.os_time()
    }
  end

  def cast!(data), do: raise("broken event: #{inspect(data)}")

  def cast!(payload, from, type, meta \\ %{}) do
    cast!(%{from: from, type: type, payload: payload, meta: meta})
  end

  defimpl String.Chars, for: Event do
    def to_string(event) do
      payload =
        case event.payload do
          payload when is_binary(payload) -> payload
          payload when is_number(payload) -> Kernel.to_string(payload)
          payload when is_atom(payload) -> Atom.to_string(payload)
          payload when is_map(payload) -> JSON.encode!(payload)
          payload -> inspect(payload)
        end

      [
        event.from,
        event.type,
        payload,
        event.timestamp
      ]
      |> Enum.join("|")
    end
  end
end
