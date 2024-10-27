defmodule Bus.Stage do
  defmacro __using__(:producer_consumer) do
    quote location: :keep do
      use GenStage

      @this __MODULE__

      def start_link(subscribe_to) do
        GenStage.start_link(@this, subscribe_to, name: @this)
      end

      def init(subscribe_to) do
        {:producer_consumer, nil, subscribe_to: {subscribe_to, [max_demand: 1]}}
      end

      def handle_events([%Bus.Event{} = event], _, state) do
        args =
          cond do
            function_exported?(@this, :handle_event, 2) -> [event, state]
            function_exported?(@this, :handle_event, 1) -> [event]
            true -> nil
          end

        if args do
          case apply(@this, :handle_event, args) do
            {:state, state} -> {:noreply, [event], state}
            {:event, event} -> {:noreply, [event], state}
            {:error, error} -> raise error
            _ -> {:noreply, [event], state}
          end
        else
          De.bug(event, @this)
          {:noreply, [event], state}
        end
      end

      def handle_events(events, _, state) do
        raise "unexpected events: #{inspect(events)}, state: #{inspect(state)}"
      end

      defoverridable init: 1, handle_events: 2
    end
  end

  defmacro __using__(_) do
    quote location: :keep do
      use GenStage

      @this __MODULE__

      def start_link(args) do
        GenStage.start_link(@this, args, name: @this)
      end
    end
  end
end
