defmodule Device.Raw.Handler do
  def inconsistent(_, _, _), do: :noop

  def change(_, _, _), do: :noop
end
