defmodule Bus.Subscriber do
  defmacro __using__([{name, order}]) do
    quote location: :keep do
      use GenServer

      alias Bus.Subscribers

      @this __MODULE__
      @registry Bus.Subscribers
      @sub_name {:via, Registry, {@registry, unquote(name)}}

      def start_link(_) do
        with {:ok, pid} <- GenServer.start_link(@this, [], [name: @sub_name]),
             :ok <- @registry.set_order(unquote(name), unquote(order)) do
          {:ok, pid}
        else
          error -> raise error
        end
      end
    end
  end
end
