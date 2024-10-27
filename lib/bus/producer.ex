defmodule Bus.Producer do
  use Bus.Stage, :producer

  def init(_) do
    {:producer, %{demand: false, events: []}}
  end

  def handle_subscribe(_, _, _, events) do
    {:automatic, events}
  end

  def handle_demand(_, %{events: [event | events]}) do
    {:noreply, [event], %{events: events, demand: false}}
  end

  def handle_demand(_, %{events: []}) do
    {:noreply, [], %{events: [], demand: true}}
  end

  def handle_cast({:push, event}, %{events: events, demand: false}) do
    {:noreply, [], %{events: events ++ [event], demand: false}}
  end

  def handle_cast({:push, event}, %{events: [next_event | events]}) do
    {:noreply, [next_event], %{events: events ++ [event], demand: false}}
  end

  def handle_cast({:push, event}, _) do
    {:noreply, [event], %{events: [], demand: false}}
  end

  def handle_call(:events, _, events),
    do: {:reply, events, [], events}
end
