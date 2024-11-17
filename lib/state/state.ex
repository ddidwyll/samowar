defmodule State do
  defmacro __using__(_) do
    quote location: :keep do
      use Agent

      defstruct []

      @this __MODULE__
      @behaviour Access

      def all, do: @this |> Agent.get(& &1.state)

      def get(key, default \\ nil)

      def get(path, default) when is_list(path) do
        case struct(@this) |> get_in(path) do
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

      def fetch(key_or_path) do
        case get(key_or_path, :completely_by_accident) do
          :completely_by_accident -> :error
          value -> {:ok, value}
        end
      end

      def update(path, fun) do
        struct(@this) |> update_in(List.wrap(path), fun)
      end

      def put(path, val) do
        struct(@this) |> put_in(List.wrap(path), val)
      end

      def change?(path, val_fun) do
        @this
        |> Agent.get_and_update(fn store ->
          path = [:state | List.wrap(path)]
          old = store |> get_in(path)

          new =
            if is_function(val_fun, 1),
              do: val_fun.(old),
              else: val_fun

          if new != old do
            result = {:changed, %{new: new, old: old}}
            {result, store |> put_in(path, new)}
          else
            {:not_changed, store}
          end
        end)
      end

      def start_link(_ \\ :-) do
        store = %{state: %{}, meta: %{}}

        if function_exported?(@this, :state, 0) do
          fn -> %{store | state: apply(@this, :state, [])} end
        else
          fn -> store end
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
            error -> Error.log({error, state, current}, :error)
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
            error -> Error.log({error, state}, :error)
          end
        end)
      end
    end
  end
end
