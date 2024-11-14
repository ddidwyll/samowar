defmodule State.WithDesired do
  defmacro __using__(_) do
    quote location: :keep do
      use State

      def params, do: %{}
      def defaults, do: %{}

      def state do
        defaults = defaults()
        acc = %{params: %{}, state: %{desired: %{}, current: %{}}}

        params()
        |> Enum.reduce(acc, fn param, acc ->
          id = Param.prepare_id(param.id)
          key = Param.build_key(id)

          param =
            param
            |> Map.merge(%{id: id, key: key})
            |> Param.cast()

          unless param.write do
            acc
          else
            acc[:state][:desired][key]
            |> put_in(defaults[key])
          end
          |> put_in([:params, id], param)
          |> put_in([:state, :current, key], nil)
        end)
      end

      def change(%{id: param_id, value: value}, type \\ :desired),
        do: change(param_id, value, type)

      def change(param_id, value, type) do
        with true <- type in [:desired, :current] && (is_binary(value) || is_number(value)),
             param_id <- Param.prepare_id(param_id),
             %{key: param_key} = param <- @this.get([:params, param_id]),
             {:ok, value} <- Value.parse(value, param),
             {:changed, value} <- @this.change?([:state, type, param_key], value) do
          handle_change(param, type, value)
          handle_change(param, type, value.new, value.old)
          check_desired(param)
        else
          :not_changed -> :noop
          error -> Error.log({param_id, value, type, error}, "#{@this} wrong param_id")
        end
      end

      def handle_change(_, _, _), do: :noop
      def handle_change(_, _, _, _), do: :noop

      defp check_desired(%{key: param_key} = param) do
        with %{^param_key => desired} <- @this.get([:state, :desired]),
             %{^param_key => current} <- @this.get([:state, :current]),
             false <- is_nil(desired) || is_nil(current),
             false <- Value.equal?(desired, current, param) do
          handle_inconsistent(param, desired, current)
        else
          _ -> :noop
        end
      end

      def handle_inconsistent(_, _, _), do: :noop

      defoverridable defaults: 0,
                     handle_inconsistent: 3,
                     handle_change: 4,
                     handle_change: 3,
                     params: 0,
                     state: 0
    end
  end
end
