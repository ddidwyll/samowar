defmodule Bus.Event do
  alias Bus.Event

  defstruct from: nil,
            type: nil,
            name: nil,
            meta: %{},
            payload: nil,
            timestamp: nil

  def cast!(%{from: from, type: type, name: name} = data)
      when not is_nil(from) and not is_nil(type) and not is_nil(name) do
    %Event{
      from: from,
      type: type,
      name: name,
      payload: data[:payload],
      meta: data[:meta] || %{},
      timestamp: System.os_time()
    }
  end

  def cast!(data), do: raise("broken event: #{inspect(data)}")

  def cast!(payload, from, type, name, meta \\ %{}) do
    cast!(%{from: from, type: type, name: name, payload: payload, meta: meta})
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
        |> String.replace(~r/\s+/, " ")

      timestamp =
        event.timestamp
        |> DateTime.from_unix!(:nanosecond)
        |> DateTime.to_time()

      [
        nil: timestamp,
        f: event.from,
        t: event.type,
        n: event.name,
        p: payload
      ]
      |> Enum.map(fn
        {nil, timestamp} -> "[#{timestamp}"
        {key, val} -> "#{key}:#{val}"
      end)
      |> Enum.join("|")
      |> Kernel.<>("]")
    end
  end
end
