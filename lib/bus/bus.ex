defmodule Bus do
  alias Bus.{Subscribers, Event}

  def publish(from, type, payload) do
    event = Event.cast!(from, type, payload)

    Subscribers.all()
    |> OK.map_all(fn {_, pid} ->
      GenServer.call(pid, event)
    end)
  end

  def publish!(from, type, payload) do
    case publish(from, type, payload) do
      {:error, error} -> raise error
      {:ok, results} -> results
    end
  end
end
