defmodule State do
  defmacro __using__(_) do
    quote location: :keep do
      use Agent

      defstruct []

      @this __MODULE__
      @behaviour Access

      def all, do: @this |> Agent.get(& &1.state)

      def get(key, default \\ nil)

      def get(keys, default) when is_list(keys) do
        struct(@this)
        |> get_in(List.wrap(keys))
        |> case do
          nil -> default
          value -> value
        end
      end

      def get(key, default) do
        case struct(@this) |> Access.fetch(key) do
          {:ok, value} -> value
          _ -> default
        end
      end

      def update(keys, fun) do
        struct(@this)
        |> update_in(List.wrap(keys), fun)
      end

      def put(keys, val) do
        struct(@this)
        |> put_in(List.wrap(keys), val)
      end

      def start_link(_ \\ :-) do
        store = %{state: %{}, meta: %{}}

        @this
        |> function_exported?(:state, 0)
        |> case do
          true -> fn -> store.state |> put_in(apply(@this, :state, [])) end
          false -> fn -> store end
        end
        |> Agent.start_link(name: @this)
      end

      @impl true
      def fetch(_, key) do
        @this
        |> Agent.get(fn %{state: state} ->
          Map.fetch(state, key)
        end)
      end

      @impl true
      def get_and_update(_, key, fun) do
        @this
        |> Agent.get_and_update(fn %{state: state} = store ->
          current = Map.get(state, key)

          with {current, new} <- fun.(current),
               new_state <- Map.put(state, key, new) do
            {{current, struct(@this)}, %{store | state: new_state}}
          else
            :pop -> {{current, struct(@this)}, %{store | state: Map.drop(state, [key])}}
            error -> De.bug({error, state, current}, :error)
          end
        end)
      end

      @impl true
      def pop(_, key) do
        @this
        |> Agent.get_and_update(fn %{state: state} = store ->
          with {value, new_state} <- state |> Map.pop(key) do
            {{value, struct(@this)}, new_state}
          else
            error -> De.bug({error, state}, :error)
          end
        end)
      end
    end
  end
end
