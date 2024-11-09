defmodule Error do
  def log(some), do: De.bug(some, "Err")
  def log(some, name), do: De.bug(some, name)
end
