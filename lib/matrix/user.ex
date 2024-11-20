defmodule Matrix.User do
  use Matrix, adapter: :user

  def query_user(user_id) do
    [
      inhibit_login: false,
      device_id: "SAMOWAR",
      initial_device_display_name: "Samowar server",
      kind: :user
    ]
    |> MatrixAppService.Client.register(client(user_id))
    |> De.bug_full(user_id)

    :ok
  end
end
