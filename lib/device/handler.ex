defmodule Device.Handler do
  def inconsistent(_, _), do: :noop
  def inconsistent(_, _, _), do: :noop

  def change(_, _, _), do: :noop
end
