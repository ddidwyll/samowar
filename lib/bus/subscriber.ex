defmodule Bus.Subscriber do
  defmacro __using__([{name, order}]) do
    quote location: :keep do
      use GenServer

      @registry Bus.Subscribers

      def start_link(_) do
        name = unquote(name)
        order = unquote(order)
        params = [name: {:via, Registry, {@registry, name}}]

        with {:ok, pid} <- __MODULE__ |> GenServer.start_link([], params),
             :ok <- Registry.put_meta(@registry, name, order) do
          {:ok, pid}
        else
          error -> raise error
        end
      end
    end
  end
end
