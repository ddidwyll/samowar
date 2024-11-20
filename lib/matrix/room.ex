defmodule Matrix.Room do
  use Matrix, adapter: :room

  def query_alias(room_alias) do
    [
      room_alias_name: room_alias,
      preset: :public_chat
    ]
    |> MatrixAppService.Client.create_room(client())
    |> De.bug_full(room_alias)

    :ok
  end
end
