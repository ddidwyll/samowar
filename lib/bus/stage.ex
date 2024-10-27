defmodule Bus.Stage do
  defmacro __using__(role) when role in [:producer_consumer, :consumer] do
    quote location: :keep do
      use GenStage

      @this __MODULE__

      def start_link(subscribe_to) do
        GenStage.start_link(@this, subscribe_to, name: @this)
      end

      def init(subscribe_to) do
        state =
          if function_exported?(@this, :state, 0),
            do: apply(@this, :state, []),
            else: nil

        params = [subscribe_to: [{subscribe_to, max_demand: 1}]]

        {unquote(role), state, params}
      end

      def handle_events([%Bus.Event{} = event], _, state) do
        args =
          cond do
            function_exported?(@this, :handle_event, 2) -> [event, state]
            function_exported?(@this, :handle_event, 1) -> [event]
            true -> nil
          end

        next = fn events ->
          case unquote(role) do
            :consumer -> []
            _ -> events
          end
        end

        if args do
          case apply(@this, :handle_event, args) do
            {:state, state} -> {:noreply, next.([event]), state}
            {:event, event} -> {:noreply, next.([event]), state}
            {:events, events} -> {:noreply, next.(events), state}
            {:ok, event, state} -> {:noreply, next.([event]), state}
            {:error, error} -> raise error
            _ -> {:noreply, next.([event]), state}
          end
        else
          De.bug(event, @this)
          {:noreply, next.([event]), state}
        end
      end

      def handle_events(events, _, state) do
        raise "unexpected events: #{inspect(events)}, state: #{inspect(state)}"
      end

      defoverridable init: 1, handle_events: 3
    end
  end

  defmacro __using__(:producer) do
    quote location: :keep do
      use GenStage

      @this __MODULE__

      def start_link(args) do
        GenStage.start_link(@this, args, name: @this)
      end
    end
  end
end
