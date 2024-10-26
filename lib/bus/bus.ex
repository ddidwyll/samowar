defmodule Bus do
  alias Bus.{Subscribers, Event}

  def publish(payload, from, type) do
    event = Event.cast!(from, type, payload)

    Subscribers.all()
    |> OK.map_all(fn {_, pid} ->
      GenServer.call(pid, event)
    end)
  end

  def publish!(payload, from, type) do
    case publish(payload, from, type) do
      {:error, error} -> raise error
      {:ok, results} -> results
    end
  end
end
