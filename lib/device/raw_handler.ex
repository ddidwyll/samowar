defmodule Device.Raw.Handler do
  def inconsistent(%{write: write_id}, desired)
      when is_binary(write_id) do
    to_string(desired)
    |> Bus.push(:raw, :mqtt_request, write_id)
  end

  def inconsistent(_, _), do: :noop
  def inconsistent(_, _, _), do: :noop

  def change(_, _, _), do: :noop
end
