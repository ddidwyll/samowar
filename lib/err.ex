defmodule Error do
  def log(some), do: De.bug(some, "Err")
  def log(a, b), do: De.bug({a, b}, "Err")
end
