defmodule Bus.Subscriber do
  defmacro __using__([{name, order}]) do
    quote location: :keep do
      use GenServer

      @this __MODULE__
      @registry Bus.Subscribers
      @sub_name {:via, Registry, {@registry, unquote(name)}}

      def start_link(_) do
        with {:ok, pid} <- GenServer.start_link(@this, [], name: @sub_name),
             :ok <- @registry.set_order(unquote(name), unquote(order)) do
          {:ok, pid}
        else
          error -> raise error
        end
      end

      def init(_), do: {:ok, nil}

      def handle_cast(event, state) do
        args =
          cond do
            function_exported?(@this, :handle_event, 2) -> [event, state]
            function_exported?(@this, :handle_event, 1) -> [event]
            true -> nil
          end

        if args do
          case apply(@this, :handle_event, args) do
            :ok -> {:reply, :ok, state}
            {:state, new_state} -> {:reply, :ok, new_state}
            {:reply, reply} -> {:reply, reply, state}
            {:ok, _} = reply -> {:reply, reply, state}
            {:error, _} = reply -> {:reply, reply, state}
            unexpected -> raise unexpected
          end
        else
          De.bug(event, @this)
          {:reply, :ok, state}
        end
      end

      defoverridable init: 1, handle_cast: 2
    end
  end
end
