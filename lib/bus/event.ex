defmodule Bus.Event do
  alias Bus.Event

  defstruct [
    from: nil,
    type: nil,
    payload: nil
  ]

  def cast!(%{from: from, type: type} = data)
      when not is_nil(from) and not is_nil(type) do
    Event |> struct(data)
  end

  def cast!(data), do: raise data

  def cast!(from, type, payload) do
    cast!(%{from: from, type: type, payload: payload})
  end

  defimpl String.Chars, for: Event do
    def to_string(event) do
      payload =
        case event.payload do
          payload when is_binary(payload) -> payload
          payload when is_map(payload) -> JSON.encode!(payload)
          payload -> inspect(payload)
        end

      [
        event.from,
        event.type,
        payload
      ]
      |> Enum.join("|")
    end
  end
end
