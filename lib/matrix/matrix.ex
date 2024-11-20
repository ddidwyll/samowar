defmodule Matrix do
  defmacro __using__(adapter: adapter) do
    alias MatrixAppService.Adapter.{Room, User, Transaction}

    behaviour = %{room: Room, user: User, transaction: Transaction}[adapter]

    quote location: :keep do
      alias MatrixAppService.Client

      @behaviour unquote(behaviour)

      defp client(user_id \\ Env.get(:matrix_user_id)) do
        Client.client(user_id: user_id)
        |> Map.update(:base_url, "", &to_string/1)
        |> Map.take([:base_url, :acces_token, :device_id, :user_id, :storage])
        |> Map.to_list()
      end
    end
  end
end
